[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [string]$ArtifactRoot = (Join-Path $PSScriptRoot "..\artifacts")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$requiredTargetScope = "one-approved-foundry-agent"
$moduleMarker = "optional-module-responsible-ai-impact-oversight"
$requiredSentinels = @(
    "__REQUIRED_AFFECTED_GROUPS__",
    "__REQUIRED_AI_ACT_RISK_CLASS__",
    "__REQUIRED_AI_ACT_ROLE__",
    "__REQUIRED_AI_SYSTEM_ID__",
    "__REQUIRED_AI_SYSTEM_NAME__",
    "__REQUIRED_ANNEX_III_AREA__",
    "__REQUIRED_APPROVAL_RECORD_STORE__",
    "__REQUIRED_APPROVAL_SLA__",
    "__REQUIRED_APPROVER_ROLE__",
    "__REQUIRED_APPROVER_APP_ROLE_OR_GROUP__",
    "__REQUIRED_ARTICLE_50_OBLIGATIONS__",
    "__REQUIRED_ARTICLE_5_REVIEWER_ROLE__",
    "__REQUIRED_ARTICLE_5_SCREENING_OUTCOME__",
    "__REQUIRED_ASSESSMENT_OWNER_ROLE__",
    "__REQUIRED_BENEFITS_AND_HARMS__",
    "__REQUIRED_BUSINESS_UNIT__",
    "__REQUIRED_CHANGE_REVIEW_CADENCE__",
    "__REQUIRED_CONSEQUENTIAL_TOOL_NAME__",
    "__REQUIRED_DATA_CATEGORIES__",
    "__REQUIRED_DECISION_RETENTION__",
    "__REQUIRED_DISCLOSURE_TEXT__",
    "__REQUIRED_EVALUATION_SUMMARY__",
    "__REQUIRED_FOUNDRY_AGENT_REFERENCE__",
    "__REQUIRED_FOUNDRY_PROJECT_REFERENCE__",
    "__REQUIRED_AGENT_VERSION_REFERENCE__",
    "__REQUIRED_INTENDED_USE__",
    "__REQUIRED_LIMITATIONS__",
    "__REQUIRED_MISUSE_RISKS__",
    "__REQUIRED_MONITORING_ROUTE__",
    "__REQUIRED_PRODUCT_OWNER_ROLE__",
    "__REQUIRED_RAI_CHAMPION_ROLE__",
    "__REQUIRED_REVIEW_DATE__",
    "__REQUIRED_RISK_MITIGATIONS__",
    "__REQUIRED_ROLE_OF_HUMANS__",
    "__REQUIRED_SIGN_OFF_ROLES__",
    "__REQUIRED_STOP_MECHANISM__",
    "__REQUIRED_TECHNICAL_OWNER_ROLE__",
    "__REQUIRED_TOOL_ACTION_CLASS__",
    "__REQUIRED_TOOL_EXECUTION_ROUTE_REFERENCE__",
    "__REQUIRED_UPSTREAM_NOTES__",
    "__REQUIRED_USE_CASE_SUMMARY__",
    "__REQUIRED_USER_NOTICE_CHANNEL__"
)

function Assert-File {
    param([Parameter(Mandatory)][string]$PathValue)
    if (-not (Test-Path -LiteralPath $PathValue -PathType Leaf)) {
        throw "Required module artifact is missing: $PathValue"
    }
}

if ($TargetScope -ne $requiredTargetScope) {
    throw "TargetScope must be '$requiredTargetScope'."
}
foreach ($commandName in @("Get-Content", "Select-String", "ConvertFrom-Json")) {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "Required PowerShell command is unavailable: $commandName"
    }
}
if (-not (Test-Path -LiteralPath $ArtifactRoot -PathType Container)) {
    throw "Artifact root is missing: $ArtifactRoot"
}

$inventoryPath = Join-Path $ArtifactRoot "records\ai-system-inventory-entry.json"
$schemaPath = Join-Path $ArtifactRoot "records\ai-system-inventory-entry.schema.json"
$impactPath = Join-Path $ArtifactRoot "records\impact-assessment.md"
$transparencyPath = Join-Path $ArtifactRoot "records\transparency-note.md"
$oversightPath = Join-Path $ArtifactRoot "oversight\oversight-decision.json"
$runtimePath = Join-Path $ArtifactRoot "runtime\foundry_human_approval_gate.py"
$requirementsPath = Join-Path $ArtifactRoot "runtime\requirements.txt"

foreach ($path in @($inventoryPath, $schemaPath, $impactPath, $transparencyPath, $oversightPath, $runtimePath, $requirementsPath)) {
    Assert-File -PathValue $path
}

