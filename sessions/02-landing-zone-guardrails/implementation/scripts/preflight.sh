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
Usage: ./scripts/preflight.sh --resource-group-name <name> --deployment-location <region> [--artifacts-path <path>]

Validate Session 02 files, __REQUIRED_*__ decisions, built-in policy IDs in the current shell,
approved sandbox subscription and resource-group assignment scope, Bicep compilation, and available what-if previews.
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
deferred = set(sys.argv[2:])
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
actionable = sorted(found - deferred)
if actionable:
    message = f"Resolve customer decisions before deployment: {', '.join(actionable)}."
    print(message, file=sys.stderr)
    raise SystemExit(1)
PY
}

resource_group_name=""
deployment_location=""
artifacts_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group-name)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      resource_group_name="$2"
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
[[ -d "$artifacts_path" ]] || die "Required implementation artifacts folder is missing: $artifacts_path"
command -v az >/dev/null 2>&1 || die 'Azure CLI is required. Install it through the customer-managed tool process.'
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required and was not found on PATH.'

required_files=(
  'policy/initiative.bicep'
  'policy/assignment.bicep'
  'policy/guardrail-settings.json'
  'environments/initiative.bicepparam'
  'environments/sandbox.bicepparam'
  'governance/change-reference.md'
)
for relative in "${required_files[@]}"; do
  [[ -f "$artifacts_path/$relative" ]] || die "Required implementation file is missing: $relative"
done

for name in RVAS_ALLOWED_LOCATIONS_POLICY_ID RVAS_REQUIRE_TAG_POLICY_ID; do
  [[ -n "${!name:-}" ]] || die "Set $name from resolve-builtins.sh output before deployment."
done

required_sentinels=(
  '__REQUIRED_PRIMARY_REGION__'
  '__REQUIRED_SECONDARY_REGION__'
  '__REQUIRED_CHANGE_REFERENCE__'
  '__REQUIRED_POLICY_OWNER__'
  '__REQUIRED_RISK_REFERENCE_OR_NONE__'
)
scan_unresolved_sentinels "$artifacts_path"

python3 - \
  "$artifacts_path/policy/guardrail-settings.json" \
  "$artifacts_path/environments/initiative.bicepparam" \
  "$artifacts_path/environments/sandbox.bicepparam" <<'PY'
import json
from pathlib import Path
import re
import sys

settings_path = Path(sys.argv[1])
settings = json.loads(settings_path.read_text(encoding='utf-8'))
tags = [str(item).strip() for item in settings.get('requiredTagNames', [])]
if (
    settings.get('implementationSession') != '02-landing-zone-guardrails'
    or not tags
    or any(not tag for tag in tags)
    or len(set(tags)) != len(tags)
):
    raise SystemExit(
        'policy/guardrail-settings.json must contain one nonempty, unique requiredTagNames list and the Session 02 marker.'
    )
for raw_path in sys.argv[2:]:
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

for file in initiative.bicep assignment.bicep; do
  run_capture az bicep build --file "$artifacts_path/policy/$file" --stdout >/dev/null || die "Bicep build failed: policy/$file"
done

subscription_json="$(run_capture az account show --query '{name:name,id:id}' --only-show-errors --output json)" || die 'Azure account check failed.'
scope="$(run_capture az group show --name "$resource_group_name" --query id --only-show-errors --output tsv)" || die "Approved resource group lookup failed: $resource_group_name"
scope="${scope//$'\r'/}"
[[ -n "$scope" ]] || die "Approved resource group lookup failed: $resource_group_name"
subscription_name="$(PYTHON_JSON_INPUT="$subscription_json" python3 - <<'PY'
import json, sys
import os
print(json.loads(os.environ['PYTHON_JSON_INPUT']).get('name', ''))
PY
)"

printf 'Preflight target:\n'
printf '  Subscription:   %s\n' "$subscription_name"
printf '  Assignment:     %s\n' "$scope"
printf '  Initiative:     current subscription\n'

initiative_preview="$(run_capture az deployment sub what-if --location "$deployment_location" --name rvas-s02-initiative-preflight --parameters "$artifacts_path/environments/initiative.bicepparam" --result-format ResourceIdOnly --only-show-errors)" || die 'Initiative preview failed.'
printf 'Initiative preview:\n%s\n' "$initiative_preview"

if [[ -z "${RVAS_INITIATIVE_DEFINITION_ID:-}" ]]; then
  printf 'Assignment preview pending. Set RVAS_INITIATIVE_DEFINITION_ID after the initiative deployment, then rerun preflight.\n'
else
  assignment_preview="$(run_capture az deployment group what-if --resource-group "$resource_group_name" --name rvas-s02-assignment-preflight --parameters "$artifacts_path/environments/sandbox.bicepparam" --result-format ResourceIdOnly --only-show-errors)" || die 'Assignment preview failed.'
  printf 'Assignment preview:\n%s\n' "$assignment_preview"
fi

printf 'PASS: tools, files, approved sandbox subscription and resource-group assignment scope, decisions, syntax, and available deployment previews are ready.\n'
