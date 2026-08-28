#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/rehearse-failover.sh --approved-scope <resource-group-id> --change-record-id <record> [--confirm]

Runs the Session 14 Bash failover rehearsal. The script validates the approved scope and required
implementationSession marker, checks the named secondary path, previews the route move, requires
explicit confirmation, moves only the named selector, and validates the active secondary result.

Required options:
  --approved-scope <resource-group-id>    Exact approved Azure resource-group scope.
  --change-record-id <record>             Approved customer change record.

Optional options:
  --confirm                               Skip the interactive confirmation prompt after reviewing
                                          the built-in preview output.
  --help                                  Show this help text.

Do not pass secrets as arguments. Use the approved Azure sign-in context and customer-owned Bash
health and routing scripts.
USAGE
}

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "Required command is unavailable: $command_name"
  fi
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Required implementation file is missing: $path"
}

validate_scope() {
  local value="$1"
  [[ "$value" =~ ^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$ ]] || fail 'Approved scope must be an exact Azure resource-group resource ID.'
}

json_get() {
  local json_path="$1"
  local dotted_path="$2"
  python - "$json_path" "$dotted_path" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
keys = sys.argv[2].split('.')
value = json.loads(path.read_text())
for key in keys:
    value = value[key]
if isinstance(value, bool):
    print('true' if value else 'false')
elif value is None:
    print('')
else:
    print(value)
PY
}

resolve_repo_file() {
  local repo_root="$1"
  local relative_path="$2"
  python - "$repo_root" "$relative_path" <<'PY'
import os
import sys
from pathlib import Path

repo_root = Path(sys.argv[1]).resolve()
relative = sys.argv[2]
candidate = (repo_root / relative).resolve()
if os.path.isabs(relative) or not str(candidate).startswith(str(repo_root) + os.sep):
    raise SystemExit(1)
print(candidate)
PY
}

validate_health_result() {
  local result_path="$1"
  local expected_status="$2"
  local expected_region="$3"
  local parameters_path="$4"
  python - "$result_path" "$expected_status" "$expected_region" "$parameters_path" <<'PY'
import json
import sys
from pathlib import Path

result = json.loads(Path(sys.argv[1]).read_text())
expected_status = sys.argv[2]
expected_region = sys.argv[3]
parameters = json.loads(Path(sys.argv[4]).read_text())['parameters']
value = lambda name: parameters[name]['value']
checks = {
    'implementationSession': '14-agent-fleet-multiregion-rehearsal',
    'status': expected_status,
    'region': expected_region,
    'agentVersion': value('agentVersion'),
    'agentIdentityId': value('agentIdentityId'),
    'gatewayPolicyVersion': value('gatewayPolicyVersion'),
    'endpointStatus': 'passed',
    'identityStatus': 'passed',
    'policyStatus': 'passed',
    'traceStatus': 'passed',
}
for field, expected in checks.items():
    actual = result.get(field)
    if actual != expected:
        raise SystemExit(f'Health result field {field!r} was {actual!r}; expected {expected!r}.')
if result.get('sensitiveInputPresent') is not False:
    raise SystemExit('Health result indicates sensitive input in the runtime path.')
PY
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
control_path="$artifact_root/control-definition.json"
preflight_path="$script_dir/preflight.sh"
temp_dir="$(mktemp -d)"
secondary_readiness_path="$temp_dir/secondary-ready.json"
secondary_active_path="$temp_dir/secondary-active.json"
trap 'rm -rf "$temp_dir"' EXIT

approved_scope=''
change_record_id=''
confirm_wrapper=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --approved-scope)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-scope'
      approved_scope="$2"
      shift 2
      ;;
    --change-record-id)
      [[ $# -ge 2 ]] || fail 'Missing value for --change-record-id'
      change_record_id="$2"
      shift 2
      ;;
    --confirm)
      confirm_wrapper=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$approved_scope" ]] || { usage >&2; fail 'The --approved-scope option is required.'; }
[[ -n "$change_record_id" ]] || { usage >&2; fail 'The --change-record-id option is required.'; }
validate_scope "$approved_scope"

require_file "$control_path"
require_file "$preflight_path"
for command_name in python bash; do
  require_command "$command_name"
done

if grep -RnoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" >/dev/null; then
  fail 'Resolve every required decision before failover.'
fi

action_session="$(json_get "$control_path" implementationSession)"
[[ "$action_session" == '14-agent-fleet-multiregion-rehearsal' ]] || fail 'Control definition has the wrong implementationSession marker.'
control_scope="$(json_get "$control_path" approvedAzureScope)"
[[ "$control_scope" == "$approved_scope" ]] || fail 'The approved scope differs from the requested scope.'

health_relative_path="$(json_get "$control_path" sourcePaths.healthCheckBash)"
routing_relative_path="$(json_get "$control_path" sourcePaths.routingControlBash)"
parameters_relative_path="$(json_get "$control_path" sourcePaths.regionalParameters)"
parameters_path="$(resolve_repo_file "$repo_root" "$parameters_relative_path")" || fail 'Regional parameters must resolve inside the repository.'
require_file "$parameters_path"
secondary_region="$(json_get "$parameters_path" parameters.secondaryRegion.value)"
primary_selector="$(json_get "$parameters_path" parameters.primarySelector.value)"
secondary_selector="$(json_get "$parameters_path" parameters.secondarySelector.value)"
[[ -n "${primary_selector//[[:space:]]/}" &&
   -n "${secondary_selector//[[:space:]]/}" &&
   "${primary_selector,,}" != "${secondary_selector,,}" ]] ||
  fail 'Primary and secondary routing selectors must be nonempty and distinct.'

health_script="$(resolve_repo_file "$repo_root" "$health_relative_path")" || fail 'Customer health script path must resolve inside the repository.'
routing_script="$(resolve_repo_file "$repo_root" "$routing_relative_path")" || fail 'Customer routing script path must resolve inside the repository.'
require_file "$health_script"
require_file "$routing_script"
bash -n "$health_script"
bash -n "$routing_script"

bash "$preflight_path" \
  --phase ready \
  --approved-scope "$approved_scope"

"$health_script" \
  --mode readiness \
  --region "$secondary_region" \
  --result-path "$secondary_readiness_path"
validate_health_result "$secondary_readiness_path" 'ready' "$secondary_region" "$parameters_path"

"$routing_script" \
  --mode preview \
  --from-selector "$primary_selector" \
  --to-selector "$secondary_selector" \
  --approved-scope "$approved_scope" \
  --change-record-id "$change_record_id"

if (( ! confirm_wrapper )); then
  [[ -t 0 ]] || fail 'Interactive confirmation is required. Re-run with --confirm only after reviewing the preview output.'
  printf 'Type yes to move only the named secondary selector: ' >&2
  read -r response
  [[ "$response" == 'yes' ]] || fail 'Failover cancelled.'
fi

"$routing_script" \
  --mode failover \
  --from-selector "$primary_selector" \
  --to-selector "$secondary_selector" \
  --approved-scope "$approved_scope" \
  --change-record-id "$change_record_id"

"$health_script" \
  --mode active \
  --region "$secondary_region" \
  --result-path "$secondary_active_path"
validate_health_result "$secondary_active_path" 'active' "$secondary_region" "$parameters_path"

printf 'PASS: the governed agent is active through the secondary selector with the expected identity, policy, version, and trace.\n'
printf 'Save the runtime result only in: %s\n' "$(json_get "$control_path" records.approvedOperationalStore)"
