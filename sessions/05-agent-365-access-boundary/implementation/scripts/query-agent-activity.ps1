[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$AgentInstanceId,

    [Parameter()]
    [datetime]$StartUtc,

    [Parameter()]
    [datetime]$EndUtc = [datetime]::UtcNow,

    [Parameter()]
    [ValidateRange(1, 5000)]
    [int]$ResultSize = 1000
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$queryPath = Join-Path $PSScriptRoot "..\artifacts\operations\agent-activity-audit-query.json"
if (-not (Test-Path -LiteralPath $queryPath -PathType Leaf)) {
    throw "Audit query definition is missing: $queryPath"
}

$query = Get-Content -LiteralPath $queryPath -Raw | ConvertFrom-Json -ErrorAction Stop
$expectedOperations = @("AIInvokeAgent", "AIExecuteTool", "AIInferenceCall", "AIGuardrail")
$expectedFields = @("CreationDate", "Operation", "AgentId", "AgentName", "ResultStatus")
if (
    [int]$query.schemaVersion -ne 1 -or
    [string]$query.implementationSession -ne "06-agent-365-access-boundary" -or
    [string]$query.microsoftGraphApplicationPermission -ne "AuditLogsQuery.Read.All" -or
    [int]$query.lookbackHours -lt 1 -or [int]$query.lookbackHours -gt 168 -or
    (@($query.operations) | Sort-Object) -join "|" -ne ($expectedOperations | Sort-Object) -join "|" -or
    (@($query.safeOutputFields) | Sort-Object) -join "|" -ne ($expectedFields | Sort-Object) -join "|" -or
    @($query.excludedContent).Count -eq 0
) {
    throw "The Agent 365 audit query must retain its approved operations and payload-free output contract."
}
if (-not $PSBoundParameters.ContainsKey("StartUtc")) {
    $StartUtc = $EndUtc.AddHours(-1 * [int]$query.lookbackHours)
}
if ($StartUtc -ge $EndUtc) {
    throw "StartUtc must be earlier than EndUtc."
}
if (-not (Get-Command Search-UnifiedAuditLog -ErrorAction SilentlyContinue)) {
    throw "Search-UnifiedAuditLog is unavailable. Connect Exchange Online PowerShell first."
}

$records = @(
    Search-UnifiedAuditLog `
        -StartDate $StartUtc `
        -EndDate $EndUtc `
        -Operations @($query.operations) `
        -ResultSize $ResultSize `
        -ErrorAction Stop
)

$safeRows = foreach ($record in $records) {
    $data = $record.AuditData | ConvertFrom-Json -ErrorAction Stop
    $agentId = if ($data.PSObject.Properties.Name -contains "AgentId") {
        [string]$data.AgentId
    }
    else {
        ""
    }
    if ($agentId -ne $AgentInstanceId) {
        continue
    }

    [pscustomobject]@{
        CreationDate = [datetime]$record.CreationDate
        Operation = [string]$record.Operations
        AgentId = $agentId
        AgentName = if ($data.PSObject.Properties.Name -contains "AgentName") {
            [string]$data.AgentName
        }
        else {
            ""
        }
        ResultStatus = if ($data.PSObject.Properties.Name -contains "ResultStatus") {
            [string]$data.ResultStatus
        }
        else {
            ""
        }
    }
}

if (-not $safeRows) {
    Write-Host "No matching Agent 365 activity found in the selected window."
    return
}

$safeRows |
    Sort-Object CreationDate |
    Format-Table -AutoSize

Write-Host "Returned $(@($safeRows).Count) payload-free activity record(s). No audit export was written."
