[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetScope
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$checkScriptPath = Join-Path $PSScriptRoot "check-discovery.ps1"
$clientPath = Join-Path $artifactRoot "registry-client-settings.json"
$ownershipPath = Join-Path $artifactRoot "registry-ownership.json"
$requiredFiles = @($clientPath, $ownershipPath)
$requiredSentinels = @(
    "__REQUIRED_APPROVED_API_CENTER_SCOPE__",
    "__REQUIRED_API_CENTER_CONFIGURATION_OWNER_ROLE__",
    "__REQUIRED_API_CENTER_NAME__",
    "__REQUIRED_API_CENTER_REGION__",
    "__REQUIRED_API_CENTER_RESOURCE_SCOPE_ALIAS__",
    "__REQUIRED_APPROVED_MCP_SERVER_NAME__",
    "__REQUIRED_CLIENT_CONFIGURATION_OWNER_ROLE__",
    "__REQUIRED_DEVELOPER_GROUP_ALIAS__",
    "__REQUIRED_DISCOVERY_REVIEW_DATE__",
    "__REQUIRED_MCP_TRANSPORT__",
    "__REQUIRED_PORTAL_APP_CLIENT_ID_REFERENCE__",
    "__REQUIRED_PREVIOUS_VISIBILITY_CONFIG_REFERENCE__",
    "__REQUIRED_RUNTIME_OWNER_ROLE__",
    "__REQUIRED_SECURITY_OWNER_ROLE__",
    "__REQUIRED_SERVER_OWNER_ROLE__",
    "__REQUIRED_TENANT_ID_REFERENCE__"
)

if (-not (Get-Command -Name $checkScriptPath -CommandType ExternalScript -ErrorAction SilentlyContinue)) {
    throw "The live discovery check cannot run because check-discovery.ps1 is missing or unreadable: $checkScriptPath"
}

foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required module artifact is missing: $path"
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
        throw "Add explicit preflight coverage for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every API Center registry discovery decision before the portal change: $($unresolved -join ', ')"
}

$client = Get-Content -LiteralPath $clientPath -Raw | ConvertFrom-Json -ErrorAction Stop
$ownership = Get-Content -LiteralPath $ownershipPath -Raw | ConvertFrom-Json -ErrorAction Stop

foreach ($record in @($client, $ownership)) {
    if ([string]$record.implementationModule -ne "api-center-registry-discovery" -or
        [string]$record.implementationSession -ne "api-center-registry-discovery") {
        throw "An artifact has the wrong implementationModule or implementationSession marker."
    }
}

if ([string]$client.targetScope -ne $TargetScope -or [string]$ownership.approvedScope -ne $TargetScope) {
    throw "TargetScope must match both artifact scope values."
}

$endpoint = [uri][string]$client.registry.endpoint
if ($endpoint.Scheme -ne "https" -or
    $endpoint.AbsolutePath -ne "/workspaces/default/v0.1/servers") {
    throw "The registry endpoint must use HTTPS and the documented /workspaces/default/v0.1/servers path."
}
if ([string]$client.registry.workspace -ne "default" -or [string]$client.registry.apiVersion -ne "v0.1") {
    throw "The documented API Center registry path uses the default workspace and v0.1."
}
if ([string]$client.registry.authentication.mode -ne "MicrosoftEntraID" -or
    [string]$ownership.developerAccess.authenticationMode -ne "MicrosoftEntraID" -or
    [bool]$ownership.developerAccess.anonymousAccess) {
    throw "This module requires Microsoft Entra ID and rejects anonymous access."
}
if ([string]$client.registry.authentication.requiredAzureRole -ne "Azure API Center Data Reader" -or
    [string]$ownership.developerAccess.azureRole -ne "Azure API Center Data Reader") {
    throw "Developer discovery requires the Azure API Center Data Reader role in this module."
}
if ([string]$client.registry.authentication.delegatedScope -ne "https://azure-apicenter.net/Data.Read.All") {
    throw "The client contract must use the documented Azure API Center data-plane delegated scope."
}

$conditions = @($ownership.visibility.builtInConditions)
$hasApiType = $conditions | Where-Object {
    [string]$_.property -eq "API type" -and [string]$_.operator -eq "equals" -and [string]$_.value -eq "MCP"
}
$hasLifecycle = $conditions | Where-Object {
    [string]$_.property -eq "Lifecycle stage" -and [string]$_.operator -eq "equals" -and [string]$_.value -eq "Production"
}
if ($conditions.Count -ne 2 -or -not $hasApiType -or -not $hasLifecycle) {
    throw "Visibility must contain exactly API type = MCP and Lifecycle stage = Production."
}
if ([bool]$ownership.visibility.customMetadataIsAuthorization -or [bool]$ownership.visibility.perUserVisibility) {
    throw "Custom metadata and per-user visibility are outside the documented discovery boundary."
}

$clientNames = @($client.approvedServerNames | ForEach-Object { [string]$_ } | Sort-Object -Unique)
$ownerNames = @($ownership.approvedServers | ForEach-Object { [string]$_.name } | Sort-Object -Unique)
if ($clientNames.Count -eq 0 -or ($clientNames -join "`n") -ne ($ownerNames -join "`n")) {
    throw "The client contract and ownership record must contain the same approved server names."
}

Write-Host "PASS: Registry discovery artifacts are complete for approved scope '$TargetScope'."
Write-Host "Portal preview required: confirm the Data API visibility preview contains only MCP records at Production lifecycle stage."
