[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedSubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedResourceGroupName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApprovedApplicationInsightsResourceId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentLocation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$artifactRoot = Join-Path $PSScriptRoot "..\artifacts"
$controlPath = Join-Path $artifactRoot "control-definition.json"
$mainTemplatePath = Join-Path $artifactRoot "infra\main.bicep"
$mainParametersPath = Join-Path $artifactRoot "infra\main.bicepparam"
$budgetTemplatePath = Join-Path $artifactRoot "cost\budget.bicep"
$budgetParametersPath = Join-Path $artifactRoot "cost\budget.bicepparam"
$telemetryPath = Join-Path $artifactRoot "telemetry\telemetry-contract.json"
$retentionPath = Join-Path $artifactRoot "governance\data-retention-decision.md"
$contentLoggingPath = Join-Path $artifactRoot "governance\prompt-response-logging-decision.md"
$allocationPath = Join-Path $artifactRoot "cost\cost-allocation.md"
$smokePowerShellPath = Join-Path $PSScriptRoot "smoke.ps1"
$smokeBashPath = Join-Path $PSScriptRoot "smoke.sh"
$smokeContractTestPath = Join-Path $PSScriptRoot "test-smoke-contract.py"
$requiredDecisionSentinels = @(
    "__REQUIRED_ACTION_GROUP_RESOURCE_ID__",
    "__REQUIRED_AI_QUALITY_OWNER__",
    "__REQUIRED_APPLICATION_INSIGHTS_RESOURCE_ID__",
    "__REQUIRED_APPLICATION_TAG__",
    "__REQUIRED_APIM_POLICY_VERSION__",
    "__REQUIRED_BUDGET_END_DATE__",
    "__REQUIRED_BUDGET_NAME__",
    "__REQUIRED_BUDGET_START_DATE__",
    "__REQUIRED_COST_CENTER__",
    "__REQUIRED_COST_NOTIFICATION_EMAIL__",
    "__REQUIRED_COST_OWNER__",
    "__REQUIRED_DAILY_CAP_DECISION__",
    "__REQUIRED_DATA_CLASSIFICATION__",
    "__REQUIRED_DATA_PROTECTION_OWNER__",
    "__REQUIRED_DATA_RESIDENCY_STATUS_CONFIRMED__",
    "__REQUIRED_DATA_RETENTION_OWNER__",
    "__REQUIRED_DEPLOYMENT_LOCATION__",
    "__REQUIRED_EXCEPTION_PATH_STATUS_DISABLED_OR_APPROVED__",
    "__REQUIRED_GATEWAY_OWNER__",
    "__REQUIRED_GATEWAY_POLICY_SOURCE_PATH__",
    "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__",
    "__REQUIRED_MONTHLY_BUDGET_AMOUNT__",
    "__REQUIRED_OBSERVABILITY_OWNER__",
    "__REQUIRED_PRIVATE_ACCESS_STATUS_YES__",
    "__REQUIRED_QUALITY_FAILURE_COUNT__",
    "__REQUIRED_REQUEST_ERROR_RATE_PERCENT__",
    "__REQUIRED_RESOURCE_GROUP_RESOURCE_ID__",
    "__REQUIRED_RETENTION_DAYS__",
    "__REQUIRED_REVIEW_DATE__",
    "__REQUIRED_SAMPLING_STRATEGY_FIXED_OR_RATE_LIMITED__",
    "__REQUIRED_SAMPLING_VALUE__",
    "__REQUIRED_SERVICE_NAME__",
    "__REQUIRED_SERVICE_OWNER__",
    "__REQUIRED_SOC_OWNER__",
    "__REQUIRED_SUBSCRIPTION_RESOURCE_ID__",
    "__REQUIRED_TOOL_FAILURE_COUNT__",
    "__REQUIRED_TOOL_OWNER__",
    "__REQUIRED_TRACE_BASED_LOG_SAMPLING_DECISION__",
    "__REQUIRED_WORKBOOK_DISPLAY_NAME__"
)

function Get-BicepStringParameter {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $content = Get-Content -LiteralPath $Path -Raw
    $pattern = "(?m)^\s*param\s+$([regex]::Escape($Name))\s*=\s*'([^']+)'\s*$"
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) {
        throw "Could not read string parameter '$Name' from $Path."
    }

    return $match.Groups[1].Value
}

