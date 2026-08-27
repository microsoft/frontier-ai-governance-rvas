[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentName = "rvas-s01-baseline",

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
)

foreach ($relative in $requiredFiles) {
    if (-not (Test-Path (Join-Path $ArtifactsPath $relative) -PathType Leaf)) {
        throw "Required implementation file is missing: $relative"
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

$parametersFile = Join-Path $ArtifactsPath "environments\sandbox.bicepparam"
$parametersText = Get-Content -LiteralPath $parametersFile -Raw
$expiryMatch = [regex]::Match(
    $parametersText,
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
    $parametersText,
    "(?m)^\s*param\s+publicNetworkAccess\s*=\s*'([^']+)'\s*$"
)
if (-not $networkMatch.Success -or $networkMatch.Groups[1].Value -notin @("Enabled", "Disabled")) {
    throw "publicNetworkAccess must be either Enabled or Disabled."
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

Write-Host "Preflight target:"
Write-Host "  Subscription:   $($account.name) ($($account.id))"
Write-Host "  Resource group: $ResourceGroupName"
Write-Host "  Location:       $($targetGroup.location)"
Write-Host "  Marker:         implementationSession=$implementationSession"
Write-Host "  Deployment:     $DeploymentName"
Write-Host ""
Write-Host "Bicep deployment preview:"

$previewOutput = & az deployment group what-if `
    --resource-group $ResourceGroupName `
    --name $DeploymentName `
    --parameters $parametersFile `
    --result-format ResourceIdOnly `
    --only-show-errors 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Bicep deployment preview failed.`n$($previewOutput | Out-String)"
}

$previewOutput | Write-Output
Write-Host "READY: tools, files, decisions, approved sandbox subscription and resource group, and deployment preview are available."
