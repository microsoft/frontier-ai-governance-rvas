#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-scope <resource-group-id> [--phase decisions|ready] [--runtime-directory <outside-repository-path>]

Checks the rehearsal contract and customer controls. Ready also checks the primary path. It does
not move traffic.
USAGE
}

fail() { printf '%s\n' "$1" >&2; exit 1; }
require_file() { [[ -f "$1" ]] || fail "Required file is missing: $1"; }
require_command() { command -v "$1" >/dev/null 2>&1 || fail "Required command is unavailable: $1"; }

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
control_path="$artifact_root/control-definition.json"
parameters_path="$artifact_root/regional/region.parameters.json"
runbook_path="$artifact_root/regional/failover-runbook.md"

phase='ready'
approved_scope=''
runtime_directory=''
while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase) phase="${2:-}"; shift 2 ;;
    --approved-scope) approved_scope="${2:-}"; shift 2 ;;
    --runtime-directory) runtime_directory="${2:-}"; shift 2 ;;
    --help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown argument: $1" ;;
  esac
done

[[ "$phase" == 'decisions' || "$phase" == 'ready' ]] || fail 'Phase must be decisions or ready.'
[[ "$approved_scope" =~ ^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$ ]] ||
  fail 'Approved scope must be an exact Azure resource-group resource ID.'
approved_target_scope="$approved_scope"
for path in "$control_path" "$parameters_path" "$runbook_path" "$artifact_root/README.md"; do
  require_file "$path"
done
for command_name in bash python; do require_command "$command_name"; done

covered_sentinels='
__REQUIRED_AGENT_IDENTITY_ID__
__REQUIRED_AGENT_VERSION__
__REQUIRED_CUSTOMER_HEALTH_CHECK_BASH_PATH__
__REQUIRED_CUSTOMER_HEALTH_CHECK_POWERSHELL_PATH__
__REQUIRED_CUSTOMER_ROUTING_CONTROL_BASH_PATH__
__REQUIRED_CUSTOMER_ROUTING_CONTROL_POWERSHELL_PATH__
__REQUIRED_DELIVERY_OWNER__
__REQUIRED_GATEWAY_POLICY_VERSION__
__REQUIRED_PRIMARY_GATEWAY_HOST__
__REQUIRED_PRIMARY_REGION__
__REQUIRED_PRIMARY_ROUTING_SELECTOR__
__REQUIRED_RESOURCE_GROUP__
__REQUIRED_ROUTING_OWNER__
__REQUIRED_SECONDARY_GATEWAY_HOST__
__REQUIRED_SECONDARY_REGION__
__REQUIRED_SECONDARY_ROUTING_SELECTOR__
__REQUIRED_SERVICE_OWNER__
__REQUIRED_SUBSCRIPTION_ID__
'
mapfile -t found_sentinels < <(
  grep -RhoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true
)
for sentinel in "${found_sentinels[@]}"; do
  grep -Fxq "$sentinel" <<<"$covered_sentinels" || fail "Preflight has no named coverage for $sentinel"