$sentinelMatches = @(Get-ChildItem -LiteralPath $ArtifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches)
if ($sentinelMatches.Count -gt 0) {
    $unresolved = @($sentinelMatches |
        ForEach-Object { $_.Matches } |
        ForEach-Object { $_.Value } |
        Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit preflight coverage for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every responsible AI oversight decision before runtime deployment: $($unresolved -join ', ')"
}

$schema = Get-Content -LiteralPath $schemaPath -Raw | ConvertFrom-Json -ErrorAction Stop
$inventory = Get-Content -LiteralPath $inventoryPath -Raw | ConvertFrom-Json -ErrorAction Stop
$oversight = Get-Content -LiteralPath $oversightPath -Raw | ConvertFrom-Json -ErrorAction Stop
$impact = Get-Content -LiteralPath $impactPath -Raw
$transparency = Get-Content -LiteralPath $transparencyPath -Raw

if ($schema.title -ne "Responsible AI system inventory entry") {
    throw "Inventory schema title is unexpected."
}
if ($inventory.implementationSession -ne $moduleMarker -or $oversight.implementationSession -ne $moduleMarker) {
    throw "Artifact implementationSession markers must be '$moduleMarker'."
}
if ($inventory.targetScope -ne $TargetScope -or $oversight.targetScope -ne $TargetScope) {
    throw "TargetScope must match the inventory and oversight records."
}

$allowedRoles = @("provider", "deployer", "provider-and-deployer", "distributor-importer", "downstream-provider")
$allowedRiskClasses = @("prohibited", "high-risk-annex-I", "high-risk-annex-III", "annex-III-exempt-art-6-3", "transparency-art-50", "gpai-based-system", "minimal")
$allowedAnnexAreas = @("biometrics", "critical-infrastructure", "education", "employment", "essential-services", "law-enforcement", "migration", "justice-democracy", "n/a")
$allowedArticle50 = @("interaction-disclosure", "synthetic-content-marking", "emotion-biometric-notice", "deepfake-label", "ai-text-public-interest-label", "none")

if ($inventory.euAiAct.role -notin $allowedRoles) {
    throw "euAiAct.role is not an allowed value."
}
if ($inventory.euAiAct.riskClass -notin $allowedRiskClasses) {
    throw "euAiAct.riskClass is not an allowed value."
}
if ($inventory.euAiAct.riskClass -eq "prohibited") {
    throw "The module must stop for a prohibited AI Act risk class."
}
if ($inventory.euAiAct.annexIIIArea -notin $allowedAnnexAreas) {
    throw "euAiAct.annexIIIArea is not an allowed value."
}
if ($inventory.euAiAct.article5Screening.outcome -notin @("passed", "flagged-resolved", "blocked")) {
    throw "article5Screening.outcome is not an allowed value."
}
if ($inventory.euAiAct.article5Screening.outcome -eq "blocked") {
    throw "The module must stop because the Article 5 screening outcome is blocked."
}
foreach ($obligation in @($inventory.euAiAct.article50Obligations)) {
    if ($obligation -notin $allowedArticle50) {
        throw "article50Obligations contains an unsupported value: $obligation"
    }
}
if (@($inventory.euAiAct.article50Obligations).Count -eq 0) {
    throw "article50Obligations must contain at least one value."
}
if (@($inventory.euAiAct.article50Obligations).Count -gt 1 -and @($inventory.euAiAct.article50Obligations) -contains "none") {
    throw "article50Obligations cannot combine 'none' with another value."
}

if ($oversight.approvalPattern -ne "foundry-hosted-agent-pause-resume") {
    throw "approvalPattern must be foundry-hosted-agent-pause-resume."
}
if ($oversight.gatedTool.actionClass -notin @("write", "irreversible")) {
    throw "gatedTool.actionClass must be write or irreversible."
}
if ($oversight.gatedTool.approvalMode -ne "always_require") {
    throw "gatedTool.approvalMode must be always_require."
}
if ($oversight.gatedTool.rejectionBehavior -ne "do-not-execute-tool") {
    throw "Rejected calls must not execute the tool."
}
if ($oversight.authentication.principalSource -ne "app-service-authentication-headers") {
    throw "Approver identity must come from App Service authentication headers."
}
$requiredPrincipalHeaders = @("X-MS-CLIENT-PRINCIPAL", "X-MS-CLIENT-PRINCIPAL-ID", "X-MS-CLIENT-PRINCIPAL-NAME")
$recordedPrincipalHeaders = @($oversight.authentication.requiredHeaders | Sort-Object -Unique)
if (($recordedPrincipalHeaders -join "|") -ne (($requiredPrincipalHeaders | Sort-Object) -join "|")) {
    throw "requiredHeaders must contain X-MS-CLIENT-PRINCIPAL, X-MS-CLIENT-PRINCIPAL-ID, and X-MS-CLIENT-PRINCIPAL-NAME."
}
if ($oversight.authentication.approverClaim.claimType -notin @("roles", "groups")) {
    throw "approverClaim.claimType must be roles or groups."
}
if ([string]::IsNullOrWhiteSpace([string]$oversight.authentication.approverClaim.claimValue)) {
    throw "approverClaim.claimValue must name the approved app role or group claim value."
}
if ($oversight.records.pendingRequestStore -ne "in-memory-nonproduction") {
    throw "pendingRequestStore must record the nonproduction in-memory boundary for this module."
}
if ($oversight.verification.approvedDecision -ne "approved-executed" -or
    $oversight.verification.rejectedDecision -ne "rejected-not-executed") {
    throw "Verification decisions must remain approved-executed and rejected-not-executed."
}
if ($impact -notmatch "# Responsible AI impact assessment" -or $transparency -notmatch "# System transparency note") {
    throw "Impact assessment and transparency records must keep their expected headings."
}

Write-Host "PASS: responsible AI records are complete for scope '$TargetScope'."
Write-Host "previewSupported=false. Foundry hosted-agent approval code and documentation records have no read-only deployment preview; use this preflight plus the deployed approved and rejected path checks."
