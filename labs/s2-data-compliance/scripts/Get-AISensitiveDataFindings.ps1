<#
.SYNOPSIS
    Export Microsoft Purview for AI / DSPM findings for sensitive data in AI interactions (read-only).

.DESCRIPTION
    Connects to Microsoft Graph with read-only security scopes and writes AI-related
    data-security findings to JSON evidence. The default Graph URI is intentionally
    configurable because DSPM for AI export endpoints can vary by tenant rollout;
    customers may paste the Microsoft Purview portal export URI or use a saved Graph
    query approved by their compliance team.

    Static-only: validated in CI. Live export is the customer's co-delivery step.

.PARAMETER OutFile
    Path to write the JSON evidence. Defaults to ./evidence/dspm-ai-findings.json.

.PARAMETER GraphUri
    Microsoft Graph URI used for read-only findings export.

.EXAMPLE
    ./Get-AISensitiveDataFindings.ps1 -OutFile ./evidence/dspm-ai-findings.json
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutFile = "./evidence/dspm-ai-findings.json",

    [Parameter()]
    [string]$GraphUri = "/beta/security/alerts_v2?`$top=50"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scopes = @(
    'SecurityEvents.Read.All',
    'AuditLog.Read.All',
    'Directory.Read.All'
)

Write-Verbose "Connecting to Microsoft Graph (read-only scopes)..."
Connect-MgGraph -Scopes $scopes -NoWelcome

try {
    $response = Invoke-MgGraphRequest -Method GET -Uri $GraphUri
    $items = @()
    if ($null -ne $response.value) {
        $items = @($response.value)
    } else {
        $items = @($response)
    }

    $aiFindings = @(
        $items | Where-Object {
            $text = ($_ | ConvertTo-Json -Depth 8)
            $text -match 'AI|Copilot|prompt|Purview|DSPM|sensitive|exfiltration'
        }
    )

    $result = [pscustomobject]@{
        capturedUtc = (Get-Date).ToUniversalTime().ToString('o')
        tenantId    = (Get-MgContext).TenantId
        sourceUri   = $GraphUri
        findingCount = $aiFindings.Count
        findings    = $aiFindings
    }

    $dir = Split-Path -Parent $OutFile
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $result | ConvertTo-Json -Depth 12 | Set-Content -Path $OutFile -Encoding utf8

    Write-Output "Exported $($aiFindings.Count) AI data-security finding(s) -> $OutFile"
    if ($aiFindings.Count -eq 0) {
        Write-Warning "No AI findings matched. Capture this as Tier B/no-finding evidence if expected."
    }
}
finally {
    Disconnect-MgGraph | Out-Null
}
