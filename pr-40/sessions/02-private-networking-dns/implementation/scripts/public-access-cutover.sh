#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
parameter_path="$script_dir/../artifacts/environments/sandbox.bicepparam"
approved_subscription_id=""
resource_group_name=""
cutover_change_reference=""
timeout_seconds='8'
confirm_prior_state_recorded=false
confirm=false

usage() {
  cat <<'USAGE'
Usage: ./scripts/public-access-cutover.sh \
  --approved-subscription-id <id> \
  --resource-group-name <name> \
  --cutover-change-reference <id-or-url> \
  --confirm-prior-state-recorded \
  [--parameter-path <path>] [--timeout-seconds <seconds>] [--confirm]

Derive the five approved services from the Bicep parameter file, verify private connectivity, and
disable public access only after their prior states are recorded in the approved change system.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

run_capture() {
  local output
  if output="$("$@" 2>&1)"; then
    printf '%s' "$output"
    return 0
  fi
  [[ -n "$output" ]] && printf '%s\n' "$output" >&2
  return 1
}

verify_public_access_disabled() {
  local alias="$1"
  local resource_id="$2"
  local require_marker="${3:-false}"
  local resource_json
  resource_json="$(run_capture az resource show --ids "$resource_id" --only-show-errors --output json)" ||
    die "Post-update lookup failed for $alias."
  PYTHON_JSON_INPUT="$resource_json" python3 - "$alias" "$require_marker" <<'PY'
import json
import os
import sys

alias, require_marker = sys.argv[1:]
resource = json.loads(os.environ["PYTHON_JSON_INPUT"])
state = str((resource.get("properties") or {}).get("publicNetworkAccess") or "")
if state.casefold() != "disabled":
    raise SystemExit(f"{alias} still reports publicNetworkAccess={state or '<missing>'}.")
if require_marker == "true":
    marker = str((resource.get("tags") or {}).get("networkControlSession") or "")
    if marker != "02-private-networking-dns":
        raise SystemExit(f"{alias} is missing the successful cutover marker.")
PY
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      approved_subscription_id="$2"
      shift 2
      ;;
    --resource-group-name)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      resource_group_name="$2"
      shift 2
      ;;
    --cutover-change-reference)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      cutover_change_reference="$2"
      shift 2
      ;;
    --parameter-path)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      parameter_path="$2"
      shift 2
      ;;
    --timeout-seconds)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      timeout_seconds="$2"
      shift 2
      ;;
    --confirm-prior-state-recorded)
      confirm_prior_state_recorded=true
      shift
      ;;
    --confirm)
      confirm=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "Unknown option: $1"
      ;;
  esac
done

[[ -n "$approved_subscription_id" ]] || { usage >&2; die '--approved-subscription-id is required.'; }
[[ -n "$resource_group_name" ]] || { usage >&2; die '--resource-group-name is required.'; }
[[ -n "$cutover_change_reference" ]] || { usage >&2; die '--cutover-change-reference is required.'; }
[[ -f "$parameter_path" ]] || die "Parameter file is missing: $parameter_path"
command -v az >/dev/null 2>&1 || die 'Azure CLI is required and was not found on PATH.'
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required and was not found on PATH.'

targets_output="$(python3 - "$parameter_path" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
for alias, field, resource_type in (
    ("foundry", "foundryResourceId", "Microsoft.CognitiveServices/accounts"),
    ("storage", "storageResourceId", "Microsoft.Storage/storageAccounts"),
    ("ai-search", "searchResourceId", "Microsoft.Search/searchServices"),
    ("cosmos", "cosmosResourceId", "Microsoft.DocumentDB/databaseAccounts"),
    ("key-vault", "keyVaultResourceId", "Microsoft.KeyVault/vaults"),
):
    matches = re.findall(
        rf"^\s*param\s+{re.escape(field)}\s*=\s*'([^']+)'\s*$",
        text,
        flags=re.MULTILINE,
    )
    if len(matches) != 1:
        raise SystemExit(f"Parameter '{field}' must contain exactly one quoted resource ID.")
    print(f"{alias}\t{matches[0].strip().rstrip('/')}\t{resource_type}")
PY
)" || die "Unable to derive cutover targets from parameter file '$parameter_path'."
mapfile -t targets <<<"$targets_output"

