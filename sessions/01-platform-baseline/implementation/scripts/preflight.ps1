[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentName = "rvas-s01-baseline",

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation,

    [Parameter()]
    [string]$ArtifactsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$implementationSession = "01-platform-baseline"
if ([string]::IsNullOrWhiteSpace($ArtifactsPath)) {
    $ArtifactsPath = Join-Path $PSScriptRoot "..\artifacts"
}

if (-not (Test-Path -LiteralPath $ArtifactsPath -PathType Container)) {
    throw "Implementation artifacts folder is missing: $ArtifactsPath"
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required. Install it through the customer-managed tool process."
}

$requiredFiles = @(
    "infra\foundry\main.bicep"
    "environments\sandbox.bicepparam"
    "decisions\resource-model.md"
    "policy\initiative.bicep"
    "policy\assignment.bicep"
    "policy\guardrail-settings.json"
    "environments\initiative.bicepparam"
    "environments\policy-assignment.bicepparam"
    "governance\change-reference.md"
)
$requiredSentinels = @(
    "__REQUIRED_AZURE_REGION__"
    "__REQUIRED_PUBLIC_NETWORK_ACCESS__"
    "__REQUIRED_BUSINESS_OWNER__"
    "__REQUIRED_TECHNICAL_OWNER__"
    "__REQUIRED_DATA_CLASSIFICATION__"
    "__REQUIRED_CRITICALITY__"
    "__REQUIRED_COST_CENTER__"
    "__REQUIRED_EXPIRY_DATE__"
    "__REQUIRED_RESOURCE_MODEL_DECISION__"
    "__REQUIRED_CUSTOMER_SYSTEM_REFERENCE__"
    "__REQUIRED_PRIMARY_REGION__"
    "__REQUIRED_SECONDARY_REGION__"
    "__REQUIRED_CHANGE_REFERENCE__"
    "__REQUIRED_POLICY_OWNER__"
    "__REQUIRED_RISK_REFERENCE_OR_NONE__"
)

foreach ($relative in $requiredFiles) {
    if (-not (Test-Path (Join-Path $ArtifactsPath $relative) -PathType Leaf)) {
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

$foundryParametersFile = Join-Path $ArtifactsPath "environments\sandbox.bicepparam"
$foundryParametersText = Get-Content -LiteralPath $foundryParametersFile -Raw
$expiryMatch = [regex]::Match(
    $foundryParametersText,
    "(?m)^\s*param\s+expiryDate\s*=\s*'([^']+)'\s*$"
)
if (-not $expiryMatch.Success) {
    throw "sandbox.bicepparam must assign expiryDate as a quoted ISO date."
}

$parsedExpiry = [datetime]::MinValue
if (-not [datetime]::TryParseExact(
    $expiryMatch.Groups[1].Value,
    "yyyy-MM-dd",
    [System.Globalization.CultureInfo]::InvariantCulture,
    [System.Globalization.DateTimeStyles]::None,
    [ref]$parsedExpiry
)) {
    throw "expiryDate must use ISO yyyy-MM-dd format."
}

$networkMatch = [regex]::Match(
    $foundryParametersText,
    "(?m)^\s*param\s+publicNetworkAccess\s*=\s*'([^']+)'\s*$"
)
if (-not $networkMatch.Success -or $networkMatch.Groups[1].Value -notin @("Enabled", "Disabled")) {
    throw "publicNetworkAccess must be either Enabled or Disabled."
}

$settingsPath = Join-Path $ArtifactsPath "policy\guardrail-settings.json"
$settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json -ErrorAction Stop
$requiredTags = @($settings.requiredTagNames | ForEach-Object { ([string]$_).Trim() })
if (
    $settings.implementationSession -ne $implementationSession -or
    $requiredTags.Count -eq 0 -or
    @($requiredTags | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0 -or
    @($requiredTags | Sort-Object -Unique).Count -ne $requiredTags.Count
) {
    throw "policy\guardrail-settings.json must contain one nonempty, unique requiredTagNames list and the $implementationSession marker."
}
foreach ($relative in @("environments\initiative.bicepparam", "environments\policy-assignment.bicepparam")) {
    $text = Get-Content -LiteralPath (Join-Path $ArtifactsPath $relative) -Raw
    if (
        $text -notmatch "loadJsonContent\('\.\./policy/guardrail-settings\.json'\)" -or
        $text -notmatch "(?m)^\s*param\s+requiredTagNames\s*=\s*settings\.requiredTagNames\s*$"
    ) {
        throw "$relative must load requiredTagNames from policy\guardrail-settings.json."
    }
}

$accountJson = & az account show --only-show-errors --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Azure account lookup failed.`n$($accountJson | Out-String)"
}
$account = ($accountJson | Out-String) | ConvertFrom-Json

$groupJson = & az group show `
    --name $ResourceGroupName `
    --query "{id:id,location:location,marker:tags.implementationSession}" `
    --only-show-errors `
    --output json 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "The approved sandbox resource group lookup failed.`n$($groupJson | Out-String)"
}
$targetGroup = ($groupJson | Out-String) | ConvertFrom-Json
if ([string]$targetGroup.marker -ne $implementationSession) {
    throw "Resource group '$ResourceGroupName' must have implementationSession=$implementationSession."
}

$providers = @(
    "Microsoft.CognitiveServices"
    "Microsoft.Insights"
    "Microsoft.OperationalInsights"
    "Microsoft.PolicyInsights"
)
foreach ($provider in $providers) {
    $stateOutput = & az provider show `
        --namespace $provider `
        --query registrationState `
        --only-show-errors `
        --output tsv 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Provider lookup failed for $provider.`n$($stateOutput | Out-String)"
    }

    $state = ($stateOutput | Out-String).Trim()
    if ($state -ne "Registered") {
        throw "Provider $provider is '$state'. Register it only through the customer-approved change process."
    }
}

$templateFile = Join-Path $ArtifactsPath "infra\foundry\main.bicep"
& az bicep build --file $templateFile --stdout | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Bicep build failed for the Foundry baseline."
}
foreach ($file in @("initiative.bicep", "assignment.bicep")) {
    $policyFile = Join-Path $ArtifactsPath "policy\$file"
    & az bicep build --file $policyFile --stdout | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Bicep build failed: policy\$file"
    }
}

Write-Host "Preflight target:"
Write-Host "  Subscription:   $($account.name) ($($account.id))"
Write-Host "  Resource group: $ResourceGroupName"
Write-Host "  Location:       $($targetGroup.location)"
Write-Host "  Marker:         implementationSession=$implementationSession"
Write-Host "  Deployment:     $DeploymentName"
Write-Host ""
Write-Host "Foundry baseline deployment preview:"

$foundryPreview = & az deployment group what-if `
    --resource-group $ResourceGroupName `
    --name $DeploymentName `
    --parameters $foundryParametersFile `
    --result-format ResourceIdOnly `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Foundry baseline deployment preview failed.`n$($foundryPreview | Out-String)"
}
$foundryPreview | Write-Output

Write-Host ""
Write-Host "Policy initiative deployment preview:"
$initiativePreview = & az deployment sub what-if `
    --location $DeploymentLocation `
    --name rvas-s01-guardrails-initiative-preflight `
    --parameters (Join-Path $ArtifactsPath "environments\initiative.bicepparam") `
    --result-format ResourceIdOnly `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Initiative preview failed.`n$($initiativePreview | Out-String)"
}
$initiativePreview | Write-Output

$initiativeDefinitionId = [Environment]::GetEnvironmentVariable("RVAS_INITIATIVE_DEFINITION_ID")
if ([string]::IsNullOrWhiteSpace($initiativeDefinitionId)) {
    Write-Host "Assignment preview pending. Set RVAS_INITIATIVE_DEFINITION_ID after the initiative deployment, then rerun preflight."
}
else {
    Write-Host ""
    Write-Host "Policy assignment deployment preview:"
    $assignmentPreview = & az deployment group what-if `
        --resource-group $ResourceGroupName `
        --name rvas-s01-guardrails-assignment-preflight `
        --parameters (Join-Path $ArtifactsPath "environments\policy-assignment.bicepparam") `
        --result-format ResourceIdOnly `
        --only-show-errors 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Assignment preview failed.`n$($assignmentPreview | Out-String)"
    }
    $assignmentPreview | Write-Output
}

Write-Host ""
Write-Host "READY: tools, files, decisions, approved sandbox subscription and resource group, provider registrations, and every available deployment preview are ready."
