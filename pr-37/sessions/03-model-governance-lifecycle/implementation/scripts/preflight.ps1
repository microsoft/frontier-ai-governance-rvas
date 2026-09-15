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
    [string]$FoundryAccountName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$OperatorObjectId,

    [switch]$ConfirmManualDataZone,

    [switch]$ConfirmManualLifecycle,

    [switch]$ConfirmManualQuota
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-AzJson {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $raw = & az @Arguments --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return (($raw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
}

function Get-PropertyValue {
    param(
        [AllowNull()]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [string]$Name
    )

    if ($null -eq $InputObject) {
        return $null
    }
    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }
    return $property.Value
}

function Assert-TextFields {
    param(
        [Parameter(Mandatory)]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [string[]]$Fields,

        [Parameter(Mandatory)]
        [string]$Description
    )

    foreach ($field in $Fields) {
        $value = Get-PropertyValue -InputObject $InputObject -Name $field
        if ($value -isnot [string] -or [string]::IsNullOrWhiteSpace($value)) {
            throw "$Description is missing text field '$field'."
        }
    }
}

function Get-JsonInteger {
    param(
        [AllowNull()]
        [object]$Value,

        [Parameter(Mandatory)]
        [string]$Description
    )

    if ($null -eq $Value) {
        throw "$Description must be a JSON integer, not a quoted string."
    }
    $integerTypes = @(
        [TypeCode]::SByte
        [TypeCode]::Byte
        [TypeCode]::Int16
        [TypeCode]::UInt16
        [TypeCode]::Int32
        [TypeCode]::UInt32
        [TypeCode]::Int64
        [TypeCode]::UInt64
    )
    if ([Type]::GetTypeCode($Value.GetType()) -notin $integerTypes) {
        throw "$Description must be a JSON integer, not a quoted string."
    }
    return [long]$Value
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required."
}

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$templatePath = Join-Path $artifactRoot "infra\models\main.bicep"
$parameterPath = Join-Path $artifactRoot "environments\sandbox.bicepparam"
$profilePath = Join-Path $artifactRoot "models\deployment-profiles.json"
$requiredSentinels = @(
    "__REQUIRED_APPROVAL_ID__"
    "__REQUIRED_APPROVED_MODEL_FORMAT__"
    "__REQUIRED_APPROVED_MODEL_NAME__"
    "__REQUIRED_APPROVED_MODEL_VERSION__"
    "__REQUIRED_DEPLOYMENT_CAPACITY_REPLACE_WITH_JSON_INTEGER__"
    "__REQUIRED_DEPLOYMENT_NAME__"
    "__REQUIRED_DEPLOYMENT_SKU__"
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
    "__REQUIRED_MINIMUM_UNUSED_QUOTA_PERCENT_REPLACE_WITH_JSON_INTEGER__"
    "__REQUIRED_PROCESSING_LOCATION_REQUIREMENT__"
    "__REQUIRED_RAI_POLICY_NAME__"
    "__REQUIRED_REVIEW_DATE__"
)
foreach ($path in @($templatePath, $parameterPath, $profilePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}

$sentinelMatches = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinelMatches.Count -gt 0) {
    $unresolved = @($sentinelMatches.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit checks for new Session 03 decisions: $($unknown -join ', ')"
    }
    throw "Resolve all Session 03 decisions before deployment: $($unresolved -join ', ')"
}

$profileSet = Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$profileSet.implementationSession -ne "03-model-governance-lifecycle") {
    throw "The deployment profiles have the wrong implementation marker."
}

$deployments = @($profileSet.deployments)
if ($deployments.Count -lt 1) {
    throw "deployment-profiles.json must contain at least one deployment."
}