function ConvertTo-StrictBoolean {
    param(
        [Parameter(Mandatory)]
        [object]$Value,

        [Parameter(Mandatory)]
        [string]$Name
    )

    if ($Value -is [bool]) {
        return [bool]$Value
    }
    if ($Value -is [string] -and [string]$Value -in @("true", "false")) {
        return [bool]::Parse([string]$Value)
    }

    throw "$Name must be true or false."
}

function Get-MarkdownVisibleLines {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $visible = [System.Collections.Generic.List[string]]::new()
    $inComment = $false
    $inFence = $false
    $fenceCharacter = [char]0
    $fenceLength = 0
    $htmlTagPattern = '<(?:/?[A-Za-z][A-Za-z0-9:_-]*(?:\s+[^<>]*?)?\s*/?|![A-Za-z][^<>]*|\?[A-Za-z][^<>]*)>'

    foreach ($rawLine in @(Get-Content -LiteralPath $Path)) {
        if ($inFence) {
            $closing = [regex]::Match($rawLine, '^\s{0,3}(`{3,}|~{3,})\s*$')
            if ($closing.Success) {
                $candidate = $closing.Groups[1].Value
                if ($candidate[0] -eq $fenceCharacter -and $candidate.Length -ge $fenceLength) {
                    $inFence = $false
                }
            }
            continue
        }

        $line = ""
        $remaining = [string]$rawLine
        while ($remaining.Length -gt 0) {
            if ($inComment) {
                $commentEnd = $remaining.IndexOf("-->", [StringComparison]::Ordinal)
                if ($commentEnd -lt 0) {
                    $remaining = ""
                    continue
                }
                $inComment = $false
                $remaining = $remaining.Substring($commentEnd + 3)
                continue
            }
            $commentStart = $remaining.IndexOf("<!--", [StringComparison]::Ordinal)
            if ($commentStart -lt 0) {
                $line += $remaining
                $remaining = ""
                continue
            }
            $line += $remaining.Substring(0, $commentStart)
            $remaining = $remaining.Substring($commentStart + 4)
            $inComment = $true
        }

        $opening = [regex]::Match($line, '^\s{0,3}(`{3,}|~{3,}).*$')
        if ($opening.Success) {
            $marker = $opening.Groups[1].Value
            $inFence = $true
            $fenceCharacter = $marker[0]
            $fenceLength = $marker.Length
            continue
        }
        if ([regex]::IsMatch($line, $htmlTagPattern)) {
            $filename = Split-Path -Leaf $Path
            throw "$filename contains raw HTML outside fenced code."
        }
        $visible.Add($line)
    }

    if ($inFence) {
        $filename = Split-Path -Leaf $Path
        throw "$filename contains an unclosed fenced code block."
    }
    if ([regex]::IsMatch(($visible -join "`n"), $htmlTagPattern)) {
        $filename = Split-Path -Leaf $Path
        throw "$filename contains raw HTML outside fenced code."
    }
    return $visible.ToArray()
}

function Get-MarkdownSection {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$Lines,

        [Parameter(Mandatory)]
        [string]$Heading,

        [Parameter(Mandatory)]
        [string]$Filename
    )

    $indexes = @()
    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index].Trim() -ceq $Heading) {
            $indexes += $index
        }
    }
    if ($indexes.Count -eq 0) {
        throw "$Filename is missing heading '$Heading'."
    }
    if ($indexes.Count -gt 1) {
        throw "$Filename contains duplicate heading '$Heading'."
    }

    $section = @()
    for ($index = $indexes[0] + 1; $index -lt $Lines.Count; $index++) {
        $headingMatch = [regex]::Match($Lines[$index].Trim(), "^(#{1,6})\s+")
        if ($headingMatch.Success) {
            break
        }
        $section += $Lines[$index]
    }
    return $section
}

