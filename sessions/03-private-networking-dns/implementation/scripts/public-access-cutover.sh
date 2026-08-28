#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../../../.." && pwd)"
tmpdir="$(mktemp -d)"
temp_paths=()

cleanup() {
  local path
  for path in "${temp_paths[@]:-}"; do
    [[ -e "$path" ]] && rm -rf -- "$path"
  done
  [[ -d "$tmpdir" ]] && rm -rf -- "$tmpdir"
}
trap cleanup EXIT

usage() {
  cat <<'USAGE'
Usage: ./scripts/public-access-cutover.sh \
  --foundry-resource-id <id> \
  --storage-resource-id <id> \
  --search-resource-id <id> \
  --cosmos-resource-id <id> \
  --key-vault-resource-id <id> \
  --approved-subscription-id <id> \
  --resource-group-name <name> \
  --cutover-record-path <path> \
  [--endpoint-matrix-path <path>] \
  [--timeout-seconds <seconds>] \
  [--what-if] [--confirm]

Validate the approved Session 04 service set, check private connectivity, write the full restore
record outside the repository, and disable public network access only when --confirm is supplied.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}
register_temp() { temp_paths+=("$1"); }
make_temp_file() {
  local template="$1"
  local path
  path="$(mktemp "$template")"
  register_temp "$path"
  printf '%s\n' "$path"
}
run_capture() {
  local stdout_file stderr_file status
  stdout_file="$(make_temp_file "$tmpdir/stdout.XXXXXX")"
  stderr_file="$(make_temp_file "$tmpdir/stderr.XXXXXX")"
  if "$@" >"$stdout_file" 2>"$stderr_file"; then
    cat "$stdout_file"
    return 0
  fi
  status=$?
  [[ -s "$stderr_file" ]] && cat "$stderr_file" >&2
  return "$status"
}

resolve_external_record_path() {
  python3 - "$repo_root" "$1" <<'PY'
from pathlib import Path
import sys
repo_root = Path(sys.argv[1]).resolve()
resolved_path = Path(sys.argv[2]).expanduser().resolve(strict=False)
try:
    resolved_path.relative_to(repo_root)
    raise SystemExit('CutoverRecordPath must resolve outside the source repository.')
except ValueError:
    pass
if resolved_path.exists():
    raise SystemExit('CutoverRecordPath already exists. Preserve it and use a new path for a new cutover.')
backup_path = Path(f"{resolved_path}.previous")
if backup_path.exists():
    raise SystemExit('CutoverRecordPath has an existing recovery copy. Preserve it and use a new path for a new cutover.')
parent = resolved_path.parent
if not str(parent):
    raise SystemExit('CutoverRecordPath must include an approved parent directory.')
if not parent.is_dir():
    raise SystemExit('The approved CutoverRecordPath parent directory does not exist.')
print(str(resolved_path))
PY
}

set_public_network_access() {
  local alias="$1"
  local resource_id="$2"
  local resource_name="$3"
  local state="$4"
  case "$alias" in
    foundry)
      run_capture az resource update --ids "$resource_id" --set "properties.publicNetworkAccess=$state" --only-show-errors --output none >/dev/null || die "Public-access update failed for $alias."
      ;;
    storage)
      run_capture az storage account update --ids "$resource_id" --public-network-access "$state" --only-show-errors --output none >/dev/null || die "Public-access update failed for $alias."
      ;;
    ai-search)
      run_capture az search service update --ids "$resource_id" --public-network-access "${state,,}" --only-show-errors --output none >/dev/null || die "Public-access update failed for $alias."
      ;;
    cosmos)
      run_capture az cosmosdb update --ids "$resource_id" --public-network-access "$state" --only-show-errors --output none >/dev/null || die "Public-access update failed for $alias."
      ;;
    key-vault)
      run_capture az keyvault update --name "$resource_name" --resource-group "$resource_group_name" --subscription "$approved_subscription_id" --public-network-access "$state" --only-show-errors >/dev/null || die "Public-access update failed for $alias."
      ;;
    *)
      die "Unsupported cutover alias: $alias"
      ;;
  esac
}

