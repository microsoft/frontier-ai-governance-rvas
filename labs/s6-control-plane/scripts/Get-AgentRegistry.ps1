<#
.SYNOPSIS
    Export the Microsoft Agent 365 registry for S6 reconciliation (read-only reference).

.DESCRIPTION
    Connects to Microsoft Graph with read scopes and writes an Agent 365 registry
    export to JSON for evidence capture. Endpoint names can change as Agent 365
    APIs evolve; treat this script as a reference pattern and verify the
    current Microsoft Graph documentation before live use.

    Static-only: validated for syntax/style in CI. Live execution is the
    customer's co-delivery step.

.PARAMETER OutFile
    Path to write the registry export JSON. Defaults to ./evidence/agent-registry.json.

.PARAMETER ApiPath
    Microsoft Graph API path for the Agent 365 package inventory.

.EXAMPLE
    ./Get-AgentRegistry.ps1 -OutFile ./evidence/agent-registry.json
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutFile = "./evidence/agent-registry.json",

    [Parameter()]
    [string]$ApiPath = "/v1.0/copilot/admin/catalog/packages"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scopes = @('CopilotPackages.Read.All')

Write-Verbose 'Connecting to Microsoft Graph with read-only scopes...'
Connect-MgGraph -Scopes $scopes -NoWelcome

try {
    Write-Verbose "Requesting Agent 365 registry from $ApiPath"
    $response = Invoke-MgGraphRequest -Method GET -Uri $ApiPath
    $agents = @()

    if ($null -ne $response.value) {
        $agents = @($response.value)
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
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 403 -or $statusCode -eq 404) {
        throw "Agent 365 package inventory request returned HTTP $statusCode. Verify the tenant has an Agent 365 license and that the operator has AI admin or Global admin. For Entra identity-only inventory, use labs/s1-identity/scripts/Get-AgentIdentities.ps1."
    }
    throw
}
finally {
    Disconnect-MgGraph | Out-Null
}
