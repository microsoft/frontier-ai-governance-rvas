<#
.SYNOPSIS
    Export a Conditional Access policy from the tenant as JSON evidence.

.DESCRIPTION
    Reads a Conditional Access policy by display name and writes its full definition
    to JSON for the takeaway kit's evidence folder. Read-only.

    Static-only: validated by PSScriptAnalyzer in CI.

.PARAMETER DisplayName
    Display name of the policy to export.

.PARAMETER OutFile
    Path to write the exported JSON.

.EXAMPLE
    ./Export-AgentConditionalAccess.ps1 -OutFile ./evidence/ca-agent-baseline.deployed.json
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$DisplayName = "RVAS S1 - Agent baseline (report-only)",

    [Parameter()]
    [string]$OutFile = "./evidence/ca-agent-baseline.deployed.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-MgGraph -Scopes @('Policy.Read.All') -NoWelcome

try {
    $policy = Get-MgIdentityConditionalAccessPolicy -All |
        Where-Object { $_.DisplayName -eq $DisplayName } |
        Select-Object -First 1

    if ($null -eq $policy) {
        throw "No Conditional Access policy found with display name '$DisplayName'."
    }

    $dir = Split-Path -Parent $OutFile
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $policy | ConvertTo-Json -Depth 10 | Set-Content -Path $OutFile -Encoding utf8
    Write-Output "Exported '$DisplayName' (state: $($policy.State)) -> $OutFile"
}
finally {
    Disconnect-MgGraph | Out-Null
}
