[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$FoundryAccountName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ProjectName,

    [Parameter(Mandatory)]
    [ValidatePattern("^https://")]
    [string]$ReadApiBaseUrl,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApplicationInsightsResourceId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$agentRoot = Join-Path $artifactRoot "agents\policy-assistant"
$configPath = Join-Path $agentRoot "agent.json"
$instructionsPath = Join-Path $agentRoot "instructions.md"
$toolPath = Join-Path $agentRoot "tool-manifest.json"
$requiredFiles = @(
    $configPath
    $instructionsPath
    $toolPath
)
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required."
}
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}

$sentinels = Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__"
if ($sentinels) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    throw "Resolve every Session 03 customer decision before deployment: $($unresolved -join ', ')."
}

$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json -ErrorAction Stop
$toolManifest = Get-Content -LiteralPath $toolPath -Raw | ConvertFrom-Json -ErrorAction Stop
$instructions = Get-Content -LiteralPath $instructionsPath -Raw

if ([string]$config.implementationSession -ne "03-citadel-agent-spoke") {
    throw "agent.json has the wrong implementation marker."
}
if ([string]$config.agentType -ne "prompt" -or [string]$config.runtimePattern -ne "persistent-prompt-agent") {
    throw "Session 03 implements one persistent prompt agent."
}
if ([string]$config.endpoint.versionSelection -ne "pinned") {
    throw "The stable endpoint must pin one explicit agent version."
}
if (@($config.endpoint.protocols).Count -ne 1 -or [string]$config.endpoint.protocols[0] -ne "responses") {
    throw "The governed baseline exposes only the Responses protocol."
}
if (@($config.endpoint.authorizationSchemes).Count -ne 1 -or [string]$config.endpoint.authorizationSchemes[0] -ne "Entra") {
    throw "The governed endpoint must use Microsoft Entra authorization only."
}
if ([double]$config.temperature -lt 0 -or [double]$config.temperature -gt 2) {
    throw "Agent temperature must be between 0 and 2."
}
if ([string]::IsNullOrWhiteSpace([string]$config.raiPolicyName)) {
    throw "A named RAI policy is required."
}
if ($instructions -notmatch "Refuse requests to create, update, approve, publish, delete" -or
    $instructions -notmatch 'The prohibited write action is `' -or
    $instructions -notmatch 'Route valid change requests to `') {
    throw "The approved instructions do not contain the prohibited-write refusal boundary."
}

$tools = @($toolManifest.tools)
if ($tools.Count -ne 1 -or [string]$tools[0].type -ne "openapi") {
    throw "The baseline must expose exactly one OpenAPI tool."
}
$paths = @($tools[0].openapi.spec.paths.PSObject.Properties)
if ($paths.Count -ne 1) {
    throw "The OpenAPI manifest must contain exactly one path."
}
$operations = @($paths[0].Value.PSObject.Properties)
if ($operations.Count -ne 1 -or $operations[0].Name -ne "get") {
    throw "The OpenAPI manifest must expose exactly one GET operation and no write operation."
}
if ([string]$operations[0].Value.operationId -notmatch "^[A-Za-z_-]+$") {
    throw "The OpenAPI operationId must contain only letters, hyphens, and underscores."
}
if ([string]$tools[0].openapi.spec.servers[0].url -ne "__RUNTIME_READ_API_BASE_URL__") {
    throw "The authoritative tool manifest must not contain a live API endpoint."
}
if ([string]$tools[0].openapi.auth.type -ne "managed_identity") {
    throw "The read tool must use managed identity authentication."
}
$account = & az account show --only-show-errors --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}
$foundry = & az cognitiveservices account show `
    --name $FoundryAccountName `
    --resource-group $ResourceGroupName `
    --only-show-errors `
    --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]$foundry.kind -ne "AIServices") {
    throw "The existing Microsoft Foundry resource must have the Azure resource property kind set to AIServices."
}
$expectedFoundryId = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.CognitiveServices/accounts/$FoundryAccountName"
if ([string]$foundry.id -ne $expectedFoundryId) {
    throw "The Foundry resource is outside the approved subscription or resource group."
}
$projectResourceId = "$expectedFoundryId/projects/$ProjectName"
$project = & az resource show --ids $projectResourceId --only-show-errors --output json |
    ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace([string]$project.identity.principalId)) {
    throw "The Foundry project managed identity could not be resolved."
}
$readScope = [string]$tools[0].openapi.auth.assignmentScope
$readRoleId = [string]$tools[0].openapi.auth.requiredRoleDefinitionId
$readAssignments = @(& az role assignment list `
    --assignee-object-id ([string]$project.identity.principalId) `
    --scope $readScope `
    --include-inherited false `
    --only-show-errors `
    --output json | ConvertFrom-Json)
if ($LASTEXITCODE -ne 0 -or
    @($readAssignments | Where-Object {
        [string]$_.scope -eq $readScope -and
        [string]$_.roleDefinitionId -match "/$([regex]::Escape($readRoleId))$"
    }).Count -ne 1) {
    throw "The exact downstream managed-identity read assignment is not ready."
}

$model = & az cognitiveservices account deployment show `
    --name $FoundryAccountName `
    --resource-group $ResourceGroupName `
    --deployment-name ([string]$config.modelDeploymentName) `
    --only-show-errors `
    --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]$model.properties.provisioningState -ne "Succeeded") {
    throw "The approved Session 03 model deployment is not ready."
}

