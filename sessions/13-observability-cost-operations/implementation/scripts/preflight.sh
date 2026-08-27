#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-subscription-id <guid> --approved-resource-group-name <name> \
  --approved-application-insights-resource-id <resource-id> --deployment-location <azure-region>

Runs the Session 13 Bash preflight. The script validates required files, tools, sentinels, target
scope, telemetry and privacy implementation files, then compiles the Bicep templates and runs both
read-only deployment previews.

Required options:
  --approved-subscription-id <guid>                  Approved Azure subscription ID.
  --approved-resource-group-name <name>             Approved deployment resource group name.
  --approved-application-insights-resource-id <id>  Approved Application Insights resource ID.
  --deployment-location <azure-region>              Approved Azure deployment location.

Optional options:
  --help                                            Show this help text.

Do not pass secrets as arguments. Use the approved deployment environment and runtime coordinates
only.
USAGE
}

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "Required command is unavailable: $command_name"
  fi
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Required implementation artifact is missing: $path"
}

require_directory() {
  local path="$1"
  [[ -d "$path" ]] || fail "Required implementation artifacts folder is missing: $path"
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
temp_dir="$(mktemp -d)"
matches_file="$temp_dir/sentinel-matches.txt"
trap 'rm -rf "$temp_dir"' EXIT

approved_subscription_id=''
approved_resource_group_name=''
approved_application_insights_resource_id=''
deployment_location=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-subscription-id'
      approved_subscription_id="$2"
      shift 2
      ;;
    --approved-resource-group-name)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-resource-group-name'
      approved_resource_group_name="$2"
      shift 2
      ;;
    --approved-application-insights-resource-id)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-application-insights-resource-id'
      approved_application_insights_resource_id="$2"
      shift 2
      ;;
    --deployment-location)
      [[ $# -ge 2 ]] || fail 'Missing value for --deployment-location'
      deployment_location="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$approved_subscription_id" ]] || { usage >&2; fail 'The --approved-subscription-id option is required.'; }
