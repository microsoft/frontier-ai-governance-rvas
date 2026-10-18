[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetScope,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SentinelResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SentinelWorkspaceName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$implementationSession = "optional-module-ai-threat-protection-shadow-ai"
$artifactRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\artifacts")).Path
$defenderTemplatePath = Join-Path $artifactRoot "defender\defender-ai-plan.bicep"
$defenderParametersPath = Join-Path $artifactRoot "defender\defender-ai-plan.bicepparam"
$defenderDecisionPath = Join-Path $artifactRoot "defender\defender-ai-plan-decisions.json"
$defenderAlertQueryPath = Join-Path $artifactRoot "defender\defender-ai-alerts.kql"
$sentinelTemplatePath = Join-Path $artifactRoot "sentinel\copilot-threat-detections.bicep"
$sentinelParametersPath = Join-Path $artifactRoot "sentinel\copilot-threat-detections.bicepparam"
$jailbreakQueryPath = Join-Path $artifactRoot "sentinel\copilot-jailbreak-analytics.kql"
$externalIpQueryPath = Join-Path $artifactRoot "sentinel\copilot-external-ip-hunting.kql"
$shadowDecisionPath = Join-Path $artifactRoot "shadow-ai\shadow-ai-sanction-decisions.json"
$requiredSentinels = @(
    "__REQUIRED_AI_PLATFORM_OWNER__",
    "__REQUIRED_BLOCKING_OWNER__",
    "__REQUIRED_DEFENDER_FOR_CLOUD_OWNER__",
    "__REQUIRED_DEFENDER_PLAN_RESTORE_REFERENCE__",
    "__REQUIRED_DEFENDER_XDR_QUEUE_OWNER__",
    "__REQUIRED_GENERATIVE_AI_APP_NAME__",
    "__REQUIRED_PRIVACY_OWNER__",
    "__REQUIRED_PROMPT_EVIDENCE_PRIVACY_DECISION_REFERENCE__",
    "__REQUIRED_PROMPT_EVIDENCE_TRUE_OR_FALSE__",
    "__REQUIRED_PURVIEW_SHARING_TRUE_OR_FALSE__",
    "__REQUIRED_RISK_REVIEW_REFERENCE__",
    "__REQUIRED_SANCTION_OR_UNSANCTION__",
    "__REQUIRED_SANCTION_TAG__",
    "__REQUIRED_SENTINEL_OWNER__",
    "__REQUIRED_SENTINEL_RESOURCE_GROUP_NAME__",
    "__REQUIRED_SENTINEL_WORKSPACE_NAME__",
    "__REQUIRED_SHADOW_AI_DISCOVERY_POLICY_NAME__",
    "__REQUIRED_SHADOW_AI_MONITORING_OWNER__",
    "__REQUIRED_SHADOW_AI_RESTORE_REFERENCE__",
    "__REQUIRED_SOC_RUNBOOK_REFERENCE__",
    "__REQUIRED_TARGET_SCOPE_ALIAS__"
)

function Get-BicepStringParameter {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $content = Get-Content -LiteralPath $Path -Raw
    $match = [regex]::Match($content, "(?m)^\s*param\s+$([regex]::Escape($Name))\s*=\s*'([^']*)'\s*$")
    if (-not $match.Success) {
        throw "Could not read string parameter '$Name' from $Path."
    }
    return $match.Groups[1].Value
}

function ConvertTo-CanonicalBooleanString {
    param(
        [Parameter(Mandatory)]
        [string]$Value,

        [Parameter(Mandatory)]
        [string]$Label
    )

    switch ($Value.Trim().ToLowerInvariant()) {
        "true" { return "True" }
        "false" { return "False" }
        default { throw "$Label must be True or False." }
    }
}

function Invoke-Az {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [string]$Description
    )

    $output = & az @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed.`n$($output | Out-String)"
    }
    return ($output | Out-String).Trim()
}

if (-not (Test-Path -LiteralPath $artifactRoot -PathType Container)) {
    throw "The module artifacts folder is missing: $artifactRoot"
}

$requiredFiles = @(
    $defenderTemplatePath,
    $defenderParametersPath,
    $defenderDecisionPath,
    $defenderAlertQueryPath,
    $sentinelTemplatePath,
    $sentinelParametersPath,
    $jailbreakQueryPath,
    $externalIpQueryPath,
    $shadowDecisionPath
)
foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $path"
    }
}

$sentinelMatches = @(Get-ChildItem -LiteralPath $artifactRoot -File -Recurse |
    Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__" -AllMatches)
if ($sentinelMatches.Count -gt 0) {
    $unresolved = @($sentinelMatches |
        ForEach-Object { $_.Matches } |
        ForEach-Object { $_.Value } |
        Sort-Object -Unique)
    $unknown = @($unresolved | Where-Object { $_ -notin $requiredSentinels })
    if ($unknown.Count -gt 0) {
        throw "Add explicit preflight coverage for new sentinels: $($unknown -join ', ')."
    }
    throw "Resolve every AI threat protection and shadow AI decision before deployment: $($unresolved -join ', ')"
}

$defenderDecision = Get-Content -LiteralPath $defenderDecisionPath -Raw | ConvertFrom-Json -ErrorAction Stop
$shadowDecision = Get-Content -LiteralPath $shadowDecisionPath -Raw | ConvertFrom-Json -ErrorAction Stop
Get-ChildItem -LiteralPath $artifactRoot -File -Recurse -Filter "*.json" | ForEach-Object {
    $null = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
}

if ([string]$defenderDecision.implementationSession -ne $implementationSession -or
    [string]$shadowDecision.implementationSession -ne $implementationSession) {
    throw "Decision records must use implementationSession=$implementationSession."
}
if ([string]$defenderDecision.targetScopeAlias -ne $TargetScope -or
    [string]$shadowDecision.targetScopeAlias -ne $TargetScope) {
    throw "TargetScope must match both decision records."
}
if ([string]$defenderDecision.defenderPlan.pricingResourceName -ne "AI" -or
    [string]$defenderDecision.defenderPlan.pricingTier -ne "Standard") {
    throw "The Defender plan decision must target Microsoft.Security/pricings name AI with Standard tier."
}

$decisionPromptEvidence = ConvertTo-CanonicalBooleanString `
    -Value ([string]$defenderDecision.defenderPlan.promptEvidence) `
    -Label "defenderPlan.promptEvidence"
$decisionPurviewSharing = ConvertTo-CanonicalBooleanString `
    -Value ([string]$defenderDecision.defenderPlan.purviewSharing) `
    -Label "defenderPlan.purviewSharing"
$parameterPromptEvidence = ConvertTo-CanonicalBooleanString `
    -Value (Get-BicepStringParameter -Path $defenderParametersPath -Name "isAIPromptEvidenceEnabled") `
    -Label "defender-ai-plan.bicepparam isAIPromptEvidenceEnabled"
$parameterPurviewSharing = ConvertTo-CanonicalBooleanString `
    -Value (Get-BicepStringParameter -Path $defenderParametersPath -Name "isAIPromptSharingWithPurviewEnabled") `
    -Label "defender-ai-plan.bicepparam isAIPromptSharingWithPurviewEnabled"
if ($decisionPromptEvidence -ne $parameterPromptEvidence) {
    throw "defenderPlan.promptEvidence must match defender-ai-plan.bicepparam isAIPromptEvidenceEnabled."
}
if ($decisionPurviewSharing -ne $parameterPurviewSharing) {
    throw "defenderPlan.purviewSharing must match defender-ai-plan.bicepparam isAIPromptSharingWithPurviewEnabled."
}
if ([string]$defenderDecision.socRouting.sentinelWorkspaceName -ne $SentinelWorkspaceName -or
    [string]$defenderDecision.socRouting.sentinelResourceGroupName -ne $SentinelResourceGroupName) {
    throw "Sentinel parameters must match defender-ai-plan-decisions.json."
}
if ([string]$shadowDecision.changeMode -ne "monitor-first" -or [string]$shadowDecision.category -ne "Generative AI") {
    throw "Shadow AI decisions must stay monitor-first for the Generative AI category."
}
foreach ($decision in @($shadowDecision.sanctionDecisions)) {
    if ([string]$decision.enforcementMode -ne "monitor") {
        throw "Every shadow AI decision must start with enforcementMode=monitor."
    }
    if ([string]$decision.decision -notin @("Sanction", "Unsanction", "sanction", "unsanction")) {
        throw "Each shadow AI decision must be Sanction or Unsanction."
    }
    if ([string]$decision.tagToApply -notin @("Sanctioned", "Unsanctioned")) {
        throw "Each shadow AI tag must be Sanctioned or Unsanctioned."
    }
}

if ((Get-BicepStringParameter -Path $defenderParametersPath -Name "targetScopeAlias") -ne $TargetScope -or
    (Get-BicepStringParameter -Path $sentinelParametersPath -Name "targetScopeAlias") -ne $TargetScope) {
    throw "Bicep parameter targetScopeAlias values must match TargetScope."
}
if ((Get-BicepStringParameter -Path $sentinelParametersPath -Name "sentinelWorkspaceName") -ne $SentinelWorkspaceName) {
    throw "copilot-threat-detections.bicepparam must target the approved Sentinel workspace."
}
if ((Get-Content -LiteralPath $jailbreakQueryPath -Raw) -notmatch "CopilotActivity" -or
    (Get-Content -LiteralPath $jailbreakQueryPath -Raw) -notmatch "JailbreakDetected") {
    throw "The Copilot jailbreak analytics query must inspect CopilotActivity and JailbreakDetected."
}
if ((Get-Content -LiteralPath $externalIpQueryPath -Raw) -notmatch "SrcIpAddr") {
    throw "The Copilot external-IP hunting query must inspect SrcIpAddr."
}
if ((Get-Content -LiteralPath $defenderAlertQueryPath -Raw) -notmatch "SecurityAlert") {
    throw "The Defender AI alert query must inspect SecurityAlert."
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required for Bicep compilation and what-if previews."
}

Invoke-Az -Arguments @("bicep", "build", "--file", $defenderTemplatePath, "--stdout") -Description "Defender plan Bicep build" | Out-Null
Invoke-Az -Arguments @("bicep", "build-params", "--file", $defenderParametersPath, "--stdout") -Description "Defender plan bicepparam build" | Out-Null
Invoke-Az -Arguments @("bicep", "build", "--file", $sentinelTemplatePath, "--stdout") -Description "Sentinel detections Bicep build" | Out-Null
Invoke-Az -Arguments @("bicep", "build-params", "--file", $sentinelParametersPath, "--stdout") -Description "Sentinel detections bicepparam build" | Out-Null

$currentSubscriptionId = Invoke-Az -Arguments @("account", "show", "--query", "id", "--output", "tsv", "--only-show-errors") -Description "Azure CLI account lookup"
if ($currentSubscriptionId -ine $TargetSubscriptionId) {
    throw "Azure CLI is not set to approved subscription '$TargetSubscriptionId'."
}

Write-Host "Preview 1 of 2: Defender for Cloud AI services plan at subscription $TargetSubscriptionId"
Invoke-Az -Arguments @(
    "deployment", "sub", "what-if",
    "--subscription", $TargetSubscriptionId,
    "--location", $DeploymentLocation,
    "--template-file", $defenderTemplatePath,
    "--parameters", $defenderParametersPath,
    "--no-pretty-print",
    "--only-show-errors"
) -Description "Defender plan deployment preview" | Write-Host

Write-Host "Preview 2 of 2: Sentinel Copilot detections in $SentinelResourceGroupName/$SentinelWorkspaceName"
Invoke-Az -Arguments @(
    "deployment", "group", "what-if",
    "--subscription", $TargetSubscriptionId,
    "--resource-group", $SentinelResourceGroupName,
    "--template-file", $sentinelTemplatePath,
    "--parameters", $sentinelParametersPath,
    "--no-pretty-print",
    "--only-show-errors"
) -Description "Sentinel detections deployment preview" | Write-Host

Write-Host "PASS: artifact syntax, decision records, approved scope, and both read-only previews are ready."
