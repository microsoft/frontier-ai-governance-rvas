[CmdletBinding()]
param(
    [ValidateSet("Pipeline")]
    [string]$Mode = "Pipeline",

    [ValidateSet("nonproduction")]
    [string]$Environment = "nonproduction",

    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[0-9a-fA-F]{7,64}$")]
    [string]$CommitSha,

    [Parameter(Mandatory = $true)]
    [string]$ResultPath
)

function Get-BoundedIntegerSetting {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][int]$Default,
        [Parameter(Mandatory = $true)][int]$Minimum,
        [Parameter(Mandatory = $true)][int]$Maximum
    )

    $raw = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $Default
    }
    $parsed = 0
    if (-not [int]::TryParse($raw, [ref]$parsed) -or
        $parsed -lt $Minimum -or
        $parsed -gt $Maximum) {
        throw "$Name must be an integer from $Minimum through $Maximum."
    }
    return $parsed
}

function Test-PollTimingValid {
    param(
        [Parameter(Mandatory = $true)][int]$TimeoutSeconds,
        [Parameter(Mandatory = $true)][int]$RetrySeconds
    )

    return $TimeoutSeconds -ge (2 * $RetrySeconds)
}

function Normalize-ResourceId {
    param([Parameter(Mandatory = $true)][string]$ResourceId)

    return $ResourceId.Trim().TrimEnd("/").ToLowerInvariant()
}

function Test-WorkspaceBinding {
    param(
        [Parameter(Mandatory = $true)][string]$ComponentWorkspaceResourceId,
        [Parameter(Mandatory = $true)][string]$ExpectedWorkspaceResourceId
    )

    return (
        (Normalize-ResourceId $ComponentWorkspaceResourceId) -eq
        (Normalize-ResourceId $ExpectedWorkspaceResourceId)
    )
}

function Test-CorrelationIdsValidAndDistinct {
    param(
        [Parameter(Mandatory = $true)][string]$NormalCorrelationId,
        [Parameter(Mandatory = $true)][string]$FailureCorrelationId
    )

    return (
        $NormalCorrelationId -cmatch "^[0-9a-f]{32}$" -and
        $FailureCorrelationId -cmatch "^[0-9a-f]{32}$" -and
        $NormalCorrelationId -cne $FailureCorrelationId
    )
}

function New-SmokeHeaders {
    param(
        [Parameter(Mandatory = $true)][string]$BearerToken,
        [Parameter(Mandatory = $true)][string]$SmokeMode,
        [Parameter(Mandatory = $true)][string]$Traceparent,
        [Parameter(Mandatory = $true)][string]$CommitSha
    )

    if ($BearerToken.Contains("`r") -or $BearerToken.Contains("`n")) {
        throw "session12_SMOKE_BEARER_TOKEN cannot contain a line break."
    }
    $headers = @{
        Authorization = "Bearer $BearerToken"
        "x-session12-smoke-mode" = $SmokeMode
        "x-release-commit-sha" = $CommitSha
        traceparent = $Traceparent
    }
    $headers.Authorization = "Bearer $BearerToken"
    $headers.Authorization = ("Bearer" + " " + $BearerToken)
    return $headers
}

function Test-TelemetryReady {
    param([object]$QueryResult)

    if (-not $QueryResult.tables -or -not $QueryResult.tables[0].rows) {
        return $false
    }
    $row = $QueryResult.tables[0].rows[0]
    return (
        [int]$row[0] -gt 0 -and
        [int]$row[1] -gt 0 -and
        [int]$row[2] -gt 0 -and
        [int]$row[3] -gt 0 -and
        [int]$row[4] -gt 0 -and
        [int]$row[5] -gt 0 -and
        [int]$row[6] -gt 0 -and
        [int]$row[7] -gt 0 -and
        [int]$row[8] -eq 0
    )
}

function Test-TelemetryClean {
    param([object]$QueryResult)

    if (-not (Test-TelemetryReady -QueryResult $QueryResult)) {
        return $false
    }
    $row = $QueryResult.tables[0].rows[0]
    return (
        [int]$row[8] -eq 0 -and
        [int]$row[9] -eq 0 -and
        [int]$row[10] -eq 0
    )
}