resource_ids=()
resource_names=()
prior_states=()
for target in "${targets[@]}"; do
  IFS=$'\t' read -r alias resource_id resource_type <<<"$target"
  resource_json="$(run_capture az resource show --ids "$resource_id" --only-show-errors --output json)" || die "$alias lookup failed."
  inspection="$(PYTHON_JSON_INPUT="$resource_json" python3 - "$resource_id" "$resource_type" "$approved_subscription_id" "$resource_group_name" <<'PY'
import json
import os
import sys

expected_id, expected_type, subscription_id, resource_group = sys.argv[1:]
resource = json.loads(os.environ["PYTHON_JSON_INPUT"])
expected_prefix = f"/subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/"
if str(resource.get("id", "")).rstrip("/").lower() != expected_id.lower():
    raise SystemExit("Resource lookup returned a different resource ID.")
if not str(resource.get("id", "")).lower().startswith(expected_prefix.lower()):
    raise SystemExit("Resource is outside the approved subscription or resource group.")
if str(resource.get("type", "")).lower() != expected_type.lower():
    raise SystemExit(f"Resource must be type '{expected_type}'.")
prior_state = str((resource.get("properties") or {}).get("publicNetworkAccess") or "")
if not prior_state:
    raise SystemExit("Resource does not expose properties.publicNetworkAccess through the current API.")
print("\t".join((str(resource.get("name", "")), prior_state)))
PY
)" || die "$alias validation failed."
  IFS=$'\t' read -r resource_name prior_state <<<"$inspection"
  [[ " ${resource_ids[*]:-} " != *" $resource_id "* ]] || die "Each cutover target must identify a unique resource."
  resource_ids+=("$resource_id")
  resource_names+=("$resource_name")
  prior_states+=("$prior_state")
done

"$script_dir/connectivity-check.sh" --parameter-path "$parameter_path" --timeout-seconds "$timeout_seconds"

printf 'Cutover scope: five approved nonproduction services.\n'
printf 'Change record: %s\n' "$cutover_change_reference"
for index in "${!targets[@]}"; do
  IFS=$'\t' read -r alias _ _ <<<"${targets[$index]}"
  printf '  %s: %s -> Disabled\n' "$alias" "${prior_states[$index]}"
done
if [[ "$confirm_prior_state_recorded" != true ]]; then
  die "Copy the displayed prior states into change record '$cutover_change_reference' through the approved change process, then rerun with --confirm-prior-state-recorded."
fi
if [[ "$confirm" != true ]]; then
  printf 'No public-access changes were applied. Add --confirm after recording the displayed prior states.\n'
  exit 0
fi

for index in "${!targets[@]}"; do
  IFS=$'\t' read -r alias _ _ <<<"${targets[$index]}"
  resource_id="${resource_ids[$index]}"
  resource_name="${resource_names[$index]}"
  case "$alias" in
    foundry)
      run_capture az resource update --ids "$resource_id" --set properties.publicNetworkAccess=Disabled --only-show-errors --output none >/dev/null ||
        die "Public-access update failed for $alias."
      ;;
    storage)
      run_capture az storage account update --ids "$resource_id" --public-network-access Disabled --only-show-errors --output none >/dev/null ||
        die "Public-access update failed for $alias."
      ;;
    ai-search)
      run_capture az search service update --ids "$resource_id" --public-network-access disabled --only-show-errors --output none >/dev/null ||
        die "Public-access update failed for $alias."
      ;;
    cosmos)
      run_capture az cosmosdb update --ids "$resource_id" --public-network-access Disabled --only-show-errors --output none >/dev/null ||
        die "Public-access update failed for $alias."
      ;;
    key-vault)
      run_capture az keyvault update --name "$resource_name" --resource-group "$resource_group_name" --subscription "$approved_subscription_id" --public-network-access Disabled --only-show-errors >/dev/null ||
        die "Public-access update failed for $alias."
      ;;
  esac
  verify_public_access_disabled "$alias" "$resource_id"
  run_capture az tag update --resource-id "$resource_id" --operation Merge --tags networkControlSession=02-private-networking-dns --only-show-errors >/dev/null ||
    die "Tag update failed for $alias after public access was disabled."
  verify_public_access_disabled "$alias" "$resource_id" true
done

printf 'Cutover complete. Each marker confirms a verified Disabled state; the change record holds the prior states for the approved restore path.\n'
