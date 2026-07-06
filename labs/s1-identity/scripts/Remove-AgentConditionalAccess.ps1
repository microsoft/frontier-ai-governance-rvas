<#
.SYNOPSIS
    Remove the report-only Conditional Access policy created in S1 (rollback).

.DESCRIPTION
    Finds the policy by display name and deletes it. Because the policy is
    report-only, removal has no user or agent impact.

    Static-only: validated by PSScriptAnalyzer in CI.

.PARAMETER DisplayName
    Display name of the policy to remove.

.EXAMPLE
    ./Remove-AgentConditionalAccess.ps1 -DisplayName "RVAS S1 - Agent baseline (report-only)"
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter()]
    [string]$DisplayName = "RVAS S1 - Agent baseline (report-only)"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') -NoWelcome

try {
    $policy = Get-MgIdentityConditionalAccessPolicy -All |
        Where-Object { $_.DisplayName -eq $DisplayName } |
        Select-Object -First 1

    if ($null -eq $policy) {
        Write-Output "No policy named '$DisplayName' found - nothing to remove."
        return
    }

    if ($PSCmdlet.ShouldProcess($DisplayName, "Remove Conditional Access policy")) {
        Remove-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $policy.Id
        Write-Output "Removed policy '$DisplayName' (id: $($policy.Id))."
    }
}
finally {
    Disconnect-MgGraph | Out-Null
}
