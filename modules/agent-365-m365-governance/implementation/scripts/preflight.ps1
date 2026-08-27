[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$approvedTargetScope = "nonproduction-agent365-m365-pilot"
$requiredFiles = @(
    "governance\agent-inventory-template.csv",
    "governance\agent-publishing-approval-checklist.md",
    "identity\entra-agent-id-policy-template.json",
    "connectors\connector-governance-matrix.csv",
    "data\sharepoint-oversharing-assessment.md",
    "defender\agent-security-hunting-queries.kql"
)
$requiredSentinels = @(
    "__REQUIRED_ACCESS_SCOPE_ALIAS__",
    "__REQUIRED_ADVANCED_CONNECTOR_POLICY_ALIAS__",
    "__REQUIRED_AGENT_ALIAS__",
    "__REQUIRED_AGENT_MAP_NODE_ID__",
    "__REQUIRED_AGENT_OWNER_ROLE__",
    "__REQUIRED_AGENT_REGISTRY_ID__",
    "__REQUIRED_AGENT_SPONSOR_ROLE__",
    "__REQUIRED_AUTHENTICATION_MODE__",
    "__REQUIRED_BROAD_LINK_DECISION__",
    "__REQUIRED_CONDITIONAL_ACCESS_POLICY_NAME__",
    "__REQUIRED_CONNECTOR_ALIAS__",
    "__REQUIRED_CONNECTOR_OWNER_ROLE__",
    "__REQUIRED_DATA_MOVEMENT_CLASSIFICATION__",
    "__REQUIRED_DATA_OWNER_ROLE__",
    "__REQUIRED_DLP_POLICY_ALIAS__",
    "__REQUIRED_EEEU_DECISION__",
    "__REQUIRED_ENTRA_AGENT_ID__",
    "__REQUIRED_GROUNDING_ACCESS_DECISION__",
    "__REQUIRED_GROUNDING_SOURCE_ALIAS__",
    "__REQUIRED_IDENTITY_OWNER_ROLE__",
    "__REQUIRED_PUBLISHING_APPROVER_ROLE__",
    "__REQUIRED_RETIREMENT_REVIEW_DATE__",
    "__REQUIRED_REVIEW_DATE__",
    "__REQUIRED_SENSITIVE_CONTENT_DECISION__",
    "__REQUIRED_SHAREPOINT_OWNER_ROLE__",
    "__REQUIRED_STALE_ACCESS_DECISION__"
)

foreach ($command in @("python3")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required."
    }
}

foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $artifactRoot $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required module artifact is missing: $path"
    }
}

$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinels.Count -gt 0) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Agent 365 module preflight checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every Agent 365 governance decision before owner review: $($unresolved -join ', ')"
}

$identityPath = Join-Path $artifactRoot "identity\entra-agent-id-policy-template.json"
$identity = Get-Content -LiteralPath $identityPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$identity.implementationModule -ne "agent-365-m365-governance") {
    throw "The Entra Agent ID policy template has the wrong implementationModule marker."
}
if ([string]$identity.conditionalAccess.mode -ne "ReportOnly") {
    throw "The module starts Conditional Access in ReportOnly mode."
}

Write-Host "PASS: Agent 365 governance artifacts are present for approved target scope '$approvedTargetScope' and customer decisions are resolved."
