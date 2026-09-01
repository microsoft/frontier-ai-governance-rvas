#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
artifact_root="$(cd -- "$script_dir/../artifacts" && pwd)"
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
Usage: ./scripts/preflight.sh --approved-subscription-id <id> --resource-group-name <name> --network-operator-object-id <id> --dns-operator-object-id <id> --dns-scope-resource-id <id> [--dns-scope-resource-id <id> ...]

Validate Session 03 files, __REQUIRED_*__ decisions, approved Azure scope, service resource
identities, operator roles, resource providers, Bicep compilation, and the read-only group what-if preview.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}
register_temp() { temp_paths+=("$1"); }
make_temp_file() {
  local prefix="$1"
  local path
  path="$(mktemp "$tmpdir/${prefix}.XXXXXX")"
  register_temp "$path"
  printf '%s\n' "$path"
}
run_capture() {
  local stdout_file stderr_file status
  stdout_file="$(make_temp_file stdout)"
  stderr_file="$(make_temp_file stderr)"
  if "$@" >"$stdout_file" 2>"$stderr_file"; then
    cat "$stdout_file"
    return 0
  fi
  status=$?
  [[ -s "$stderr_file" ]] && cat "$stderr_file" >&2
  return "$status"
}
scan_unresolved_sentinels() {
  local artifact_dir="$1"
  shift
  python3 - "$artifact_dir" "$@" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
allowed = set(sys.argv[2:])
pattern = re.compile(r"__REQUIRED_[A-Z0-9_]+__")
found = set()
for path in root.rglob('*'):
    if not path.is_file():
        continue
    try:
        text = path.read_text(encoding='utf-8')
    except UnicodeDecodeError:
        continue
    found.update(pattern.findall(text))
if found:
    unresolved = sorted(found)
    unknown = [item for item in unresolved if item not in allowed]
    message = f"Resolve all Session 03 decisions before deployment: {', '.join(unresolved)}."
    if unknown:
        message += f" Add explicit checks for new sentinels: {', '.join(unknown)}."
    print(message, file=sys.stderr)
    raise SystemExit(1)
PY
}

approved_subscription_id=""
resource_group_name=""
network_operator_object_id=""
dns_operator_object_id=""
dns_scope_resource_ids=()

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
    --network-operator-object-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      network_operator_object_id="$2"
      shift 2
      ;;
    --dns-operator-object-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      dns_operator_object_id="$2"
      shift 2
      ;;
    --dns-scope-resource-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      dns_scope_resource_ids+=("${2%/}")
      shift 2
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
[[ -n "$network_operator_object_id" ]] || { usage >&2; die '--network-operator-object-id is required.'; }
[[ -n "$dns_operator_object_id" ]] || { usage >&2; die '--dns-operator-object-id is required.'; }
[[ ${#dns_scope_resource_ids[@]} -gt 0 ]] || { usage >&2; die 'At least one --dns-scope-resource-id is required.'; }
command -v az >/dev/null 2>&1 || die 'Azure CLI is required and was not found on PATH.'
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required and was not found on PATH.'

required_files=(
  'infra/network/main.bicep'
  'environments/sandbox.bicepparam'
)
for relative in "${required_files[@]}"; do
  [[ -f "$artifact_root/$relative" ]] || die "Required implementation file is missing: $relative"
done

scan_unresolved_sentinels "$artifact_root" \
  '__REQUIRED_COSMOS_RESOURCE_ID__' \
  '__REQUIRED_EXPIRY_DATE__' \
  '__REQUIRED_FOUNDRY_RESOURCE_ID__' \
  '__REQUIRED_KEY_VAULT_RESOURCE_ID__' \
  '__REQUIRED_LOCATION__' \
  '__REQUIRED_SEARCH_RESOURCE_ID__' \
  '__REQUIRED_SESSION01_PRIVATE_ENDPOINT_SUBNET_RESOURCE_ID__' \
  '__REQUIRED_SESSION01_VNET_RESOURCE_ID__' \
  '__REQUIRED_STORAGE_RESOURCE_ID__'

account_json="$(run_capture az account show --only-show-errors --output json)" || die 'Azure account lookup failed.'
current_subscription_id="$(PYTHON_JSON_INPUT="$account_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('id', ''))
PY
)"
[[ "$current_subscription_id" == "$approved_subscription_id" ]] || die 'Azure CLI is not using the approved subscription.'

resource_group_json="$(run_capture az group show --name "$resource_group_name" --only-show-errors --output json)" || die 'Implementation resource-group lookup failed.'
resource_group_location="$(PYTHON_JSON_INPUT="$resource_group_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('location', ''))
PY
)"
[[ -n "$resource_group_location" ]] || die 'The approved implementation resource group has no location.'

resource_group_id="$(PYTHON_JSON_INPUT="$resource_group_json" python3 - <<'PY'
import json
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('id', ''))
PY
)"

