#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-scope <resource-group-id> [--phase decisions|ready]

Checks the source-controlled rehearsal contract, regional deployment parameters, customer script
interfaces, live Azure resources, API Management topology, and deployment what-if. It does not
write runtime or decision state to this repository.
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
approved_target_scope=''
while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase)
      [[ $# -ge 2 ]] || fail 'Missing value for --phase'
      phase="${2,,}"
      shift 2
      ;;
    --approved-scope)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-scope'
      approved_target_scope="$2"
      shift 2
      ;;
    --help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown argument: $1" ;;
  esac
done

[[ "$phase" == 'decisions' || "$phase" == 'ready' ]] || fail 'Phase must be decisions or ready.'
[[ "$approved_target_scope" =~ ^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$ ]] ||
  fail 'Approved scope must be an exact Azure resource-group resource ID.'

for path in "$control_path" "$parameters_path" "$runbook_path" "$artifact_root/README.md"; do
  require_file "$path"
done
for command_name in az bash python; do require_command "$command_name"; done

covered_sentinels='
__REQUIRED_AGENT_IDENTITY_ID__
__REQUIRED_AGENT_VERSION__
__REQUIRED_APPLICATION_INSIGHTS_NAME__
__REQUIRED_CUSTOMER_BICEP_ENTRYPOINT_PATH__
__REQUIRED_CUSTOMER_HEALTH_CHECK_BASH_PATH__
__REQUIRED_CUSTOMER_HEALTH_CHECK_POWERSHELL_PATH__
__REQUIRED_CUSTOMER_ROUTING_CONTROL_BASH_PATH__
__REQUIRED_CUSTOMER_ROUTING_CONTROL_POWERSHELL_PATH__
__REQUIRED_DELIVERY_OWNER__
__REQUIRED_FOUNDRY_ACCOUNT_NAME__
__REQUIRED_FOUNDRY_PROJECT_NAME__
__REQUIRED_GATEWAY_PATTERN_MULTI_REGION_OR_SEPARATE__
__REQUIRED_GATEWAY_POLICY_VERSION__
__REQUIRED_PLATFORM_OWNER__
__REQUIRED_PRIMARY_APIM_SERVICE_NAME__
__REQUIRED_PRIMARY_APIM_TIER__
__REQUIRED_PRIMARY_BACKEND_URL__
__REQUIRED_PRIMARY_GATEWAY_URL__
__REQUIRED_PRIMARY_REGION__
__REQUIRED_PRIMARY_ROUTING_SELECTOR__
__REQUIRED_RESOURCE_GROUP__
__REQUIRED_ROUTING_MODE_EXTERNAL_OR_INTERNAL__
__REQUIRED_SECONDARY_APIM_RESOURCE_ID__
__REQUIRED_SECONDARY_APIM_TIER__
__REQUIRED_SECONDARY_BACKEND_URL__
__REQUIRED_SECONDARY_GATEWAY_URL__
__REQUIRED_SECONDARY_REGION__
__REQUIRED_SECONDARY_ROUTING_SELECTOR__
__REQUIRED_SECURITY_OWNER__
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

control = json.loads(control_path.read_text())
parameters = json.loads(parameters_path.read_text()).get("parameters", {})
values = {name: item.get("value") for name, item in parameters.items()}

def value(name):
    if name not in values or not isinstance(values[name], str) or not values[name].strip():
        raise SystemExit(f"region.parameters.json is missing a usable {name} value.")
    return values[name].strip()

def resolve(relative, purpose):
    if not isinstance(relative, str) or os.path.isabs(relative):
        raise SystemExit(f"{purpose} must be repository-relative.")
    candidate = (repo / relative).resolve()
    if not str(candidate).startswith(str(repo) + os.sep) or not candidate.is_file():
        raise SystemExit(f"{purpose} is missing or outside the repository.")
    return candidate

if control.get("schemaVersion") != 2:
    raise SystemExit("control-definition.json must use schemaVersion 2.")
if control.get("implementationSession") != "14-agent-fleet-multiregion-rehearsal":
    raise SystemExit("control-definition.json has the wrong implementationSession marker.")
if str(control.get("approvedAzureScope", "")).lower() != scope.lower():
    raise SystemExit("Approved scope differs from the rehearsal contract.")

source_paths = control.get("sourcePaths")
if not isinstance(source_paths, dict):
    raise SystemExit("control-definition.json is missing sourcePaths.")
bicep = resolve(source_paths.get("bicepEntrypoint"), "Customer Bicep entrypoint")
health_bash = resolve(source_paths.get("healthCheckBash"), "Customer Bash health script")
routing_bash = resolve(source_paths.get("routingControlBash"), "Customer Bash routing script")
health_powershell = resolve(
    source_paths.get("healthCheckPowerShell"), "Customer PowerShell health script"
)
routing_powershell = resolve(
    source_paths.get("routingControlPowerShell"), "Customer PowerShell routing script"
)
if resolve(source_paths.get("regionalParameters"), "Regional parameter contract") != parameters_path:
    raise SystemExit("regionalParameters must point to region.parameters.json.")

primary_region = value("primaryRegion")
secondary_region = value("secondaryRegion")
if primary_region.casefold() == secondary_region.casefold():
    raise SystemExit("Primary and secondary regions must differ.")
primary_selector = value("primarySelector")
secondary_selector = value("secondarySelector")
if primary_selector.casefold() == secondary_selector.casefold():
    raise SystemExit("Primary and secondary routing selectors must differ.")

gateway_pattern = value("gatewayPattern")
if gateway_pattern not in ("multi-region-instance", "separate-regional-gateways"):
    raise SystemExit("Invalid gatewayPattern.")
routing_mode = value("routingMode")
if routing_mode not in ("external", "internal"):
    raise SystemExit("Invalid routingMode.")

prefix = scope.lower() + "/providers/microsoft.apimanagement/service/"
primary_apim = value("primaryApimResourceId")
secondary_apim = value("secondaryApimResourceId")
for name, resource_id in (
    ("primaryApimResourceId", primary_apim),
    ("secondaryApimResourceId", secondary_apim),
):
    if not resource_id.lower().startswith(prefix):
        raise SystemExit(f"{name} must remain inside the approved scope.")
if gateway_pattern == "multi-region-instance":
    if primary_apim.casefold() != secondary_apim.casefold() or value("primaryApimTier").casefold() != "premium":
        raise SystemExit("A multi-region instance requires one Premium API Management resource ID.")
elif primary_apim.casefold() == secondary_apim.casefold():
    raise SystemExit("Separate regional gateways require different resource IDs.")

for name in (
    "foundryProjectResourceId",
    "applicationInsightsResourceId",
    "agentVersion",
    "agentIdentityId",
    "gatewayPolicyVersion",
):
    value(name)
for name in (
    "primaryGatewayUrl",
    "secondaryGatewayUrl",
    "primaryBackendUrl",
    "secondaryBackendUrl",
):
    if not re.fullmatch(r"https://[^/\s]+(?:/.*)?", value(name)):
        raise SystemExit(f"{name} must be an absolute HTTPS URL.")

print(json.dumps({
    "subscriptionId": scope.split("/")[2],
    "resourceGroup": scope.split("/")[4],
    "bicep": str(bicep),
    "healthBash": str(health_bash),
    "routingBash": str(routing_bash),
    "healthPowerShell": str(health_powershell),
    "routingPowerShell": str(routing_powershell),
    "parameters": str(parameters_path),
    "primaryRegion": primary_region,
    "secondaryRegion": secondary_region,
    "gatewayPattern": gateway_pattern,
    "primaryApimResourceId": primary_apim,
    "secondaryApimResourceId": secondary_apim,
    "primaryApimTier": value("primaryApimTier"),
    "secondaryApimTier": value("secondaryApimTier"),
    "liveResources": [
        value("foundryProjectResourceId"),
        value("applicationInsightsResourceId"),
    ],
}))
PY
)"

