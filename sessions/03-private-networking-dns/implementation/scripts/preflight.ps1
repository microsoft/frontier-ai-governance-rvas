[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$templatePath = Join-Path $artifactRoot "infra\network\main.bicep"
$parameterPath = Join-Path $artifactRoot "environments\sandbox.bicepparam"
$requiredFiles = @(
    "infra\network\main.bicep"
    "environments\sandbox.bicepparam"
    "network\endpoint-matrix.json"
    "decisions\network-design-record.md"
)
$requiredProviders = @(
    "Microsoft.App"
    "Microsoft.CognitiveServices"
    "Microsoft.DocumentDB"
    "Microsoft.KeyVault"
    "Microsoft.Network"
    "Microsoft.Search"
    "Microsoft.Storage"
)
$requiredSentinels = @(
    "__REQUIRED_ADDRESS_DECISION__"
    "__REQUIRED_AGENT_SUBNET_CIDR__"
    "__REQUIRED_AI_SEARCH_FQDN__"
    "__REQUIRED_COSMOS_FQDN__"
    "__REQUIRED_COSMOS_RESOURCE_ID__"
    "__REQUIRED_CUTOVER_DECISION__"
    "__REQUIRED_DNS_DECISION__"
    "__REQUIRED_EXPIRY_DATE__"
    "__REQUIRED_FIREWALL_DECISION__"
    "__REQUIRED_FIREWALL_SOURCE_REFERENCE__"
    "__REQUIRED_FIREWALL_PRIVATE_IP__"
    "__REQUIRED_FORWARDING_DECISION__"
    "__REQUIRED_FOUNDRY_FQDN__"
    "__REQUIRED_FOUNDRY_INJECTION_DECISION__"
    "__REQUIRED_FOUNDRY_RESOURCE_ID__"
    "__REQUIRED_KEY_VAULT_FQDN__"
    "__REQUIRED_KEY_VAULT_RESOURCE_ID__"
    "__REQUIRED_LOCATION__"
    "__REQUIRED_PRIVATE_ENDPOINT_SUBNET_CIDR__"
    "__REQUIRED_SCOPE_DECISION__"
    "__REQUIRED_SEARCH_RESOURCE_ID__"
    "__REQUIRED_STORAGE_BLOB_FQDN__"
    "__REQUIRED_STORAGE_RESOURCE_ID__"
    "__REQUIRED_TOPOLOGY_DECISION__"
    "__REQUIRED_VNET_CIDR__"
    "__REQUIRED_VNET_NAME__"
)

function Invoke-AzJson {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $raw = & az @Arguments --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return (($raw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required and was not found on PATH."
}
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path (Join-Path $artifactRoot $relativePath) -PathType Leaf)) {
        throw "Required implementation file is missing: $relativePath"
    }
}

$endpointMatrix = Get-Content -LiteralPath (Join-Path $artifactRoot "network\endpoint-matrix.json") -Raw |
    ConvertFrom-Json -ErrorAction Stop
