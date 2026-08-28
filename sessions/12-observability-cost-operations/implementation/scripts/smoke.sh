#!/usr/bin/env bash
set -euo pipefail
set +x

telemetry_result_ready() {
  local value="$1"
  jq -e '
    (.tables[0].rows | length) > 0
    and ([.tables[0].rows[0][0:8][] | tonumber] | all(. > 0))
    and ((.tables[0].rows[0][8] | tonumber) == 0)
  ' >/dev/null <<<"$value"
}

telemetry_result_clean() {
  local value="$1"
  telemetry_result_ready "$value" \
    && jq -e '
      ((.tables[0].rows[0][8] | tonumber) == 0)
      and ((.tables[0].rows[0][9] | tonumber) == 0)
      and ((.tables[0].rows[0][10] | tonumber) == 0)
    ' >/dev/null <<<"$value"
}

telemetry_signature() {
  jq -c '.tables[0].rows[0] // []' <<<"$1"
}

normalize_resource_id() {
  local value="$1"
  value="${value%/}"
  printf '%s' "${value,,}"
}

workspace_binding_matches() {
  [[ "$(normalize_resource_id "$1")" == "$(normalize_resource_id "$2")" ]]
}

correlation_ids_valid_and_distinct() {
  [[ "$1" =~ ^[0-9a-f]{32}$ && "$2" =~ ^[0-9a-f]{32}$ && "$1" != "$2" ]]
}

poll_timing_valid() {
  (( $1 >= 2 * $2 ))
}

invoke_smoke_request() {
  local bearer_token="$1"
  local request_url="$2"
  local smoke_mode="$3"
  local traceparent_value="$4"
  local commit_sha_value="$5"
  local request_body="$6"
  local response_headers_path="$7"

  [[ "$bearer_token" != *$'\r'* && "$bearer_token" != *$'\n'* ]] \
    || { echo "ERROR: SESSION12_SMOKE_BEARER_TOKEN cannot contain a line break." >&2; return 1; }
  {
    printf 'header = "Authorization: Bearer %s"\n' "$bearer_token"
    printf 'header = "Content-Type: application/json"\n'
    printf 'header = "x-session12-smoke-mode: %s"\n' "$smoke_mode"
    printf 'header = "x-release-commit-sha: %s"\n' "$commit_sha_value"
    printf 'header = "traceparent: %s"\n' "$traceparent_value"
  } | (
    unset SESSION12_SMOKE_BEARER_TOKEN
    curl --config - \
      --silent \
      --show-error \
      --request POST "$request_url" \
      --data "$request_body" \
      --dump-header "$response_headers_path" \
      --output /dev/null \
      --write-out '%{http_code}'
  )
}

invoke_smoke_request() {
  local bearer_token="$1"
  local request_url="$2"
  local smoke_mode="$3"
  local traceparent_value="$4"
  local commit_sha_value="$5"
  local request_body="$6"
  local response_headers_path="$7"

  [[ "$bearer_token" != *$'\r'* && "$bearer_token" != *$'\n'* ]] \
    || { echo "ERROR: SESSION12_SMOKE_BEARER_TOKEN cannot contain a line break." >&2; return 1; }
  {
    printf 'header = "Authorization: Bearer %s"\n' "$bearer_token"
    printf 'header = "Content-Type: application/json"\n'
    printf 'header = "x-session12-smoke-mode: %s"\n' "$smoke_mode"
    printf 'header = "x-release-commit-sha: %s"\n' "$commit_sha_value"
    printf 'header = "traceparent: %s"\n' "$traceparent_value"
  } | (
    unset SESSION12_SMOKE_BEARER_TOKEN
    curl --config - \
      --silent \
      --show-error \
      --request POST "$request_url" \
      --data "$request_body" \
      --dump-header "$response_headers_path" \
      --output /dev/null \
      --write-out '%{http_code}'
  )
}

