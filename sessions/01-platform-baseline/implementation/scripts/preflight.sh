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
Usage: ./scripts/preflight.sh --resource-group-name <name> [--deployment-name <name>] [--artifacts-path <path>]

Validate Session 01 artifacts, required __REQUIRED_*__ decisions, the approved sandbox subscription and resource group,
provider registrations, Bicep compilation, and the read-only group what-if preview.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

register_temp() {
  temp_paths+=("$1")
}

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

require_command() {
  local name="$1"
  local message="$2"
  command -v "$name" >/dev/null 2>&1 || die "$message"
}

version_ge() {
  python3 - "$1" "$2" <<'PY'
import re
import sys

def parse(raw: str) -> list[int]:
    parts = []
    for token in re.split(r"[.-]", raw.strip()):
        match = re.match(r"(\d+)", token)
        parts.append(int(match.group(1)) if match else 0)
    while len(parts) < 3:
        parts.append(0)
    return parts

sys.exit(0 if parse(sys.argv[1]) >= parse(sys.argv[2]) else 1)
PY
}

require_az_min_version() {
  local minimum="$1"
  local version_json current
  version_json="$(run_capture az version --output json --only-show-errors)" || die "Azure CLI $minimum or later is required."
  current="$(PYTHON_JSON_INPUT="$version_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('azure-cli', '0.0.0'))
PY
)"
  version_ge "$current" "$minimum" || die "Azure CLI $minimum or later is required; found $current."
}

require_bicep_min_version() {
  local minimum="$1"
  local raw current
  raw="$(run_capture az bicep version)" || die "Bicep $minimum or later is required."
  current="$(PYTHON_TEXT_INPUT="$raw" python3 - <<'PY'
import re, sys
import os
text = os.environ['PYTHON_TEXT_INPUT']
match = re.search(r'(\d+\.\d+\.\d+)', text)
if not match:
    raise SystemExit(1)
print(match.group(1))
PY
)" || die "Bicep $minimum or later is required."
  version_ge "$current" "$minimum" || die "Bicep $minimum or later is required; found $current."
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
for path in root.rglob("*"):
    if not path.is_file():
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue
    found.update(pattern.findall(text))
if found:
    unresolved = sorted(found)
    unknown = [item for item in unresolved if item not in allowed]
    message = f"Resolve customer decisions before deployment: {', '.join(unresolved)}."
    if unknown:
        message += f" Add checks for new sentinels: {', '.join(unknown)}."
    print(message, file=sys.stderr)
    raise SystemExit(1)
PY
}

validate_parameters() {
  local parameter_file="$1"
  python3 - "$parameter_file" <<'PY'
from pathlib import Path
import datetime as dt
import re
import sys

text = Path(sys.argv[1]).read_text(encoding='utf-8')
expiry_match = re.search(r"(?m)^\s*param\s+expiryDate\s*=\s*'([^']+)'\s*$", text)
if not expiry_match:
    print('sandbox.bicepparam must assign expiryDate as a quoted ISO date.', file=sys.stderr)
    raise SystemExit(1)
try:
    dt.datetime.strptime(expiry_match.group(1), '%Y-%m-%d')
except ValueError:
    print('expiryDate must use ISO yyyy-MM-dd format.', file=sys.stderr)
    raise SystemExit(1)
network_match = re.search(r"(?m)^\s*param\s+publicNetworkAccess\s*=\s*'([^']+)'\s*$", text)
if not network_match or network_match.group(1) not in {'Enabled', 'Disabled'}:
    print('publicNetworkAccess must be either Enabled or Disabled.', file=sys.stderr)
    raise SystemExit(1)
PY
}

resource_group_name=""
deployment_name="rvas-s01-baseline"
artifacts_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group-name)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      resource_group_name="$2"
      shift 2
      ;;
    --deployment-name)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      deployment_name="$2"
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
[[ -d "$artifacts_path" ]] || die "Implementation artifacts folder is missing: $artifacts_path"