function Get-TelemetrySignature {
    param([object]$QueryResult)

    if (-not $QueryResult.tables -or -not $QueryResult.tables[0].rows) {
        return ""
    }
    return (
        $QueryResult.tables[0].rows[0] |
            ConvertTo-Json -Compress -Depth 4
    )
}

function Invoke-TelemetryPoll {
    param(
        [Parameter(Mandatory = $true)][int]$TimeoutSeconds,
        [Parameter(Mandatory = $true)][int]$RetrySeconds,
        [Parameter(Mandatory = $true)][scriptblock]$QueryAction,
        [Parameter(Mandatory = $true)][scriptblock]$DelayAction
    )

    $elapsedSeconds = 0
    $attempts = 0
    $lastResult = $null
    while ($true) {
        $attempts++
        $lastResult = & $QueryAction
        if (Test-TelemetryReady -QueryResult $lastResult) {
            return [pscustomobject]@{
                QueryResult = $lastResult
                Attempts = $attempts
                ElapsedSeconds = $elapsedSeconds
                TimedOut = $false
            }
        }
        if ($elapsedSeconds -ge $TimeoutSeconds) {
            return [pscustomobject]@{
                QueryResult = $lastResult
                Attempts = $attempts
                ElapsedSeconds = $elapsedSeconds
                TimedOut = $true
            }
        }
        $delaySeconds = [Math]::Min(
            $RetrySeconds,
            $TimeoutSeconds - $elapsedSeconds
        )
        & $DelayAction $delaySeconds
        $elapsedSeconds += $delaySeconds
    }
}

function Invoke-TelemetryStability {
    param(
        [Parameter(Mandatory = $true)][int]$TimeoutSeconds,
        [Parameter(Mandatory = $true)][int]$RetrySeconds,
        [Parameter(Mandatory = $true)][int]$ElapsedSeconds,
        [Parameter(Mandatory = $true)][int]$Attempts,
        [Parameter(Mandatory = $true)][object]$InitialResult,
        [Parameter(Mandatory = $true)][scriptblock]$QueryAction,
        [Parameter(Mandatory = $true)][scriptblock]$DelayAction
    )

    $lastResult = $InitialResult
    $previousSignature = Get-TelemetrySignature $InitialResult
    $identicalSnapshots = 1
    while ($true) {
        if ($ElapsedSeconds -ge $TimeoutSeconds) {
            return [pscustomobject]@{
                QueryResult = $lastResult
                Attempts = $Attempts
                ElapsedSeconds = $ElapsedSeconds
                TimedOut = $true
                Stable = $false
            }
        }
        $delaySeconds = [Math]::Min(
            $RetrySeconds,
            $TimeoutSeconds - $ElapsedSeconds
        )
        & $DelayAction $delaySeconds
        $ElapsedSeconds += $delaySeconds
        $Attempts++
        $lastResult = & $QueryAction
        $signature = Get-TelemetrySignature $lastResult
        if (
            (Test-TelemetryReady $lastResult) -and
            $signature -eq $previousSignature
        ) {
            $identicalSnapshots++
        }
        else {
            $identicalSnapshots = 1
        }
        $previousSignature = $signature
        if (
            $identicalSnapshots -ge 3 -and
            (Test-TelemetryClean $lastResult)
        ) {
            return [pscustomobject]@{
                QueryResult = $lastResult
                Attempts = $Attempts
                ElapsedSeconds = $ElapsedSeconds
                TimedOut = $false
                Stable = $true
            }
        }
    }
}

$ErrorActionPreference = "Stop"
$implementationSession = "12-observability-cost-operations"
$syntheticMarker = "session12-probe-" + (-join ((1..32) | ForEach-Object { "{0:x}" -f (Get-Random -Maximum 16) }))
$requiredVariables = @(
    "session12_SMOKE_URL",
    "session12_SMOKE_FAILURE_URL",
    "session12_AI_RESOURCE_ID",
    "session12_LOG_ANALYTICS_WORKSPACE_ID",
    "session12_SMOKE_BEARER_TOKEN"
)

