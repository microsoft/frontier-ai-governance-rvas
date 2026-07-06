<#
.SYNOPSIS
    Remove the simulation/test Purview DLP policy created in S2 (rollback).

.DESCRIPTION
    Finds the DLP policy by display name and deletes it. Because the curriculum
    creates the policy only in simulation/test mode, removal has no blocking impact.

    Static-only: validated in CI.

.PARAMETER DisplayName
    Display name of the policy to remove.

.EXAMPLE
    ./Remove-AIDataLossPreventionPolicy.ps1 -DisplayName "RVAS S2 - AI sensitive data DLP (simulation)"
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter()]
    [string]$DisplayName = "RVAS S2 - AI sensitive data DLP (simulation)"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command Connect-IPPSSession -ErrorAction SilentlyContinue)) {
    throw "Connect-IPPSSession was not found. Install and import ExchangeOnlineManagement before running this script."
}

Connect-IPPSSession

try {
    $policy = Get-DlpCompliancePolicy -Identity $DisplayName -ErrorAction SilentlyContinue
    if ($null -eq $policy) {
        Write-Output "No DLP policy named '$DisplayName' found - nothing to remove."
        return
    }

    if ($PSCmdlet.ShouldProcess($DisplayName, "Remove simulation/test DLP policy")) {
        Remove-DlpCompliancePolicy -Identity $DisplayName -Confirm:$false
        Write-Output "Removed DLP policy '$DisplayName'."
    }
}
finally {
    if (Get-Command Disconnect-ExchangeOnline -ErrorAction SilentlyContinue) {
        Disconnect-ExchangeOnline -Confirm:$false
    }
}