function Get-MarkdownField {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Heading,

        [Parameter(Mandatory)]
        [string]$Field
    )

    $filename = Split-Path -Leaf $Path
    $lines = @(Get-MarkdownVisibleLines -Path $Path)
    $section = @(Get-MarkdownSection -Lines $lines -Heading $Heading -Filename $filename)
    $headerPattern = '^\|\s*Field\s*\|\s*Decision\s*\|\s*$'
    $separatorPattern = '^\|\s*:?-{3,}:?\s*\|\s*:?-{3,}:?\s*\|\s*$'
    $fieldPattern = "^\|\s*$([regex]::Escape($Field))\s*\|\s*(.*?)\s*\|\s*$"
    $values = @()
    for ($index = 0; $index + 1 -lt $section.Count; $index++) {
        if ($section[$index] -notmatch $headerPattern -or
            $section[$index + 1] -notmatch $separatorPattern) {
            continue
        }
        for ($rowIndex = $index + 2; $rowIndex -lt $section.Count; $rowIndex++) {
            if ($section[$rowIndex] -notmatch '^\|.*\|\s*$') {
                break
            }
            $match = [regex]::Match($section[$rowIndex], $fieldPattern)
            if ($match.Success) {
                $values += $match.Groups[1].Value.Trim()
            }
        }
    }
    if ($values.Count -eq 0) {
        throw "$filename is missing field '$Field'."
    }
    if ($values.Count -gt 1) {
        throw "$filename contains duplicate field '$Field'."
    }

    $value = $values[0]
    if ($value.Length -ge 2 -and
        $value[0] -eq [char]96 -and
        $value[$value.Length - 1] -eq [char]96) {
        $value = $value.Substring(1, $value.Length - 2).Trim()
    }
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "$filename field '$Field' is empty."
    }
    return $value
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required."
}
if (-not (Test-Path $artifactRoot -PathType Container)) {
    throw "Required implementation artifacts folder is missing: $artifactRoot"
}

$requiredFiles = @(
    $controlPath,
    $mainTemplatePath,
    $mainParametersPath,
    $budgetTemplatePath,
    $budgetParametersPath,
    $telemetryPath,
    $retentionPath,
    $contentLoggingPath,
    $allocationPath,
    $smokePowerShellPath,
    $smokeBashPath,
    $smokeContractTestPath,
    (Join-Path $artifactRoot "monitoring\workbook.json"),
    (Join-Path $artifactRoot "operations\incident-runbook.md")
)
foreach ($path in $requiredFiles) {
    if (-not (Test-Path $path -PathType Leaf)) {
        throw "Required implementation artifact is missing: $path"
    }
}

