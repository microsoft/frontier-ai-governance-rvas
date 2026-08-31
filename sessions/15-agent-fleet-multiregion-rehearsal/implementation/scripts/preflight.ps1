[CmdletBinding()]
param(
    [ValidateSet("Decisions", "Ready")]
    [string]$Phase = "Ready",

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedScope
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$approvedTargetScope = $ApprovedScope

function Require-File {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
}

function Invoke-Az {
    param([Parameter(Mandatory)][string[]]$Arguments)
    & az @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI command failed: az $($Arguments -join ' ')"
    }
}

function Resolve-RepoFile {
    param(
        [Parameter(Mandatory)][string]$RepositoryRoot,
        [Parameter(Mandatory)][string]$RelativePath,
        [Parameter(Mandatory)][string]$Purpose
    )

    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "$Purpose must be repository-relative."
    }
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $RelativePath))
    $rootPrefix = "$([System.IO.Path]::GetFullPath($RepositoryRoot))$([System.IO.Path]::DirectorySeparatorChar)"
    if (-not $candidate.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "$Purpose is missing or resolves outside the repository."
    }
    return $candidate
}

function Get-ParameterValue {
    param(
        [Parameter(Mandatory)]$Parameters,
        [Parameter(Mandatory)][string]$Name
    )

    $property = $Parameters.PSObject.Properties[$Name]
    if ($null -eq $property -or [string]::IsNullOrWhiteSpace([string]$property.Value.value)) {
        throw "region.parameters.json is missing a usable $Name value."
    }
    return [string]$property.Value.value
}

if ($ApprovedTargetScope -notmatch '^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$') {
    throw "Approved scope must be an exact Azure resource-group resource ID."
}

$sessionRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$repositoryRoot = (Resolve-Path (Join-Path $sessionRoot "..\..")).Path
$artifactRoot = Join-Path $sessionRoot "implementation\artifacts"
$controlPath = Join-Path $artifactRoot "control-definition.json"
$parametersPath = Join-Path $artifactRoot "regional\region.parameters.json"
$runbookPath = Join-Path $artifactRoot "regional\failover-runbook.md"

foreach ($path in @($controlPath, $parametersPath, $runbookPath, (Join-Path $artifactRoot "README.md"))) {
    Require-File -Path $path
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Required command is unavailable: az"
}

$coveredDecisionSentinels = @(
    "__REQUIRED_AGENT_IDENTITY_ID__",
    "__REQUIRED_AGENT_VERSION__",
    "__REQUIRED_APPLICATION_INSIGHTS_NAME__",
    "__REQUIRED_CUSTOMER_BICEP_ENTRYPOINT_PATH__",
    "__REQUIRED_CUSTOMER_HEALTH_CHECK_BASH_PATH__",
    "__REQUIRED_CUSTOMER_HEALTH_CHECK_POWERSHELL_PATH__",
    "__REQUIRED_CUSTOMER_ROUTING_CONTROL_BASH_PATH__",
    "__REQUIRED_CUSTOMER_ROUTING_CONTROL_POWERSHELL_PATH__",
    "__REQUIRED_DELIVERY_OWNER__",
    "__REQUIRED_FOUNDRY_ACCOUNT_NAME__",
    "__REQUIRED_FOUNDRY_PROJECT_NAME__",
    "__REQUIRED_GATEWAY_PATTERN_MULTI_REGION_OR_SEPARATE__",
    "__REQUIRED_GATEWAY_POLICY_VERSION__",
    "__REQUIRED_PLATFORM_OWNER__",
    "__REQUIRED_PRIMARY_APIM_SERVICE_NAME__",
    "__REQUIRED_PRIMARY_APIM_TIER__",
    "__REQUIRED_PRIMARY_BACKEND_URL__",
    "__REQUIRED_PRIMARY_GATEWAY_URL__",
    "__REQUIRED_PRIMARY_REGION__",
    "__REQUIRED_PRIMARY_ROUTING_SELECTOR__",
    "__REQUIRED_RESOURCE_GROUP__",
    "__REQUIRED_ROUTING_MODE_EXTERNAL_OR_INTERNAL__",
    "__REQUIRED_SECONDARY_APIM_RESOURCE_ID__",
    "__REQUIRED_SECONDARY_APIM_TIER__",
    "__REQUIRED_SECONDARY_BACKEND_URL__",
    "__REQUIRED_SECONDARY_GATEWAY_URL__",
    "__REQUIRED_SECONDARY_REGION__",
    "__REQUIRED_SECONDARY_ROUTING_SELECTOR__",
    "__REQUIRED_SECURITY_OWNER__",
    "__REQUIRED_SERVICE_OWNER__",
    "__REQUIRED_SUBSCRIPTION_ID__"
)
$foundSentinels = @(
    Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern '__REQUIRED_[A-Z0-9_]+__' -AllMatches |
        ForEach-Object { $_.Matches.Value } |
        Sort-Object -Unique
)
foreach ($sentinel in $foundSentinels) {
    if ($sentinel -notin $coveredDecisionSentinels) {
        throw "Preflight has no named coverage for $sentinel"
    }
}
if ($foundSentinels.Count -gt 0) {
    $locations = Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern '__REQUIRED_[A-Z0-9_]+__' -AllMatches |
        ForEach-Object { "$($_.Path):$($_.LineNumber):$($_.Line.Trim())" }
    $locations | Write-Error
    throw "Resolve every named customer decision before a state change."
}

