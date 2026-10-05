[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$moduleRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$artifactRoot = Join-Path $moduleRoot "implementation\artifacts"
$policyTemplate = Join-Path $artifactRoot "policy\tag-allocation.bicep"
$policyParams = Join-Path $artifactRoot "policy\tag-allocation.bicepparam"
$budgetTemplate = Join-Path $artifactRoot "cost\ai-budget-with-filters.bicep"
$budgetParams = Join-Path $artifactRoot "cost\ai-budget-with-filters.bicepparam"
$chargebackDecisionsPath = Join-Path $artifactRoot "finance\chargeback-decisions.json"
$rateTablePath = Join-Path $artifactRoot "finance\token-rate-table.json"
$apimPolicyPath = Join-Path $artifactRoot "apim\token-chargeback-policy.xml"
$queryPath = Join-Path $artifactRoot "queries\token-chargeback.kql"

$requiredFiles = @(
    $policyTemplate,
    $policyParams,
    $budgetTemplate,
    $budgetParams,
    $chargebackDecisionsPath,
    $rateTablePath,
    $apimPolicyPath,
    $queryPath
)

$requiredSentinels = @(
    "__REQUIRED_ACTUAL_BUDGET_THRESHOLD_PERCENT__",
    "__REQUIRED_AI_BUDGET_NAME__",
    "__REQUIRED_AI_FINOPS_TARGET_SCOPE_RESOURCE_ID__",
    "__REQUIRED_AI_METER_CATEGORY__",
    "__REQUIRED_AI_RESOURCE_GROUP_NAME__",
    "__REQUIRED_APIM_PRODUCT_ID__",
    "__REQUIRED_APIM_SERVICE_NAME__",
    "__REQUIRED_APPLICATION_INSIGHTS_RESOURCE_ID__",
    "__REQUIRED_AZURE_SUBSCRIPTION_ID__",
    "__REQUIRED_BILLING_CURRENCY__",
    "__REQUIRED_BUDGET_ACTION_GROUP_RESOURCE_ID__",
    "__REQUIRED_BUDGET_END_DATE__",
    "__REQUIRED_BUDGET_START_DATE__",
    "__REQUIRED_CACHED_INPUT_TOKEN_RATE_OR_NA__",
    "__REQUIRED_CHARGEBACK_QUERY_OWNER_ROLE__",
    "__REQUIRED_COST_CENTER__",
    "__REQUIRED_COST_CENTER_FALLBACK__",
    "__REQUIRED_COST_NOTIFICATION_EMAIL__",
    "__REQUIRED_COST_OWNER_ROLE__",
    "__REQUIRED_FINANCE_APPROVED_RATE_SOURCE__",
    "__REQUIRED_FORECAST_BUDGET_THRESHOLD_PERCENT__",
    "__REQUIRED_GATEWAY_POLICY_OWNER_ROLE__",
    "__REQUIRED_INPUT_TOKEN_RATE__",
    "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__",
    "__REQUIRED_MODEL_ALIAS__",
    "__REQUIRED_MODEL_ROUTE_ALIAS__",
    "__REQUIRED_MONTHLY_AI_BUDGET_AMOUNT__",
    "__REQUIRED_MONTHLY_TOKEN_QUOTA__",
    "__REQUIRED_OUTPUT_TOKEN_RATE__",
    "__REQUIRED_POLICY_ASSIGNMENT_IDENTITY_LOCATION__",
    "__REQUIRED_POLICY_ASSIGNMENT_PREFIX__",
    "__REQUIRED_POLICY_REMEDIATION_PLAN_REFERENCE__",
    "__REQUIRED_RATE_EFFECTIVE_DATE__",
    "__REQUIRED_RATE_NOTES_OR_NA__",
    "__REQUIRED_RATE_OWNER_ROLE__",
    "__REQUIRED_RECONCILIATION_CADENCE__",
    "__REQUIRED_RESTORE_REFERENCE__",
    "__REQUIRED_TOKENS_PER_MINUTE__"
)

function Assert-Command {
    param([string]$Name)
    if (-not (Get-Command -Name $Name -ErrorAction SilentlyContinue)) {
        throw "Required command is unavailable: $Name"
    }
}

function Invoke-AzChecked {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [switch]$SuppressOutput
    )

    if ($SuppressOutput) {
        & az @Arguments | Out-Null
    }
    else {
        & az @Arguments
    }
    if ($LASTEXITCODE -ne 0) {
        throw "az $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

function Invoke-AzText {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & az @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "az $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
    return ($output -join "`n").Trim()
}

Assert-Command "az"

foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $path"
    }
}

