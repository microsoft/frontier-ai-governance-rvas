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
    [string]$CandidateRecordPath,

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

function Assert-ImplementationMarker {
    param(
        [Parameter(Mandatory)][object]$Value,
        [Parameter(Mandatory)][string]$Purpose,
        [Parameter()][string]$Expected = "14-cicd-promotion-controls"
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

function Invoke-Session11Gate {
    param(
        [Parameter(Mandatory)][string]$CandidateRecord,
        [Parameter(Mandatory)][ValidateSet("pass", "block")][string]$Expected
    )

    $paths = $control.sourcePaths
    $releaseGate = Resolve-RepositoryPath $paths.session11ReleaseGate "Session 11 release gate" @(".py")
    $thresholds = Resolve-RepositoryPath $paths.session11ThresholdPolicy "Session 11 threshold policy" @(".yaml", ".yml")
    $spec = Resolve-RepositoryPath $paths.session11EvaluationSpec "Session 11 evaluation specification" @(".json")
    $dataset = Resolve-RepositoryPath $paths.session11Dataset "Session 11 evaluation dataset" @(".jsonl")
    $baseline = Resolve-RepositoryPath $paths.session11BaselineRecord "Session 11 approved baseline record" @(".json")
    $releasePolicy = Resolve-RepositoryPath $paths.session11ReleasePolicy "Session 11 release policy" @(".json")
    $candidate = Resolve-RepositoryPath $CandidateRecord "Session 11 candidate record" @(".json")
    $candidateRecordValue = Read-JsonObject $candidate
    if ([string]$candidateRecordValue.run.runId -cne [string]$control.immutableRelease.evaluationRunId) {
        throw "The passing Session 11 candidate record does not match immutableRelease.evaluationRunId."
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
        throw "Session 11 release gate did not produce expected outcome '$Expected'."
    }
}

function Invoke-Session11BlockedSelfTest {
    $selfTest = Resolve-RepositoryPath `
        $control.sourcePaths.session11GateSelfTest `
        "Session 11 generated blocked self-test" `
        @(".py")
    & python $selfTest --mode blocked-tool-process
    if ($LASTEXITCODE -ne 0) {
        throw "Session 11 generated blocked-tool-process self-test did not return BLOCK."
    }
}

function Assert-AdversarialReport {
    $path = Resolve-RepositoryPath `
        $control.sourcePaths.session12AdversarialReport `
        "Session 12 adversarial before-after report" `
        @(".json")
    $report = Read-JsonObject $path
    Assert-ImplementationMarker $report "Session 12 adversarial report" "12-red-teaming-threat-defense"
    if ($report.schemaVersion -ne 1 -or
        [string]$report.recordType -ne "red-team-before-after-aggregate" -or
        [string]$report.status -ne "confirmed") {
        throw "Session 12 adversarial report must be confirmed; pending or failed reports block promotion."
    }
    if ([string]$report.target.type -cne "azure_ai_agent" -or
        [string]$report.target.name -cne [string]$control.immutableRelease.agentName -or
        [string]::IsNullOrWhiteSpace([string]$report.target.baselineVersion) -or
        [string]$report.target.postRemediationVersion -cne
            [string]$control.immutableRelease.agentVersion -or
        [string]$report.target.baselineVersion -ceq
            [string]$report.target.postRemediationVersion) {
        throw "Session 12 adversarial report targets another agent name or immutable version."
    }
    if ([string]$report.configurationSha256 -notmatch "^[0-9a-fA-F]{64}$") {
        throw "Session 12 adversarial report must name the shared attack-plan configuration SHA-256."
    }
    $handoffPath = Resolve-RepositoryPath `
        $control.sourcePaths.session12RiskChangeHandoff `
        "Session 12 risk/change handoff" `
        @(".json")
    $handoff = Read-JsonObject $handoffPath
    Assert-ImplementationMarker $handoff "Session 12 risk/change handoff" "12-red-teaming-threat-defense"
    if ([string]$handoff.target.agentName -cne [string]$report.target.name -or
        [string]$handoff.target.baselineVersion -cne [string]$report.target.baselineVersion -or
        [string]$handoff.target.postRemediationVersion -cne
            [string]$report.target.postRemediationVersion) {
        throw "Session 12 risk/change handoff does not match the report target and immutable versions."
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
            throw "Session 12 $runName result has an incomplete schema."
        }
        foreach ($field in @("evalId", "runId", "reportUrl")) {
            if ([string]::IsNullOrWhiteSpace([string]$run.$field)) {
                throw "Session 12 $runName result is missing $field."
            }
        }
        if ($run.overallAttackSuccessRate -is [bool] -or
            $run.overallAttackSuccessRate -isnot [ValueType]) {
            throw "Session 12 $runName overallAttackSuccessRate must be numeric."
        }
        $rate = [double]$run.overallAttackSuccessRate
        if ($rate -lt 0 -or $rate -gt 1) {
            throw "Session 12 $runName overallAttackSuccessRate must be between zero and one."
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
        throw "Session 12 overall attack-success comparison is invalid or did not improve."
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
        throw "Session 12 adversarial report has an incomplete privacy schema."
    }
    foreach ($field in $requiredPrivacyFields) {
        if ($report.privacy.$field -isnot [bool] -or
            $report.privacy.$field -ne $false) {
            throw "Session 12 adversarial report must remain payload-free: privacy.$field."
        }
    }
    foreach ($field in @(
        "lowerOverallAttackSuccessRate",
        "perRiskNonRegressionPassed",
        "prohibitedActionsBlocked"
    )) {
        if ($report.comparison.$field -isnot [bool] -or
            $report.comparison.$field -ne $true) {
            throw "Session 12 adversarial comparison field $field must be the JSON boolean true."
        }
    }
    $metrics = @($report.comparison.metrics)
    if ($metrics.Count -eq 0) {
        throw "Session 12 adversarial report must include per-risk comparison rows."
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
            throw "Session 12 adversarial report has an incomplete per-risk comparison schema."
        }
        foreach ($field in @("evaluatorName", "riskCategory", "attackStrategy")) {
            if ([string]::IsNullOrWhiteSpace([string]$metric.$field)) {
                throw "Session 12 per-risk comparison is missing $field."
            }
        }
        $key = "$($metric.evaluatorName)`n$($metric.riskCategory)`n$($metric.attackStrategy)"
        if (-not $metricKeys.Add($key)) {
            throw "Session 12 adversarial report has a duplicate per-risk comparison row."
        }
        if ($metric.nonRegressionPassed -isnot [bool] -or
            $metric.nonRegressionPassed -ne $true) {
            throw "Session 12 per-risk nonRegressionPassed must be the JSON boolean true."
        }
        foreach ($field in @(
            "baselineAttackSuccessRate",
            "postRemediationAttackSuccessRate",
            "change"
        )) {
            if ($metric.$field -is [bool] -or $metric.$field -isnot [ValueType]) {
                throw "Session 12 per-risk comparison field $field must be numeric."
            }
        }
        $baselineRate = [double]$metric.baselineAttackSuccessRate
        $postRate = [double]$metric.postRemediationAttackSuccessRate
        $change = [double]$metric.change
        if ($baselineRate -lt 0 -or $baselineRate -gt 1 -or
            $postRate -lt 0 -or $postRate -gt 1 -or
            [math]::Abs(($postRate - $baselineRate) - $change) -gt 0.000001 -or
            $postRate -gt $baselineRate) {
            throw "Session 12 per-risk comparison has invalid or regressed attack-success rates."
        }
        if ([string]$metric.evaluatorName -ceq "builtin.prohibited_actions") {
            $prohibitedActionCount++
            if ($postRate -ne 0) {
                throw "Session 12 prohibited-actions metrics must end at zero attack success."
            }
        }
    }
    if ($prohibitedActionCount -eq 0) {
        throw "Session 12 adversarial report must include a prohibited-actions metric."
    }
}

function Assert-SmokeResult {
    param([Parameter(Mandatory)][string]$Path)

    $smoke = Read-JsonObject $Path
    Assert-ImplementationMarker $smoke "Session 13 smoke result" "13-observability-cost-operations"
    if ($smoke.schemaVersion -isnot [long] -or
        $smoke.schemaVersion -ne 1 -or
        [string]$smoke.recordType -cne "session13-smoke-result" -or
        [string]$smoke.mode -cne "pipeline" -or
        [string]$smoke.environment -cne "nonproduction" -or
        [string]$smoke.status -cne "passed" -or
        [string]$smoke.implementationMarker -cne
            "implementationSession=13-observability-cost-operations") {
        throw "Session 13 smoke result has an invalid root contract or non-passing status."
    }
    if ([string]$smoke.commitSha -cne $ReleaseSha) {
        throw "Session 13 smoke result does not target the promoted commit SHA."
    }
    foreach ($field in @("correlationId", "normalCorrelationId", "failureCorrelationId")) {
        if ($smoke.$field -isnot [string] -or
            [string]$smoke.$field -cnotmatch "^[0-9a-f]{32}$") {
            throw "Session 13 smoke result '$field' must be a lower-case W3C trace ID."
        }
    }
    if ([string]$smoke.correlationId -cne [string]$smoke.normalCorrelationId -or
        [string]$smoke.normalCorrelationId -ceq [string]$smoke.failureCorrelationId) {
        throw "Session 13 smoke result must bind its root correlation to distinct normal and failure traces."
    }
    foreach ($field in @("syntheticRequest", "endToEndTrace", "toolAndModelFailureSeparated")) {
        if ([string]$smoke.checks.$field -cne "passed") {
            throw "Session 13 smoke result check '$field' did not pass."
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
            throw "Session 13 smoke result check '$field' must be the JSON boolean true."
        }
    }
    foreach ($field in @("sensitiveInputPresent", "payloadsRetained")) {
        if ($smoke.checks.$field -isnot [bool] -or
            $smoke.checks.$field -ne $false) {
            throw "Session 13 smoke result check '$field' must be the JSON boolean false."
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
        throw "Session 13 smoke result must check the five required telemetry privacy surfaces."
    }
    $pollAttemptsValue = $smoke.checks.telemetryPollAttempts
    $pollTimeoutValue = $smoke.checks.telemetryPollTimeoutSeconds
    $pollRetryValue = $smoke.checks.telemetryPollRetrySeconds
    if ($smoke.checks.telemetryPollTimedOut -isnot [bool] -or
        $smoke.checks.telemetryPollTimedOut -ne $false -or
        $pollAttemptsValue -isnot [long] -or
        $pollTimeoutValue -isnot [long] -or
        $pollRetryValue -isnot [long]) {
        throw "Session 13 smoke polling fields must use the required JSON boolean and integer types."
    }
    $pollAttempts = [int]$pollAttemptsValue
    $pollTimeout = [int]$pollTimeoutValue
    $pollRetry = [int]$pollRetryValue
    if (
        $pollTimeout -lt 30 -or $pollTimeout -gt 600 -or
        $pollRetry -lt 5 -or $pollRetry -gt 60 -or
        $pollRetry -gt $pollTimeout -or
        $pollTimeout -lt (2 * $pollRetry)) {
        throw "Session 13 smoke result does not show a successful bounded telemetry-ingestion poll."
    }
    $maximumAttempts = [math]::Ceiling($pollTimeout / $pollRetry) + 1
    if ($pollAttempts -lt 3 -or $pollAttempts -gt $maximumAttempts) {
        throw "Session 13 smoke result reports an invalid telemetry polling attempt count."
    }
    $observedAt = [datetimeoffset]::MinValue
    if ($smoke.payloadsRetained -isnot [bool] -or
        $smoke.payloadsRetained -ne $false -or
        [string]$smoke.correlationId -notmatch "^[A-Za-z0-9._:-]{1,128}$" -or
        -not [datetimeoffset]::TryParse([string]$smoke.observedAt, [ref]$observedAt)) {
        throw "Session 13 smoke result must report no stored payloads and include a valid correlationId and observedAt."
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
if ([string]$control.routing.strategy -notin @("canary", "blue-green")) {
    throw "Routing strategy must be canary or blue-green."
}
if ($control.routing.existingSession06Or07SupportConfirmed -ne $true) {
    throw "Existing Session 06 or 07 routing support is not confirmed; keep 100 percent on the previous approved release."
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
    "Apply evaluation and adversarial gates before deployment",
    'SESSION13_SMOKE_URL: ${{ vars.SESSION13_SMOKE_URL }}',
    'SESSION13_SMOKE_FAILURE_URL: ${{ vars.SESSION13_SMOKE_FAILURE_URL }}',
    'SESSION13_AI_RESOURCE_ID: ${{ vars.SESSION13_AI_RESOURCE_ID }}',
    'SESSION13_LOG_ANALYTICS_WORKSPACE_ID: ${{ vars.SESSION13_LOG_ANALYTICS_WORKSPACE_ID }}',
    'SESSION13_SMOKE_TIMEOUT_SECONDS: ${{ vars.SESSION13_SMOKE_TIMEOUT_SECONDS }}',
    'SESSION13_SMOKE_RETRY_SECONDS: ${{ vars.SESSION13_SMOKE_RETRY_SECONDS }}',
    'SESSION13_SMOKE_BEARER_TOKEN: ${{ secrets.SESSION13_SMOKE_BEARER_TOKEN }}',
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
    "evaluationThresholdPolicySha256",
    "previousApprovedReleaseId"
)) {
    Assert-ImmutableValue ([string]$control.immutableRelease.$property) "immutableRelease.$property"
}
$thresholdPolicyPath = Resolve-RepositoryPath `
    $control.sourcePaths.session11ThresholdPolicy `
    "Session 11 threshold policy" `
    @(".yaml", ".yml")
$thresholdPolicyHash = (Get-FileHash -LiteralPath $thresholdPolicyPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ([string]$control.immutableRelease.evaluationThresholdPolicySha256 -cne $thresholdPolicyHash) {
    throw "immutableRelease.evaluationThresholdPolicySha256 does not match the approved Session 11 threshold policy."
}
$releasePolicyPath = Resolve-RepositoryPath `
    $control.sourcePaths.session11ReleasePolicy `
    "Session 11 release policy" `
    @(".json")
$baselineRecordPath = Resolve-RepositoryPath `
    $control.sourcePaths.session11BaselineRecord `
    "Session 11 approved baseline record" `
    @(".json")
$candidateRecordPath = Resolve-RepositoryPath `
    $control.sourcePaths.session11CandidateRecord `
    "Session 11 candidate record" `
    @(".json")
$releasePolicy = Read-JsonObject $releasePolicyPath
$baselineRecord = Read-JsonObject $baselineRecordPath
$candidateRecord = Read-JsonObject $candidateRecordPath
Assert-ImplementationMarker $releasePolicy "Session 11 release policy" "11-foundry-evaluations-quality-gates"
Assert-ImplementationMarker $baselineRecord "Session 11 baseline record" "11-foundry-evaluations-quality-gates"
Assert-ImplementationMarker $candidateRecord "Session 11 candidate record" "11-foundry-evaluations-quality-gates"
if ($releasePolicy.schemaVersion -ne 2) {
    throw "Session 11 release policy must use schemaVersion 2."
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
    throw "Session 11 release policy has an unexpected activationContract schema."
}
foreach ($field in $expectedActivationContract.Keys) {
    $expectedValue = $expectedActivationContract[$field]
    $actualValue = $releasePolicy.activationContract.$field
    if (($expectedValue -is [bool] -and $actualValue -isnot [bool]) -or
        $actualValue -cne $expectedValue) {
        throw "Session 11 release policy activationContract.$field is not the required value."
    }
}
if ([string]$releasePolicy.gate.callableInterface.requiredEnforcementOption -cne
    "--require-enabled") {
    throw "Session 11 callable release gate must require --require-enabled."
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
    throw "Session 11 release policy must have enabled state and an approved decision date."
}
if ($decisionDate.Date -gt [datetime]::UtcNow.Date) {
    throw "Session 11 release policy decisionDate cannot be in the future."
}
if ([string]$releasePolicy.target.agentName -cne [string]$control.immutableRelease.agentName -or
    [string]$releasePolicy.target.candidateVersion -cne [string]$control.immutableRelease.agentVersion -or
    [string]$baselineRecord.run.target.name -cne [string]$control.immutableRelease.agentName -or
    [string]$candidateRecord.run.target.name -cne [string]$control.immutableRelease.agentName -or
    [string]$baselineRecord.run.target.version -cne [string]$releasePolicy.target.approvedVersion -or
    [string]$candidateRecord.run.target.version -cne [string]$control.immutableRelease.agentVersion) {
    throw "Session 11 release policy and records must target the approved agent name and immutable versions."
}
if ([string]$releasePolicy.gate.baselineRunId -cne [string]$baselineRecord.run.runId -or
    [string]$releasePolicy.gate.candidateRunId -cne [string]$candidateRecord.run.runId -or
    [string]$candidateRecord.run.runId -cne [string]$control.immutableRelease.evaluationRunId) {
    throw "Session 11 release-policy run IDs must match the baseline, candidate, and immutable release."
}
$releaseGatePath = Resolve-RepositoryPath `
    $control.sourcePaths.session11ReleaseGate `
    "Session 11 release gate" `
    @(".py")
& python $releaseGatePath `
    --policy $thresholdPolicyPath `
    --validate-policy `
    --phase candidate
if ($LASTEXITCODE -ne 0) {
    throw "Session 11 threshold policy must be active and approved for candidate gating."
}

foreach ($entry in @(
    @($control.sourcePaths.bicepEntrypoint, "Bicep entrypoint", @(".bicep")),
    @($control.sourcePaths.apimPolicy, "APIM policy", @(".xml")),
    @($control.sourcePaths.unitTestScript, "unit-test script", @(".ps1")),
    @($control.sourcePaths.session13SmokePowerShell, "Session 13 PowerShell smoke script", @(".ps1")),
    @($control.sourcePaths.session13SmokeBash, "Session 13 Bash smoke script", @(".sh")),
    @($control.sourcePaths.routingControlScript, "routing-control script", @(".ps1")),
    @($control.sourcePaths.releaseStoreScript, "approved release-store script", @(".ps1"))
)) {
    $null = Resolve-RepositoryPath $entry[0] $entry[1] $entry[2]
}

foreach ($pair in @(
    @($nonproductionParameters, "nonproduction"),
    @($productionParameters, "production")
)) {
    $parameters = $pair[0].parameters
    $environmentName = $pair[1]
    if ([string]$parameters.environment.value -ne $environmentName -or
        [string]$parameters.implementationSession.value -ne "14-cicd-promotion-controls") {
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
        Invoke-Session11Gate $control.sourcePaths.session11CandidateRecord "pass"
        Invoke-Session11BlockedSelfTest
        Assert-AdversarialReport
        Write-Host "PASS: Session 11 permitted path, generated blocked self-test, and confirmed Session 12 adversarial report are ready."
    }
    "Smoke" {
        if ([string]::IsNullOrWhiteSpace($SmokeResultPath)) {
            throw "-SmokeResultPath is required for Smoke mode."
        }
        Assert-SmokeResult $SmokeResultPath
        Write-Host "PASS: Session 13 smoke and observability result is complete and payload-safe."
    }
    "Intended" {
        if ([string]::IsNullOrWhiteSpace($SmokeResultPath)) {
            throw "-SmokeResultPath is required for Intended mode."
        }
        $selectedCandidate = if ([string]::IsNullOrWhiteSpace($CandidateRecordPath)) {
            [string]$control.sourcePaths.session11CandidateRecord
        }
        else {
            $CandidateRecordPath
        }
        Invoke-Session11Gate $selectedCandidate "pass"
        Assert-AdversarialReport
        Assert-SmokeResult $SmokeResultPath
        Write-Host "PASS: intended quality, adversarial, and smoke gates permit production approval."
    }
    "Blocked" {
        Invoke-Session11BlockedSelfTest
        Write-Host "PASS: the Session 11 generated blocked-tool-process self-test returned BLOCK."
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
            "__RUNTIME_BICEP_ENTRYPOINT__" = $runtime.bicepEntrypoint
            "__RUNTIME_BICEP_TEMPLATE_SHA256__" = $runtime.bicepTemplateSha256
            "__RUNTIME_PROMPT_VERSION__" = $runtime.promptVersion
            "__RUNTIME_AGENT_NAME__" = $runtime.agentName
            "__RUNTIME_AGENT_VERSION__" = $runtime.agentVersion
            "__RUNTIME_MODEL_DEPLOYMENT_ALIAS__" = $runtime.modelDeploymentAlias
            "__RUNTIME_APIM_POLICY_SHA256__" = $runtime.apimPolicySha256
            "__RUNTIME_APIM_POLICY_VERSION__" = $runtime.apimPolicyVersion
            "__RUNTIME_EVALUATION_RUN_ID__" = $runtime.evaluationRunId
            "__RUNTIME_EVALUATION_THRESHOLD_POLICY_VERSION__" = $runtime.evaluationThresholdPolicyVersion
            "__RUNTIME_EVALUATION_THRESHOLD_POLICY_SHA256__" = $runtime.evaluationThresholdPolicySha256
            "__RUNTIME_ADVERSARIAL_REPORT_SHA256__" = $runtime.adversarialReportSha256
            "__RUNTIME_NONPRODUCTION_DEPLOYMENT_ID__" = $runtime.nonproductionDeploymentId
            "__RUNTIME_PRODUCTION_APPROVAL_RECORD_URL__" = $runtime.productionApprovalRecordUrl
            "__RUNTIME_PRODUCTION_APPROVER_ROLE__" = $runtime.productionApproverRole
            "__RUNTIME_ROUTING_STRATEGY__" = $runtime.routingStrategy
            "__RUNTIME_CANDIDATE_SELECTOR__" = $runtime.candidateSelector
            "__RUNTIME_STABLE_SELECTOR__" = $runtime.stableSelector
            "__RUNTIME_PREVIOUS_APPROVED_RELEASE_ID__" = $runtime.previousApprovedReleaseId
            "__RUNTIME_GITHUB_ACTIONS_RUN_URL__" = $runtime.githubActionsRunUrl
            "__RUNTIME_APPROVED_RELEASE_STORE__" = $runtime.approvedReleaseStore
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
