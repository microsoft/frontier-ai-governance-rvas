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
    [string]$NetworkOperatorObjectId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DnsOperatorObjectId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]]$DnsScopeResourceId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$templatePath = Join-Path $artifactRoot "infra\network\main.bicep"
$parameterPath = Join-Path $artifactRoot "environments\sandbox.bicepparam"
$requiredFiles = @(
    "infra\network\main.bicep"
    "environments\sandbox.bicepparam"
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
    "__REQUIRED_COSMOS_RESOURCE_ID__"
    "__REQUIRED_EXPIRY_DATE__"
    "__REQUIRED_FOUNDRY_RESOURCE_ID__"
    "__REQUIRED_KEY_VAULT_RESOURCE_ID__"
    "__REQUIRED_LOCATION__"
    "__REQUIRED_SEARCH_RESOURCE_ID__"
    "__REQUIRED_SESSION01_PRIVATE_ENDPOINT_SUBNET_RESOURCE_ID__"
    "__REQUIRED_SESSION01_VNET_RESOURCE_ID__"
    "__REQUIRED_STORAGE_RESOURCE_ID__"
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

function Assert-WhatIfChanges {
    param(
        [Parameter(Mandatory)][object]$WhatIf,
        [Parameter(Mandatory)][string]$ResourceGroupId
    )

    $scope = $ResourceGroupId.TrimEnd("/")
    $zones = @(
        "privatelink.cognitiveservices.azure.com"
        "privatelink.openai.azure.com"
        "privatelink.services.ai.azure.com"
        "privatelink.blob.core.windows.net"
        "privatelink.search.windows.net"
        "privatelink.documents.azure.com"
        "privatelink.vaultcore.azure.net"
    )
    $endpoints = @(
        "pe-foundry"
        "pe-storage-blob"
        "pe-ai-search"
        "pe-cosmos-sql"
        "pe-key-vault"
    )
    $allowedResourceIds = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::OrdinalIgnoreCase
    )
    foreach ($zone in $zones) {
        $zoneId = "$scope/providers/Microsoft.Network/privateDnsZones/$zone"
        [void]$allowedResourceIds.Add($zoneId)
        [void]$allowedResourceIds.Add("$zoneId/virtualNetworkLinks/link-session01-vnet")
    }
    foreach ($endpoint in $endpoints) {
        $endpointId = "$scope/providers/Microsoft.Network/privateEndpoints/$endpoint"
        [void]$allowedResourceIds.Add($endpointId)
        [void]$allowedResourceIds.Add("$endpointId/privateDnsZoneGroups/default")
    }

    foreach ($change in @($WhatIf.changes)) {
        $resourceId = ([string]$change.resourceId).TrimEnd("/")
        if ([string]::IsNullOrWhiteSpace($resourceId) -or -not $allowedResourceIds.Contains($resourceId)) {
            throw "What-if includes an unrelated resource: $($resourceId ?? '<missing resource ID>')"
        }
        if ([string]$change.changeType -notin @("Create", "Modify", "NoChange")) {
            throw "What-if change $($change.changeType) is not allowed for $resourceId."
        }
    }
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required and was not found on PATH."
}
foreach ($relativePath in $requiredFiles) {
    if (-not (Test-Path (Join-Path $artifactRoot $relativePath) -PathType Leaf)) {
        throw "Required implementation file is missing: $relativePath"
    }
}