[[ -n "$approved_resource_group_name" ]] || { usage >&2; fail 'The --approved-resource-group-name option is required.'; }
[[ -n "$approved_application_insights_resource_id" ]] || { usage >&2; fail 'The --approved-application-insights-resource-id option is required.'; }
[[ -n "$deployment_location" ]] || { usage >&2; fail 'The --deployment-location option is required.'; }
[[ "$approved_subscription_id" =~ ^[0-9a-fA-F-]{36}$ ]] || fail 'Approved subscription ID must be a GUID.'
[[ "$approved_application_insights_resource_id" == /subscriptions/* ]] || fail 'Approved Application Insights resource ID must be an Azure resource ID.'

require_directory "$artifact_root"
for path in \
  "$artifact_root/control-definition.json" \
  "$artifact_root/infra/main.bicep" \
  "$artifact_root/infra/main.bicepparam" \
  "$artifact_root/cost/budget.bicep" \
  "$artifact_root/cost/budget.bicepparam" \
  "$artifact_root/telemetry/telemetry-contract.json" \
  "$artifact_root/governance/data-retention-decision.md" \
  "$artifact_root/governance/prompt-response-logging-decision.md" \
  "$artifact_root/cost/cost-allocation.md" \
  "$artifact_root/monitoring/workbook.json" \
  "$artifact_root/operations/incident-runbook.md" \
  "$script_dir/smoke.ps1" \
  "$script_dir/smoke.sh" \
  "$script_dir/test-smoke-contract.py"; do
  require_file "$path"
done

for command_name in az jq python; do
  require_command "$command_name"
done

covered_decision_sentinels=(
  "__REQUIRED_ACTION_GROUP_RESOURCE_ID__"
  "__REQUIRED_AI_QUALITY_OWNER__"
  "__REQUIRED_APIM_POLICY_VERSION__"
  "__REQUIRED_APPLICATION_INSIGHTS_RESOURCE_ID__"
  "__REQUIRED_APPLICATION_TAG__"
  "__REQUIRED_BUDGET_END_DATE__"
  "__REQUIRED_BUDGET_NAME__"
  "__REQUIRED_BUDGET_START_DATE__"
  "__REQUIRED_COST_CENTER__"
  "__REQUIRED_COST_NOTIFICATION_EMAIL__"
  "__REQUIRED_COST_OWNER__"
  "__REQUIRED_DAILY_CAP_DECISION__"
  "__REQUIRED_DATA_CLASSIFICATION__"
  "__REQUIRED_DATA_PROTECTION_OWNER__"
  "__REQUIRED_DATA_RESIDENCY_STATUS_CONFIRMED__"
  "__REQUIRED_DATA_RETENTION_OWNER__"
  "__REQUIRED_DEPLOYMENT_LOCATION__"
  "__REQUIRED_EXCEPTION_PATH_STATUS_DISABLED_OR_APPROVED__"
  "__REQUIRED_GATEWAY_OWNER__"
  "__REQUIRED_GATEWAY_POLICY_SOURCE_PATH__"
  "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__"
  "__REQUIRED_MONTHLY_BUDGET_AMOUNT__"
  "__REQUIRED_OBSERVABILITY_OWNER__"
  "__REQUIRED_PRIVATE_ACCESS_STATUS_YES__"
  "__REQUIRED_QUALITY_FAILURE_COUNT__"
  "__REQUIRED_REQUEST_ERROR_RATE_PERCENT__"
  "__REQUIRED_RESOURCE_GROUP_RESOURCE_ID__"
  "__REQUIRED_RETENTION_DAYS__"
  "__REQUIRED_REVIEW_DATE__"
  "__REQUIRED_SAMPLING_STRATEGY_FIXED_OR_RATE_LIMITED__"
  "__REQUIRED_SAMPLING_VALUE__"
  "__REQUIRED_SERVICE_NAME__"
  "__REQUIRED_SERVICE_OWNER__"
  "__REQUIRED_SOC_OWNER__"
  "__REQUIRED_SUBSCRIPTION_RESOURCE_ID__"
  "__REQUIRED_TOOL_FAILURE_COUNT__"
  "__REQUIRED_TOOL_OWNER__"
  "__REQUIRED_TRACE_BASED_LOG_SAMPLING_DECISION__"
  "__REQUIRED_WORKBOOK_DISPLAY_NAME__"
)
declare -A covered=()
for sentinel in "${covered_decision_sentinels[@]}"; do
  covered["$sentinel"]=1
done

unresolved_locations=()
unknown_sentinels=()
if grep -RnoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" >"$matches_file"; then
  while IFS=: read -r match_path match_line match_value; do
    if [[ -z "${covered[$match_value]+x}" ]]; then
      unknown_sentinels+=("$match_value")
    fi
    relative_path="${match_path#"$repo_root"/}"
    unresolved_locations+=("$match_value at $relative_path:$match_line")
  done <"$matches_file"
fi

if (( ${#unknown_sentinels[@]} > 0 )); then
  printf 'Preflight has no named coverage for:\n%s\n' "$(printf '%s\n' "${unknown_sentinels[@]}" | sort -u)" >&2
  exit 1
fi

if (( ${#unresolved_locations[@]} > 0 )); then
  printf 'Resolve every required customer decision before deployment:\n%s\n' "$(printf '%s\n' "${unresolved_locations[@]}")" >&2
  exit 1
fi

python - "$artifact_root" "$repo_root" "$approved_subscription_id" "$approved_resource_group_name" "$approved_application_insights_resource_id" "$deployment_location" <<'PY'
import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

artifact_root = Path(sys.argv[1])
repo_root = Path(sys.argv[2]).resolve()
approved_subscription_id = sys.argv[3]
approved_resource_group_name = sys.argv[4]
approved_application_insights_resource_id = sys.argv[5]
deployment_location = sys.argv[6]

control = json.loads((artifact_root / 'control-definition.json').read_text())
telemetry = json.loads((artifact_root / 'telemetry' / 'telemetry-contract.json').read_text())
retention_text = (artifact_root / 'governance' / 'data-retention-decision.md').read_text()
content_logging_text = (artifact_root / 'governance' / 'prompt-response-logging-decision.md').read_text()
policy_path = (repo_root / control['gatewayPolicy']['customerOwnedSourcePath']).resolve()

def markdown_lines(markdown: str, filename: str) -> list[str]:
    visible = []
    in_comment = False
    fence_character = None
    fence_length = 0
    html_tag_pattern = re.compile(
        r'<(?:/?[A-Za-z][A-Za-z0-9:_-]*(?:\s+[^<>]*?)?\s*/?|![A-Za-z][^<>]*|\?[A-Za-z][^<>]*)>'
    )
    for raw_line in markdown.splitlines():
        if fence_character is not None:
            closing = re.fullmatch(r'\s{0,3}(`{3,}|~{3,})\s*', raw_line)
            if (
                closing
                and closing.group(1)[0] == fence_character
                and len(closing.group(1)) >= fence_length
            ):
                fence_character = None
            continue

        line = ''
        remaining = raw_line
        while remaining:
            if in_comment:
                comment_end = remaining.find('-->')
                if comment_end < 0:
                    remaining = ''
                    continue
                in_comment = False
                remaining = remaining[comment_end + 3:]
                continue
            comment_start = remaining.find('<!--')
            if comment_start < 0:
                line += remaining
                remaining = ''
                continue
            line += remaining[:comment_start]
            remaining = remaining[comment_start + 4:]
            in_comment = True

        opening = re.match(r'^\s{0,3}(`{3,}|~{3,}).*$', line)
        if opening:
            marker = opening.group(1)
            fence_character = marker[0]
            fence_length = len(marker)
            continue
        if html_tag_pattern.search(line):
            raise SystemExit(f'{filename} contains raw HTML outside fenced code.')
        visible.append(line)

    if fence_character is not None:
        raise SystemExit(f'{filename} contains an unclosed fenced code block.')
    if html_tag_pattern.search('\n'.join(visible)):
        raise SystemExit(f'{filename} contains raw HTML outside fenced code.')
    return visible