invoke_smoke_request() {
  local bearer_token="$1"
  local request_url="$2"
  local smoke_mode="$3"
  local traceparent_value="$4"
  local commit_sha_value="$5"
  local request_body="$6"
  local response_headers_path="$7"

  [[ "$bearer_token" != *$'\r'* && "$bearer_token" != *$'\n'* ]] \
    || { echo "ERROR: SESSION12_SMOKE_BEARER_TOKEN cannot contain a line break." >&2; return 1; }
  {
    printf 'header = "Authorization: %s %s"\n' "Bearer" "$bearer_token"
    printf 'header = "Content-Type: application/json"\n'
    printf 'header = "x-session12-smoke-mode: %s"\n' "$smoke_mode"
    printf 'header = "x-release-commit-sha: %s"\n' "$commit_sha_value"
    printf 'header = "traceparent: %s"\n' "$traceparent_value"
  } | (
    unset SESSION12_SMOKE_BEARER_TOKEN
    curl --config - \
      --silent \
      --show-error \
      --request POST "$request_url" \
      --data "$request_body" \
      --dump-header "$response_headers_path" \
      --output /dev/null \
      --write-out '%{http_code}'
  )
}

poll_telemetry() {
  local timeout_seconds="$1"
  local retry_seconds="$2"
  local query_action="$3"
  local delay_action="$4"
  local elapsed_seconds=0

  telemetry_poll_attempts=0
  telemetry_poll_elapsed_seconds=0
  telemetry_poll_timed_out=false
  query_result=""
  while true; do
    telemetry_poll_attempts=$((telemetry_poll_attempts + 1))
    "$query_action" || return 2
    if telemetry_result_ready "$query_result"; then
      telemetry_poll_elapsed_seconds="$elapsed_seconds"
      return 0
    fi
    if (( elapsed_seconds >= timeout_seconds )); then
      telemetry_poll_timed_out=true
      telemetry_poll_elapsed_seconds="$elapsed_seconds"
      return 1
    fi
    local delay_seconds="$retry_seconds"
    if (( elapsed_seconds + delay_seconds > timeout_seconds )); then
      delay_seconds=$((timeout_seconds - elapsed_seconds))
    fi
    "$delay_action" "$delay_seconds" || return 2
    elapsed_seconds=$((elapsed_seconds + delay_seconds))
  done
}

stabilize_telemetry() {
  local timeout_seconds="$1"
  local retry_seconds="$2"
  local query_action="$3"
  local delay_action="$4"
  local previous_signature
  local current_signature
  local identical_snapshots=1
  local delay_seconds

  previous_signature="$(telemetry_signature "$query_result")"
  telemetry_ingestion_stable=false
  while true; do
    if (( telemetry_poll_elapsed_seconds >= timeout_seconds )); then
      telemetry_poll_timed_out=true
      return 1
    fi
    delay_seconds="$retry_seconds"
    if (( telemetry_poll_elapsed_seconds + delay_seconds > timeout_seconds )); then
      delay_seconds=$((timeout_seconds - telemetry_poll_elapsed_seconds))
    fi
    "$delay_action" "$delay_seconds" || return 2
    telemetry_poll_elapsed_seconds=$((telemetry_poll_elapsed_seconds + delay_seconds))
    telemetry_poll_attempts=$((telemetry_poll_attempts + 1))
    "$query_action" || return 2
    current_signature="$(telemetry_signature "$query_result")"
    if telemetry_result_ready "$query_result" && [[ "$current_signature" == "$previous_signature" ]]; then
      identical_snapshots=$((identical_snapshots + 1))
    else
      identical_snapshots=1
    fi
    previous_signature="$current_signature"
    if (( identical_snapshots >= 3 )) && telemetry_result_clean "$query_result"; then
      telemetry_ingestion_stable=true
      return 0
    fi
  done
}

wait_for_retry() {
  sleep "$1"
}

main() {
mode=""
environment=""
commit_sha=""
result_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) mode="${2:-}"; shift 2 ;;
    --environment) environment="${2:-}"; shift 2 ;;
    --commit-sha) commit_sha="${2:-}"; shift 2 ;;
    --result-path) result_path="${2:-}"; shift 2 ;;
    *) echo "ERROR: unknown argument '$1'." >&2; exit 2 ;;
  esac
