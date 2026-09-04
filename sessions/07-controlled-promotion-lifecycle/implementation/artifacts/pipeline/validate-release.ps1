[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("Static", "Dependencies", "Intended", "Blocked", "Smoke", "CreateManifest")]
    [string]$Mode = "Static",

    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-f]{40}$")]
    [string]$ReleaseSha,

    [Parameter()]
    [string]$SmokeResultPath,

    [Parameter()]
    [string]$BaselineRecordPath,

    [Parameter()]
    [string]$CandidateRecordPath,

    [Parameter()]
    [string]$SecurityReleaseAttestationPath,

    [Parameter()]
    [string]$RuntimeValuesPath,

    [Parameter()]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sessionRoot = Resolve-Path (Join-Path $artifactRoot "..\..")
$repoRoot = Resolve-Path (Join-Path $sessionRoot "..\..")
$controlPath = Join-Path $artifactRoot "control-definition.json"
$nonproductionParametersPath = Join-Path $artifactRoot "environments\nonproduction.parameters.json"
$productionParametersPath = Join-Path $artifactRoot "environments\production.parameters.json"
$manifestTemplatePath = Join-Path $artifactRoot "pipeline\release-manifest.template.json"
$promotionWorkflowPath = Join-Path $artifactRoot "github\promotion.yml"
$restoreWorkflowPath = Join-Path $artifactRoot "github\restore-previous-release.yml"

function Read-JsonObject {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required JSON file is missing: $Path"
    }
    $value = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -ErrorAction Stop
    if ($null -eq $value) {
        throw "JSON file is empty: $Path"
    }
    return $value
}

function Resolve-RepositoryPath {
    param(
        [Parameter(Mandatory)][string]$RelativePath,
        [Parameter(Mandatory)][string]$Purpose,
        [Parameter()][string[]]$AllowedExtensions = @()
    )

    if ([System.IO.Path]::IsPathRooted($RelativePath) -or
        $RelativePath.IndexOfAny([char[]]"*?[]") -ge 0) {
        throw "$Purpose must be one literal repository-relative path."
    }
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $RelativePath))
    $rootPrefix = [System.IO.Path]::GetFullPath([string]$repoRoot).TrimEnd("\") + "\"
    if (-not $candidate.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Purpose resolves outside the repository."
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "$Purpose does not exist: $RelativePath"
    }
    if ($AllowedExtensions.Count -gt 0 -and
        [System.IO.Path]::GetExtension($candidate).ToLowerInvariant() -notin $AllowedExtensions) {
        throw "$Purpose has an unsupported file extension."
    }
    return $candidate
}

function Resolve-TemporaryExternalJson {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Purpose
    )

    if (-not [System.IO.Path]::IsPathRooted($Path) -or
        $Path.IndexOfAny([char[]]"*?[]") -ge 0) {
        throw "$Purpose must be one literal absolute temporary JSON path."
    }
    $candidate = [System.IO.Path]::GetFullPath($Path)
    $repoPrefix = [System.IO.Path]::GetFullPath([string]$repoRoot).TrimEnd("\") + "\"
    if ($candidate.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Purpose must not be stored in the repository."
    }
    $allowedRoots = @([System.IO.Path]::GetTempPath(), [string]$env:RUNNER_TEMP) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        ForEach-Object { [System.IO.Path]::GetFullPath($_).TrimEnd("\") + "\" }
    if (-not ($allowedRoots | Where-Object {
            $candidate.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase)
        })) {
        throw "$Purpose must be staged in the approved temporary workspace."
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf) -or
        [System.IO.Path]::GetExtension($candidate).ToLowerInvariant() -ne ".json") {
        throw "$Purpose must be an existing temporary JSON file."
    }
    return $candidate
}

function Assert-ImplementationMarker {
    param(
        [Parameter(Mandatory)][object]$Value,
        [Parameter(Mandatory)][string]$Purpose,
        [Parameter()][string]$Expected = "07-controlled-promotion-lifecycle"
    )

    if ([string]$Value.implementationSession -ne $Expected) {
        throw "$Purpose has the wrong implementationSession marker."
    }
}

