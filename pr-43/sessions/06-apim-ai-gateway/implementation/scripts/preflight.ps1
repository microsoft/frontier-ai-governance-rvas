[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidatePattern("^https://")]
    [string]$PrimaryAgentBaseUrl,

    [Parameter()]
    [ValidatePattern("^$|^https://")]
    [string]$SecondaryAgentBaseUrl = "",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$DesignRecordPath = (Join-Path $PSScriptRoot "..\artifacts\gateway-design-record.json")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$namedSentinels = @(
    "__REQUIRED_AGENT_NAME__",
    "__REQUIRED_APIM_DEPLOYMENT_MODEL__",
    "__REQUIRED_APIM_INSTANCE__",
    "__REQUIRED_APIM_NAME__",
    "__REQUIRED_APIM_TIER__",
    "__REQUIRED_APIM_VIRTUAL_NETWORK_TYPE__",
    "__REQUIRED_API_AUDIENCE__",
    "__REQUIRED_API_PRODUCT_OWNER__",
    "__REQUIRED_APPROVED_ENDPOINT_REFERENCE__",
    "__REQUIRED_APPROVED_SCOPE__",
    "__REQUIRED_APP_INSIGHTS_LOGGER_NAME__",
    "__REQUIRED_APP_ROLE__",
    "__REQUIRED_BACKEND_IDENTITY__",
    "__REQUIRED_BACKEND_NETWORK_PATH__",
    "__REQUIRED_BACKEND_ROLE_STATE__",
    "__REQUIRED_CHANGE_REFERENCE__",
    "__REQUIRED_CLIENT_APPLICATION_ID__",
    "__REQUIRED_CLIENT_IDENTITY__",
    "__REQUIRED_CONTENT_SAFETY_BACKEND_ID__",
    "__REQUIRED_CONTENT_SAFETY_DECISION__",
    "__REQUIRED_CONTENT_SAFETY_PUBLIC_NETWORK_ACCESS__",
    "__REQUIRED_CONTENT_SAFETY_REFERENCE__",
    "__REQUIRED_CONTENT_SAFETY_RESOURCE_ID__",
    "__REQUIRED_DELIVERY_OWNER__",
    "__REQUIRED_DESIGN_APPROVER__",
    "__REQUIRED_ENTRA_TENANT_ID__",
    "__REQUIRED_ENVIRONMENT__",
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__",
    "__REQUIRED_FOUNDRY_PROJECT_NAME__",
    "__REQUIRED_FOUNDRY_PUBLIC_NETWORK_ACCESS__",
    "__REQUIRED_GAP_OWNER__",
    "__REQUIRED_GAP_RESOLUTION__",
    "__REQUIRED_IDENTITY_OWNER__",
    "__REQUIRED_IMPLEMENTATION_VARIANT__",
    "__REQUIRED_INBOUND_NETWORK_PATH__",
    "__REQUIRED_INGRESS_PATTERN__",
    "__REQUIRED_NETWORK_OWNER__",
    "__REQUIRED_OPERATIONS_OWNER__",
    "__REQUIRED_PLATFORM_OWNER__",
    "__REQUIRED_PRIVATE_DNS_STATE__",
    "__REQUIRED_PRODUCT_OWNER__",
    "__REQUIRED_READINESS_GAP_DESCRIPTION__",
    "__REQUIRED_RECORD_STATUS__",
    "__REQUIRED_REQUEST_LIMIT__",
    "__REQUIRED_RESOURCE_GROUP_NAME__",
    "__REQUIRED_RESTORE_DECISION__",
    "__REQUIRED_ROUTING_DECISION__",
    "__REQUIRED_SAFETY_OWNER__",
    "__REQUIRED_SAFETY_POLICY__",
    "__REQUIRED_TARGET_BACKEND_TYPE__",
    "__REQUIRED_TELEMETRY_BODY_POLICY__",
    "__REQUIRED_TELEMETRY_SINK__",
    "__REQUIRED_TOKEN_LIMIT_DECISION__"
)
if (-not (Test-Path -LiteralPath $DesignRecordPath -PathType Leaf)) {
    throw "The gateway design record is missing: $DesignRecordPath"
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required."
}
$artifactRoot = Join-Path $PSScriptRoot "..\artifacts"
$foundSentinels = @(
    Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches |
        ForEach-Object { $_.Matches.Value } |
        Sort-Object -Unique
)
foreach ($sentinel in $foundSentinels) {
    if ($sentinel -notin $namedSentinels) {
        throw "Preflight has no named coverage for $sentinel."
    }
}
if ($foundSentinels.Count -gt 0) {
    throw "Resolve every __REQUIRED_*__ decision before deployment."
}

& (Join-Path $PSScriptRoot "preflight-design.ps1") -DesignRecordPath $DesignRecordPath
& (Join-Path $PSScriptRoot "preflight-implementation.ps1") `
    -ApprovedSubscriptionId $ApprovedSubscriptionId `
    -PrimaryAgentBaseUrl $PrimaryAgentBaseUrl `
    -SecondaryAgentBaseUrl $SecondaryAgentBaseUrl `
    -DesignRecordPath $DesignRecordPath