$allowedSkus = @(
    "GlobalStandard"
    "GlobalProvisionedManaged"
    "GlobalBatch"
    "DataZoneStandard"
    "DataZoneProvisionedManaged"
    "DataZoneBatch"
    "Standard"
    "ProvisionedManaged"
)
$deploymentByName = @{}
foreach ($deployment in $deployments) {
    Assert-TextFields -InputObject $deployment `
        -Fields @(
            "approvalId"
            "deploymentName"
            "raiPolicyName"
            "versionUpgradeOption"
            "processingLocationRequirement"
            "reviewBy"
        ) `
        -Description "A deployment"
    Assert-TextFields -InputObject $deployment.model -Fields @("name", "version", "format") `
        -Description "Model for $($deployment.deploymentName)"
    Assert-TextFields -InputObject $deployment.sku -Fields @("name") `
        -Description "SKU for $($deployment.deploymentName)"
    if ($deploymentByName.ContainsKey([string]$deployment.deploymentName)) {
        throw "Duplicate deploymentName: $($deployment.deploymentName)"
    }
    if ([string]$deployment.sku.name -notin $allowedSkus) {
        if ([string]$deployment.sku.name -eq "DeveloperTier") {
            throw "DeveloperTier is limited to fine-tuned model evaluation, expires after 24 hours, and has no SLA or data-residency guarantee. It is outside this governed deployment path."
        }
        throw "Unsupported serverless API deployment SKU: $($deployment.sku.name)"
    }
    if ([string]$deployment.versionUpgradeOption -ne "NoAutoUpgrade") {
        throw "versionUpgradeOption must be NoAutoUpgrade for $($deployment.deploymentName); a model version change requires a new approved decision and profile change."
    }
    $capacity = Get-JsonInteger -Value $deployment.sku.capacity `
        -Description "Capacity for $($deployment.deploymentName)"
    if ($capacity -lt 1) {
        throw "Capacity for $($deployment.deploymentName) must be a positive integer."
    }
    $reviewBy = [datetime]::MinValue
    if (-not [datetime]::TryParseExact(
        [string]$deployment.reviewBy,
        "yyyy-MM-dd",
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::None,
        [ref]$reviewBy
    )) {
        throw "reviewBy must use YYYY-MM-DD for $($deployment.deploymentName)."
    }
    if ($reviewBy.Date -lt (Get-Date).Date) {
        throw "The deployment review date has passed for $($deployment.deploymentName)."
    }
    $requirement = [string]$deployment.processingLocationRequirement
    if ($requirement -notmatch "^(global|data-zone:(us|eu|apac)|region:[a-z0-9-]+)$") {
        throw "processingLocationRequirement must be global, data-zone:us, data-zone:eu, data-zone:apac, or region:<azure-region> for $($deployment.deploymentName)."
    }
    $headroom = Get-JsonInteger -Value $deployment.minimumUnusedQuotaPercent `
        -Description "minimumUnusedQuotaPercent for $($deployment.deploymentName)"
    if ($headroom -lt 0 -or $headroom -ge 100) {
        throw "minimumUnusedQuotaPercent must be an integer from 0 to 99 for $($deployment.deploymentName)."
    }
    if ($requirement -eq "global" -and -not ([string]$deployment.sku.name).StartsWith("Global")) {
        throw "Deployment $($deployment.deploymentName) does not implement global processing."
    }
    if ($requirement.StartsWith("data-zone:") -and -not ([string]$deployment.sku.name).StartsWith("DataZone")) {
        throw "Deployment $($deployment.deploymentName) does not implement data-zone processing."
    }
    if ($requirement.StartsWith("region:") -and [string]$deployment.sku.name -notin @("Standard", "ProvisionedManaged")) {
        throw "Deployment $($deployment.deploymentName) does not implement regional processing."
    }
    $deploymentByName[[string]$deployment.deploymentName] = $deployment
}

$parameterText = Get-Content -LiteralPath $parameterPath -Raw
$parameterMatch = [regex]::Match(
    $parameterText,
    "(?m)^\s*param\s+foundryAccountName\s*=\s*'(?<value>[^']+)'\s*$"
)
if (-not $parameterMatch.Success -or $parameterMatch.Groups["value"].Value -ne $FoundryAccountName) {
    throw "sandbox.bicepparam must name the Foundry resource passed to preflight."
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}
$foundry = Invoke-AzJson `
    -Arguments @(
        "cognitiveservices", "account", "show",
        "--name", $FoundryAccountName,
        "--resource-group", $ResourceGroupName
    ) `
    -Description "Foundry resource lookup"
$expectedFoundryId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.CognitiveServices/accounts/$FoundryAccountName"
if ([string]$foundry.id -ne $expectedFoundryId) {
    throw "The Foundry resource is outside the approved subscription or resource group."
}
if ([string]$foundry.kind -ne "AIServices") {
    throw "The existing Foundry resource must have kind AIServices."
}
if ([string]::IsNullOrWhiteSpace([string]$foundry.location)) {
    throw "The Foundry resource lookup did not return an account location."
}