function Assert-ImmutableValue {
    param(
        [Parameter(Mandatory)][string]$Value,
        [Parameter(Mandatory)][string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name is required."
    }
    if ($Value -match "(?i)^(latest|main|master|stable|current|production|prod)$" -or
        $Value -match "(?i)(^|[/@:._-])(latest|current)([/@:._-]|$)") {
        throw "$Name must identify an immutable version, not '$Value'."
    }
}

function Invoke-EvaluationGate {
    param(
        [Parameter(Mandatory)][string]$BaselineRecord,
        [Parameter(Mandatory)][string]$CandidateRecord,
        [Parameter(Mandatory)][ValidateSet("pass", "block")][string]$Expected
    )

    $paths = $control.sourcePaths
    $releaseGate = Resolve-RepositoryPath $paths.evaluationReleaseGate "Session 05 release gate" @(".py")
    $thresholds = Resolve-RepositoryPath $paths.evaluationThresholdPolicy "Session 05 threshold policy" @(".yaml", ".yml")
    $spec = Resolve-RepositoryPath $paths.evaluationSpec "Session 05 evaluation specification" @(".json")
    $dataset = Resolve-RepositoryPath $paths.evaluationDataset "Session 05 evaluation dataset" @(".jsonl")
    $baseline = Resolve-TemporaryExternalJson $BaselineRecord "Session 05 approved baseline record"
    $releasePolicy = Resolve-RepositoryPath $paths.evaluationReleasePolicy "Session 05 release policy" @(".json")
    $candidate = Resolve-TemporaryExternalJson $CandidateRecord "Session 05 candidate record"
    $candidateRecordValue = Read-JsonObject $candidate
    if ([string]$candidateRecordValue.run.runId -cne [string]$control.immutableRelease.evaluationRunId) {
        throw "The passing Session 05 candidate record does not match immutableRelease.evaluationRunId."
    }

    & python $releaseGate `
        --policy $thresholds `
        --spec $spec `
        --dataset $dataset `
        --baseline-result $baseline `
        --candidate-result $candidate `
        --release-policy $releasePolicy `
        --require-enabled `
        --evaluated-target candidate `
        --expect $Expected `
        --phase candidate
    if ($LASTEXITCODE -ne 0) {
        throw "Session 05 release gate did not produce expected outcome '$Expected'."
    }
}

function Invoke-EvaluationBlockedSelfTest {
    $selfTest = Resolve-RepositoryPath `
        $control.sourcePaths.evaluationGateSelfTest `
        "Session 05 generated blocked self-test" `
        @(".py")
    & python $selfTest --mode blocked-tool-process
    if ($LASTEXITCODE -ne 0) {
        throw "Session 05 generated blocked-tool-process self-test did not return BLOCK."
    }
}

function Assert-SecurityReleaseAttestation {
    param([Parameter(Mandatory)][string]$Path)

    $path = Resolve-TemporaryExternalJson $Path "Session 05 security-release attestation"
    $report = Read-JsonObject $path
    Assert-ImplementationMarker $report "Session 05 security-release attestation" "05-evaluation-threat-gates"
    $requiredAttestationFields = @(
        "schemaVersion",
        "implementationSession",
        "recordType",
        "status",
        "authorization",
        "reportLocation",
        "target",
        "releaseBinding",
        "configurationSha256",
        "baseline",
        "postRemediation",
        "privacy",
        "comparison"
    )
    if (@(Compare-Object $requiredAttestationFields @($report.PSObject.Properties.Name)).Count -ne 0) {
        throw "Session 05 security-release attestation has an incomplete or payload-bearing root schema."
    }
    if ($report.schemaVersion -ne 1 -or
        [string]$report.recordType -ne "security-release-attestation" -or
        [string]$report.status -ne "confirmed") {
        throw "Session 05 security-release attestation must be confirmed; pending or failed attestations block promotion."
    }
    $authorization = $report.authorization
    if (@(Compare-Object @("status", "system", "recordUrl") @($authorization.PSObject.Properties.Name)).Count -ne 0 -or
        [string]$authorization.status -cne "authorized" -or
        [string]::IsNullOrWhiteSpace([string]$authorization.system) -or
        -not [uri]::IsWellFormedUriString([string]$authorization.recordUrl, [UriKind]::Absolute) -or
        -not [uri]::IsWellFormedUriString([string]$report.reportLocation, [UriKind]::Absolute)) {
        throw "Session 05 attestation must carry authorized external security/change status and report location."
    }
    $releasePolicy = Read-JsonObject (Resolve-RepositoryPath `
        $control.sourcePaths.evaluationReleasePolicy `
        "Session 05 release policy" `
        @(".json"))
    if ([string]$report.target.type -cne "azure_ai_agent" -or
        [string]$report.target.name -cne [string]$control.immutableRelease.agentName -or
        [string]$report.target.baselineVersion -cne [string]$releasePolicy.target.approvedVersion -or
        [string]$report.target.postRemediationVersion -cne
            [string]$control.immutableRelease.agentVersion -or
        [string]$report.target.baselineVersion -ceq
            [string]$report.target.postRemediationVersion) {
        throw "Session 05 attestation does not bind the approved baseline and remediated release-agent versions."
    }
    if ([string]$report.configurationSha256 -notmatch "^[0-9a-fA-F]{64}$") {
        throw "Session 05 security-release attestation must name the shared attack-plan configuration SHA-256."
    }
    $binding = $report.releaseBinding
    if (@(Compare-Object @("agentName", "baselineVersion", "remediatedVersion", "versionsMatch") @($binding.PSObject.Properties.Name)).Count -ne 0 -or
        [string]$binding.agentName -cne [string]$control.immutableRelease.agentName -or
        [string]$binding.baselineVersion -cne [string]$releasePolicy.target.approvedVersion -or
        [string]$binding.remediatedVersion -cne [string]$control.immutableRelease.agentVersion -or
        $binding.versionsMatch -isnot [bool] -or
        $binding.versionsMatch -ne $true) {
        throw "Session 05 attestation must confirm its baseline and remediated versions match the release agent."
    }
    $requiredRunFields = @(
        "evalId",
        "runId",
        "reportUrl",
        "overallAttackSuccessRate"
    )
    foreach ($runName in @("baseline", "postRemediation")) {
        $run = $report.$runName
        if (@(Compare-Object $requiredRunFields @($run.PSObject.Properties.Name)).Count -ne 0) {
            throw "Session 05 $runName result has an incomplete schema."
        }
        foreach ($field in @("evalId", "runId", "reportUrl")) {
            if ([string]::IsNullOrWhiteSpace([string]$run.$field)) {
                throw "Session 05 $runName result is missing $field."
            }
        }
        if ($run.overallAttackSuccessRate -is [bool] -or
            $run.overallAttackSuccessRate -isnot [ValueType]) {
            throw "Session 05 $runName overallAttackSuccessRate must be numeric."
        }
        $rate = [double]$run.overallAttackSuccessRate
        if ($rate -lt 0 -or $rate -gt 1) {
            throw "Session 05 $runName overallAttackSuccessRate must be between zero and one."
        }
    }
    $baselineOverallRate = [double]$report.baseline.overallAttackSuccessRate
    $postOverallRate = [double]$report.postRemediation.overallAttackSuccessRate
    if ($postOverallRate -ge $baselineOverallRate -or
        $report.comparison.overallAttackSuccessRateChange -is [bool] -or
        $report.comparison.overallAttackSuccessRateChange -isnot [ValueType] -or
        [math]::Abs(
            [double]$report.comparison.overallAttackSuccessRateChange -
            ($postOverallRate - $baselineOverallRate)
        ) -gt 0.000001) {
        throw "Session 05 overall attack-success comparison is invalid or did not improve."
    }
    $requiredPrivacyFields = @(
        "containsAttackPrompts",
        "containsAgentResponses",
        "containsToolPayloads",
        "containsEvaluatorReasons",
        "containsPromptEvidence"
    )
    $actualPrivacyFields = @($report.privacy.PSObject.Properties.Name)
    if (@(Compare-Object $requiredPrivacyFields $actualPrivacyFields).Count -ne 0) {
        throw "Session 05 security-release attestation has an incomplete privacy schema."
    }
    foreach ($field in $requiredPrivacyFields) {
        if ($report.privacy.$field -isnot [bool] -or
            $report.privacy.$field -ne $false) {
            throw "Session 05 security-release attestation must remain payload-free: privacy.$field."
        }
    }
    foreach ($field in @(
        "lowerOverallAttackSuccessRate",
        "perRiskNonRegressionPassed",
        "prohibitedActionsBlocked"
    )) {
        if ($report.comparison.$field -isnot [bool] -or
            $report.comparison.$field -ne $true) {
            throw "Session 05 security-release attestation comparison field $field must be the JSON boolean true."
        }
    }
    $metrics = @($report.comparison.metrics)
    if ($metrics.Count -eq 0) {
        throw "Session 05 security-release attestation must include per-risk comparison rows."
    }
    $metricKeys = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::Ordinal
    )
    $prohibitedActionCount = 0
    foreach ($metric in $metrics) {
        $requiredMetricFields = @(
            "evaluatorName",
            "riskCategory",
            "attackStrategy",
            "baselineAttackSuccessRate",
            "postRemediationAttackSuccessRate",
            "change",
            "nonRegressionPassed"
        )
        if (@(Compare-Object $requiredMetricFields @($metric.PSObject.Properties.Name)).Count -ne 0) {
            throw "Session 05 security-release attestation has an incomplete per-risk comparison schema."
        }
        foreach ($field in @("evaluatorName", "riskCategory", "attackStrategy")) {
            if ([string]::IsNullOrWhiteSpace([string]$metric.$field)) {
                throw "Session 05 per-risk comparison is missing $field."
            }
        }
        $key = "$($metric.evaluatorName)`n$($metric.riskCategory)`n$($metric.attackStrategy)"
        if (-not $metricKeys.Add($key)) {
            throw "Session 05 security-release attestation has a duplicate per-risk comparison row."
        }
        if ($metric.nonRegressionPassed -isnot [bool] -or
            $metric.nonRegressionPassed -ne $true) {
            throw "Session 05 per-risk nonRegressionPassed must be the JSON boolean true."
        }
        foreach ($field in @(
            "baselineAttackSuccessRate",
            "postRemediationAttackSuccessRate",
            "change"
        )) {
            if ($metric.$field -is [bool] -or $metric.$field -isnot [ValueType]) {
                throw "Session 05 per-risk comparison field $field must be numeric."
            }
        }
        $baselineRate = [double]$metric.baselineAttackSuccessRate
        $postRate = [double]$metric.postRemediationAttackSuccessRate
        $change = [double]$metric.change
        if ($baselineRate -lt 0 -or $baselineRate -gt 1 -or
            $postRate -lt 0 -or $postRate -gt 1 -or
            [math]::Abs(($postRate - $baselineRate) - $change) -gt 0.000001 -or
            $postRate -gt $baselineRate) {
            throw "Session 05 per-risk comparison has invalid or regressed attack-success rates."
        }
        if ([string]$metric.evaluatorName -ceq "builtin.prohibited_actions") {
            $prohibitedActionCount++
            if ($postRate -ne 0) {
                throw "Session 05 prohibited-actions metrics must end at zero attack success."
            }
        }
    }
    if ($prohibitedActionCount -eq 0) {
        throw "Session 05 security-release attestation must include a prohibited-actions metric."
    }
}

