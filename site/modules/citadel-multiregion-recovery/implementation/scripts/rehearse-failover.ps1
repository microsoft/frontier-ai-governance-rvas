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
        throw "Customer control paths must be repository-relative."
    }
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $RelativePath))
    $rootPrefix = "$([System.IO.Path]::GetFullPath($repoRoot))$([System.IO.Path]::DirectorySeparatorChar)"
    if (-not $candidate.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "Customer control is missing or resolves outside the repository: $RelativePath"
    }
    return $candidate
}

function Test-HealthResult {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$ExpectedStatus,
        [Parameter(Mandatory)]$PathContract,
        [Parameter(Mandatory)]$Expected
    )

    $result = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -ErrorAction Stop
    $required = @{
        implementationSession = "optional-module-citadel-multiregion-recovery"
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
    foreach ($traceField in @($Expected.requiredTraceFields)) {
        if ([string]$traceField -notin @($result.traceFields)) {
            throw "Health result is missing required trace field $traceField."
        }
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

& $preflightPath -Phase Ready -ApprovedScope $ApprovedScope -RuntimeDirectory $runtimePath
if (-not $?) { throw "Ready preflight failed." }

$control = Get-Content -LiteralPath $controlPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$control.implementationSession -cne "optional-module-citadel-multiregion-recovery" -or
    [string]$control.approvedAzureScope -ine $ApprovedScope) {
    throw "Control marker or approved scope differs from the rehearsal request."
}
$parameterPath = Resolve-RepoFile ([string]$control.sourcePaths.regionalParameters)
$regional = Get-Content -LiteralPath $parameterPath -Raw | ConvertFrom-Json -ErrorAction Stop
$healthControl = Resolve-RepoFile ([string]$control.sourcePaths.healthCheckPowerShell)
$routingControl = Resolve-RepoFile ([string]$control.sourcePaths.routingControlPowerShell)

$secondaryReadyPath = Join-Path $runtimePath "s13-secondary-ready-$PID.json"
$secondaryActivePath = Join-Path $runtimePath "s13-secondary-active-$PID.json"
$primaryRestoredPath = Join-Path $runtimePath "s13-primary-restored-$PID.json"
try {
    & $healthControl -Mode Readiness -Region ([string]$regional.secondary.region) -ResultPath $secondaryReadyPath
    if (-not $?) { throw "Secondary readiness check failed." }
    Test-HealthResult -Path $secondaryReadyPath -ExpectedStatus "ready" `
        -PathContract $regional.secondary -Expected $regional.expected

    & $routingControl -Mode Preview -FromSelector ([string]$regional.primary.selector) `
        -ToSelector ([string]$regional.secondary.selector) -ApprovedScope $ApprovedScope `
        -ChangeRecordId $ChangeRecordId
    if (-not $?) { throw "Primary-to-secondary routing preview failed." }
    if (-not $PSCmdlet.ShouldProcess([string]$regional.secondary.selector, "Move the approved traffic selector")) {
        return
    }
    & $routingControl -Mode Failover -FromSelector ([string]$regional.primary.selector) `
        -ToSelector ([string]$regional.secondary.selector) -ApprovedScope $ApprovedScope `
        -ChangeRecordId $ChangeRecordId
    if (-not $?) { throw "Selector move failed. Use the approved restore path if traffic moved partially." }

    & $healthControl -Mode Active -Region ([string]$regional.secondary.region) -ResultPath $secondaryActivePath
    if (-not $?) { throw "Secondary active-path check failed. Use the approved restore path." }
    Test-HealthResult -Path $secondaryActivePath -ExpectedStatus "active" `
        -PathContract $regional.secondary -Expected $regional.expected

    & $routingControl -Mode Preview -FromSelector ([string]$regional.secondary.selector) `
        -ToSelector ([string]$regional.primary.selector) -ApprovedScope $ApprovedScope `
        -ChangeRecordId $ChangeRecordId
    if (-not $?) { throw "Secondary-to-primary routing preview failed." }
    if (-not $PSCmdlet.ShouldProcess([string]$regional.primary.selector, "Restore the approved traffic selector")) {
        return
    }
    & $routingControl -Mode Restore -FromSelector ([string]$regional.secondary.selector) `
        -ToSelector ([string]$regional.primary.selector) -ApprovedScope $ApprovedScope `
        -ChangeRecordId $ChangeRecordId
    if (-not $?) { throw "Primary restore failed. Use the approved restore path." }

    & $healthControl -Mode Active -Region ([string]$regional.primary.region) -ResultPath $primaryRestoredPath
    if (-not $?) { throw "Restored primary active-path check failed." }
    Test-HealthResult -Path $primaryRestoredPath -ExpectedStatus "active" `
        -PathContract $regional.primary -Expected $regional.expected

    Write-Host "PASS: secondary matched the contract. Primary was restored and checked."
    Write-Host "Record the result in customer change record $ChangeRecordId."
}
finally {
    Remove-Item -LiteralPath $secondaryReadyPath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $secondaryActivePath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $primaryRestoredPath -Force -ErrorAction SilentlyContinue
}
