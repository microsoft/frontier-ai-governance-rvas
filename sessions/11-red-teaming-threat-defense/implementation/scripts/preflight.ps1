[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern("^[0-9a-fA-F-]{36}$")]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ExpectedRegion,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$AuthorizationReference,

    [Parameter(Mandatory)]
    [ValidatePattern("^\d{4}-\d{2}-\d{2}$")]
    [string]$SupportConfirmedOn,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SocRouteReference,

    [Parameter()]
    [ValidateSet("PrepareTaxonomy", "Baseline", "PostRemediation")]
    [string]$Phase = "PrepareTaxonomy",

    [Parameter()]
    [string]$TaxonomyId,

    [Parameter()]
    [string]$PostRemediationVersion
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-AzJson {
    param([string[]]$Arguments, [string]$Description)
    $raw = & az @Arguments --only-show-errors --output json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($raw | Out-String)"
    }
    return (($raw | Out-String) | ConvertFrom-Json -ErrorAction Stop)
}

if ([datetime]::ParseExact($SupportConfirmedOn, "yyyy-MM-dd", [Globalization.CultureInfo]::InvariantCulture).Date -ne (Get-Date).Date) {
    throw "Confirm current Microsoft cloud red-teaming support on the day of the run."
}
if (($Phase -ne "PrepareTaxonomy") -and [string]::IsNullOrWhiteSpace($TaxonomyId)) {
    throw "TaxonomyId is required for a red-team run."
}
if ($Phase -eq "PostRemediation" -and [string]::IsNullOrWhiteSpace($PostRemediationVersion)) {
    throw "PostRemediationVersion is required for the post-remediation run."
}

foreach ($command in @("az", "python")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "$command is required."
    }
}

$artifactRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\artifacts")).Path
$attackPlanPath = Join-Path $artifactRoot "red-team\attack-plan.json"
$huntPath = Join-Path $artifactRoot "defender\ai-alert-hunt.kql"
$playbookPath = Join-Path $artifactRoot "operations\soc-triage-playbook.md"
foreach ($path in @($attackPlanPath, $huntPath, $playbookPath, (Join-Path $PSScriptRoot "run-red-team.py"), (Join-Path $PSScriptRoot "compare-runs.py"), (Join-Path $PSScriptRoot "requirements.txt"))) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation file is missing: $path"
    }

    $requiredSentinels = @(
        "__REQUIRED_AGENT_NAME__",
        "__REQUIRED_SECURITY_OWNER_ROLE__",
        "__REQUIRED_TAXONOMY_NAME__"
    )
    $unresolved = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
        Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__")
    if ($unresolved.Count -gt 0) {
        $unknown = @($unresolved.Matches.Value | Sort-Object -Unique | Where-Object { $_ -notin $requiredSentinels })
        if ($unknown.Count -gt 0) {
            throw "Add explicit preflight coverage for: $($unknown -join ', ')."
        }
        throw "Resolve every __REQUIRED_*__ sentinel before a red-team run."
    }
}

$attackPlan = Get-Content -LiteralPath $attackPlanPath -Raw | ConvertFrom-Json -ErrorAction Stop
if ([string]$attackPlan.implementationSession -ne "12-red-teaming-threat-defense" -or
    [string]$attackPlan.target.type -ne "azure_ai_agent" -or
    [string]::IsNullOrWhiteSpace([string]$attackPlan.target.name) -or
    [bool]$attackPlan.resultHandling.retainAttackPromptsInRepository -or
    [bool]$attackPlan.resultHandling.retainAgentResponsesInRepository -or
    [bool]$attackPlan.resultHandling.retainToolPayloadsInRepository -or
    -not [bool]$attackPlan.resultHandling.retainAggregateOnly -or
    -not [bool]$attackPlan.resultHandling.humanReviewRequired) {
    throw "The attack plan must retain its bounded target and payload-free result boundary."
}
$requiredStrategies = @("Jailbreak", "Flip", "Base64", "IndirectJailbreak")
foreach ($strategy in $requiredStrategies) {
    if ($strategy -notin @($attackPlan.attackStrategies)) {
        throw "The attack plan is missing $strategy."
    }
}
$requiredEvaluators = @("builtin.prohibited_actions", "builtin.task_adherence", "builtin.sensitive_data_leakage")
foreach ($evaluator in $requiredEvaluators) {
    if ($evaluator -notin @($attackPlan.testingCriteria | ForEach-Object { [string]$_.evaluatorName })) {
        throw "The attack plan is missing $evaluator."
    }
}

$baselineVersion = [Environment]::GetEnvironmentVariable("FOUNDRY_BASELINE_AGENT_VERSION")
$foundryResourceId = [Environment]::GetEnvironmentVariable("FOUNDRY_RESOURCE_ID")
$projectEndpoint = [Environment]::GetEnvironmentVariable("FOUNDRY_PROJECT_ENDPOINT")
$judgeModel = [Environment]::GetEnvironmentVariable("FOUNDRY_MODEL_NAME")
if ([string]::IsNullOrWhiteSpace($baselineVersion) -or
    [string]::IsNullOrWhiteSpace($foundryResourceId) -or
    $foundryResourceId -notlike "/subscriptions/$ApprovedSubscriptionId/*" -or
    [string]::IsNullOrWhiteSpace($projectEndpoint) -or
    $projectEndpoint -notmatch "^https://[^/]+\.services\.ai\.azure\.com/api/projects/[^/]+$" -or
    [string]::IsNullOrWhiteSpace($judgeModel)) {
    throw "Supply the approved Foundry target through FOUNDRY_* environment variables."
}

& python -c "import azure.ai.projects, azure.identity, openai" 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "Install the Session 12 Python dependencies: python -m pip install -r `"$PSScriptRoot\requirements.txt`""
}
$account = Invoke-AzJson -Arguments @("account", "show") -Description "Azure account lookup"
if ([string]$account.id -ne $ApprovedSubscriptionId) {
    throw "Azure CLI is not using the approved subscription."
}
$foundry = Invoke-AzJson -Arguments @("resource", "show", "--ids", $foundryResourceId) -Description "Foundry resource lookup"
if ([string]$foundry.kind -ne "AIServices" -or ([string]$foundry.location).Replace(" ", "").ToLowerInvariant() -ne $ExpectedRegion.Replace(" ", "").ToLowerInvariant()) {
    throw "FOUNDRY_RESOURCE_ID must resolve to the approved AIServices resource in ExpectedRegion."
}

$phaseArgument = if ($Phase -eq "PostRemediation") { "post-remediation" } else { "baseline" }
$runnerArguments = @($PSScriptRoot + "\run-red-team.py", "--config", $attackPlanPath, "--phase", $phaseArgument, "--check-only")
if ($Phase -eq "PostRemediation") {
    $runnerArguments += @("--post-remediation-version", $PostRemediationVersion)
}
& python @runnerArguments
if ($LASTEXITCODE -ne 0) {
    throw "The approved Foundry project or exact agent version could not be resolved."
}

Write-Host "Red-team safe preview (read-only):"
Write-Host "  Authorization: $AuthorizationReference"
Write-Host "  Support confirmed: $SupportConfirmedOn"
Write-Host "  Target: $($attackPlan.target.name) / $baselineVersion"
Write-Host "  Expected region: $ExpectedRegion"
Write-Host "  SOC route: $SocRouteReference"
Write-Host "  Strategies: $(@($attackPlan.attackStrategies) -join ', ')"
Write-Host "No taxonomy or run was created. Foundry, Defender, and the SOC system remain authoritative for current state."
