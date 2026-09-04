[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [string]$CitadelPath,

    [Parameter(Mandatory)]
    [string]$SubscriptionId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "preflight.ps1") -CitadelPath $CitadelPath -SubscriptionId $SubscriptionId
$profile = Get-Content (Join-Path $PSScriptRoot "../artifacts/citadel/deployment-profile.json") -Raw | ConvertFrom-Json

$environment:AZURE_ENV_NAME = $profile.environmentName
$environment:AZURE_LOCATION = $profile.location
$environment:AZURE_RESOURCE_GROUP = $profile.resourceGroupName
$environment:USE_EXISTING_VNET = $profile.network.useExistingVnet.ToString().ToLowerInvariant()
$environment:EXISTING_VNET_RG = $profile.network.existingVnetResourceGroup
$environment:VNET_NAME = $profile.network.vnetName
$environment:APIM_SUBNET_NAME = $profile.network.apimSubnetName
$environment:PRIVATE_ENDPOINT_SUBNET_NAME = $profile.network.privateEndpointSubnetName
$environment:USE_EXISTING_LOG_ANALYTICS = $profile.monitoring.useExistingLogAnalytics.ToString().ToLowerInvariant()
$environment:EXISTING_LOG_ANALYTICS_RG = $profile.monitoring.workspaceResourceGroup
$environment:EXISTING_LOG_ANALYTICS_NAME = $profile.monitoring.workspaceName
$environment:ENABLE_API_CENTER = $profile.features.enableApiCenter.ToString().ToLowerInvariant()
$environment:ENABLE_PII_REDACTION = $profile.features.enablePiiRedaction.ToString().ToLowerInvariant()
$environment:ENABLE_MANAGED_REDIS = $profile.features.enableManagedRedis.ToString().ToLowerInvariant()
$environment:ENABLE_AZURE_AI_SEARCH = $profile.features.enableAzureAiSearch.ToString().ToLowerInvariant()
$environment:ENABLE_DOCUMENT_INTELLIGENCE = $profile.features.enableDocumentIntelligence.ToString().ToLowerInvariant()

if ($PSCmdlet.ShouldProcess($profile.resourceGroupName, "Provision and deploy the pinned Citadel Governance Hub")) {
    Push-Location $CitadelPath
    try {
        & azd env select $profile.environmentName 2>$null
        if ($LASTEXITCODE -ne 0) {
            & azd env new $profile.environmentName
        }
        & azd provision
        if ($LASTEXITCODE -ne 0) { throw "azd provision failed." }
        & azd deploy
        if ($LASTEXITCODE -ne 0) { throw "azd deploy failed." }
    }
    finally {
        Pop-Location
    }
}

Write-Host "PASS: Citadel Governance Hub deployment completed through the pinned source."
