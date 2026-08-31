#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/rehearse-failover.sh --approved-scope <resource-group-id> --change-record-id <record> --runtime-directory <path> [--confirm]

Runs the approved regional rehearsal. Temporary health output is written outside this repository,
then removed. The customer change system remains the record of the traffic move.
USAGE
}

fail() { printf '%s\n' "$1" >&2; exit 1; }
require_file() { [[ -f "$1" ]] || fail "Required implementation file is missing: $1"; }
require_command() { command -v "$1" >/dev/null 2>&1 || fail "Required command is unavailable: $1"; }

json_get() {
  python - "$1" "$2" <<'PY'
import json
import sys
from pathlib import Path

value = json.loads(Path(sys.argv[1]).read_text())
for key in sys.argv[2].split("."):
    value = value[key]
print(value)
PY
}

resolve_repo_file() {
  python - "$1" "$2" <<'PY'
import os
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
relative = sys.argv[2]
candidate = (root / relative).resolve()
if os.path.isabs(relative) or not str(candidate).startswith(str(root) + os.sep):
    raise SystemExit(1)
print(candidate)
PY
}

validate_runtime_directory() {
  python - "$1" "$2" <<'PY'
import os
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
runtime = Path(sys.argv[2]).resolve()
if not runtime.is_dir():
    raise SystemExit("Runtime directory must already exist.")
if runtime == repo or str(runtime).startswith(str(repo) + os.sep):
    raise SystemExit("Runtime directory must be outside the repository.")
print(runtime)
PY
}

validate_health_result() {
  python - "$1" "$2" "$3" "$4" <<'PY'
import json
import sys
from pathlib import Path

result = json.loads(Path(sys.argv[1]).read_text())
parameters = json.loads(Path(sys.argv[4]).read_text())["parameters"]
value = lambda name: parameters[name]["value"]
expected = {
    "implementationSession": "15-agent-fleet-multiregion-rehearsal",
    "status": sys.argv[2],
    "region": sys.argv[3],
    "agentVersion": value("agentVersion"),
    "agentIdentityId": value("agentIdentityId"),
    "gatewayPolicyVersion": value("gatewayPolicyVersion"),
    "endpointStatus": "passed",
    "identityStatus": "passed",
    "policyStatus": "passed",
    "traceStatus": "passed",
}
for field, wanted in expected.items():
    if result.get(field) != wanted:
        raise SystemExit(f"Health result field {field!r} does not match the rehearsal contract.")
if result.get("sensitiveInputPresent") is not False:
    raise SystemExit("Health result indicates sensitive input in the runtime path.")
PY
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
control_path="$artifact_root/control-definition.json"
preflight_path="$script_dir/preflight.sh"

approved_scope=''
change_record_id=''
runtime_directory=''
confirm_wrapper=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --approved-scope) approved_scope="${2:-}"; shift 2 ;;
    --change-record-id) change_record_id="${2:-}"; shift 2 ;;
    --runtime-directory) runtime_directory="${2:-}"; shift 2 ;;
    --confirm) confirm_wrapper=1; shift ;;
    --help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown argument: $1" ;;
  esac
done

[[ "$approved_scope" =~ ^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$ ]] ||
  fail 'Approved scope must be an exact Azure resource-group resource ID.'
[[ -n "$change_record_id" ]] || fail 'The --change-record-id option is required.'
[[ -n "$runtime_directory" ]] || fail 'The --runtime-directory option is required.'

for path in "$control_path" "$preflight_path"; do require_file "$path"; done
for command_name in bash python; do require_command "$command_name"; done

runtime_directory="$(validate_runtime_directory "$repo_root" "$runtime_directory")"
secondary_readiness_path="$runtime_directory/s14-secondary-ready-$$.json"
secondary_active_path="$runtime_directory/s14-secondary-active-$$.json"
trap 'rm -f "$secondary_readiness_path" "$secondary_active_path"' EXIT

if grep -RnoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" >/dev/null; then
  fail 'Resolve every required decision before failover.'
fi

control_session="$(json_get "$control_path" implementationSession)"
[[ "$control_session" == '15-agent-fleet-multiregion-rehearsal' ]] ||
  fail 'Control definition has the wrong implementationSession marker.'
control_scope="$(json_get "$control_path" approvedAzureScope)"
[[ "$control_scope" == "$approved_scope" ]] || fail 'The approved scope differs from the requested scope.'

health_script="$(resolve_repo_file "$repo_root" "$(json_get "$control_path" sourcePaths.healthCheckBash)")" ||
  fail 'Customer Bash health script must resolve inside the repository.'
routing_script="$(resolve_repo_file "$repo_root" "$(json_get "$control_path" sourcePaths.routingControlBash)")" ||
  fail 'Customer Bash routing script must resolve inside the repository.'
parameters_path="$(resolve_repo_file "$repo_root" "$(json_get "$control_path" sourcePaths.regionalParameters)")" ||
  fail 'Regional parameters must resolve inside the repository.'
for path in "$health_script" "$routing_script" "$parameters_path"; do require_file "$path"; done
bash -n "$health_script"
bash -n "$routing_script"

secondary_region="$(json_get "$parameters_path" parameters.secondaryRegion.value)"
primary_selector="$(json_get "$parameters_path" parameters.primarySelector.value)"
secondary_selector="$(json_get "$parameters_path" parameters.secondarySelector.value)"
[[ -n "${primary_selector//[[:space:]]/}" &&
   -n "${secondary_selector//[[:space:]]/}" &&
   "${primary_selector,,}" != "${secondary_selector,,}" ]] ||
  fail 'Primary and secondary routing selectors must be nonempty and distinct.'

bash "$preflight_path" --phase ready --approved-scope "$approved_scope"

"$health_script" --mode readiness --region "$secondary_region" --result-path "$secondary_readiness_path"
validate_health_result "$secondary_readiness_path" 'ready' "$secondary_region" "$parameters_path"

"$routing_script" \
  --mode preview \
  --from-selector "$primary_selector" \
  --to-selector "$secondary_selector" \
  --approved-scope "$approved_scope" \
  --change-record-id "$change_record_id"

if (( ! confirm_wrapper )); then
  [[ -t 0 ]] || fail 'Interactive confirmation is required. Re-run with --confirm after reviewing the preview.'
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

"$health_script" --mode active --region "$secondary_region" --result-path "$secondary_active_path"
validate_health_result "$secondary_active_path" 'active' "$secondary_region" "$parameters_path"

printf 'PASS: the governed agent is active through the secondary selector with the expected identity, policy, version, and trace.\n'
printf 'Record the result in customer change record %s.\n' "$change_record_id"