def markdown_section(lines: list[str], heading: str, filename: str) -> list[str]:
    indexes = [index for index, line in enumerate(lines) if line.strip() == heading]
    if not indexes:
        raise SystemExit(f"{filename} is missing heading '{heading}'.")
    if len(indexes) > 1:
        raise SystemExit(f"{filename} contains duplicate heading '{heading}'.")
    start = indexes[0] + 1
    end = next(
        (
            index
            for index in range(start, len(lines))
            if re.match(r'^#{1,6}\s+', lines[index].strip())
        ),
        len(lines),
    )
    return lines[start:end]

def markdown_field(markdown: str, name: str, filename: str, heading: str) -> str:
    lines = markdown_lines(markdown, filename)
    section = markdown_section(lines, heading, filename)
    header = re.compile(r'^\|\s*Field\s*\|\s*Decision\s*\|\s*$')
    separator = re.compile(r'^\|\s*:?-{3,}:?\s*\|\s*:?-{3,}:?\s*\|\s*$')
    pattern = re.compile(rf'^\|\s*{re.escape(name)}\s*\|\s*(.*?)\s*\|\s*$', re.MULTILINE)
    matches = []
    for index in range(len(section) - 1):
        if not header.fullmatch(section[index]) or not separator.fullmatch(section[index + 1]):
            continue
        for row in section[index + 2:]:
            if not re.fullmatch(r'\|.*\|\s*', row):
                break
            if match := pattern.fullmatch(row):
                matches.append(match.group(1).strip())
    if not matches:
        raise SystemExit(f"{filename} is missing field '{name}'.")
    if len(matches) > 1:
        raise SystemExit(f"{filename} contains duplicate field '{name}'.")
    value = matches[0]
    if len(value) >= 2 and value[0] == value[-1] == '`':
        value = value[1:-1].strip()
    if not value:
        raise SystemExit(f"{filename} field '{name}' is empty.")
    return value

try:
    policy_path.relative_to(repo_root)
