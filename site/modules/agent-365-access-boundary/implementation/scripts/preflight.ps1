[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("Dlp", "Install")]
    [string]$Phase = "Dlp",

    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedTenantId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$AgentInstanceId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-GraphToken {
    param([string]$TenantId)

    $token = & az account get-access-token --tenant $TenantId --resource-type ms-graph --query accessToken --output tsv --only-show-errors
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
        $token = & az account get-access-token --tenant $TenantId --scope "https://graph.microsoft.com/.default" --query accessToken --output tsv --only-show-errors
    }
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
        throw "Unable to acquire a Microsoft Graph token for the approved tenant."
    }
    return $token.Trim()
}

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$deploymentPath = Join-Path $artifactRoot "agent-deployment.json"
$handoffPath = Join-Path $artifactRoot "governance\coverage-handoff.md"
$queryPath = Join-Path $artifactRoot "operations\agent-activity-audit-query.json"
$approvedTargetScope = "nonproduction-agent365-group-pilot"
$supportedPlatforms = @("foundry", "copilot-studio", "agent-builder")
$requiredSentinels = @(
    "__REQUIRED_AGENT_ALIAS__",
    "__REQUIRED_AGENT_INSTANCE_ID__",
    "__REQUIRED_AGENT_PLATFORM__",
    "__REQUIRED_AGENT_REGISTRY_ID__",
    "__REQUIRED_APPROVED_USE_CASE__",
    "__REQUIRED_DLP_POLICY_STATE__",
    "__REQUIRED_DLP_PROPAGATION_STATE__",
    "__REQUIRED_EXCLUDED_USER_ALIAS__",
    "__REQUIRED_HOST_PRODUCT__",
    "__REQUIRED_TENANT_ALIAS__",
    "__REQUIRED_TEST_GROUP_ALIAS__",
    "__REQUIRED_TEST_GROUP_MEMBER_ALIAS__",
    "__REQUIRED_TEST_GROUP_OBJECT_ID__"
)

foreach ($path in @($deploymentPath, $handoffPath, $queryPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required Agent 365 module implementation artifact is missing: $path"
    }
}
if (-not (Get-Command ConvertFrom-Json -ErrorAction SilentlyContinue)) {
    throw "PowerShell JSON support is required to validate the Agent 365 module implementation artifacts."
}

$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinels.Count -gt 0) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Agent 365 module preflight checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every Agent 365 module decision before changing DLP or Microsoft 365 state: $($unresolved -join ', ')."
}

$deployment = Get-Content -LiteralPath $deploymentPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$deployment.implementationSession -ne "optional-module-agent-365-access-boundary") {
    throw "agent-deployment.json has the wrong implementationSession marker."
}
if ([string]$deployment.targetScope -ne $approvedTargetScope) {
    throw "agent-deployment.json must use the approved target scope '$approvedTargetScope'."
}
if ([string]$deployment.agent.instanceId -ne $AgentInstanceId) {
    throw "The supplied Agent 365 instance ID must match agent.instanceId in agent-deployment.json."
}
if ([string]$deployment.agent.requiredStatus -ne "Available") {
    throw "The selected Agent Registry agent must be Available before installation."
}
$agentPlatform = [string]$deployment.agent.platform
if ($agentPlatform -notin $supportedPlatforms) {
    throw "agent.platform must be one of: $($supportedPlatforms -join ', ')."
}
if ([string]$deployment.deployment.adminConsent -ne "Approved") {
    throw "The Entra owner must approve the requested agent permissions before installation."
}
if ([string]$deployment.deployment.action -ne "InstallAfterDlpPropagation" -or
    [string]$deployment.deployment.restoreAction -ne "RemoveScopedInstallation") {
    throw "Agent 365 module requires scoped installation after DLP propagation and a scoped-installation removal route."
}
if ([string]$deployment.dlpGate.requiredInstallState -ne "EnabledAndPropagated") {
    throw "The DLP readiness gate must require EnabledAndPropagated before installation."
}
if ([string]$deployment.dataBoundary.allowedData -ne "SyntheticOnly" -or
    [string]$deployment.dataBoundary.userAccess -ne "ScopedAfterDlpPropagation") {
    throw "Agent 365 module permits labelled synthetic data and scoped access only after DLP propagation."
}
if (@($deployment.deployment.hostProducts).Count -ne 1 -or
    [string]::IsNullOrWhiteSpace([string]$deployment.deployment.hostProducts[0])) {
    throw "Configure exactly one approved host product for the scoped pilot."
}

$handoff = Get-Content -LiteralPath $handoffPath -Raw
if ($handoff -notmatch "\| Review cadence \| Quarterly \|") {
    throw "The coverage handoff must name its quarterly review cadence."
}

$query = Get-Content -LiteralPath $queryPath -Raw | ConvertFrom-Json -ErrorAction Stop
$expectedOperations = @("AIInvokeAgent", "AIExecuteTool", "AIInferenceCall", "AIGuardrail")
$expectedFields = @("CreationDate", "Operation", "AgentId", "AgentName", "ResultStatus")
if (
    [int]$query.schemaVersion -ne 1 -or
    [string]$query.implementationSession -ne "optional-module-agent-365-access-boundary" -or
    [string]$query.microsoftGraphApplicationPermission -ne "AuditLogsQuery.Read.All" -or
    [int]$query.lookbackHours -lt 1 -or [int]$query.lookbackHours -gt 168 -or
    (@($query.operations) | Sort-Object) -join "|" -ne ($expectedOperations | Sort-Object) -join "|" -or
    (@($query.safeOutputFields) | Sort-Object) -join "|" -ne ($expectedFields | Sort-Object) -join "|" -or
    @($query.excludedContent).Count -eq 0
) {
    throw "The Agent 365 audit query must retain its approved operations and payload-free output contract."
}

if ($Phase -eq "Dlp") {
    if ([string]$deployment.dlpGate.policyState -ne "ReadyForSimulation" -or
        [string]$deployment.dlpGate.propagationState -ne "NotStarted") {
        throw "DLP preflight requires ReadyForSimulation and NotStarted. Inspect the approved change before configuring Purview."
    }
    Write-Host "PASS: Agent 365 module is ready to configure the scoped DLP policy in TestWithNotifications. This phase does not authorize installation."
    return
}

if ([string]$deployment.dlpGate.policyState -ne "EnabledAndPropagated" -or
    [string]$deployment.dlpGate.propagationState -ne "Confirmed") {
    throw "Installation requires the recorded EnabledAndPropagated policy state and Confirmed propagation. Inspect Purview and the approved change before updating the gate."
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "az is required to verify the approved Microsoft Graph audit permission."
}

$token = Get-GraphToken -TenantId $ApprovedTenantId
$payload = $token.Split(".")[1].Replace("-", "+").Replace("_", "/")
$payload += "=" * ((4 - $payload.Length % 4) % 4)
$claims = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)) | ConvertFrom-Json -ErrorAction Stop
if (@($claims.roles) -notcontains "AuditLogsQuery.Read.All") {
    throw "The Microsoft Graph application token must include AuditLogsQuery.Read.All with administrator consent."
}
if ([string]$claims.tid -ine $ApprovedTenantId) {
    throw "The Microsoft Graph application token does not identify the approved tenant."
}

Write-Host "PASS: Agent 365 module accepts the approved scoped installation after recorded DLP propagation and validates the payload-free audit query."