network_resource_lines="$(python3 - "$artifact_root/environments/sandbox.bicepparam" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
for parameter_name, expected_type in (
    ("virtualNetworkResourceId", "Microsoft.Network/virtualNetworks"),
    ("privateEndpointSubnetResourceId", "Microsoft.Network/virtualNetworks/subnets"),
):
    matches = re.findall(
        rf"^\s*param\s+{re.escape(parameter_name)}\s*=\s*'([^']+)'\s*$",
        text,
        flags=re.MULTILINE,
    )
    if len(matches) != 1:
        raise SystemExit(
            f"Parameter '{parameter_name}' must contain exactly one quoted Session 01 resource ID."
        )
    print(f"{parameter_name}\t{matches[0].strip().rstrip('/')}\t{expected_type}")
PY
)" || die 'Session 01 network resource ID validation failed.'
while IFS=$'\t' read -r parameter_name resource_id expected_type; do
  resource_json="$(run_capture az resource show --ids "$resource_id" --query '{id:id,type:type,tags:tags}' --only-show-errors --output json)" ||
    die "Session 01 network resource lookup failed for '$parameter_name'."
  PYTHON_JSON_INPUT="$resource_json" python3 - "$parameter_name" "$resource_id" "$expected_type" <<'PY'
import json
import os
import sys

parameter_name, expected_id, expected_type = sys.argv[1:]
resource = json.loads(os.environ["PYTHON_JSON_INPUT"])
if (
    str(resource.get("id", "")).rstrip("/").casefold() != expected_id.casefold()
    or str(resource.get("type", "")).casefold() != expected_type.casefold()
    or (
        parameter_name == "virtualNetworkResourceId"
        and str((resource.get("tags") or {}).get("implementationSession") or "") != "01-platform-baseline"
    )
):
    raise SystemExit(
        f"Parameter '{parameter_name}' must identify the Session 01-owned {expected_type}."
    )
PY
done <<<"$network_resource_lines"

check_exact_role() {
  local principal_id="$1"
  local role_id="$2"
  local scope="$3"
  local role_name="$4"
  local assignments_json
  assignments_json="$(run_capture az role assignment list \
    --assignee-object-id "$principal_id" \
    --fill-principal-name false \
    --scope "$scope" \
    --only-show-errors \
    --output json)" || die "$role_name assignment lookup failed."
  PYTHON_JSON_INPUT="$assignments_json" python3 - "$role_id" "$scope" "$principal_id" "$role_name" <<'PY'
import json
import os
import sys

role_id, scope, principal_id, role_name = sys.argv[1:]
assignments = json.loads(os.environ['PYTHON_JSON_INPUT'])
for assignment in assignments:
    definition_id = str(assignment.get('roleDefinitionId') or '')
    assignment_scope = str(assignment.get('scope') or '').rstrip('/')
    if definition_id.lower().endswith('/' + role_id.lower()) and assignment_scope.lower() == scope.rstrip('/').lower():
        raise SystemExit(0)
raise SystemExit(f"Principal '{principal_id}' lacks {role_name} on exact scope '{scope}'.")
PY
}

check_exact_role \
  "$network_operator_object_id" \
  '4d97b98b-1d4f-4787-a291-c67834d212e7' \
  "$resource_group_id" \
  'Network Contributor'

for dns_scope in "${dns_scope_resource_ids[@]}"; do
  [[ "$dns_scope" =~ ^/subscriptions/[^/]+/resourceGroups/[^/]+(/providers/Microsoft\\.Network/privateDnsZones/[^/]+)?$ ]] || \
    die 'Each --dns-scope-resource-id must be a resource-group ID or a private DNS zone ID.'
  check_exact_role \
    "$dns_operator_object_id" \
    'b12aa53e-6015-4669-85d0-8515ebb3ae7f' \
    "$dns_scope" \
    'Private DNS Zone Contributor'
done

printf 'Service resource resolution:\n'
resource_lines="$(python3 - "$artifact_root/environments/sandbox.bicepparam" "$approved_subscription_id" "$resource_group_name" <<'PY'
from pathlib import Path
import re
import sys

parameter_path, approved_subscription_id, resource_group_name = sys.argv[1:]
expected = [
    ('foundryResourceId', 'foundry', 'Microsoft.CognitiveServices/accounts'),
    ('storageResourceId', 'storage-blob', 'Microsoft.Storage/storageAccounts'),
    ('searchResourceId', 'ai-search', 'Microsoft.Search/searchServices'),
    ('cosmosResourceId', 'cosmos-sql', 'Microsoft.DocumentDB/databaseAccounts'),
    ('keyVaultResourceId', 'key-vault', 'Microsoft.KeyVault/vaults'),
]
text = Path(parameter_path).read_text(encoding='utf-8')
seen = set()
for parameter_name, alias, expected_type in expected:
    matches = re.findall(
        rf"^\s*param\s+{re.escape(parameter_name)}\s*=\s*'([^']+)'\s*$",
        text,
        flags=re.MULTILINE,
    )
    if len(matches) != 1:
        raise SystemExit(
            f"Parameter '{parameter_name}' must contain exactly one quoted service resource ID."
        )
    resource_id = matches[0].strip().rstrip('/')
    normalized_id = resource_id.casefold()
    if normalized_id in seen:
        raise SystemExit(
            f"Service resource IDs must be unique; '{resource_id}' is used more than once."
        )
    seen.add(normalized_id)
    id_match = re.fullmatch(
        r"/subscriptions/([^/]+)/resourceGroups/([^/]+)/providers/([^/]+/[^/]+)/([^/]+)",
        resource_id,
        flags=re.IGNORECASE,
    )
    if not id_match:
        raise SystemExit(
            f"Parameter '{parameter_name}' is not a top-level Azure service resource ID."
        )
    subscription_id, resource_group, resource_type, _ = id_match.groups()
    if subscription_id.casefold() != approved_subscription_id.casefold():
        raise SystemExit(
            f"Parameter '{parameter_name}' is outside the approved subscription."
        )
    if resource_group.casefold() != resource_group_name.casefold():
        raise SystemExit(
            f"Parameter '{parameter_name}' is outside resource group '{resource_group_name}'."
        )
    if resource_type.casefold() != expected_type.casefold():
        raise SystemExit(
            f"Parameter '{parameter_name}' must use resource type '{expected_type}'."
        )
    print(f'{alias}\t{resource_id}\t{expected_type}')
