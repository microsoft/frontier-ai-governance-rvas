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
Usage: ./scripts/preflight.sh --resource-group-name <name> --deployment-location <region> [--deployment-name <name>] [--artifacts-path <path>] [--confirm-inherited-policy-review]

Validate Session 01 artifacts, required __REQUIRED_*__ decisions, resolved built-in policy IDs in
the current shell, the approved sandbox subscription and resource group, provider registrations,
inherited policy review, Bicep compilation for the Foundry baseline and the policy initiative and
assignment, and the available what-if previews.
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
import json
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
import re
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

validate_foundry_parameters() {
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
pattern_match = re.search(r"(?m)^\s*param\s+networkPattern\s*=\s*'([^']+)'\s*$", text)
if not pattern_match or pattern_match.group(1) not in {'public', 'public-private-inbound', 'byo-vnet'}:
    print('networkPattern must be public, public-private-inbound, or byo-vnet.', file=sys.stderr)
    raise SystemExit(1)
subnet_match = re.search(r"(?m)^\s*param\s+agentSubnetResourceId\s*=\s*'([^']*)'\s*$", text)
if pattern_match.group(1) == 'byo-vnet' and (not subnet_match or not subnet_match.group(1).strip()):
    print('byo-vnet requires agentSubnetResourceId from the approved delegated subnet.', file=sys.stderr)
    raise SystemExit(1)
PY
}

validate_policy_settings() {
  local implementation_session="$1"
  shift
  python3 - "$implementation_session" "$@" <<'PY'
import json
from pathlib import Path
import re
import sys

implementation_session = sys.argv[1]
settings_path = Path(sys.argv[2])
settings = json.loads(settings_path.read_text(encoding='utf-8'))
tags = [str(item).strip() for item in settings.get('requiredTagNames', [])]
if (
    settings.get('implementationSession') != implementation_session
    or not tags
    or any(not tag for tag in tags)
    or len(set(tags)) != len(tags)
):
    raise SystemExit(
        f'policy/guardrail-settings.json must contain one nonempty, unique requiredTagNames list and the {implementation_session} marker.'
    )
for raw_path in sys.argv[3:]:
    path = Path(raw_path)
    text = path.read_text(encoding='utf-8')
    if (
        "loadJsonContent('../policy/guardrail-settings.json')" not in text
        or not re.search(r'(?m)^\s*param\s+requiredTagNames\s*=\s*settings\.requiredTagNames\s*$', text)
    ):
        raise SystemExit(
            f'{path.name} must load requiredTagNames from policy/guardrail-settings.json.'
        )
PY
}

resource_group_name=""
deployment_name="rvas-s01-baseline"
deployment_location=""
artifacts_path=""
confirm_inherited_policy_review=false

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
    --deployment-location)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      deployment_location="$2"
      shift 2
      ;;
    --artifacts-path)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      artifacts_path="$2"
      shift 2
      ;;
    --confirm-inherited-policy-review)
      confirm_inherited_policy_review=true
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

[[ -n "$resource_group_name" ]] || { usage >&2; die '--resource-group-name is required.'; }
[[ -n "$deployment_location" ]] || { usage >&2; die '--deployment-location is required.'; }

if [[ -z "$artifacts_path" ]]; then
  artifacts_path="$script_dir/../artifacts"
fi
[[ -d "$artifacts_path" ]] || die "Implementation artifacts folder is missing: $artifacts_path"

require_command az 'Azure CLI is required. Install it through the customer-managed tool process.'
require_command python3 'Python 3 is required and was not found on PATH.'
require_az_min_version '2.47.0'
require_bicep_min_version '0.18.4'

implementation_session='01-platform-baseline'

required_files=(
  'infra/foundry/main.bicep'
  'infra/network/main.bicep'
  'environments/sandbox.bicepparam'
  'environments/network-foundation.bicepparam'
  'policy/initiative.bicep'
  'policy/assignment.bicep'
  'policy/guardrail-settings.json'
  'environments/initiative.bicepparam'
  'environments/policy-assignment.bicepparam'
)
for relative in "${required_files[@]}"; do
  [[ -f "$artifacts_path/$relative" ]] || die "Required implementation file is missing: $relative"
