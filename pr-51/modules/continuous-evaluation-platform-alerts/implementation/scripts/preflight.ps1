[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$implementationSession = "optional-module-continuous-evaluation-platform-alerts"
$artifactRoot = Join-Path $PSScriptRoot "..\artifacts"
$monitoringTemplate = Join-Path $artifactRoot "monitoring\foundry-platform-monitoring.bicep"
$monitoringParameters = Join-Path $artifactRoot "monitoring\foundry-platform-monitoring.bicepparam"
$decisionPath = Join-Path $artifactRoot "evaluation\continuous-evaluation-decision.json"
$evaluationScript = Join-Path $artifactRoot "evaluation\continuous-evaluation-rule.py"
$requirementsPath = Join-Path $artifactRoot "evaluation\requirements.txt"
$queryPath = Join-Path $artifactRoot "queries\foundry-token-and-throttling.kql"

$requiredSentinels = @(
    "__REQUIRED_ACTION_GROUP_NAME__",
    "__REQUIRED_ACTION_GROUP_SHORT_NAME__",
    "__REQUIRED_ACTION_RECEIVER_EMAIL__",
    "__REQUIRED_AGENT_NAME__",
    "__REQUIRED_AGENT_VERSION__",
    "__REQUIRED_AI_QUALITY_OWNER_ROLE__",
    "__REQUIRED_ALERT_OWNER_ROLE__",
    "__REQUIRED_APPROVED_FOUNDRY_SCOPE_ALIAS__",
    "__REQUIRED_DEPLOYMENT_LOCATION__",
    "__REQUIRED_EVALUATION_NAME__",
    "__REQUIRED_EVALUATION_RULE_DISPLAY_NAME__",
    "__REQUIRED_EVALUATION_RULE_ID__",
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__",
    "__REQUIRED_FOUNDRY_PROJECT_NAME__",
    "__REQUIRED_INCIDENT_ROUTE_ALIAS__",
    "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__",
    "__REQUIRED_MAX_HOURLY_RUNS__",
    "__REQUIRED_RESTORE_CHANGE_REFERENCE__",
    "__REQUIRED_SAFETY_OWNER_ROLE__",
    "__REQUIRED_SAFETY_THRESHOLD__",
    "__REQUIRED_SERVICE_NAME__",
    "__REQUIRED_STATUS_CODE_DIMENSION_VALUE_CONFIRMED__",
    "__REQUIRED_TASK_ADHERENCE_THRESHOLD__",
    "__REQUIRED_THROTTLED_REQUESTS_THRESHOLD__",
    "__REQUIRED_TIME_TO_LAST_BYTE_THRESHOLD_MS__",
    "__REQUIRED_TOKEN_TRANSACTION_THRESHOLD__"
)

function Get-BicepStringParameter {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name
    )

    $match = [regex]::Match(
        (Get-Content -LiteralPath $Path -Raw),
        "(?m)^\s*param\s+$([regex]::Escape($Name))\s*=\s*'([^']*)'\s*$"
    )
    if (-not $match.Success) {
        throw "Could not read string parameter '$Name' from $Path."
    }
    return $match.Groups[1].Value
}

function Assert-IntegerString {
    param(
        [Parameter(Mandatory)][string]$Value,
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][int]$Minimum,
        [Parameter(Mandatory)][int]$Maximum
    )

    $parsed = 0
    if (-not [int]::TryParse($Value, [ref]$parsed) -or $parsed -lt $Minimum -or $parsed -gt $Maximum) {
        throw "$Label must be an integer from $Minimum through $Maximum."
    }
}

foreach ($command in @("az", "python")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is unavailable: $command"
    }
}

foreach ($path in @($monitoringTemplate, $monitoringParameters, $decisionPath, $evaluationScript, $requirementsPath, $queryPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $path"
    }
}

$matches = @(
    Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches
)
if ($matches.Count -gt 0) {
    $unresolved = @($matches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value } | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit preflight coverage for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every required monitoring and evaluation decision before deployment: $($unresolved -join ', ')"
}