$artifactFiles = Get-ChildItem -LiteralPath $artifactRoot -File -Recurse
$sentinels = $artifactFiles | Select-String -Pattern "__REQUIRED_[A-Z0-9_]+__"
if ($sentinels) {
    $locations = $sentinels | ForEach-Object { "$($_.Path):$($_.LineNumber)" }
    throw "Resolve every required customer decision before deployment:`n$($locations -join "`n")"
}
$artifactText = ($artifactFiles | ForEach-Object {
    Get-Content -LiteralPath $_.FullName -Raw
}) -join "`n"
foreach ($sentinel in $requiredDecisionSentinels) {
    if ($artifactText.Contains($sentinel)) {
        throw "Resolve customer decision $sentinel before deployment."
    }
}

$jsonFiles = Get-ChildItem -LiteralPath $artifactRoot -File -Recurse -Filter "*.json"
foreach ($jsonFile in $jsonFiles) {
    $null = Get-Content -LiteralPath $jsonFile.FullName -Raw |
        ConvertFrom-Json -ErrorAction Stop
}

$control = Get-Content -LiteralPath $controlPath -Raw | ConvertFrom-Json
$expectedTargetScope = "/subscriptions/$ApprovedSubscriptionId/resourceGroups/$ApprovedResourceGroupName"
if ([string]$control.targetScope -ine $expectedTargetScope) {
    throw "Control target scope '$($control.targetScope)' does not match approved scope '$expectedTargetScope'."
}
if ([string]$control.monitoredApplicationInsightsResourceId -ine $ApprovedApplicationInsightsResourceId) {
    throw "The control definition does not name the approved Application Insights resource."
}
if ([string]$control.costScope -ine "/subscriptions/$ApprovedSubscriptionId") {
    throw "The cost scope must be the approved subscription resource ID."
}
if ([string]$control.environment -ne "nonproduction") {
    throw "This session is limited to the approved nonproduction service."
}
if ([int]$control.schemaVersion -ne 2) {
    throw "The control definition must use smoke contract schemaVersion 2."
}
$smoke = $control.confirmation.smokeExecutable
$requiredRuntimeEnvironment = @(
    "SESSION13_SMOKE_URL",
    "SESSION13_SMOKE_FAILURE_URL",
    "SESSION13_AI_RESOURCE_ID",
    "SESSION13_LOG_ANALYTICS_WORKSPACE_ID",
    "SESSION13_SMOKE_BEARER_TOKEN"
)
if (@($smoke.runtimeEnvironment).Count -ne $requiredRuntimeEnvironment.Count -or
    @($requiredRuntimeEnvironment | Where-Object { $_ -notin @($smoke.runtimeEnvironment) }).Count -gt 0) {
    throw "The Session 13 smoke runtime environment contract has changed."
}
$polling = $smoke.ingestionPolling
if ([string]$polling.timeoutEnvironment -ne "SESSION13_SMOKE_TIMEOUT_SECONDS" -or
    [int]$polling.defaultTimeoutSeconds -ne 180 -or
    [int]$polling.minimumTimeoutSeconds -ne 30 -or
    [int]$polling.maximumTimeoutSeconds -ne 600 -or
    [string]$polling.retryEnvironment -ne "SESSION13_SMOKE_RETRY_SECONDS" -or
    [int]$polling.defaultRetrySeconds -ne 15 -or
    [int]$polling.minimumRetrySeconds -ne 5 -or
    [int]$polling.maximumRetrySeconds -ne 60 -or
    [int]$polling.minimumTimeoutRetryMultiplier -ne 2 -or
    [string]$polling.attemptCountSemantics -ne "all telemetry queries across readiness and stability, including the initial and final queries" -or
    [int]$polling.minimumPassingAttempts -ne 3 -or
    [string]$polling.maximumAttemptsFormula -ne "1 + ceiling(timeoutSeconds / retrySeconds)" -or
    @($polling.correlationIds).Count -ne 2 -or
    "normal" -notin @($polling.correlationIds) -or
    "expectedToolFailure" -notin @($polling.correlationIds) -or
    -not [bool]$polling.timeoutIncludesStabilityChecks -or
    [string]$polling.watermark -ne "maximum TimeGenerated across both correlated telemetry sets" -or
    [int]$polling.requiredIdenticalSnapshots -ne 3 -or
    -not [bool]$polling.finalQueryRequired) {
    throw "The bounded ingestion-polling contract has changed."
}
if ([string]$smoke.correlationContract.format -ne "32 lower-case hexadecimal characters" -or
    -not [bool]$smoke.correlationContract.normalAndFailureMustBeDistinct -or
    @($smoke.correlationContract.resultFields).Count -ne 2 -or
    "normalCorrelationId" -notin @($smoke.correlationContract.resultFields) -or
    "failureCorrelationId" -notin @($smoke.correlationContract.resultFields)) {
    throw "The smoke correlation-ID contract has changed."
}
if ([string]$smoke.requestBodies.normal.syntheticMarker -ne
    [string]$smoke.requestBodies.expectedToolFailure.syntheticMarker) {
    throw "Both smoke requests must use the same fixed synthetic marker."
}
if ([string]$smoke.requestBodies.normal.releaseCommitSha -ne "exact lower-case CommitSha CLI value" -or
    [string]$smoke.requestBodies.expectedToolFailure.releaseCommitSha -ne "exact lower-case CommitSha CLI value") {
    throw "Both smoke requests must bind the exact release commit SHA."
}
if ([string]$smoke.authentication.scheme -ne "Bearer" -or
    [string]$smoke.authentication.tokenEnvironment -ne "SESSION13_SMOKE_BEARER_TOKEN" -or
    [string]$smoke.authentication.powershellTransport -ne "in-memory request header" -or
    [string]$smoke.authentication.bashTransport -ne "curl configuration over standard input" -or
    [bool]$smoke.authentication.tokenWrittenToDisk) {
    throw "The smoke authentication transport contract has changed."
}
if ([string]$smoke.releaseCommitBinding.requestHeader -ne "x-release-commit-sha" -or
    [string]$smoke.releaseCommitBinding.requestBodyField -ne "releaseCommitSha" -or
    [string]$smoke.releaseCommitBinding.telemetryProperty -ne "release.commit.sha" -or
    @($smoke.releaseCommitBinding.requiredForCorrelations).Count -ne 2 -or
    "normal" -notin @($smoke.releaseCommitBinding.requiredForCorrelations) -or
    "expectedToolFailure" -notin @($smoke.releaseCommitBinding.requiredForCorrelations) -or
    -not [bool]$smoke.releaseCommitBinding.copyToResultOnlyAfterTelemetryMatch) {
    throw "The release commit telemetry-binding contract has changed."
}
if ([string]$smoke.workspaceBinding.componentResourceEnvironment -ne "SESSION13_AI_RESOURCE_ID" -or
    [string]$smoke.workspaceBinding.componentProperty -ne "WorkspaceResourceId" -or
    [string]$smoke.workspaceBinding.workspaceResourceEnvironment -ne "SESSION13_LOG_ANALYTICS_WORKSPACE_ID" -or
    [string]$smoke.workspaceBinding.resourceIdComparison -ne "case-insensitive" -or
    -not [bool]$smoke.workspaceBinding.requiredBeforeQuery) {
    throw "The Application Insights workspace-binding contract has changed."
}
$requiredPrivacySurfaces = @("AppRequests", "AppDependencies", "AppEvents", "AppTraces", "AppExceptions")
if (@($smoke.privacySurfaces).Count -ne $requiredPrivacySurfaces.Count -or
    @($requiredPrivacySurfaces | Where-Object { $_ -notin @($smoke.privacySurfaces) }).Count -gt 0) {
    throw "The smoke privacy check must cover all five required telemetry surfaces."
}
if ([string]$smoke.prohibitedPropertySource -ne "implementation/artifacts/telemetry/telemetry-contract.json prohibitedAttributes") {
    throw "The smoke privacy check must use telemetry-contract.json prohibitedAttributes."
}
$requiredCheckNames = @(
    "syntheticRequest",
    "endToEndTrace",
    "expectedToolFailure",
    "independentModelResult",
    "toolAndModelFailureSeparated",
    "releaseCommitShaVerified",
    "workspaceBindingVerified",
    "correlationIdsDistinct",
    "telemetryIngestionStable",
    "sensitiveInputPresent",
    "payloadsRetained",
    "telemetryPollTimedOut"
)
if (@($smoke.requiredChecks.PSObject.Properties.Name).Count -ne $requiredCheckNames.Count -or
    @($requiredCheckNames | Where-Object { $_ -notin @($smoke.requiredChecks.PSObject.Properties.Name) }).Count -gt 0) {
    throw "The Session 13 smoke result-check fields have changed."
}
if ([string]$smoke.requiredChecks.syntheticRequest -ne "passed" -or
    [string]$smoke.requiredChecks.endToEndTrace -ne "passed" -or
    -not [bool]$smoke.requiredChecks.expectedToolFailure -or
    -not [bool]$smoke.requiredChecks.independentModelResult -or
    -not [bool]$smoke.requiredChecks.releaseCommitShaVerified -or
    -not [bool]$smoke.requiredChecks.workspaceBindingVerified -or
    -not [bool]$smoke.requiredChecks.correlationIdsDistinct -or
    -not [bool]$smoke.requiredChecks.telemetryIngestionStable -or
    [string]$smoke.requiredChecks.toolAndModelFailureSeparated -ne "passed" -or
    [bool]$smoke.requiredChecks.payloadsRetained -or
    [bool]$smoke.requiredChecks.sensitiveInputPresent -or
    [bool]$smoke.requiredChecks.telemetryPollTimedOut) {
    throw "The Session 13 smoke result-check contract is incomplete."
}
if ([string]$control.previewSupported -ne "Supported") {
    throw "Both Azure deployments require read-only what-if previews."
}
if (-not [bool]$control.gatewayPolicy.correlationAndTokenMetricsMerged) {
    throw "The gateway owner must confirm the correlation and token-metric merge in the customer-owned policy source."
}
$sessionRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$repoRoot = (Resolve-Path (Join-Path $sessionRoot "..\..")).Path
$policyPath = [IO.Path]::GetFullPath(
    (Join-Path $repoRoot ([string]$control.gatewayPolicy.customerOwnedSourcePath))
)
$repoPrefix = $repoRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $policyPath.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase) -or
    [IO.Path]::GetExtension($policyPath) -ne ".xml" -or
    -not (Test-Path -LiteralPath $policyPath -PathType Leaf)) {
    throw "The customer-owned gateway policy source must be one repository-relative XML file."
}
try {
    $policy = [xml](Get-Content -LiteralPath $policyPath -Raw)
}
catch {
    throw "The customer-owned APIM policy XML is invalid: $($_.Exception.Message)"
}
$correlationHeader = @($policy.SelectNodes("//set-header[@name='x-correlation-id']"))
$tokenMetric = @($policy.SelectNodes("//llm-emit-token-metric"))
if ($correlationHeader.Count -eq 0 -or $tokenMetric.Count -eq 0) {
    throw "The customer-owned APIM policy must contain x-correlation-id handling and llm-emit-token-metric."
}
if (ConvertTo-StrictBoolean `
        -Value $control.confirmation.sensitiveInputExpectedInStandardTelemetry `
        -Name "confirmation.sensitiveInputExpectedInStandardTelemetry") {
    throw "Sensitive input must not be expected in standard telemetry."
}

