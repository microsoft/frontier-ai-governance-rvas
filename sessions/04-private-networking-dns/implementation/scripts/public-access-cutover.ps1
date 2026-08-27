[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$FoundryResourceId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$StorageResourceId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SearchResourceId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$CosmosResourceId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultResourceId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$EndpointMatrixPath = (Join-Path $PSScriptRoot "..\artifacts\network\endpoint-matrix.json"),

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$CutoverRecordPath,

    [Parameter()]
    [ValidateRange(2, 30)]
    [int]$TimeoutSeconds = 8
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$marker = "04-private-networking-dns"

function Invoke-AzJson {
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [Parameter(Mandatory)][string]$Description
    )

    $raw = & az @Arguments --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return (($raw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
}

function Set-PublicNetworkAccess {
    param(
        [Parameter(Mandatory)][string]$Alias,
        [Parameter(Mandatory)][object]$Resource,
        [Parameter(Mandatory)][ValidateSet("Enabled", "Disabled")][string]$State
    )

    $arguments = switch ($Alias) {
        "foundry" {
            @("resource", "update", "--ids", [string]$Resource.id, "--set", "properties.publicNetworkAccess=$State")
        }
        "storage" {
            @("storage", "account", "update", "--ids", [string]$Resource.id, "--public-network-access", $State)
        }
        "ai-search" {
            @("search", "service", "update", "--ids", [string]$Resource.id, "--public-network-access", $State.ToLowerInvariant())
        }
        "cosmos" {
            @("cosmosdb", "update", "--ids", [string]$Resource.id, "--public-network-access", $State)
        }
        "key-vault" {
            $segments = ([string]$Resource.id).Split("/")
            $resourceGroup = $segments[[array]::IndexOf($segments, "resourceGroups") + 1]
            @(
                "keyvault", "update",
                "--name", [string]$Resource.name,
                "--resource-group", $resourceGroup,
                "--subscription", $ApprovedSubscriptionId,
                "--public-network-access", $State
            )
        }
        default {
            throw "Unsupported cutover alias: $Alias"
        }
    }

    $raw = & az @arguments --only-show-errors --output none 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Public-access update failed for $Alias.`n$($raw | Out-String)"
    }
}

function Resolve-ExternalRecordPath {
    param([Parameter(Mandatory)][string]$Path)

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    $repoBoundary = $repoRoot.TrimEnd("\") + "\"
    if (
        $resolvedPath.Equals($repoRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
        $resolvedPath.StartsWith($repoBoundary, [System.StringComparison]::OrdinalIgnoreCase)
    ) {
        throw "CutoverRecordPath must resolve outside the source repository."
    }
    if (Test-Path -LiteralPath $resolvedPath) {
        throw "CutoverRecordPath already exists. Preserve it and use a new path for a new cutover."
    }
    if (Test-Path -LiteralPath "$resolvedPath.previous") {
        throw "CutoverRecordPath has an existing recovery copy. Preserve it and use a new path for a new cutover."
    }

    $parent = [System.IO.Path]::GetDirectoryName($resolvedPath)
    if ([string]::IsNullOrWhiteSpace($parent)) {
        throw "CutoverRecordPath must include an approved parent directory."
    }
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        throw "The approved CutoverRecordPath parent directory does not exist."
    }
    return $resolvedPath
}

function Write-CutoverRecord {
    param(
        [Parameter(Mandatory)][object]$Record,
        [Parameter(Mandatory)][string]$Path
    )

    $parent = [System.IO.Path]::GetDirectoryName($Path)
    $fileName = [System.IO.Path]::GetFileName($Path)
    $temporaryPath = Join-Path $parent ".$fileName.$([guid]::NewGuid().ToString('N')).tmp"
    $backupPath = "$Path.previous"
    $encoding = [System.Text.UTF8Encoding]::new($false)
    $bytes = $encoding.GetBytes(
        (($Record | ConvertTo-Json -Depth 10) + [Environment]::NewLine)
    )

    try {
        $stream = [System.IO.FileStream]::new(
            $temporaryPath,
            [System.IO.FileMode]::CreateNew,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None,
            4096,
            [System.IO.FileOptions]::WriteThrough
        )
        try {
            $stream.Write($bytes, 0, $bytes.Length)
            $stream.Flush($true)
        }
        finally {
            $stream.Dispose()
        }

        if (Test-Path -LiteralPath $Path -PathType Leaf) {
            if (Test-Path -LiteralPath $backupPath) {
                Remove-Item -LiteralPath $backupPath -Force
            }
            [System.IO.File]::Replace($temporaryPath, $Path, $backupPath, $true)
        }
        else {
            [System.IO.File]::Move($temporaryPath, $Path)
        }
    }
    finally {
        if (Test-Path -LiteralPath $temporaryPath) {
            Remove-Item -LiteralPath $temporaryPath -Force
        }
    }
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required and was not found on PATH."
}

$endpointMatrix = Get-Content -LiteralPath $EndpointMatrixPath -Raw |
    ConvertFrom-Json -ErrorAction Stop
if (
    $endpointMatrix.implementationSession -ne $marker -or
    @($endpointMatrix.endpoints).Count -ne 5
) {
    throw "EndpointMatrixPath must contain the complete Session 04 endpoint set."
}

$targets = @(
    [ordered]@{
        alias = "foundry"
        endpointAlias = "foundry"
        id = $FoundryResourceId
        type = "Microsoft.CognitiveServices/accounts"
        dnsSuffixes = @(
            ".services.ai.azure.com"
            ".cognitiveservices.azure.com"
            ".openai.azure.com"
        )
    }
    [ordered]@{
        alias = "storage"
        endpointAlias = "storage-blob"
        id = $StorageResourceId
        type = "Microsoft.Storage/storageAccounts"
        dnsSuffixes = @(".blob.core.windows.net")
    }
    [ordered]@{
        alias = "ai-search"
        endpointAlias = "ai-search"
        id = $SearchResourceId
        type = "Microsoft.Search/searchServices"
        dnsSuffixes = @(".search.windows.net")
    }
    [ordered]@{
        alias = "cosmos"
        endpointAlias = "cosmos-sql"
        id = $CosmosResourceId
        type = "Microsoft.DocumentDB/databaseAccounts"
        dnsSuffixes = @(".documents.azure.com")
    }
    [ordered]@{
        alias = "key-vault"
        endpointAlias = "key-vault"
        id = $KeyVaultResourceId
        type = "Microsoft.KeyVault/vaults"
        dnsSuffixes = @(".vault.azure.net")
    }
)

$resources = @{}
$recordResources = @()
$seenResourceIds = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
foreach ($target in $targets) {
    $resource = Invoke-AzJson `
        -Arguments @("resource", "show", "--ids", $target.id) `
        -Description "$($target.alias) lookup"
    if (-not ([string]$resource.id).Equals(
        [string]$target.id,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "$($target.alias) lookup returned a different resource ID."
    }
    if (-not $seenResourceIds.Add([string]$resource.id)) {
        throw "Each cutover alias must identify a unique resource."
    }
    $resourceIdMatch = [regex]::Match(
        [string]$resource.id,
        "^/subscriptions/([^/]+)/resourceGroups/([^/]+)/providers/(.+)/[^/]+$",
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    if (-not $resourceIdMatch.Success) {
        throw "$($target.alias) does not use a supported resource-group-scoped Azure resource ID."
    }
    if (
        $resourceIdMatch.Groups[1].Value -ine $ApprovedSubscriptionId -or
        $resourceIdMatch.Groups[2].Value -ine $ResourceGroupName
    ) {
        throw "$($target.alias) is outside the approved subscription or resource group."
    }
    if ([string]$resource.type -ine [string]$target.type) {
        throw "$($target.alias) must identify a $($target.type) resource."
    }

    $matchingEndpoints = @(
        $endpointMatrix.endpoints |
            Where-Object { [string]$_.alias -ieq [string]$target.endpointAlias }
    )
    if ($matchingEndpoints.Count -ne 1) {
        throw "Endpoint matrix must contain exactly one $($target.endpointAlias) entry."
    }
    $fqdn = ([string]$matchingEndpoints[0].fqdn).Trim().TrimEnd(".")
    $expectedFqdns = @(
        $target.dnsSuffixes |
            ForEach-Object { "$([string]$resource.name)$([string]$_)" }
    )
    if (-not @($expectedFqdns | Where-Object {
        $fqdn.Equals($_, [System.StringComparison]::OrdinalIgnoreCase)
    })) {
        throw "$($target.endpointAlias) FQDN must match the selected resource name and service DNS suffix."
    }

    $priorState = [string]$resource.properties.publicNetworkAccess
    if ([string]::IsNullOrWhiteSpace($priorState)) {
        throw "$($target.alias) does not expose properties.publicNetworkAccess through the current API."
    }
    $resources[$target.alias] = $resource
    $recordResources += [ordered]@{
        alias = $target.alias
        resourceId = [string]$resource.id
        priorState = $priorState
        requestedState = "Disabled"
        result = "NotStarted"
    }
}

$connectivityCheck = Join-Path $PSScriptRoot "connectivity-check.ps1"
& $connectivityCheck -EndpointMatrixPath $EndpointMatrixPath -TimeoutSeconds $TimeoutSeconds

$recordPath = Resolve-ExternalRecordPath -Path $CutoverRecordPath
Write-Host "Cutover scope: five approved nonproduction services."
Write-Host "  Subscription:   $ApprovedSubscriptionId"
Write-Host "  Resource group: $ResourceGroupName"
Write-Host "Restore state: $recordPath"
if (-not $PSCmdlet.ShouldProcess(
    "five approved nonproduction services",
    "Write the complete restore record, add the Session 04 marker, and disable public network access"
)) {
    Write-Host "No public-access changes were applied."
    return
}

$record = [ordered]@{
    schemaVersion = 1
    session = $marker
    capturedAtUtc = [datetimeoffset]::UtcNow.ToString("o")
    status = "Cutover ready"
    resources = $recordResources
}
Write-CutoverRecord -Record $record -Path $recordPath

for ($index = 0; $index -lt $targets.Count; $index++) {
    $target = $targets[$index]
    $record.resources[$index].result = "UpdatePending"
    $record.status = "Cutover in progress"
    Write-CutoverRecord -Record $record -Path $recordPath

    $tagOutput = & az tag update `
        --resource-id $target.id `
        --operation Merge `
        --tags "networkControlSession=$marker" `
        --only-show-errors 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Tag update failed for $($target.alias).`n$($tagOutput | Out-String)"
    }
    Set-PublicNetworkAccess -Alias $target.alias -Resource $resources[$target.alias] -State "Disabled"

    $record.resources[$index].result = "Applied"
    Write-CutoverRecord -Record $record -Path $recordPath
}

$record.status = "Cutover applied"
Write-CutoverRecord -Record $record -Path $recordPath
Write-Host "Cutover complete. Run connectivity-check.ps1 from this approved private host."
