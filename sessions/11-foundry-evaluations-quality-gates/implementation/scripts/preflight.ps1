[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter()]
    [ValidateSet("Baseline", "Candidate")]
    [string]$Phase = "Baseline"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-AzJson {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $raw = & az @Arguments --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return (($raw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
}

$implementationSession = "11-foundry-evaluations-quality-gates"
$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$releasePolicyPath = Join-Path $artifactRoot "release\release-policy.json"
$specPath = Join-Path $artifactRoot "eval\evaluation-spec.json"
$datasetPath = Join-Path $artifactRoot "eval\data\golden-v1.jsonl"
$thresholdsPath = Join-Path $artifactRoot "eval\thresholds.yaml"
$runnerPath = Join-Path $PSScriptRoot "run-evaluation.py"
$gatePath = Join-Path $PSScriptRoot "release-gate.py"
$gateTestPath = Join-Path $PSScriptRoot "test_release_gate.py"
$requirementsPath = Join-Path $PSScriptRoot "requirements.txt"
$requiredFiles = @(
    $releasePolicyPath
    $specPath
    $datasetPath
    $thresholdsPath
    $runnerPath
    $gatePath
    $gateTestPath
    $requirementsPath
)
$requiredSentinels = @(
    "__REQUIRED_AGENT_NAME__"
    "__REQUIRED_APPROVED_AGENT_VERSION__"
    "__REQUIRED_CANDIDATE_AGENT_VERSION__"
    "__REQUIRED_COST_OWNER_ROLE__"
    "__REQUIRED_CURRENT_SUPPORT_STATUS_SUPPORTED__"
    "__REQUIRED_EVALUATION_REGION__"
    "__REQUIRED_EXCEPTION_AUTHORITY_ROLE__"
    "__REQUIRED_FOUNDRY_PROJECT_ALIAS__"
    "__REQUIRED_GOLDEN_DATASET_SHA256__"
    "__REQUIRED_JUDGE_MODEL_DEPLOYMENT_ALIAS__"
    "__REQUIRED_NETWORK_MODE_PUBLIC_OR_ISOLATED__"
    "__REQUIRED_QUALITY_OWNER_ROLE__"
    "__REQUIRED_RELEASE_OWNER_ROLE__"
    "__REQUIRED_SAFETY_OWNER_ROLE__"
    "__REQUIRED_SUPPORT_CHECK_DATE__"
    "__REQUIRED_TOOL_EVALUATOR_COMPATIBILITY_STATUS__"
    "__REQUIRED_TOOL_OWNER_ROLE__"
)

foreach ($command in @("az", "python")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required."
    }
}
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }
}