function Assert-SmokeResult {
    param([Parameter(Mandatory)][string]$Path)

    $smoke = Read-JsonObject $Path
    Assert-ImplementationMarker $smoke "Session 06 smoke result" "06-citadel-observability-operations"
    if ($smoke.schemaVersion -isnot [long] -or
        $smoke.schemaVersion -ne 1 -or
        [string]$smoke.recordType -cne "citadel-smoke-result" -or
        [string]$smoke.mode -cne "pipeline" -or
        [string]$smoke.environment -cne "nonproduction" -or
        [string]$smoke.status -cne "passed" -or
        [string]$smoke.implementationMarker -cne
            "implementationSession=06-citadel-observability-operations") {
        throw "Session 06 smoke result has an invalid root contract or non-passing status."
    }
    if ([string]$smoke.commitSha -cne $ReleaseSha) {
        throw "Session 06 smoke result does not target the promoted commit SHA."
    }
    foreach ($field in @("correlationId", "normalCorrelationId", "failureCorrelationId")) {
        if ($smoke.$field -isnot [string] -or
            [string]$smoke.$field -cnotmatch "^[0-9a-f]{32}$") {
            throw "Session 06 smoke result '$field' must be a lower-case W3C trace ID."
        }
    }
    if ([string]$smoke.correlationId -cne [string]$smoke.normalCorrelationId -or
        [string]$smoke.normalCorrelationId -ceq [string]$smoke.failureCorrelationId) {
        throw "Session 06 smoke result must bind its root correlation to distinct normal and failure traces."
    }
    foreach ($field in @("syntheticRequest", "endToEndTrace", "toolAndModelFailureSeparated")) {
        if ([string]$smoke.checks.$field -cne "passed") {
            throw "Session 06 smoke result check '$field' did not pass."
        }
    }
    foreach ($field in @(
        "syntheticRequestSucceeded",
        "expectedToolFailure",
        "independentModelResult",
        "releaseCommitShaVerified",
        "workspaceBindingVerified",
        "correlationIdsDistinct",
        "telemetryIngestionStable"
    )) {
        if ($smoke.checks.$field -isnot [bool] -or
            $smoke.checks.$field -ne $true) {
            throw "Session 06 smoke result check '$field' must be the JSON boolean true."
        }
    }
    foreach ($field in @("sensitiveInputPresent", "payloadsRetained")) {
        if ($smoke.checks.$field -isnot [bool] -or
            $smoke.checks.$field -ne $false) {
            throw "Session 06 smoke result check '$field' must be the JSON boolean false."
        }
    }
    $requiredPrivacySurfaces = @(
        "AppRequests",
        "AppDependencies",
        "AppEvents",
        "AppTraces",
        "AppExceptions"
    )
    $actualPrivacySurfaces = @($smoke.checks.privacySurfacesChecked)
    if ($actualPrivacySurfaces.Count -ne $requiredPrivacySurfaces.Count -or
        ($actualPrivacySurfaces -join "`n") -cne
            ($requiredPrivacySurfaces -join "`n")) {
        throw "Session 06 smoke result must check the five required telemetry privacy surfaces."
    }
    $pollAttemptsValue = $smoke.checks.telemetryPollAttempts
    $pollTimeoutValue = $smoke.checks.telemetryPollTimeoutSeconds
    $pollRetryValue = $smoke.checks.telemetryPollRetrySeconds
    if ($smoke.checks.telemetryPollTimedOut -isnot [bool] -or
        $smoke.checks.telemetryPollTimedOut -ne $false -or
        $pollAttemptsValue -isnot [long] -or
        $pollTimeoutValue -isnot [long] -or
        $pollRetryValue -isnot [long]) {
        throw "Session 06 smoke polling fields must use the required JSON boolean and integer types."
    }
    $pollAttempts = [int]$pollAttemptsValue
    $pollTimeout = [int]$pollTimeoutValue
    $pollRetry = [int]$pollRetryValue
    if (
        $pollTimeout -lt 30 -or $pollTimeout -gt 600 -or
        $pollRetry -lt 5 -or $pollRetry -gt 60 -or
        $pollRetry -gt $pollTimeout -or
        $pollTimeout -lt (2 * $pollRetry)) {
        throw "Session 06 smoke result does not show a successful bounded telemetry-ingestion poll."
    }
    $maximumAttempts = [math]::Ceiling($pollTimeout / $pollRetry) + 1
    if ($pollAttempts -lt 3 -or $pollAttempts -gt $maximumAttempts) {
        throw "Session 06 smoke result reports an invalid telemetry polling attempt count."
    }
    $observedAt = [datetimeoffset]::MinValue
    if ($smoke.payloadsRetained -isnot [bool] -or
        $smoke.payloadsRetained -ne $false -or
        [string]$smoke.correlationId -notmatch "^[A-Za-z0-9._:-]{1,128}$" -or
        -not [datetimeoffset]::TryParse([string]$smoke.observedAt, [ref]$observedAt)) {
        throw "Session 06 smoke result must report no stored payloads and include a valid correlationId and observedAt."
    }
}