$raiPolicyNames = @(
    $deployments |
        ForEach-Object { [string]$_.raiPolicyName } |
        Sort-Object -Unique
)
foreach ($raiPolicyName in $raiPolicyNames) {
    $raiPolicyId = "$expectedFoundryId/raiPolicies/$raiPolicyName"
    $raiPolicy = Invoke-AzJson `
        -Arguments @(
            "resource", "show",
            "--ids", $raiPolicyId,
            "--api-version", "2026-05-01"
        ) `
        -Description "Responsible AI policy lookup for '$raiPolicyName'"
    if (
        -not ([string]$raiPolicy.id).Equals(
            $raiPolicyId,
            [System.StringComparison]::OrdinalIgnoreCase
        )
    ) {
        throw "Responsible AI policy '$raiPolicyName' resolved outside the selected Foundry resource."
    }
    Write-Host "Responsible AI policy: $raiPolicyName -> $($raiPolicy.id)"
}

$roleAssignments = @(
    Invoke-AzJson `
        -Arguments @(
            "role", "assignment", "list",
            "--assignee-object-id", $OperatorObjectId,
            "--fill-principal-name", "false",
            "--scope", $expectedFoundryId
        ) `
        -Description "Operator role lookup"
)
$matchingRole = @(
    $roleAssignments | Where-Object {
        [string]$_.roleDefinitionName -eq "Cognitive Services Contributor" -and
        [string]$_.scope -ieq $expectedFoundryId
    }
)
if ($matchingRole.Count -lt 1) {
    throw "The operator lacks Cognitive Services Contributor on the exact Foundry resource."
}

$models = @(
    Invoke-AzJson `
        -Arguments @(
            "cognitiveservices", "account", "list-models",
            "--name", $FoundryAccountName,
            "--resource-group", $ResourceGroupName
        ) `
        -Description "Foundry model availability lookup"
)
$existingDeployments = @(
    Invoke-AzJson `
        -Arguments @(
            "cognitiveservices", "account", "deployment", "list",
            "--name", $FoundryAccountName,
            "--resource-group", $ResourceGroupName
        ) `
        -Description "Existing deployment lookup"
)
$usages = $null
try {
    $usages = @(
        Invoke-AzJson `
            -Arguments @("cognitiveservices", "usage", "list", "--location", [string]$foundry.location) `
            -Description "Live quota lookup"
    )
}
catch {
    Write-Warning $_
}

$existingByName = @{}
foreach ($existing in $existingDeployments) {
    $existingByName[[string]$existing.name] = $existing
}
$quotaIncrements = @{}
$headroomByUsage = @{}
$manualDataZone = [System.Collections.Generic.List[string]]::new()
$manualLifecycle = [System.Collections.Generic.List[string]]::new()
$manualQuota = [System.Collections.Generic.List[string]]::new()

