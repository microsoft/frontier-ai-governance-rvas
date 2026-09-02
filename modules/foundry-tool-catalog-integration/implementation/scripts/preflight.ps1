[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectEndpoint,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedTargetScope
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$bindingPath = Join-Path $artifactRoot "governance\catalog-toolbox-binding.json"
$toolboxPath = Join-Path $artifactRoot "toolbox\toolbox-version.json"
$checkPath = Join-Path $artifactRoot "operations\check_toolbox.py"
$requiredFiles = @($bindingPath, $toolboxPath, $checkPath)
$requiredSentinels = @(
    "__REQUIRED_AGENT_RELEASE_OWNER_ROLE__",
    "__REQUIRED_ALLOWED_TOOL_NAME__",
    "__REQUIRED_API_CATALOG_OWNER_ROLE__",
    "__REQUIRED_API_CENTER_NAME__",
    "__REQUIRED_API_CENTER_WORKSPACE_NAME__",
    "__REQUIRED_APPROVAL_REFERENCE__",
    "__REQUIRED_APPROVED_TARGET_SCOPE__",
    "__REQUIRED_CATALOG_DISCOVERY_CONFIRMATION__",
    "__REQUIRED_CONNECTION_AUTHENTICATION_MODE__",
    "__REQUIRED_FOUNDRY_PROJECT_NAME__",
    "__REQUIRED_FOUNDRY_TOOL_OWNER_ROLE__",
    "__REQUIRED_MCP_ASSET_NAME__",
    "__REQUIRED_MCP_ASSET_VERSION__",
    "__REQUIRED_MCP_DEPLOYMENT_NAME__",
    "__REQUIRED_MCP_ENDPOINT_SHA256__",
    "__REQUIRED_MCP_SERVER_URL__",
    "__REQUIRED_NAMESPACED_TOOL_NAME__",
    "__REQUIRED_PREVIEW_DECISION__",
    "__REQUIRED_PREVIEW_DECISION_OWNER_ROLE__",
    "__REQUIRED_PROJECT_CONNECTION_NAME__",
    "__REQUIRED_RESTORE_OWNER_ROLE__",
    "__REQUIRED_SERVER_LABEL__",
    "__REQUIRED_SOURCE_AUTHENTICATION_MODE__",
    "__REQUIRED_TOOLBOX_NAME__"
)

foreach ($command in @("az", "azd")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required."
    }
}

$pythonCommand = @("python", "python3", "py") |
    Where-Object { Get-Command $_ -ErrorAction SilentlyContinue } |
    Select-Object -First 1
if (-not $pythonCommand) {
    throw "Python 3 is required. The confirmation step runs check_toolbox.py with 'python', 'python3', or the Windows 'py' launcher, and none resolves on this host."
}

foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required module file is missing: $path"
    }
}

