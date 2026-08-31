[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$deploymentPath = Join-Path $artifactRoot "agent-deployment.json"
$approvedTargetScope = "nonproduction-agent365-group-pilot"
$requiredSentinels = @(
    "__REQUIRED_AGENT_ALIAS__",
    "__REQUIRED_AGENT_PLATFORM__",
    "__REQUIRED_AGENT_REGISTRY_ID__",
    "__REQUIRED_APPROVED_USE_CASE__",
    "__REQUIRED_EXCLUDED_USER_ALIAS__",
    "__REQUIRED_HOST_PRODUCT__",
    "__REQUIRED_TENANT_ALIAS__",
    "__REQUIRED_TEST_GROUP_ALIAS__",
    "__REQUIRED_TEST_GROUP_MEMBER_ALIAS__",
    "__REQUIRED_TEST_GROUP_OBJECT_ID__"
)

if (-not (Test-Path -LiteralPath $deploymentPath -PathType Leaf)) {
    throw "Required Agent 365 deployment configuration is missing: $deploymentPath"
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python is required to validate the Agent 365 deployment configuration."
}

$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinels.Count -gt 0) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Session 06 preflight checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every Session 06 group-deployment decision before changing Microsoft 365 state: $($unresolved -join ', ')."
}

$deployment = Get-Content -LiteralPath $deploymentPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$deployment.implementationSession -ne "06-agent-365-access-boundary") {
    throw "agent-deployment.json has the wrong implementationSession marker."
}
if ([string]$deployment.targetScope -ne $approvedTargetScope) {
    throw "agent-deployment.json must use the approved target scope '$approvedTargetScope'."
}
if ([string]$deployment.agent.requiredStatus -ne "Available") {
    throw "The selected Agent Registry agent must be Available before installation."
}
if ([string]$deployment.deployment.adminConsent -ne "Approved") {
    throw "The Entra owner must approve the requested agent permissions before installation."
}
if ([string]$deployment.deployment.restoreAction -ne "Uninstall") {
    throw "The Session 06 restore action must be Uninstall."
}
if ([string]$deployment.dataBoundary.allowedData -ne "SyntheticOnly" -or
    [string]$deployment.dataBoundary.userAccess -ne "WithheldPendingSession10DlpConfirmation") {
    throw "Session 06 permits synthetic-data setup only. Withhold user access until Session 10 confirms the DLP policy."
}
if (@($deployment.deployment.hostProducts).Count -ne 1 -or
    [string]::IsNullOrWhiteSpace([string]$deployment.deployment.hostProducts[0])) {
    throw "Configure exactly one approved host product for the scoped pilot."
}

Write-Host "No read-only deployment preview is supported for this Microsoft 365 admin center action. Preflight validates the approved target scope and the exact change contract."
Write-Host "PASS: The Agent 365 deployment contract is complete for one Available agent, one test group, one host product, approved permission consent, and an uninstall restore path."