PY
)" || die 'Service resource ID validation failed.'

live_resource_ids=''
while IFS=$'\t' read -r service_alias resource_id expected_type; do
  [[ -n "$service_alias" ]] || continue
  live_resource_json="$(run_capture az resource show \
    --ids "$resource_id" \
    --query '{id:id,type:type,resourceGroup:resourceGroup}' \
    --only-show-errors \
    --output json)" || die "Service resource lookup failed for '$service_alias'."
  live_resource_id="$(
    PYTHON_JSON_INPUT="$live_resource_json" python3 - \
      "$service_alias" \
      "$resource_id" \
      "$expected_type" \
      "$resource_group_name" \
      "$live_resource_ids" <<'PY'
import json
import os
import sys

alias, expected_id, expected_type, expected_group, prior_ids = sys.argv[1:]
resource = json.loads(os.environ['PYTHON_JSON_INPUT'])
live_id = str(resource.get('id', '')).strip().rstrip('/')
if live_id.casefold() != expected_id.casefold():
    raise SystemExit(
        f"Service '{alias}' resolved to a different Azure resource ID."
    )
if str(resource.get('resourceGroup', '')).casefold() != expected_group.casefold():
    raise SystemExit(
        f"Service '{alias}' resolved outside resource group '{expected_group}'."
    )
if str(resource.get('type', '')).casefold() != expected_type.casefold():
    raise SystemExit(
        f"Service '{alias}' resolved as '{resource.get('type', '')}', "
        f"not '{expected_type}'."
    )
if live_id.casefold() in {item for item in prior_ids.split('|') if item}:
    raise SystemExit(
        f"Service '{alias}' resolved to an Azure resource already used by another endpoint."
    )
print(live_id)
PY
  )" || die "Service resource identity validation failed for '$service_alias'."
  normalized_live_id="${live_resource_id,,}"
  live_resource_ids="${live_resource_ids:+$live_resource_ids|}$normalized_live_id"
  printf '  %s -> %s (%s)\n' "$service_alias" "$live_resource_id" "$expected_type"
done <<<"$resource_lines"

providers_json="$(run_capture az provider list --query '[].{namespace:namespace,state:registrationState}' --only-show-errors --output json)" || die 'Resource-provider lookup failed.'
PYTHON_JSON_INPUT="$providers_json" python3 - <<'PY'
import json, sys
import os
required = {
    'Microsoft.App',
    'Microsoft.CognitiveServices',
    'Microsoft.DocumentDB',
    'Microsoft.KeyVault',
    'Microsoft.Network',
    'Microsoft.Search',
    'Microsoft.Storage',
}
providers = {item.get('namespace'): item.get('state') for item in json.loads(os.environ['PYTHON_JSON_INPUT'])}
for namespace in sorted(required):
    if providers.get(namespace) != 'Registered':
        raise SystemExit(f'Required resource provider is not registered: {namespace}')
PY

run_capture az bicep build --file "$artifact_root/infra/network/main.bicep" --stdout >/dev/null || die "Bicep build failed: $artifact_root/infra/network/main.bicep"

printf 'Preflight target:\n'
printf '  Subscription:   %s\n' "$approved_subscription_id"
printf '  Resource group: %s\n' "$resource_group_name"
printf '  Location:       %s\n' "$resource_group_location"
printf '  Approved scope: nonproduction subscription and network resource group\n'
printf 'Bicep deployment preview:\n'
preview_output="$(run_capture az deployment group what-if --resource-group "$resource_group_name" --name rvas-s03-preflight --template-file "$artifact_root/infra/network/main.bicep" --parameters "$artifact_root/environments/sandbox.bicepparam" --no-pretty-print --only-show-errors)" || die 'Bicep what-if failed.'
printf '%s\n' "$preview_output"
printf 'PASS: Session 03 files, decisions, Azure scope, operator roles, service resources, providers, Bicep syntax, and what-if are ready.\n'