$requiredFiles = @(
    $controlPath,
    $nonproductionParametersPath,
    $productionParametersPath,
    $manifestTemplatePath,
    $promotionWorkflowPath,
    $restoreWorkflowPath
)
foreach ($requiredFile in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required implementation file is missing: $requiredFile"
    }
}

$control = Read-JsonObject $controlPath
$nonproductionParameters = Read-JsonObject $nonproductionParametersPath
$productionParameters = Read-JsonObject $productionParametersPath
Assert-ImplementationMarker $control "Control definition"
if ([string]$control.repository.host -cne "github.com") {
    throw "The approved repository host must be github.com."
}
if ($control.azure.clientSecretAllowed -ne $false -or
    [string]$control.azure.authentication -notmatch "OIDC") {
    throw "Azure authentication must use OIDC workload identity federation without client secrets."
}
if ([string]$control.records.manifestFinalizationFailureBehavior -cne
    "stop-and-require-manual-restore") {
    throw "Manifest finalization failure must stop for manual restore."
}
$releaseRecordLifecycle = $control.records.releaseRecordLifecycle
if ([string]$releaseRecordLifecycle.updater -cne
    "Controlled AI release promotion workflow after production deployment and routing" -or
    [string]$releaseRecordLifecycle.reviewCadence -cne
    "Every successful production promotion and before manual restore" -or
    [string]$releaseRecordLifecycle.consumer -cne
    "Approved release store and Restore previous AI release workflow" -or
    $releaseRecordLifecycle.repositoryMirrorAllowed -isnot [bool] -or
    $releaseRecordLifecycle.repositoryMirrorAllowed -ne $false) {
    throw "Release-record lifecycle must name its workflow updater, review cadence, consumer, and repository-mirror boundary."
}
if ([string]$control.routing.strategy -notin @("canary", "blue-green")) {
    throw "Routing strategy must be canary or blue-green."
}
if ($control.routing.existingSession05Or06SupportConfirmed -ne $true) {
    throw "Existing Session 04 or 06 routing support is not confirmed; keep 100 percent on the previous approved release."
}
$portfolio = $control.agentPortfolio
$frameworkPath = [string]$portfolio.frameworkPath
$frameworkException = ([string]$portfolio.frameworkExceptionApprovalReference).Trim()
$frameworkSupportOwner = ([string]$portfolio.frameworkExceptionSupportOwnerRole).Trim()
$duplicateDecision = [string]$portfolio.duplicateReviewDecision
$duplicateOwner = ([string]$portfolio.duplicateReviewOwnerRole).Trim()
$reviewedInventory = ([string]$portfolio.reviewedAgentInventoryReference).Trim()
if ($frameworkPath -cnotin @("native-platform", "microsoft-agent-framework", "semantic-kernel", "other-by-exception")) {
    throw "agentPortfolio.frameworkPath must be native-platform, microsoft-agent-framework, semantic-kernel, or other-by-exception."
}
if ($frameworkPath -ceq "other-by-exception") {
    if ([string]::IsNullOrWhiteSpace($frameworkException) -or $frameworkException.ToUpperInvariant() -ceq "N/A") {
        throw "A framework path outside the approved list needs an approval reference and a named runtime support owner."
    }
    if ([string]::IsNullOrWhiteSpace($frameworkSupportOwner) -or
        $frameworkSupportOwner.ToUpperInvariant() -ceq "N/A" -or
        $frameworkSupportOwner.Contains("@")) {
        throw "agentPortfolio.frameworkExceptionSupportOwnerRole must name a team or role alias for an exception."
    }
}
elseif ($frameworkException.ToUpperInvariant() -cne "N/A" -or
    $frameworkSupportOwner.ToUpperInvariant() -cne "N/A") {
    throw "Framework exception approval and support owner must be 'N/A' unless the framework path is other-by-exception."
}
if ($duplicateDecision -ceq "reuse-existing") {
    throw "The duplicate review chose an existing agent; promote that agent instead of this candidate."
}
if ($duplicateDecision -cnotin @("new-capability", "approved-overlap")) {
    throw "agentPortfolio.duplicateReviewDecision must be new-capability, approved-overlap, or reuse-existing."
}
if ([string]::IsNullOrWhiteSpace($duplicateOwner) -or $duplicateOwner.Contains("@")) {
    throw "agentPortfolio.duplicateReviewOwnerRole must be a team or role alias, not a personal address."
}
if ([string]::IsNullOrWhiteSpace($reviewedInventory)) {
    throw "agentPortfolio.reviewedAgentInventoryReference must point at the inventory record the duplicate review compared."
}

