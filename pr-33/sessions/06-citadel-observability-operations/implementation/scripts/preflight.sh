#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-subscription-id <guid> --approved-resource-group-name <name> \
  --approved-application-insights-resource-id <resource-id> --deployment-location <azure-region>

Validates the Session 06 desired-state files and runs read-only previews. Do not pass secrets as
arguments.
USAGE
}

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command is unavailable: $1"
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"

approved_subscription_id=''
approved_resource_group_name=''
approved_application_insights_resource_id=''
deployment_location=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --approved-subscription-id) approved_subscription_id="${2:-}"; shift 2 ;;
    --approved-resource-group-name) approved_resource_group_name="${2:-}"; shift 2 ;;
    --approved-application-insights-resource-id) approved_application_insights_resource_id="${2:-}"; shift 2 ;;
    --deployment-location) deployment_location="${2:-}"; shift 2 ;;
    --help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown argument: $1" ;;
  esac
done

[[ -n "$approved_subscription_id" && -n "$approved_resource_group_name" && -n "$approved_application_insights_resource_id" && -n "$deployment_location" ]] \
  || { usage >&2; fail 'All approved scope options are required.'; }
[[ "$approved_subscription_id" =~ ^[0-9a-fA-F-]{36}$ ]] || fail 'Approved subscription ID must be a GUID.'
[[ "$approved_application_insights_resource_id" == /subscriptions/* ]] || fail 'Approved Application Insights resource ID must be an Azure resource ID.'

for command_name in az jq python grep; do require_command "$command_name"; done
for path in \
  "$artifact_root/infra/main.bicep" \
  "$artifact_root/infra/main.bicepparam" \
  "$artifact_root/cost/budget.bicep" \
  "$artifact_root/cost/budget.bicepparam" \
  "$artifact_root/telemetry/telemetry-contract.json" \
  "$artifact_root/governance/data-retention-decision.md" \
  "$artifact_root/governance/prompt-response-logging-decision.md" \
  "$artifact_root/cost/cost-allocation.md" \
  "$artifact_root/monitoring/workbook.json" \
  "$artifact_root/operations/incident-runbook.md" \
  "$artifact_root/queries/request-error-rate-alert.kql" \
  "$artifact_root/queries/tool-failure-alert.kql" \
  "$artifact_root/queries/quality-safety-alert.kql"; do
  [[ -f "$path" ]] || fail "Required implementation artifact is missing: $path"
done

covered_decision_sentinels=(
  "__REQUIRED_ACTION_GROUP_RESOURCE_ID__"
  "__REQUIRED_APPLICATION_INSIGHTS_RESOURCE_ID__"
  "__REQUIRED_APPLICATION_TAG__"
  "__REQUIRED_BUDGET_END_DATE__"
  "__REQUIRED_BUDGET_NAME__"
  "__REQUIRED_BUDGET_START_DATE__"
  "__REQUIRED_COST_CENTER__"
  "__REQUIRED_COST_NOTIFICATION_EMAIL__"
  "__REQUIRED_COST_OWNER__"
  "__REQUIRED_DAILY_CAP_DECISION__"
  "__REQUIRED_DATA_CLASSIFICATION__"
  "__REQUIRED_DATA_PROTECTION_OWNER__"
  "__REQUIRED_DATA_RESIDENCY_STATUS_CONFIRMED__"
  "__REQUIRED_DATA_RETENTION_OWNER__"
  "__REQUIRED_DEPLOYMENT_LOCATION__"
  "__REQUIRED_EXCEPTION_PATH_STATUS_DISABLED_OR_APPROVED__"
  "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__"
  "__REQUIRED_MONTHLY_BUDGET_AMOUNT__"
  "__REQUIRED_OBSERVABILITY_OWNER__"
  "__REQUIRED_PRIVATE_ACCESS_STATUS_YES__"
  "__REQUIRED_QUALITY_FAILURE_COUNT__"
  "__REQUIRED_REQUEST_ERROR_RATE_PERCENT__"
  "__REQUIRED_RETENTION_DAYS__"
  "__REQUIRED_SAMPLING_STRATEGY_FIXED_OR_RATE_LIMITED__"
  "__REQUIRED_SAMPLING_VALUE__"
  "__REQUIRED_SERVICE_NAME__"
  "__REQUIRED_TOOL_FAILURE_COUNT__"
  "__REQUIRED_TRACE_BASED_LOG_SAMPLING_DECISION__"
  "__REQUIRED_WORKBOOK_DISPLAY_NAME__"
)
declare -A covered_sentinels=()
for sentinel in "${covered_decision_sentinels[@]}"; do
  covered_sentinels["$sentinel"]=1
done
if matches="$(grep -RnoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" || true)" && [[ -n "$matches" ]]; then
  while IFS= read -r match; do
    sentinel="${match##*:}"
    [[ -n "${covered_sentinels[$sentinel]+x}" ]] || fail "Preflight has no named coverage for customer decision $sentinel."
  done <<<"$matches"
  printf 'Resolve every required customer decision before deployment:\n%s\n' "$matches" >&2
  exit 1
fi

python - "$artifact_root" "$approved_application_insights_resource_id" "$deployment_location" <<'PY'
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
approved_app_insights = sys.argv[2]
deployment_location = sys.argv[3]

for path in root.rglob("*.json"):
    json.loads(path.read_text())

telemetry = json.loads((root / "telemetry" / "telemetry-contract.json").read_text())
if telemetry.get("schemaVersion") != 1 or telemetry.get("implementationSession") != "06-citadel-observability-operations":
    raise SystemExit("Telemetry contract has a stale schema or implementation session marker.")
if telemetry.get("propagation", {}).get("standard") != "W3C Trace Context" or telemetry["propagation"].get("correlationIdMayContainUserData"):
    raise SystemExit("Telemetry must use W3C Trace Context and reject user data in correlation IDs.")
prohibited = {
    "gen_ai.prompt", "gen_ai.completion", "ai.input.content", "ai.output.content",
    "tool.input", "tool.output", "http.request.header.authorization",
    "http.request.header.cookie", "url.query", "enduser.id", "user.email",
}
if not prohibited.issubset(set(telemetry.get("prohibitedAttributes", []))):
    raise SystemExit("Telemetry contract is missing a prohibited attribute.")
cardinality = telemetry.get("cardinality", {})
if len(cardinality.get("approvedDimensions", [])) > 5 or cardinality.get("userLevelDimensionAllowed") or cardinality.get("freeTextDimensionAllowed"):
    raise SystemExit("Token telemetry must use no more than five low-cardinality dimensions.")

def field(path: Path, heading: str, name: str) -> str:
    text = path.read_text()
    section = re.search(rf"(?ms)^{re.escape(heading)}\s*$.*?(?=^#" + r"{1,6}\s|\Z)", text)
    if not section:
        raise SystemExit(f"{path.name} is missing heading {heading!r}.")
    match = re.search(rf"(?m)^\|\s*{re.escape(name)}\s*\|\s*`?([^|`]+?)`?\s*\|\s*$", section.group())
    if not match:
        raise SystemExit(f"{path.name} is missing field {name!r}.")
    return match.group(1).strip()

retention = root / "governance" / "data-retention-decision.md"
if field(retention, "# Data retention decision", "Application Insights resource ID").casefold() != approved_app_insights.casefold():
    raise SystemExit("The retention decision does not target the approved Application Insights resource.")
days = field(retention, "# Data retention decision", "Retention days")
if not days.isdigit() or not 30 <= int(days) <= 730:
    raise SystemExit("Retention days must be an approved integer from 30 through 730.")
if field(retention, "# Data retention decision", "Data residency status") != "Confirmed" or field(retention, "# Data retention decision", "Private-access boundary status") != "Yes":
    raise SystemExit("The data residency and private-access boundary decisions must be confirmed.")

logging = root / "governance" / "prompt-response-logging-decision.md"
for name, expected in {
    "Standard content logging": "Disabled", "Prompts logged by default": "No",
    "Responses logged by default": "No", "Tool payloads logged by default": "No",
    "Query strings logged by default": "No", "Authorization headers logged by default": "No",
}.items():
    if field(logging, "## Standard telemetry", name) != expected:
        raise SystemExit(f"{logging.name} field {name!r} must be {expected!r}.")
status = field(logging, "## Exception path", "Status")
if status not in {"Disabled", "Approved"}:
    raise SystemExit("The content-logging exception status must be Disabled or Approved.")
for name in ("Purpose", "Approved scope", "Access owner", "Retention days", "Expiry date"):
    value = field(logging, "## Exception path", name)
    if (status == "Disabled" and value != "N/A") or (status == "Approved" and value == "N/A"):
        raise SystemExit("Content-logging exception details do not match the selected status.")

def parameter(path: Path, name: str) -> str:
    match = re.search(rf"(?m)^\s*param\s+{re.escape(name)}\s*=\s*'([^']+)'\s*$", path.read_text())
    if not match:
        raise SystemExit(f"Could not read string parameter {name!r} from {path}.")
    return match.group(1)

main_parameters = root / "infra" / "main.bicepparam"
if parameter(main_parameters, "applicationInsightsResourceId").casefold() != approved_app_insights.casefold():
    raise SystemExit("main.bicepparam does not target the approved Application Insights resource.")
if parameter(main_parameters, "location").casefold() != deployment_location.casefold() or parameter(main_parameters, "environment") != "nonproduction":
    raise SystemExit("Monitoring deployment parameters do not match the approved nonproduction scope.")
try:
    if float(parameter(root / "cost" / "budget.bicepparam", "amount")) <= 0:
        raise ValueError
except ValueError:
    raise SystemExit("Budget amount must be a positive number in invariant format.")
PY

current_subscription_id="$(az account show --query id -o tsv)"
[[ "$current_subscription_id" == "$approved_subscription_id" ]] || fail "Azure CLI is not set to approved subscription '$approved_subscription_id'."
app_insights_type="$(az resource show --ids "$approved_application_insights_resource_id" --api-version 2020-02-02 --query type -o tsv)"
[[ "${app_insights_type,,}" == "microsoft.insights/components" ]] || fail 'The approved Application Insights resource could not be resolved.'
action_group_id="$(python - "$artifact_root/infra/main.bicepparam" <<'PY'
import re, sys
from pathlib import Path
match = re.search(r"(?m)^\s*param\s+actionGroupResourceId\s*=\s*'([^']+)'\s*$", Path(sys.argv[1]).read_text())
if not match:
    raise SystemExit(1)
print(match.group(1))
PY
)"
action_group_type="$(az resource show --ids "$action_group_id" --query type -o tsv)"
[[ "${action_group_type,,}" == "microsoft.insights/actiongroups" ]] || fail 'The approved Azure Monitor action group could not be resolved.'

az bicep build --file "$artifact_root/infra/main.bicep" --stdout >/dev/null
az bicep build --file "$artifact_root/cost/budget.bicep" --stdout >/dev/null

printf 'Preview 1 of 2: workbook and alert rules in /subscriptions/%s/resourceGroups/%s\n' "$approved_subscription_id" "$approved_resource_group_name"
az deployment group what-if \
  --subscription "$approved_subscription_id" \
  --resource-group "$approved_resource_group_name" \
  --template-file "$artifact_root/infra/main.bicep" \
  --parameters "$artifact_root/infra/main.bicepparam" \
  --no-pretty-print

printf 'Preview 2 of 2: budget in /subscriptions/%s\n' "$approved_subscription_id"
az deployment sub what-if \
  --subscription "$approved_subscription_id" \
  --location "$deployment_location" \
  --template-file "$artifact_root/cost/budget.bicep" \
  --parameters "$artifact_root/cost/budget.bicepparam" \
  --no-pretty-print

printf 'PASS: scope, decisions, telemetry privacy, Bicep compilation, and both previews are ready.\n'