$telemetry = Get-Content -LiteralPath $telemetryPath -Raw | ConvertFrom-Json
if ([string]$telemetry.propagation.standard -ne "W3C Trace Context") {
    throw "The telemetry contract must include W3C Trace Context."
}
if ([string]$telemetry.serviceName -ne [string]$control.serviceName) {
    throw "Service name differs between the telemetry and control definitions."
}
$requiredSpanKinds = @("gateway.request", "agent.invoke", "model.invoke", "tool.invoke", "evaluation.result", "security.signal")
foreach ($spanKind in $requiredSpanKinds) {
    if ($spanKind -notin @($telemetry.requiredSpanKinds)) {
        throw "Telemetry contract is missing required span kind '$spanKind'."
    }
    if ("release.commit.sha" -notin @($telemetry.requiredAttributes)) {
        throw "The telemetry contract must bind smoke records to release.commit.sha."
    }
}
if ([string]$telemetry.releaseCommitBinding.requestHeader -ne "x-release-commit-sha" -or
    [string]$telemetry.releaseCommitBinding.requestBodyField -ne "releaseCommitSha" -or
    [string]$telemetry.releaseCommitBinding.telemetryProperty -ne "release.commit.sha" -or
    @($telemetry.releaseCommitBinding.requiredOnRequestSpans).Count -ne 2 -or
    "normal" -notin @($telemetry.releaseCommitBinding.requiredOnRequestSpans) -or
    "expected-tool-failure" -notin @($telemetry.releaseCommitBinding.requiredOnRequestSpans) -or
    [string]$telemetry.releaseCommitBinding.valueType -ne "lower-case hexadecimal commit SHA" -or
    [bool]$telemetry.releaseCommitBinding.containsSensitiveData) {
    throw "The telemetry release-commit binding has changed."
}
$requiredProhibitedAttributes = @(
    "gen_ai.prompt",
    "gen_ai.completion",
    "ai.input.content",
    "ai.output.content",
    "tool.input",
    "tool.output",
    "http.request.header.authorization",
    "http.request.header.cookie",
    "url.query",
    "enduser.id",
    "user.email"
)
foreach ($attribute in $requiredProhibitedAttributes) {
    if ($attribute -notin @($telemetry.prohibitedAttributes)) {
        throw "Telemetry contract must prohibit '$attribute'."
    }
}
if (-not (ConvertTo-StrictBoolean `
        -Value $telemetry.sampling.errorsAndSecuritySignalsAlwaysRetained `
        -Name "sampling.errorsAndSecuritySignalsAlwaysRetained")) {
    throw "Errors and security signals must remain outside normal trace sampling."
}
$userLevelDimensionAllowed = ConvertTo-StrictBoolean `
    -Value $telemetry.cardinality.userLevelDimensionAllowed `
    -Name "cardinality.userLevelDimensionAllowed"
