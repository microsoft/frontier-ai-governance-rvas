[CmdletBinding()]
param(
    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$EndpointMatrixPath = (Join-Path $PSScriptRoot "..\artifacts\network\endpoint-matrix.json"),

    [Parameter()]
    [ValidateRange(2, 30)]
    [int]$TimeoutSeconds = 8
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$implementationSession = "04-private-networking-dns"

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

$matrix = Get-Content -LiteralPath $EndpointMatrixPath -Raw |
    ConvertFrom-Json -ErrorAction Stop
if ($matrix.implementationSession -ne $implementationSession) {
    throw "The endpoint matrix has the wrong implementation marker."
}
$expectedAliases = @("foundry", "storage-blob", "ai-search", "cosmos-sql", "key-vault")
$actualAliases = @(
    $matrix.endpoints |
        ForEach-Object { ([string]$_.alias).Trim().ToLowerInvariant() }
)
$fqdns = @(
    $matrix.endpoints |
        ForEach-Object { ([string]$_.fqdn).Trim().ToLowerInvariant() }
)
if (
    $actualAliases.Count -ne $expectedAliases.Count -or
    @($actualAliases | Sort-Object -Unique).Count -ne $expectedAliases.Count -or
    @($expectedAliases | Where-Object { $_ -notin $actualAliases }).Count -gt 0
) {
    throw "The endpoint matrix must contain the five unique aliases: $($expectedAliases -join ', ')."
}
if (
    @($fqdns | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0 -or
    @($fqdns | Sort-Object -Unique).Count -ne $expectedAliases.Count
) {
    throw "The endpoint matrix must contain one distinct FQDN for each approved service."
}

foreach ($endpoint in $matrix.endpoints) {
    $records = @(
        Resolve-DnsName -Name $endpoint.fqdn -Type A -DnsOnly -ErrorAction Stop |
            Where-Object { $_.IPAddress } |
            Select-Object -ExpandProperty IPAddress -Unique
    )
    if ($records.Count -eq 0 -or @($records | Where-Object { -not (Test-PrivateIPv4 $_) }).Count -gt 0) {
        throw "Endpoint '$($endpoint.alias)' did not resolve only to RFC 1918 IPv4 addresses."
    }
    if (-not (Test-Tcp443 -HostName $endpoint.fqdn -Timeout $TimeoutSeconds)) {
        throw "Endpoint '$($endpoint.alias)' did not accept TCP 443."
    }
    Write-Host "PASS: $($endpoint.alias) uses private DNS and accepts TCP 443."
}

Write-Host "PASS: Current endpoint connectivity is available from this host."