$control = Get-Content -LiteralPath $controlPath -Raw | ConvertFrom-Json -ErrorAction Stop
$parameterDocument = Get-Content -LiteralPath $parametersPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ($control.schemaVersion -ne 2 -or
    [string]$control.implementationSession -cne "15-agent-fleet-multiregion-rehearsal") {
    throw "control-definition.json has an invalid schema or implementationSession marker."
}
if ([string]$control.approvedAzureScope -ine $ApprovedTargetScope) {
    throw "Approved scope differs from the rehearsal contract."
}
if ($null -eq $control.sourcePaths) {
    throw "control-definition.json is missing sourcePaths."
}

$bicepPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.bicepEntrypoint) -Purpose "Customer Bicep entrypoint"
$healthBashPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.healthCheckBash) -Purpose "Customer Bash health script"
$routingBashPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.routingControlBash) -Purpose "Customer Bash routing script"
$healthPowerShellPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.healthCheckPowerShell) -Purpose "Customer PowerShell health script"
$routingPowerShellPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.routingControlPowerShell) -Purpose "Customer PowerShell routing script"
$configuredParametersPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.regionalParameters) -Purpose "Regional parameter contract"
if ($configuredParametersPath -ine (Resolve-Path -LiteralPath $parametersPath).Path) {
    throw "regionalParameters must point to region.parameters.json."
}

$parameters = $parameterDocument.parameters
$primaryRegion = Get-ParameterValue -Parameters $parameters -Name "primaryRegion"
$secondaryRegion = Get-ParameterValue -Parameters $parameters -Name "secondaryRegion"
if ($primaryRegion -ieq $secondaryRegion) {
    throw "Primary and secondary regions must differ."
}
$primarySelector = Get-ParameterValue -Parameters $parameters -Name "primarySelector"
$secondarySelector = Get-ParameterValue -Parameters $parameters -Name "secondarySelector"
if ($primarySelector -ieq $secondarySelector) {
    throw "Primary and secondary routing selectors must differ."
}
$gatewayPattern = Get-ParameterValue -Parameters $parameters -Name "gatewayPattern"
if ($gatewayPattern -notin @("multi-region-instance", "separate-regional-gateways")) {
    throw "Invalid gatewayPattern."
}
$routingMode = Get-ParameterValue -Parameters $parameters -Name "routingMode"
if ($routingMode -notin @("external", "internal")) {
    throw "Invalid routingMode."
}
$primaryApimResourceId = Get-ParameterValue -Parameters $parameters -Name "primaryApimResourceId"
$secondaryApimResourceId = Get-ParameterValue -Parameters $parameters -Name "secondaryApimResourceId"
$apimPrefix = "$($ApprovedTargetScope.ToLowerInvariant())/providers/microsoft.apimanagement/service/"
foreach ($resourceId in @($primaryApimResourceId, $secondaryApimResourceId)) {
    if (-not $resourceId.ToLowerInvariant().StartsWith($apimPrefix)) {
        throw "API Management resource IDs must remain inside the approved scope."
    }
}
if ($gatewayPattern -eq "multi-region-instance" -and
    ($primaryApimResourceId -ine $secondaryApimResourceId -or
     (Get-ParameterValue -Parameters $parameters -Name "primaryApimTier") -ine "Premium")) {
    throw "A multi-region instance requires one Premium API Management resource ID."
}
if ($gatewayPattern -eq "separate-regional-gateways" -and $primaryApimResourceId -ieq $secondaryApimResourceId) {
    throw "Separate regional gateways require different resource IDs."
}
foreach ($name in @(
        "foundryProjectResourceId", "applicationInsightsResourceId", "agentVersion",
        "agentIdentityId", "gatewayPolicyVersion"
    )) {
    $null = Get-ParameterValue -Parameters $parameters -Name $name
}
foreach ($name in @("primaryGatewayUrl", "secondaryGatewayUrl", "primaryBackendUrl", "secondaryBackendUrl")) {
    if ((Get-ParameterValue -Parameters $parameters -Name $name) -notmatch '^https://[^\s/]+(?:/.*)?$') {
        throw "$name must be an absolute HTTPS URL."
    }
}

