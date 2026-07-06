<#
.SYNOPSIS
    Inventory Microsoft Entra Agent ID identities and their human sponsors (read-only).

.DESCRIPTION
    Connects to Microsoft Graph with least-privilege read scopes and exports the
    agent identities present in the tenant, including sponsor/owner information, to
    JSON. Makes NO changes to the tenant.

    Static-only: this script is validated by PSScriptAnalyzer in CI. Live execution
    is the customer's co-delivery step.

.PARAMETER OutFile
    Path to write the JSON inventory. Defaults to ./evidence/agent-inventory.json.

.EXAMPLE
    ./Get-AgentIdentities.ps1 -OutFile ./evidence/agent-inventory.json
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutFile = "./evidence/agent-inventory.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Least-privilege read scopes. Agent identities surface as service principals with
# an agent tag; sponsors surface as owners.
$scopes = @(
    'Application.Read.All',
    'Directory.Read.All'
)

Write-Verbose "Connecting to Microsoft Graph (read-only scopes)..."
Connect-MgGraph -Scopes $scopes -NoWelcome

try {
    # Agent identities are modeled as service principals. Adjust the filter to your
    # tenant's tagging convention if needed; this errs toward inclusivity.
    $servicePrincipals = Get-MgServicePrincipal -All -Property 'id,displayName,appId,servicePrincipalType,tags,accountEnabled'

    $agents = foreach ($sp in $servicePrincipals) {
        $isAgent = $false
        if ($null -ne $sp.Tags) {
            $isAgent = @($sp.Tags | Where-Object { $_ -match 'agent' }).Count -gt 0
        }
        if (-not $isAgent) { continue }

        $owners = @()
        try {
            $owners = Get-MgServicePrincipalOwner -ServicePrincipalId $sp.Id -All |
                ForEach-Object { $_.AdditionalProperties['userPrincipalName'] ?? $_.Id }
        } catch {
            Write-Warning "Could not read owners for $($sp.DisplayName): $($_.Exception.Message)"
        }

        [pscustomobject]@{
            displayName          = $sp.DisplayName
            objectId             = $sp.Id
            appId                = $sp.AppId
            servicePrincipalType = $sp.ServicePrincipalType
            accountEnabled       = $sp.AccountEnabled
            sponsors             = $owners
            hasSponsor           = @($owners).Count -gt 0
        }
    }

    $agents = @($agents)
    $result = [pscustomobject]@{
        capturedUtc = (Get-Date).ToUniversalTime().ToString('o')
        tenantId    = (Get-MgContext).TenantId
        agentCount  = $agents.Count
        agents      = $agents
    }

    $dir = Split-Path -Parent $OutFile
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $result | ConvertTo-Json -Depth 6 | Set-Content -Path $OutFile -Encoding utf8

    Write-Output "Inventoried $($agents.Count) agent identity(ies) -> $OutFile"
    $withoutSponsor = @($agents | Where-Object { -not $_.hasSponsor })
    if ($withoutSponsor.Count -gt 0) {
        Write-Warning "$($withoutSponsor.Count) agent(s) have NO human sponsor - governance finding."
    }
}
finally {
    Disconnect-MgGraph | Out-Null
}
