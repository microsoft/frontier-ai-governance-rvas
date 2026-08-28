[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedApplicationInsightsResourceId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = Join-Path $PSScriptRoot "..\artifacts"
$mainTemplatePath = Join-Path $artifactRoot "infra\main.bicep"
$mainParametersPath = Join-Path $artifactRoot "infra\main.bicepparam"
$budgetTemplatePath = Join-Path $artifactRoot "cost\budget.bicep"
$budgetParametersPath = Join-Path $artifactRoot "cost\budget.bicepparam"
$telemetryPath = Join-Path $artifactRoot "telemetry\telemetry-contract.json"
$retentionPath = Join-Path $artifactRoot "governance\data-retention-decision.md"
$contentLoggingPath = Join-Path $artifactRoot "governance\prompt-response-logging-decision.md"
$requiredDecisionSentinels = @(
    "__REQUIRED_ACTION_GROUP_RESOURCE_ID__",
    "__REQUIRED_APPLICATION_INSIGHTS_RESOURCE_ID__",
    "__REQUIRED_APPLICATION_TAG__",
    "__REQUIRED_BUDGET_END_DATE__",
    "__REQUIRED_BUDGET_NAME__",
    "__REQUIRED_BUDGET_START_DATE__",
    "__REQUIRED_COST_CENTER__",
    "__REQUIRED_COST_NOTIFICATION_EMAIL__",
    "__REQUIRED_COST_OWNER__",
    "__REQUIRED_DAILY_CAP_DECISION__",
    "__REQUIRED_DATA_CLASSIFICATION__",
    "__REQUIRED_DATA_PROTECTION_OWNER__",
    "__REQUIRED_DATA_RESIDENCY_STATUS_CONFIRMED__",
    "__REQUIRED_DATA_RETENTION_OWNER__",
    "__REQUIRED_DEPLOYMENT_LOCATION__",
    "__REQUIRED_EXCEPTION_PATH_STATUS_DISABLED_OR_APPROVED__",
    "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__",
    "__REQUIRED_MONTHLY_BUDGET_AMOUNT__",
    "__REQUIRED_OBSERVABILITY_OWNER__",
    "__REQUIRED_PRIVATE_ACCESS_STATUS_YES__",
    "__REQUIRED_QUALITY_FAILURE_COUNT__",
    "__REQUIRED_REQUEST_ERROR_RATE_PERCENT__",
    "__REQUIRED_RETENTION_DAYS__",
    "__REQUIRED_SAMPLING_STRATEGY_FIXED_OR_RATE_LIMITED__",
    "__REQUIRED_SAMPLING_VALUE__",
    "__REQUIRED_SERVICE_NAME__",
    "__REQUIRED_TOOL_FAILURE_COUNT__",
    "__REQUIRED_TRACE_BASED_LOG_SAMPLING_DECISION__",
    "__REQUIRED_WORKBOOK_DISPLAY_NAME__"
)

function Get-BicepStringParameter {
    param([string]$Path, [string]$Name)

    $match = [regex]::Match(
        (Get-Content -LiteralPath $Path -Raw),
        "(?m)^\s*param\s+$([regex]::Escape($Name))\s*=\s*'([^']+)'\s*$"
    )
    if (-not $match.Success) {
        throw "Could not read string parameter '$Name' from $Path."
    }
    return $match.Groups[1].Value
}

function Get-MarkdownField {
    param([string]$Path, [string]$Heading, [string]$Field)

    $content = Get-Content -LiteralPath $Path -Raw
    $sectionMatch = [regex]::Match(
        $content,
        "(?ms)^$([regex]::Escape($Heading))\s*$.*?(?=^#{1,6}\s|\z)"
    )
    if (-not $sectionMatch.Success) {
        throw "$(Split-Path -Leaf $Path) is missing heading '$Heading'."
    }
    $fieldMatch = [regex]::Match(
        $sectionMatch.Value,
        "(?m)^\|\s*$([regex]::Escape($Field))\s*\|\s*`?([^|`]+?)`?\s*\|\s*$"
    )
    if (-not $fieldMatch.Success) {
        throw "$(Split-Path -Leaf $Path) is missing field '$Field'."
    }
    return $fieldMatch.Groups[1].Value.Trim()
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required."
}
if (-not (Test-Path $artifactRoot -PathType Container)) {
    throw "Required implementation artifacts folder is missing: $artifactRoot"
}

$requiredFiles = @(
    $mainTemplatePath,
    $mainParametersPath,
    $budgetTemplatePath,
    $budgetParametersPath,
    $telemetryPath,
    $retentionPath,
    $contentLoggingPath,
    (Join-Path $artifactRoot "cost\cost-allocation.md"),
    (Join-Path $artifactRoot "monitoring\workbook.json"),
    (Join-Path $artifactRoot "operations\incident-runbook.md"),
    (Join-Path $artifactRoot "queries\request-error-rate-alert.kql"),
    (Join-Path $artifactRoot "queries\tool-failure-alert.kql"),
    (Join-Path $artifactRoot "queries\quality-safety-alert.kql")
)
foreach ($path in $requiredFiles) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $path"
    }
}