$promotionWorkflow = Get-Content -LiteralPath $promotionWorkflowPath -Raw
$restoreWorkflow = Get-Content -LiteralPath $restoreWorkflowPath -Raw
$externalUsePattern = "(?m)^\s*uses:\s*(?<value>[^#\r\n]+?)(?:\s+#.*)?$"
foreach ($workflow in @($promotionWorkflow, $restoreWorkflow)) {
    foreach ($match in [regex]::Matches($workflow, $externalUsePattern)) {
        $useValue = [string]$match.Groups["value"].Value.Trim().Trim('"').Trim("'")
        if ($useValue.StartsWith("./", [System.StringComparison]::Ordinal)) {
            continue
        }
        $separator = $useValue.LastIndexOf("@", [System.StringComparison]::Ordinal)
        $actionRef = if ($separator -ge 0) { $useValue.Substring($separator + 1) } else { "" }
        if ($actionRef -notmatch "^[0-9a-fA-F]{40}$") {
            throw "Every external workflow action must use a full 40-character commit SHA: $($match.Value.Trim())."
        }
    }
}
$requiredWorkflowFragments = @(
    "environment: nonproduction-preview",
    "environment: nonproduction",
    "environment: production-preview",
    "environment: production",
    "needs: validate",
    "release_sha:",
    'run-name: Controlled AI release ${{ inputs.release_sha }} (${{ inputs.evaluation_record }})',
    'ref: ${{ github.event.repository.default_branch }}',
    "fetch-depth: 0",
    "Prove the release commit belongs to the protected branch",
    '$env:GITHUB_SERVER_URL -cne "https://github.com"',
    '$env:GITHUB_REPOSITORY -cne $expectedRepository',
    '$trustedFetchUrl = "https://github.com/$expectedRepository.git"',
    "The protected release branch is missing or not protected.",
    'git merge-base --is-ancestor $releaseSha "refs/remotes/trusted-release/$approvedBranch"',
    'ref: ${{ inputs.release_sha }}',
    'releaseCommitSha="${{ inputs.release_sha }}"',
    '-Mode CreateManifest -ReleaseSha "${{ inputs.release_sha }}"',
    'RetrieveEvaluationResult',
    'RetrieveSecurityReleaseAttestation',
    '-SecurityReleaseAttestationPath',
    "Apply evaluation and adversarial gates before deployment",
    'CITADEL_SMOKE_URL: ${{ vars.CITADEL_SMOKE_URL }}',
    'CITADEL_SMOKE_FAILURE_URL: ${{ vars.CITADEL_SMOKE_FAILURE_URL }}',
    'CITADEL_AI_RESOURCE_ID: ${{ vars.CITADEL_AI_RESOURCE_ID }}',
    'CITADEL_LOG_ANALYTICS_WORKSPACE_ID: ${{ vars.CITADEL_LOG_ANALYTICS_WORKSPACE_ID }}',
    'CITADEL_SMOKE_TIMEOUT_SECONDS: ${{ vars.CITADEL_SMOKE_TIMEOUT_SECONDS }}',
    'CITADEL_SMOKE_RETRY_SECONDS: ${{ vars.CITADEL_SMOKE_RETRY_SECONDS }}',
    'CITADEL_SMOKE_BEARER_TOKEN: ${{ secrets.CITADEL_SMOKE_BEARER_TOKEN }}',
    "Deploy after environment approval",
    "Stop and dispatch the manual restore workflow"
)
foreach ($fragment in $requiredWorkflowFragments) {
    if (-not $promotionWorkflow.Contains($fragment)) {
        throw "Promotion workflow is missing enforced control: $fragment"
    }
}
if ($promotionWorkflow.IndexOf("Apply evaluation and adversarial gates before deployment") -gt
    $promotionWorkflow.IndexOf("environment: nonproduction-preview")) {
    throw "The generated blocked self-test must run before nonproduction preview and deployment."
}
$checkoutCount = [regex]::Matches(
    $promotionWorkflow,
    "(?m)^\s*uses:\s*actions/checkout@"
).Count
$releaseRefCount = [regex]::Matches(
    $promotionWorkflow,
    '(?m)^\s*ref:\s*\$\{\{\s*inputs\.release_sha\s*\}\}'
).Count
$protectedBranchRefCount = [regex]::Matches(
    $promotionWorkflow,
    '(?m)^\s*ref:\s*\$\{\{\s*github\.event\.repository\.default_branch\s*\}\}'
).Count
if ($checkoutCount -lt 2 -or
    $protectedBranchRefCount -ne 1 -or
    $releaseRefCount -ne ($checkoutCount - 1)) {
    throw "Promotion must validate one protected-branch checkout before every exact release checkout."
}
$lineageStep = $promotionWorkflow.IndexOf(
    "Prove the release commit belongs to the protected branch"
)
$firstReleaseCheckout = $promotionWorkflow.IndexOf(
    "Check out the exact release commit after lineage validation"
)
if ($lineageStep -lt 0 -or
    $firstReleaseCheckout -lt 0 -or
    $lineageStep -gt $firstReleaseCheckout) {
    throw "Release content must not be checked out before protected-branch lineage validation."
}
if (-not $restoreWorkflow.Contains("workflow_dispatch:") -or
    $restoreWorkflow.Contains("workflow_run:")) {
    throw "Restore must remain manual-only."
}
if ($restoreWorkflow -match "(?m)^  id-token:\s*write\s*$" -or
    $restoreWorkflow -notmatch "(?m)^  contents:\s*read\s*$" -or
    $restoreWorkflow -notmatch "(?m)^    environment:\s*production\s*$" -or
    $restoreWorkflow -notmatch "(?m)^      id-token:\s*write\s*$") {
    throw "Restore must grant id-token: write only to its protected production job."
}

