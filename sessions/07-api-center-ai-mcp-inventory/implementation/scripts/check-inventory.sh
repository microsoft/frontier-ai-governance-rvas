#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  check-inventory.sh --approved-subscription-id SUBSCRIPTION_ID
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
catalog_records_path="$artifact_root/catalog/catalog-records.json"

approved_subscription_id=""
while (($# > 0)); do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail "--approved-subscription-id requires a value."
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
[[ -n "$approved_subscription_id" ]] || fail "--approved-subscription-id is required."

grep -R -q -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" && fail 'Resolve every Session 07 customer decision before checking the live inventory.'
account_json=$(az_json 'Azure account lookup' account show)
[[ $(jq -r '.id' <<<"$account_json") == "$approved_subscription_id" ]] || fail 'Azure CLI is not using the approved subscription.'

environment_json=$(cat "$environment_path")
inventory_json=$(az_json 'API Center inventory lookup' apic api list --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" --max-items 500)
python3 - "$inventory_json" "$catalog_records_path" <<'PY'
import json
import sys
inventory = json.loads(sys.argv[1])
catalog = json.load(open(sys.argv[2], encoding='utf-8'))
agent = catalog['records']['agent']
apim = catalog['records']['apim']
mcp = catalog['records']['mcp']
items = inventory.get('value', inventory)
required_titles = [agent['title'], apim['sourceTitle'], mcp['title']]
for title in required_titles:
    count = sum(1 for item in items if item.get('properties', {}).get('title') == title)
    if count != 1:
        raise SystemExit(f"Expected exactly one inventory asset titled '{title}'; found {count}.")
required_properties = [
    'businessOwner', 'technicalOwner', 'assetKind', 'dataClassification', 'permittedConsumers',
    'modelProvider', 'residencyProfile', 'riskTier', 'evaluationResultsUrl', 'lastReviewDate',
    'expiryDate', 'implementationSession'
]
orphans = []
for item in items:
    props = item.get('properties', {})
    custom = props.get('customProperties') or {}
    missing = []
    for name in required_properties:
        value = custom.get(name)
        if value is None or value == '' or value == []:
            missing.append(name)
    if missing:
        title = props.get('title') or item.get('name') or item.get('id', 'unknown')
        orphans.append(f"{title}: {', '.join(missing)}")
if orphans:
    raise SystemExit('Inventory assets are missing mandatory metadata:\n' + '\n'.join(orphans))
PY
integration_json=$(az_json 'API Center APIM integration lookup' apic integration show --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" --integration-name "$(jq -r '.integrationName' <<<"$environment_json")")
expected_apim_id="/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")/providers/Microsoft.ApiManagement/service/$(jq -r '.apiManagementName' <<<"$environment_json")"
[[ "$integration_json" == *"$expected_apim_id"* ]] || fail 'The API Center integration does not point to the current APIM source.'
integration_state=$(jq -r '.properties.provisioningState // empty' <<<"$integration_json")
if [[ -z "$integration_state" ]]; then
  echo 'WARNING: This API Center response does not expose integration provisioning state. Check source health manually in the portal.' >&2
else
  [[ "$integration_state" == 'Succeeded' || "$integration_state" == 'Ready' ]] || fail "The APIM source integration is not healthy. Current provisioning state: $integration_state."
fi
echo 'PASS: the three records have mandatory metadata and the APIM integration resolves to the implementation source. Provisioning state is checked when exposed; native MCP deployment health remains manual.'