if ($endpointMatrix.implementationSession -ne "03-private-networking-dns") {
    throw "The endpoint matrix has the wrong implementation marker."
}
$expectedEndpointAliases = @("foundry", "storage-blob", "ai-search", "cosmos-sql", "key-vault")
$actualEndpointAliases = @(
    $endpointMatrix.endpoints |
        ForEach-Object { ([string]$_.alias).Trim().ToLowerInvariant() }
)
if (
    $actualEndpointAliases.Count -ne $expectedEndpointAliases.Count -or
    @($actualEndpointAliases | Sort-Object -Unique).Count -ne $expectedEndpointAliases.Count -or
    @($expectedEndpointAliases | Where-Object { $_ -notin $actualEndpointAliases }).Count -gt 0
) {
    throw "The endpoint matrix must contain the five unique approved service aliases."
}
$matches = @(Get-ChildItem $artifactRoot -Recurse -File |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($matches.Count -gt 0) {
    $unresolved = @($matches.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    $message = "Resolve all Session 03 decisions before deployment: $($unresolved -join ', ')."
    if ($unknown.Count -gt 0) {
        $message += " Add explicit checks for new sentinels: $($unknown -join ', ')."
    }
    throw $message
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}

$resourceGroup = Invoke-AzJson `
    -Arguments @("group", "show", "--name", $ResourceGroupName) `
    -Description "Implementation resource-group lookup"
if (-not $resourceGroup.location) {
    throw "The approved implementation resource group has no location."
}

$expectedServiceResources = [ordered]@{
    foundryResourceId = @{
        alias = "foundry"
        type = "Microsoft.CognitiveServices/accounts"
    }
    storageResourceId = @{
        alias = "storage-blob"
        type = "Microsoft.Storage/storageAccounts"
    }
    searchResourceId = @{
        alias = "ai-search"
        type = "Microsoft.Search/searchServices"
    }
    cosmosResourceId = @{
        alias = "cosmos-sql"
        type = "Microsoft.DocumentDB/databaseAccounts"
    }
    keyVaultResourceId = @{
        alias = "key-vault"
        type = "Microsoft.KeyVault/vaults"
    }
}
$parameterText = Get-Content -LiteralPath $parameterPath -Raw
$inputResourceIds = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
$liveResourceIds = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

Write-Host "Service resource resolution:"
foreach ($parameterName in $expectedServiceResources.Keys) {
    $expectation = $expectedServiceResources[$parameterName]
    $pattern = "(?m)^\s*param\s+$([regex]::Escape($parameterName))\s*=\s*'([^']+)'\s*$"
    $parameterMatches = [regex]::Matches($parameterText, $pattern)
    if ($parameterMatches.Count -ne 1) {
        throw "Parameter '$parameterName' must contain exactly one quoted service resource ID."
    }

    $resourceId = $parameterMatches[0].Groups[1].Value.Trim().TrimEnd("/")
    if (-not $inputResourceIds.Add($resourceId)) {
        throw "Service resource IDs must be unique; '$resourceId' is used more than once."
    }

    $idMatch = [regex]::Match(
        $resourceId,
        "^/subscriptions/(?<subscription>[^/]+)/resourceGroups/(?<resourceGroup>[^/]+)/providers/(?<type>[^/]+/[^/]+)/(?<name>[^/]+)$",
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    if (-not $idMatch.Success) {
        throw "Parameter '$parameterName' is not a top-level Azure service resource ID."
    }
    if ($idMatch.Groups["subscription"].Value -ine $ApprovedSubscriptionId) {
        throw "Parameter '$parameterName' is outside the approved subscription."
    }
    if ($idMatch.Groups["resourceGroup"].Value -ine $ResourceGroupName) {
        throw "Parameter '$parameterName' is outside resource group '$ResourceGroupName'."
    }
    if ($idMatch.Groups["type"].Value -ine [string]$expectation.type) {
        throw "Parameter '$parameterName' must use resource type '$($expectation.type)'."
    }

    $liveResource = Invoke-AzJson `
        -Arguments @(
            "resource", "show",
            "--ids", $resourceId,
            "--query", "{id:id,type:type,resourceGroup:resourceGroup}"
        ) `
        -Description "Service resource lookup for '$($expectation.alias)'"
    $liveId = ([string]$liveResource.id).Trim().TrimEnd("/")
    if ($liveId -ine $resourceId) {
        throw "Service '$($expectation.alias)' resolved to a different Azure resource ID."
    }
    if ([string]$liveResource.resourceGroup -ine $ResourceGroupName) {
        throw "Service '$($expectation.alias)' resolved outside resource group '$ResourceGroupName'."
    }
    if ([string]$liveResource.type -ine [string]$expectation.type) {
        throw "Service '$($expectation.alias)' resolved as '$($liveResource.type)', not '$($expectation.type)'."
    }
    if (-not $liveResourceIds.Add($liveId)) {
        throw "Service '$($expectation.alias)' resolved to an Azure resource already used by another endpoint."
    }

    Write-Host "  $($expectation.alias) -> $liveId ($($expectation.type))"
}

$providers = @(
    Invoke-AzJson `
        -Arguments @("provider", "list", "--query", "[].{namespace:namespace,state:registrationState}") `
        -Description "Resource-provider lookup"
)
foreach ($providerName in $requiredProviders) {
    $provider = @($providers | Where-Object { $_.namespace -eq $providerName })
    if ($provider.Count -ne 1 -or $provider[0].state -ne "Registered") {
        throw "Required resource provider is not registered: $providerName"
    }
}

& az bicep build --file $templatePath --stdout --only-show-errors | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Bicep build failed: $templatePath"
}

$whatIfOutput = & az deployment group what-if `
    --resource-group $ResourceGroupName `
    --name "rvas-s03-preflight" `
    --template-file $templatePath `
    --parameters $parameterPath `
    --no-pretty-print `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Bicep what-if failed.`n$($whatIfOutput | Out-String)"
}

Write-Host "PASS: Session 03 files, decisions, Azure scope, service resources, providers, Bicep syntax, and what-if are ready."