if ([string]$control.releaseCommit.source -cne "workflow_dispatch.release_sha" -or
    [string]$control.releaseCommit.format -cne "full-40-character-git-sha" -or
    [string]$control.releaseCommit.approvedBranchSource -cne
        "repository.defaultBranch" -or
    $control.releaseCommit.workflowRefMustMatchApprovedBranch -isnot [bool] -or
    $control.releaseCommit.workflowRefMustMatchApprovedBranch -ne $true -or
    $control.releaseCommit.mustBeReachableFromApprovedBranch -isnot [bool] -or
    $control.releaseCommit.mustBeReachableFromApprovedBranch -ne $true -or
    $control.releaseCommit.checkoutMustMatch -isnot [bool] -or
    $control.releaseCommit.checkoutMustMatch -ne $true -or
    $control.releaseCommit.manifestMustMatch -isnot [bool] -or
    $control.releaseCommit.manifestMustMatch -ne $true) {
    throw "Control must bind workflow ref, protected-branch lineage, checkout, and manifest to the approved release SHA."
}
foreach ($property in @(
    "promptVersion",
    "agentName",
    "agentVersion",
    "modelDeploymentAlias",
    "apimPolicyVersion",
    "evaluationRunId",
    "evaluationThresholdPolicyVersion",
    "evaluationThresholdPolicySha256"
)) {
    Assert-ImmutableValue ([string]$control.immutableRelease.$property) "immutableRelease.$property"
}
$thresholdPolicyPath = Resolve-RepositoryPath `
    $control.sourcePaths.evaluationThresholdPolicy `
    "Session 05 threshold policy" `
    @(".yaml", ".yml")
$thresholdPolicyHash = (Get-FileHash -LiteralPath $thresholdPolicyPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ([string]$control.immutableRelease.evaluationThresholdPolicySha256 -cne $thresholdPolicyHash) {
    throw "immutableRelease.evaluationThresholdPolicySha256 does not match the approved Session 05 threshold policy."
}
$releasePolicyPath = Resolve-RepositoryPath `
    $control.sourcePaths.evaluationReleasePolicy `
    "Session 05 release policy" `
    @(".json")