done

[[ "$mode" == "pipeline" ]] || { echo "ERROR: --mode must be pipeline." >&2; exit 2; }
[[ "$environment" == "nonproduction" ]] || { echo "ERROR: --environment must be nonproduction." >&2; exit 2; }
[[ "$commit_sha" =~ ^[0-9a-fA-F]{7,64}$ ]] || { echo "ERROR: --commit-sha must be a 7-64 character hexadecimal commit SHA." >&2; exit 2; }
[[ -n "$result_path" ]] || { echo "ERROR: --result-path is required." >&2; exit 2; }
[[ -n "${RUNNER_TEMP:-}" ]] || { echo "ERROR: RUNNER_TEMP is required so the release check cannot retain an output in the customer clone." >&2; exit 1; }
[[ -d "$RUNNER_TEMP" ]] || { echo "ERROR: RUNNER_TEMP must be an existing directory." >&2; exit 1; }
mkdir -p "$(dirname -- "$result_path")"
runner_temp="$(cd -- "$RUNNER_TEMP" && pwd)"
result_directory="$(cd -- "$(dirname -- "$result_path")" && pwd)"
case "$result_directory/" in
  "$runner_temp/"*) result_path="$result_directory/$(basename -- "$result_path")" ;;
  *) echo "ERROR: --result-path must be inside RUNNER_TEMP." >&2; exit 1 ;;
esac

[[ -n "${SESSION12_SMOKE_URL:-}" ]] || { echo "ERROR: required environment variable 'SESSION12_SMOKE_URL' is missing." >&2; exit 1; }
[[ -n "${SESSION12_SMOKE_FAILURE_URL:-}" ]] || { echo "ERROR: required environment variable 'SESSION12_SMOKE_FAILURE_URL' is missing." >&2; exit 1; }
[[ -n "${SESSION12_AI_RESOURCE_ID:-}" ]] || { echo "ERROR: required environment variable 'SESSION12_AI_RESOURCE_ID' is missing." >&2; exit 1; }
[[ -n "${SESSION12_LOG_ANALYTICS_WORKSPACE_ID:-}" ]] || { echo "ERROR: required environment variable 'SESSION12_LOG_ANALYTICS_WORKSPACE_ID' is missing." >&2; exit 1; }
[[ -n "${SESSION12_SMOKE_BEARER_TOKEN:-}" ]] || { echo "ERROR: required environment variable 'SESSION12_SMOKE_BEARER_TOKEN' is missing." >&2; exit 1; }
poll_timeout_seconds="${SESSION12_SMOKE_TIMEOUT_SECONDS:-180}"
poll_retry_seconds="${SESSION12_SMOKE_RETRY_SECONDS:-15}"
[[ "$poll_timeout_seconds" =~ ^[0-9]+$ ]] && (( poll_timeout_seconds >= 30 && poll_timeout_seconds <= 600 )) \
  || { echo "ERROR: SESSION12_SMOKE_TIMEOUT_SECONDS must be an integer from 30 through 600." >&2; exit 1; }
[[ "$poll_retry_seconds" =~ ^[0-9]+$ ]] && (( poll_retry_seconds >= 5 && poll_retry_seconds <= 60 )) \
  || { echo "ERROR: SESSION12_SMOKE_RETRY_SECONDS must be an integer from 5 through 60." >&2; exit 1; }
