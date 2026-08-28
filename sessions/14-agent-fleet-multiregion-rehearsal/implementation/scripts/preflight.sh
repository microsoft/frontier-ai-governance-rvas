#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-scope <resource-group-id> [--phase decisions|ready]

Checks the dated one-agent snapshot, one MCP record, minimal regional Bicep parameters, customer
script syntax, stable live Azure resources, API Management topology, and deployment what-if.
USAGE
}

fail() { printf '%s\n' "$1" >&2; exit 1; }
require_file() { [[ -f "$1" ]] || fail "Required file is missing: $1"; }
require_command() { command -v "$1" >/dev/null 2>&1 || fail "Required command is unavailable: $1"; }

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
control_path="$artifact_root/control-definition.json"
inventory_path="$artifact_root/fleet/agent-inventory.md"
parameters_path="$artifact_root/regional/region.parameters.json"

phase='ready'
approved_scope=''
while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase)
      [[ $# -ge 2 ]] || fail 'Missing value for --phase'
      phase="${2,,}"
      shift 2
      ;;
    --approved-scope)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-scope'
      approved_scope="$2"
      shift 2
      ;;
    --help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown argument: $1" ;;
  esac
done

[[ "$phase" == 'decisions' || "$phase" == 'ready' ]] || fail 'Phase must be decisions or ready.'
[[ "$approved_scope" =~ ^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$ ]] ||
  fail 'Approved scope must be an exact Azure resource-group resource ID.'
approved_target_scope="$approved_scope"

for path in \
  "$control_path" \
  "$inventory_path" \
  "$parameters_path" \
  "$artifact_root/regional/failover-runbook.md" \
  "$artifact_root/README.md"; do
  require_file "$path"
done
for command_name in python az bash; do require_command "$command_name"; done

covered_sentinels='
__REQUIRED_AGENT_365_REGISTRY_ID__
__REQUIRED_AGENT_365_VISIBILITY_STATUS__
__REQUIRED_AGENT_IDENTITY_ID__
__REQUIRED_AGENT_OWNER__
__REQUIRED_AGENT_VERSION__
__REQUIRED_APPLICATION_INSIGHTS_NAME__
__REQUIRED_BUSINESS_SERVICE_NAME__
__REQUIRED_CUSTOMER_BICEP_ENTRYPOINT_PATH__
__REQUIRED_CUSTOMER_HEALTH_CHECK_BASH_PATH__
__REQUIRED_CUSTOMER_HEALTH_CHECK_POWERSHELL_PATH__
__REQUIRED_CUSTOMER_ROUTING_CONTROL_BASH_PATH__
__REQUIRED_CUSTOMER_ROUTING_CONTROL_POWERSHELL_PATH__
__REQUIRED_DEFENDER_VISIBILITY_STATUS__
__REQUIRED_DELIVERY_OWNER__
__REQUIRED_FOUNDRY_ACCOUNT_NAME__
__REQUIRED_FOUNDRY_AGENT_NAME__
__REQUIRED_FOUNDRY_CONTROL_PLANE_VISIBILITY_STATUS__
__REQUIRED_FOUNDRY_PROJECT_NAME__
__REQUIRED_GATEWAY_PATTERN_MULTI_REGION_OR_SEPARATE__
__REQUIRED_GATEWAY_POLICY_VERSION__
__REQUIRED_INVENTORY_SNAPSHOT_DATE__
__REQUIRED_MANAGEMENT_PLANE_LIMIT_ACCEPTED_TRUE__
__REQUIRED_MCP_OWNER__
__REQUIRED_MCP_SERVER_INVENTORY_ID__
__REQUIRED_OPERATIONAL_RECORD_STORE__
__REQUIRED_PLATFORM_OWNER__
__REQUIRED_PRIMARY_APIM_SERVICE_NAME__
__REQUIRED_PRIMARY_APIM_TIER__
__REQUIRED_PRIMARY_BACKEND_URL__
__REQUIRED_PRIMARY_GATEWAY_URL__
__REQUIRED_PRIMARY_REGION__
__REQUIRED_PRIMARY_ROUTING_SELECTOR__
__REQUIRED_PURVIEW_VISIBILITY_STATUS__
__REQUIRED_REGIONAL_RATE_COUNTER_LIMIT_ACCEPTED_TRUE__
__REQUIRED_RESOURCE_GROUP__
__REQUIRED_ROUTING_MODE_EXTERNAL_OR_INTERNAL__
__REQUIRED_SECONDARY_APIM_RESOURCE_ID__
__REQUIRED_SECONDARY_APIM_TIER__
__REQUIRED_SECONDARY_BACKEND_URL__
__REQUIRED_SECONDARY_GATEWAY_URL__
__REQUIRED_SECONDARY_REGION__
__REQUIRED_SECONDARY_ROUTING_SELECTOR__
__REQUIRED_SECURITY_OWNER__
__REQUIRED_SERVICE_OWNER__
__REQUIRED_SUBSCRIPTION_ID__
'
mapfile -t found_sentinels < <(grep -RhoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u)
for sentinel in "${found_sentinels[@]}"; do
  grep -Fxq "$sentinel" <<<"$covered_sentinels" || fail "Preflight has no named coverage for $sentinel"
done
if (( ${#found_sentinels[@]} > 0 )); then
  grep -RnoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" >&2 || true
  fail 'Resolve every named customer decision before a state change.'
fi

state="$(
python - "$repo_root" "$control_path" "$inventory_path" "$parameters_path" "$approved_target_scope" <<'PY'
import datetime
import json
import os
import re
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
control = json.load(open(sys.argv[2]))
inventory_path = Path(sys.argv[3]).resolve()
inventory_text = inventory_path.read_text()
parameters_path = Path(sys.argv[4]).resolve()
document = json.load(open(parameters_path))
scope = sys.argv[5]
values = {name: item.get('value') for name, item in document.get('parameters', {}).items()}

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
            raise SystemExit('agent-inventory.md contains raw HTML outside fenced code.')
        visible.append(line)

    if fence_character is not None:
        raise SystemExit('agent-inventory.md contains an unclosed fenced code block.')
    if html_tag_pattern.search('\n'.join(visible)):
        raise SystemExit('agent-inventory.md contains raw HTML outside fenced code.')
    return visible

def section(lines, heading):
    indexes = [index for index, line in enumerate(lines) if line.strip() == heading]
    if not indexes:
        raise SystemExit(f"agent-inventory.md is missing heading '{heading}'.")
    if len(indexes) > 1:
        raise SystemExit(f"agent-inventory.md contains duplicate heading '{heading}'.")
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
    header = re.compile(r'^\|\s*Field\s*\|\s*Observation\s*\|\s*$')
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
        raise SystemExit(f"agent-inventory.md section '{heading}' is missing field '{name}'.")
    if len(matches) > 1:
        raise SystemExit(f"agent-inventory.md section '{heading}' contains duplicate field '{name}'.")
    value = matches[0]
    if len(value) >= 2 and value[0] == value[-1] == '`':
        value = value[1:-1].strip()
    if not value:
        raise SystemExit(f"agent-inventory.md field '{name}' in section '{heading}' is empty.")
    return value

summary_heading = '# Agent inventory operator snapshot'
visibility_heading = '## Operator visibility observations'
agent_heading = '## Governed agent'
agent365_heading = '## Microsoft Agent 365'
mcp_heading = '## MCP server'
inventory_lines = markdown_lines(inventory_text)
summary = section(inventory_lines, summary_heading)
visibility = section(inventory_lines, visibility_heading)
agent = section(inventory_lines, agent_heading)
agent365 = section(inventory_lines, agent365_heading)
mcp = section(inventory_lines, mcp_heading)

try:
    snapshot_date = datetime.date.fromisoformat(field(summary, 'Snapshot date', summary_heading))
except ValueError as error:
    raise SystemExit('agent-inventory.md Snapshot date must be a real yyyy-mm-dd date.') from error
if snapshot_date > datetime.datetime.now(datetime.timezone.utc).date():
    raise SystemExit('agent-inventory.md Snapshot date cannot be in the future.')
system_of_record = field(summary, 'System of record', summary_heading)
if system_of_record != control.get('records', {}).get('approvedOperationalStore'):
    raise SystemExit('The inventory system of record must match the approved operational store.')
if field(summary, 'Runtime output committed to this repository', summary_heading) != 'No':
    raise SystemExit('The inventory must keep runtime output out of this repository.')
for name in ('Name', 'Owner'):
    field(agent, name, agent_heading)
inventory_agent_version = field(agent, 'Immutable version', agent_heading)
field(agent365, 'Registry ID', agent365_heading)
inventory_agent_identity_id = field(
    agent365, 'Microsoft Entra agent identity ID', agent365_heading
)
for name in ('Inventory ID', 'Owner'):
    field(mcp, name, mcp_heading)
required_visibility = (
    'Foundry Control Plane agent visibility',
    'Microsoft Agent 365 registry visibility',
    'Microsoft Purview agent visibility',
    'Microsoft Defender agent visibility',
)
for name in required_visibility:
    if field(visibility, name, visibility_heading) != 'Confirmed':
        raise SystemExit(f"agent-inventory.md field '{name}' must be Confirmed.")

if control.get('implementationSession') != '15-agent-fleet-multiregion-rehearsal' or values.get('implementationSession') != '15-agent-fleet-multiregion-rehearsal':
    raise SystemExit('A implementation file has the wrong implementationSession marker.')
if control.get('approvedAzureScope', '').lower() != scope.lower():
    raise SystemExit('Approved scope differs from the operational control.')
if inventory_agent_version != values.get('agentVersion'):
    raise SystemExit(
        'The inventory immutable version must match region.parameters.json agentVersion.'
    )
if inventory_agent_identity_id != values.get('agentIdentityId'):
    raise SystemExit(
        'The inventory Microsoft Entra agent identity ID must match region.parameters.json agentIdentityId.'
    )
if values.get('primaryRegion', '').lower() == values.get('secondaryRegion', '').lower():
    raise SystemExit('Primary and secondary regions must differ.')
primary_selector = str(values.get('primarySelector', '')).strip()
secondary_selector = str(values.get('secondarySelector', '')).strip()
if not primary_selector or not secondary_selector or primary_selector.casefold() == secondary_selector.casefold():
    raise SystemExit('Primary and secondary routing selectors must be nonempty and distinct.')
project_resource_id = str(values.get('foundryProjectResourceId', ''))
application_insights_resource_id = str(values.get('applicationInsightsResourceId', ''))
live_resources = [str(value).lower() for value in control.get('inventory', {}).get('liveAzureResources', [])]
if (
    len(live_resources) != 2
    or project_resource_id.lower() not in live_resources
    or application_insights_resource_id.lower() not in live_resources
):
    raise SystemExit('The control definition and regional parameters use different live Azure resource IDs.')
if values.get('gatewayPattern') not in ('multi-region-instance', 'separate-regional-gateways'):
    raise SystemExit('Invalid gatewayPattern.')
if values.get('routingMode') not in ('external', 'internal'):
    raise SystemExit('Invalid routingMode.')
if values.get('managementPlanePrimaryRegionAccepted') is not True or values.get('regionalRateCountersAccepted') is not True:
    raise SystemExit('Regional platform limits must be accepted.')
prefix = scope.lower() + '/providers/microsoft.apimanagement/service/'
for name in ('primaryApimResourceId', 'secondaryApimResourceId'):
    if not str(values.get(name, '')).lower().startswith(prefix):
        raise SystemExit(f'{name} must remain inside the approved scope.')
for name in ('primaryGatewayUrl', 'secondaryGatewayUrl', 'primaryBackendUrl', 'secondaryBackendUrl'):
    if not re.fullmatch(r'https://[^/\s]+(?:/.*)?', str(values.get(name, ''))):
        raise SystemExit(f'{name} must be an absolute HTTPS URL.')

def resolve(relative, purpose):
    if os.path.isabs(relative):
        raise SystemExit(f'{purpose} must be repository-relative.')
    candidate = (repo / relative).resolve()
    if not str(candidate).startswith(str(repo) + os.sep) or not candidate.is_file():
        raise SystemExit(f'{purpose} is missing or outside the repository.')
    return candidate

bicep = resolve(control['sourcePaths']['bicepEntrypoint'], 'Customer Bicep entrypoint')
health = resolve(control['sourcePaths']['healthCheckBash'], 'Customer Bash health script')
routing = resolve(control['sourcePaths']['routingControlBash'], 'Customer Bash routing script')
resolve(control['sourcePaths']['healthCheckPowerShell'], 'Customer PowerShell health script')
resolve(control['sourcePaths']['routingControlPowerShell'], 'Customer PowerShell routing script')
retained_parameters = resolve(control['sourcePaths']['regionalParameters'], 'Regional parameter contract')
if retained_parameters != parameters_path:
    raise SystemExit('regionalParameters must point to region.parameters.json.')

print(json.dumps({
    'subscriptionId': scope.split('/')[2],
    'resourceGroup': scope.split('/')[4],
    'bicep': str(bicep),
    'health': str(health),
    'routing': str(routing),
    'parameters': str(parameters_path),
    'primaryRegion': values['primaryRegion'],
    'secondaryRegion': values['secondaryRegion'],
    'gatewayPattern': values['gatewayPattern'],
    'primaryApimResourceId': values['primaryApimResourceId'],
    'secondaryApimResourceId': values['secondaryApimResourceId'],
    'primaryApimTier': values['primaryApimTier'],
    'secondaryApimTier': values['secondaryApimTier'],
    'liveResources': control['inventory']['liveAzureResources'],
}))
PY
)"

json_value() {
  python -c 'import json,sys; value=json.loads(sys.stdin.read()); print(value[sys.argv[1]])' "$1" <<<"$state"
}
bicep_path="$(json_value bicep)"
health_script="$(json_value health)"
routing_script="$(json_value routing)"
bash -n "$health_script"
bash -n "$routing_script"
az bicep lint --file "$bicep_path"
az bicep build --file "$bicep_path" --stdout >/dev/null

if [[ "$phase" == 'decisions' ]]; then
  printf 'PASS: the dated Markdown inventory, agent and MCP ownership, Confirmed visibility statuses, regional parameters, script syntax, and Bicep checks are ready.\n'
  exit 0
fi

python - "$state" "$(az account show -o json)" <<'PY'
import json, sys
state = json.loads(sys.argv[1])
account = json.loads(sys.argv[2])
if str(account.get('id', '')).lower() != state['subscriptionId'].lower():
    raise SystemExit('Active Azure subscription differs from the approved scope.')
PY

python - "$state" <<'PY'
import json, subprocess, sys
state = json.loads(sys.argv[1])
for resource_id in state['liveResources']:
    subprocess.check_call(('az', 'resource', 'show', '--ids', resource_id, '-o', 'none'))

def show(resource_id):
    return json.loads(subprocess.check_output(('az', 'resource', 'show', '--ids', resource_id, '-o', 'json'), text=True))

primary = show(state['primaryApimResourceId'])
secondary = primary if state['secondaryApimResourceId'].lower() == state['primaryApimResourceId'].lower() else show(state['secondaryApimResourceId'])
if primary.get('location', '').lower() != state['primaryRegion'].lower():
    raise SystemExit('Primary API Management region differs from the parameter contract.')
if primary.get('sku', {}).get('name', '').lower() != state['primaryApimTier'].lower() or secondary.get('sku', {}).get('name', '').lower() != state['secondaryApimTier'].lower():
    raise SystemExit('Live API Management tier differs from the parameter contract.')
if state['gatewayPattern'] == 'multi-region-instance':
    locations = [item.get('location', '').lower() for item in primary.get('properties', {}).get('additionalLocations', [])]
    if state['primaryApimResourceId'].lower() != state['secondaryApimResourceId'].lower() or primary.get('sku', {}).get('name', '').lower() != 'premium' or state['secondaryRegion'].lower() not in locations:
        raise SystemExit('The live Premium (classic) instance lacks the configured secondary location.')
elif state['primaryApimResourceId'].lower() == state['secondaryApimResourceId'].lower() or secondary.get('location', '').lower() != state['secondaryRegion'].lower():
    raise SystemExit('Separate regional gateways require different resource IDs in their approved regions.')
PY

az deployment group what-if \
  --subscription "$(json_value subscriptionId)" \
  --resource-group "$(json_value resourceGroup)" \
  --name s15-regional-preflight \
  --template-file "$bicep_path" \
  --parameters "@$(json_value parameters)" \
  --no-pretty-print

printf 'PASS: the dated Markdown inventory, stable Azure resources, API Management topology, regional parameters, customer scripts, Bicep, and read-only preview are ready.\n'
