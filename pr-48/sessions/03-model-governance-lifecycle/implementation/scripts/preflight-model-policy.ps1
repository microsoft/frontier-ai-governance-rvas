[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetScope,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$registerPath = Join-Path $artifactRoot "model-approval-register.json"
$templatePath = Join-Path $artifactRoot "policy\model-governance.bicep"
$parameterPath = Join-Path $artifactRoot "policy\model-governance.bicepparam"
$requiredSentinels = @(
    "__REQUIRED_APPROVED_DATA_CLASSIFICATION__",
    "__REQUIRED_APPROVED_DEPLOYMENT_TYPE__",
    "__REQUIRED_APPROVED_MODEL_ASSET_ID__",
    "__REQUIRED_APPROVED_POLICY_SCOPE_ALIAS__",
    "__REQUIRED_APPROVED_PROCESSING_LOCATION__",
    "__REQUIRED_APPROVED_PUBLISHER_NAME__",
    "__REQUIRED_APPROVED_USE_CASE_BOUNDARY__",
    "__REQUIRED_DATA_OWNER_ROLE__",
    "__REQUIRED_EVALUATION_REFERENCE__",
    "__REQUIRED_MODEL_REVIEW_DATE__",
    "__REQUIRED_PLATFORM_OWNER_ROLE__",
    "__REQUIRED_PREVIOUS_ASSIGNMENT_REFERENCE__",
    "__REQUIRED_REGISTER_REVIEW_DATE__",
    "__REQUIRED_SECURITY_OWNER_ROLE__"
)

if (-not (Get-Command -Name "az" -ErrorAction SilentlyContinue)) {
    throw "The Azure CLI is required."
}

foreach ($path in @($registerPath, $templatePath, $parameterPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required Session 03 policy artifact is missing: $path"
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
    throw "Resolve every model approval decision before assigning policy: $($unresolved -join ', ')"
}

if ([string]::IsNullOrWhiteSpace($env:RVAS_APPROVED_MODELS_POLICY_ID)) {
    throw "Set RVAS_APPROVED_MODELS_POLICY_ID to the built-in approved-models policy definition ID."
}
if ([string]::IsNullOrWhiteSpace($env:RVAS_MODEL_ELIGIBILITY_POLICY_ID)) {
    throw "Set RVAS_MODEL_ELIGIBILITY_POLICY_ID to the built-in eligibility policy definition ID."
}

$register = Get-Content -LiteralPath $registerPath -Raw | ConvertFrom-Json
if ($register.implementationSession -ne "03-model-governance-lifecycle") {
    throw "The register has the wrong implementationSession marker."
}
if ($register.approvedScope -ne $TargetScope) {
    throw "The register scope must match -TargetScope."
}

$effect = $register.assignmentEffect
if (@("Audit", "Deny") -notcontains $effect) {
    throw "assignmentEffect must be Audit or Deny."
}

foreach ($toggle in @("onlyAllowDirectFromAzure", "denyPreviewModels")) {
    if ($register.eligibility.$toggle -isnot [bool]) {
        throw "eligibility.$toggle must be true or false."
    }
}

$models = @($register.approvedModels)
if ($models.Count -eq 0) {
    throw "The register must contain at least one approved model."
}

$assetPattern = "^azureml://registries/[^/]+/models/[^/]+/(versions/[^/]+)?$"
$requiredFields = @(
    "assetId",
    "publisher",
    "sourceCategory",
    "lifecycleStatus",
    "hostingRoute",
    "processingLocation",
    "useCaseBoundary",
    "dataClassificationCeiling",
    "evaluationReference",
    "reviewDate"
)

foreach ($model in $models) {
    foreach ($field in $requiredFields) {
        if ([string]::IsNullOrWhiteSpace([string]$model.$field)) {
            throw "Approved model entry is missing $field."
        }
    }
    if (@("SoldByAzure", "PartnersAndCommunity") -notcontains $model.sourceCategory) {
        throw "sourceCategory must be SoldByAzure or PartnersAndCommunity."
    }
    if (@("GenerallyAvailable", "Preview") -notcontains $model.lifecycleStatus) {
        throw "lifecycleStatus must be GenerallyAvailable or Preview."
    }
    if ($model.assetId -notmatch $assetPattern) {
        throw ("Each assetId must be a registry model ID ending in a trailing slash or an explicit " +
            "version, so prefix matching cannot allow a longer model name: $($model.assetId)")
    }
    if (@($model.approvedDeploymentTypes).Count -eq 0) {
        throw "Record the approved deployment types for $($model.assetId)."
    }
    foreach ($role in @("platformOwner", "securityOwner", "dataOwner")) {
        if ([string]::IsNullOrWhiteSpace([string]$model.approvers.$role)) {
            throw "Record the $role who approved $($model.assetId)."
        }
    }
    if ($register.eligibility.onlyAllowDirectFromAzure -and $model.sourceCategory -ne "SoldByAzure") {
        throw ("onlyAllowDirectFromAzure is true, so the policy denies $($model.assetId) " +
            "even though the register approves it.")
    }
    if ($register.eligibility.denyPreviewModels -and $model.lifecycleStatus -eq "Preview") {
        throw ("denyPreviewModels is true, so the policy denies $($model.assetId) " +
            "even though the register approves it.")
    }
}

$registerAssets = @($models | ForEach-Object { $_.assetId } | Sort-Object -Unique)
$registerPublishers = @($models | ForEach-Object { $_.publisher } | Sort-Object -Unique)
$allowedAssets = @($register.allowedAssetIds | Sort-Object -Unique)
$allowedPublishers = @($register.allowedPublishers | Sort-Object -Unique)
if (Compare-Object -ReferenceObject $registerAssets -DifferenceObject $allowedAssets) {
    throw "allowedAssetIds must contain exactly the approved model asset IDs."
}
if (Compare-Object -ReferenceObject $registerPublishers -DifferenceObject $allowedPublishers) {
    throw "allowedPublishers must contain exactly the approved model publishers."
}

Write-Host "Register holds $($models.Count) approved model(s) with effect $effect."
Write-Host "Previewing the policy assignment deployment in resource group '$ResourceGroup'..."
az deployment group what-if `
    --resource-group $ResourceGroup `
    --template-file $templatePath `
    --parameters $parameterPath
if ($LASTEXITCODE -ne 0) {
    throw "The policy assignment preview failed. Resolve the reported error before deploying."
}

Write-Host "PASS: The model approval register and policy assignment preview are ready for scope '$TargetScope'."
Write-Host "Review the what-if output before deploying, then keep the effect at Audit until compliance is reviewed."