except ValueError:
    raise SystemExit('The customer-owned gateway policy source resolves outside the repository.')
if policy_path.suffix.lower() != '.xml' or not policy_path.is_file():
    raise SystemExit('The customer-owned gateway policy source must be one repository-relative XML file.')
policy = ET.fromstring(policy_path.read_text())
if not control['gatewayPolicy']['correlationAndTokenMetricsMerged']:
    raise SystemExit('The gateway owner must confirm the correlation and token-metric merge.')
if not policy.findall(".//set-header[@name='x-correlation-id']") or not policy.findall('.//llm-emit-token-metric'):
    raise SystemExit('The customer-owned APIM policy must contain x-correlation-id handling and llm-emit-token-metric.')
dimensions = policy.findall('.//llm-emit-token-metric/dimension')
custom_dimensions = [item for item in dimensions if item.get('value') is not None]
if len(custom_dimensions) > 5:
    raise SystemExit('The customer-owned APIM token metric exceeds five custom dimensions.')
if {'User ID', 'Subscription ID'} & {item.get('name') for item in dimensions}:
    raise SystemExit('User- or subscription-level APIM token dimensions are outside this control.')

expected_scope = f'/subscriptions/{approved_subscription_id}/resourceGroups/{approved_resource_group_name}'
if control['targetScope'] != expected_scope:
    raise SystemExit('The control definition does not match the approved resource-group scope.')
if control['monitoredApplicationInsightsResourceId'] != approved_application_insights_resource_id:
    raise SystemExit('The control definition does not name the approved Application Insights resource.')
if control['costScope'] != f'/subscriptions/{approved_subscription_id}':
    raise SystemExit('The cost scope must be the approved subscription resource ID.')
if control['environment'] != 'nonproduction':
    raise SystemExit('This session is limited to the approved nonproduction service.')
smoke = control.get('confirmation', {}).get('smokeExecutable', {})
if control.get('schemaVersion') != 2:
    raise SystemExit('The control definition must use smoke contract schemaVersion 2.')
if set(smoke.get('runtimeEnvironment', [])) != {
    'SESSION13_SMOKE_URL',
    'SESSION13_SMOKE_FAILURE_URL',
    'SESSION13_AI_RESOURCE_ID',
    'SESSION13_LOG_ANALYTICS_WORKSPACE_ID',
    'SESSION13_SMOKE_BEARER_TOKEN',
}:
    raise SystemExit('The Session 13 smoke runtime environment contract has changed.')
polling = smoke.get('ingestionPolling', {})
if polling != {
    'timeoutEnvironment': 'SESSION13_SMOKE_TIMEOUT_SECONDS',
    'defaultTimeoutSeconds': 180,
    'minimumTimeoutSeconds': 30,
    'maximumTimeoutSeconds': 600,
    'retryEnvironment': 'SESSION13_SMOKE_RETRY_SECONDS',
    'defaultRetrySeconds': 15,
    'minimumRetrySeconds': 5,
    'maximumRetrySeconds': 60,
    'minimumTimeoutRetryMultiplier': 2,
    'attemptCountSemantics': 'all telemetry queries across readiness and stability, including the initial and final queries',
    'minimumPassingAttempts': 3,
    'maximumAttemptsFormula': '1 + ceiling(timeoutSeconds / retrySeconds)',
    'correlationIds': ['normal', 'expectedToolFailure'],
    'timeoutIncludesStabilityChecks': True,
    'watermark': 'maximum TimeGenerated across both correlated telemetry sets',
    'requiredIdenticalSnapshots': 3,
    'finalQueryRequired': True,
}:
    raise SystemExit('The bounded ingestion-polling contract has changed.')
if smoke.get('correlationContract') != {
    'format': '32 lower-case hexadecimal characters',
    'normalAndFailureMustBeDistinct': True,
    'resultFields': ['normalCorrelationId', 'failureCorrelationId'],
}:
    raise SystemExit('The smoke correlation-ID contract has changed.')