done

for name in RVAS_ALLOWED_LOCATIONS_POLICY_ID RVAS_REQUIRE_TAG_POLICY_ID; do
  [[ -n "${!name:-}" ]] || die "Set $name from resolve-builtins.sh output before deployment."
done

scan_unresolved_sentinels "$artifacts_path" \
  '__REQUIRED_AZURE_REGION__' \
  '__REQUIRED_NETWORK_PATTERN__' \
  '__REQUIRED_VNET_NAME__' \
  '__REQUIRED_VNET_CIDR__' \
  '__REQUIRED_AGENT_SUBNET_CIDR__' \
  '__REQUIRED_PRIVATE_ENDPOINT_SUBNET_CIDR__' \
  '__REQUIRED_FIREWALL_PRIVATE_IP__' \
  '__REQUIRED_PUBLIC_NETWORK_ACCESS__' \
  '__REQUIRED_BUSINESS_OWNER__' \
  '__REQUIRED_TECHNICAL_OWNER__' \
  '__REQUIRED_DATA_CLASSIFICATION__' \
  '__REQUIRED_CRITICALITY__' \
  '__REQUIRED_COST_CENTER__' \
  '__REQUIRED_EXPIRY_DATE__' \
  '__REQUIRED_PRIMARY_REGION__' \
  '__REQUIRED_SECONDARY_REGION__' \

foundry_parameters_file="$artifacts_path/environments/sandbox.bicepparam"
validate_foundry_parameters "$foundry_parameters_file"

validate_policy_settings \
  "$implementation_session" \
  "$artifacts_path/policy/guardrail-settings.json" \
  "$artifacts_path/environments/initiative.bicepparam" \
  "$artifacts_path/environments/policy-assignment.bicepparam"

account_json="$(run_capture az account show --only-show-errors --output json)" || die 'Azure account lookup failed.'
group_json="$(run_capture az group show --name "$resource_group_name" --query '{id:id,location:location,marker:tags.implementationSession}' --only-show-errors --output json)" || die 'The approved sandbox resource group lookup failed.'

group_marker="$(PYTHON_JSON_INPUT="$group_json" python3 - <<'PY'
import json
import os
print((json.loads(os.environ['PYTHON_JSON_INPUT']).get('marker') or '').strip())
PY
)"
[[ "$group_marker" == "$implementation_session" ]] || die "Resource group '$resource_group_name' must have implementationSession=$implementation_session."

policy_assignments_json="$(run_capture az policy assignment list \
  --scope "$(
    PYTHON_JSON_INPUT="$group_json" python3 - <<'PY'
import json
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('id', ''))
PY
  )" \
  --disable-scope-strict-match true \
  --query '[].{name:name,displayName:displayName,scope:scope,enforcementMode:enforcementMode,policyDefinitionId:policyDefinitionId}' \
  --only-show-errors \
  --output json)" || die 'Applicable policy-assignment lookup failed.'
inherited_assignments="$(
  PYTHON_JSON_INPUT="$policy_assignments_json" GROUP_JSON_INPUT="$group_json" python3 - <<'PY'
import json
import os

group_id = str(json.loads(os.environ['GROUP_JSON_INPUT']).get('id', '')).rstrip('/')
assignments = json.loads(os.environ['PYTHON_JSON_INPUT'])
for assignment in assignments:
    scope = str(assignment.get('scope') or '').rstrip('/')
    if scope and scope.casefold() != group_id.casefold() and not scope.casefold().startswith(group_id.casefold() + '/'):
        print(
            '{}\t{}\t{}\t{}\t{}'.format(
                assignment.get('displayName') or '',
                assignment.get('name') or '',
                scope,
                assignment.get('enforcementMode') or '',
                assignment.get('policyDefinitionId') or '',
            )
        )
