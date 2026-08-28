[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidatePattern("^https://")]
    [string]$PrimaryAgentBaseUrl,

    [Parameter()]
    [ValidatePattern("^$|^https://")]
    [string]$SecondaryAgentBaseUrl = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$environmentPath = Join-Path $artifactRoot "environments\sandbox.json"
$bicepPath = Join-Path $artifactRoot "gateway\main.bicep"
$environment = Get-Content -LiteralPath $environmentPath -Raw | ConvertFrom-Json -ErrorAction Stop

& (Join-Path $PSScriptRoot "preflight.ps1") `
    -ApprovedSubscriptionId $ApprovedSubscriptionId `
    -PrimaryAgentBaseUrl $PrimaryAgentBaseUrl `
    -SecondaryAgentBaseUrl $SecondaryAgentBaseUrl
if ($LASTEXITCODE -ne 0) {
    throw "Session 07 preflight failed."
}

$deployment = & az deployment group create `
    --name "session06-apim-ai-gateway" `
    --resource-group ([string]$environment.resourceGroupName) `
    --template-file $bicepPath `
    --parameters `
      "primaryAgentBaseUrl=$PrimaryAgentBaseUrl" `
      "secondaryAgentBaseUrl=$SecondaryAgentBaseUrl" `
      "apiManagementName=$($environment.apiManagementName)" `
      "applicationInsightsLoggerName=$($environment.applicationInsightsLoggerName)" `
      "contentSafetyBackendId=$($environment.contentSafetyBackendId)" `
      "secondaryBackendEnabled=$($environment.secondaryBackendEnabled.ToString().ToLowerInvariant())" `
    --only-show-errors `
    --output json
if ($LASTEXITCODE -ne 0) {
    throw "Session 07 API Management deployment failed."
}

$result = $deployment | ConvertFrom-Json -ErrorAction Stop
Write-Host "Deployed Session 07 API Management control."
Write-Host "Gateway path: $($result.properties.outputs.gatewayPath.value)"
Write-Host "The product owner must issue or approve a workload-specific product subscription before client use."
