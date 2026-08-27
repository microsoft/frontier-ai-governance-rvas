[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter()]
    [scriptblock]$PreviewCommand
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = Join-Path $PSScriptRoot "..\artifacts"
$deploymentInputsPath = Join-Path $artifactRoot "deployment-inputs.json"
$requiredSentinels = @(
    "__REQUIRED_DEPLOYMENT_NAME__"
    "__REQUIRED_OWNER__"
    "__REQUIRED_PREVIEW_CAPABILITY__"
    "__REQUIRED_TARGET_SCOPE__"
)
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required. Replace this check if the implementation uses another tool."
}
if (-not (Test-Path $artifactRoot -PathType Container)) {
    throw "Required implementation artifacts folder is missing: $artifactRoot"
}
if (-not (Test-Path $deploymentInputsPath -PathType Leaf)) {
    throw "Required deployment inputs are missing: $deploymentInputsPath"
}
$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinels) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    $message = "Resolve every required customer decision in implementation/artifacts before deployment."
    if ($unknown) {
        $message += " Add explicit checks for new sentinels: $($unknown -join ', ')."
    }
    throw $message
}

$deploymentInputs = Get-Content -LiteralPath $deploymentInputsPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]::IsNullOrWhiteSpace([string]$deploymentInputs.deploymentName)) {
    throw "deploymentName must identify the approved deployment."
}
if ([string]::IsNullOrWhiteSpace([string]$deploymentInputs.owner)) {
    throw "owner must identify the team responsible for the deployed state."
}
if ([string]$deploymentInputs.targetScope -ne $TargetScope) {
    throw "Target scope does not match the approved scope in deployment-inputs.json."
}
if ([string]$deploymentInputs.previewSupported -notin @("Supported", "NotSupported")) {
    throw "previewSupported must be Supported or NotSupported."
}
if ($deploymentInputs.previewSupported -eq "Supported") {
    if (-not $PreviewCommand) {
        throw "A read-only preview command is required for this target platform."
    }
    & $PreviewCommand
    if (-not $?) {
        throw "The read-only deployment preview failed."
    }
}
else {
    Write-Host "No read-only deployment preview is supported for this target platform."
}

Write-Host "PASS: prerequisites, files, decisions, target scope, and preview gate are ready."
