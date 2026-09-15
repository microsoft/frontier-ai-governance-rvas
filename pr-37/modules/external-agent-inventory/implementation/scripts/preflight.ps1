[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [string]$DecisionFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$requiredTargetScope = "one-approved-external-agent"
$supportedRegistrySyncPlatforms = @(
    "Amazon Bedrock",
    "Anthropic Claude Managed Agents",
    "Databricks Genie",
    "Google Vertex AI",
    "Oracle Generative AI Agents",
    "Salesforce Agentforce"
)
$requiredRetirementActions = @(
    "block-user-access",
    "revoke-connected-platform-credential",
    "remove-agent-registry-record",
    "retire-source-runtime",
    "preserve-required-audit-records"
)
$credentialFields = @(
    "issuingOwner",
    "grantedScope",
    "deleteCapabilityDecision",
    "storageLocation",
    "rotationAndRevocationOwner",
    "revocationPath"
)
# Every decision below must be resolved in the record before the platform change.
$requiredSentinels = @(
    "__REQUIRED_AGENT_365_ADMINISTRATOR_ROLE__",
    "__REQUIRED_AGENT_OWNER_ROLE__",
    "__REQUIRED_CREDENTIAL_GRANTED_SCOPE__",
    "__REQUIRED_CREDENTIAL_ISSUING_OWNER_ROLE__",
    "__REQUIRED_CREDENTIAL_REVOCATION_PATH__",
    "__REQUIRED_CREDENTIAL_ROTATION_OWNER_ROLE__",
    "__REQUIRED_CREDENTIAL_STORAGE_LOCATION__",
    "__REQUIRED_DELETE_CAPABILITY_DECISION__",
    "__REQUIRED_INTEGRATION_PATH__",
    "__REQUIRED_REGISTRY_SYNC_PLATFORM__",
    "__REQUIRED_RETIREMENT_COORDINATOR_ROLE__",
    "__REQUIRED_RETIREMENT_PLAN_REFERENCE__",
    "__REQUIRED_RUNTIME_OWNER_ROLE__",
    "__REQUIRED_RUNTIME_SOURCE_REFERENCE__"
)
$secretMarker = "(?i)(secret|password|token|api[-_ ]?key|access[-_ ]?key|consumer[-_ ]?key)\s*[:=]"

if (-not (Get-Command Get-Content -ErrorAction SilentlyContinue)) {
    throw "PowerShell core commands are unavailable."
}
if (-not (Test-Path -LiteralPath $PSScriptRoot -PathType Container)) {
    throw "The module script directory is unavailable."
}

$artifactRoot = Join-Path $PSScriptRoot "../artifacts"
if (-not (Test-Path -LiteralPath $artifactRoot -PathType Container)) {
    throw "The module artifacts folder is missing: $artifactRoot"
}
if ([string]::IsNullOrWhiteSpace($DecisionFile)) {
    $DecisionFile = Join-Path $artifactRoot "onboarding-decision.json"
}
if (-not (Test-Path -LiteralPath $DecisionFile -PathType Leaf)) {
    throw "The onboarding decision record is missing: $DecisionFile"
}
if ($TargetScope -ne $requiredTargetScope) {
    throw "TargetScope must be '$requiredTargetScope'."
}

$unresolved = @(
    Select-String -LiteralPath $DecisionFile -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches |
        ForEach-Object { $_.Matches.Value } |
        Sort-Object -Unique
)
if ($unresolved.Count -gt 0) {
    foreach ($sentinel in $unresolved) {
        if ($requiredSentinels -notcontains $sentinel) {
            throw "Add an explicit preflight check for the new decision: $sentinel"
        }
        Write-Warning "Unresolved decision: $sentinel"
    }
    throw "Resolve every onboarding decision before the Agent 365 change."
}

$decision = Get-Content -LiteralPath $DecisionFile -Raw | ConvertFrom-Json

function Get-DecisionText {
    param([object]$Section, [string]$Field, [string]$Label)

    if ($null -eq $Section -or -not $Section.PSObject.Properties.Name.Contains($Field)) {
        throw "$Label must be a non-empty string."
    }
    $value = $Section.$Field
    if ($value -isnot [string] -or [string]::IsNullOrWhiteSpace($value)) {
        throw "$Label must be a non-empty string."
    }
    return $value.Trim()
}

if ($decision.implementationSession -ne "optional-module-external-agent-inventory") {
    throw "The decision record has the wrong implementationSession marker."
}
if ($decision.targetScope -ne $requiredTargetScope) {
    throw "targetScope must be $requiredTargetScope."
}
if ($decision.targetScope -ne $TargetScope) {
    throw "targetScope does not match the approved target scope passed to preflight."
}

$integrationPath = Get-DecisionText $decision.onboarding "integrationPath" "onboarding.integrationPath"
if (@("built-in", "registry-sync", "sdk") -notcontains $integrationPath) {
    throw "onboarding.integrationPath must be built-in, registry-sync, or sdk."
}

$sourceReference = Get-DecisionText $decision.onboarding "runtimeSourceReference" "onboarding.runtimeSourceReference"
$sourceUri = $null
if (-not [uri]::TryCreate($sourceReference, [UriKind]::Absolute, [ref]$sourceUri)) {
    throw "onboarding.runtimeSourceReference must be an absolute HTTP or HTTPS URL."
}
if (@("http", "https") -notcontains $sourceUri.Scheme) {
    throw "onboarding.runtimeSourceReference must be an absolute HTTP or HTTPS URL."
}
if ([string]::IsNullOrEmpty($sourceUri.Host)) {
    throw "onboarding.runtimeSourceReference must name a host."
}
if (-not [string]::IsNullOrEmpty($sourceUri.UserInfo)) {
    throw "onboarding.runtimeSourceReference must not contain embedded credentials."
}

foreach ($role in @("agent365Administrator", "runtimeOwner", "agentOwner", "retirementCoordinator")) {
    if ((Get-DecisionText $decision.owners $role "owners.$role").ToUpperInvariant() -eq "N/A") {
        throw "owners.$role must name a role that can act on the live system."
    }
}

$registryPlatform = Get-DecisionText $decision.onboarding "registrySyncPlatform" "onboarding.registrySyncPlatform"
if ($integrationPath -eq "registry-sync") {
    if ($supportedRegistrySyncPlatforms -notcontains $registryPlatform) {
        throw "onboarding.registrySyncPlatform is not a supported connected platform."
    }
    $values = @{}
    foreach ($field in $credentialFields) {
        $value = Get-DecisionText $decision.connectedPlatformCredential $field "connectedPlatformCredential.$field"
        if ($value.ToUpperInvariant() -eq "N/A") {
            throw "connectedPlatformCredential.$field is required for Registry sync."
        }
        $values[$field] = $value
    }
    if ($values["deleteCapabilityDecision"] -ne "accepted-by-retirement-coordinator") {
        throw ("The retirement coordinator must accept that the connection credential can delete agents " +
            "on the external platform: set deleteCapabilityDecision to accepted-by-retirement-coordinator.")
    }
    $storage = $values["storageLocation"]
    if ($storage.StartsWith(".") -or $storage.StartsWith("/") -or $storage.StartsWith("\") -or
        $storage -match '^[A-Za-z]:[\\/]') {
        throw "connectedPlatformCredential.storageLocation must name a managed secret store, not a file path."
    }
    if ($storage.Replace("\", "/") -like "*implementation/artifacts*") {
        throw "The connection credential must never live in this repository."
    }
    foreach ($field in @("grantedScope", "storageLocation", "revocationPath")) {
        if ($values[$field] -match $secretMarker) {
            throw "connectedPlatformCredential.$field looks like credential material; record a reference instead."
        }
    }
}
else {
    if ($registryPlatform.ToUpperInvariant() -ne "N/A") {
        throw "onboarding.registrySyncPlatform applies only to the registry-sync route; use N/A."
    }
    foreach ($field in $credentialFields) {
        $value = Get-DecisionText $decision.connectedPlatformCredential $field "connectedPlatformCredential.$field"
        if ($value.ToUpperInvariant() -ne "N/A") {
            throw "connectedPlatformCredential.$field applies only to the registry-sync route; use N/A."
        }
    }
}

$planReference = Get-DecisionText $decision.retirementCoordination "planReference" "retirementCoordination.planReference"
if ($planReference.ToUpperInvariant() -eq "N/A") {
    throw "retirementCoordination.planReference must link the approved cross-platform retirement plan."
}
$recordedActions = @($decision.retirementCoordination.requiredActions)
$missingActions = @($requiredRetirementActions | Where-Object { $recordedActions -notcontains $_ } | Sort-Object)
if ($missingActions.Count -gt 0) {
    throw "The retirement plan must cover: $($missingActions -join ', ')"
}

Write-Host "PASS: the onboarding route, source reference, credential decision, and retirement plan are recorded."
Write-Host "NOTE: a read-only deployment preview is unsupported; Agent 365 onboarding runs through the selected platform or runtime change path."
