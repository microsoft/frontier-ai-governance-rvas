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
    [string]$ReadApiBaseUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$agentRoot = Join-Path $artifactRoot "agents\policy-assistant"
$configPath = Join-Path $agentRoot "agent.json"
$instructionsPath = Join-Path $agentRoot "instructions.md"
$toolPath = Join-Path $agentRoot "tool-manifest.json"
$policyPath = Join-Path $agentRoot "prohibited-actions.json"
$releaseOperationsPath = Join-Path $artifactRoot "operations\release-operations.json"

function Get-AiToken {
    $token = & az account get-access-token `
        --scope "https://ai.azure.com/.default" `
        --query accessToken `
        --output tsv `
        --only-show-errors
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
        throw "Unable to acquire a Microsoft Foundry data-plane token."
    }
    return [string]$token
}

function Invoke-AiRequest {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("GET", "POST", "PATCH", "DELETE")]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter()]
        [object]$Body,

        [Parameter()]
        [switch]$AllowNotFound
    )

    $headers = @{ Authorization = "Bearer $(Get-AiToken)" }
    try {
        if ($null -eq $Body) {
            return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
        }
        $json = $Body | ConvertTo-Json -Depth 100
        $contentType = if ($Method -eq "PATCH") {
            "application/merge-patch+json"
        }
        else {
            "application/json"
        }
        return Invoke-RestMethod `
            -Method $Method `
            -Uri $Uri `
            -Headers $headers `
            -ContentType $contentType `
            -Body $json
    }
    catch {
            $statusCode = [int]$_.Exception.Response.StatusCode
        if ($AllowNotFound -and $statusCode -eq 404) {
            return $null
        }
        throw
    }
}

$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinels.Count -gt 0) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    throw "Resolve every Session 05 customer decision before deployment: $($unresolved -join ', ')."
}

$apiUri = [uri]$ReadApiBaseUrl
if ($apiUri.Scheme -ne "https" -or -not [string]::IsNullOrWhiteSpace($apiUri.Query) -or -not [string]::IsNullOrWhiteSpace($apiUri.Fragment)) {
    throw "ReadApiBaseUrl must be an HTTPS base URL without a query string or fragment."
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

$config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
$toolManifest = Get-Content -LiteralPath $toolPath -Raw | ConvertFrom-Json
$prohibited = Get-Content -LiteralPath $policyPath -Raw | ConvertFrom-Json
$instructions = Get-Content -LiteralPath $instructionsPath -Raw

$prohibitedAction = [string]$prohibited.actions[0].action
$humanRoute = [string]$prohibited.humanChangeRoute
$runtimeInstructions = @"
$instructions

## Customer decision for this implementation

The explicitly prohibited write action is: $prohibitedAction.
Route legitimate change requests to: $humanRoute.
"@

$tool = $toolManifest.tools[0]
$tool.openapi.spec.servers[0].url = $ReadApiBaseUrl.TrimEnd("/")
$projectEndpoint = "https://$FoundryAccountName.services.ai.azure.com/api/projects/$ProjectName"
$escapedAgentName = [uri]::EscapeDataString([string]$config.agentName)
$agentUri = "$projectEndpoint/agents/$escapedAgentName`?api-version=v1"
$existing = Invoke-AiRequest -Method GET -Uri $agentUri -AllowNotFound
if ($null -ne $existing) {
    $existingDescription = [string]$existing.agent_card.description
    if ($existingDescription -notlike "*$($config.implementationSession)*") {
        throw "An agent with this name exists without the Session 05 implementation marker."
    }
}

$createBody = @{
    name = [string]$config.agentName
    definition = @{
        kind = "prompt"
        model = [string]$config.modelDeploymentName
        instructions = $runtimeInstructions
        temperature = [double]$config.temperature
        rai_config = @{
            rai_policy_name = [string]$config.raiPolicyName
        }
        tools = @($tool)
    }
}
$created = Invoke-AiRequest `
    -Method POST `
    -Uri "$projectEndpoint/agents?api-version=v1" `
    -Body $createBody

$createdVersion = [string]$created.version
if ([string]::IsNullOrWhiteSpace($createdVersion)) {
    throw "Foundry created the agent version but did not return its version identifier."
}

$patchBody = @{
    agent_endpoint = @{
        version_selector = @{
            version_selection_rules = @(
                @{
                    type = "FixedRatio"
                    agent_version = $createdVersion
                    traffic_percentage = 100
                }
            )
        }
        protocol_configuration = @{
            responses = @{}
        }
        authorization_schemes = @(
            @{ type = "Entra" }
        )
    }
    agent_card = @{
        version = "1.0.0"
        description = "Internal policy assistant. implementationSession=$($config.implementationSession)"
        skills = @(
            @{
                id = "policy-lookup"
                name = "Policy lookup"
                description = "Reads an approved policy record by identifier without changing state."
                tags = @("policy", "read-only", "governed")
                examples = @("Summarize policy POL-001.")
            }
        )
    }
}
$patched = Invoke-AiRequest `
    -Method PATCH `
    -Uri $agentUri `
    -Body $patchBody

if ([string]::IsNullOrWhiteSpace([string]$patched.instance_identity.principal_id)) {
    throw "The created agent does not expose a unique Entra Agent Identity."
}

$releaseOperations = Get-Content -LiteralPath $releaseOperationsPath -Raw |
    ConvertFrom-Json -ErrorAction Stop
$releaseOperations.release = [ordered]@{
    agentName = [string]$config.agentName
    activeVersion = $createdVersion
    modelDeploymentName = [string]$config.modelDeploymentName
    versionSelection = "pinned"
    instructionsSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $instructionsPath).Hash.ToLowerInvariant()
    toolManifestSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $toolPath).Hash.ToLowerInvariant()
    prohibitedActionsSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $policyPath).Hash.ToLowerInvariant()
    deployedAtUtc = [DateTime]::UtcNow.ToString("o")
    status = "deployed"
}
$releaseOperations |
    ConvertTo-Json -Depth 10 |
    Set-Content -LiteralPath $releaseOperationsPath -Encoding utf8

Write-Host "PASS: Created agent version $createdVersion, pinned the stable Responses endpoint, enforced Entra authorization, and confirmed a unique agent identity."
