[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$AssignmentName = "rvas-ai-services-guardrails",

    [Parameter()]
    [string]$DecisionFile = (Join-Path $PSScriptRoot "..\artifacts\policy\guardrail-decisions.json")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $DecisionFile -PathType Leaf)) {
    throw "Decision file is missing: $DecisionFile"
}
$decisionText = Get-Content -LiteralPath $DecisionFile -Raw
if ($decisionText -match "__REQUIRED_[A-Z0-9_]+__") {
    throw "Resolve every guardrail decision before checking live compliance."
}
$decision = $decisionText | ConvertFrom-Json -ErrorAction Stop
if ([string]$decision.implementationSession -ne "optional-module-ai-services-guardrail-policy") {
    throw "Decision file has the wrong implementationSession marker."
}
if ([string]$decision.targetScopeResourceId -ne $TargetScope) {
    throw "TargetScope must match guardrail-decisions.json targetScopeResourceId."
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "az is required."
}

function Get-PolicyStateScopeArguments {
    param([Parameter(Mandatory)][string]$Scope)

    $subscriptionMatch = [regex]::Match($Scope, "^/subscriptions/([^/]+)$", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($subscriptionMatch.Success) {
        return @("--subscription", $subscriptionMatch.Groups[1].Value)
    }

    $resourceGroupMatch = [regex]::Match($Scope, "^/subscriptions/([^/]+)/resourceGroups/([^/]+)$", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($resourceGroupMatch.Success) {
        return @(
            "--subscription", $resourceGroupMatch.Groups[1].Value,
            "--resource-group", $resourceGroupMatch.Groups[2].Value
        )
    }

    $managementGroupMatch = [regex]::Match($Scope, "^/providers/Microsoft\.Management/managementGroups/([^/]+)$", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($managementGroupMatch.Success) {
        return @("--management-group", $managementGroupMatch.Groups[1].Value)
    }

    throw "TargetScope must be a subscription, resource group, or management-group resource ID."
}

$stateScopeArguments = @(Get-PolicyStateScopeArguments -Scope $TargetScope)
$assignmentIdRaw = & az policy assignment show `
    --name $AssignmentName `
    --scope $TargetScope `
    --query id `
    --output tsv `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace(($assignmentIdRaw | Out-String).Trim())) {
    throw "Policy assignment lookup failed for '$AssignmentName' at '$TargetScope'.`n$($assignmentIdRaw | Out-String)"
}
$assignmentId = ($assignmentIdRaw | Out-String).Trim()

$statesRaw = & az policy state list `
    @stateScopeArguments `
    --policy-assignment $AssignmentName `
    --query "[].{reference:policyDefinitionReferenceId,state:complianceState}" `
    --output json `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Policy state lookup failed for assignment '$AssignmentName' ($assignmentId).`n$($statesRaw | Out-String)"
}
$states = @((($statesRaw | Out-String) | ConvertFrom-Json -ErrorAction Stop))
if ($states.Count -eq 0) {
    Write-Host "No policy state records were returned for assignment '$AssignmentName'. Trigger or wait for evaluation before promotion."
    return
}

$states |
    Group-Object reference, state |
    Sort-Object Name |
    ForEach-Object {
        [pscustomobject]@{
            Reference = ($_.Group[0].reference)
            ComplianceState = ($_.Group[0].state)
            Count = $_.Count
        }
    } |
    Format-Table -AutoSize
