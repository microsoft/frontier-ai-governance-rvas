<#
.SYNOPSIS
    Create a Purview DLP policy for AI interactions in SIMULATION/TEST mode.

.DESCRIPTION
    Reads an exported-style Purview DLP policy JSON file and creates a DLP policy
    through Security & Compliance PowerShell. The script REFUSES to proceed unless
    the policy mode is a simulation/test value and no blocking action is enabled.
    Promotion to enforce is a separate, customer-owned change after impact review.

    Static-only: validated in CI. Live creation is the customer's co-delivery step.

.PARAMETER PolicyFile
    Path to the DLP policy JSON (see policies/dlp-ai-simulation.json).

.EXAMPLE
    ./New-AIDataLossPreventionPolicy.ps1 -PolicyFile ./policies/dlp-ai-simulation.json
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
$allowedModes = @('TestWithoutNotifications', 'TestWithNotifications', 'Simulation', 'Test')
if ($policy.mode -notin $allowedModes) {
    throw "Refusing to create: policy mode is '$($policy.mode)'. This kit only creates simulation/test DLP policies."
}

$rules = @($policy.rules)
if ($rules.Count -eq 0) {
    throw "Refusing to create: no DLP rules are defined."
}

foreach ($rule in $rules) {
    if ($rule.actions.blockAccess -eq $true -or $rule.actions.restrictAccess -eq $true) {
        throw "Refusing to create: rule '$($rule.name)' enables a blocking or restrictive action. Use simulation/test only."
    }
}

$policyJson = $policy | ConvertTo-Json -Depth 12
if ($policyJson -match 'REPLACE-WITH') {
    throw "Refusing to create: policy JSON still contains REPLACE-WITH placeholders. Fill tenant-specific IDs first."
}

if (-not (Get-Command Connect-IPPSSession -ErrorAction SilentlyContinue)) {
    throw "Connect-IPPSSession was not found. Install and import ExchangeOnlineManagement before running this script."
}

Connect-IPPSSession

try {
    $existing = Get-DlpCompliancePolicy -Identity $policy.displayName -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Output "DLP policy '$($policy.displayName)' already exists (mode: $($existing.Mode)) - nothing to create."
        return
    }

    if ($PSCmdlet.ShouldProcess($policy.displayName, "Create simulation/test DLP policy")) {
        $created = New-DlpCompliancePolicy -Name $policy.displayName -Mode $policy.mode -Comment $policy.description
        Write-Output "Created DLP policy '$($created.Name)' in mode '$($policy.mode)'."

        foreach ($rule in $rules) {
            $sensitiveInformation = @()
            foreach ($item in @($rule.conditions.contentContainsSensitiveInformation)) {
                $sensitiveInformation += @{ Name = $item.name; minCount = $item.minCount; confidenceLevel = $item.confidenceLevel }
            }

            $createdRule = New-DlpComplianceRule -Name $rule.name -Policy $policy.displayName -ContentContainsSensitiveInformation $sensitiveInformation -GenerateIncidentReport $rule.actions.generateIncidentReport -Disabled:(!$rule.enabled)
            Write-Output "Created DLP rule '$($createdRule.Name)' for policy '$($policy.displayName)'."
        }
    }
}
finally {
    if (Get-Command Disconnect-ExchangeOnline -ErrorAction SilentlyContinue) {
        Disconnect-ExchangeOnline -Confirm:$false
    }
}
