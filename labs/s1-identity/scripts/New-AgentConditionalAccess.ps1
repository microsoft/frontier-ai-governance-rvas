<#
.SYNOPSIS
    Create a Conditional Access policy targeting agent identities in REPORT-ONLY mode.

.DESCRIPTION
    Reads a Conditional Access policy definition from JSON and creates it via
    Microsoft Graph. The script REFUSES to proceed unless the policy state is
    'enabledForReportingButNotEnforced' (report-only) and a break-glass exclusion
    group is present, enforcing the curriculum's audit-first safety protocol.

    Static-only: validated by PSScriptAnalyzer in CI. Live creation is the
    customer's co-delivery step.

.PARAMETER PolicyFile
    Path to the Conditional Access policy JSON (see policies/ca-agent-baseline.json).

.EXAMPLE
    ./New-AgentConditionalAccess.ps1 -PolicyFile ./policies/ca-agent-baseline.json
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [string]$PolicyFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $PolicyFile)) {
    throw "Policy file not found: $PolicyFile"
}

$policy = Get-Content -Path $PolicyFile -Raw | ConvertFrom-Json

# Safety gate 1: report-only only.
if ($policy.state -ne 'enabledForReportingButNotEnforced') {
    throw "Refusing to create: policy state is '$($policy.state)'. This curriculum only creates Conditional Access in report-only ('enabledForReportingButNotEnforced'). Promotion to enforce is a separate, customer-owned step."
}

# Safety gate 2: a break-glass exclusion must be present and not a placeholder.
$excluded = @($policy.conditions.users.excludeGroups)
if ($excluded.Count -eq 0) {
    throw "Refusing to create: no excludeGroups set. Add the break-glass group object ID before creating any policy."
}
if ($excluded -match 'REPLACE-WITH') {
    throw "Refusing to create: excludeGroups still contains a placeholder. Set the real break-glass group object ID first."
}
if (@($policy.conditions.users.includeGroups) -match 'REPLACE-WITH') {
    throw "Refusing to create: includeGroups still contains a placeholder. Set the real agent-identity group object ID first."
}

$scopes = @('Policy.ReadWrite.ConditionalAccess', 'Policy.Read.All')
Write-Verbose "Connecting to Microsoft Graph..."
Connect-MgGraph -Scopes $scopes -NoWelcome

try {
    $body = $policy | ConvertTo-Json -Depth 10
    if ($PSCmdlet.ShouldProcess($policy.displayName, "Create report-only Conditional Access policy")) {
        $created = New-MgIdentityConditionalAccessPolicy -BodyParameter $body
        Write-Output "Created report-only policy '$($created.DisplayName)' (id: $($created.Id))."
        Write-Output "State: $($created.State). Review sign-in impact before any promotion to enforce."
    }
}
finally {
    Disconnect-MgGraph | Out-Null
}
