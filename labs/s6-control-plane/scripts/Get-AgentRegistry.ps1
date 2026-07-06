<#
.SYNOPSIS
    Export the Microsoft Agent 365 registry for S6 reconciliation (read-only reference).

.DESCRIPTION
    Connects to Microsoft Graph with read scopes and writes an Agent 365 registry
    export to JSON for evidence capture. Endpoint names can change as Agent 365
    APIs evolve; treat this script as a Tier A reference pattern and verify the
    current Microsoft Graph documentation before live use.

    Static-only: validated for syntax/style in CI. Live execution is the
    customer's co-delivery step.

.PARAMETER OutFile
    Path to write the registry export JSON. Defaults to ./evidence/agent-registry.json.

.PARAMETER ApiPath
    Microsoft Graph API path for the Agent 365 registry. Defaults to a placeholder
    beta path that must be verified before production use.

.EXAMPLE
    ./Get-AgentRegistry.ps1 -OutFile ./evidence/agent-registry.json
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutFile = "./evidence/agent-registry.json",

    [Parameter()]
    [string]$ApiPath = "/beta/agent365/agents"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scopes = @(
    'Directory.Read.All',
    'Application.Read.All'
)

Write-Verbose 'Connecting to Microsoft Graph with read-only scopes...'
Connect-MgGraph -Scopes $scopes -NoWelcome

try {
    Write-Verbose "Requesting Agent 365 registry from $ApiPath"
    $response = Invoke-MgGraphRequest -Method GET -Uri $ApiPath
    $agents = @()

    if ($response.ContainsKey('value')) {
        $agents = @($response['value'])
    } else {
        $agents = @($response)
    }

    $result = [pscustomobject]@{
        capturedUtc = (Get-Date).ToUniversalTime().ToString('o')
        tenantId    = (Get-MgContext).TenantId
        source      = $ApiPath
        agentCount  = $agents.Count
        agents      = $agents
    }

    $directory = Split-Path -Parent $OutFile
    if ($directory -and -not (Test-Path -Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $result | ConvertTo-Json -Depth 10 | Set-Content -Path $OutFile -Encoding utf8
    Write-Output "Exported $($agents.Count) registry agent(s) -> $OutFile"
}
finally {
    Disconnect-MgGraph | Out-Null
}
