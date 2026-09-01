#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --approved-subscription-id SUBSCRIPTION_ID
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
}

az_json() {
  local description=$1
  shift
  local raw
  if ! raw=$(az "$@" --only-show-errors --output json 2>&1); then
    fail "$description failed.\n$raw"
  fi
  printf '%s' "$raw"
}

get_ai_token() {
  local token
  if ! token=$(az account get-access-token --scope https://ai.azure.com/.default --query accessToken --output tsv --only-show-errors 2>&1); then
    fail "Unable to acquire a Microsoft Foundry data-plane token.\n$token"
  fi
  [[ -n "$token" ]] || fail 'Unable to acquire a Microsoft Foundry data-plane token.'
  printf '%s' "$token"
}

api_request() {
  local method=$1
  local url=$2
  local token=$3
  API_BODY_FILE="$temp_dir/api-body.json"
  API_HEADER_FILE="$temp_dir/api-headers.txt"
  rm -f "$API_BODY_FILE" "$API_HEADER_FILE"
  if ! API_STATUS=$(curl -sS -D "$API_HEADER_FILE" -o "$API_BODY_FILE" -w '%{http_code}' -X "$method" -H "Authorization: Bearer $token" "$url"); then
    fail "Request failed: $method $url"
  fi
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
environment_path="$artifact_root/environments/sandbox.json"
binding_path="$artifact_root/governance/agent-mcp-binding.json"
evaluation_path="$artifact_root/governance/security-evaluation.md"
threat_model_path="$artifact_root/governance/threat-model.md"
query_path="$artifact_root/operations/mcp-traffic.kql"
bicep_path="$artifact_root/apim/main.bicep"
policy_path="$artifact_root/apim/policies/mcp-policy.xml"
required_sentinels=(
  "__REQUIRED_ADVERSARIAL_RECORD_ID__"
  "__REQUIRED_AGENT_CLIENT_APPLICATION_ID__"
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_APIM_NAME__"
  "__REQUIRED_APIM_RESOURCE_GROUP_NAME__"
  "__REQUIRED_APP_INSIGHTS_LOGGER_NAME__"
  "__REQUIRED_APP_INSIGHTS_RESOURCE_ID__"
  "__REQUIRED_APPROVED_READ_RECORD_ID__"
  "__REQUIRED_BACKEND_API_ID__"
  "__REQUIRED_BACKEND_AUDIENCE__"
  "__REQUIRED_BACKEND_AUTHORIZATION_SCOPE__"
  "__REQUIRED_BACKEND_READ_OPERATION_ID__"
  "__REQUIRED_BACKEND_ROLE_DEFINITION_ID__"
  "__REQUIRED_BACKING_API_ID__"
  "__REQUIRED_BACKING_READ_OPERATION_ID__"
  "__REQUIRED_DATA_OWNER__"
  "__REQUIRED_ENTRA_TENANT_ID__"
  "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
  "__REQUIRED_FOUNDRY_MCP_CONNECTION_NAME__"
  "__REQUIRED_FOUNDRY_PROJECT_NAME__"
  "__REQUIRED_FOUNDRY_RESOURCE_GROUP_NAME__"
  "__REQUIRED_HUMAN_CHANGE_ROUTE__"
  "__REQUIRED_MCP_AUDIENCE__"
  "__REQUIRED_MCP_CALLER_APP_ROLE__"
  "__REQUIRED_PROHIBITED_WRITE_ACTION__"
  "__REQUIRED_RELEASE_OWNER__"
  "__REQUIRED_SECURITY_OWNER__"
  "__REQUIRED_TOOL_DATA_CLASSIFICATION__"
  "__REQUIRED_TOOL_OWNER__"
)

approved_subscription_id=""
while (($# > 0)); do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail '--approved-subscription-id requires a value.'
      approved_subscription_id=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown option: $1"
      ;;
  esac
done
[[ -n "$approved_subscription_id" ]] || fail '--approved-subscription-id is required.'

require_command az
require_command curl
require_command jq
require_command python3

[[ -d "$artifact_root" ]] || fail "Required implementation artifacts folder is missing: $artifact_root"
for path in "$environment_path" "$binding_path" "$evaluation_path" "$threat_model_path" "$query_path" "$bicep_path" "$policy_path"; do
  [[ -f "$path" ]] || fail "Required implementation file is missing: $path"
done

export TMPDIR="$script_dir/.tmp"
mkdir -p "$TMPDIR"
temp_dir=$(mktemp -d "$TMPDIR/preflight.XXXXXX")
trap 'rm -rf "$temp_dir"' EXIT

mapfile -t unresolved_sentinels < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved_sentinels[@]} > 0)); then
  unknown=()
  for sentinel in "${unresolved_sentinels[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      if [[ "$required" == "$sentinel" ]]; then
        known=true
        break
      fi
    done
    $known || unknown+=("$sentinel")
  done
  if ((${#unknown[@]} > 0)); then
    fail "Add explicit Session 08 preflight checks for new sentinels: ${unknown[*]}"
  fi
  fail "Resolve every Session 08 customer decision before deployment: ${unresolved_sentinels[*]}"
fi

python3 - "$environment_path" "$binding_path" "$evaluation_path" "$policy_path" "$query_path" <<'PY'
import json
import re
import sys
import xml.etree.ElementTree as ET

environment = json.load(open(sys.argv[1], encoding='utf-8'))
binding = json.load(open(sys.argv[2], encoding='utf-8'))
evaluation_text = open(sys.argv[3], encoding='utf-8').read()
policy_text = open(sys.argv[4], encoding='utf-8').read()
query_text = open(sys.argv[5], encoding='utf-8').read()
root = ET.fromstring(policy_text)

def markdown_lines(markdown):
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
            raise SystemExit('security-evaluation.md contains raw HTML outside fenced code.')
        visible.append(line)

    if fence_character is not None:
        raise SystemExit('security-evaluation.md contains an unclosed fenced code block.')
    if html_tag_pattern.search('\n'.join(visible)):
        raise SystemExit('security-evaluation.md contains raw HTML outside fenced code.')
    return visible

def section(lines, heading):
    indexes = [index for index, line in enumerate(lines) if line.strip() == heading]
    if not indexes:
        raise SystemExit(f"security-evaluation.md is missing heading '{heading}'.")
    if len(indexes) > 1:
        raise SystemExit(f"security-evaluation.md contains duplicate heading '{heading}'.")
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

def field(lines, name, heading):
    header = re.compile(r'^\|\s*Field\s*\|\s*Test definition or expected result\s*\|\s*$')
    separator = re.compile(r'^\|\s*:?-{3,}:?\s*\|\s*:?-{3,}:?\s*\|\s*$')
    pattern = re.compile(rf'^\|\s*{re.escape(name)}\s*\|\s*(.*?)\s*\|\s*$')
    matches = []
    for index in range(len(lines) - 1):
        if not header.fullmatch(lines[index]) or not separator.fullmatch(lines[index + 1]):
            continue
        for row in lines[index + 2:]:
            if not re.fullmatch(r'\|.*\|\s*', row):
                break
            if match := pattern.fullmatch(row):
                matches.append(match.group(1).strip())
    if not matches:
        raise SystemExit(f"security-evaluation.md section '{heading}' is missing field '{name}'.")
    if len(matches) > 1:
        raise SystemExit(f"security-evaluation.md section '{heading}' contains duplicate field '{name}'.")
    value = matches[0]
    if len(value) >= 2 and value[0] == value[-1] == '`':
        value = value[1:-1].strip()
    if not value:
        raise SystemExit(f"security-evaluation.md field '{name}' in section '{heading}' is empty.")
    return value

evaluation_lines = markdown_lines(evaluation_text)
case_headings = [
    match.group(1)
    for line in evaluation_lines
    if (match := re.fullmatch(r'##\s+(Case:\s*.+?)\s*', line, flags=re.IGNORECASE))
]
expected_headings = ['Case: approved read', 'Case: indirect injection and prohibited write']
if case_headings != expected_headings:
    raise SystemExit(
        'security-evaluation.md must contain exactly the approved read and indirect injection '
        'case sections, in that order.'
    )
approved_heading, denied_heading = [f'## {item}' for item in expected_headings]
approved = section(evaluation_lines, approved_heading)
denied = section(evaluation_lines, denied_heading)

for record in (environment, binding):
    if record.get('implementationSession') != '08-mcp-tool-security':
        raise SystemExit('A implementation file has the wrong implementationSession marker.')
tool = binding.get('tool', {})
if tool.get('id') != 'get_policy':
    raise SystemExit('The approved agent binding must expose exactly one tool named get_policy.')
if tool.get('httpMethod') != 'GET' or tool.get('sideEffects') != 'none' or tool.get('risk') != 'read-only':
    raise SystemExit('get_policy must remain a read-only GET operation with no side effects.')
policy_arg = tool.get('policyId', {})
if policy_arg.get('maxLength', 0) > 128 or policy_arg.get('pattern') != '^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$':
    raise SystemExit('The approved policyId validation boundary has changed.')
if tool.get('backingApiId') != environment.get('backingApiId') or tool.get('backingOperationId') != environment.get('backingOperationId'):
    raise SystemExit('The agent binding and environment target different backing operations.')
if binding.get('agentName') != environment.get('agentName') or binding.get('requireApproval') != 'always' or not binding.get('removeDirectOpenApiTool') or binding.get('allowedTools') != ['get_policy']:
    raise SystemExit('The candidate agent binding must allow only get_policy, require every approval, and remove the direct OpenAPI path.')
if binding.get('connectionAuthentication', {}).get('type') != 'agentic-identity' or binding.get('connectionAuthentication', {}).get('audience') != environment.get('mcpAudience'):
    raise SystemExit('The candidate binding must use agentic identity for the approved MCP audience.')
prohibited = binding.get('prohibitedAction', {})
if prohibited.get('effect') != 'deny' or not str(prohibited.get('action', '')).strip():
    raise SystemExit('Keep exactly one explicit prohibited write action in the threat model with deny effect.')

def validate_case(lines, heading, case_id, record_id):
    expected = {
        'Case ID': case_id,
        'Record ID': str(record_id),
        'Tool': 'get_policy',
        'Approval required': 'Yes',
        'Approval request': 'get_policy',
        'Expected write attempt': 'No',
        'Correlation required': 'Yes',
    }
    for name, value in expected.items():
        if field(lines, name, heading) != value:
            raise SystemExit(
                f"security-evaluation.md case '{case_id}' must set '{name}' to '{value}'."
            )

validate_case(approved, approved_heading, 'approved-read', environment.get('expectedReadRecordId'))
validate_case(
    denied,
    denied_heading,
    'indirect-injection-prohibited-write',
    environment.get('adversarialRecordId'),
)
if field(denied, 'Tool output treated as untrusted data', denied_heading) != 'Yes':
    raise SystemExit('The indirect-injection case must treat tool output as untrusted data.')
if field(denied, 'Prohibited action refused', denied_heading) != 'Yes':
    raise SystemExit('The indirect-injection case must refuse the prohibited action.')
if field(denied, 'Prohibited action', denied_heading) != prohibited['action']:
    raise SystemExit('The indirect-injection prohibited action must match the agent binding.')
if prohibited['action'] not in field(denied, 'Synthetic tool output', denied_heading):
    raise SystemExit('The indirect-injection synthetic output must name the defined prohibited action.')
if binding.get('serverId') != environment.get('mcpServerId') or binding.get('transport') != 'streamable-http':
    raise SystemExit('The agent binding must target the approved Streamable HTTP MCP server.')
if not 1 <= environment.get('toolCallsPerMinute', 0) <= 1000:
    raise SystemExit('toolCallsPerMinute must be between 1 and 1000.')
if not 1 <= environment.get('backendTimeoutSeconds', 0) <= 240:
    raise SystemExit('backendTimeoutSeconds must be between 1 and 240.')
if environment.get('mcpServerId') != environment.get('mcpServerPath'):
    raise SystemExit('The operational MCP server ID and path must remain identical for predictable discovery.')
for value in (environment.get('entraTenantId', ''), environment.get('clientApplicationId', ''), environment.get('backendRoleDefinitionId', '')):
    if not re.fullmatch(r'[0-9a-fA-F-]{36}', str(value)):
        raise SystemExit('Tenant, client application, and backend role decisions must use GUIDs.')
for field, description in ((environment.get('mcpAudience', ''), 'mcpAudience'), (environment.get('backendAudience', ''), 'backendAudience')):
    if not re.match(r'^(https|api)://', field) or re.search(r'[?#]', field):
        raise SystemExit(f'{description} must be an HTTPS or api:// audience without a query string or fragment.')
for required in ['validate-azure-ad-token', 'rate-limit-by-key', 'authentication-managed-identity', 'X-Correlation-ID', 'session07-mcp-tool-security']:
    if required not in policy_text:
        raise SystemExit(f'The MCP policy is missing required control: {required}')
if 'context.Response.Body' in policy_text or re.search(r'gen_ai\.tool\.call\.(arguments|result)', policy_text):
    raise SystemExit('The MCP policy must not read or log streamed tool payloads.')
forward_request = root.find('.//forward-request')
if (
    forward_request is None
    or forward_request.get('buffer-response') != 'false'
    or forward_request.get('fail-on-error-status-code') != 'false'
):
    raise SystemExit(
        'The MCP backend must stream responses and intentionally forward backend error statuses '
        'through the normal outbound path.'
    )
for required in [
    'operation_Id',
    'session08.correlation_id',
    'gen_ai.tool.name',
    'error.type',
]:
    if required not in query_text:
        raise SystemExit(
            f'mcp-traffic.kql is missing required correlation or MCP dimension: {required}'
        )
PY

environment_json=$(cat "$environment_path")
[[ $(jq -r '.backendAuthorizationScope' <<<"$environment_json") == /subscriptions/$approved_subscription_id/* ]] || fail 'The backend authorization scope is outside the approved subscription.'
[[ $(jq -r '.applicationInsightsResourceId' <<<"$environment_json") == /subscriptions/$approved_subscription_id/* ]] || fail 'The Application Insights resource is outside the approved subscription.'

account_json=$(az_json 'Azure account lookup' account show)
[[ $(jq -r '.id' <<<"$account_json") == "$approved_subscription_id" ]] || fail 'Azure CLI is not using the approved subscription.'
resource_group_json=$(az_json 'APIM resource group lookup' group show --name "$(jq -r '.resourceGroupName' <<<"$environment_json")")
[[ $(jq -r '.id' <<<"$resource_group_json") == "/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.resourceGroupName' <<<"$environment_json")" ]] || fail 'The APIM resource group is outside the approved subscription.'

apim_json=$(az_json 'API Management lookup' apim show --name "$(jq -r '.apiManagementName' <<<"$environment_json")" --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")")
expected_apim_id="/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.resourceGroupName' <<<"$environment_json")/providers/Microsoft.ApiManagement/service/$(jq -r '.apiManagementName' <<<"$environment_json")"
[[ $(jq -r '.id' <<<"$apim_json") == "$expected_apim_id" ]] || fail 'API Management is outside the existing resource group.'
case $(jq -r '.sku.name' <<<"$apim_json") in
  Developer|Basic|BasicV2|Standard|StandardV2|Premium|PremiumV2) ;;
  *) fail 'The APIM tier is not currently documented for MCP server support.' ;;
esac
apim_principal_id=$(jq -r '.identity.principalId // empty' <<<"$apim_json")
[[ -n "$apim_principal_id" ]] || fail 'The APIM service must have a system-assigned identity for the backend hop.'

logger_json=$(az_json 'Application Insights logger lookup' rest --method GET --uri "$expected_apim_id/loggers/$(jq -r '.applicationInsightsLoggerName' <<<"$environment_json")?api-version=2024-05-01")
[[ $(jq -r '.properties.loggerType' <<<"$logger_json") == 'applicationInsights' && $(jq -r '.properties.resourceId' <<<"$logger_json") == $(jq -r '.applicationInsightsResourceId' <<<"$environment_json") ]] || fail 'The configured logger must target the approved Application Insights resource.'

operation_json=$(az_json 'Backing API operation lookup' apim api operation show --api-id "$(jq -r '.backingApiId' <<<"$environment_json")" --operation-id "$(jq -r '.backingOperationId' <<<"$environment_json")" --service-name "$(jq -r '.apiManagementName' <<<"$environment_json")" --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")")
[[ $(jq -r '.method' <<<"$operation_json") == 'GET' ]] || fail 'The backing operation must remain GET.'

role_definitions=$(az_json 'Backend role definition lookup' role definition list --name "$(jq -r '.backendRoleDefinitionId' <<<"$environment_json")")
[[ $(jq -r 'length' <<<"$role_definitions") == '1' ]] || fail 'The backend role definition could not be resolved exactly once.'
python3 - <<'PY' "$role_definitions"
import json
import re
import sys
role = json.loads(sys.argv[1])[0]
operations = []
for permission in role.get('permissions', []):
    operations.extend(permission.get('actions', []))
    operations.extend(permission.get('dataActions', []))
unsafe = [item for item in operations if item == '*' or re.search(r'/(write|delete|action)$', item)]
if unsafe:
    raise SystemExit('The approved backend role includes broad or mutating operations: ' + ', '.join(unsafe))
PY
assignments_json=$(az_json 'APIM backend role assignment lookup' role assignment list --assignee "$apim_principal_id" --role "$(jq -r '.backendRoleDefinitionId' <<<"$environment_json")" --scope "$(jq -r '.backendAuthorizationScope' <<<"$environment_json")")
[[ $(jq -r 'length' <<<"$assignments_json") == '1' ]] || fail 'The APIM identity must have exactly one approved read role at the exact backend scope.'

global_diagnostics=$(az_json 'APIM global diagnostics lookup' rest --method GET --uri "$expected_apim_id/diagnostics?api-version=2024-05-01")
python3 - <<'PY' "$global_diagnostics"
import json
import sys
payload = json.loads(sys.argv[1])
for diagnostic in payload.get('value', []):
    properties = diagnostic.get('properties', {})
    for section_name in ('frontend', 'backend'):
        section = properties.get(section_name) or {}
        for side_name in ('request', 'response'):
            side = section.get(side_name) or {}
            body = side.get('body') or {}
            if int(body.get('bytes', 0) or 0) > 0:
                raise SystemExit('Global APIM diagnostics capture payload bytes. Set request and response body logging to 0.')
PY

foundry_json=$(az_json 'Microsoft Foundry resource lookup' cognitiveservices account show --name "$(jq -r '.foundryAccountName' <<<"$environment_json")" --resource-group "$(jq -r '.foundryResourceGroupName' <<<"$environment_json")")
[[ $(jq -r '.kind' <<<"$foundry_json") == 'AIServices' && $(jq -r '.id' <<<"$foundry_json") == /subscriptions/$approved_subscription_id/* ]] || fail 'The approved Foundry resource ID is not a current AIServices resource in the approved subscription.'

token=$(get_ai_token)
agent_name=$(python3 - <<'PY' "$environment_json"
import json
import sys
from urllib.parse import quote
print(quote(json.loads(sys.argv[1])['agentName'], safe=''))
PY
)
agent_uri="https://$(jq -r '.foundryAccountName' <<<"$environment_json").services.ai.azure.com/api/projects/$(jq -r '.foundryProjectName' <<<"$environment_json")/agents/$agent_name?api-version=v1"
api_request GET "$agent_uri" "$token"
[[ "$API_STATUS" == '200' ]] || fail 'Unable to read the existing Session 04 policy assistant.'
[[ $(jq -r '.agent_card.description // ""' "$API_BODY_FILE") == *'04-governed-agent-baseline'* ]] || fail 'The approved agent ID is not the marked Session 04 policy assistant.'

existing_mcp=$(az rest --method GET --uri "$expected_apim_id/apis/$(jq -r '.mcpServerId' <<<"$environment_json")?api-version=2025-09-01-preview" --only-show-errors --output json 2>/dev/null || true)
if [[ -n "$existing_mcp" ]]; then
  [[ $(jq -r '.properties.description // ""' <<<"$existing_mcp") == *'implementationSession=08-mcp-tool-security'* ]] || fail 'An APIM API already uses the MCP server ID without the Session 08 marker.'
fi

echo 'Deployment preview:'
echo "  MCP server: $expected_apim_id/apis/$(jq -r '.mcpServerId' <<<"$environment_json")"
echo "  Tool: get_policy -> $(jq -r '.backingApiId' <<<"$environment_json")/$(jq -r '.backingOperationId' <<<"$environment_json")"
echo "  Client identity: $(jq -r '.clientApplicationId' <<<"$environment_json") / $(jq -r '.requiredAppRole' <<<"$environment_json")"
echo "  Backend identity: APIM system identity -> $(jq -r '.backendAuthorizationScope' <<<"$environment_json")"
echo "  Candidate agent: $(jq -r '.agentName' <<<"$environment_json") (not pinned)"
echo '  Telemetry: correlation and MCP dimensions only; body bytes 0'

az bicep build --file "$bicep_path" --stdout >/dev/null || fail 'The Session 08 Bicep definition failed to compile.'
az deployment group what-if --name session08-mcp-preview --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --template-file "$bicep_path" --parameters "apiManagementName=$(jq -r '.apiManagementName' <<<"$environment_json")" --only-show-errors --no-pretty-print >/dev/null || fail 'The Session 08 deployment preview failed.'

echo 'PASS: Session 08 Markdown security cases, one-tool boundary, identity scopes, payload-free telemetry, approved APIM and backend scopes, and deployment preview are ready.'