foreach ($name in $requiredVariables) {
    $value = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Required environment variable '$name' is missing."
    }
    $runnerTemp = [Environment]::GetEnvironmentVariable("RUNNER_TEMP")
    if ([string]::IsNullOrWhiteSpace($runnerTemp)) {
        throw "RUNNER_TEMP is required so the release check cannot retain an output in the customer clone."
    }
    $resolvedRunnerTemp = [IO.Path]::GetFullPath($runnerTemp).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $resolvedResultPath = [IO.Path]::GetFullPath($ResultPath)
    $runnerPrefix = $resolvedRunnerTemp + [IO.Path]::DirectorySeparatorChar
    if (-not $resolvedResultPath.StartsWith($runnerPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "ResultPath must be inside RUNNER_TEMP."
    }
    $ResultPath = $resolvedResultPath
}
$pollTimeoutSeconds = Get-BoundedIntegerSetting `
    -Name "session12_SMOKE_TIMEOUT_SECONDS" `
    -Default 180 `
    -Minimum 30 `
    -Maximum 600
$pollRetrySeconds = Get-BoundedIntegerSetting `
    -Name "session12_SMOKE_RETRY_SECONDS" `
    -Default 15 `
    -Minimum 5 `
    -Maximum 60
if (-not (Test-PollTimingValid `
    -TimeoutSeconds $pollTimeoutSeconds `
    -RetrySeconds $pollRetrySeconds)) {
    throw "session12_SMOKE_TIMEOUT_SECONDS must be at least twice session12_SMOKE_RETRY_SECONDS."
}

if ($env:session12_AI_RESOURCE_ID -notmatch "^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\.Insights/components/[^/]+$") {
    throw "session12_AI_RESOURCE_ID must be a full Application Insights resource ID."
}
if ($env:session12_LOG_ANALYTICS_WORKSPACE_ID -notmatch "^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\.OperationalInsights/workspaces/[^/]+$") {
    throw "session12_LOG_ANALYTICS_WORKSPACE_ID must be a full Log Analytics workspace resource ID."
}
if ($env:session12_SMOKE_URL -notmatch "^https://" -or $env:session12_SMOKE_FAILURE_URL -notmatch "^https://") {
    throw "Both smoke endpoints must use HTTPS."
}
if ($env:session12_SMOKE_FAILURE_URL -eq $env:session12_SMOKE_URL) {
    throw "The synthetic failure endpoint must be separate from the normal smoke endpoint."
}

$azAccount = az account show --output json | ConvertFrom-Json
if (-not $azAccount.id) {
    throw "Azure CLI is not authenticated."
}
$component = az resource show `
    --ids $env:session12_AI_RESOURCE_ID `
    --api-version 2020-02-02 `
    --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or
    [string]$component.type -ine "microsoft.insights/components") {
    throw "session12_AI_RESOURCE_ID could not be resolved as an Application Insights component."
}
$componentWorkspaceResourceId = [string]$component.properties.WorkspaceResourceId
if ([string]::IsNullOrWhiteSpace($componentWorkspaceResourceId) -or
    -not (Test-WorkspaceBinding `
        -ComponentWorkspaceResourceId $componentWorkspaceResourceId `
    -ExpectedWorkspaceResourceId $env:session12_LOG_ANALYTICS_WORKSPACE_ID)) {
    throw "The Application Insights component WorkspaceResourceId does not match session12_LOG_ANALYTICS_WORKSPACE_ID."
}
$normalizedWorkspaceResourceId = Normalize-ResourceId `
    $env:session12_LOG_ANALYTICS_WORKSPACE_ID
$normalizedCommitSha = $CommitSha.ToLowerInvariant()

