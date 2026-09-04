[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetScope,

    [string]$WorkbookSubscriptionId,

    [string]$WorkbookResourceGroup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$reportScriptPath = Join-Path $PSScriptRoot "build-estate-report.ps1"
$scopePath = Join-Path $artifactRoot "estate-scope.json"
$queryPath = Join-Path $artifactRoot "queries\foundry-accounts.kql"
$serviceHealthQueryPath = Join-Path $artifactRoot "queries\service-health-retirements.kql"
$advisorQueryPath = Join-Path $artifactRoot "queries\advisor-retirement-findings.kql"
$reportPythonPath = Join-Path $PSScriptRoot "build-estate-report.py"
$workbookTemplatePath = Join-Path $artifactRoot "infra\main.bicep"
$workbookDefinitionPath = Join-Path $artifactRoot "monitoring\estate-lifecycle-workbook.json"
$requiredSentinels = @(
    "__REQUIRED_APPROVED_ESTATE_SCOPE_ALIAS__",
    "__REQUIRED_APPROVED_MANAGEMENT_GROUP_ID__",
    "__REQUIRED_APPROVED_PRIMARY_REGION__",
    "__REQUIRED_COST_TAG_KEY__",
    "__REQUIRED_ENVIRONMENT_TAG_KEY__",
    "__REQUIRED_ESTATE_REVIEW_DATE__",
    "__REQUIRED_EXCEPTION_ACCOUNT_NAME__",
    "__REQUIRED_EXCEPTION_EXPIRY_DATE__",
    "__REQUIRED_EXCEPTION_OWNER_ROLE__",
    "__REQUIRED_EXCEPTION_REASON__",
    "__REQUIRED_INVENTORY_OWNER_ROLE__",
    "__REQUIRED_LIFECYCLE_OWNER_ROLE__",
    "__REQUIRED_OWNER_TAG_KEY__"
)

if (-not (Get-Command -Name "az" -ErrorAction SilentlyContinue)) {
    throw "The Azure CLI is required."
}
if (-not (Get-Command -Name "python" -ErrorAction SilentlyContinue)) {
    throw "Python is required."
}
if (-not (Test-Path -LiteralPath $reportScriptPath -PathType Leaf)) {
    throw "The estate report cannot run because build-estate-report.ps1 is missing: $reportScriptPath"
}
foreach ($path in @($scopePath, $queryPath, $serviceHealthQueryPath, $advisorQueryPath, $reportPythonPath, $workbookTemplatePath, $workbookDefinitionPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required Session 14 artifact is missing: $path"
    }
    if ($WorkbookSubscriptionId -or $WorkbookResourceGroup) {
        if ([string]::IsNullOrWhiteSpace($WorkbookSubscriptionId) -or [string]::IsNullOrWhiteSpace($WorkbookResourceGroup)) {
            throw "-WorkbookSubscriptionId and -WorkbookResourceGroup must be supplied together."
        }
        if ($WorkbookSubscriptionId -notmatch '^[0-9a-fA-F-]{36}$') {
            throw "-WorkbookSubscriptionId must be a GUID."
        }
    }
}

$sentinelMatches = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches)
$unresolved = @($sentinelMatches |
    ForEach-Object { $_.Matches } |
    ForEach-Object { $_.Value } |
    Sort-Object -Unique)
if ($unresolved.Count -gt 0) {
    $unknown = @($unresolved | Where-Object { $requiredSentinels -notcontains $_ })
    if ($unknown.Count -gt 0) {
        throw "Add explicit preflight coverage for new sentinels: $($unknown -join ', ')"
    }
    throw "Resolve every estate scope decision before the estate read: $($unresolved -join ', ')"
}

az extension show --name resource-graph --output none 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "Install the Resource Graph extension first: az extension add --name resource-graph"
}