$freeTextDimensionAllowed = ConvertTo-StrictBoolean `
    -Value $telemetry.cardinality.freeTextDimensionAllowed `
    -Name "cardinality.freeTextDimensionAllowed"
if (@($telemetry.cardinality.approvedDimensions).Count -gt 5) {
    throw "APIM token telemetry is limited to five approved low-cardinality dimensions."
}
if ($userLevelDimensionAllowed -or $freeTextDimensionAllowed) {
    throw "User-level and free-text telemetry dimensions are prohibited."
}

$retentionResourceId = Get-MarkdownField `
    -Path $retentionPath `
    -Heading "# Data retention decision" `
    -Field "Application Insights resource ID"
if ($retentionResourceId -ine $ApprovedApplicationInsightsResourceId) {
    throw "The retention decision does not target the approved Application Insights resource."
}
$retentionDaysText = Get-MarkdownField `
    -Path $retentionPath `
    -Heading "# Data retention decision" `
    -Field "Retention days"
$retentionDays = 0
if (-not [int]::TryParse($retentionDaysText, [ref]$retentionDays) -or
    $retentionDays -lt 30 -or $retentionDays -gt 730) {
    throw "Retention days must be an approved integer from 30 through 730."
}
if ((Get-MarkdownField `
        -Path $retentionPath `
        -Heading "# Data retention decision" `
        -Field "Data residency status") -cne "Confirmed") {
    throw "The data residency status must be Confirmed."
}
if ((Get-MarkdownField `
        -Path $retentionPath `
        -Heading "# Data retention decision" `
        -Field "Private-access boundary status") -cne "Yes") {
    throw "The private-access boundary status must be Yes."
}

