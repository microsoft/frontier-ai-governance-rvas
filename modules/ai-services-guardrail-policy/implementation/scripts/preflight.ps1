[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation,

    [Parameter()]
    [string]$ArtifactsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ArtifactsPath)) {
    $ArtifactsPath = Join-Path $PSScriptRoot "..\artifacts"
}

$implementationSession = "optional-module-ai-services-guardrail-policy"
$requiredSentinels = @(
    "__REQUIRED_ALLOWED_RESOURCE_LOCATION__",
    "__REQUIRED_CHANGE_RECORD_REFERENCE__",
    "__REQUIRED_COMPLIANCE_REVIEW_OWNER__",
    "__REQUIRED_DATA_RESIDENCY_OWNER__",
    "__REQUIRED_DEPLOYMENT_LOCATION__",
    "__REQUIRED_DIAGNOSTIC_REMEDIATION_ROLE_STATUS__",
    "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__",
    "__REQUIRED_PLATFORM_POLICY_OWNER__",
    "__REQUIRED_POLICY_STATE_REVIEW_STATUS__",
    "__REQUIRED_PROMOTION_AUTHORITY__",
    "__REQUIRED_RESTORE_REFERENCE__",
    "__REQUIRED_TARGET_SCOPE_RESOURCE_ID__"
)
$requiredFiles = @(
    "policy\definitions\restrict-foundry-deployment-sku.json",
    "policy\guardrail-decisions.json",
    "policy\initiative.bicep",
    "policy\assignment.bicep",
    "environments\initiative.bicepparam",
    "environments\assignment.bicepparam"
)

if (-not (Test-Path -LiteralPath $ArtifactsPath -PathType Container)) {
    throw "Implementation artifacts folder is missing: $ArtifactsPath"
}
foreach ($relative in $requiredFiles) {
    $path = Join-Path $ArtifactsPath $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $relative"
    }
}

$sentinelMatches = @(
    Get-ChildItem -LiteralPath $ArtifactsPath -File -Recurse |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches
)
if ($sentinelMatches.Count -gt 0) {
    $unresolved = @($sentinelMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit preflight coverage for new sentinel(s): $($unknown -join ', ')."
    }
    throw "Resolve every guardrail policy decision before Azure what-if: $($unresolved -join ', ')."
}

foreach ($command in @("az")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is unavailable: $command"
    }
}

$decisionPath = Join-Path $ArtifactsPath "policy\guardrail-decisions.json"
$decision = Get-Content -LiteralPath $decisionPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$decision.implementationSession -ne $implementationSession) {
    throw "guardrail-decisions.json has the wrong implementationSession marker."
}
if ([string]$decision.targetScopeResourceId -ne $TargetScope) {
    throw "TargetScope must match guardrail-decisions.json targetScopeResourceId."
}
if ([string]$decision.deploymentLocation -ne $DeploymentLocation) {
    throw "DeploymentLocation must match guardrail-decisions.json deploymentLocation."
}
if ($TargetScope -notmatch "^/subscriptions/[0-9a-fA-F-]{36}$") {
    throw "TargetScope must be the approved subscription resource ID."
}

$allowedEffects = @{
    networkAccess = @("Audit", "Deny", "Disabled")
    localAuthentication = @("Audit", "Deny", "Disabled")
    deploymentSku = @("Audit", "Deny", "Disabled")
    contentFilterMinimum = @("Audit", "Disabled")
    diagnosticLogs = @("AuditIfNotExists", "DeployIfNotExists", "Disabled")
    enforcementMode = @("DoNotEnforce", "Default")
}
foreach ($name in $allowedEffects.Keys) {
    $value = [string]$decision.effects.$name
    if ($value -notin $allowedEffects[$name]) {
        throw "effects.$name has unsupported value '$value'."
    }
}
if ([string]$decision.effects.enforcementMode -eq "Default" -and [string]$decision.promotion.policyStateReviewStatus -ne "Reviewed") {
    throw "Promotion to Default requires promotion.policyStateReviewStatus set to Reviewed."
}
if ([string]$decision.effects.diagnosticLogs -eq "DeployIfNotExists" -and
    [string]$decision.diagnosticLogs.remediationRoleStatus -ne "LogAnalyticsContributorApproved") {
    throw "Diagnostic DeployIfNotExists requires remediationRoleStatus=LogAnalyticsContributorApproved."
}
if (@($decision.dataResidency.disallowedDeploymentSkus).Count -eq 0) {
    throw "dataResidency.disallowedDeploymentSkus must contain at least one SKU."
}
if (@($decision.contentFilters.minimumPromptSeverities).Count -eq 0 -or
    @($decision.contentFilters.minimumCompletionSeverities).Count -eq 0) {
    throw "Content-filter severity lists cannot be empty."
}

Get-Content -LiteralPath (Join-Path $ArtifactsPath "policy\definitions\restrict-foundry-deployment-sku.json") -Raw |
    ConvertFrom-Json -ErrorAction Stop | Out-Null

& az bicep build --file (Join-Path $ArtifactsPath "policy\initiative.bicep") --stdout | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Bicep build failed for policy\initiative.bicep." }
& az bicep build --file (Join-Path $ArtifactsPath "policy\assignment.bicep") --stdout | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Bicep build failed for policy\assignment.bicep." }
& az bicep build-params --file (Join-Path $ArtifactsPath "environments\initiative.bicepparam") --stdout | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Bicep parameter build failed for environments\initiative.bicepparam." }
& az bicep build-params --file (Join-Path $ArtifactsPath "environments\assignment.bicepparam") --stdout | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Bicep parameter build failed for environments\assignment.bicepparam." }

$accountJson = & az account show --only-show-errors --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Azure account lookup failed. Sign in only through the approved customer process before running a live preview.`n$($accountJson | Out-String)"
}
$account = ($accountJson | Out-String) | ConvertFrom-Json -ErrorAction Stop
$scopeSubscription = [regex]::Match($TargetScope, "^/subscriptions/([^/]+)").Groups[1].Value
if ([string]$account.id -ine $scopeSubscription) {
    throw "Azure CLI is not set to the approved subscription in TargetScope."
}

Write-Host "Preview 1 of 2: initiative and custom SKU policy in subscription $($account.id)."
& az deployment sub what-if `
    --location $DeploymentLocation `
    --name "optional-ai-services-guardrail-policy-initiative-preflight" `
    --template-file (Join-Path $ArtifactsPath "policy\initiative.bicep") `
    --parameters (Join-Path $ArtifactsPath "environments\initiative.bicepparam") `
    --no-pretty-print `
    --only-show-errors
if ($LASTEXITCODE -ne 0) { throw "Initiative what-if preview failed." }

Write-Host "Preview 2 of 2: staged policy assignment for $TargetScope."
& az deployment sub what-if `
    --location $DeploymentLocation `
    --name "optional-ai-services-guardrail-policy-assignment-preflight" `
    --template-file (Join-Path $ArtifactsPath "policy\assignment.bicep") `
    --parameters (Join-Path $ArtifactsPath "environments\assignment.bicepparam") `
    --no-pretty-print `
    --only-show-errors
if ($LASTEXITCODE -ne 0) { throw "Assignment what-if preview failed." }

Write-Host "PASS: files, decisions, exact target scope, syntax checks, and subscription-scope what-if previews are ready."
