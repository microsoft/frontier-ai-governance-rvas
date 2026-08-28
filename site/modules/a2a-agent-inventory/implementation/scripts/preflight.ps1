[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter(Mandatory)]
    [ValidateSet("built-in", "registry-sync", "sdk")]
    [string]$IntegrationPath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$RuntimeSourceReference,

    [string]$RegistrySyncPlatform
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$requiredTargetScope = "one-approved-a2a-agent"
$supportedRegistrySyncPlatforms = @(
    "Amazon Bedrock",
    "Anthropic Claude Managed Agents",
    "Databricks Genie",
    "Google Vertex AI",
    "Oracle Generative AI Agents",
    "Salesforce Agentforce"
)

if (-not (Get-Command Get-Date -ErrorAction SilentlyContinue)) {
    throw "PowerShell core commands are unavailable."
}
if (-not (Test-Path -LiteralPath $PSScriptRoot -PathType Container)) {
    throw "The module script directory is unavailable."
}
if ($TargetScope -ne $requiredTargetScope) {
    throw "TargetScope must be '$requiredTargetScope'."
}
if ($RuntimeSourceReference -match "__REQUIRED_[A-Z0-9_]+__") {
    throw "Resolve every __REQUIRED_ source reference before onboarding."
}
if (-not [uri]::TryCreate($RuntimeSourceReference, [UriKind]::Absolute, [ref]$null)) {
    throw "RuntimeSourceReference must be an absolute URI."
}
if ($RuntimeSourceReference -match 'https?://[^/\s:@]+:[^/\s@]+@') {
    throw "RuntimeSourceReference must not contain embedded credentials."
}
if ($IntegrationPath -eq "registry-sync") {
    if ([string]::IsNullOrWhiteSpace($RegistrySyncPlatform)) {
        throw "RegistrySyncPlatform is required when IntegrationPath is registry-sync."
    }
    if ($RegistrySyncPlatform -notin $supportedRegistrySyncPlatforms) {
        throw "RegistrySyncPlatform is not currently supported by this module."
    }
}
elseif (-not [string]::IsNullOrWhiteSpace($RegistrySyncPlatform)) {
    throw "RegistrySyncPlatform is valid only when IntegrationPath is registry-sync."
}

Write-Host "PASS: the selected Agent 365 onboarding path and runtime-owned source reference are ready for the live platform check."