foreach ($deployment in $deployments) {
    $matchingModels = @(
        $models | Where-Object {
            [string]$_.name -eq [string]$deployment.model.name -and
            [string]$_.version -eq [string]$deployment.model.version -and
            [string]$_.format -eq [string]$deployment.model.format
        }
    )
    if ($matchingModels.Count -ne 1) {
        throw "Model for $($deployment.deploymentName) is not available to this Foundry resource."
    }
    $model = $matchingModels[0]
    $lifecycle = ([string](Get-PropertyValue -InputObject $model -Name "lifecycleStatus") -replace "[^A-Za-z0-9]", "").ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($lifecycle)) {
        $manualLifecycle.Add("$($deployment.deploymentName): no lifecycleStatus was returned")
    }
    if ($lifecycle -in @("deprecating", "deprecated", "retired")) {
        throw "Model for $($deployment.deploymentName) has lifecycle state $($model.lifecycleStatus)."
    }

    $requirement = [string]$deployment.processingLocationRequirement
    $foundryLocation = ([string]$foundry.location).ToLowerInvariant()
    if ($requirement.StartsWith("region:")) {
        $requiredRegion = $requirement.Substring("region:".Length).ToLowerInvariant()
        if ($requiredRegion -ne $foundryLocation) {
            throw "Regional processing for $($deployment.deploymentName) requires $requiredRegion, but the Foundry account is in $foundryLocation."
        }
    }
    if ($requirement.StartsWith("data-zone:")) {
        $requiredZone = $requirement.Substring("data-zone:".Length)
        $manualDataZone.Add(
            "$($deployment.deploymentName): confirm $foundryLocation belongs to the approved $requiredZone data zone"
        )
    }
    $reviewBy = [datetime]::ParseExact(
        [string]$deployment.reviewBy,
        "yyyy-MM-dd",
        [Globalization.CultureInfo]::InvariantCulture
    )
    $deprecation = Get-PropertyValue -InputObject $model -Name "deprecation"
    $modelEndRaw = Get-PropertyValue -InputObject $deprecation -Name "inference"
    if ($modelEndRaw) {
        $modelEnd = [datetime]$modelEndRaw
        if ($modelEnd.Date -le (Get-Date).Date) {
            throw "Model for $($deployment.deploymentName) has reached its inference deprecation date."
        }
        if ($reviewBy.Date -ge $modelEnd.Date) {
            throw "Review $($deployment.approvalId) before the live inference deprecation date $($modelEnd.ToString('yyyy-MM-dd'))."
        }
    }

    $matchingSkus = @($model.skus | Where-Object { [string]$_.name -eq [string]$deployment.sku.name })
    if ($matchingSkus.Count -ne 1) {
        throw "SKU for $($deployment.deploymentName) is not available for the exact model version."
    }
    $sku = $matchingSkus[0]
    $skuEndRaw = Get-PropertyValue -InputObject $sku -Name "deprecationDate"
    if ($skuEndRaw) {
        $skuEnd = [datetime]$skuEndRaw
        if ($skuEnd.Date -le (Get-Date).Date) {
            throw "SKU for $($deployment.deploymentName) has reached its deprecation date."
        }
        if ($reviewBy.Date -ge $skuEnd.Date) {
            throw "Review $($deployment.approvalId) before the live SKU deprecation date $($skuEnd.ToString('yyyy-MM-dd'))."
        }
    }
    $requested = [int]$deployment.sku.capacity
    $capacity = Get-PropertyValue -InputObject $sku -Name "capacity"
    $minimum = Get-PropertyValue -InputObject $capacity -Name "minimum"
    $maximum = Get-PropertyValue -InputObject $capacity -Name "maximum"
    $step = Get-PropertyValue -InputObject $capacity -Name "step"
    if ($null -ne $minimum -and $requested -lt [int]$minimum) {
        throw "Capacity for $($deployment.deploymentName) is below the live minimum $minimum."
    }
    if ($null -ne $maximum -and $requested -gt [int]$maximum) {
        throw "Capacity for $($deployment.deploymentName) exceeds the live maximum $maximum."
    }
    $minimumBase = 0
    if ($null -ne $minimum) {
        $minimumBase = [int]$minimum
    }
    if ($null -ne $step -and [int]$step -gt 0 -and
        (($requested - $minimumBase) % [int]$step) -ne 0) {
        throw "Capacity for $($deployment.deploymentName) does not follow the live step $step."
    }

    $usageName = [string](Get-PropertyValue -InputObject $sku -Name "usageName")
    if ([string]::IsNullOrWhiteSpace($usageName)) {
        $manualQuota.Add("$($deployment.deploymentName): model metadata has no quota usageName")
        continue
    }
    $currentCapacity = 0
    if ($existingByName.ContainsKey([string]$deployment.deploymentName)) {
        $currentDeployment = $existingByName[[string]$deployment.deploymentName]
        $currentModel = Get-PropertyValue `
            -InputObject (Get-PropertyValue -InputObject $currentDeployment -Name "properties") `
            -Name "model"
        $currentModelMatches = @(
            $models | Where-Object {
                [string]$_.name -eq [string](Get-PropertyValue -InputObject $currentModel -Name "name") -and
                [string]$_.version -eq [string](Get-PropertyValue -InputObject $currentModel -Name "version") -and
                [string]$_.format -eq [string](Get-PropertyValue -InputObject $currentModel -Name "format")
            }
        )
        if ($currentModelMatches.Count -eq 1) {
            $currentSkuName = [string](
                Get-PropertyValue `
                    -InputObject (Get-PropertyValue -InputObject $currentDeployment -Name "sku") `
                    -Name "name"
            )
            $currentSkus = @(
                $currentModelMatches[0].skus | Where-Object {
                    [string]$_.name -eq $currentSkuName
                }
            )
            if (
                $currentSkus.Count -eq 1 -and
                [string](Get-PropertyValue -InputObject $currentSkus[0] -Name "usageName") -eq $usageName
            ) {
                $currentCapacity = [int](
                    Get-PropertyValue `
                        -InputObject (Get-PropertyValue -InputObject $currentDeployment -Name "sku") `
                        -Name "capacity"
                )
            }
        }
    }
    $increment = [math]::Max($requested - $currentCapacity, 0)
    $currentIncrement = 0
    if ($quotaIncrements.ContainsKey($usageName)) {
        $currentIncrement = [int]$quotaIncrements[$usageName]
    }
    $quotaIncrements[$usageName] = $currentIncrement + $increment
    $currentHeadroom = 0
    if ($headroomByUsage.ContainsKey($usageName)) {
        $currentHeadroom = [int]$headroomByUsage[$usageName]
    }
    $headroomByUsage[$usageName] = [math]::Max(
        $currentHeadroom,
        [int]$deployment.minimumUnusedQuotaPercent
    )
}