$artifactFiles = Get-ChildItem -LiteralPath $artifactRoot -File -Recurse
$sentinels = $artifactFiles | Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches
foreach ($match in @($sentinels | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value } | Select-Object -Unique)) {
    if ($match -notin $requiredDecisionSentinels) {
        throw "Preflight has no named coverage for customer decision $match."
    }
}
if ($sentinels) {
    $locations = $sentinels | ForEach-Object { "$($_.Path):$($_.LineNumber)" }
    throw "Resolve every required customer decision before deployment:`n$($locations -join "`n")"
}

Get-ChildItem -LiteralPath $artifactRoot -File -Recurse -Filter "*.json" | ForEach-Object {
    $null = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
}

$telemetry = Get-Content -LiteralPath $telemetryPath -Raw | ConvertFrom-Json
if ([int]$telemetry.schemaVersion -ne 1 -or [string]$telemetry.implementationSession -cne "12") {
    throw "Telemetry contract has a stale schema or implementation session marker."
}
if ([string]$telemetry.propagation.standard -ne "W3C Trace Context" -or
    [bool]$telemetry.propagation.correlationIdMayContainUserData) {
    throw "Telemetry must use W3C Trace Context and reject user data in correlation IDs."
}
foreach ($attribute in @(
    "gen_ai.prompt", "gen_ai.completion", "ai.input.content", "ai.output.content",
    "tool.input", "tool.output", "http.request.header.authorization",
    "http.request.header.cookie", "url.query", "enduser.id", "user.email"
)) {
    if ($attribute -notin @($telemetry.prohibitedAttributes)) {
        throw "Telemetry contract must prohibit '$attribute'."
    }
}
if (@($telemetry.cardinality.approvedDimensions).Count -gt 5 -or
    [bool]$telemetry.cardinality.userLevelDimensionAllowed -or
    [bool]$telemetry.cardinality.freeTextDimensionAllowed) {
    throw "Token telemetry must use no more than five low-cardinality dimensions."
}

if ((Get-MarkdownField $retentionPath "# Data retention decision" "Application Insights resource ID") -ine
    $ApprovedApplicationInsightsResourceId) {
    throw "The retention decision does not target the approved Application Insights resource."
}
$retentionDays = Get-MarkdownField $retentionPath "# Data retention decision" "Retention days"
$parsedRetentionDays = 0
if (-not [int]::TryParse($retentionDays, [ref]$parsedRetentionDays) -or
    $parsedRetentionDays -lt 30 -or $parsedRetentionDays -gt 730) {
    throw "Retention days must be an approved integer from 30 through 730."
}
if ((Get-MarkdownField $retentionPath "# Data retention decision" "Data residency status") -cne "Confirmed" -or
    (Get-MarkdownField $retentionPath "# Data retention decision" "Private-access boundary status") -cne "Yes") {
    throw "The data residency and private-access boundary decisions must be confirmed."
}

foreach ($entry in @{
    "Standard content logging" = "Disabled"
    "Prompts logged by default" = "No"
    "Responses logged by default" = "No"
    "Tool payloads logged by default" = "No"
    "Query strings logged by default" = "No"
    "Authorization headers logged by default" = "No"
}.GetEnumerator()) {
    if ((Get-MarkdownField $contentLoggingPath "## Standard telemetry" $entry.Key) -cne $entry.Value) {
        throw "prompt-response-logging-decision.md field '$($entry.Key)' must be '$($entry.Value)'."
    }
}
$exceptionStatus = Get-MarkdownField $contentLoggingPath "## Exception path" "Status"
$exceptionFields = @("Purpose", "Approved scope", "Access owner", "Retention days", "Expiry date")
if ($exceptionStatus -notin @("Disabled", "Approved")) {
    throw "The content-logging exception status must be Disabled or Approved."
}
foreach ($field in $exceptionFields) {
    $value = Get-MarkdownField $contentLoggingPath "## Exception path" $field
    if (($exceptionStatus -eq "Disabled" -and $value -ne "N/A") -or
        ($exceptionStatus -eq "Approved" -and $value -eq "N/A")) {
        throw "Content-logging exception details do not match the selected status."
    }
}

if ((Get-BicepStringParameter $mainParametersPath "applicationInsightsResourceId") -ine
    $ApprovedApplicationInsightsResourceId) {
    throw "main.bicepparam does not target the approved Application Insights resource."
}
if ((Get-BicepStringParameter $mainParametersPath "location") -ine $DeploymentLocation -or
    (Get-BicepStringParameter $mainParametersPath "environment") -cne "nonproduction") {
    throw "Monitoring deployment parameters do not match the approved nonproduction scope."
}
$budgetAmount = Get-BicepStringParameter $budgetParametersPath "amount"
$parsedBudgetAmount = 0.0
if (-not [double]::TryParse(
        $budgetAmount,
        [Globalization.NumberStyles]::Number,
        [Globalization.CultureInfo]::InvariantCulture,
        [ref]$parsedBudgetAmount
    ) -or $parsedBudgetAmount -le 0) {
    throw "Budget amount must be a positive number in invariant format."
}

$currentSubscriptionId = [string](az account show --query id -o tsv)
if ($LASTEXITCODE -ne 0 -or $currentSubscriptionId -ine $ApprovedSubscriptionId) {
    throw "Azure CLI is not set to approved subscription '$ApprovedSubscriptionId'."
}
$applicationInsights = az resource show --ids $ApprovedApplicationInsightsResourceId --api-version 2020-02-02 -o json |
    ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]$applicationInsights.type -ine "microsoft.insights/components") {
    throw "The approved Application Insights resource could not be resolved."
}
$actionGroupId = Get-BicepStringParameter $mainParametersPath "actionGroupResourceId"
$actionGroupType = [string](az resource show --ids $actionGroupId --query type -o tsv)
if ($LASTEXITCODE -ne 0 -or $actionGroupType -ine "microsoft.insights/actiongroups") {
    throw "The approved Azure Monitor action group could not be resolved."
}

$null = az bicep build --file $mainTemplatePath --stdout
if ($LASTEXITCODE -ne 0) { throw "The workbook and alert Bicep template did not compile." }
$null = az bicep build --file $budgetTemplatePath --stdout
if ($LASTEXITCODE -ne 0) { throw "The budget Bicep template did not compile." }

Write-Host "Preview 1 of 2: workbook and alert rules in /subscriptions/$ApprovedSubscriptionId/resourceGroups/$ApprovedResourceGroupName"
az deployment group what-if --subscription $ApprovedSubscriptionId --resource-group $ApprovedResourceGroupName `
    --template-file $mainTemplatePath --parameters $mainParametersPath --no-pretty-print
if ($LASTEXITCODE -ne 0) { throw "Workbook and alert-rule deployment preview failed." }

Write-Host "Preview 2 of 2: budget in /subscriptions/$ApprovedSubscriptionId"
az deployment sub what-if --subscription $ApprovedSubscriptionId --location $DeploymentLocation `
    --template-file $budgetTemplatePath --parameters $budgetParametersPath --no-pretty-print
if ($LASTEXITCODE -ne 0) { throw "Subscription budget deployment preview failed." }

Write-Host "PASS: scope, decisions, telemetry privacy, Bicep compilation, and both previews are ready."