json_value() {
  python -c 'import json,sys; print(json.loads(sys.stdin.read())[sys.argv[1]])' "$1" <<<"$state"
}

bash -n "$(json_value healthBash)"
bash -n "$(json_value routingBash)"
az bicep lint --file "$(json_value bicep)"
az bicep build --file "$(json_value bicep)" --stdout >/dev/null

if [[ "$phase" == 'decisions' ]]; then
  printf 'PASS: the source-controlled contracts, customer script interfaces, and Bicep checks are ready.\n'
  exit 0
fi

python - "$state" "$(az account show -o json)" <<'PY'
import json
import sys

state = json.loads(sys.argv[1])
account = json.loads(sys.argv[2])
if str(account.get("id", "")).lower() != state["subscriptionId"].lower():
    raise SystemExit("Active Azure subscription differs from the approved scope.")
PY

python - "$state" <<'PY'
import json
import subprocess
import sys

state = json.loads(sys.argv[1])
for resource_id in state["liveResources"]:
    subprocess.check_call(("az", "resource", "show", "--ids", resource_id, "-o", "none"))

def show(resource_id):
    return json.loads(subprocess.check_output(
        ("az", "resource", "show", "--ids", resource_id, "-o", "json"), text=True
    ))

primary = show(state["primaryApimResourceId"])
secondary = primary if (
    state["secondaryApimResourceId"].casefold() == state["primaryApimResourceId"].casefold()
) else show(state["secondaryApimResourceId"])
if primary.get("location", "").casefold() != state["primaryRegion"].casefold():
    raise SystemExit("Primary API Management region differs from the parameter contract.")
if (
    primary.get("sku", {}).get("name", "").casefold() != state["primaryApimTier"].casefold()
    or secondary.get("sku", {}).get("name", "").casefold() != state["secondaryApimTier"].casefold()
):
    raise SystemExit("Live API Management tier differs from the parameter contract.")
if state["gatewayPattern"] == "multi-region-instance":
    locations = [
        item.get("location", "").casefold()
        for item in primary.get("properties", {}).get("additionalLocations", [])
    ]
    if (
        primary.get("sku", {}).get("name", "").casefold() != "premium"
        or state["secondaryRegion"].casefold() not in locations
    ):
        raise SystemExit("The live Premium API Management instance lacks the configured secondary location.")
elif secondary.get("location", "").casefold() != state["secondaryRegion"].casefold():
    raise SystemExit("Secondary API Management region differs from the parameter contract.")
PY

az deployment group what-if \
  --subscription "$(json_value subscriptionId)" \
  --resource-group "$(json_value resourceGroup)" \
  --name s14-regional-preflight \
  --template-file "$(json_value bicep)" \
  --parameters "@$(json_value parameters)" \
  --no-pretty-print

printf 'PASS: live Azure resources, API Management topology, and the read-only deployment preview are ready.\n'
