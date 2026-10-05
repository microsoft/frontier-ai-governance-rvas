#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ArtifactRoot = (Join-Path $PSScriptRoot '..\artifacts')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$requiredTargetScope = "one-approved-fabric-ai-grounding-lakehouse"
$moduleMarker = "optional-module-fabric-purview-ai-data-governance"
$requiredFiles = @(
    "fabric\tenant-settings-baseline.json",
    "fabric\onelake-ai-consumer-role.json",
    "purview\fabric-label-dlp-decision.json",
    "verification\access-check-plan.json"
)
$requiredSentinels = @(
    "__REQUIRED_AI_CONSUMER_GROUP_NAME__",
    "__REQUIRED_AI_CONSUMER_GROUP_OBJECT_ID__",
    "__REQUIRED_ALLOWED_COLUMN_NAME__",
    "__REQUIRED_APPROVED_ITEMS_REVIEW_OWNER__",
    "__REQUIRED_BLOCKED_ERROR_OR_EMPTY_RESULT__",
    "__REQUIRED_COPILOT_CAPACITY_ADMIN_GROUP__",
    "__REQUIRED_CURRENT_DATA_ACCESS_ROLE_ETAG__",
    "__REQUIRED_DATA_ACCESS_OWNER__",
    "__REQUIRED_DELIVERY_OWNER_ROLE__",
    "__REQUIRED_DLP_ALERT_OWNER__",
    "__REQUIRED_DLP_CHANGE_REFERENCE__",
    "__REQUIRED_DLP_RESTORE_REFERENCE__",
    "__REQUIRED_DLP_TEST_MODE_OWNER__",
    "__REQUIRED_EXPECTED_ALLOWED_RESULT_SHAPE__",
    "__REQUIRED_FABRIC_ADMIN_ROLE__",
    "__REQUIRED_FABRIC_COPILOT_AI_PILOT_GROUP__",
    "__REQUIRED_FABRIC_LAKEHOUSE_ITEM_ID__",
    "__REQUIRED_FABRIC_WORKSPACE_ID__",
    "__REQUIRED_FOUNDRY_OBSERVABILITY_OWNER__",
    "__REQUIRED_GOLD_LAKEHOUSE_NAME__",
    "__REQUIRED_GOLD_TABLE_NAME__",
    "__REQUIRED_LABEL_DISPLAY_NAME__",
    "__REQUIRED_LABEL_GUID__",
    "__REQUIRED_PERMITTED_CONSUMER_ALIAS__",
    "__REQUIRED_PROTECTION_POLICY_REFERENCE__",
    "__REQUIRED_PURVIEW_DLP_POLICY_NAME__",
    "__REQUIRED_PURVIEW_POLICY_OWNER__",
    "__REQUIRED_RESTRICTED_CONSUMER_ALIAS__",
    "__REQUIRED_RESTRICTED_CONSUMER_GROUP_OBJECT_ID__",
    "__REQUIRED_RLS_PREDICATE__",
    "__REQUIRED_TARGET_TENANT_ID__",
    "__REQUIRED_TENANT_BASELINE_OWNER__"
)

$resolvedArtifactRoot = (Resolve-Path -LiteralPath $ArtifactRoot -ErrorAction Stop).Path
foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $resolvedArtifactRoot $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $relativePath"
    }
}

if ($TargetScope -ne $requiredTargetScope) {
    throw "TargetScope must be '$requiredTargetScope'."
}

$artifactFiles = Get-ChildItem -LiteralPath $resolvedArtifactRoot -Recurse -File |
    Where-Object { $_.Name -ne "README.md" }
$unresolved = @()
foreach ($file in $artifactFiles) {
    $matches = Select-String -LiteralPath $file.FullName -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches
    foreach ($match in $matches) {
        foreach ($value in $match.Matches.Value) {
            $unresolved += [pscustomobject]@{
                Sentinel = $value
                Path = $file.FullName
            }
        }
    }
}

