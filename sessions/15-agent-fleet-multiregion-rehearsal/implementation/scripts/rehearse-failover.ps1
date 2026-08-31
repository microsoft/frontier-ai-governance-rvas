[CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedScope,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ChangeRecordId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$RuntimeDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoFile {
    param([Parameter(Mandatory)][string]$RelativePath)

    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "Customer script paths must be repository-relative."
    }
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $RelativePath))
    $rootPrefix = "$([System.IO.Path]::GetFullPath($repoRoot))$([System.IO.Path]::DirectorySeparatorChar)"
    if (-not $candidate.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "Customer script is missing or resolves outside the repository: $RelativePath"
    }
    return $candidate
}

function Read-HealthResult {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedStatus,
        [Parameter(Mandatory)][string]$ExpectedRegion,
        [Parameter(Mandatory)][pscustomobject]$Regional
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Customer health script did not write its required JSON result."
    }
    $result = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -ErrorAction Stop
    if ([string]$result.implementationSession -cne "15-agent-fleet-multiregion-rehearsal" -or
        [string]$result.status -cne $ExpectedStatus -or
        [string]$result.region -ine $ExpectedRegion -or
        [string]$result.agentVersion -cne [string]$Regional.agentVersion -or
        [string]$result.agentIdentityId -cne [string]$Regional.agentIdentityId -or
        [string]$result.gatewayPolicyVersion -cne [string]$Regional.gatewayPolicyVersion -or
        [string]$result.endpointStatus -cne "passed" -or
        [string]$result.identityStatus -cne "passed" -or
        [string]$result.policyStatus -cne "passed" -or
        [string]$result.traceStatus -cne "passed" -or
        $result.sensitiveInputPresent -ne $false) {
        throw "Health result does not match the approved regional control contract."
    }
}

$sessionRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$repoRoot = (Resolve-Path (Join-Path $sessionRoot "..\..")).Path
$controlPath = Join-Path $sessionRoot "implementation\artifacts\control-definition.json"
$preflightPath = Join-Path $PSScriptRoot "preflight.ps1"

if ($ApprovedScope -notmatch '^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$') {
    throw "Approved scope must be an exact Azure resource-group resource ID."
}
if (-not (Test-Path -LiteralPath $RuntimeDirectory -PathType Container)) {
    throw "Runtime directory must already exist."
}
$runtimePath = (Resolve-Path -LiteralPath $RuntimeDirectory).Path
$repoPrefix = "$([System.IO.Path]::GetFullPath($repoRoot))$([System.IO.Path]::DirectorySeparatorChar)"
if ($runtimePath -eq $repoRoot -or $runtimePath.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Runtime directory must be outside the repository."
}

& $preflightPath -Phase Ready -ApprovedScope $ApprovedScope
if (-not $?) {
    throw "Ready preflight failed."
}

$control = Get-Content -LiteralPath $controlPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$control.implementationSession -cne "15-agent-fleet-multiregion-rehearsal" -or
    [string]$control.approvedAzureScope -ine $ApprovedScope) {
    throw "Control marker or approved scope differs from the rehearsal request."
}
$parameterPath = Resolve-RepoFile ([string]$control.sourcePaths.regionalParameters)
$parameterDocument = Get-Content -LiteralPath $parameterPath -Raw | ConvertFrom-Json -ErrorAction Stop
$regional = [pscustomobject]@{
    secondaryRegion = $parameterDocument.parameters.secondaryRegion.value
    primarySelector = $parameterDocument.parameters.primarySelector.value
    secondarySelector = $parameterDocument.parameters.secondarySelector.value
    agentVersion = $parameterDocument.parameters.agentVersion.value
    agentIdentityId = $parameterDocument.parameters.agentIdentityId.value
    gatewayPolicyVersion = $parameterDocument.parameters.gatewayPolicyVersion.value
}
if ([string]::IsNullOrWhiteSpace([string]$regional.primarySelector) -or
    [string]::IsNullOrWhiteSpace([string]$regional.secondarySelector) -or
    [string]$regional.primarySelector -ieq [string]$regional.secondarySelector) {
    throw "Primary and secondary routing selectors must be nonempty and distinct."
}

$healthScript = Resolve-RepoFile ([string]$control.sourcePaths.healthCheckPowerShell)
$routingScript = Resolve-RepoFile ([string]$control.sourcePaths.routingControlPowerShell)
$secondaryReadinessPath = Join-Path $runtimePath "s14-secondary-ready-$PID.json"
$secondaryActivePath = Join-Path $runtimePath "s14-secondary-active-$PID.json"

try {
    & $healthScript -Mode Readiness -Region ([string]$regional.secondaryRegion) -ResultPath $secondaryReadinessPath
    if (-not $?) { throw "Secondary readiness check failed." }
    Read-HealthResult -Path $secondaryReadinessPath -ExpectedStatus "ready" `
        -ExpectedRegion ([string]$regional.secondaryRegion) -Regional $regional

    & $routingScript -Mode Preview -FromSelector ([string]$regional.primarySelector) `
        -ToSelector ([string]$regional.secondarySelector) -ApprovedScope $ApprovedScope `
        -ChangeRecordId $ChangeRecordId
    if (-not $?) { throw "Customer routing preview failed." }

    $target = "$([string]$regional.secondarySelector) in $([string]$regional.secondaryRegion)"
    if (-not $PSCmdlet.ShouldProcess($target, "Move the governed agent traffic selector")) {
        return
    }

    & $routingScript -Mode Failover -FromSelector ([string]$regional.primarySelector) `
        -ToSelector ([string]$regional.secondarySelector) -ApprovedScope $ApprovedScope `
        -ChangeRecordId $ChangeRecordId
    if (-not $?) { throw "Customer routing failover failed. Use the approved routing restore path if traffic moved partially." }

    & $healthScript -Mode Active -Region ([string]$regional.secondaryRegion) -ResultPath $secondaryActivePath
    if (-not $?) { throw "Secondary active-path check failed. Use the approved routing restore path." }
    Read-HealthResult -Path $secondaryActivePath -ExpectedStatus "active" `
        -ExpectedRegion ([string]$regional.secondaryRegion) -Regional $regional

    Write-Host "PASS: the governed agent is active through the secondary selector with the expected identity, policy, version, and trace."
    Write-Host "Record the result in customer change record $ChangeRecordId."
}
finally {
    Remove-Item -LiteralPath $secondaryReadinessPath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $secondaryActivePath -Force -ErrorAction SilentlyContinue
}