require_command az 'Azure CLI is required. Install it through the customer-managed tool process.'
require_command python3 'Python 3 is required and was not found on PATH.'
require_az_min_version '2.47.0'
require_bicep_min_version '0.18.4'

required_files=(
  'infra/foundry/main.bicep'
  'environments/sandbox.bicepparam'
  'decisions/resource-model.md'
)
for relative in "${required_files[@]}"; do
  [[ -f "$artifacts_path/$relative" ]] || die "Required implementation file is missing: $relative"
done

scan_unresolved_sentinels "$artifacts_path" \
  '__REQUIRED_AZURE_REGION__' \
  '__REQUIRED_PUBLIC_NETWORK_ACCESS__' \
  '__REQUIRED_BUSINESS_OWNER__' \
  '__REQUIRED_TECHNICAL_OWNER__' \
  '__REQUIRED_DATA_CLASSIFICATION__' \
  '__REQUIRED_CRITICALITY__' \
  '__REQUIRED_COST_CENTER__' \
  '__REQUIRED_EXPIRY_DATE__' \
  '__REQUIRED_RESOURCE_MODEL_DECISION__' \
  '__REQUIRED_CUSTOMER_SYSTEM_REFERENCE__'

parameters_file="$artifacts_path/environments/sandbox.bicepparam"
validate_parameters "$parameters_file"

account_json="$(run_capture az account show --only-show-errors --output json)" || die 'Azure account lookup failed.'
group_json="$(run_capture az group show --name "$resource_group_name" --query '{id:id,location:location,marker:tags.implementationSession}' --only-show-errors --output json)" || die 'The approved sandbox resource group lookup failed.'

group_marker="$(PYTHON_JSON_INPUT="$group_json" python3 - <<'PY'
import json, sys
import os
print((json.loads(os.environ['PYTHON_JSON_INPUT']).get('marker') or '').strip())
PY
)"
[[ "$group_marker" == '01-platform-baseline' ]] || die "Resource group '$resource_group_name' must have implementationSession=01-platform-baseline."

for provider in Microsoft.CognitiveServices Microsoft.Insights Microsoft.OperationalInsights; do
  state="$(run_capture az provider show --namespace "$provider" --query registrationState --only-show-errors --output tsv)" || die "Provider lookup failed for $provider."
  state="${state//$'\r'/}"
  [[ "$state" == 'Registered' ]] || die "Provider $provider is '$state'. Register it only through the customer-approved change process."
done

template_file="$artifacts_path/infra/foundry/main.bicep"
run_capture az bicep build --file "$template_file" --stdout >/dev/null || die 'Bicep build failed for the Foundry baseline.'

subscription_name="$(PYTHON_JSON_INPUT="$account_json" python3 - <<'PY'
import json, sys
import os
account = json.loads(os.environ['PYTHON_JSON_INPUT'])
print(account.get('name', ''))
PY
)"
subscription_id="$(PYTHON_JSON_INPUT="$account_json" python3 - <<'PY'
import json, sys
import os
account = json.loads(os.environ['PYTHON_JSON_INPUT'])
print(account.get('id', ''))
PY
)"
group_location="$(PYTHON_JSON_INPUT="$group_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('location', ''))
PY
)"

printf 'Preflight target:\n'
printf '  Subscription:   %s (%s)\n' "$subscription_name" "$subscription_id"
printf '  Resource group: %s\n' "$resource_group_name"
printf '  Location:       %s\n' "$group_location"
printf '  Marker:         implementationSession=01-platform-baseline\n'
printf '  Deployment:     %s\n\n' "$deployment_name"
printf 'Bicep deployment preview:\n'

preview_output="$(run_capture az deployment group what-if --resource-group "$resource_group_name" --name "$deployment_name" --parameters "$parameters_file" --result-format ResourceIdOnly --only-show-errors)" || die 'Bicep deployment preview failed.'
printf '%s\n' "$preview_output"
printf 'READY: tools, files, decisions, approved sandbox subscription and resource group, and deployment preview are available.\n'
