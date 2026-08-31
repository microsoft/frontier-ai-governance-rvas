[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedTenantId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$AgentInstanceId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-GraphToken {
    param([string]$TenantId)

    $token = & az account get-access-token --tenant $TenantId --resource-type ms-graph --query accessToken --output tsv --only-show-errors
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
        $token = & az account get-access-token --tenant $TenantId --scope "https://graph.microsoft.com/.default" --query accessToken --output tsv --only-show-errors
    }
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
        throw "Unable to acquire a Microsoft Graph token for the approved tenant."
    }
    return $token.Trim()
}

foreach ($command in @("az")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required."
    }
}

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$handoffPath = Join-Path $artifactRoot "governance\coverage-handoff.md"
$queryPath = Join-Path $artifactRoot "operations\agent-activity-audit-query.json"
foreach ($path in @($handoffPath, $queryPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $path"
    }

    $unresolved = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
    if ($unresolved.Count -gt 0) {
        throw "Resolve every __REQUIRED_*__ sentinel before changing Purview state."
    }
}

$handoff = Get-Content -LiteralPath $handoffPath -Raw
if ($handoff -notmatch "\| Review cadence \| Quarterly \|") {
    throw "The coverage handoff must name its quarterly review cadence."
}

$query = Get-Content -LiteralPath $queryPath -Raw | ConvertFrom-Json -ErrorAction Stop
$expectedOperations = @("AIInvokeAgent", "AIExecuteTool", "AIInferenceCall", "AIGuardrail")
$expectedFields = @("CreationDate", "Operation", "AgentId", "AgentName", "ResultStatus")
if (
    [int]$query.schemaVersion -ne 1 -or
    [string]$query.implementationSession -ne "10-purview-data-governance" -or
    [string]$query.microsoftGraphApplicationPermission -ne "AuditLogsQuery.Read.All" -or
    [int]$query.lookbackHours -lt 1 -or [int]$query.lookbackHours -gt 168 -or
    (@($query.operations) | Sort-Object) -join "|" -ne ($expectedOperations | Sort-Object) -join "|" -or
    (@($query.safeOutputFields) | Sort-Object) -join "|" -ne ($expectedFields | Sort-Object) -join "|" -or
    @($query.excludedContent).Count -eq 0
) {
    throw "The Agent 365 audit query must retain its approved operations and payload-free output contract."
}

$token = Get-GraphToken -TenantId $ApprovedTenantId
$payload = $token.Split(".")[1].Replace("-", "+").Replace("_", "/")
$payload += "=" * ((4 - $payload.Length % 4) % 4)
$claims = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)) | ConvertFrom-Json -ErrorAction Stop
if (@($claims.roles) -notcontains "AuditLogsQuery.Read.All") {
    throw "The Microsoft Graph application token must include AuditLogsQuery.Read.All with administrator consent."
}
if ([string]$claims.tid -ine $ApprovedTenantId) {
    throw "The Microsoft Graph application token does not identify the approved tenant."
}

Write-Host "PASS: Session 10 accepts the supplied tenant and agent scope, validates the payload-free audit query, and leaves Purview state in Microsoft Purview."
