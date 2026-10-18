[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$DesignRecordPath = (Join-Path $PSScriptRoot "..\artifacts\gateway-design-record.json")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$requiredSentinelPattern = "_{2}REQUIRED_[A-Z0-9_]+_{2}"

if (-not (Get-Command ConvertFrom-Json -ErrorAction SilentlyContinue)) {
    throw "PowerShell JSON support is required to inspect the gateway design record."
}
if (-not (Test-Path -LiteralPath $DesignRecordPath -PathType Leaf)) {
    throw "The gateway design record is missing: $DesignRecordPath"
}

$rawRecord = Get-Content -LiteralPath $DesignRecordPath -Raw
try {
    $record = $rawRecord | ConvertFrom-Json -ErrorAction Stop
}
catch {
    throw "The gateway design record must be valid JSON: $DesignRecordPath"
}

$matches = [regex]::Matches($rawRecord, $requiredSentinelPattern)
if ($matches.Count -gt 0) {
    throw "Resolve every required gateway design decision before sharing this record."
}

if ($record.recordVersion -ne 1) {
    throw "gateway-design-record.json must use recordVersion 1."
}
$approvedTargetScope = [string]$record.approvedImplementationScope.scopeReference
if ([string]::IsNullOrWhiteSpace($approvedTargetScope)) {
    throw "The approved target scope must be recorded before the design is shared."
}
if ([string]$record.recordStatus -notin @("approved-with-gaps", "ready-for-implementation")) {
    throw "recordStatus must be approved-with-gaps or ready-for-implementation."
}

$requiredValues = @(
    $record.approvedImplementationScope.scopeReference,
    $record.approvedImplementationScope.environment,
    $record.approvedImplementationScope.changeReference,
    $record.apiManagement.instanceName,
    $record.apiManagement.tier,
    $record.apiManagement.deploymentModel,
    $record.targetBackend.type,
    $record.targetBackend.implementationVariant,
    $record.targetBackend.endpointReference,
    $record.ingress.pattern,
    $record.ingress.clientIdentity,
    $record.ingress.backendIdentity,
    $record.ingress.backendRoleState,
    $record.network.inboundPath,
    $record.network.backendPath,
    $record.network.privateDnsState,
    $record.contentSafety.decision,
    $record.contentSafety.backendReference,
    $record.telemetry.sink,
    $record.telemetry.bodyCapturePolicy,
    $record.controls.requestLimit,
    $record.controls.tokenLimitDecision,
    $record.controls.safetyPolicy,
    $record.controls.routingDecision,
    $record.controls.restoreDecision,
    $record.owners.apiProduct,
    $record.owners.identity,
    $record.owners.network,
    $record.owners.safety,
    $record.owners.operations,
    $record.owners.delivery,
    $record.approval.designApprover,
    $record.approval.approvalReference
)
if (@($requiredValues | Where-Object { [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0) {
    throw "The gateway design record has an empty required decision."
}

$gaps = @($record.readinessGaps)
if ($gaps.Count -eq 0) {
    throw "Record an explicit readiness-gaps entry, including 'none' when no gap remains."
}
foreach ($gap in $gaps) {
    if ([string]$gap.status -notin @("open", "resolved", "not-applicable")) {
        throw "Each readiness gap must use open, resolved, or not-applicable status."
    }
    if ([string]::IsNullOrWhiteSpace([string]$gap.id) -or
        [string]::IsNullOrWhiteSpace([string]$gap.description) -or
        [string]::IsNullOrWhiteSpace([string]$gap.owner) -or
        [string]::IsNullOrWhiteSpace([string]$gap.resolution)) {
        throw "Each readiness gap must identify its ID, description, owner, and resolution."
    }
}
if ($record.recordStatus -eq "ready-for-implementation" -and
    @($gaps | Where-Object { $_.status -eq "open" }).Count -gt 0) {
    throw "A record with open readiness gaps cannot be ready-for-implementation."
}
if ($record.recordStatus -eq "approved-with-gaps" -and
    @($gaps | Where-Object { $_.status -eq "open" }).Count -eq 0) {
    throw "approved-with-gaps requires at least one open readiness gap."
}

Write-Host "PASS: Session 06 gateway design record is complete and its readiness state is inspectable. No Azure resources were changed."