poll_timeout_seconds=$((10#$poll_timeout_seconds))
poll_retry_seconds=$((10#$poll_retry_seconds))
poll_timing_valid "$poll_timeout_seconds" "$poll_retry_seconds" \
  || { echo "ERROR: SESSION12_SMOKE_TIMEOUT_SECONDS must be at least twice SESSION12_SMOKE_RETRY_SECONDS." >&2; exit 1; }

[[ "$SESSION12_AI_RESOURCE_ID" =~ ^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\.Insights/components/[^/]+$ ]] \
  || { echo "ERROR: SESSION12_AI_RESOURCE_ID must be a full Application Insights resource ID." >&2; exit 1; }
[[ "$SESSION12_LOG_ANALYTICS_WORKSPACE_ID" =~ ^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\.OperationalInsights/workspaces/[^/]+$ ]] \
  || { echo "ERROR: SESSION12_LOG_ANALYTICS_WORKSPACE_ID must be a full Log Analytics workspace resource ID." >&2; exit 1; }
[[ "$SESSION12_SMOKE_URL" == https://* && "$SESSION12_SMOKE_FAILURE_URL" == https://* ]] \
  || { echo "ERROR: both smoke endpoints must use HTTPS." >&2; exit 1; }
[[ "$SESSION12_SMOKE_URL" != "$SESSION12_SMOKE_FAILURE_URL" ]] \
  || { echo "ERROR: the synthetic failure endpoint must be separate from the normal smoke endpoint." >&2; exit 1; }
for command in az curl jq python3; do
  command -v "$command" >/dev/null 2>&1 || { echo "ERROR: required command '$command' was not found." >&2; exit 1; }
done

subscription_id="$(az account show --query id --output tsv)"
[[ -n "$subscription_id" ]] || { echo "ERROR: Azure CLI is not authenticated." >&2; exit 1; }
component_json="$(az resource show \
  --ids "$SESSION12_AI_RESOURCE_ID" \
  --api-version 2020-02-02 \
  --output json)"
component_type="$(jq -r '.type // empty' <<<"$component_json")"
component_workspace_resource_id="$(jq -r '.properties.WorkspaceResourceId // .properties.workspaceResourceId // empty' <<<"$component_json")"
[[ "${component_type,,}" == "microsoft.insights/components" ]] \
  || { echo "ERROR: SESSION12_AI_RESOURCE_ID could not be resolved as an Application Insights component." >&2; exit 1; }
workspace_binding_matches "$component_workspace_resource_id" "$SESSION12_LOG_ANALYTICS_WORKSPACE_ID" \
  || { echo "ERROR: the Application Insights component WorkspaceResourceId does not match SESSION12_LOG_ANALYTICS_WORKSPACE_ID." >&2; exit 1; }
normalized_workspace_resource_id="$(normalize_resource_id "$SESSION12_LOG_ANALYTICS_WORKSPACE_ID")"
normalized_commit_sha="${commit_sha,,}"

normal_trace_id="$(python3 -c 'import secrets; print(secrets.token_hex(16))')"
failure_trace_id="$(python3 -c 'import secrets; print(secrets.token_hex(16))')"
normal_traceparent="00-${normal_trace_id}-0000000000000001-01"
failure_traceparent="00-${failure_trace_id}-0000000000000002-01"
synthetic_marker="session12-probe-$(python3 -c 'import secrets; print(secrets.token_hex(16))')"
normal_body="$(jq -nc --arg marker "$synthetic_marker" --arg commit "$normalized_commit_sha" '{requestType:"approved-read-only-policy-lookup",syntheticMarker:$marker,releaseCommitSha:$commit}')"
failure_body="$(jq -nc --arg marker "$synthetic_marker" --arg commit "$normalized_commit_sha" '{requestType:"approved-read-only-nonexistent-policy-lookup",syntheticMarker:$marker,releaseCommitSha:$commit}')"

normal_headers="${result_path}.normal.headers"
failure_headers="${result_path}.failure.headers"
cleanup() {
  rm -f "$normal_headers" "$failure_headers"
}
trap cleanup EXIT

normal_status="$(invoke_smoke_request \
  "$SESSION12_SMOKE_BEARER_TOKEN" \
  "$SESSION12_SMOKE_URL" \
  "normal" \
  "$normal_traceparent" \
  "$normalized_commit_sha" \
  "$normal_body" \
  "$normal_headers")"
[[ "$normal_status" =~ ^2[0-9][0-9]$ ]] || { echo "ERROR: the normal synthetic request did not return a success status." >&2; exit 1; }

failure_status="$(invoke_smoke_request \
  "$SESSION12_SMOKE_BEARER_TOKEN" \
  "$SESSION12_SMOKE_FAILURE_URL" \
  "expected-tool-failure" \
  "$failure_traceparent" \
  "$normalized_commit_sha" \
  "$failure_body" \
  "$failure_headers")"
[[ "$failure_status" =~ ^2[0-9][0-9]$ ]] || { echo "ERROR: the handled synthetic failure request did not return a success status." >&2; exit 1; }

returned_normal_trace="$(awk 'BEGIN{IGNORECASE=1} /^traceparent:/ {gsub("\r","",$2); print $2; exit}' "$normal_headers")"
if [[ "$returned_normal_trace" =~ ^00-([0-9a-fA-F]{32})- ]]; then
  normal_trace_id="${BASH_REMATCH[1],,}"
fi
returned_failure_trace="$(awk 'BEGIN{IGNORECASE=1} /^traceparent:/ {gsub("\r","",$2); print $2; exit}' "$failure_headers")"
if [[ "$returned_failure_trace" =~ ^00-([0-9a-fA-F]{32})- ]]; then
  failure_trace_id="${BASH_REMATCH[1],,}"
fi
correlation_ids_valid_and_distinct "$normal_trace_id" "$failure_trace_id" \
  || { echo "ERROR: normal and failure correlation IDs must be valid, lower-case, and distinct." >&2; exit 1; }

read -r -d '' query <<KQL || true
let StartTime = ago(15m);
let NormalTraceId = '$normal_trace_id';
let FailureTraceId = '$failure_trace_id';
let Marker = '$synthetic_marker';
let CommitSha = '$normalized_commit_sha';
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
KQL

query_uri="https://management.azure.com${normalized_workspace_resource_id}/query?api-version=2022-10-01"
run_telemetry_query() {
  query_result="$(az rest \
    --method post \
    --uri "$query_uri" \
    --body "$(jq -nc --arg query "$query" '{query:$query}')" \
    --headers "Content-Type=application/json" \
    --output json)"
}
poll_exit=0
poll_telemetry "$poll_timeout_seconds" "$poll_retry_seconds" run_telemetry_query wait_for_retry || poll_exit=$?
if (( poll_exit == 2 )); then
  echo "ERROR: the telemetry query failed during ingestion polling." >&2
  exit 1
fi
if (( poll_exit == 0 )); then
  stabilize_telemetry "$poll_timeout_seconds" "$poll_retry_seconds" run_telemetry_query wait_for_retry || poll_exit=$?
  if (( poll_exit == 2 )); then
    echo "ERROR: the telemetry query failed during ingestion stability checks." >&2
    exit 1
  fi
else
  telemetry_ingestion_stable=false
fi

row_count="$(jq '.tables[0].rows | length' <<<"$query_result")"
[[ "$row_count" -gt 0 ]] || { echo "ERROR: the telemetry query returned no summary row before the bounded ingestion timeout." >&2; exit 1; }
normal_request_count="$(jq -r '.tables[0].rows[0][0]' <<<"$query_result")"
normal_tool_count="$(jq -r '.tables[0].rows[0][1]' <<<"$query_result")"
normal_model_count="$(jq -r '.tables[0].rows[0][2]' <<<"$query_result")"
failure_request_count="$(jq -r '.tables[0].rows[0][3]' <<<"$query_result")"
expected_tool_failure_count="$(jq -r '.tables[0].rows[0][4]' <<<"$query_result")"
independent_model_result_count="$(jq -r '.tables[0].rows[0][5]' <<<"$query_result")"
normal_commit_match_count="$(jq -r '.tables[0].rows[0][6]' <<<"$query_result")"
failure_commit_match_count="$(jq -r '.tables[0].rows[0][7]' <<<"$query_result")"
commit_mismatch_count="$(jq -r '.tables[0].rows[0][8]' <<<"$query_result")"
marker_match_count="$(jq -r '.tables[0].rows[0][9]' <<<"$query_result")"
prohibited_property_count="$(jq -r '.tables[0].rows[0][10]' <<<"$query_result")"

normal_trace_complete=false
expected_tool_failure=false
independent_model_result=false
failure_separated=false
sensitive_input_present=false
release_commit_sha_verified=false
if (( normal_request_count > 0 && normal_tool_count > 0 && normal_model_count > 0 )); then normal_trace_complete=true; fi
if (( expected_tool_failure_count > 0 )); then expected_tool_failure=true; fi
if (( independent_model_result_count > 0 )); then independent_model_result=true; fi
if (( failure_request_count > 0 && expected_tool_failure_count > 0 && independent_model_result_count > 0 )); then failure_separated=true; fi
if (( normal_commit_match_count > 0 && failure_commit_match_count > 0 && commit_mismatch_count == 0 )); then release_commit_sha_verified=true; fi
if (( marker_match_count > 0 || prohibited_property_count > 0 )); then sensitive_input_present=true; fi

status="failed"
if [[ "$telemetry_poll_timed_out" == false && "$telemetry_ingestion_stable" == true && "$normal_trace_complete" == true && "$failure_separated" == true && "$release_commit_sha_verified" == true && "$sensitive_input_present" == false ]]; then
  status="passed"
fi

jq -n \
  --arg implementation_session "12-observability-cost-operations" \
  --arg mode "$mode" \
  --arg environment "$environment" \
  --arg commit_sha "$normalized_commit_sha" \
  --arg correlation_id "$normal_trace_id" \
  --arg normal_correlation_id "$normal_trace_id" \
  --arg failure_correlation_id "$failure_trace_id" \
  --arg observed_at "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  --arg status "$status" \
  --argjson normal_trace_complete "$normal_trace_complete" \
  --argjson expected_tool_failure "$expected_tool_failure" \
  --argjson independent_model_result "$independent_model_result" \
  --argjson failure_separated "$failure_separated" \
  --argjson release_commit_sha_verified "$release_commit_sha_verified" \
  --argjson telemetry_ingestion_stable "$telemetry_ingestion_stable" \
  --argjson sensitive_input_present "$sensitive_input_present" \
  --argjson telemetry_poll_timed_out "$telemetry_poll_timed_out" \
  --argjson telemetry_poll_attempts "$telemetry_poll_attempts" \
  --argjson telemetry_poll_timeout_seconds "$poll_timeout_seconds" \
  --argjson telemetry_poll_retry_seconds "$poll_retry_seconds" \
  '{
    schemaVersion: 1,
    implementationSession: $implementation_session,
    recordType: "session12-smoke-result",
    mode: $mode,
    environment: $environment,
    commitSha: (if $release_commit_sha_verified then $commit_sha else null end),
    correlationId: $correlation_id,
    normalCorrelationId: $normal_correlation_id,
    failureCorrelationId: $failure_correlation_id,
    observedAt: $observed_at,
    payloadsRetained: false,
    checks: {
      syntheticRequest: "passed",
      syntheticRequestSucceeded: true,
      endToEndTrace: (if $normal_trace_complete then "passed" else "failed" end),
      expectedToolFailure: $expected_tool_failure,
      independentModelResult: $independent_model_result,
      toolAndModelFailureSeparated: (if $failure_separated then "passed" else "failed" end),
      releaseCommitShaVerified: $release_commit_sha_verified,
      workspaceBindingVerified: true,
      correlationIdsDistinct: true,
      telemetryIngestionStable: $telemetry_ingestion_stable,
      sensitiveInputPresent: $sensitive_input_present,
      payloadsRetained: false,
      telemetryPollTimedOut: $telemetry_poll_timed_out,
      telemetryPollAttempts: $telemetry_poll_attempts,
      telemetryPollTimeoutSeconds: $telemetry_poll_timeout_seconds,
      telemetryPollRetrySeconds: $telemetry_poll_retry_seconds,
      privacySurfacesChecked: ["AppRequests", "AppDependencies", "AppEvents", "AppTraces", "AppExceptions"]
    },
    status: $status,
    implementationMarker: ("implementationSession=" + $implementation_session)
  }' > "$result_path"

[[ "$status" == "passed" ]] || { echo "ERROR: Session 12 smoke checks failed. Inspect the payload-free result at $result_path." >&2; exit 1; }
echo "PASS: Session 12 smoke checks passed."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
