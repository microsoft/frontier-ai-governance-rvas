[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId
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

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$environment = Get-Content -LiteralPath (Join-Path $artifactRoot "environments\sandbox.json") -Raw |
    ConvertFrom-Json -ErrorAction Stop
$catalog = Get-Content -LiteralPath (Join-Path $artifactRoot "catalog\catalog-records.json") -Raw |
    ConvertFrom-Json -ErrorAction Stop
$agentRecord = $catalog.records.agent
$apimRecord = $catalog.records.apim
$mcpRecord = $catalog.records.mcp

if ((Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")) {
    throw "Resolve every Session 08 customer decision before checking the live inventory."
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}
$result = Invoke-AzJson `
    -Arguments @(
        "apic", "api", "list",
        "--resource-group", [string]$environment.resourceGroupName,
        "--service-name", [string]$environment.apiCenterName,
        "--max-items", "500"
    ) `
    -Description "API Center inventory lookup"
$apis = if ($null -ne $result.PSObject.Properties["value"]) {
    @($result.value)
}
else {
    @($result)
}
$requiredTitles = @(
    [string]$agentRecord.title
    [string]$apimRecord.sourceTitle
    [string]$mcpRecord.title
)
foreach ($title in $requiredTitles) {
    $count = @($apis | Where-Object { [string]$_.properties.title -eq $title }).Count
    if ($count -ne 1) {
        throw "Expected exactly one inventory asset titled '$title'; found $count."
    }
}

$requiredProperties = @(
    "businessOwner"
    "technicalOwner"
    "assetKind"
    "dataClassification"
    "permittedConsumers"
    "modelProvider"
    "residencyProfile"
    "riskTier"
    "evaluationResultsUrl"
    "lastReviewDate"
    "expiryDate"
    "implementationSession"
)
$orphans = [System.Collections.Generic.List[string]]::new()
foreach ($api in $apis) {
    $apiPropertiesProperty = $api.PSObject.Properties["properties"]
    $apiProperties = if ($null -eq $apiPropertiesProperty) {
        $null
    }
    else {
        $apiPropertiesProperty.Value
    }
    $properties = if ($null -eq $apiProperties) {
        $null
    }
    else {
        $customPropertiesProperty = $apiProperties.PSObject.Properties["customProperties"]
        if ($null -eq $customPropertiesProperty) {
            $null
        }
        else {
            $customPropertiesProperty.Value
        }
    }
    $actualNames = if ($null -eq $properties) {
        @()
    }
    else {
        @($properties.PSObject.Properties.Name)
    }
    $missing = if ($null -eq $properties) {
        @($requiredProperties)
    }
    else {
        @($requiredProperties | Where-Object {
                $property = $properties.PSObject.Properties[$_]
                $_ -notin $actualNames -or
                $null -eq $property -or
                $null -eq $property.Value -or
                [string]::IsNullOrWhiteSpace([string]$property.Value)
            })
    }
    if ($missing.Count -gt 0) {
        $title = if ($null -eq $apiProperties) {
            [string]$api.name
        }
        else {
            $titleProperty = $apiProperties.PSObject.Properties["title"]
            if ($null -eq $titleProperty) {
                [string]$api.name
            }
            else {
                [string]$titleProperty.Value
            }
        }
        $orphans.Add("${title}: $($missing -join ', ')")
    }
}
if ($orphans.Count -gt 0) {
    throw "Inventory assets are missing mandatory metadata:`n$($orphans -join "`n")"
}

$integration = Invoke-AzJson -Arguments @(
    "apic", "integration", "show",
    "--resource-group", [string]$environment.resourceGroupName,
    "--service-name", [string]$environment.apiCenterName,
    "--integration-name", [string]$environment.integrationName
) -Description "API Center APIM integration lookup"
$state = [string]$integration.properties.provisioningState
$expectedApimId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.apiManagementResourceGroupName)/providers/Microsoft.ApiManagement/service/$($environment.apiManagementName)"
if (($integration | ConvertTo-Json -Depth 30) -notlike "*$expectedApimId*") {
    throw "The API Center integration does not point to the current APIM source."
}
if ([string]::IsNullOrWhiteSpace($state)) {
    Write-Warning "This API Center response does not expose integration provisioning state. Check source health manually in the portal."
}
elseif ($state -notin @("Succeeded", "Ready")) {
    throw "The APIM source integration is not healthy. Current provisioning state: $state."
}

Write-Host "PASS: the three records have mandatory metadata and the APIM integration resolves to the implementation source. Provisioning state is checked when exposed; native MCP deployment health remains manual."
