[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CitadelPath,

    [Parameter(Mandatory)]
    [string]$ResourceGroup
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Contract and governance sentinels:
# __REQUIRED_SUBSCRIPTION_ID__ __REQUIRED_HUB_RESOURCE_GROUP__ __REQUIRED_APIM_NAME__
# __REQUIRED_APIM_IDENTITY_NAME__ __REQUIRED_FOUNDRY_ENDPOINT__ __REQUIRED_MODEL_DEPLOYMENT_NAME__
# __REQUIRED_MODEL_SKU__ __REQUIRED_MODEL_VERSION__ __REQUIRED_SPOKE_RESOURCE_GROUP__
# __REQUIRED_KEY_VAULT_NAME__ __REQUIRED_BUSINESS_UNIT__ __REQUIRED_API_CENTER_NAME__
# __REQUIRED_TOOL_OWNER__ __REQUIRED_TOOL_CONTACT__ __REQUIRED_MCP_SERVER_URL__
# __REQUIRED_MCP_AUDIENCE__ __REQUIRED_AGENT_NAME__ __REQUIRED_TOOL_DATA_CLASSIFICATION__
# __REQUIRED_FOUNDRY_MCP_CONNECTION_NAME__ __REQUIRED_BACKING_API_ID__
# __REQUIRED_BACKING_READ_OPERATION_ID__ __REQUIRED_PROHIBITED_WRITE_ACTION__
# __REQUIRED_HUMAN_CHANGE_ROUTE__ __REQUIRED_RELEASE_OWNER__ __REQUIRED_SECURITY_OWNER__
# __REQUIRED_APPROVED_READ_RECORD_ID__ __REQUIRED_ADVERSARIAL_RECORD_ID__
# __REQUIRED_MCP_CALLER_APP_ROLE__ __REQUIRED_BACKEND_AUDIENCE__
# __REQUIRED_BACKEND_AUTHORIZATION_SCOPE__ __REQUIRED_BACKEND_ROLE_DEFINITION_ID__

foreach ($commandName in @("git", "az")) {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "$commandName is required."
    }
}

$artifactRoot = Join-Path $PSScriptRoot "../artifacts"
$release = Get-Content (Join-Path $artifactRoot "citadel-release.json") -Raw | ConvertFrom-Json
$actualCommit = (& git -C $CitadelPath rev-parse HEAD).Trim()
if ($actualCommit -ne $release.commit) {
    throw "Citadel checkout must resolve to $($release.commit)."
}

$artifactText = Get-ChildItem $artifactRoot -Recurse -File | ForEach-Object { Get-Content $_.FullName -Raw }
if (($artifactText -join "`n") -match "__REQUIRED_[A-Z0-9_]+__") {
    throw "Resolve every __REQUIRED_*__ contract value before preview."
}

foreach ($property in @("backendTemplate", "accessTemplate", "publishTemplate")) {
    $relativePath = $release.$property
    if (-not (Test-Path (Join-Path $CitadelPath $relativePath))) {
        throw "Pinned Citadel template is missing: $relativePath"
    }
}

& az group show --name $ResourceGroup --only-show-errors | Out-Null
Write-Host "PASS: Citadel contract overlays, pinned templates, tools, and target resource group are ready."
