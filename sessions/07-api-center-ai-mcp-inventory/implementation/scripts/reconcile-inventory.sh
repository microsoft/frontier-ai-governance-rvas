#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  reconcile-inventory.sh --approved-subscription-id SUBSCRIPTION_ID
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
apim_record_path="$artifact_root/catalog/catalog-records.json"
[[ -f "$environment_path" ]] || fail "Required implementation file is missing: $environment_path"
[[ -f "$apim_record_path" ]] || fail "Required implementation file is missing: $apim_record_path"

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

grep -R -q -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" && fail 'Resolve every Session 07 customer decision before reconciling the inventory.'

environment_json=$(cat "$environment_path")
record_json=$(jq -c '.records.apim + {customProperties:(.commonMetadata + .records.apim.customProperties)}' "$apim_record_path")
account_json=$(az_json 'Azure account lookup' account show)
[[ $(jq -r '.id' <<<"$account_json") == "$approved_subscription_id" ]] || fail 'Azure CLI is not using the approved subscription.'

inventory_json=$(az_json 'API Center inventory lookup' apic api list --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" --max-items 500)
api_id=$(python3 - "$inventory_json" "$(jq -r '.sourceTitle' <<<"$record_json")" <<'PY'
import json
import sys
payload = json.loads(sys.argv[1])
source_title = sys.argv[2]
items = payload.get('value', payload)
matches = [item for item in items if item.get('properties', {}).get('title') == source_title]
if len(matches) != 1:
    raise SystemExit(f"Expected one synchronized API titled '{source_title}'; found {len(matches)}. Wait for synchronization or resolve duplicate titles.")
match = matches[0]
print(match.get('name') or match.get('id', '').split('/')[-1])
PY
)
custom_properties=$(jq -c '.customProperties' <<<"$record_json")
update_output=$(az apic api update --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" --api-id "$api_id" --custom-properties "$custom_properties" --only-show-errors --output none 2>&1) || fail "Updating mandatory metadata on the synchronized Session 06 API failed.\n$update_output"
echo "Updated mandatory governance metadata on '$(jq -r '.sourceTitle' <<<"$record_json")'."
