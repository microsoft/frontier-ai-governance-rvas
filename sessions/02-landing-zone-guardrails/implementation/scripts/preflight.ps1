[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation,

    [Parameter()]
    [string]$ArtifactsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ArtifactsPath)) {
    $ArtifactsPath = Join-Path $PSScriptRoot "..\artifacts"
}
if (-not (Test-Path -LiteralPath $ArtifactsPath -PathType Container)) {
    throw "Required implementation artifacts folder is missing: $ArtifactsPath"
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required. Install it through the customer-managed tool process."
}

$requiredFiles = @(
    "policy\initiative.bicep"
    "policy\assignment.bicep"
    "policy\guardrail-settings.json"
    "environments\initiative.bicepparam"
    "environments\sandbox.bicepparam"
    "governance\change-reference.md"
)
$requiredSentinels = @(
    "__REQUIRED_PRIMARY_REGION__"
    "__REQUIRED_SECONDARY_REGION__"
    "__REQUIRED_CHANGE_REFERENCE__"
    "__REQUIRED_POLICY_OWNER__"
    "__REQUIRED_RISK_REFERENCE_OR_NONE__"
)

foreach ($relative in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $ArtifactsPath $relative) -PathType Leaf)) {
        throw "Required implementation file is missing: $relative"
    }
}
foreach ($name in @("RVAS_ALLOWED_LOCATIONS_POLICY_ID", "RVAS_REQUIRE_TAG_POLICY_ID")) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
        throw "Set $name from resolve-builtins.ps1 output before deployment."
    }
}

$matches = @(
    Get-ChildItem -LiteralPath $ArtifactsPath -Recurse -File |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__"
)
if ($matches.Count -gt 0) {
    $unresolved = @($matches.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    $message = "Resolve customer decisions before deployment: $($unresolved -join ', ')."
    if ($unknown.Count -gt 0) {
        $message += " Add checks for new sentinels: $($unknown -join ', ')."
    }
    throw $message
}

$settingsPath = Join-Path $ArtifactsPath "policy\guardrail-settings.json"
$settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json -ErrorAction Stop
$requiredTags = @($settings.requiredTagNames | ForEach-Object { ([string]$_).Trim() })
if (
    $settings.implementationSession -ne "02-landing-zone-guardrails" -or
    $requiredTags.Count -eq 0 -or
    @($requiredTags | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0 -or
    @($requiredTags | Sort-Object -Unique).Count -ne $requiredTags.Count
) {
    throw "policy\guardrail-settings.json must contain one nonempty, unique requiredTagNames list and the Session 02 marker."
}
foreach ($relative in @("environments\initiative.bicepparam", "environments\sandbox.bicepparam")) {
    $text = Get-Content -LiteralPath (Join-Path $ArtifactsPath $relative) -Raw
    if (
        $text -notmatch "loadJsonContent\('\.\./policy/guardrail-settings\.json'\)" -or
        $text -notmatch "(?m)^\s*param\s+requiredTagNames\s*=\s*settings\.requiredTagNames\s*$"
    ) {
        throw "$relative must load requiredTagNames from policy\guardrail-settings.json."
    }
}

foreach ($file in @("initiative.bicep", "assignment.bicep")) {
    $path = Join-Path $ArtifactsPath "policy\$file"
    & az bicep build --file $path --stdout | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Bicep build failed: policy\$file"
    }
}

$subscription = & az account show --query "{name:name,id:id}" --output json --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Azure account check failed.`n$($subscription | Out-String)"
}
$scope = & az group show `
    --name $ResourceGroupName `
    --query id `
    --output tsv `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace([string]$scope)) {
    throw "Approved resource group lookup failed: $ResourceGroupName"
}

Write-Host "Preflight target:"
Write-Host "  Subscription:   $($subscription | ConvertFrom-Json | Select-Object -ExpandProperty name)"
Write-Host "  Assignment:     $scope"
Write-Host "  Initiative:     current subscription"

$initiativePreview = & az deployment sub what-if `
    --location $DeploymentLocation `
    --name rvas-s02-initiative-preflight `
    --parameters (Join-Path $ArtifactsPath "environments\initiative.bicepparam") `
    --result-format ResourceIdOnly `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Initiative preview failed.`n$($initiativePreview | Out-String)"
}
Write-Host "Initiative preview:"
$initiativePreview | ForEach-Object { Write-Host $_ }

$initiativeDefinitionId = [Environment]::GetEnvironmentVariable("RVAS_INITIATIVE_DEFINITION_ID")
if ([string]::IsNullOrWhiteSpace($initiativeDefinitionId)) {
    Write-Host "Assignment preview pending. Set RVAS_INITIATIVE_DEFINITION_ID after the initiative deployment, then rerun preflight."
}
else {
    $assignmentPreview = & az deployment group what-if `
        --resource-group $ResourceGroupName `
        --name rvas-s02-assignment-preflight `
        --parameters (Join-Path $ArtifactsPath "environments\sandbox.bicepparam") `
        --result-format ResourceIdOnly `
        --only-show-errors 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Assignment preview failed.`n$($assignmentPreview | Out-String)"
    }
    Write-Host "Assignment preview:"
    $assignmentPreview | ForEach-Object { Write-Host $_ }
}

Write-Host "PASS: tools, files, approved sandbox subscription and resource-group assignment scope, decisions, syntax, and available deployment previews are ready."
