<#
.SYNOPSIS
    Creates a read-only readiness report for the lab sessions.
#>
[CmdletBinding()]
param(
    [string]$OutFile = "./evidence/tenant-readiness.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-MgGraph -Scopes 'Organization.Read.All', 'Application.Read.All' -NoWelcome
try {
    $skus = @(Get-MgSubscribedSku | ForEach-Object { $_.SkuPartNumber })
    $agents = @(Get-MgServicePrincipal -All -Property 'id,displayName' | Where-Object {
        $_.DisplayName -match 'agent|copilot'
    })
    $sessions = @(
        [pscustomobject]@{ session = 'S0'; status = 'ready'; reason = 'No tenant prerequisite.' }
        [pscustomobject]@{ session = 'S1'; status = 'review'; reason = 'Confirm workload identity licensing before risk-based Conditional Access.' }
        [pscustomobject]@{ session = 'S2'; status = 'review'; reason = 'Confirm Purview DSPM for AI availability.' }
        [pscustomobject]@{ session = 'S3'; status = 'review'; reason = 'Confirm Defender or Citadel track prerequisites.' }
        [pscustomobject]@{ session = 'S4'; status = 'review'; reason = 'Confirm non-production Foundry test target.' }
        [pscustomobject]@{ session = 'S5'; status = 'review'; reason = 'Confirm authorized non-production test target.' }
        [pscustomobject]@{ session = 'S6'; status = 'review'; reason = 'Confirm Agent 365 package inventory access.' }
    )
    $result = [pscustomobject]@{
        capturedUtc = (Get-Date).ToUniversalTime().ToString('o')
        tenantId = (Get-MgContext).TenantId
        subscribedSkuPartNumbers = $skus
        candidateAgentServicePrincipals = $agents
        sessions = $sessions
    }
    $directory = Split-Path -Parent $OutFile
    if ($directory -and -not (Test-Path -Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    $result | ConvertTo-Json -Depth 6 | Set-Content -Path $OutFile -Encoding utf8
    Write-Output "Readiness report written to $OutFile"
}
finally {
    Disconnect-MgGraph | Out-Null
}