if smoke.get('requestBodies', {}).get('normal', {}).get('syntheticMarker') != smoke.get('requestBodies', {}).get('expectedToolFailure', {}).get('syntheticMarker'):
    raise SystemExit('Both smoke requests must use the same fixed synthetic marker.')
if any(
    smoke.get('requestBodies', {}).get(name, {}).get('releaseCommitSha') != 'exact lower-case CommitSha CLI value'
    for name in ('normal', 'expectedToolFailure')
):
    raise SystemExit('Both smoke requests must bind the exact release commit SHA.')
if smoke.get('authentication') != {
    'scheme': 'Bearer',
    'tokenEnvironment': 'SESSION13_SMOKE_BEARER_TOKEN',
    'powershellTransport': 'in-memory request header',
    'bashTransport': 'curl configuration over standard input',
    'tokenWrittenToDisk': False,
}:
    raise SystemExit('The smoke authentication transport contract has changed.')
if smoke.get('releaseCommitBinding') != {
    'requestHeader': 'x-release-commit-sha',
    'requestBodyField': 'releaseCommitSha',
    'telemetryProperty': 'release.commit.sha',
    'requiredForCorrelations': ['normal', 'expectedToolFailure'],
    'copyToResultOnlyAfterTelemetryMatch': True,
}:
    raise SystemExit('The release commit telemetry-binding contract has changed.')
if smoke.get('workspaceBinding') != {
    'componentResourceEnvironment': 'SESSION13_AI_RESOURCE_ID',
    'componentProperty': 'WorkspaceResourceId',
    'workspaceResourceEnvironment': 'SESSION13_LOG_ANALYTICS_WORKSPACE_ID',
    'resourceIdComparison': 'case-insensitive',
    'requiredBeforeQuery': True,
}:
    raise SystemExit('The Application Insights workspace-binding contract has changed.')
if set(smoke.get('privacySurfaces', [])) != {'AppRequests', 'AppDependencies', 'AppEvents', 'AppTraces', 'AppExceptions'}:
    raise SystemExit('The smoke privacy check must cover all five required telemetry surfaces.')
if smoke.get('prohibitedPropertySource') != 'implementation/artifacts/telemetry/telemetry-contract.json prohibitedAttributes':
    raise SystemExit('The smoke privacy check must use telemetry-contract.json prohibitedAttributes.')
required_checks = smoke.get('requiredChecks', {})
if set(required_checks) != {
    'syntheticRequest',
    'endToEndTrace',
    'expectedToolFailure',
    'independentModelResult',
    'toolAndModelFailureSeparated',
    'releaseCommitShaVerified',
    'workspaceBindingVerified',
    'correlationIdsDistinct',
    'telemetryIngestionStable',
    'sensitiveInputPresent',
    'payloadsRetained',
    'telemetryPollTimedOut',
}:
    raise SystemExit('The Session 13 smoke result-check fields have changed.')
if any(required_checks.get(name) != 'passed' for name in ('syntheticRequest', 'endToEndTrace', 'toolAndModelFailureSeparated')):
    raise SystemExit('The smoke contract is missing a required passed result check.')
if any(required_checks.get(name) is not True for name in ('expectedToolFailure', 'independentModelResult')):
    raise SystemExit('The smoke contract must require explicit tool-failure and model-result checks.')
if any(required_checks.get(name) is not True for name in ('releaseCommitShaVerified', 'workspaceBindingVerified', 'correlationIdsDistinct', 'telemetryIngestionStable')):
    raise SystemExit('The smoke contract must require commit, workspace, correlation, and ingestion-stability checks.')
if any(required_checks.get(name) is not False for name in ('sensitiveInputPresent', 'payloadsRetained', 'telemetryPollTimedOut')):
    raise SystemExit('The smoke contract must reject sensitive input, stored payloads, and telemetry polling timeouts.')
if telemetry['propagation']['standard'] != 'W3C Trace Context':
    raise SystemExit('The telemetry contract must include W3C Trace Context.')