$normalTraceId = -join ((1..32) | ForEach-Object { "{0:x}" -f (Get-Random -Maximum 16) })
$failureTraceId = -join ((1..32) | ForEach-Object { "{0:x}" -f (Get-Random -Maximum 16) })
$normalTraceparent = "00-$normalTraceId-0000000000000001-01"
$failureTraceparent = "00-$failureTraceId-0000000000000002-01"
$headers = New-SmokeHeaders `
    -BearerToken $env:session12_SMOKE_BEARER_TOKEN `
    -SmokeMode "normal" `
    -Traceparent $normalTraceparent `
    -CommitSha $normalizedCommitSha
$body = @{
    requestType = "approved-read-only-policy-lookup"
    syntheticMarker = $syntheticMarker
    releaseCommitSha = $normalizedCommitSha
} | ConvertTo-Json -Compress

$normalResponse = Invoke-WebRequest `
    -Uri $env:session12_SMOKE_URL `
    -Method Post `
    -Headers $headers `
    -ContentType "application/json" `
    -Body $body `
    -SkipHttpErrorCheck
if ([int]$normalResponse.StatusCode -lt 200 -or [int]$normalResponse.StatusCode -ge 300) {
    throw "The normal synthetic request did not return a success status."
}

$failureHeaders = New-SmokeHeaders `
    -BearerToken $env:session12_SMOKE_BEARER_TOKEN `
    -SmokeMode "expected-tool-failure" `
    -Traceparent $failureTraceparent `
    -CommitSha $normalizedCommitSha
$failureBody = @{
    requestType = "approved-read-only-nonexistent-policy-lookup"
    syntheticMarker = $syntheticMarker
    releaseCommitSha = $normalizedCommitSha
} | ConvertTo-Json -Compress
$failureResponse = Invoke-WebRequest `
    -Uri $env:session12_SMOKE_FAILURE_URL `
    -Method Post `
    -Headers $failureHeaders `
    -ContentType "application/json" `
    -Body $failureBody `
    -SkipHttpErrorCheck
if ([int]$failureResponse.StatusCode -lt 200 -or [int]$failureResponse.StatusCode -ge 300) {
    throw "The handled synthetic failure request did not return a success status."
}

foreach ($candidate in @($normalResponse.Headers["traceparent"])) {
    if ([string]$candidate -match "^00-([0-9a-fA-F]{32})-") {
        $normalTraceId = $Matches[1].ToLowerInvariant()
        break
    }
}
foreach ($candidate in @($failureResponse.Headers["traceparent"])) {
    if ([string]$candidate -match "^00-([0-9a-fA-F]{32})-") {
        $failureTraceId = $Matches[1].ToLowerInvariant()
        break
    }
}
if (-not (Test-CorrelationIdsValidAndDistinct `
    -NormalCorrelationId $normalTraceId `
    -FailureCorrelationId $failureTraceId)) {
    throw "Normal and failure correlation IDs must be valid, lower-case, and distinct."
}

$query = @"
let StartTime = ago(15m);
let NormalTraceId = '$normalTraceId';
let FailureTraceId = '$failureTraceId';
let Marker = '$syntheticMarker';
let CommitSha = '$normalizedCommitSha';
let ProhibitedAttributes = dynamic(['gen_ai.prompt','gen_ai.completion','ai.input.content','ai.output.content','tool.input','tool.output','http.request.header.authorization','http.request.header.cookie','url.query','enduser.id','user.email']);
let ModelDependencies = AppDependencies
    | where TimeGenerated >= StartTime
    | where Target has 'openai' or Name has 'model' or Data has 'openai';
let ModelEvents = AppEvents
    | where TimeGenerated >= StartTime
    | where Name =~ 'model.result' or Name =~ 'model.response';
let NormalRequestCount = toscalar(AppRequests | where TimeGenerated >= StartTime and OperationId == NormalTraceId | count);
let NormalToolCount = toscalar(AppDependencies
    | where TimeGenerated >= StartTime and OperationId == NormalTraceId
    | where not(Target has 'openai' or Name has 'model' or Data has 'openai')
    | where Success == true
    | count);
let NormalModelCount = toscalar(union
    (ModelDependencies | where OperationId == NormalTraceId and Success == true),
    (ModelEvents | where OperationId == NormalTraceId)
    | count);