$scope = Get-Content -LiteralPath $scopePath -Raw | ConvertFrom-Json
if ($scope.implementationSession -ne "14-foundry-estate-inventory") {
    throw "The estate scope record has the wrong implementationSession marker."
}
if ($scope.approvedScope -ne $TargetScope) {
    throw "The estate scope record must match -TargetScope."
}

foreach ($name in @("managementGroups", "inScopeAccountKinds", "approvedRegions", "requiredTagKeys")) {
    $values = @($scope.$name)
    if ($values.Count -eq 0) {
        throw "$name must be a non-empty list."
    }
    if (@($values | Where-Object { [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0) {
        throw "$name contains an empty value."
    }
}

foreach ($key in @("ownerTagKey", "costTagKey")) {
    if (@($scope.requiredTagKeys) -notcontains $scope.$key) {
        throw "$key must also appear in requiredTagKeys."
    }
}

foreach ($owner in @("inventoryOwner", "lifecycleOwner")) {
    if ([string]::IsNullOrWhiteSpace([string]$scope.$owner)) {
        throw "Record the $owner role."
    }
}
if ($scope.reviewCadenceDays -isnot [int] -or $scope.reviewCadenceDays -le 0) {
    throw "reviewCadenceDays must be a positive whole number of days."
}
if ($scope.modelRetirementWarningDays -isnot [int] -or $scope.modelRetirementWarningDays -le 0) {
    throw "modelRetirementWarningDays must be a positive whole number of days."
}

foreach ($exception in @($scope.recordedExceptions)) {
    foreach ($field in @("accountName", "reason", "owner", "expiryDate")) {
        if ([string]::IsNullOrWhiteSpace([string]$exception.$field)) {
            throw "Every recorded exception needs $field."
        }
    }
}

Write-Host ("Estate scope covers $(@($scope.managementGroups).Count) management group(s), " +
    "$(@($scope.inScopeAccountKinds).Count) account kind(s), and " +
    "$(@($scope.requiredTagKeys).Count) required tag key(s).")

Write-Host "Checking read access to the approved management groups..."
$probeQuery = "Resources | where type =~ 'microsoft.cognitiveservices/accounts' | summarize accounts = count()"
foreach ($group in @($scope.managementGroups)) {
    az graph query --graph-query $probeQuery --management-groups $group --output none
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot read management group '$group' through Resource Graph."
    }
    Write-Host "  read access confirmed: $group"
}

az graph query --graph-query "ServiceHealthResources | where type =~ 'microsoft.resourcehealth/events' | take 1" `
    --management-groups @($scope.managementGroups)[0] --output none
if ($LASTEXITCODE -ne 0) {
    throw "Cannot read Service Health events through Resource Graph."
}

if ($WorkbookSubscriptionId) {
    az group show --subscription $WorkbookSubscriptionId --name $WorkbookResourceGroup --output none
    if ($LASTEXITCODE -ne 0) {
        throw "Cannot read workbook resource group '$WorkbookResourceGroup'."
    }
    $preview = az deployment group what-if `
        --subscription $WorkbookSubscriptionId `
        --resource-group $WorkbookResourceGroup `
        --name rvas-foundry-estate-lifecycle-workbook `
        --template-file $workbookTemplatePath `
        --result-format FullResourcePayloads `
        --only-show-errors `
        --output json
    if ($LASTEXITCODE -ne 0) {
        throw "The workbook deployment preview failed."
    }
    $changes = @(($preview | ConvertFrom-Json).changes)
    $unexpected = @($changes | Where-Object {
            ([string]$_.resourceId).ToLowerInvariant() -notlike "*/providers/microsoft.insights/workbooks/*"
        })
    if ($unexpected.Count -gt 0) {
        throw "Workbook preview contains a resource outside the workbook scope."
    }
}

Write-Host "PASS: The estate scope record and Resource Graph access are ready for scope '$TargetScope'."
if ($WorkbookSubscriptionId) {
    Write-Host "PASS: The workbook deployment preview targets '$WorkbookResourceGroup'."
}
