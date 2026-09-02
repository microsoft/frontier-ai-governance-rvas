[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetScope
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Get-Command ConvertFrom-Json -ErrorAction Stop | Out-Null

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$standardPath = Join-Path $artifactRoot "portfolio-standard.json"
$decisionPath = Join-Path $artifactRoot "portfolio-decision.json"
$modelPath = Join-Path $artifactRoot "governance\operating-model.md"

foreach ($path in @($standardPath, $decisionPath, $modelPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required module artifact is missing: $path"
    }
}

$coveredSentinels = @(
    "__REQUIRED_AGENT_IDENTITY_REFERENCE__",
    "__REQUIRED_AGENT_INVENTORY_REFERENCE__",
    "__REQUIRED_AGENT_TYPE__",
    "__REQUIRED_API_CATALOG_REFERENCE__",
    "__REQUIRED_APPROVED_PORTFOLIO_SCOPE__",
    "__REQUIRED_BUSINESS_SPONSOR_ROLE__",
    "__REQUIRED_DUPLICATE_DECISION_OWNER_ROLE__",
    "__REQUIRED_DUPLICATE_INVENTORY_REFERENCE__",
    "__REQUIRED_DUPLICATE_REVIEW_DECISION__",
    "__REQUIRED_FRAMEWORK_DECISION__",
    "__REQUIRED_GATEWAY_POLICY_REFERENCE__",
    "__REQUIRED_LIFECYCLE_APPROVAL_REFERENCE__",
    "__REQUIRED_PORTFOLIO_OWNER_ROLE__",
    "__REQUIRED_RELEASE_OWNER_ROLE__",
    "__REQUIRED_REQUESTED_LIFECYCLE_STATE__",
    "__REQUIRED_RETIREMENT_COORDINATOR_ROLE__",
    "__REQUIRED_RETIREMENT_PLAN_REFERENCE__",
    "__REQUIRED_SOURCE_PLATFORM__",
    "__REQUIRED_SOURCE_PLATFORM_REFERENCE__"
)
$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinels.Count -gt 0) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknownSentinels = @($unresolved | Where-Object { $_ -notin $coveredSentinels })
    if ($unknownSentinels.Count -gt 0) {
        throw "Preflight does not cover new required fields: $($unknownSentinels -join ', ')"
    }
    throw "Resolve every portfolio decision before review: $($unresolved -join ', ')"
}

$standard = Get-Content -LiteralPath $standardPath -Raw | ConvertFrom-Json -ErrorAction Stop
$decision = Get-Content -LiteralPath $decisionPath -Raw | ConvertFrom-Json -ErrorAction Stop
$operatingModel = Get-Content -LiteralPath $modelPath -Raw
$expectedMarker = "enterprise-agent-portfolio-standards"

foreach ($item in @($standard, $decision)) {
    if ([string]$item.implementationModule -ne $expectedMarker -or
        [string]$item.implementationSession -ne $expectedMarker) {
        throw "An artifact has the wrong implementation marker."
    }
}
if ([string]$standard.approvedPortfolioScope -ne $TargetScope -or
    [string]$decision.portfolioScope -ne $TargetScope) {
    throw "TargetScope must match both JSON artifacts."
}

$references = $decision.authoritativeReferences
$expectedSystems = @{
    agentInventory = "Microsoft Agent 365"
    apiAndToolCatalog = "Azure API Center"
    agentIdentity = "Microsoft Entra ID"
    gatewayPolicy = "Azure API Management"
}
foreach ($name in $expectedSystems.Keys) {
    if ([string]$references.$name.system -ne $expectedSystems[$name] -or
        [string]::IsNullOrWhiteSpace([string]$references.$name.recordReference)) {
        throw "The $name authoritative reference is incomplete or uses the wrong system."
    }
}
if ([string]$references.sourcePlatform.system -notin @($standard.architectureDecisions.allowedSourcePlatforms) -or
    [string]::IsNullOrWhiteSpace([string]$references.sourcePlatform.recordReference)) {
    throw "The source-platform reference is incomplete or outside the approved standard."
}

if ([string]$decision.classificationDecision.agentType -notin @($standard.classification.allowedTypes)) {
    throw "The agent classification is outside the approved taxonomy."
}
if ([string]$decision.frameworkDecision.selectedPath -notin @($standard.architectureDecisions.approvedFrameworks)) {
    throw "The framework decision is outside the approved standard."
}
if ([string]$decision.frameworkDecision.selectedPath -eq "other-by-exception" -and
    [string]$decision.frameworkDecision.exceptionApprovalReference -eq "N/A") {
    throw "Another framework needs an approved exception reference."
}

$requiredRoles = @($standard.ownership.requiredRoles)
$missingRoles = @($requiredRoles | Where-Object {
    $_ -notin @($decision.owners.PSObject.Properties.Name) -or
    [string]::IsNullOrWhiteSpace([string]$decision.owners.$_)
})
if ($missingRoles.Count -gt 0) {
    throw "The portfolio decision is missing required owner roles: $($missingRoles -join ', ')"
}

$transition = "$([string]$decision.lifecycleDecision.currentState):$([string]$decision.lifecycleDecision.requestedState)"
if ($transition -notin @($standard.lifecycle.allowedTransitions)) {
    throw "Lifecycle transition is not approved: $transition"
}
if (-not [bool]$decision.duplicateDecision.possibleMatchesReviewed -or
    [string]$decision.duplicateDecision.decision -notin @("new-capability", "reuse-existing", "approved-overlap")) {
    throw "The duplicate decision is incomplete."
}
if (-not [bool]$decision.retirementCoordination.crossPlatformPlanConfirmed -or
    [string]::IsNullOrWhiteSpace([string]$decision.retirementCoordination.planReference)) {
    throw "Cross-platform retirement coordination is incomplete."
}

$combinedText = ($decision | ConvertTo-Json -Depth 20) + $operatingModel
if ($combinedText -match "\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b") {
    throw "Use role aliases, not personal email addresses."
}

Write-Host "PASS: Portfolio decisions are complete for '$TargetScope'."