$decision = Get-Content -LiteralPath $decisionPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$decision.implementationSession -ne $implementationSession) {
    throw "The continuous evaluation decision file has the wrong implementationSession marker."
}
if ([string]$decision.targetScope -ne $TargetScope) {
    throw "TargetScope must match continuous-evaluation-decision.json."
}
if ((Get-BicepStringParameter -Path $monitoringParameters -Name "targetScopeAlias") -ne $TargetScope) {
    throw "TargetScope must match foundry-platform-monitoring.bicepparam."
}
if ((Get-BicepStringParameter -Path $monitoringParameters -Name "location") -ne $DeploymentLocation) {
    throw "DeploymentLocation must match foundry-platform-monitoring.bicepparam."
}
if ((Get-BicepStringParameter -Path $monitoringParameters -Name "foundryAccountName") -ne [string]$decision.foundry.accountName) {
    throw "Foundry account name must match between monitoring parameters and evaluation decision record."
}

$email = Get-BicepStringParameter -Path $monitoringParameters -Name "actionReceiverEmail"
if ($email -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
    throw "actionReceiverEmail must be a distribution list or mailbox alias, not free text."
}
$shortName = Get-BicepStringParameter -Path $monitoringParameters -Name "actionGroupShortName"
if ($shortName.Length -gt 12) {
    throw "actionGroupShortName must be 12 characters or fewer."
}
Assert-IntegerString (Get-BicepStringParameter -Path $monitoringParameters -Name "throttledRequestsThreshold") "throttledRequestsThreshold" 1 1000000
Assert-IntegerString (Get-BicepStringParameter -Path $monitoringParameters -Name "timeToLastByteThresholdMs") "timeToLastByteThresholdMs" 1 600000
Assert-IntegerString (Get-BicepStringParameter -Path $monitoringParameters -Name "tokenTransactionThreshold") "tokenTransactionThreshold" 1 1000000000

$maxHourlyRuns = [string]$decision.continuousEvaluation.sampling.maxHourlyRuns
Assert-IntegerString $maxHourlyRuns "continuousEvaluation.sampling.maxHourlyRuns" 1 1000
if ([string]$decision.operations.statusCodeDimensionValueConfirmed -ne "true") {
    throw "Confirm the AzureOpenAIRequests StatusCode value for throttling by setting statusCodeDimensionValueConfirmed to true."
}
foreach ($evaluator in @($decision.continuousEvaluation.evaluators)) {
    if ([string]$evaluator.evaluatorName -notlike "builtin.*") {
        throw "Evaluator '$($evaluator.evaluatorName)' must come from the approved Foundry evaluator catalog."
    }
}

Get-ChildItem -LiteralPath $artifactRoot -File -Recurse -Filter "*.json" | ForEach-Object {
    $null = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
}

$pythonCompile = & python -m py_compile $evaluationScript 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Python syntax check failed.`n$($pythonCompile | Out-String)"
}

$bicepBuild = & az bicep build --file $monitoringTemplate --stdout 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Bicep build failed.`n$($bicepBuild | Out-String)"
}
$bicepParamBuild = & az bicep build-params --file $monitoringParameters --stdout 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Bicep parameter build failed.`n$($bicepParamBuild | Out-String)"
}

$account = & az account show --subscription $ApprovedSubscriptionId --only-show-errors --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI is not signed in to the approved subscription or cannot read it.`n$($account | Out-String)"
}

$whatIf = & az deployment group what-if `
    --subscription $ApprovedSubscriptionId `
    --resource-group $ResourceGroupName `
    --template-file $monitoringTemplate `
    --parameters $monitoringParameters `
    --only-show-errors `
    --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Bicep what-if failed.`n$($whatIf | Out-String)"
}

Write-Host "PASS: preflight completed for target scope '$TargetScope'."
Write-Host "Preview complete: review the resource-group what-if before deploying diagnostic settings, the action group, and metric alerts."