if (Get-Command bash -ErrorAction SilentlyContinue) {
    & bash -n $healthBashPath
    if ($LASTEXITCODE -ne 0) { throw "Customer Bash health script syntax is invalid." }
    & bash -n $routingBashPath
    if ($LASTEXITCODE -ne 0) { throw "Customer Bash routing script syntax is invalid." }
}
foreach ($path in @($healthPowerShellPath, $routingPowerShellPath)) {
    $parseTokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        $path, [ref]$parseTokens, [ref]$parseErrors
    ) | Out-Null
    if ($parseErrors.Count -gt 0) {
        throw "Customer PowerShell script syntax is invalid: $path"
    }
}

Invoke-Az -Arguments @("bicep", "lint", "--file", $bicepPath)
Invoke-Az -Arguments @("bicep", "build", "--file", $bicepPath, "--stdout")

if ($Phase -eq "Decisions") {
    Write-Host "PASS: the source-controlled contracts, customer script interfaces, and Bicep checks are ready."
    return
}

$account = (& az account show -o json | ConvertFrom-Json -ErrorAction Stop)
if ([string]$account.id -ine $ApprovedTargetScope.Split("/")[2]) {
    throw "Active Azure subscription differs from the approved scope."
}
$foundryProjectResourceId = Get-ParameterValue -Parameters $parameters -Name "foundryProjectResourceId"
$applicationInsightsResourceId = Get-ParameterValue -Parameters $parameters -Name "applicationInsightsResourceId"
foreach ($resourceId in @($foundryProjectResourceId, $applicationInsightsResourceId)) {
    Invoke-Az -Arguments @("resource", "show", "--ids", $resourceId, "-o", "none")
}
$primary = (& az resource show --ids $primaryApimResourceId -o json | ConvertFrom-Json -ErrorAction Stop)
$secondary = if ($secondaryApimResourceId -ieq $primaryApimResourceId) {
    $primary
} else {
    (& az resource show --ids $secondaryApimResourceId -o json | ConvertFrom-Json -ErrorAction Stop)
}
if ([string]$primary.location -ine $primaryRegion) {
    throw "Primary API Management region differs from the parameter contract."
}
$primaryTier = Get-ParameterValue -Parameters $parameters -Name "primaryApimTier"
$secondaryTier = Get-ParameterValue -Parameters $parameters -Name "secondaryApimTier"
if ([string]$primary.sku.name -ine $primaryTier -or [string]$secondary.sku.name -ine $secondaryTier) {
    throw "Live API Management tier differs from the parameter contract."
}
if ($gatewayPattern -eq "multi-region-instance") {
    $locations = @($primary.properties.additionalLocations | ForEach-Object { [string]$_.location })
    if ([string]$primary.sku.name -ine "Premium" -or $secondaryRegion -notin $locations) {
        throw "The live Premium API Management instance lacks the configured secondary location."
    }
} elseif ([string]$secondary.location -ine $secondaryRegion) {
    throw "Secondary API Management region differs from the parameter contract."
}

Invoke-Az -Arguments @(
    "deployment", "group", "what-if",
    "--subscription", $ApprovedTargetScope.Split("/")[2],
    "--resource-group", $ApprovedTargetScope.Split("/")[4],
    "--name", "s14-regional-preflight",
    "--template-file", $bicepPath,
    "--parameters", "@$parametersPath",
    "--no-pretty-print"
)
Write-Host "PASS: live Azure resources, API Management topology, and the read-only deployment preview are ready."