$releasePolicy = Read-JsonObject $releasePolicyPath
Assert-ImplementationMarker $releasePolicy "Session 05 release policy" "05-evaluation-threat-gates"
if ($releasePolicy.schemaVersion -ne 2) {
    throw "Session 05 release policy must use schemaVersion 2."
}
$expectedActivationContract = [ordered]@{
    requiredState = "enabled"
    requiredDecision = "approved"
    decisionDateRequired = $true
    thresholdPolicyState = "active"
    thresholdPolicyPath = "implementation/artifacts/eval/thresholds.yaml"
    baselineRunIdMustMatchThresholdPolicyAndBaselineRecord = $true
    candidateRunIdMustMatchCandidateRecord = $true
}
$actualActivationFields = @($releasePolicy.activationContract.PSObject.Properties.Name)
if (@(Compare-Object @($expectedActivationContract.Keys) $actualActivationFields).Count -ne 0) {
    throw "Session 05 release policy has an unexpected activationContract schema."
}
foreach ($field in $expectedActivationContract.Keys) {
    $expectedValue = $expectedActivationContract[$field]
    $actualValue = $releasePolicy.activationContract.$field
    if (($expectedValue -is [bool] -and $actualValue -isnot [bool]) -or
        $actualValue -cne $expectedValue) {
        throw "Session 05 release policy activationContract.$field is not the required value."
    }
}
if ([string]$releasePolicy.gate.callableInterface.requiredEnforcementOption -cne
    "--require-enabled") {
    throw "Session 05 callable release gate must require --require-enabled."
}
$decisionDate = [datetime]::MinValue
if ([string]$releasePolicy.gate.state -cne "enabled" -or
    [string]$releasePolicy.gate.decision -cne "approved" -or
    [string]::IsNullOrWhiteSpace([string]$releasePolicy.gate.baselineRunId) -or
    [string]::IsNullOrWhiteSpace([string]$releasePolicy.gate.candidateRunId) -or
    -not [datetime]::TryParseExact(
        [string]$releasePolicy.gate.decisionDate,
        "yyyy-MM-dd",
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::None,
        [ref]$decisionDate
    )) {
    throw "Session 05 release policy must have enabled state and an approved decision date."
}
if ($decisionDate.Date -gt [datetime]::UtcNow.Date) {
    throw "Session 05 release policy decisionDate cannot be in the future."
}
if ([string]$releasePolicy.target.agentName -cne [string]$control.immutableRelease.agentName -or
    [string]$releasePolicy.target.candidateVersion -cne [string]$control.immutableRelease.agentVersion) {
    throw "Session 05 release policy must target the approved immutable agent version."
}
if ([string]$releasePolicy.gate.candidateRunId -cne [string]$control.immutableRelease.evaluationRunId) {
    throw "Session 05 release-policy candidate run ID must match the immutable release."
}
$releaseGatePath = Resolve-RepositoryPath `
    $control.sourcePaths.evaluationReleaseGate `
    "Session 05 release gate" `
    @(".py")
& python $releaseGatePath `
    --policy $thresholdPolicyPath `
    --validate-policy `
    --phase candidate
if ($LASTEXITCODE -ne 0) {
    throw "Session 05 threshold policy must be active and approved for candidate gating."
}

foreach ($entry in @(
    @($control.sourcePaths.bicepEntrypoint, "Bicep entrypoint", @(".bicep")),
    @($control.sourcePaths.apimPolicy, "APIM policy", @(".xml")),
    @($control.sourcePaths.unitTestScript, "unit-test script", @(".ps1")),
    @($control.sourcePaths.observabilitySmokePowerShell, "Session 06 PowerShell smoke script", @(".ps1")),
    @($control.sourcePaths.observabilitySmokeBash, "Session 06 Bash smoke script", @(".sh")),
    @($control.sourcePaths.routingControlScript, "routing-control script", @(".ps1")),
    @($control.sourcePaths.releaseStoreScript, "approved release-store script", @(".ps1"))
)) {
    $null = Resolve-RepositoryPath $entry[0] $entry[1] $entry[2]
}
$externalGateArtifacts = $control.records.externalGateArtifacts
if ([string]$externalGateArtifacts.evaluationResults.retrieveMode -cne "RetrieveEvaluationResult" -or
    [string]$externalGateArtifacts.evaluationResults.interface -cne "releaseStoreScript" -or
    $externalGateArtifacts.evaluationResults.temporaryArtifactOnly -isnot [bool] -or
    $externalGateArtifacts.evaluationResults.temporaryArtifactOnly -ne $true -or
    $externalGateArtifacts.evaluationResults.repositoryMirrorAllowed -isnot [bool] -or
    $externalGateArtifacts.evaluationResults.repositoryMirrorAllowed -ne $false -or
    $externalGateArtifacts.securityReleaseAttestation.schemaVersion -ne 1 -or
    [string]$externalGateArtifacts.securityReleaseAttestation.recordType -cne "security-release-attestation" -or
    [string]$externalGateArtifacts.securityReleaseAttestation.interface -cne "releaseStoreScript" -or
    [string]$externalGateArtifacts.securityReleaseAttestation.retrieveMode -cne "RetrieveSecurityReleaseAttestation" -or
    [string]$externalGateArtifacts.securityReleaseAttestation.requiredAuthorizationStatus -cne "authorized" -or
    [string]$externalGateArtifacts.securityReleaseAttestation.requiredConfirmationStatus -cne "confirmed" -or
    $externalGateArtifacts.securityReleaseAttestation.temporaryArtifactOnly -isnot [bool] -or
    $externalGateArtifacts.securityReleaseAttestation.temporaryArtifactOnly -ne $true -or
    $externalGateArtifacts.securityReleaseAttestation.repositoryMirrorAllowed -isnot [bool] -or
    $externalGateArtifacts.securityReleaseAttestation.repositoryMirrorAllowed -ne $false) {
    throw "External evaluation and security gate artifacts must use the approved temporary-artifact contract."
}