$sentinelMatches = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
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
    throw "Resolve every AI FinOps decision before deployment: $($unresolved -join ', ')"
}

Get-ChildItem -LiteralPath $artifactRoot -File -Recurse -Filter "*.json" | ForEach-Object {
    $null = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
}

$null = [xml](Get-Content -LiteralPath $apimPolicyPath -Raw)

$decisions = Get-Content -LiteralPath $chargebackDecisionsPath -Raw | ConvertFrom-Json -ErrorAction Stop
$rates = Get-Content -LiteralPath $rateTablePath -Raw | ConvertFrom-Json -ErrorAction Stop

if ([string]$decisions.implementationModule -cne "ai-finops-token-chargeback" -or
    [string]$decisions.implementationSession -cne "optional-module-ai-finops-token-chargeback") {
    throw "chargeback-decisions.json has the wrong module marker."
}
if ([string]$rates.implementationModule -cne "ai-finops-token-chargeback" -or
    [string]$rates.implementationSession -cne "optional-module-ai-finops-token-chargeback") {
    throw "token-rate-table.json has the wrong module marker."
}
if ([string]$decisions.targetScope -cne $TargetScope) {
    throw "TargetScope must match chargeback-decisions.json targetScope."
}
$targetScopeMatch = [regex]::Match($TargetScope, '^/subscriptions/([0-9a-fA-F-]{36})$')
if (-not $targetScopeMatch.Success) {
    throw "TargetScope must be the exact approved subscription scope, for example /subscriptions/<subscription-id>."
}
$targetSubscriptionId = $targetScopeMatch.Groups[1].Value
if ([bool]$decisions.budget.budgetDoesNotStopResources -ne $true) {
    throw "The budget record must state that budgets notify and do not stop resources."
}
$gateway = $decisions.gateway
if ([int]$gateway.customMetricDimensionCount -gt 5 -or
    [bool]$gateway.userLevelMetricDimensionAllowed -or
    [bool]$gateway.clientSuppliedChargebackDimensionsAllowed) {
    throw "Token metric dimensions must stay at five or fewer and cannot use user-level or client-supplied dimensions."
}
if ([string]$gateway.dimensionMapping.costCenterSource -cne "approvedProductMapping" -or
    [string]$gateway.dimensionMapping.consumerSource -cne "context.Subscription.Id" -or
    [string]$gateway.dimensionMapping.modelRouteSource -cne "approvedStaticAlias") {
    throw "Gateway chargeback dimensions must come from product mapping, APIM subscription, and an approved static model-route alias."
}
if (@($decisions.policy.requiredTags).Count -lt 1 -or "CostCenter" -notin @($decisions.policy.requiredTags)) {
    throw "The tag taxonomy must include CostCenter."
}
if (@($decisions.gateway.products).Count -lt 1) {
    throw "At least one APIM product quota must be recorded."
}
if (@($rates.modelRates).Count -lt 1) {
    throw "At least one token rate row must be recorded."
}

$expectedSubscriptionId = [string]$decisions.approvedSubscriptionId
if ($targetSubscriptionId -ine $expectedSubscriptionId) {
    throw "TargetScope subscription '$targetSubscriptionId' must match approvedSubscriptionId '$expectedSubscriptionId'."
}
$activeSubscriptionId = Invoke-AzText -Arguments @("account", "show", "--query", "id", "--output", "tsv", "--only-show-errors")
if ($activeSubscriptionId -ne $expectedSubscriptionId) {
    throw "Azure CLI is targeting subscription '$activeSubscriptionId' but the approved subscription is '$expectedSubscriptionId'."
}

Invoke-AzChecked -Arguments @("bicep", "build", "--file", $policyTemplate, "--stdout") -SuppressOutput
Invoke-AzChecked -Arguments @("bicep", "build", "--file", $budgetTemplate, "--stdout") -SuppressOutput
Invoke-AzChecked -Arguments @("bicep", "build-params", "--file", $policyParams, "--stdout") -SuppressOutput
Invoke-AzChecked -Arguments @("bicep", "build-params", "--file", $budgetParams, "--stdout") -SuppressOutput

Write-Host "Running read-only subscription what-if for tag allocation policy."
Invoke-AzChecked -Arguments @(
    "deployment", "sub", "what-if",
    "--location", $DeploymentLocation,
    "--parameters", $policyParams,
    "--only-show-errors"
)

Write-Host "Running read-only subscription what-if for filtered AI budget."
Invoke-AzChecked -Arguments @(
    "deployment", "sub", "what-if",
    "--location", $DeploymentLocation,
    "--parameters", $budgetParams,
    "--only-show-errors"
)

Write-Host "PASS: AI FinOps preflight completed for approved scope '$TargetScope'."