$sentinels = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinels.Count -gt 0) {
    $unresolved = @($sentinels.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Session 11 preflight checks for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every Session 11 customer decision before running evaluation: $($unresolved -join ', ')."
}

$jsonFiles = @(
    $releasePolicyPath
    $specPath
)
foreach ($path in $jsonFiles) {
    $null = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -ErrorAction Stop
}
$releasePolicy = Get-Content -LiteralPath $releasePolicyPath -Raw | ConvertFrom-Json -ErrorAction Stop
$spec = Get-Content -LiteralPath $specPath -Raw | ConvertFrom-Json -ErrorAction Stop

foreach ($record in @($releasePolicy, $spec)) {
    if ([string]$record.implementationSession -ne $implementationSession) {
        throw "A implementation file has the wrong implementationSession marker."
    }
}
if ([string]$releasePolicy.target.agentName -ne [string]$spec.target.agentName) {
    throw "The release policy and evaluation specification must target the same agent."
}
if ([string]$releasePolicy.target.approvedVersion -ne [string]$spec.target.approvedVersion) {
    throw "The approved agent version differs between the release policy and evaluation specification."
}
if ([string]$releasePolicy.target.candidateVersion -ne [string]$spec.target.candidateVersion) {
    throw "The candidate agent version differs between the release policy and evaluation specification."
}
if ([string]$releasePolicy.target.approvedVersion -eq [string]$releasePolicy.target.candidateVersion) {
    throw "The approved and candidate agent versions must be different immutable versions."
}
if ([int]$releasePolicy.schemaVersion -ne 2 -or
    [string]$releasePolicy.activationContract.requiredState -ne "enabled" -or
    [string]$releasePolicy.activationContract.requiredDecision -ne "approved" -or
    -not [bool]$releasePolicy.activationContract.decisionDateRequired -or
    [string]$releasePolicy.activationContract.thresholdPolicyState -ne "active" -or
    [string]$releasePolicy.activationContract.thresholdPolicyPath -ne "implementation/artifacts/eval/thresholds.yaml" -or
    -not [bool]$releasePolicy.activationContract.baselineRunIdMustMatchThresholdPolicyAndBaselineRecord -or
    -not [bool]$releasePolicy.activationContract.candidateRunIdMustMatchCandidateRecord) {
    throw "The release policy activation contract has changed or is incomplete."
}
if ([string]$releasePolicy.gate.callableInterface.requiredEnforcementOption -ne "--require-enabled") {
    throw "The callable gate must require the --require-enabled enforcement option."
}
if ([string]$releasePolicy.gate.state -eq "enabled") {
    if ([string]$releasePolicy.gate.decision -ne "approved" -or
        [string]::IsNullOrWhiteSpace([string]$releasePolicy.gate.decisionDate) -or
        [string]::IsNullOrWhiteSpace([string]$releasePolicy.gate.baselineRunId) -or
        [string]::IsNullOrWhiteSpace([string]$releasePolicy.gate.candidateRunId)) {
        throw "An enabled gate needs an approved dated decision and baseline and candidate run IDs."
    }
    [void][datetime]::ParseExact(
        [string]$releasePolicy.gate.decisionDate,
        "yyyy-MM-dd",
        [Globalization.CultureInfo]::InvariantCulture
    )
}
if ([string]$releasePolicy.target.networkMode -notin @("public", "isolated")) {
    throw "networkMode must be public or isolated."
}
if (-not [bool]$releasePolicy.currentSupportGate.manualGateRequired -or
    [bool]$releasePolicy.currentSupportGate.stableDiscoveryApiAvailable -or
    [string]$releasePolicy.currentSupportGate.status -ne "supported") {
    throw "The manual current-support gate must record supported; no stable discovery API is assumed."
}
$protectedMaterialDecision = $releasePolicy.currentSupportGate.protectedMaterialDecision
if (-not [bool]$protectedMaterialDecision.blocking -or
    [string]$protectedMaterialDecision.requiredRegion -ne "East US 2" -or
    [string]$protectedMaterialDecision.ifUnavailable -ne "stop-and-relocate-or-revise-policy") {
    throw "The protected-material decision must keep the blocking metric in East US 2 or stop for an explicit policy revision."
}
$supportCheckedOn = [datetime]::ParseExact(
    [string]$releasePolicy.currentSupportGate.checkedOn,
    "yyyy-MM-dd",
    [Globalization.CultureInfo]::InvariantCulture
)
if ($supportCheckedOn.Date -ne (Get-Date).Date) {
    throw "Check current Microsoft evaluation support documentation on the day of the run."
}
if (-not [bool]$releasePolicy.currentSupportGate.confirmedCapabilities.batchEvaluation -or
    -not [bool]$releasePolicy.currentSupportGate.confirmedCapabilities.selectedRiskAndSafetyEvaluators -or
    -not [bool]$releasePolicy.currentSupportGate.confirmedCapabilities.protectedMaterialEvaluator -or
    -not [bool]$releasePolicy.capability.projectManagedIdentityFoundryUserConfirmed -or
    -not [bool]$releasePolicy.capability.evaluationBudgetApproved) {
    throw "Current evaluator support, project identity access, and evaluation budget must be confirmed."
}
if ([string]$releasePolicy.target.networkMode -eq "isolated" -and
    -not [bool]$releasePolicy.capability.subnetDelegationConfirmed) {
    throw "The release policy must confirm subnet delegation for isolated evaluation."
}
if ([bool]$releasePolicy.capability.previewEvaluators.allowedAsSoleBlockingControl) {
    throw "Preview evaluators cannot be the sole blocking control."
}
$toolCompatibility = $releasePolicy.capability.toolEvaluatorCompatibility
if ([string]$toolCompatibility.status -ne "approved" -or
    [bool]$toolCompatibility.limitedSupportToolPresent -or
    (@($toolCompatibility.evaluatedToolTypes) -join ",") -ne "Function Tool") {
    throw "The tool owner must approve tool-call evaluators for the supported Function Tool path."
}

$region = ([string]$releasePolicy.target.evaluationRegion).ToLowerInvariant().Replace(" ", "")
if ($region -ne "eastus2") {
    throw "The blocking protected_material evaluator requires East US 2. Relocate or revise the policy before running."
}

$rows = @(Get-Content -LiteralPath $datasetPath | Where-Object { $_.Trim().Length -gt 0 })
if ($rows.Count -lt [int]$spec.dataset.minimumCases -or
    $rows.Count -gt [int]$spec.dataset.maximumCases) {
    throw "The golden dataset row count is outside the approved bounds."
}
$categories = @()
$caseIds = @()
foreach ($line in $rows) {
    if ([Text.Encoding]::UTF8.GetByteCount($line) -gt [int]$spec.dataset.maximumBytesPerRow) {
        throw "A golden dataset row exceeds the current 2 MB service limit."
    }
    $row = $line | ConvertFrom-Json -ErrorAction Stop
    $categories += [string]$row.category
    $caseIds += [string]$row.case_id
    if ([string]::IsNullOrWhiteSpace([string]$row.query) -or
        [string]::IsNullOrWhiteSpace([string]$row.expected_behavior)) {
        throw "Every golden case needs a query and expected_behavior."
    }
}
if (($caseIds | Sort-Object -Unique).Count -ne $caseIds.Count) {
    throw "Golden dataset case_id values must be unique."
}
foreach ($requiredCategory in @($spec.dataset.requiredCategories)) {
    if ([string]$requiredCategory -notin $categories) {
        throw "Golden dataset category is missing: $requiredCategory"
    }
}

$evaluatorNames = @($spec.evaluators | ForEach-Object { [string]$_.name })
if (($evaluatorNames | Sort-Object -Unique).Count -ne $evaluatorNames.Count) {
    throw "Evaluator names must be unique."
}
foreach ($evaluator in @($spec.evaluators)) {
    if ([bool]$evaluator.preview -and [bool]$evaluator.blockingEligible) {
        throw "Preview evaluator $($evaluator.name) cannot be blocking-eligible."
    }
    $evaluatorsByName = @{}
    foreach ($evaluator in @($spec.evaluators)) {
        $evaluatorsByName[[string]$evaluator.name] = $evaluator
    }
    foreach ($previewSafetyName in @("prohibited_actions", "sensitive_data_leakage")) {
        $previewSafety = $evaluatorsByName[$previewSafetyName]
        if ($null -eq $previewSafety -or
            [string]$previewSafety.layer -ne "safety" -or
            -not [bool]$previewSafety.preview -or
            [bool]$previewSafety.blockingEligible) {
            throw "$previewSafetyName must remain a nonblocking preview safety evaluator."
        }
    }
    if ([string]$evaluator.layer -notin @("final-answer-quality", "tool-process", "safety")) {
        throw "Evaluator $($evaluator.name) has an unknown metric layer."
    }
}
if (-not [bool]$spec.resultHandling.retainAggregateOnly -or
    [bool]$spec.resultHandling.retainOutputItemsInRepository -or
    [bool]$spec.resultHandling.retainEvaluatorReasonsInRepository) {
    throw "Release records must remain aggregate and payload-free."
}

& python -c "import azure.ai.projects, azure.identity, openai, yaml" 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "Install the Session 11 Python dependencies: python -m pip install -r `"$requirementsPath`""
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}
$foundryResourceId = [Environment]::GetEnvironmentVariable("FOUNDRY_RESOURCE_ID")
$projectEndpoint = [Environment]::GetEnvironmentVariable("FOUNDRY_PROJECT_ENDPOINT")
$judgeModel = [Environment]::GetEnvironmentVariable("FOUNDRY_MODEL_NAME")
if ([string]::IsNullOrWhiteSpace($foundryResourceId) -or
    $foundryResourceId -notlike "/subscriptions/$ApprovedSubscriptionId/*") {
    throw "FOUNDRY_RESOURCE_ID must identify the approved Foundry resource in the approved subscription."
}
if ([string]::IsNullOrWhiteSpace($projectEndpoint) -or
    $projectEndpoint -notmatch "^https://[^/]+\.services\.ai\.azure\.com/api/projects/[^/]+$") {
    throw "FOUNDRY_PROJECT_ENDPOINT must be the approved HTTPS project endpoint."
}
if ([string]::IsNullOrWhiteSpace($judgeModel)) {
    throw "FOUNDRY_MODEL_NAME must name the approved judge-model deployment."
}
$foundry = Invoke-AzJson -Arguments @(
    "resource", "show", "--ids", $foundryResourceId
) -Description "Foundry resource lookup"
if ([string]$foundry.kind -ne "AIServices" -or
    ([string]$foundry.location).ToLowerInvariant().Replace(" ", "") -ne $region) {
    throw "FOUNDRY_RESOURCE_ID must resolve to the approved AIServices resource in the approved evaluation region."
}

$policyPhase = $Phase.ToLowerInvariant()
& python $gatePath --policy $thresholdsPath --validate-policy --phase $policyPhase
if ($LASTEXITCODE -ne 0) {
    throw "The release threshold policy is not valid for the $Phase phase."
}
& python $runnerPath --spec $specPath --check-only
if ($LASTEXITCODE -ne 0) {
    throw "The Foundry project, judge model, or approved agent versions could not be resolved."
}

$datasetHash = (Get-FileHash -LiteralPath $datasetPath -Algorithm SHA256).Hash.ToLowerInvariant()
$targetVersion = if ($Phase -eq "Baseline") {
    [string]$releasePolicy.target.approvedVersion
}
else {
    [string]$releasePolicy.target.candidateVersion
}
Write-Host "Evaluation preview (read-only):"
Write-Host "  Project alias: $($releasePolicy.target.foundryProjectAlias)"
Write-Host "  Region: $($releasePolicy.target.evaluationRegion)"
Write-Host "  Agent: $($releasePolicy.target.agentName)"
Write-Host "  Phase/version: $Phase / $targetVersion"
Write-Host "  Golden cases: $($rows.Count); SHA-256: $datasetHash"
Write-Host "  Evaluators: $($evaluatorNames -join ', ')"
Write-Host "  Repository output: aggregate metrics only"
Write-Host "Read-only deployment preview is unsupported by the Evals API. The safe preview is the exact scope above; the stable endpoint remains pinned."
Write-Host "PASS: Session 11 release policy, current manual support gate, Foundry target, dataset, dependencies, and $Phase gate are ready."