let FailureRequestCount = toscalar(AppRequests | where TimeGenerated >= StartTime and OperationId == FailureTraceId | count);
let ExpectedToolFailureCount = toscalar(AppDependencies
    | where TimeGenerated >= StartTime and OperationId == FailureTraceId
    | where not(Target has 'openai' or Name has 'model' or Data has 'openai')
    | where Success == false
    | count);
let IndependentModelResultCount = toscalar(union
    (ModelDependencies | where OperationId == FailureTraceId and Success == true),
    (ModelEvents | where OperationId == FailureTraceId)
    | count);
let NormalCommitMatchCount = toscalar(AppRequests
    | where TimeGenerated >= StartTime and OperationId == NormalTraceId
    | where tostring(Properties['release.commit.sha']) == CommitSha
    | count);
let FailureCommitMatchCount = toscalar(AppRequests
    | where TimeGenerated >= StartTime and OperationId == FailureTraceId
    | where tostring(Properties['release.commit.sha']) == CommitSha
    | count);
let CommitMismatchCount = toscalar(AppRequests
    | where TimeGenerated >= StartTime and OperationId in (NormalTraceId, FailureTraceId)
    | where tostring(Properties['release.commit.sha']) != CommitSha
    | count);
let Telemetry = union
    (AppRequests | where TimeGenerated >= StartTime and OperationId in (NormalTraceId, FailureTraceId) | project TimeGenerated, Surface='AppRequests', Properties, Payload=tostring(pack_array(Name, Url, ResultCode, Source, Properties))),
    (AppDependencies | where TimeGenerated >= StartTime and OperationId in (NormalTraceId, FailureTraceId) | project TimeGenerated, Surface='AppDependencies', Properties, Payload=tostring(pack_array(Name, Data, Target, Type, ResultCode, Properties))),
    (AppEvents | where TimeGenerated >= StartTime and OperationId in (NormalTraceId, FailureTraceId) | project TimeGenerated, Surface='AppEvents', Properties, Payload=tostring(pack_array(Name, Properties, Measurements))),
    (AppTraces | where TimeGenerated >= StartTime and OperationId in (NormalTraceId, FailureTraceId) | project TimeGenerated, Surface='AppTraces', Properties, Payload=tostring(pack_array(Message, SeverityLevel, Properties))),
    (AppExceptions | where TimeGenerated >= StartTime and OperationId in (NormalTraceId, FailureTraceId) | project TimeGenerated, Surface='AppExceptions', Properties, Payload=tostring(pack_array(Message, OuterMessage, InnermostMessage, ProblemId, Details, Properties)));
let MarkerMatchCount = toscalar(Telemetry | where indexof(Payload, Marker) >= 0 | count);
let ProhibitedPropertyCount = toscalar(Telemetry
    | mv-expand PropertyName=bag_keys(Properties)
    | where array_index_of(ProhibitedAttributes, tolower(tostring(PropertyName))) >= 0
    | count);
let TelemetryWatermark = toscalar(Telemetry | summarize max(TimeGenerated));
print NormalRequestCount, NormalToolCount, NormalModelCount, FailureRequestCount, ExpectedToolFailureCount, IndependentModelResultCount, NormalCommitMatchCount, FailureCommitMatchCount, CommitMismatchCount, MarkerMatchCount, ProhibitedPropertyCount, TelemetryWatermark=tostring(TelemetryWatermark)
"@