PY
)"
if [[ -n "$inherited_assignments" ]]; then
  printf 'Inherited policy assignments:\n'
  printf '%s\n' "$inherited_assignments"
  "$confirm_inherited_policy_review" || die 'Inherited policy assignments apply to the sandbox resource group. Review their effects and exemptions with the cloud platform owner, then rerun with --confirm-inherited-policy-review.'
fi

for provider in Microsoft.CognitiveServices Microsoft.Insights Microsoft.OperationalInsights Microsoft.PolicyInsights Microsoft.Network Microsoft.App; do
  state="$(run_capture az provider show --namespace "$provider" --query registrationState --only-show-errors --output tsv)" || die "Provider lookup failed for $provider."
  state="${state//$'\r'/}"
  [[ "$state" == 'Registered' ]] || die "Provider $provider is '$state'. Register it only through the customer-approved change process."
done

template_file="$artifacts_path/infra/foundry/main.bicep"
run_capture az bicep build --file "$template_file" --stdout >/dev/null || die 'Bicep build failed for the Foundry baseline.'
run_capture az bicep build --file "$artifacts_path/infra/network/main.bicep" --stdout >/dev/null || die 'Bicep build failed for the BYO VNet foundation.'
for file in initiative.bicep assignment.bicep; do
  run_capture az bicep build --file "$artifacts_path/policy/$file" --stdout >/dev/null || die "Bicep build failed: policy/$file"
done

subscription_name="$(PYTHON_JSON_INPUT="$account_json" python3 - <<'PY'
import json
import os
account = json.loads(os.environ['PYTHON_JSON_INPUT'])
print(account.get('name', ''))
PY
)"
subscription_id="$(PYTHON_JSON_INPUT="$account_json" python3 - <<'PY'
import json
import os
account = json.loads(os.environ['PYTHON_JSON_INPUT'])
print(account.get('id', ''))
PY
)"
group_location="$(PYTHON_JSON_INPUT="$group_json" python3 - <<'PY'
import json
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('location', ''))
PY
)"

printf 'Preflight target:\n'
printf '  Subscription:   %s (%s)\n' "$subscription_name" "$subscription_id"
printf '  Resource group: %s\n' "$resource_group_name"
printf '  Location:       %s\n' "$group_location"
printf '  Marker:         implementationSession=%s\n' "$implementation_session"
printf '  Deployment:     %s\n\n' "$deployment_name"
printf 'Foundry baseline deployment preview:\n'

foundry_preview="$(run_capture az deployment group what-if --resource-group "$resource_group_name" --name "$deployment_name" --parameters "$foundry_parameters_file" --result-format ResourceIdOnly --only-show-errors)" || die 'Foundry baseline deployment preview failed.'
printf '%s\n' "$foundry_preview"

printf '\nPolicy initiative deployment preview:\n'
initiative_preview="$(run_capture az deployment sub what-if --location "$deployment_location" --name rvas-s01-guardrails-initiative-preflight --parameters "$artifacts_path/environments/initiative.bicepparam" --result-format ResourceIdOnly --only-show-errors)" || die 'Initiative preview failed.'
printf '%s\n' "$initiative_preview"

if [[ -z "${RVAS_INITIATIVE_DEFINITION_ID:-}" ]]; then
  printf 'Assignment preview pending. Set RVAS_INITIATIVE_DEFINITION_ID after the initiative deployment, then rerun preflight.\n'
else
  printf '\nPolicy assignment deployment preview:\n'
  assignment_preview="$(run_capture az deployment group what-if --resource-group "$resource_group_name" --name rvas-s01-guardrails-assignment-preflight --parameters "$artifacts_path/environments/policy-assignment.bicepparam" --result-format ResourceIdOnly --only-show-errors)" || die 'Assignment preview failed.'
  printf '%s\n' "$assignment_preview"
fi

printf '\nREADY: tools, files, decisions, approved sandbox subscription and resource group, inherited-policy review, provider registrations, and every available deployment preview are ready.\n'
