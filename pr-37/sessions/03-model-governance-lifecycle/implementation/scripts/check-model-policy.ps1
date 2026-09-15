[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [string]$ApprovedModelsAssignment = "rvas-mod-approved-models",

    [string]$EligibilityAssignment = "rvas-mod-model-eligibility"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command -Name "az" -ErrorAction SilentlyContinue)) {
    throw "The Azure CLI is required."
}

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$register = Get-Content -LiteralPath (Join-Path $artifactRoot "model-approval-register.json") -Raw |
    ConvertFrom-Json

$scope = az group show --name $ResourceGroup --query id --output tsv
if ($LASTEXITCODE -ne 0) {
    throw "Cannot read resource group '$ResourceGroup'."
}

$approved = az policy assignment show --name $ApprovedModelsAssignment --scope $scope --output json |
    ConvertFrom-Json
if ($LASTEXITCODE -ne 0) {
    throw "Cannot read policy assignment '$ApprovedModelsAssignment'."
}

$eligibility = az policy assignment show --name $EligibilityAssignment --scope $scope --output json |
    ConvertFrom-Json
if ($LASTEXITCODE -ne 0) {
    throw "Cannot read policy assignment '$EligibilityAssignment'."
}

function Get-ParameterValue {
    param($Assignment, [string]$Name)

    if (-not $Assignment.parameters -or -not $Assignment.parameters.PSObject.Properties[$Name]) {
        return $null
    }
    return $Assignment.parameters.$Name.value
}

$problems = @()
if ((Get-ParameterValue $approved "effect") -ne $register.assignmentEffect) {
    $problems += "The approved-models effect does not match the register."
}
if ((Get-ParameterValue $eligibility "effect") -ne $register.assignmentEffect) {
    $problems += "The eligibility effect does not match the register."
}

$liveAssets = @(Get-ParameterValue $approved "allowedAssetIds" | Sort-Object)
$livePublishers = @(Get-ParameterValue $approved "allowedPublishers" | Sort-Object)
if (Compare-Object -ReferenceObject @($register.allowedAssetIds | Sort-Object) -DifferenceObject $liveAssets) {
    $problems += "The live allowed asset IDs do not match the register."
}
if (Compare-Object -ReferenceObject @($register.allowedPublishers | Sort-Object) -DifferenceObject $livePublishers) {
    $problems += "The live allowed publishers do not match the register."
}
foreach ($toggle in @("onlyAllowDirectFromAzure", "denyPreviewModels")) {
    if ((Get-ParameterValue $eligibility $toggle) -ne $register.eligibility.$toggle) {
        $problems += "The live $toggle value does not match the register."
    }
}

if ($problems.Count -gt 0) {
    throw "FAIL: $($problems -join ' ')"
}

Write-Host ("PASS: Both assignments use effect $($register.assignmentEffect) with " +
    "$(@($register.allowedAssetIds).Count) approved model asset ID(s) and " +
    "$(@($register.allowedPublishers).Count) approved publisher(s) from the register.")