write_cutover_record() {
  local path="$1"
  local status_text="$2"
  local parent file_name tmp_file backup_file
  parent="$(dirname -- "$path")"
  file_name="$(basename -- "$path")"
  tmp_file="$(make_temp_file "$parent/.${file_name}.XXXXXX.tmp")"
  backup_file="${path}.previous"
  python3 - "$status_text" "$captured_at_utc" "${record_entries[@]}" >"$tmp_file" <<'PY'
import json
import sys
status = sys.argv[1]
captured_at = sys.argv[2]
entries = []
for item in sys.argv[3:]:
    alias, resource_id, prior_state, requested_state, result = item.split('|', 4)
    entries.append({
        'alias': alias,
        'resourceId': resource_id,
        'priorState': prior_state,
        'requestedState': requested_state,
        'result': result,
    })
record = {
    'schemaVersion': 1,
    'session': '04-private-networking-dns',
    'capturedAtUtc': captured_at,
    'status': status,
    'resources': entries,
}
json.dump(record, sys.stdout, indent=2)
sys.stdout.write('\n')
PY
  if [[ -f "$path" ]]; then
    cp -f -- "$path" "$backup_file"
  fi
  mv -f -- "$tmp_file" "$path"
}

foundry_resource_id=""
storage_resource_id=""
search_resource_id=""
cosmos_resource_id=""
key_vault_resource_id=""
approved_subscription_id=""
resource_group_name=""
endpoint_matrix_path="$script_dir/../artifacts/network/endpoint-matrix.json"
cutover_record_path=""
timeout_seconds='8'
what_if=false
confirm=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --foundry-resource-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      foundry_resource_id="$2"
      shift 2
      ;;
    --storage-resource-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      storage_resource_id="$2"
      shift 2
      ;;
    --search-resource-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      search_resource_id="$2"
      shift 2
      ;;
    --cosmos-resource-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      cosmos_resource_id="$2"
      shift 2
      ;;
    --key-vault-resource-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      key_vault_resource_id="$2"
      shift 2
      ;;
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
    --endpoint-matrix-path)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      endpoint_matrix_path="$2"
      shift 2
      ;;
    --cutover-record-path)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      cutover_record_path="$2"
      shift 2
      ;;
    --timeout-seconds)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      timeout_seconds="$2"
      shift 2
      ;;
    --what-if)
      what_if=true
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

for required_name in \
  foundry_resource_id storage_resource_id search_resource_id cosmos_resource_id key_vault_resource_id \
  approved_subscription_id resource_group_name cutover_record_path; do
  [[ -n "${!required_name}" ]] || { usage >&2; die "--${required_name//_/-} is required."; }
done
[[ -f "$endpoint_matrix_path" ]] || die "EndpointMatrixPath is missing: $endpoint_matrix_path"
command -v az >/dev/null 2>&1 || die 'Azure CLI is required and was not found on PATH.'
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required and was not found on PATH.'

python3 - "$endpoint_matrix_path" <<'PY'
import json, sys
with open(sys.argv[1], encoding='utf-8') as handle:
    matrix = json.load(handle)
if matrix.get('implementationSession') != '04-private-networking-dns' or len(matrix.get('endpoints') or []) != 5:
    raise SystemExit('EndpointMatrixPath must contain the complete Session 04 endpoint set.')
PY

"$script_dir/connectivity-check.sh" --endpoint-matrix-path "$endpoint_matrix_path" --timeout-seconds "$timeout_seconds"
if ! cutover_record_path="$(resolve_external_record_path "$cutover_record_path")"; then
  die "CutoverRecordPath validation failed."
fi

alias_order=(foundry storage ai-search cosmos key-vault)
endpoint_aliases=(foundry storage-blob ai-search cosmos-sql key-vault)
resource_ids=("$foundry_resource_id" "$storage_resource_id" "$search_resource_id" "$cosmos_resource_id" "$key_vault_resource_id")
resource_types=(
  'Microsoft.CognitiveServices/accounts'
  'Microsoft.Storage/storageAccounts'
  'Microsoft.Search/searchServices'
  'Microsoft.DocumentDB/databaseAccounts'
  'Microsoft.KeyVault/vaults'
)
dns_suffix_sets=(
  '.services.ai.azure.com;.cognitiveservices.azure.com;.openai.azure.com'
  '.blob.core.windows.net'
  '.search.windows.net'
  '.documents.azure.com'
  '.vault.azure.net'
)

declare -A seen_ids=()
declare -A resource_names=()
declare -A prior_states=()
record_entries=()

for index in "${!alias_order[@]}"; do
  alias_name="${alias_order[$index]}"
  endpoint_alias="${endpoint_aliases[$index]}"
  resource_id="${resource_ids[$index]}"
  resource_type="${resource_types[$index]}"
  suffix_set="${dns_suffix_sets[$index]}"
  resource_json="$(run_capture az resource show --ids "$resource_id" --only-show-errors --output json)" || die "$alias_name lookup failed."
  inspection="$(PYTHON_JSON_INPUT="$resource_json" python3 - "$endpoint_matrix_path" "$alias_name" "$endpoint_alias" "$resource_id" "$resource_type" "$approved_subscription_id" "$resource_group_name" "$suffix_set" <<'PY'
