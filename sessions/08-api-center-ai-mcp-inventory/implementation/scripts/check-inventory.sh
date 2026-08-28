#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  check-inventory.sh --approved-subscription-id SUBSCRIPTION_ID --remote-mcp-server-title TITLE
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
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

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
environment_path="$artifact_root/environments/sandbox.json"
agent_definition_path="$artifact_root/api-center/agent-api-definition.json"
approved_subscription_id=""
remote_mcp_server_title=""

while (($# > 0)); do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail "--approved-subscription-id requires a value."
      approved_subscription_id=$2
      shift 2
      ;;
    --remote-mcp-server-title)
      [[ $# -ge 2 ]] || fail "--remote-mcp-server-title requires a value."
      remote_mcp_server_title=$2
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

[[ -n "$approved_subscription_id" ]] || fail "--approved-subscription-id is required."
[[ -n "$remote_mcp_server_title" ]] || fail "--remote-mcp-server-title is required."
command -v az >/dev/null 2>&1 || fail "az is required."
command -v jq >/dev/null 2>&1 || fail "jq is required."
command -v python3 >/dev/null 2>&1 || fail "python3 is required."
[[ -f "$environment_path" ]] || fail "Required implementation file is missing: $environment_path"
[[ -f "$agent_definition_path" ]] || fail "Required implementation file is missing: $agent_definition_path"
grep -R -q -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" &&
  fail "Resolve every Session 08 deployment decision before checking the live inventory."

environment_json=$(cat "$environment_path")
account_json=$(az_json "Azure account lookup" account show)
[[ $(jq -r '.id' <<<"$account_json") == "$approved_subscription_id" ]] ||
  fail "Azure CLI is not using the approved subscription."
session06_api=$(az_json "Session 07 APIM API lookup" apim api show \
  --api-id policy-assistant-responses \
  --service-name "$(jq -r '.apiManagementName' <<<"$environment_json")" \
  --resource-group "$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")")
[[ $(jq -r '.description // ""' <<<"$session06_api") == *'implementationSession=06-apim-ai-gateway'* ]] ||
  fail "The Session 07 APIM source does not contain the expected marker."
inventory_json=$(az_json "API Center inventory lookup" apic api list \
  --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" \
  --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" \
  --max-items 500)

python3 - "$inventory_json" "$agent_definition_path" "$(jq -r '.displayName' <<<"$session06_api")" "$remote_mcp_server_title" <<'PY'
import json
import sys

inventory = json.loads(sys.argv[1])
agent_definition = json.load(open(sys.argv[2], encoding='utf-8'))
if agent_definition.get('implementationSession') != '07-api-center-ai-mcp-inventory':
    raise SystemExit('The direct agent definition has the wrong implementationSession marker.')
agent = agent_definition['api']
titles = [agent['title'], sys.argv[3], sys.argv[4]]
items = inventory.get('value', inventory)
selected = []
for title in titles:
    matches = [item for item in items if item.get('properties', {}).get('title') == title]
    if len(matches) != 1:
        raise SystemExit(f"Expected exactly one inventory asset titled '{title}'; found {len(matches)}.")
    selected.append(matches[0])
required = [
    'businessOwner', 'technicalOwner', 'assetKind', 'dataClassification', 'permittedConsumers',
    'modelProvider', 'residencyProfile', 'riskTier', 'evaluationResultsUrl', 'lastReviewDate',
    'expiryDate', 'implementationSession'
]
incomplete = []
for item in selected:
    props = item.get('properties', {})
    custom = props.get('customProperties') or {}
    missing = [name for name in required if custom.get(name) in (None, '', [])]
    if missing:
        incomplete.append(f"{props.get('title')}: {', '.join(missing)}")
if incomplete:
    raise SystemExit('Selected inventory assets are missing mandatory metadata:\n' + '\n'.join(incomplete))
PY

integration_json=$(az_json "API Center APIM integration lookup" apic integration show \
  --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" \
  --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" \
  --integration-name "$(jq -r '.integrationName' <<<"$environment_json")")
expected_apim_id="/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")/providers/Microsoft.ApiManagement/service/$(jq -r '.apiManagementName' <<<"$environment_json")"
[[ "$integration_json" == *"$expected_apim_id"* ]] ||
  fail "The API Center integration does not point to the current APIM source."
integration_state=$(jq -r '.properties.provisioningState // empty' <<<"$integration_json")
if [[ -z "$integration_state" ]]; then
  echo "WARNING: This API Center response does not expose integration provisioning state. Check source health manually in the portal." >&2
elif [[ "$integration_state" != "Succeeded" && "$integration_state" != "Ready" ]]; then
  fail "The APIM source integration is not healthy. Current provisioning state: $integration_state."
fi

echo "PASS: the selected agent, APIM, and MCP records have mandatory metadata and the APIM integration resolves to the implementation source."