$manualDataZoneMessage = $manualDataZone -join "; "
if ($manualDataZone.Count -gt 0 -and -not $ConfirmManualDataZone) {
    throw "Azure CLI does not expose a stable data-zone membership mapping. Verify the Foundry account location against the current Microsoft data-zone region list, then rerun with -ConfirmManualDataZone. Details: $manualDataZoneMessage"
}
if ($manualDataZone.Count -gt 0) {
    Write-Warning "MANUAL DATA-ZONE CHECK CONFIRMED: $manualDataZoneMessage"
}

$manualLifecycleMessage = $manualLifecycle -join "; "
if ($manualLifecycle.Count -gt 0 -and -not $ConfirmManualLifecycle) {
    throw "Azure CLI did not return lifecycleStatus for every model. Check the current model details and retirement notice, then rerun with -ConfirmManualLifecycle. Details: $manualLifecycleMessage"
}
if ($manualLifecycle.Count -gt 0) {
    Write-Warning "MANUAL LIFECYCLE CONFIRMED: $manualLifecycleMessage"
}

$usageByName = @{}
foreach ($usage in @($usages)) {
    $name = Get-PropertyValue -InputObject (Get-PropertyValue -InputObject $usage -Name "name") -Name "value"
    if ($name) {
        $usageByName[[string]$name] = $usage
    }
}
foreach ($usageName in $quotaIncrements.Keys) {
    if (-not $usageByName.ContainsKey($usageName)) {
        $manualQuota.Add("$usageName`: no exact live quota metric was returned")
        continue
    }
    $usage = $usageByName[$usageName]
    $limit = [double]$usage.limit
    $current = [double]$usage.currentValue
    if ($limit -le 0) {
        throw "Live quota limit for $usageName is zero."
    }
    $remainingPercent = (($limit - $current - [int]$quotaIncrements[$usageName]) / $limit) * 100
    if ($remainingPercent -lt [int]$headroomByUsage[$usageName]) {
        throw "Projected unused quota for $usageName is $($remainingPercent.ToString('0.0'))%; policy requires $($headroomByUsage[$usageName])%."
    }
}
if ($manualQuota.Count -gt 0 -and -not $ConfirmManualQuota) {
    throw "Azure CLI could not map every deployment to live quota. Check the Foundry Quota page, then rerun with -ConfirmManualQuota. Details: $($manualQuota -join '; ')"
}
if ($manualQuota.Count -gt 0) {
    Write-Warning "MANUAL QUOTA CONFIRMED: $($manualQuota -join '; ')"
}

& az bicep build --file $templatePath --stdout --only-show-errors | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Bicep build failed: $templatePath"
}

$whatIf = Invoke-AzJson `
    -Arguments @(
        "deployment", "group", "what-if",
        "--resource-group", $ResourceGroupName,
        "--name", "rvas-s03-preflight",
        "--template-file", $templatePath,
        "--parameters", $parameterPath,
        "--result-format", "FullResourcePayloads",
        "--no-pretty-print"
    ) `
    -Description "Bicep what-if"
$allowedResourceIds = @{}
foreach ($deployment in $deployments) {
    $allowedResourceIds["$expectedFoundryId/deployments/$($deployment.deploymentName)".ToLowerInvariant()] = $true
}
foreach ($change in @($whatIf.changes)) {
    $resourceId = ([string]$change.resourceId).ToLowerInvariant()
    if (-not $allowedResourceIds.ContainsKey($resourceId)) {
        throw "What-if includes an unrelated resource: $resourceId"
    }
    if ([string]$change.changeType -notin @("Create", "Modify", "NoChange")) {
        throw "What-if change $($change.changeType) is not allowed for $resourceId."
    }
}

$whatIf | ConvertTo-Json -Depth 20
Write-Host "PASS: Session 03 deployment plan, Responsible AI policies, operator role, live availability and lifecycle, quota gate, Bicep, and scoped what-if are ready."
