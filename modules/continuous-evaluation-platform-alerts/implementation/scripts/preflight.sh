#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --approved-subscription-id <guid> --resource-group-name <name> \
    --target-scope <approved-scope-alias> --deployment-location <azure-region>

Checks the module artifacts, rejects unresolved decisions, validates syntax, and runs a read-only
resource-group what-if after every required decision is resolved.
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

approved_subscription_id=""
resource_group_name=""
target_scope=""
deployment_location=""

while (($# > 0)); do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail "--approved-subscription-id requires a value."
      approved_subscription_id=$2
      shift 2
      ;;
    --resource-group-name)
      [[ $# -ge 2 ]] || fail "--resource-group-name requires a value."
      resource_group_name=$2
      shift 2
      ;;
    --target-scope)
      [[ $# -ge 2 ]] || fail "--target-scope requires a value."
      target_scope=$2
      shift 2
      ;;
    --deployment-location)
      [[ $# -ge 2 ]] || fail "--deployment-location requires a value."
      deployment_location=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$approved_subscription_id" && -n "$resource_group_name" && -n "$target_scope" && -n "$deployment_location" ]] ||
  { usage >&2; fail "All approved scope options are required."; }
[[ "$approved_subscription_id" =~ ^[0-9a-fA-F-]{36}$ ]] || fail "Approved subscription ID must be a GUID."

for command_name in az python3 grep; do
  command -v "$command_name" >/dev/null 2>&1 || fail "Required command is unavailable: $command_name"
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
artifact_root="$(cd -- "$script_dir/../artifacts" && pwd)"
monitoring_template="$artifact_root/monitoring/foundry-platform-monitoring.bicep"
monitoring_parameters="$artifact_root/monitoring/foundry-platform-monitoring.bicepparam"
decision_path="$artifact_root/evaluation/continuous-evaluation-decision.json"
evaluation_script="$artifact_root/evaluation/continuous-evaluation-rule.py"
requirements_path="$artifact_root/evaluation/requirements.txt"
query_path="$artifact_root/queries/foundry-token-and-throttling.kql"

for path in "$monitoring_template" "$monitoring_parameters" "$decision_path" "$evaluation_script" "$requirements_path" "$query_path"; do
  [[ -f "$path" ]] || fail "Required implementation artifact is missing: $path"
done

required_sentinels=(
  "__REQUIRED_ACTION_GROUP_NAME__"
  "__REQUIRED_ACTION_GROUP_SHORT_NAME__"
  "__REQUIRED_ACTION_RECEIVER_EMAIL__"
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_AGENT_VERSION__"
  "__REQUIRED_AI_QUALITY_OWNER_ROLE__"
  "__REQUIRED_ALERT_OWNER_ROLE__"
  "__REQUIRED_APPROVED_FOUNDRY_SCOPE_ALIAS__"
  "__REQUIRED_DEPLOYMENT_LOCATION__"
  "__REQUIRED_EVALUATION_NAME__"
  "__REQUIRED_EVALUATION_RULE_DISPLAY_NAME__"
  "__REQUIRED_EVALUATION_RULE_ID__"
  "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
  "__REQUIRED_FOUNDRY_PROJECT_NAME__"
  "__REQUIRED_INCIDENT_ROUTE_ALIAS__"
  "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__"
  "__REQUIRED_MAX_HOURLY_RUNS__"
  "__REQUIRED_RESTORE_CHANGE_REFERENCE__"
  "__REQUIRED_SAFETY_OWNER_ROLE__"
  "__REQUIRED_SAFETY_THRESHOLD__"
  "__REQUIRED_SERVICE_NAME__"
  "__REQUIRED_STATUS_CODE_DIMENSION_VALUE_CONFIRMED__"
  "__REQUIRED_TASK_ADHERENCE_THRESHOLD__"
  "__REQUIRED_THROTTLED_REQUESTS_THRESHOLD__"
  "__REQUIRED_TIME_TO_LAST_BYTE_THRESHOLD_MS__"
  "__REQUIRED_TOKEN_TRANSACTION_THRESHOLD__"
)

mapfile -t unresolved < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved[@]} > 0)); then
  unknown=()
  for sentinel in "${unresolved[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      if [[ "$sentinel" == "$required" ]]; then
        known=true
        break
      fi
    done
    $known || unknown+=("$sentinel")
  done
  ((${#unknown[@]} == 0)) || fail "Add explicit preflight coverage for new sentinels: ${unknown[*]}"
  fail "Resolve every required monitoring and evaluation decision before deployment: ${unresolved[*]}"
fi

python3 - "$monitoring_parameters" "$decision_path" "$target_scope" "$deployment_location" <<'PY'
import json
import re
import sys
from pathlib import Path

parameters_path, decision_path, target_scope, deployment_location = sys.argv[1:]
parameters_text = Path(parameters_path).read_text(encoding="utf-8")
decision = json.loads(Path(decision_path).read_text(encoding="utf-8"))

def stop(message: str) -> None:
    raise SystemExit(message)

def param(name: str) -> str:
    match = re.search(rf"(?m)^\s*param\s+{re.escape(name)}\s*=\s*'([^']*)'\s*$", parameters_text)
    if not match:
        stop(f"Could not read string parameter {name}.")
    return match.group(1)

def integer_string(value: str, label: str, minimum: int, maximum: int) -> None:
    try:
        parsed = int(value)
    except ValueError:
        stop(f"{label} must be an integer.")
    if parsed < minimum or parsed > maximum:
        stop(f"{label} must be from {minimum} through {maximum}.")

if decision.get("implementationSession") != "optional-module-continuous-evaluation-platform-alerts":
    stop("The continuous evaluation decision file has the wrong implementationSession marker.")
if decision.get("targetScope") != target_scope:
    stop("Target scope must match continuous-evaluation-decision.json.")
if param("targetScopeAlias") != target_scope:
    stop("Target scope must match foundry-platform-monitoring.bicepparam.")
if param("location") != deployment_location:
    stop("Deployment location must match foundry-platform-monitoring.bicepparam.")
if param("foundryAccountName") != decision["foundry"]["accountName"]:
    stop("Foundry account name must match between monitoring parameters and evaluation decision record.")

if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", param("actionReceiverEmail")):
    stop("actionReceiverEmail must be a distribution list or mailbox alias, not free text.")
if len(param("actionGroupShortName")) > 12:
    stop("actionGroupShortName must be 12 characters or fewer.")
integer_string(param("throttledRequestsThreshold"), "throttledRequestsThreshold", 1, 1_000_000)
integer_string(param("timeToLastByteThresholdMs"), "timeToLastByteThresholdMs", 1, 600_000)
integer_string(param("tokenTransactionThreshold"), "tokenTransactionThreshold", 1, 1_000_000_000)
integer_string(str(decision["continuousEvaluation"]["sampling"]["maxHourlyRuns"]), "continuousEvaluation.sampling.maxHourlyRuns", 1, 1000)

if decision["operations"]["statusCodeDimensionValueConfirmed"] != "true":
    stop("Confirm the AzureOpenAIRequests StatusCode value for throttling by setting statusCodeDimensionValueConfirmed to true.")
for evaluator in decision["continuousEvaluation"]["evaluators"]:
    if not evaluator["evaluatorName"].startswith("builtin."):
        stop(f"Evaluator {evaluator['evaluatorName']} must come from the approved Foundry evaluator catalog.")
PY

find "$artifact_root" -name '*.json' -print0 | while IFS= read -r -d '' path; do
  python3 -m json.tool "$path" >/dev/null
done
python3 -m py_compile "$evaluation_script"
az bicep build --file "$monitoring_template" --stdout >/dev/null
az bicep build-params --file "$monitoring_parameters" --stdout >/dev/null
az account show --subscription "$approved_subscription_id" --only-show-errors --output json >/dev/null
az deployment group what-if \
  --subscription "$approved_subscription_id" \
  --resource-group "$resource_group_name" \
  --template-file "$monitoring_template" \
  --parameters "$monitoring_parameters" \
  --only-show-errors \
  --output json >/dev/null

echo "PASS: preflight completed for target scope '$target_scope'."
echo "Preview complete: review the resource-group what-if before deploying diagnostic settings, the action group, and metric alerts."