if ($unresolved.Count -gt 0) {
    foreach ($sentinel in ($unresolved.Sentinel | Sort-Object -Unique)) {
        if ($requiredSentinels -notcontains $sentinel) {
            throw "Add an explicit preflight check for the new decision: $sentinel"
        }
        Write-Warning "Unresolved decision: $sentinel"
    }
    throw "Resolve every Fabric, Purview, and access-check decision before any service change."
}

foreach ($command in @("az", "Get-Content")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command is unavailable: $command"
    }
}

function Read-JsonArtifact {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    $path = Join-Path $resolvedArtifactRoot $RelativePath
    return Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -Depth 100
}

$tenantBaseline = Read-JsonArtifact -RelativePath "fabric\tenant-settings-baseline.json"
$oneLakeRole = Read-JsonArtifact -RelativePath "fabric\onelake-ai-consumer-role.json"
$dlpDecision = Read-JsonArtifact -RelativePath "purview\fabric-label-dlp-decision.json"
$accessPlan = Read-JsonArtifact -RelativePath "verification\access-check-plan.json"

foreach ($artifact in @($tenantBaseline, $oneLakeRole, $dlpDecision, $accessPlan)) {
    if ($artifact.implementationSession -ne $moduleMarker) {
        throw "Artifact has the wrong implementationSession marker."
    }
    if ($artifact.targetScope -ne $requiredTargetScope) {
        throw "Artifact targetScope must be '$requiredTargetScope'."
    }
}

if ($oneLakeRole.tenantId -ne $tenantBaseline.tenantId) {
    throw "Tenant IDs must match between tenant-settings-baseline.json and onelake-ai-consumer-role.json."
}
if ($oneLakeRole.fabric.workspaceId -ne $dlpDecision.fabricItem.workspaceId -or
    $oneLakeRole.fabric.lakehouseItemId -ne $dlpDecision.fabricItem.lakehouseItemId) {
    throw "Fabric workspace and lakehouse item IDs must match between OneLake and Purview artifacts."
}
if ($oneLakeRole.fabric.workspaceId -ne $accessPlan.fabric.workspaceId -or
    $oneLakeRole.fabric.lakehouseItemId -ne $accessPlan.fabric.lakehouseItemId) {
    throw "Fabric workspace and lakehouse item IDs must match the access-check plan."
}

$role = $oneLakeRole.rolePayload.value | Where-Object { $_.name -eq "AiGroundingConsumerRead" } | Select-Object -First 1
if ($null -eq $role) {
    throw "The OneLake role payload must include AiGroundingConsumerRead."
}
$membersProperty = $role.members.PSObject.Properties["microsoftEntraMembers"]
$groupMembers = @()
if ($null -ne $membersProperty -and $null -ne $membersProperty.Value) {
    $groupMembers = @($membersProperty.Value | Where-Object { $_.objectType -eq "Group" })
}
if ($groupMembers.Count -ne 1) {
    throw "The OneLake role must name exactly one Microsoft Entra group member."
}
$member = $groupMembers[0]
if ($member.objectId -ne $oneLakeRole.accessBoundary.aiConsumerGroupObjectId) {
    throw "The OneLake role member must match accessBoundary.aiConsumerGroupObjectId."
}
if ($member.tenantId -ne $oneLakeRole.tenantId) {
    throw "The OneLake role member tenant must match the approved tenant."
}

if ($dlpDecision.dlpPolicy.location -ne "Fabric" -or $dlpDecision.dlpPolicy.mode -ne "simulation") {
    throw "The Purview DLP policy decision must stay scoped to Fabric in simulation mode."
}
if ($accessPlan.checks.Count -ne 2) {
    throw "The access-check plan must contain intended-path and blocked-path checks."
}

Write-Host "PASS: local artifacts, target scope, owner records, and role payload are ready."
Write-Host "PREVIEW: OneLake role application supports Fabric REST dryRun=true with If-Match. Purview DLP uses portal simulation mode; this module has no read-only API deployment preview for the DLP policy."