import json
import os
import re
import sys
from pathlib import Path

endpoint_path, alias_name, endpoint_alias, expected_id, expected_type, approved_subscription_id, resource_group_name, suffix_set = sys.argv[1:9]
resource = json.loads(os.environ['PYTHON_JSON_INPUT'])
if str(resource.get('id', '')).lower() != expected_id.lower():
    raise SystemExit(f"{alias_name} lookup returned a different resource ID.")
match = re.fullmatch(r"/subscriptions/([^/]+)/resourceGroups/([^/]+)/providers/.+/[^/]+", str(resource.get('id', '')), re.IGNORECASE)
if not match:
    raise SystemExit(f"{alias_name} does not use a supported resource-group-scoped Azure resource ID.")
if match.group(1).lower() != approved_subscription_id.lower() or match.group(2).lower() != resource_group_name.lower():
    raise SystemExit(f"{alias_name} is outside the approved subscription or resource group.")
if str(resource.get('type', '')).lower() != expected_type.lower():
    raise SystemExit(f"{alias_name} must identify a {expected_type} resource.")
with open(endpoint_path, encoding='utf-8') as handle:
    endpoint_matrix = json.load(handle)
matches = [item for item in endpoint_matrix.get('endpoints', []) if str(item.get('alias', '')).lower() == endpoint_alias.lower()]
if len(matches) != 1:
    raise SystemExit(f"Endpoint matrix must contain exactly one {endpoint_alias} entry.")
fqdn = str(matches[0].get('fqdn', '')).strip().rstrip('.')
name = str(resource.get('name', ''))
expected_fqdns = {f"{name}{suffix}" for suffix in suffix_set.split(';') if suffix}
if fqdn.lower() not in {item.lower() for item in expected_fqdns}:
    raise SystemExit(f"{endpoint_alias} FQDN must match the selected resource name and service DNS suffix.")
prior_state = str(((resource.get('properties') or {}).get('publicNetworkAccess')) or '')
if not prior_state:
    raise SystemExit(f"{alias_name} does not expose properties.publicNetworkAccess through the current API.")
print('|'.join([name, str(resource.get('id', '')), prior_state]))
PY
)" || die "$inspection"
  IFS='|' read -r resource_name resolved_id prior_state <<<"$inspection"
  [[ -z "${seen_ids[${resolved_id,,}]:-}" ]] || die 'Each cutover alias must identify a unique resource.'
  seen_ids["${resolved_id,,}"]=1
  resource_names["$alias_name"]="$resource_name"
  prior_states["$alias_name"]="$prior_state"
  record_entries+=("$alias_name|$resolved_id|$prior_state|Disabled|NotStarted")
done

printf 'Cutover scope: five approved nonproduction services.\n'
printf '  Subscription:   %s\n' "$approved_subscription_id"
printf '  Resource group: %s\n' "$resource_group_name"
printf 'Restore state: %s\n' "$cutover_record_path"
if [[ "$confirm" != 'true' || "$what_if" == 'true' ]]; then
  printf 'No public-access changes were applied. Add --confirm to write the complete restore record, add the Session 04 marker, and disable public network access.\n'
  exit 0
fi

captured_at_utc="$(python3 - <<'PY'
import datetime
print(datetime.datetime.now(datetime.timezone.utc).isoformat().replace('+00:00', 'Z'))
PY
)"
write_cutover_record "$cutover_record_path" 'Cutover ready'

for index in "${!alias_order[@]}"; do
  alias_name="${alias_order[$index]}"
  resource_id="${resource_ids[$index]}"
  record_entries[$index]="$alias_name|$resource_id|${prior_states[$alias_name]}|Disabled|UpdatePending"
  write_cutover_record "$cutover_record_path" 'Cutover in progress'
  run_capture az tag update --resource-id "$resource_id" --operation Merge --tags networkControlSession=04-private-networking-dns --only-show-errors >/dev/null || die "Tag update failed for $alias_name."
  set_public_network_access "$alias_name" "$resource_id" "${resource_names[$alias_name]}" 'Disabled'
  record_entries[$index]="$alias_name|$resource_id|${prior_states[$alias_name]}|Disabled|Applied"
  write_cutover_record "$cutover_record_path" 'Cutover in progress'
done

write_cutover_record "$cutover_record_path" 'Cutover applied'
printf 'Cutover complete. Run connectivity-check.sh from this approved private host.\n'