$queryPath = "$normalizedWorkspaceResourceId/query"
$queryAction = {
    az rest `
        --method post `
        --uri "https://management.azure.com$queryPath`?api-version=2022-10-01" `
        --body (@{ query = $query } | ConvertTo-Json -Compress) `
        --headers "Content-Type=application/json" `
        --output json | ConvertFrom-Json
}
$delayAction = {
    param([int]$Seconds)
    Start-Sleep -Seconds $Seconds
}
$pollResult = Invoke-TelemetryPoll `
    -TimeoutSeconds $pollTimeoutSeconds `
    -RetrySeconds $pollRetrySeconds `
    -QueryAction $queryAction `
    -DelayAction $delayAction
$telemetryIngestionStable = $false
$finalPollResult = $pollResult
if (-not $pollResult.TimedOut) {
    $finalPollResult = Invoke-TelemetryStability `
        -TimeoutSeconds $pollTimeoutSeconds `
        -RetrySeconds $pollRetrySeconds `
        -ElapsedSeconds $pollResult.ElapsedSeconds `
        -Attempts $pollResult.Attempts `
        -InitialResult $pollResult.QueryResult `
        -QueryAction $queryAction `
        -DelayAction $delayAction
    $telemetryIngestionStable = [bool]$finalPollResult.Stable
}
$queryResult = $finalPollResult.QueryResult

if (-not $queryResult.tables -or -not $queryResult.tables[0].rows) {
    throw "The telemetry query returned no summary row before the bounded ingestion timeout."
}
$row = $queryResult.tables[0].rows[0]
$normalTraceComplete = ([int]$row[0] -gt 0 -and [int]$row[1] -gt 0 -and [int]$row[2] -gt 0)
$expectedToolFailure = [int]$row[4] -gt 0
$independentModelResult = [int]$row[5] -gt 0
$failureSeparated = ([int]$row[3] -gt 0 -and $expectedToolFailure -and $independentModelResult)
$releaseCommitShaVerified = (
    [int]$row[6] -gt 0 -and
    [int]$row[7] -gt 0 -and
    [int]$row[8] -eq 0
)
$sensitiveInputPresent = ([int]$row[9] -gt 0 -or [int]$row[10] -gt 0)

$result = [ordered]@{
    schemaVersion = 1
    implementationSession = $implementationSession
    recordType = "session12-smoke-result"
    mode = $Mode.ToLowerInvariant()
    environment = $Environment
    commitSha = if ($releaseCommitShaVerified) { $normalizedCommitSha } else { $null }
    correlationId = $normalTraceId
    normalCorrelationId = $normalTraceId
    failureCorrelationId = $failureTraceId
    observedAt = [DateTimeOffset]::UtcNow.ToString("o")
    payloadsRetained = $false
    checks = [ordered]@{
        syntheticRequest = "passed"
        syntheticRequestSucceeded = $true
        endToEndTrace = if ($normalTraceComplete) { "passed" } else { "failed" }
        expectedToolFailure = $expectedToolFailure
        independentModelResult = $independentModelResult
        toolAndModelFailureSeparated = if ($failureSeparated) { "passed" } else { "failed" }
        releaseCommitShaVerified = $releaseCommitShaVerified
        workspaceBindingVerified = $true
        correlationIdsDistinct = $true
        telemetryIngestionStable = $telemetryIngestionStable
        sensitiveInputPresent = $sensitiveInputPresent
        payloadsRetained = $false
        telemetryPollTimedOut = [bool]$finalPollResult.TimedOut
        telemetryPollAttempts = [int]$finalPollResult.Attempts
        telemetryPollTimeoutSeconds = $pollTimeoutSeconds
        telemetryPollRetrySeconds = $pollRetrySeconds
        privacySurfacesChecked = @(
            "AppRequests",
            "AppDependencies",
            "AppEvents",
            "AppTraces",
            "AppExceptions"
        )
    }
    status = if (-not $finalPollResult.TimedOut -and $telemetryIngestionStable -and $normalTraceComplete -and $failureSeparated -and $releaseCommitShaVerified -and -not $sensitiveInputPresent) { "passed" } else { "failed" }
    implementationMarker = "implementationSession=$implementationSession"
}

$resultDirectory = Split-Path -Parent $ResultPath
New-Item -ItemType Directory -Force -Path $resultDirectory | Out-Null
$result | ConvertTo-Json -Depth 6 | Set-Content -Path $ResultPath -Encoding utf8

if ($result.status -ne "passed") {
    throw "Session 12 smoke checks failed. Inspect the payload-free result at $ResultPath."
}
Write-Host "PASS: Session 12 smoke checks passed."