for attribute in ('gen_ai.prompt', 'gen_ai.completion', 'ai.input.content', 'ai.output.content', 'tool.input', 'tool.output', 'http.request.header.authorization', 'http.request.header.cookie', 'url.query', 'enduser.id', 'user.email'):
    if attribute not in telemetry['prohibitedAttributes']:
        raise SystemExit(f"Telemetry contract must prohibit '{attribute}'.")
if 'release.commit.sha' not in telemetry['requiredAttributes']:
    raise SystemExit('The telemetry contract must bind smoke records to release.commit.sha.')
if telemetry.get('releaseCommitBinding') != {
    'requestHeader': 'x-release-commit-sha',
    'requestBodyField': 'releaseCommitSha',
    'telemetryProperty': 'release.commit.sha',
    'requiredOnRequestSpans': ['normal', 'expected-tool-failure'],
    'valueType': 'lower-case hexadecimal commit SHA',
    'containsSensitiveData': False,
}:
    raise SystemExit('The telemetry release-commit binding has changed.')
if len(telemetry.get('cardinality', {}).get('approvedDimensions', [])) > 5:
    raise SystemExit('APIM token telemetry is limited to five approved low-cardinality dimensions.')
if telemetry.get('cardinality', {}).get('userLevelDimensionAllowed') is not False or telemetry.get('cardinality', {}).get('freeTextDimensionAllowed') is not False:
    raise SystemExit('User-level and free-text telemetry dimensions are prohibited.')

retention_filename = 'data-retention-decision.md'
retention_resource_id = markdown_field(
    retention_text,
    'Application Insights resource ID',
    retention_filename,
    '# Data retention decision',
)
if retention_resource_id.casefold() != approved_application_insights_resource_id.casefold():
    raise SystemExit('The retention decision does not target the approved Application Insights resource.')
retention_days_text = markdown_field(
    retention_text, 'Retention days', retention_filename, '# Data retention decision'
)
if not re.fullmatch(r'\d+', retention_days_text) or not 30 <= int(retention_days_text) <= 730:
    raise SystemExit('Retention days must be an approved integer from 30 through 730.')
if markdown_field(
    retention_text, 'Data residency status', retention_filename, '# Data retention decision'
) != 'Confirmed':
    raise SystemExit('The data residency status must be Confirmed.')
if markdown_field(
    retention_text,
    'Private-access boundary status',
    retention_filename,
    '# Data retention decision',
) != 'Yes':
    raise SystemExit('The private-access boundary status must be Yes.')

logging_filename = 'prompt-response-logging-decision.md'
logging_defaults = {
    'Standard content logging': 'Disabled',
    'Prompts logged by default': 'No',
    'Responses logged by default': 'No',
    'Tool payloads logged by default': 'No',
    'Query strings logged by default': 'No',
    'Authorization headers logged by default': 'No',
}
for name, expected in logging_defaults.items():
    actual = markdown_field(
        content_logging_text, name, logging_filename, '## Standard telemetry'
    )
    if actual != expected:
        raise SystemExit(f"{logging_filename} field '{name}' must be '{expected}'.")
exception_status = markdown_field(
    content_logging_text, 'Status', logging_filename, '## Exception path'
)
if exception_status not in {'Disabled', 'Approved'}:
    raise SystemExit('The content-logging exception status must be Disabled or Approved.')
exception_details = [
    markdown_field(content_logging_text, name, logging_filename, '## Exception path')
    for name in ('Purpose', 'Approved scope', 'Access owner', 'Retention days', 'Expiry date')
]
if exception_status == 'Disabled' and any(value != 'N/A' for value in exception_details):
    raise SystemExit('A Disabled content-logging exception must use N/A for every exception detail.')
if exception_status == 'Approved' and any(value == 'N/A' for value in exception_details):
    raise SystemExit(
        'An Approved content-logging exception requires explicit purpose, scope, owner, retention, and expiry values.'
    )

def read_bicepparam_value(path: Path, name: str) -> str:
    match = re.search(rf"(?m)^\s*param\s+{re.escape(name)}\s*=\s*'([^']+)'\s*$", path.read_text())
    if not match:
        raise SystemExit(f"Could not read string parameter '{name}' from {path}.")
    return match.group(1)