$sentinelMatches = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches)
if ($sentinelMatches.Count -gt 0) {
    $unresolved = @($sentinelMatches |
        ForEach-Object { $_.Matches } |
        ForEach-Object { $_.Value } |
        Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit preflight checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every catalog and Toolbox decision before change: $($unresolved -join ', ')"
}

$binding = Get-Content -LiteralPath $bindingPath -Raw | ConvertFrom-Json -ErrorAction Stop
$toolbox = Get-Content -LiteralPath $toolboxPath -Raw | ConvertFrom-Json -ErrorAction Stop

if ([string]$binding.implementationSession -ne "optional-module-foundry-tool-catalog-integration") {
    throw "The binding record has the wrong implementationSession marker."
}
if ([string]$binding.targetScope -ne $ApprovedTargetScope) {
    throw "The target scope does not match the approved target scope in the binding record."
}
if ([string]$binding.previewDecision.privateToolCatalog -ne "accepted-for-approved-nonproduction-scope") {
    throw "The public-preview private tool catalog must be explicitly accepted for the approved nonproduction scope."
}
if ([string]$binding.previewDecision.catalogDiscovery -ne "confirmed-in-foundry-tools") {
    throw "Confirm the API Center record is visible under Build > Tools in the intended Foundry project."
}
if ([string]$binding.foundryBinding.initialToolboxState -ne "absent") {
    throw "This module creates one dedicated Toolbox and requires its initial state to be absent."
}
if ([string]$binding.foundryBinding.requireApproval -ne "always") {
    throw "The binding record must require approval for every tool call."
}
if ([string]$binding.sourceRecord.lifecycleState -ne "approved") {
    throw "The API Center source record lifecycleState must be approved."
}
if ([string]$binding.sourceRecord.authenticationMode -ne [string]$binding.foundryBinding.connectionAuthenticationMode) {
    throw "The API Center and Foundry project connection authentication modes do not match."
}
if (-not $ProjectEndpoint.StartsWith("https://") -or
    $ProjectEndpoint -notmatch "/api/projects/[^/]+/?$") {
    throw "ProjectEndpoint must be the exact HTTPS Microsoft Foundry project endpoint."
}

$tools = @($toolbox.tools)
if ($tools.Count -ne 1) {
    throw "toolbox-version.json must define exactly one tool."
}
$tool = $tools[0]
if ([string]$tool.type -ne "mcp") {
    throw "The Toolbox definition must contain one MCP tool."
}
if (@($tool.allowed_tools).Count -ne 1) {
    throw "The MCP binding must allow exactly one tool."
}
if ([string]$tool.require_approval -ne "always") {
    throw "The MCP tool must require approval for every call."
}
if ([string]$tool.server_label -ne [string]$binding.foundryBinding.serverLabel) {
    throw "The Toolbox server_label does not match the binding record."
}
if ([string]$tool.allowed_tools[0] -ne [string]$binding.foundryBinding.allowedToolName) {
    throw "The Toolbox allowed_tools entry does not match the binding record."
}
if ([string]$tool.project_connection_id -ne [string]$binding.foundryBinding.projectConnectionName) {
    throw "The Toolbox project_connection_id does not match the binding record."
}
$expectedNamespacedTool = "$($tool.server_label).$($tool.allowed_tools[0])"
if ($expectedNamespacedTool -ne [string]$binding.foundryBinding.expectedNamespacedTool) {
    throw "The expected namespaced tool must be '<server_label>.<allowed_tool_name>'."
}

$sha256 = [Security.Cryptography.SHA256]::Create()
try {
    $endpointHash = [Convert]::ToHexString(
        $sha256.ComputeHash(
            [Text.Encoding]::UTF8.GetBytes(([string]$tool.server_url).TrimEnd("/"))
        )
    ).ToLowerInvariant()
}
finally {
    $sha256.Dispose()
}
if ($endpointHash -ne ([string]$binding.sourceRecord.mcpEndpointSha256).ToLowerInvariant()) {
    throw "The Toolbox MCP endpoint does not match the approved API Center deployment endpoint hash."
}

$description = [string]$toolbox.description
if ($description -notmatch "implementationSession=optional-module-foundry-tool-catalog-integration") {
    throw "The Toolbox description must retain the implementationSession marker."
}

az account show --output none
azd ai toolbox --help | Out-Null
azd ai project set $ProjectEndpoint | Out-Null

$connectionName = [string]$binding.foundryBinding.projectConnectionName
azd ai connection show $connectionName --output json | Out-Null

$toolboxName = [string]$binding.foundryBinding.toolboxName
$toolboxLookup = & azd ai toolbox show $toolboxName --output json 2>&1
$toolboxLookupExitCode = $LASTEXITCODE
$toolboxLookupText = ($toolboxLookup -join [Environment]::NewLine)
if ($toolboxLookupExitCode -eq 0) {
    throw "The dedicated Toolbox '$toolboxName' already exists. Stop rather than adding a version to an unreviewed Toolbox."
}
if ($toolboxLookupText -notmatch '(?i)(not found|could not be found|404)') {
    throw "Could not confirm that Toolbox '$toolboxName' is unused: $toolboxLookupText"
}

Write-Host "No read-only deployment preview is supported for Toolbox version creation."
Write-Host "Run the confirmation check with '$pythonCommand'."
Write-Host "PASS: the exact target scope, preview decision, API Center reconciliation, project connection, one-tool payload, and no-collision gate are ready."
