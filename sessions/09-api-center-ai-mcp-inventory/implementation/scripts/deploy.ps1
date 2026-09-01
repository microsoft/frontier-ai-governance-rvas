[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidatePattern("^https://")]
    [string]$Session05AgentBaseUrl,

    [Parameter(Mandatory)]
    [ValidatePattern("^https://")]
    [string]$RemoteMcpServerUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$environmentPath = Join-Path $artifactRoot "environments\sandbox.json"
$bicepPath = Join-Path $artifactRoot "api-center\main.bicep"
$openApiPath = Join-Path $artifactRoot "catalog\specs\policy-assistant-agent.openapi.json"
$agentDefinitionPath = Join-Path $artifactRoot "api-center\agent-api-definition.json"
$environment = Get-Content -LiteralPath $environmentPath -Raw | ConvertFrom-Json -ErrorAction Stop
$agentRecord = (Get-Content -LiteralPath $agentDefinitionPath -Raw | ConvertFrom-Json -ErrorAction Stop).api

& (Join-Path $PSScriptRoot "preflight.ps1") `
    -ApprovedSubscriptionId $ApprovedSubscriptionId `
    -Session05AgentBaseUrl $Session05AgentBaseUrl `
    -RemoteMcpServerUrl $RemoteMcpServerUrl

$deploymentRaw = & az deployment group create `
    --name "session09-api-center-inventory" `
    --resource-group ([string]$environment.resourceGroupName) `
    --template-file $bicepPath `
    --parameters `
      "apiManagementResourceGroupName=$($environment.apiManagementResourceGroupName)" `
      "apiManagementName=$($environment.apiManagementName)" `
      "apiCenterName=$($environment.apiCenterName)" `
      "location=$($environment.location)" `
      "session05AgentBaseUrl=$Session05AgentBaseUrl" `
    --only-show-errors `
    --output json
if ($LASTEXITCODE -ne 0) {
    throw "Session 09 API Center deployment failed."
}
$deployment = $deploymentRaw | ConvertFrom-Json -ErrorAction Stop

$specification = '{"name":"openapi","version":"3.0.3"}'
& az apic api definition import-specification `
    --resource-group ([string]$environment.resourceGroupName) `
    --service-name ([string]$environment.apiCenterName) `
    --api-id ([string]$agentRecord.apiId) `
    --version-id ([string]$agentRecord.versionId) `
    --definition-id ([string]$agentRecord.definitionId) `
    --format inline `
    --value "@$openApiPath" `
    --specification $specification `
    --only-show-errors `
    --output none
if ($LASTEXITCODE -ne 0) {
    throw "Importing the authoritative agent OpenAPI definition failed."
}

$apimId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$($environment.apiManagementResourceGroupName)/providers/Microsoft.ApiManagement/service/$($environment.apiManagementName)"
$existingIntegrationRaw = & az apic integration show `
    --resource-group ([string]$environment.resourceGroupName) `
    --service-name ([string]$environment.apiCenterName) `
    --integration-name ([string]$environment.integrationName) `
    --only-show-errors `
    --output json 2>$null
if ($LASTEXITCODE -eq 0) {
    if (($existingIntegrationRaw | Out-String) -notmatch [regex]::Escape($apimId)) {
        throw "The current integration name points to a different API source."
    }
    Write-Host "The current APIM integration already exists."
}
else {
    & az apic integration create apim `
        --resource-group ([string]$environment.resourceGroupName) `
        --service-name ([string]$environment.apiCenterName) `
        --integration-name ([string]$environment.integrationName) `
        --azure-apim $apimId `
        --import-specification always `
        --target-lifecycle-stage testing `
        --only-show-errors `
        --output none
    if ($LASTEXITCODE -ne 0) {
        throw "Creating the Session 08 APIM integration failed."
    }
}

Write-Host "Deployed the marked Session 09 API Center control."
Write-Host "API Center: $($deployment.properties.outputs.apiCenterId.value)"
Write-Host "APIM synchronization can take up to 24 hours."
Write-Host "Confirm the current '$($environment.apiCenterPlan)' plan in the API Center portal; the stable 2024-03-01 Bicep service resource does not expose plan selection."
Write-Host "Register the registered remote MCP server through the current native API Center portal flow, using only the supplied runtime URL."
Write-Host "After synchronization and MCP registration, run check-inventory.ps1 with the portal MCP title."
