[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CitadelPath,

    [Parameter(Mandatory)]
    [string]$SubscriptionId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Required profile sentinels checked before deployment:
# __REQUIRED_HUB_RESOURCE_GROUP__ __REQUIRED_NETWORK_RESOURCE_GROUP__ __REQUIRED_VNET_NAME__
# __REQUIRED_APIM_SUBNET_NAME__ __REQUIRED_PRIVATE_ENDPOINT_SUBNET_NAME__
# __REQUIRED_LOG_ANALYTICS_RESOURCE_GROUP__ __REQUIRED_LOG_ANALYTICS_NAME__

foreach ($commandName in @("git", "az", "azd")) {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "$commandName is required."
    }
}

$artifactRoot = Join-Path $PSScriptRoot "../artifacts"
$release = Get-Content (Join-Path $artifactRoot "citadel/release.json") -Raw | ConvertFrom-Json
$profilePath = Join-Path $artifactRoot "citadel/deployment-profile.json"
$profileText = Get-Content $profilePath -Raw
if ($profileText -match "__REQUIRED_[A-Z0-9_]+__") {
    throw "Resolve every __REQUIRED_*__ value in the Citadel deployment profile."
}

$actualCommit = (& git -C $CitadelPath rev-parse HEAD).Trim()
if ($actualCommit -ne $release.commit) {
    throw "Citadel checkout must resolve to $($release.commit)."
}

$activeSubscription = (& az account show --query id --output tsv --only-show-errors).Trim()
if ($activeSubscription -ne $SubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}

foreach ($relativePath in @($release.templatePath, $release.parameterPath)) {
    if (-not (Test-Path (Join-Path $CitadelPath $relativePath))) {
        throw "The pinned Citadel deployment file is missing: $relativePath"
    }
}

Write-Host "PASS: pinned Citadel source, deployment profile, tools, and Azure subscription are ready."