done
if (( ${#found_sentinels[@]} > 0 )); then
  grep -RnoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" >&2 || true
  fail 'Resolve every named customer decision before a state change.'
fi

state="$(
python - "$repo_root" "$control_path" "$parameters_path" "$approved_target_scope" <<'PY'
import json
import os
import re
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
control_path = Path(sys.argv[2]).resolve()
parameters_path = Path(sys.argv[3]).resolve()
scope = sys.argv[4]

def resolve(relative, purpose):
    if not isinstance(relative, str) or os.path.isabs(relative):
        raise SystemExit(f"{purpose} must be repository-relative.")
    candidate = (repo / relative).resolve()
    if not str(candidate).startswith(str(repo) + os.sep) or not candidate.is_file():
        raise SystemExit(f"{purpose} is missing or outside the repository.")
    return candidate

control = json.loads(control_path.read_text())
parameters = json.loads(parameters_path.read_text())
if control.get("schemaVersion") != 2:
    raise SystemExit("control-definition.json must use schemaVersion 2.")
if parameters.get("schemaVersion") != 2:
    raise SystemExit("region.parameters.json must use schemaVersion 2.")
for document, name in ((control, "control-definition.json"), (parameters, "region.parameters.json")):
    if document.get("implementationSession") != "13-agent-fleet-multiregion-rehearsal":
        raise SystemExit(f"{name} has the wrong implementationSession marker.")
if str(control.get("approvedAzureScope", "")).casefold() != scope.casefold():
    raise SystemExit("Approved scope differs from the rehearsal contract.")

source_paths = control.get("sourcePaths")
if not isinstance(source_paths, dict):
    raise SystemExit("control-definition.json is missing sourcePaths.")
health_bash = resolve(source_paths.get("healthCheckBash"), "Customer Bash health control")
routing_bash = resolve(source_paths.get("routingControlBash"), "Customer Bash routing control")
health_powershell = resolve(source_paths.get("healthCheckPowerShell"), "Customer PowerShell health control")
routing_powershell = resolve(source_paths.get("routingControlPowerShell"), "Customer PowerShell routing control")
if resolve(source_paths.get("regionalParameters"), "Regional parameter contract") != parameters_path:
    raise SystemExit("regionalParameters must point to region.parameters.json.")

def text(group, name):
    value = parameters.get(group, {}).get(name)
    if not isinstance(value, str) or not value.strip():
        raise SystemExit(f"region.parameters.json is missing {group}.{name}.")
    return value.strip()

primary_region = text("primary", "region")
secondary_region = text("secondary", "region")
if primary_region.casefold() == secondary_region.casefold():
    raise SystemExit("Primary and secondary regions must differ.")
primary_selector = text("primary", "selector")
secondary_selector = text("secondary", "selector")
if primary_selector.casefold() == secondary_selector.casefold():
    raise SystemExit("Primary and secondary selectors must differ.")
primary_endpoint = text("primary", "endpoint")
secondary_endpoint = text("secondary", "endpoint")
for endpoint in (primary_endpoint, secondary_endpoint):
    if not re.fullmatch(r"https://[^/\s]+(?:/.*)?", endpoint):
        raise SystemExit("Regional endpoints must be absolute HTTPS URLs.")

expected = parameters.get("expected")
if not isinstance(expected, dict):
    raise SystemExit("region.parameters.json is missing expected values.")
for name in ("agentVersion", "agentIdentityId", "gatewayPolicyVersion"):
    if not isinstance(expected.get(name), str) or not expected[name].strip():
        raise SystemExit(f"region.parameters.json is missing expected.{name}.")
trace_fields = expected.get("requiredTraceFields")
if not isinstance(trace_fields, list) or not trace_fields or any(
    not isinstance(field, str) or not field.strip() for field in trace_fields
):
    raise SystemExit("expected.requiredTraceFields must be a nonempty string array.")

print(json.dumps({
    "subscriptionId": scope.split("/")[2],
    "healthBash": str(health_bash),
    "routingBash": str(routing_bash),
    "healthPowerShell": str(health_powershell),
    "routingPowerShell": str(routing_powershell),
    "primaryRegion": primary_region,
    "primaryEndpoint": primary_endpoint,
}))
PY
)"

json_value() {
  python -c 'import json,sys; print(json.loads(sys.stdin.read())[sys.argv[1]])' "$1" <<<"$state"
}

bash -n "$(json_value healthBash)"
bash -n "$(json_value routingBash)"
require_file "$(json_value healthPowerShell)"
require_file "$(json_value routingPowerShell)"

if [[ "$phase" == 'decisions' ]]; then
  printf 'PASS: scope, regional contract, and customer controls are ready.\n'
  exit 0
fi

[[ -n "$runtime_directory" ]] || fail 'Ready phase requires --runtime-directory.'
runtime_directory="$(
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
)"

require_command az
account_id="$(az account show --query id --output tsv)"
[[ "${account_id,,}" == "$(json_value subscriptionId | tr '[:upper:]' '[:lower:]')" ]] ||
  fail 'Active Azure subscription differs from the approved scope.'

primary_result="$runtime_directory/s13-primary-active-$$.json"
trap 'rm -f "$primary_result"' EXIT
"$(json_value healthBash)" \
  --mode active \
  --region "$(json_value primaryRegion)" \
  --result-path "$primary_result"

python - "$primary_result" "$parameters_path" <<'PY'
import json
import sys
from pathlib import Path

result = json.loads(Path(sys.argv[1]).read_text())
parameters = json.loads(Path(sys.argv[2]).read_text())
primary = parameters["primary"]
expected = parameters["expected"]
required = {
    "implementationSession": "13-agent-fleet-multiregion-rehearsal",
    "status": "active",
    "region": primary["region"],
    "agentVersion": expected["agentVersion"],
    "agentIdentityId": expected["agentIdentityId"],
    "gatewayPolicyVersion": expected["gatewayPolicyVersion"],
    "endpoint": primary["endpoint"],
}
for field, value in required.items():
    if result.get(field) != value:
        raise SystemExit(f"Primary health result field {field!r} does not match the rehearsal contract.")
if result.get("sensitiveInputPresent") is not False:
    raise SystemExit("Primary health result indicates sensitive input.")
trace_fields = result.get("traceFields")
if not isinstance(trace_fields, list) or not set(expected["requiredTraceFields"]).issubset(trace_fields):
    raise SystemExit("Primary health result is missing a required trace field.")
PY

printf 'PASS: the approved primary path is active and matches the contract.\n'
