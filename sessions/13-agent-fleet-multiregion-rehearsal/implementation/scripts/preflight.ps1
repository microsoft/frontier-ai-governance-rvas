[CmdletBinding()]
param(
    [ValidateSet("Decisions", "Ready")]
    [string]$Phase = "Ready",

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedScope,

    [string]$RuntimeDirectory
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

function Require-Value {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Purpose
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or [string]::IsNullOrWhiteSpace([string]$property.Value)) {
        throw "$Purpose is missing $Name."
    }
    return [string]$property.Value
}

function Test-HealthResult {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedStatus,
        [Parameter(Mandatory)]$PathContract,
        [Parameter(Mandatory)]$Expected
    )

    Require-File -Path $Path
    $result = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -ErrorAction Stop
    $required = @{
        implementationSession = "14-agent-fleet-multiregion-rehearsal"
        status = $ExpectedStatus
        region = [string]$PathContract.region
        agentVersion = [string]$Expected.agentVersion
        agentIdentityId = [string]$Expected.agentIdentityId
        gatewayPolicyVersion = [string]$Expected.gatewayPolicyVersion
        endpoint = [string]$PathContract.endpoint
    }
    foreach ($name in $required.Keys) {
        if ([string]$result.$name -cne $required[$name]) {
            throw "Health result field $name does not match the rehearsal contract."
        }
    }
    if ($result.sensitiveInputPresent -ne $false) {
        throw "Health result indicates sensitive input."
    }
    $actualTraceFields = @($result.traceFields)
    foreach ($traceField in @($Expected.requiredTraceFields)) {
        if ([string]$traceField -notin $actualTraceFields) {
            throw "Health result is missing required trace field $traceField."
        }
    }
}

if ($approvedTargetScope -notmatch '^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$') {
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

$coveredDecisionSentinels = @(
    "__REQUIRED_AGENT_IDENTITY_ID__",
    "__REQUIRED_AGENT_VERSION__",
    "__REQUIRED_CUSTOMER_HEALTH_CHECK_BASH_PATH__",
    "__REQUIRED_CUSTOMER_HEALTH_CHECK_POWERSHELL_PATH__",
    "__REQUIRED_CUSTOMER_ROUTING_CONTROL_BASH_PATH__",
    "__REQUIRED_CUSTOMER_ROUTING_CONTROL_POWERSHELL_PATH__",
    "__REQUIRED_DELIVERY_OWNER__",
    "__REQUIRED_GATEWAY_POLICY_VERSION__",
    "__REQUIRED_PRIMARY_GATEWAY_HOST__",
    "__REQUIRED_PRIMARY_REGION__",
    "__REQUIRED_PRIMARY_ROUTING_SELECTOR__",
    "__REQUIRED_RESOURCE_GROUP__",
    "__REQUIRED_ROUTING_OWNER__",
    "__REQUIRED_SECONDARY_GATEWAY_HOST__",
    "__REQUIRED_SECONDARY_REGION__",
    "__REQUIRED_SECONDARY_ROUTING_SELECTOR__",
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
        throw "Preflight has no named coverage for $sentinel."
    }
}
if ($foundSentinels.Count -gt 0) {
    throw "Resolve every named customer decision before a state change."
}

$control = Get-Content -LiteralPath $controlPath -Raw | ConvertFrom-Json -ErrorAction Stop
$regional = Get-Content -LiteralPath $parametersPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ($control.schemaVersion -ne 2 -or $regional.schemaVersion -ne 2 -or
    [string]$control.implementationSession -cne "14-agent-fleet-multiregion-rehearsal" -or
    [string]$regional.implementationSession -cne "14-agent-fleet-multiregion-rehearsal") {
    throw "The rehearsal contracts have an invalid schema or implementationSession marker."
}
if ([string]$control.approvedAzureScope -ine $approvedTargetScope) {
    throw "Approved scope differs from the rehearsal contract."
}
if ($null -eq $control.sourcePaths) {
    throw "control-definition.json is missing sourcePaths."
}

$healthPowerShellPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.healthCheckPowerShell) -Purpose "Customer PowerShell health control"
$routingPowerShellPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.routingControlPowerShell) -Purpose "Customer PowerShell routing control"
$healthBashPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.healthCheckBash) -Purpose "Customer Bash health control"
$routingBashPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.routingControlBash) -Purpose "Customer Bash routing control"
$configuredParametersPath = Resolve-RepoFile -RepositoryRoot $repositoryRoot `
    -RelativePath ([string]$control.sourcePaths.regionalParameters) -Purpose "Regional parameter contract"
if ($configuredParametersPath -ine (Resolve-Path -LiteralPath $parametersPath).Path) {
    throw "regionalParameters must point to region.parameters.json."
}

$primaryRegion = Require-Value -Object $regional.primary -Name "region" -Purpose "Primary path"
$secondaryRegion = Require-Value -Object $regional.secondary -Name "region" -Purpose "Secondary path"
if ($primaryRegion -ieq $secondaryRegion) {
    throw "Primary and secondary regions must differ."
}
$primarySelector = Require-Value -Object $regional.primary -Name "selector" -Purpose "Primary path"
$secondarySelector = Require-Value -Object $regional.secondary -Name "selector" -Purpose "Secondary path"
if ($primarySelector -ieq $secondarySelector) {
    throw "Primary and secondary selectors must differ."
}
foreach ($path in @($regional.primary, $regional.secondary)) {
    $endpoint = Require-Value -Object $path -Name "endpoint" -Purpose "Regional path"
    if ($endpoint -notmatch '^https://[^\s/]+(?:/.*)?$') {
        throw "Regional endpoints must be absolute HTTPS URLs."
    }
}
foreach ($name in @("agentVersion", "agentIdentityId", "gatewayPolicyVersion")) {
    $null = Require-Value -Object $regional.expected -Name $name -Purpose "Expected values"
}
if ($null -eq $regional.expected.requiredTraceFields -or @($regional.expected.requiredTraceFields).Count -eq 0) {
    throw "Expected values must list requiredTraceFields."
}

foreach ($path in @($healthPowerShellPath, $routingPowerShellPath)) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count -gt 0) {
        throw "Customer PowerShell control syntax is invalid: $path"
    }
}
if (Get-Command bash -ErrorAction SilentlyContinue) {
    & bash -n $healthBashPath
    if ($LASTEXITCODE -ne 0) { throw "Customer Bash health control syntax is invalid." }
    & bash -n $routingBashPath
    if ($LASTEXITCODE -ne 0) { throw "Customer Bash routing control syntax is invalid." }
}

if ($Phase -eq "Decisions") {
    Write-Host "PASS: scope, regional contract, and customer controls are ready."
    return
}

if ([string]::IsNullOrWhiteSpace($RuntimeDirectory) -or
    -not (Test-Path -LiteralPath $RuntimeDirectory -PathType Container)) {
    throw "Ready phase requires an existing runtime directory."
}
$runtimePath = (Resolve-Path -LiteralPath $RuntimeDirectory).Path
$repoPrefix = "$([System.IO.Path]::GetFullPath($repositoryRoot))$([System.IO.Path]::DirectorySeparatorChar)"
if ($runtimePath -eq $repositoryRoot -or
    $runtimePath.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Runtime directory must be outside the repository."
}
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Required command is unavailable: az"
}
$account = (& az account show -o json | ConvertFrom-Json -ErrorAction Stop)
if ([string]$account.id -ine $approvedTargetScope.Split("/")[2]) {
    throw "Active Azure subscription differs from the approved scope."
}

$primaryResultPath = Join-Path $runtimePath "s14-primary-active-$PID.json"
try {
    & $healthPowerShellPath -Mode Active -Region $primaryRegion -ResultPath $primaryResultPath
    if (-not $?) { throw "Primary active-path check failed." }
    Test-HealthResult -Path $primaryResultPath -ExpectedStatus "active" `
        -PathContract $regional.primary -Expected $regional.expected
    Write-Host "PASS: the approved primary path is active and matches the contract."
}
finally {
    Remove-Item -LiteralPath $primaryResultPath -Force -ErrorAction SilentlyContinue
}
