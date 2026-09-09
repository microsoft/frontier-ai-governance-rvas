[CmdletBinding()]
param(
    [string]$ClientSettingsPath = (Join-Path $PSScriptRoot "..\artifacts\registry-client-settings.json"),
    [string]$OwnershipPath = (Join-Path $PSScriptRoot "..\artifacts\registry-ownership.json"),
    [string]$AccessTokenEnvironmentVariable = "API_CENTER_ACCESS_TOKEN",
    [ValidateRange(1, 100)]
    [int]$MaxPages = 50
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$client = Get-Content -LiteralPath $ClientSettingsPath -Raw | ConvertFrom-Json -ErrorAction Stop
$ownership = Get-Content -LiteralPath $OwnershipPath -Raw | ConvertFrom-Json -ErrorAction Stop

$artifactText = (Get-Content -LiteralPath $ClientSettingsPath -Raw) +
    (Get-Content -LiteralPath $OwnershipPath -Raw)
if ($artifactText -match "__REQUIRED_[A-Z0-9_]+__") {
    throw "Run preflight and resolve every required decision before checking live discovery."
}

$endpoint = [uri][string]$client.registry.endpoint
$documentedHostPattern = '^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.data\.[a-z0-9]+\.azure-apicenter\.ms$'
if ($endpoint.Scheme -ne "https" -or
    $endpoint.Host -notmatch $documentedHostPattern -or
    -not [string]::IsNullOrEmpty($endpoint.UserInfo) -or
    -not $endpoint.IsDefaultPort -or
    $endpoint.AbsolutePath -ne "/workspaces/default/v0.1/servers" -or
    -not [string]::IsNullOrEmpty($endpoint.Query) -or
    -not [string]::IsNullOrEmpty($endpoint.Fragment)) {
    throw "The registry endpoint must use the documented Azure API Center data-plane host and /workspaces/default/v0.1/servers path."
}

$token = [Environment]::GetEnvironmentVariable($AccessTokenEnvironmentVariable)
if ([string]::IsNullOrWhiteSpace($token)) {
    throw "Set $AccessTokenEnvironmentVariable through the approved OAuth credential helper. Do not pass the token as an argument."
}

$approvedNames = @($ownership.approvedServers |
    ForEach-Object { [string]$_.name } |
    Sort-Object -Unique)
if ($approvedNames.Count -eq 0) {
    throw "The ownership record has no approved server names."
}

$headers = @{
    Authorization = "Bearer $token"
    Accept = "application/json"
}
$headers.Authorization = "Bearer $token"
$discoveredNames = [System.Collections.Generic.List[string]]::new()
$nextUri = $endpoint.AbsoluteUri
$page = 0

while ($null -ne $nextUri) {
    $page++
    if ($page -gt $MaxPages) {
        throw "Registry pagination exceeded MaxPages=$MaxPages."
    }

    $response = Invoke-RestMethod -Uri $nextUri -Headers $headers -Method Get -MaximumRedirection 0
    $serversProperty = $response.PSObject.Properties["servers"]
    if ($null -eq $serversProperty -or $null -eq $serversProperty.Value) {
        throw "The registry response does not contain the MCP Registry API v0.1 servers array."
    }

    foreach ($item in @($serversProperty.Value)) {
        $serverProperty = $item.PSObject.Properties["server"]
        $nameProperty = if ($null -ne $serverProperty) {
            $serverProperty.Value.PSObject.Properties["name"]
        }
        else {
            $null
        }
        if ($null -eq $nameProperty -or [string]::IsNullOrWhiteSpace([string]$nameProperty.Value)) {
            throw "A registry entry does not contain server.name."
        }
        $discoveredNames.Add([string]$nameProperty.Value)
    }

    $cursor = ""
    $metadataProperty = $response.PSObject.Properties["metadata"]
    if ($null -ne $metadataProperty -and $null -ne $metadataProperty.Value) {
        $cursorProperty = $metadataProperty.Value.PSObject.Properties["nextCursor"]
        if ($null -ne $cursorProperty) {
            $cursor = [string]$cursorProperty.Value
        }
    }
    if ([string]::IsNullOrWhiteSpace($cursor)) {
        $nextUri = $null
    }
    else {
        $builder = [System.UriBuilder]::new($endpoint)
        $builder.Query = "cursor=$([uri]::EscapeDataString($cursor))"
        $nextUri = $builder.Uri.AbsoluteUri
    }
}

$actualNames = @($discoveredNames | Sort-Object -Unique)
$missing = @($approvedNames | Where-Object { $_ -notin $actualNames })
$unexpected = @($actualNames | Where-Object { $_ -notin $approvedNames })

if ($missing.Count -gt 0) {
    throw "Registry discovery is missing $($missing.Count) approved server name(s)."
}
if ($unexpected.Count -gt 0) {
    throw "Registry discovery returned $($unexpected.Count) unapproved server name(s). Names are not printed."
}

Write-Host "PASS: Registry discovery returned $($actualNames.Count) approved server name(s), zero unapproved server names, across $page page(s)."
