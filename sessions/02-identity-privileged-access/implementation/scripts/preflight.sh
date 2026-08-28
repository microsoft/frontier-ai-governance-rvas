#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
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
Usage: ./scripts/preflight.sh --resource-group-name <name> [--artifacts-path <path>]

Validate Session 02 files, __REQUIRED_*__ identity and PIM decisions, the approved nonproduction resource group,
semantic built-in role resolution, and both implementation Bicep templates.
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
  local artifact_root="$1"
  shift
  python3 - "$artifact_root" "$@" <<'PY'
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
    message = f"Resolve identity decisions before deployment: {', '.join(unresolved)}."
    if unknown:
        message += f" Add checks for new sentinels: {', '.join(unknown)}."
    print(message, file=sys.stderr)
    raise SystemExit(1)
PY
}

resource_group_name=""
artifacts_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group-name)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      resource_group_name="$2"
      shift 2
      ;;
    --artifacts-path)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      artifacts_path="$2"
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

[[ -n "$resource_group_name" ]] || { usage >&2; die '--resource-group-name is required.'; }

if [[ -z "$artifacts_path" ]]; then
  artifacts_path="$script_dir/../artifacts"
fi
[[ -d "$artifacts_path" ]] || die "Required implementation artifacts folder is missing: $artifacts_path"
command -v az >/dev/null 2>&1 || die 'Azure CLI is required. Install it through the customer-managed tool process.'
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required and was not found on PATH.'

required_files=(
  'identity/human-role-assignments.bicep'
  'identity/workload-identity.bicep'
  'identity/role-definitions.json'
  'identity/role-to-task-matrix.md'
  'pim/pim-change-reference.md'
)
for relative in "${required_files[@]}"; do
  [[ -f "$artifacts_path/$relative" ]] || die "Required implementation file is missing: $relative"
done

scan_unresolved_sentinels "$artifacts_path" \
  '__REQUIRED_GITHUB_ENVIRONMENT__' \
  '__REQUIRED_PIM_CHANGE_REFERENCE__' \
  '__REQUIRED_PIM_OWNER__' \
  '__REQUIRED_PLATFORM_ADMINISTRATOR_GROUP_REFERENCE__'

account_json="$(run_capture az account show --query '{subscriptionId:id,subscriptionName:name,tenantId:tenantId}' --only-show-errors --output json)" || die 'Azure account lookup failed.'
group_json="$(run_capture az group show --name "$resource_group_name" --query '{id:id,location:location}' --only-show-errors --output json)" || die "The approved nonproduction resource group lookup failed for '$resource_group_name'."

subscription_name="$(PYTHON_JSON_INPUT="$account_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('subscriptionName', ''))
PY
)"
subscription_id="$(PYTHON_JSON_INPUT="$account_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('subscriptionId', ''))
PY
)"
group_id="$(PYTHON_JSON_INPUT="$group_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('id', ''))
PY
)"
group_location="$(PYTHON_JSON_INPUT="$group_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('location', ''))
PY
)"

printf 'Implementation target:\n'
printf '  Subscription:   %s (%s)\n' "$subscription_name" "$subscription_id"
printf '  Resource group: %s\n' "$group_id"
printf '  Location:       %s\n' "$group_location"

role_definitions_path="$artifacts_path/identity/role-definitions.json"
printf 'Role resolution:\n'
role_lines="$(python3 - "$role_definitions_path" <<'PY'
import json
from pathlib import Path
import sys
import uuid

path = Path(sys.argv[1])
document = json.loads(path.read_text(encoding='utf-8'))
required = [
    'foundryUser',
    'foundryProjectManager',
    'foundryAccountOwner',
    'reader',
    'cognitiveServicesUser',
    'storageBlobDataReader',
]
expected = {
    'foundryUser': (
        '53ca6127-db72-4b80-b1b0-d745d6d5456d',
        ('Foundry User', 'Azure AI User'),
    ),
    'foundryProjectManager': (
        'eadc314b-1a2d-4efa-be10-5d325db5065e',
        ('Foundry Project Manager', 'Azure AI Project Manager'),
    ),
    'foundryAccountOwner': (
        'e47c6f54-e4a2-4754-9501-8e0985b135e1',
        ('Foundry Account Owner', 'Azure AI Account Owner'),
    ),
    'reader': (
        'acdd72a7-3385-48ef-bd42-f606fba81ae7',
        ('Reader',),
    ),
    'cognitiveServicesUser': (
        'a97b65f3-24c7-4388-baec-2e87135dc908',
        ('Cognitive Services User',),
    ),
    'storageBlobDataReader': (
        '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1',
        ('Storage Blob Data Reader',),
    ),
}
if document.get('implementationSession') != '02-identity-privileged-access':
    raise SystemExit('role-definitions.json has the wrong implementation marker.')
roles = document.get('roles') or {}
if set(roles) != set(required):
    raise SystemExit('role-definitions.json must contain the six documented role keys.')
for key in required:
    role_id = str((roles.get(key) or {}).get('id') or '')
    try:
        uuid.UUID(role_id)
    except ValueError:
        raise SystemExit(f"Role '{key}' has an invalid ID in role-definitions.json.")
    expected_id, accepted_names = expected[key]
    if role_id.lower() != expected_id:
        raise SystemExit(
            f"Role '{key}' must use built-in role ID '{expected_id}', not '{role_id}'."
        )
    print(f"{key}\t{role_id}\t{'|'.join(accepted_names)}")
PY
)" || die 'Could not validate role-definitions.json.'
while IFS=$'\t' read -r role_key role_id accepted_names; do
  role_json="$(run_capture az role definition list --name "$role_id" --query '[0].{id:name,displayName:roleName,roleType:roleType}' --output json --only-show-errors)" || die "Role lookup failed for '$role_key'."
  PYTHON_JSON_INPUT="$role_json" python3 - "$role_key" "$role_id" "$accepted_names" <<'PY'
import json
import os
import sys

key, expected_id, accepted_names = sys.argv[1], sys.argv[2], sys.argv[3].split('|')
role = json.loads(os.environ['PYTHON_JSON_INPUT'])
if not role or str(role.get('id', '')).lower() != expected_id.lower():
    raise SystemExit(f"Role '{key}' did not resolve to the configured ID.")
if str(role.get('roleType', '')).lower() != 'builtinrole':
    raise SystemExit(
        f"Role '{key}' must resolve to role type 'BuiltInRole', not "
        f"'{role.get('roleType', '')}'."
    )
if role.get('displayName') not in accepted_names:
    raise SystemExit(
        f"Role '{key}' resolved to '{role.get('displayName', '')}'; "
        f"expected one of {accepted_names}."
    )
print(f"  {key} -> {role.get('displayName', '')} ({expected_id}, BuiltInRole)")
PY
done <<<"$role_lines"

for file in human-role-assignments.bicep workload-identity.bicep; do
  run_capture az bicep build --file "$artifacts_path/identity/$file" --stdout >/dev/null || die "Bicep build failed: identity/$file"
done
printf 'PASS: Session 02 tools, files, decisions, approved nonproduction resource group, role definitions, and Bicep syntax are ready.\n'