$aiResource = & az resource show `
    --ids $ApplicationInsightsResourceId `
    --only-show-errors `
    --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]$aiResource.type -ne "microsoft.insights/components") {
    throw "The supplied Application Insights resource ID does not identify a Microsoft.Insights/components resource."
}
if ([string]$aiResource.id -notlike "/subscriptions/$ApprovedSubscriptionId/*") {
    throw "Application Insights is outside the approved subscription."
}
$apiUri = [uri]$ReadApiBaseUrl
if ($apiUri.Scheme -ne "https" -or -not [string]::IsNullOrWhiteSpace($apiUri.Query) -or -not [string]::IsNullOrWhiteSpace($apiUri.Fragment)) {
    throw "ReadApiBaseUrl must be an HTTPS base URL without a query string or fragment."
}

$projectEndpoint = "https://$FoundryAccountName.services.ai.azure.com/api/projects/$ProjectName"
$token = & az account get-access-token `
    --scope "https://ai.azure.com/.default" `
    --query accessToken `
    --output tsv `
    --only-show-errors
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
    throw "Unable to acquire a Microsoft Foundry data-plane token."
}
$headers = @{ Authorization = "Bearer $token" }
try {
    $agents = Invoke-RestMethod `
        -Method GET `
        -Uri "$projectEndpoint/agents?api-version=v1" `
        -Headers $headers
}
catch {
    throw "The approved Foundry project endpoint could not be read. $($_.Exception.Message)"
}

$agentItems = if ($null -ne $agents.data) { @($agents.data) } else { @($agents.value) }
$existing = @($agentItems | Where-Object { $_.name -eq [string]$config.agentName })
if ($existing.Count -gt 1) {
    throw "The project returned more than one agent with the configured name."
}
if ($existing.Count -eq 1) {
    $description = [string]$existing[0].agent_card.description
    if ($description -notlike "*$($config.implementationSession)*") {
        throw "An existing agent uses the configured name but does not carry the Session 03 marker."
    }
    if ([string]::IsNullOrWhiteSpace([string]$existing[0].instance_identity.principal_id)) {
        throw "The existing agent is a legacy agent without a unique Entra Agent Identity. Create a new named agent instead."
    }
    $escapedAgentName = [uri]::EscapeDataString([string]$config.agentName)
    $liveAgent = Invoke-RestMethod `
        -Method GET `
        -Uri "$projectEndpoint/agents/$escapedAgentName`?api-version=v1" `
        -Headers $headers
    $liveVersion = [string]$liveAgent.agent_endpoint.version_selector.version_selection_rules[0].agent_version
    if ([string]::IsNullOrWhiteSpace($liveVersion)) {
        throw "The existing marked agent does not expose a pinned stable endpoint version."
    }
}

Write-Host "Read-only preview:"
Write-Host "  Project: $projectEndpoint"
Write-Host "  Agent: $($config.agentName)"
Write-Host "  Model deployment: $($config.modelDeploymentName)"
Write-Host "  Tool surface: GET $($paths[0].Name) only"
Write-Host "  Endpoint: Responses, Entra authorization, pinned to the new version"
Write-Host "  Existing marked agent: $($existing.Count -eq 1)"
if ($existing.Count -eq 1) {
    Write-Host "  Current/live active version: $liveVersion"
}
Write-Host "Foundry doesn't expose a what-if operation for data-plane agent version creation. This read-only lookup and exact mutation summary are the preview gate."

Write-Host "PASS: Session 03 files, decisions, live release selector, approved Azure scope, model, Application Insights resource, Foundry project access, read-only tool boundary, unique-identity path, and preview gate are ready."
