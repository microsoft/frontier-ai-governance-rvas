[CmdletBinding()]
param(
    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ParameterPath = (Join-Path $PSScriptRoot "..\artifacts\environments\sandbox.bicepparam"),

    [Parameter()]
    [ValidateRange(2, 30)]
    [int]$TimeoutSeconds = 8
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-ParameterValue {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Name
    )

    $matches = [regex]::Matches(
        $Text,
        "(?m)^\s*param\s+$([regex]::Escape($Name))\s*=\s*'([^']+)'\s*$"
    )
    if ($matches.Count -ne 1) {
        throw "Parameter '$Name' must contain exactly one quoted resource ID."
    }
    return $matches[0].Groups[1].Value.Trim()
}

function Test-PrivateIPv4 {
    param([Parameter(Mandatory)][string]$Address)

    $bytes = [System.Net.IPAddress]::Parse($Address).GetAddressBytes()
    return (
        $bytes.Length -eq 4 -and (
            $bytes[0] -eq 10 -or
            ($bytes[0] -eq 172 -and $bytes[1] -ge 16 -and $bytes[1] -le 31) -or
            ($bytes[0] -eq 192 -and $bytes[1] -eq 168)
        )
    )
}

function Test-Tcp443 {
    param(
        [Parameter(Mandatory)][string]$HostName,
        [Parameter(Mandatory)][int]$Timeout
    )

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $connection = $client.BeginConnect($HostName, 443, $null, $null)
        if (-not $connection.AsyncWaitHandle.WaitOne([timespan]::FromSeconds($Timeout))) {
            return $false
        }
        $client.EndConnect($connection)
        return $true
    }
    catch {
        return $false
    }
    finally {
        $client.Dispose()
    }
}

$parameterText = Get-Content -LiteralPath $ParameterPath -Raw
$serviceNames = @{
    Foundry = Get-ParameterValue -Text $parameterText -Name "foundryResourceId"
    Storage = Get-ParameterValue -Text $parameterText -Name "storageResourceId"
    Search = Get-ParameterValue -Text $parameterText -Name "searchResourceId"
    Cosmos = Get-ParameterValue -Text $parameterText -Name "cosmosResourceId"
    KeyVault = Get-ParameterValue -Text $parameterText -Name "keyVaultResourceId"
}

foreach ($key in @($serviceNames.Keys)) {
    $segments = $serviceNames[$key].TrimEnd("/").Split("/")
    if ($segments.Count -lt 2 -or [string]::IsNullOrWhiteSpace($segments[-1])) {
        throw "The $key resource ID is invalid."
    }
    $serviceNames[$key] = $segments[-1]
}

$endpoints = @(
    [pscustomobject]@{ Alias = "foundry-cognitive"; Fqdn = "$($serviceNames.Foundry).cognitiveservices.azure.com" }
    [pscustomobject]@{ Alias = "foundry-openai"; Fqdn = "$($serviceNames.Foundry).openai.azure.com" }
    [pscustomobject]@{ Alias = "foundry-services"; Fqdn = "$($serviceNames.Foundry).services.ai.azure.com" }
    [pscustomobject]@{ Alias = "storage-blob"; Fqdn = "$($serviceNames.Storage).blob.core.windows.net" }
    [pscustomobject]@{ Alias = "ai-search"; Fqdn = "$($serviceNames.Search).search.windows.net" }
    [pscustomobject]@{ Alias = "cosmos-sql"; Fqdn = "$($serviceNames.Cosmos).documents.azure.com" }
    [pscustomobject]@{ Alias = "key-vault"; Fqdn = "$($serviceNames.KeyVault).vault.azure.net" }
)

foreach ($endpoint in $endpoints) {
    $records = @(
        Resolve-DnsName -Name $endpoint.Fqdn -Type A -DnsOnly -ErrorAction Stop |
            Where-Object { $_.IPAddress } |
            Select-Object -ExpandProperty IPAddress -Unique
    )
    if ($records.Count -eq 0 -or @($records | Where-Object { -not (Test-PrivateIPv4 $_) }).Count -gt 0) {
        throw "Endpoint '$($endpoint.Alias)' did not resolve only to RFC 1918 IPv4 addresses."
    }
    if (-not (Test-Tcp443 -HostName $endpoint.Fqdn -Timeout $TimeoutSeconds)) {
        throw "Endpoint '$($endpoint.Alias)' did not accept TCP 443."
    }
    Write-Host "PASS: $($endpoint.Alias) uses private DNS and accepts TCP 443."
}

Write-Host "PASS: Current endpoint connectivity is available from this host."