main_parameters = artifact_root / 'infra' / 'main.bicepparam'
budget_parameters = artifact_root / 'cost' / 'budget.bicepparam'
if read_bicepparam_value(main_parameters, 'applicationInsightsResourceId') != approved_application_insights_resource_id:
    raise SystemExit('main.bicepparam does not target the approved Application Insights resource.')
if read_bicepparam_value(main_parameters, 'location') != deployment_location:
    raise SystemExit('Deployment location differs from main.bicepparam.')
amount = float(read_bicepparam_value(budget_parameters, 'amount'))
if amount <= 0:
    raise SystemExit('Budget amount must be a positive number.')
PY

current_subscription_id="$(az account show --query id -o tsv)"
[[ "$current_subscription_id" == "$approved_subscription_id" ]] || fail "Azure CLI is not set to approved subscription '$approved_subscription_id'."
app_insights_json="$(az resource show --ids "$approved_application_insights_resource_id" --api-version 2020-02-02 -o json)"
app_insights_type="$(jq -r '.type // empty' <<<"$app_insights_json")"
[[ "${app_insights_type,,}" == 'microsoft.insights/components' ]] || fail 'The approved Application Insights resource could not be resolved.'
app_insights_workspace_id="$(jq -r '.properties.WorkspaceResourceId // .properties.workspaceResourceId // empty' <<<"$app_insights_json")"
[[ "${app_insights_workspace_id,,}" =~ ^/subscriptions/[^/]+/resourcegroups/[^/]+/providers/microsoft\.operationalinsights/workspaces/[^/]+$ ]] \
  || fail 'The approved Application Insights component must expose a valid WorkspaceResourceId.'
if [[ -n "${SESSION13_LOG_ANALYTICS_WORKSPACE_ID:-}" ]]; then
  live_workspace_id="${app_insights_workspace_id%/}"
  runtime_workspace_id="${SESSION13_LOG_ANALYTICS_WORKSPACE_ID%/}"
  [[ "${live_workspace_id,,}" == "${runtime_workspace_id,,}" ]] \
    || fail 'The live Application Insights WorkspaceResourceId does not match SESSION13_LOG_ANALYTICS_WORKSPACE_ID.'
fi
action_group_resource_id="$(python - "$artifact_root/cost/../infra/main.bicepparam" <<'PY'
import re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text()
match = re.search(r"(?m)^\s*param\s+actionGroupResourceId\s*=\s*'([^']+)'\s*$", text)
if not match:
    raise SystemExit(1)
print(match.group(1))
PY
)"
action_group_type="$(az resource show --ids "$action_group_resource_id" --query type -o tsv)"
[[ "$action_group_type" == 'microsoft.insights/actiongroups' ]] || fail 'The approved Azure Monitor action group could not be resolved.'

az bicep version >/dev/null
az monitor app-insights query --help >/dev/null
az bicep build --file "$artifact_root/infra/main.bicep" --stdout >/dev/null
az bicep build --file "$artifact_root/cost/budget.bicep" --stdout >/dev/null

printf 'Preview 1 of 2: workbook and alert rules in /subscriptions/%s/resourceGroups/%s\n' "$approved_subscription_id" "$approved_resource_group_name"
az deployment group what-if \
  --subscription "$approved_subscription_id" \
  --resource-group "$approved_resource_group_name" \
  --template-file "$artifact_root/infra/main.bicep" \
  --parameters "$artifact_root/infra/main.bicepparam" \
  --no-pretty-print

printf 'Preview 2 of 2: budget in /subscriptions/%s\n' "$approved_subscription_id"
az deployment sub what-if \
  --subscription "$approved_subscription_id" \
  --location "$deployment_location" \
  --template-file "$artifact_root/cost/budget.bicep" \
  --parameters "$artifact_root/cost/budget.bicepparam" \
  --no-pretty-print

printf 'PASS: Markdown retention and content-logging decisions, telemetry privacy gates, scope, resources, Bicep compilation, and both previews are ready.\n'
