[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter()]
    [ValidateSet("PrepareTaxonomy", "Baseline", "PostRemediation")]
    [string]$Phase = "PrepareTaxonomy"
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

$implementationSession = "12-red-teaming-threat-defense"
$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$authorizationPath = Join-Path $artifactRoot "red-team\authorization-scope.json"
$attackPlanPath = Join-Path $artifactRoot "red-team\attack-plan.json"
$taxonomyChecklistPath = Join-Path $artifactRoot "red-team\taxonomy-review-checklist.md"
$safeSeedExamplesPath = Join-Path $artifactRoot "red-team\safe-seed-examples.json"
$releaseGateMappingPath = Join-Path $artifactRoot "governance\release-gate-mapping.md"
$handoffPath = Join-Path $artifactRoot "governance\risk-change-handoff.json"
$scorecardTemplatePath = Join-Path $artifactRoot "reports\red-team-scorecard-template.json"
$evidenceRetentionPath = Join-Path $artifactRoot "reports\evidence-retention-record.md"
$huntPath = Join-Path $artifactRoot "defender\ai-alert-hunt.kql"
$playbookPath = Join-Path $artifactRoot "operations\soc-triage-playbook.md"
$runnerPath = Join-Path $PSScriptRoot "run-red-team.py"
$comparePath = Join-Path $PSScriptRoot "compare-runs.py"
$requirementsPath = Join-Path $PSScriptRoot "requirements.txt"
$requiredFiles = @(
    $authorizationPath
    $attackPlanPath
    $taxonomyChecklistPath
    $safeSeedExamplesPath
    $releaseGateMappingPath
    $handoffPath
    $scorecardTemplatePath
    $evidenceRetentionPath
    $huntPath
    $playbookPath
    $runnerPath
    $comparePath
    $requirementsPath
)
$requiredSentinels = @(
    "__REQUIRED_AGENT_NAME__"
    "__REQUIRED_AGENT_OWNER_ROLE__"
    "__REQUIRED_AGENT_VERSION__"
    "__REQUIRED_AUTHORIZATION_DATE__"
    "__REQUIRED_AUTHORIZATION_EXPIRY__"
    "__REQUIRED_AUTHORIZATION_ID__"
    "__REQUIRED_CONNECTED_OR_NOT_APPLICABLE__"
    "__REQUIRED_CHANGE_REFERENCE__"
    "__REQUIRED_COST_OWNER_ROLE__"
    "__REQUIRED_CURRENT_SUPPORT_STATUS_SUPPORTED__"
    "__REQUIRED_DEFENDER_CONFIRMATION_DATE__"
    "__REQUIRED_DEFENDER_FOR_CLOUD_OR_AGENT365__"
    "__REQUIRED_DEFENDER_INCIDENT_SENTINEL_INCIDENT_OR_ITSM__"
    "__REQUIRED_DEFENDER_OWNER_ROLE__"
    "__REQUIRED_ENABLED__"
    "__REQUIRED_ENABLED_OR_DISABLED__"
    "__REQUIRED_FOUNDRY_PROJECT_ALIAS__"
    "__REQUIRED_JUDGE_MODEL_DEPLOYMENT_ALIAS__"
    "__REQUIRED_POST_REMEDIATION_AGENT_VERSION__"
    "__REQUIRED_PROMPT_EVIDENCE_ACCESS_ROLE__"
    "__REQUIRED_RED_TEAM_REGION__"
    "__REQUIRED_REMEDIATION_COMMIT__"
    "__REQUIRED_RELEASE_OWNER_ROLE__"
    "__REQUIRED_RESIDUAL_RISK_AUTHORITY_ROLE__"
    "__REQUIRED_SECURITY_OWNER_ROLE__"
    "__REQUIRED_SOC_DESTINATION_ALIAS__"
    "__REQUIRED_SOC_OWNER_ROLE__"
    "__REQUIRED_STOP_CONTACT_ROLE__"
    "__REQUIRED_SUPPORT_CHECK_DATE__"
    "__REQUIRED_SUBSCRIPTION_ALIAS__"
    "__REQUIRED_TAXONOMY_NAME__"
    "__REQUIRED_TOOL_OWNER_ROLE__"
    "__REQUIRED_YES_OR_NO__"
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

$sentinelMatches = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
if ($sentinelMatches.Count -gt 0) {
    $unresolved = @($sentinelMatches.Matches.Value | Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit Session 12 preflight checks for new sentinels: $($unknown -join ', ')."
    }
    if ($unresolved.Count -gt 0) {
        throw "Resolve every Session 12 decision required for $Phase before continuing: $($unresolved -join ', ')."
    }
}

$jsonFiles = @(
    $authorizationPath
    $attackPlanPath
    $safeSeedExamplesPath
    $handoffPath
)
foreach ($path in $jsonFiles) {
    $null = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -ErrorAction Stop
}

$authorization = Get-Content -LiteralPath $authorizationPath -Raw | ConvertFrom-Json -ErrorAction Stop
$attackPlan = Get-Content -LiteralPath $attackPlanPath -Raw | ConvertFrom-Json -ErrorAction Stop
$safeSeeds = Get-Content -LiteralPath $safeSeedExamplesPath -Raw | ConvertFrom-Json -ErrorAction Stop
$handoff = Get-Content -LiteralPath $handoffPath -Raw | ConvertFrom-Json -ErrorAction Stop

foreach ($record in @(
    $authorization
    $attackPlan
    $safeSeeds
    $handoff
)) {
    if ([string]$record.implementationSession -ne $implementationSession) {
        throw "A implementation file has the wrong implementationSession marker."
    }
}

if (-not [bool]$safeSeeds.targetBoundary.syntheticDataOnly -or
    [bool]$safeSeeds.targetBoundary.writeCapableToolsAllowed -or
    [bool]$safeSeeds.customerSeedBoundary.storeCustomerSeedsInRepository -or
    -not [bool]$safeSeeds.customerSeedBoundary.retainAggregateOnly) {
    throw "Safe seed examples must stay synthetic, read-only, and outside repository retention."
}
foreach ($seed in @($safeSeeds.seedExamples)) {
    $seedText = "$($seed.objectiveSummary) $($seed.expectedSafeBehavior)"
    if ([bool]$seed.containsAttackPrompt -or
        $seedText -match "(?i)ignore previous instructions|bypass|exfiltrate|secret key") {
        throw "Safe seed examples must not become reusable adversarial prompt text."
    }
}

$agentName = [string]$authorization.target.agentName
$baselineVersion = [string]$authorization.target.agentVersion
$postVersion = [string]$handoff.target.postRemediationVersion
if ($agentName -ne [string]$authorization.target.agentName -or
    $agentName -ne [string]$attackPlan.target.name -or
    $agentName -ne [string]$handoff.target.agentName) {
    throw "The agent name is inconsistent across implementation files."
}
if ($baselineVersion -ne [string]$authorization.target.agentVersion -or
    $baselineVersion -ne [string]$attackPlan.target.version -or
    $baselineVersion -ne [string]$handoff.target.baselineVersion) {
    throw "The baseline agent version is inconsistent across implementation files."
}
if ($baselineVersion -eq $postVersion) {
    throw "The post-remediation agent version must be a new immutable version."
}
if ([string]$authorization.target.foundryProjectAlias -ne [string]$handoff.target.foundryProjectAlias) {
    throw "The approved Foundry project alias is inconsistent."
}
if ([string]$authorization.target.subscriptionAlias -ne [string]$handoff.target.subscriptionAlias) {
    throw "The authorization and risk/change handoff must use the same subscription alias."
}

if (-not [bool]$authorization.safety.customerAuthorized -or
    -not [bool]$authorization.safety.agentOwnerPresent -or
    -not [bool]$authorization.safety.securityOwnerPresent -or
    -not [bool]$authorization.safety.socOwnerOnCall -or
    -not [bool]$authorization.safety.previewApiAccepted -or
    -not [bool]$authorization.safety.projectManagedIdentityFoundryUserConfirmed -or
    -not [bool]$authorization.safety.redTeamBudgetApproved -or
    [bool]$authorization.safety.stableEndpointChangeAllowed -or
    [bool]$authorization.safety.writeCapableToolsAllowed) {
    throw "Red-team authorization, owner presence, stop contact, or tool boundary is incomplete."
}
if (-not [bool]$authorization.dataHandling.syntheticInputsOnly -or
    [bool]$authorization.dataHandling.productionDataAllowed -or
    -not [bool]$authorization.dataHandling.rawAttackPayloadsRemainInFoundry -or
    -not [bool]$authorization.dataHandling.repositoryContainsAggregateMetricsOnly) {
    throw "The authorization data-handling boundary is not safe."
}
$authorizedOn = [datetime]::ParseExact(
    [string]$authorization.approvedOn,
    "yyyy-MM-dd",
    [Globalization.CultureInfo]::InvariantCulture
)
$expiresOn = [datetime]::ParseExact(
    [string]$authorization.expiresOn,
    "yyyy-MM-dd",
    [Globalization.CultureInfo]::InvariantCulture
)
if ($expiresOn -lt $authorizedOn -or $expiresOn.Date -lt (Get-Date).Date) {
    throw "The red-team authorization is expired or has an invalid date range."
}

$supportGate = $authorization.currentSupportGate
if (-not [bool]$supportGate.manualGateRequired -or
    [bool]$supportGate.stableDiscoveryApiAvailable -or
    [string]$supportGate.status -ne "supported") {
    throw "The manual current-support gate must record supported; no stable discovery API is assumed."
}
$supportCheckedOn = [datetime]::ParseExact(
    [string]$supportGate.checkedOn,
    "yyyy-MM-dd",
    [Globalization.CultureInfo]::InvariantCulture
)
if ($supportCheckedOn.Date -ne (Get-Date).Date) {
    throw "Check current Microsoft cloud red-teaming support documentation on the day of the run."
}
$region = ([string]$authorization.target.region).ToLowerInvariant().Replace(" ", "")
if ([string]$attackPlan.sdk.apiVersion -ne "2025-11-15-preview") {
    throw "The attack plan must pin the currently verified preview API version."
}
$requiredCriteria = @(
    "builtin.prohibited_actions"
    "builtin.task_adherence"
    "builtin.sensitive_data_leakage"
)
$criteria = @($attackPlan.testingCriteria | ForEach-Object { [string]$_.evaluatorName })
foreach ($required in $requiredCriteria) {
    if ($required -notin $criteria) {
        throw "Required agentic evaluator is missing: $required"
    }
}
$requiredStrategies = @("Jailbreak", "Flip", "Base64", "IndirectJailbreak")
foreach ($required in $requiredStrategies) {
    if ($required -notin @($attackPlan.attackStrategies)) {
        throw "Required direct, encoded, or indirect attack strategy is missing: $required"
    }
}
if (-not [bool]$attackPlan.resultHandling.retainAggregateOnly -or
    [bool]$attackPlan.resultHandling.retainAttackPromptsInRepository -or
    [bool]$attackPlan.resultHandling.retainAgentResponsesInRepository -or
    [bool]$attackPlan.resultHandling.retainToolPayloadsInRepository -or
    -not [bool]$attackPlan.resultHandling.humanReviewRequired) {
    throw "The attack-plan result handling must remain aggregate and payload-free."
}

$defender = $handoff.defender
if ([string]$defender.aiServicesThreatProtection.planState -ne "enabled") {
    throw "Defender for Cloud AI services threat protection must be enabled for the approved subscription."
}
if ([string]$defender.aiServicesThreatProtection.suspiciousPromptEvidence -notin @("enabled", "disabled") -or
    [string]$authorization.dataHandling.promptEvidenceSetting -ne
        [string]$defender.aiServicesThreatProtection.suspiciousPromptEvidence) {
    throw "The prompt-evidence decision must be enabled or disabled and agree with authorization."
}
if ([string]$defender.aiServicesThreatProtection.suspiciousPromptEvidence -eq "enabled" -and
    -not [bool]$defender.aiServicesThreatProtection.promptEvidenceDataHandlingApproved) {
    throw "Enabled prompt evidence requires an explicit data-handling approval."
}
if ([string]$defender.agent365.applicable -notin @("yes", "no")) {
    throw "Agent 365 applicability must be yes or no."
}
if ([string]$defender.selectedSignalPath -notin @(
    "defender-for-cloud-ai-services"
    "agent365-defender-preview"
)) {
    throw "Select the supported Defender signal path."
}
if ([string]$defender.selectedSignalPath -eq "agent365-defender-preview" -and
    ([string]$defender.agent365.applicable -ne "yes" -or
     -not [bool]$defender.agent365.onboarded -or
     [string]$defender.agent365.microsoft365Connector -ne "connected")) {
    throw "The Agent 365 preview signal path requires onboarding and a connected Microsoft 365 connector."
}
if ([bool]$defender.agent365.usedAsSoleOperationalControl) {
    throw "Public-preview Agent 365 detection cannot be the sole operational control."
}
$socDelivery = $handoff.socDelivery
if ([string]$socDelivery.source -ne [string]$defender.selectedSignalPath -or
    [string]$socDelivery.routeType -notin @("defender-incident", "sentinel-incident", "itsm-connector")) {
    throw "The SOC route must use the selected Defender source and an approved route type."
}

if ($Phase -ne "PrepareTaxonomy") {
    if (-not [bool]$attackPlan.taxonomy.customerReviewed -or
        [string]::IsNullOrWhiteSpace([string]$attackPlan.taxonomy.approvedTaxonomyId)) {
        throw "Review the generated taxonomy and save its approved taxonomy ID in the attack plan before a red-team run."
    }
}
$remediation = $handoff.remediation
if ([string]$remediation.status -ne "applied-to-new-version") {
    throw "Pre-work must apply the owned remediation to a new immutable version before this session."
}
foreach ($change in @($remediation.changes)) {
    if ([string]$change.status -ne "applied") {
        throw "Every approved remediation change must be applied before this session."
    }
}
if ($Phase -eq "PostRemediation") {
    $baselineRecord = Join-Path $artifactRoot "reports\baseline-aggregate.json"
    if (-not (Test-Path -LiteralPath $baselineRecord -PathType Leaf)) {
        throw "The payload-free baseline aggregate is required before the post-remediation run."
    }
}

& python -c "import azure.ai.projects, azure.identity, openai" 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "Install the Session 12 Python dependencies: python -m pip install -r `"$requirementsPath`""
}

$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using authorization-scope.json targetSubscriptionAlias."
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
    throw "FOUNDRY_RESOURCE_ID must resolve to the approved AIServices resource in the approved region."
}

$phaseArgument = switch ($Phase) {
    "PostRemediation" { "post-remediation" }
    default { "baseline" }
}
& python $runnerPath --config $attackPlanPath --phase $phaseArgument --check-only
if ($LASTEXITCODE -ne 0) {
    throw "The approved Foundry project, judge model, or exact agent version could not be resolved."
}

Write-Host "Red-team safe preview (read-only):"
Write-Host "  Subscription alias: $($authorization.target.subscriptionAlias)"
Write-Host "  Foundry project alias: $($authorization.target.foundryProjectAlias)"
Write-Host "  Region: $($authorization.target.region)"
Write-Host "  Agent/version: $agentName / $(if ($Phase -eq 'PostRemediation') { $postVersion } else { $baselineVersion })"
Write-Host "  Strategies: $(@($attackPlan.attackStrategies) -join ', ')"
Write-Host "  Evaluators: $($criteria -join ', ')"
Write-Host "  Defender route: $($defender.selectedSignalPath) -> $($socDelivery.routeType) -> $($socDelivery.destinationAlias)"
Write-Host "  Repository output: aggregate metrics and alert/incident references only"
Write-Host "Read-only deployment preview is unsupported by the red-team API. No taxonomy or run was created."
Write-Host "PASS: Session 12 authorization, current manual support gate, risk/change handoff, Foundry target, and $Phase phase are ready."