$matches = @(Get-ChildItem $artifactRoot -Recurse -File |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($matches.Count -gt 0) {
    $unresolved = @($matches.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    $message = "Resolve all Session 02 decisions before deployment: $($unresolved -join ', ')."
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

$networkContributorId = "4d97b98b-1d4f-4787-a291-c67834d212e7"
$privateDnsZoneContributorId = "b12aa53e-6015-4669-85d0-8515ebb3ae7f"

function Assert-ExactRoleAssignment {
    param(
        [Parameter(Mandatory)][string]$PrincipalObjectId,
        [Parameter(Mandatory)][string]$RoleDefinitionId,
        [Parameter(Mandatory)][string]$Scope,
        [Parameter(Mandatory)][string]$RoleName
    )

    $assignments = @(
        Invoke-AzJson `
            -Arguments @(
                "role", "assignment", "list",
                "--assignee-object-id", $PrincipalObjectId,
                "--fill-principal-name", "false",
                "--scope", $Scope
            ) `
            -Description "$RoleName assignment lookup"
    )
    $match = @(
        $assignments | Where-Object {
            ([string]$_.roleDefinitionId).EndsWith(
                "/$RoleDefinitionId",
                [System.StringComparison]::OrdinalIgnoreCase
            ) -and
            ([string]$_.scope).Equals($Scope, [System.StringComparison]::OrdinalIgnoreCase)
        }
    )
    if ($match.Count -lt 1) {
        throw "Principal '$PrincipalObjectId' lacks $RoleName on exact scope '$Scope'."
    }
}

Assert-ExactRoleAssignment `
    -PrincipalObjectId $NetworkOperatorObjectId `
    -RoleDefinitionId $networkContributorId `
    -Scope ([string]$resourceGroup.id) `
    -RoleName "Network Contributor"

foreach ($dnsScope in $DnsScopeResourceId) {
    if ($dnsScope -notmatch "^/subscriptions/[^/]+/resourceGroups/[^/]+(?:/providers/Microsoft\.Network/privateDnsZones/[^/]+)?$") {
        throw "DnsScopeResourceId must be a resource-group ID or a private DNS zone ID."
    }
    Assert-ExactRoleAssignment `
        -PrincipalObjectId $DnsOperatorObjectId `
        -RoleDefinitionId $privateDnsZoneContributorId `
        -Scope $dnsScope.TrimEnd("/") `
        -RoleName "Private DNS Zone Contributor"
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
$networkResourceIds = [ordered]@{
    virtualNetworkResourceId = "Microsoft.Network/virtualNetworks"
    privateEndpointSubnetResourceId = "Microsoft.Network/virtualNetworks/subnets"
}
foreach ($parameterName in $networkResourceIds.Keys) {
    $matches = [regex]::Matches(
        $parameterText,
        "(?m)^\s*param\s+$([regex]::Escape($parameterName))\s*=\s*'([^']+)'\s*$"
    )
    if ($matches.Count -ne 1) {
        throw "Parameter '$parameterName' must contain exactly one quoted Session 01 resource ID."
    }
    $resourceId = $matches[0].Groups[1].Value.Trim().TrimEnd("/")
    $resource = Invoke-AzJson `
        -Arguments @("resource", "show", "--ids", $resourceId, "--query", "{id:id,type:type,tags:tags}") `
        -Description "Session 01 network resource lookup for '$parameterName'"
    if (
        [string]$resource.id -ine $resourceId -or
        [string]$resource.type -ine $networkResourceIds[$parameterName] -or
        ($parameterName -eq "virtualNetworkResourceId" -and
            [string]$resource.tags.implementationSession -ne "01-platform-baseline")
    ) {
        throw "Parameter '$parameterName' must identify the Session 01-owned $($networkResourceIds[$parameterName])."
    }
}
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
    --result-format FullResourcePayloads `
    --no-pretty-print `
    --output json `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Bicep what-if failed.`n$($whatIfOutput | Out-String)"
}
$whatIf = ($whatIfOutput | Out-String) | ConvertFrom-Json -ErrorAction Stop
Assert-WhatIfChanges -WhatIf $whatIf -ResourceGroupId ([string]$resourceGroup.id)

$whatIf | ConvertTo-Json -Depth 20
Write-Host "PASS: Session 02 files, decisions, Azure scope, operator roles, service resources, providers, Bicep syntax, and what-if are ready."