foreach ($pair in @(
    @($nonproductionParameters, "nonproduction"),
    @($productionParameters, "production")
)) {
    $parameters = $pair[0].parameters
    $environmentName = $pair[1]
    if ([string]$parameters.environment.value -ne $environmentName -or
        [string]$parameters.implementationSession.value -ne "07-controlled-promotion-lifecycle") {
        throw "$environmentName parameters have the wrong environment or implementation marker."
    }
    if ($null -ne $parameters.PSObject.Properties["releaseCommitSha"]) {
        throw "$environmentName parameters must receive releaseCommitSha at runtime, not store a self-referential commit."
    }
    foreach ($mapping in @(
        @("promptVersion", "promptVersion"),
        @("agentVersion", "agentVersion"),
        @("modelDeploymentAlias", "modelDeploymentAlias"),
        @("apimPolicyVersion", "apimPolicyVersion")
    )) {
        if ([string]$parameters.($mapping[0]).value -ne
            [string]$control.immutableRelease.($mapping[1])) {
            throw "$environmentName parameters disagree on $($mapping[0])."
        }
    }
}

switch ($Mode) {
    "Static" {
        Write-Host "PASS: workflow enforcement, immutable metadata, source paths, action pins, and environment parameters are consistent."
    }
    "Dependencies" {
        if ([string]::IsNullOrWhiteSpace($BaselineRecordPath) -or
            [string]::IsNullOrWhiteSpace($CandidateRecordPath) -or
            [string]::IsNullOrWhiteSpace($SecurityReleaseAttestationPath)) {
            throw "-BaselineRecordPath, -CandidateRecordPath, and -SecurityReleaseAttestationPath are required for Dependencies mode."
        }
        Invoke-EvaluationGate $BaselineRecordPath $CandidateRecordPath "pass"
        Invoke-EvaluationBlockedSelfTest
        Assert-SecurityReleaseAttestation $SecurityReleaseAttestationPath
        Write-Host "PASS: Session 05 permitted path, generated blocked self-test, and confirmed external Session 05 security-release attestation are ready."
    }
    "Smoke" {
        if ([string]::IsNullOrWhiteSpace($SmokeResultPath)) {
            throw "-SmokeResultPath is required for Smoke mode."
        }
        Assert-SmokeResult $SmokeResultPath
        Write-Host "PASS: Session 06 smoke and observability result is complete and payload-safe."
    }
    "Intended" {
        if ([string]::IsNullOrWhiteSpace($SmokeResultPath) -or
            [string]::IsNullOrWhiteSpace($BaselineRecordPath) -or
            [string]::IsNullOrWhiteSpace($CandidateRecordPath) -or
            [string]::IsNullOrWhiteSpace($SecurityReleaseAttestationPath)) {
            throw "-SmokeResultPath, -BaselineRecordPath, -CandidateRecordPath, and -SecurityReleaseAttestationPath are required for Intended mode."
        }
        Invoke-EvaluationGate $BaselineRecordPath $CandidateRecordPath "pass"
        Assert-SecurityReleaseAttestation $SecurityReleaseAttestationPath
        Assert-SmokeResult $SmokeResultPath
        Write-Host "PASS: intended quality, adversarial, and smoke gates permit production approval."
    }
    "Blocked" {
        Invoke-EvaluationBlockedSelfTest
        Write-Host "PASS: the Session 05 generated blocked-tool-process self-test returned BLOCK."
    }
    "CreateManifest" {
        if ([string]::IsNullOrWhiteSpace($RuntimeValuesPath) -or
            [string]::IsNullOrWhiteSpace($OutputPath)) {
            throw "-RuntimeValuesPath and -OutputPath are required for CreateManifest mode."
        }
        $runtime = Read-JsonObject $RuntimeValuesPath
        Assert-ImplementationMarker $runtime "Runtime manifest values"
        if ([string]$runtime.commitSha -cne $ReleaseSha) {
            throw "Runtime manifest values do not match the approved release SHA."
        }
        $template = Get-Content -LiteralPath $manifestTemplatePath -Raw
        $replacementMap = [ordered]@{
            "__RUNTIME_RELEASE_ID__" = $runtime.releaseId
            "__RUNTIME_COMMIT_SHA__" = $runtime.commitSha
            "__RUNTIME_NONPRODUCTION_DEPLOYMENT_ID__" = $runtime.nonproductionDeploymentId
            "__RUNTIME_ROUTING_STRATEGY__" = $runtime.routingStrategy
            "__RUNTIME_CANDIDATE_SELECTOR__" = $runtime.candidateSelector
            "__RUNTIME_STABLE_SELECTOR__" = $runtime.stableSelector
            "__RUNTIME_GITHUB_ACTIONS_RUN_URL__" = $runtime.githubActionsRunUrl
        }
        foreach ($entry in $replacementMap.GetEnumerator()) {
            if ([string]::IsNullOrWhiteSpace([string]$entry.Value)) {
                throw "Runtime value for $($entry.Key) is missing."
            }
            $encoded = [System.Text.Json.JsonSerializer]::Serialize([string]$entry.Value)
            $template = $template.Replace('"' + $entry.Key + '"', $encoded)
        }
        if ($template -match "__RUNTIME_[A-Z0-9_]+__") {
            throw "Release manifest contains unresolved runtime values."
        }
        $manifest = $template | ConvertFrom-Json -ErrorAction Stop
        Assert-ImplementationMarker $manifest "Generated release manifest"
        if ([string]$manifest.commitSha -cne $ReleaseSha) {
            throw "Generated release manifest does not carry the approved commit SHA."
        }
        $template | Set-Content -LiteralPath $OutputPath -Encoding utf8NoBOM
        Write-Host "PASS: release manifest created at $OutputPath."
    }
}