$loggingDefaults = [ordered]@{
    "Standard content logging" = "Disabled"
    "Prompts logged by default" = "No"
    "Responses logged by default" = "No"
    "Tool payloads logged by default" = "No"
    "Query strings logged by default" = "No"
    "Authorization headers logged by default" = "No"
}
foreach ($entry in $loggingDefaults.GetEnumerator()) {
    $actual = Get-MarkdownField `
        -Path $contentLoggingPath `
        -Heading "## Standard telemetry" `
        -Field $entry.Key
    if ($actual -cne $entry.Value) {
        throw "prompt-response-logging-decision.md field '$($entry.Key)' must be '$($entry.Value)'."
    }
}
$exceptionStatus = Get-MarkdownField `
    -Path $contentLoggingPath `
    -Heading "## Exception path" `
    -Field "Status"
if (@("Disabled", "Approved") -cnotcontains $exceptionStatus) {
    throw "The content-logging exception status must be Disabled or Approved."
}
$exceptionValues = @(
    (Get-MarkdownField -Path $contentLoggingPath -Heading "## Exception path" -Field "Purpose"),
    (Get-MarkdownField -Path $contentLoggingPath -Heading "## Exception path" -Field "Approved scope"),
    (Get-MarkdownField -Path $contentLoggingPath -Heading "## Exception path" -Field "Access owner"),
    (Get-MarkdownField -Path $contentLoggingPath -Heading "## Exception path" -Field "Retention days"),
    (Get-MarkdownField -Path $contentLoggingPath -Heading "## Exception path" -Field "Expiry date")
)
if ($exceptionStatus -eq "Disabled" -and
    @($exceptionValues | Where-Object { $_ -cne "N/A" }).Count -gt 0) {
    throw "A Disabled content-logging exception must use N/A for every exception detail."
}
if ($exceptionStatus -eq "Approved" -and
    @($exceptionValues | Where-Object { $_ -ceq "N/A" }).Count -gt 0) {
    throw "An Approved content-logging exception requires explicit purpose, scope, owner, retention, and expiry values."
}

$customDimensions = @($policy.SelectNodes("//llm-emit-token-metric/dimension[@value]"))
if ($customDimensions.Count -gt 5) {
    throw "APIM token metric policy exceeds five custom dimensions."
}
$dimensionNames = @($policy.SelectNodes("//llm-emit-token-metric/dimension") |
    ForEach-Object { [string]$_.name })
if ($dimensionNames -contains "User ID" -or $dimensionNames -contains "Subscription ID") {
    throw "User- or subscription-level APIM token dimensions are outside this control."
}

$mainApplicationInsightsId = Get-BicepStringParameter -Path $mainParametersPath -Name "applicationInsightsResourceId"
if ($mainApplicationInsightsId -ine $ApprovedApplicationInsightsResourceId) {
    throw "main.bicepparam does not target the approved Application Insights resource."
}
$mainLocation = Get-BicepStringParameter -Path $mainParametersPath -Name "location"
if ($mainLocation -ine $DeploymentLocation) {
    throw "Deployment location differs from main.bicepparam."
}
$mainServiceName = Get-BicepStringParameter -Path $mainParametersPath -Name "serviceName"
if ($mainServiceName -ne [string]$control.serviceName) {
    throw "Service name differs between main.bicepparam and control-definition.json."
}
$budgetAmountText = Get-BicepStringParameter -Path $budgetParametersPath -Name "amount"
$budgetAmount = 0.0
if (-not [decimal]::TryParse(
        $budgetAmountText,
        [Globalization.NumberStyles]::Number,
        [Globalization.CultureInfo]::InvariantCulture,
        [ref]$budgetAmount
    ) -or $budgetAmount -le 0) {
    throw "Budget amount must be a positive number in invariant format."
}

$currentSubscriptionId = [string](az account show --query id -o tsv)
if ($LASTEXITCODE -ne 0 -or $currentSubscriptionId -ine $ApprovedSubscriptionId) {
    throw "Azure CLI is not set to approved subscription '$ApprovedSubscriptionId'."
}
$appInsights = az resource show `
    --ids $ApprovedApplicationInsightsResourceId `
    --api-version 2020-02-02 `
    -o json |
    ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]$appInsights.type -ine "microsoft.insights/components") {
    throw "The approved Application Insights resource could not be resolved."
}
$appInsightsWorkspaceId = [string]$appInsights.properties.WorkspaceResourceId
if ($appInsightsWorkspaceId -notmatch "^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\.OperationalInsights/workspaces/[^/]+$") {
    throw "The approved Application Insights component must expose a valid WorkspaceResourceId."
}
$runtimeWorkspaceId = [Environment]::GetEnvironmentVariable("SESSION13_LOG_ANALYTICS_WORKSPACE_ID")
if (-not [string]::IsNullOrWhiteSpace($runtimeWorkspaceId) -and
    $appInsightsWorkspaceId.TrimEnd("/").ToLowerInvariant() -ne
        $runtimeWorkspaceId.TrimEnd("/").ToLowerInvariant()) {
    throw "The live Application Insights WorkspaceResourceId does not match SESSION13_LOG_ANALYTICS_WORKSPACE_ID."
}
$actionGroupResourceId = Get-BicepStringParameter -Path $mainParametersPath -Name "actionGroupResourceId"
$actionGroup = az resource show --ids $actionGroupResourceId -o json |
    ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or [string]$actionGroup.type -ine "microsoft.insights/actiongroups") {
    throw "The approved Azure Monitor action group could not be resolved."
}

$null = az bicep version
if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI Bicep support is required."
}
$null = az monitor app-insights query --help
if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI Application Insights query support is required by the Session 13 smoke executable."
}
$null = az bicep build --file $mainTemplatePath --stdout
if ($LASTEXITCODE -ne 0) {
    throw "The workbook and alert Bicep template did not compile."
}
$null = az bicep build --file $budgetTemplatePath --stdout
if ($LASTEXITCODE -ne 0) {
    throw "The budget Bicep template did not compile."
}

Write-Host "Preview 1 of 2: workbook and alert rules in $expectedTargetScope"
az deployment group what-if `
    --subscription $ApprovedSubscriptionId `
    --resource-group $ApprovedResourceGroupName `
    --template-file $mainTemplatePath `
    --parameters $mainParametersPath `
    --no-pretty-print
if ($LASTEXITCODE -ne 0) {
    throw "Workbook and alert-rule deployment preview failed."
}

Write-Host "Preview 2 of 2: budget in /subscriptions/$ApprovedSubscriptionId"
az deployment sub what-if `
    --subscription $ApprovedSubscriptionId `
    --location $DeploymentLocation `
    --template-file $budgetTemplatePath `
    --parameters $budgetParametersPath `
    --no-pretty-print
if ($LASTEXITCODE -ne 0) {
    throw "Subscription budget deployment preview failed."
}

Write-Host "PASS: Markdown retention and content-logging decisions, telemetry privacy gates, scope, resources, Bicep compilation, and both previews are ready."
