param(
    [Parameter(Mandatory = $true)]
    [string]$ArtifactsDir
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
# Shared checker rejects these decisions before inspecting the approved target scope.
# __REQUIRED_SUBSCRIPTION_ID__ __REQUIRED_TENANT_ID__ __REQUIRED_APIM_RESOURCE_GROUP__
# __REQUIRED_APIM_NAME__ __REQUIRED_FOUNDRY_RESOURCE_GROUP__ __REQUIRED_FOUNDRY_NAME__
# __REQUIRED_GATEWAY_CLIENT_ID__ __REQUIRED_DESKTOP_CLIENT_ID__ __REQUIRED_GATEWAY_BASE_URL__
# __REQUIRED_GATEWAY_OWNER__ __REQUIRED_IDENTITY_OWNER__ __REQUIRED_CLIENT_OWNER__
# __REQUIRED_RESTORE_REFERENCE__ __REQUIRED_NETWORK_PATH__ __REQUIRED_HELPER_COMMAND__
# __REQUIRED_SONNET_DEPLOYMENT__ __REQUIRED_OPUS_DEPLOYMENT__ __REQUIRED_HAIKU_DEPLOYMENT__
Get-Command python3 -ErrorAction Stop | Out-Null
Get-Command az -ErrorAction Stop | Out-Null
$checker = Join-Path $PSScriptRoot "preflight.py"
if (-not (Test-Path -LiteralPath $checker -PathType Leaf)) {
    throw "Missing shared preflight checker."
}
& python3 $checker --artifacts-dir $ArtifactsDir
if ($LASTEXITCODE -ne 0) { throw "Preflight failed." }
