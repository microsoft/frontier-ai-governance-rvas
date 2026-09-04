#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/rehearse-failover.sh --approved-scope <resource-group-id> --change-record-id <record> --runtime-directory <outside-repository-path> --confirm

Previews one selector move. Checks the secondary path, restores the primary path, and checks it.
The customer change record holds the outcome.
USAGE
}

fail() { printf '%s\n' "$1" >&2; exit 1; }
require_file() { [[ -f "$1" ]] || fail "Required file is missing: $1"; }

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
control_path="$artifact_root/control-definition.json"
parameters_path="$artifact_root/regional/region.parameters.json"
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
(( confirm_wrapper )) || fail 'Re-run with --confirm after the delivery owner approves both moves.'
for path in "$control_path" "$parameters_path" "$preflight_path"; do require_file "$path"; done

state="$(
python - "$repo_root" "$control_path" "$parameters_path" "$approved_scope" <<'PY'
import json
import os
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
control = json.loads(Path(sys.argv[2]).read_text())
parameters = json.loads(Path(sys.argv[3]).read_text())
scope = sys.argv[4]

def resolve(relative, purpose):
    if not isinstance(relative, str) or os.path.isabs(relative):
        raise SystemExit(f"{purpose} must be repository-relative.")
    candidate = (repo / relative).resolve()
    if not str(candidate).startswith(str(repo) + os.sep) or not candidate.is_file():
        raise SystemExit(f"{purpose} is missing or outside the repository.")
    return candidate

if control.get("implementationSession") != "optional-module-citadel-multiregion-recovery":
    raise SystemExit("Control definition has the wrong implementationSession marker.")
if str(control.get("approvedAzureScope", "")).casefold() != scope.casefold():
    raise SystemExit("The approved scope differs from the requested scope.")
paths = control["sourcePaths"]
def value(group, name):
    result = parameters[group][name]
    if not isinstance(result, str) or not result.strip():
        raise SystemExit(f"region.parameters.json is missing {group}.{name}.")
    return result
expected = parameters["expected"]
print(json.dumps({
    "health": str(resolve(paths["healthCheckBash"], "Customer Bash health control")),
    "routing": str(resolve(paths["routingControlBash"], "Customer Bash routing control")),
    "primaryRegion": value("primary", "region"),
    "primarySelector": value("primary", "selector"),
    "secondaryRegion": value("secondary", "region"),
    "secondarySelector": value("secondary", "selector"),
}))
PY
)"

json_value() {
  python -c 'import json,sys; print(json.loads(sys.stdin.read())[sys.argv[1]])' "$1" <<<"$state"
}
validate_runtime_directory() {
  python - "$repo_root" "$runtime_directory" <<'PY'
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
validate_result() {
  python - "$1" "$2" "$3" "$parameters_path" <<'PY'
import json
import sys
from pathlib import Path

result = json.loads(Path(sys.argv[1]).read_text())
status, path_name = sys.argv[2:4]
parameters = json.loads(Path(sys.argv[4]).read_text())
path = parameters[path_name]
expected = parameters["expected"]
fields = {
    "implementationSession": "optional-module-citadel-multiregion-recovery",
    "status": status,
    "region": path["region"],
    "agentVersion": expected["agentVersion"],
    "agentIdentityId": expected["agentIdentityId"],
    "gatewayPolicyVersion": expected["gatewayPolicyVersion"],
    "endpoint": path["endpoint"],
}
for field, value in fields.items():
    if result.get(field) != value:
        raise SystemExit(f"Health result field {field!r} does not match the rehearsal contract.")
if result.get("sensitiveInputPresent") is not False:
    raise SystemExit("Health result indicates sensitive input.")
trace_fields = result.get("traceFields")
if not isinstance(trace_fields, list) or not set(expected["requiredTraceFields"]).issubset(trace_fields):
    raise SystemExit("Health result is missing a required trace field.")
PY
}

runtime_directory="$(validate_runtime_directory)"
secondary_ready="$runtime_directory/s13-secondary-ready-$$.json"
secondary_active="$runtime_directory/s13-secondary-active-$$.json"
primary_restored="$runtime_directory/s13-primary-restored-$$.json"
trap 'rm -f "$secondary_ready" "$secondary_active" "$primary_restored"' EXIT

bash "$preflight_path" --phase ready --approved-scope "$approved_scope" \
  --runtime-directory "$runtime_directory"
bash -n "$(json_value health)"
bash -n "$(json_value routing)"

"$(json_value health)" --mode readiness --region "$(json_value secondaryRegion)" \
  --result-path "$secondary_ready"
validate_result "$secondary_ready" ready secondary

"$(json_value routing)" --mode preview --from-selector "$(json_value primarySelector)" \
  --to-selector "$(json_value secondarySelector)" --approved-scope "$approved_scope" \
  --change-record-id "$change_record_id"
"$(json_value routing)" --mode failover --from-selector "$(json_value primarySelector)" \
  --to-selector "$(json_value secondarySelector)" --approved-scope "$approved_scope" \
  --change-record-id "$change_record_id"

"$(json_value health)" --mode active --region "$(json_value secondaryRegion)" \
  --result-path "$secondary_active"
validate_result "$secondary_active" active secondary

"$(json_value routing)" --mode preview --from-selector "$(json_value secondarySelector)" \
  --to-selector "$(json_value primarySelector)" --approved-scope "$approved_scope" \
  --change-record-id "$change_record_id"
"$(json_value routing)" --mode restore --from-selector "$(json_value secondarySelector)" \
  --to-selector "$(json_value primarySelector)" --approved-scope "$approved_scope" \
  --change-record-id "$change_record_id"

"$(json_value health)" --mode active --region "$(json_value primaryRegion)" \
  --result-path "$primary_restored"
validate_result "$primary_restored" active primary

printf 'PASS: secondary matched the contract. Primary was restored and checked.\n'
printf 'Record the result in customer change record %s.\n' "$change_record_id"
