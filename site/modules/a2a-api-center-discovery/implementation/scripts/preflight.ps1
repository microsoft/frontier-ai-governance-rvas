[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter(Mandatory)]
    [ValidateSet("git", "api-management")]
    [string]$SourceIntegration,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$RuntimeSourceReference
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Get-Command Get-Date -ErrorAction SilentlyContinue)) {
    throw "PowerShell core commands are unavailable."
}
if (-not (Test-Path -LiteralPath $PSScriptRoot -PathType Container)) {
    throw "The module script directory is unavailable."
}
if ($TargetScope -ne "one-approved-a2a-discovery-asset") {
    throw "TargetScope must be 'one-approved-a2a-discovery-asset'."
}
if ($RuntimeSourceReference -match "__REQUIRED_[A-Z0-9_]+__") {
    throw "Resolve every __REQUIRED_ source reference before discovery setup."
}
if (-not [uri]::TryCreate($RuntimeSourceReference, [UriKind]::Absolute, [ref]$null)) {
    throw "RuntimeSourceReference must be an absolute URI."
}
if ($RuntimeSourceReference -match 'https?://[^/\s:@]+:[^/\s@]+@') {
    throw "RuntimeSourceReference must not contain embedded credentials."
}

Write-Host "PASS: the selected API Center source integration and runtime-owned source reference are ready for the live platform check."
