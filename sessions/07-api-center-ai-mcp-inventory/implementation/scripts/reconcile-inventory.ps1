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
$environmentPath = Join-Path $artifactRoot "environments\sandbox.json"
$apimRecordPath = Join-Path $artifactRoot "catalog\catalog-records.json"
if ((Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")) {
    throw "Resolve every Session 07 customer decision before reconciling the inventory."
}
$environment = Get-Content -LiteralPath $environmentPath -Raw | ConvertFrom-Json -ErrorAction Stop
$catalog = Get-Content -LiteralPath $apimRecordPath -Raw | ConvertFrom-Json -ErrorAction Stop
$record = $catalog.records.apim
$properties = [ordered]@{}
foreach ($property in $catalog.commonMetadata.PSObject.Properties) {
    $properties[$property.Name] = $property.Value
}
foreach ($property in $record.customProperties.PSObject.Properties) {
    $properties[$property.Name] = $property.Value
}
$record.customProperties = [pscustomobject]$properties

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
$matches = @($apis | Where-Object { [string]$_.properties.title -eq [string]$record.sourceTitle })
if ($matches.Count -ne 1) {
    throw "Expected one synchronized API titled '$($record.sourceTitle)'; found $($matches.Count). Wait for synchronization or resolve duplicate titles."
}

$apiId = if (-not [string]::IsNullOrWhiteSpace([string]$matches[0].name)) {
    [string]$matches[0].name
}
else {
    ([string]$matches[0].id).Split("/")[-1]
}
$customProperties = $record.customProperties | ConvertTo-Json -Compress -Depth 20
& az apic api update `
    --resource-group ([string]$environment.resourceGroupName) `
    --service-name ([string]$environment.apiCenterName) `
    --api-id $apiId `
    --custom-properties $customProperties `
    --only-show-errors `
    --output none
if ($LASTEXITCODE -ne 0) {
    throw "Updating mandatory metadata on the synchronized Session 06 API failed."
}

Write-Host "Updated mandatory governance metadata on '$($record.sourceTitle)'."
