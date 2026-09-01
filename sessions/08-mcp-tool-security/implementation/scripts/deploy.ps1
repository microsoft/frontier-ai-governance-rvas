[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "preflight.ps1") -ApprovedSubscriptionId $ApprovedSubscriptionId
if ($LASTEXITCODE -ne 0) {
    throw "Session 08 preflight failed."
}

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$environmentPath = Join-Path $artifactRoot "environments\sandbox.json"
$bicepPath = Join-Path $artifactRoot "apim\main.bicep"
$environment = Get-Content -LiteralPath $environmentPath -Raw |
    ConvertFrom-Json -ErrorAction Stop

$deployment = & az deployment group create `
    --name "session07-mcp-tool-security" `
    --resource-group ([string]$environment.resourceGroupName) `
    --template-file $bicepPath `
    --parameters "apiManagementName=$($environment.apiManagementName)" `
    --only-show-errors `
    --output json
if ($LASTEXITCODE -ne 0) {
    throw "Session 08 APIM deployment failed."
}
$result = $deployment | ConvertFrom-Json -ErrorAction Stop
if ([string]$result.properties.provisioningState -ne "Succeeded") {
    throw "Session 08 APIM deployment did not reach Succeeded."
}

Write-Host "PASS: Deployed the marked MCP server, one read tool, identity policy, throttle, correlation trace, and payload-free diagnostic."
Write-Host "Next: create the candidate Foundry agent version from agent-mcp-binding.json. Do not pin it before both extended checks."
