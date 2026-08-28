#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
artifact_root="$(cd -- "$script_dir/../artifacts" && pwd)"

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-subscription-id <id> --resource-group-name <name> --foundry-account-name <name> --operator-object-id <id> [--confirm-manual-data-zone] [--confirm-manual-lifecycle] [--confirm-manual-quota]

Validate the Session 04 approval record, deployment plan, Azure scope, operator role, live model
availability and lifecycle, quota when Azure exposes an exact usage metric, Bicep, and what-if.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

run_capture() {
  local output
  if output="$("$@" 2>&1)"; then
    printf '%s' "$output"
    return 0
  fi
  [[ -n "$output" ]] && printf '%s\n' "$output" >&2
  return 1
}

approved_subscription_id=""
resource_group_name=""
foundry_account_name=""
operator_object_id=""
confirm_manual_data_zone=false
confirm_manual_lifecycle=false
confirm_manual_quota=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      approved_subscription_id="$2"
      shift 2
      ;;
    --resource-group-name)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      resource_group_name="$2"
      shift 2
      ;;
    --foundry-account-name)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      foundry_account_name="$2"
      shift 2
      ;;
    --operator-object-id)
      [[ $# -ge 2 ]] || die "Missing value for $1"
      operator_object_id="$2"
      shift 2
      ;;
    --confirm-manual-quota)
      confirm_manual_quota=true
      shift
      ;;
    --confirm-manual-lifecycle)
      confirm_manual_lifecycle=true
      shift
      ;;
    --confirm-manual-data-zone)
      confirm_manual_data_zone=true
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

[[ -n "$approved_subscription_id" ]] || { usage >&2; die '--approved-subscription-id is required.'; }
[[ -n "$resource_group_name" ]] || { usage >&2; die '--resource-group-name is required.'; }
[[ -n "$foundry_account_name" ]] || { usage >&2; die '--foundry-account-name is required.'; }
[[ -n "$operator_object_id" ]] || { usage >&2; die '--operator-object-id is required.'; }
command -v az >/dev/null 2>&1 || die 'Azure CLI is required.'
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required.'

required_sentinels=(
  '__REQUIRED_APPROVAL_ID__'
  '__REQUIRED_APPROVED_MODEL_FORMAT__'
  '__REQUIRED_APPROVED_MODEL_NAME__'
  '__REQUIRED_APPROVED_MODEL_VERSION__'
  '__REQUIRED_CHANGE_NOTIFICATION_ROUTE__'
  '__REQUIRED_DECISION_AUTHORITY__'
  '__REQUIRED_DEPLOYMENT_CAPACITY_REPLACE_WITH_JSON_INTEGER__'
  '__REQUIRED_DEPLOYMENT_NAME__'
  '__REQUIRED_DEPLOYMENT_SKU__'
  '__REQUIRED_EXTERNAL_DECISION_REFERENCE__'
  '__REQUIRED_FOUNDRY_ACCOUNT_NAME__'
  '__REQUIRED_LIFECYCLE_OWNER__'
  '__REQUIRED_MINIMUM_UNUSED_QUOTA_PERCENT_REPLACE_WITH_JSON_INTEGER__'
  '__REQUIRED_PROCESSING_LOCATION_REQUIREMENT__'
  '__REQUIRED_RAI_POLICY_NAME__'
  '__REQUIRED_REVIEW_DATE__'
  '__REQUIRED_WORKLOAD_PURPOSE__'
)

template_path="$artifact_root/infra/models/main.bicep"
parameter_path="$artifact_root/environments/sandbox.bicepparam"
profile_path="$artifact_root/models/deployment-profiles.json"
approval_path="$artifact_root/governance/model-approval-record.json"
for path in "$template_path" "$parameter_path" "$profile_path" "$approval_path"; do
  [[ -f "$path" ]] || die "Required implementation file is missing: ${path#"$artifact_root/"}"
done

REQUIRED_SENTINELS="$(printf '%s\n' "${required_sentinels[@]}")" \
python3 - "$artifact_root" "$foundry_account_name" <<'PY'
from datetime import date
import json
import os
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
foundry_name = sys.argv[2]
unresolved = sorted({
    match
    for path in root.rglob("*")
    if path.is_file()
    for match in re.findall(r"__REQUIRED_[A-Z0-9_]+__", path.read_text(encoding="utf-8"))
})
if unresolved:
    known = set(os.environ["REQUIRED_SENTINELS"].splitlines())
    unknown = [item for item in unresolved if item not in known]
    if unknown:
        raise SystemExit("Add explicit checks for new Session 04 decisions: " + ", ".join(unknown))
    raise SystemExit("Resolve all Session 04 decisions before deployment: " + ", ".join(unresolved))

profiles = json.loads((root / "models/deployment-profiles.json").read_text(encoding="utf-8"))
record = json.loads((root / "governance/model-approval-record.json").read_text(encoding="utf-8"))
for item, label in ((profiles, "deployment profiles"), (record, "approval record")):
    if item.get("implementationSession") != "04-model-governance-lifecycle":
        raise SystemExit(f"The {label} has the wrong implementation marker.")

deployments = profiles.get("deployments")
approvals = record.get("approvals")
if not isinstance(deployments, list) or not deployments:
    raise SystemExit("deployment-profiles.json must contain at least one deployment.")
if not isinstance(approvals, list) or not approvals:
    raise SystemExit("model-approval-record.json must contain at least one approval.")

allowed_skus = {
    "GlobalStandard", "GlobalProvisionedManaged", "GlobalBatch",
    "DataZoneStandard", "DataZoneProvisionedManaged", "DataZoneBatch",
    "Standard", "ProvisionedManaged",
}
def require_text(obj, fields, label):
    for field in fields:
        if not isinstance(obj.get(field), str) or not obj[field].strip():
            raise SystemExit(f"{label} is missing text field '{field}'.")

deployment_by_name = {}
for deployment in deployments:
    require_text(deployment, ["approvalId", "deploymentName", "raiPolicyName", "versionUpgradeOption"], "A deployment")
    require_text(deployment.get("model", {}), ["name", "version", "format"], f"Model for {deployment['deploymentName']}")
    sku = deployment.get("sku", {})
    require_text(sku, ["name"], f"SKU for {deployment['deploymentName']}")
    if deployment["deploymentName"] in deployment_by_name:
        raise SystemExit(f"Duplicate deploymentName: {deployment['deploymentName']}")
    if sku["name"] not in allowed_skus:
        raise SystemExit(f"Unsupported serverless API deployment SKU: {sku['name']}")
    if deployment["versionUpgradeOption"] != "NoAutoUpgrade":
        raise SystemExit(
            f"versionUpgradeOption must be NoAutoUpgrade for {deployment['deploymentName']}; "
            "a model version change requires a new approved record and profile change."
        )
    if isinstance(sku.get("capacity"), bool) or not isinstance(sku.get("capacity"), int) or sku["capacity"] < 1:
        raise SystemExit(f"Capacity for {deployment['deploymentName']} must be a positive integer.")
    deployment_by_name[deployment["deploymentName"]] = deployment

approval_ids = set()
linked_names = set()
for approval in approvals:
    require_text(
        approval,
        [
            "approvalId", "workloadPurpose", "decisionAuthority", "externalDecisionReference",
            "processingLocationRequirement", "lifecycleOwner", "reviewBy", "changeNotificationRoute",
        ],
        "An approval",
    )
    require_text(approval.get("model", {}), ["name", "version", "format"], f"Model for {approval['approvalId']}")
    if approval["approvalId"] in approval_ids:
        raise SystemExit(f"Duplicate approvalId: {approval['approvalId']}")
    approval_ids.add(approval["approvalId"])
    try:
        review_by = date.fromisoformat(approval["reviewBy"])
    except ValueError as exc:
        raise SystemExit(f"reviewBy must use YYYY-MM-DD for {approval['approvalId']}.") from exc
    if review_by < date.today():
        raise SystemExit(f"The approval review date has passed for {approval['approvalId']}.")
    requirement = approval["processingLocationRequirement"]
    if not re.fullmatch(r"(global|data-zone:[a-z0-9-]+|region:[a-z0-9-]+)", requirement):
        raise SystemExit(
            f"processingLocationRequirement must be global, data-zone:<zone>, or "
            f"region:<azure-region> for {approval['approvalId']}."
        )
    headroom = approval.get("minimumUnusedQuotaPercent")
    if isinstance(headroom, bool) or not isinstance(headroom, int) or not 0 <= headroom < 100:
        raise SystemExit(f"minimumUnusedQuotaPercent must be an integer from 0 to 99 for {approval['approvalId']}.")
    names = approval.get("deploymentNames")
    if not isinstance(names, list) or not names or any(not isinstance(name, str) or not name for name in names):
        raise SystemExit(f"deploymentNames must contain at least one name for {approval['approvalId']}.")
    for name in names:
        deployment = deployment_by_name.get(name)
        if not deployment:
            raise SystemExit(f"Approval {approval['approvalId']} links unknown deployment {name}.")
        if name in linked_names:
            raise SystemExit(f"Deployment {name} is linked by more than one approval.")
        linked_names.add(name)
        if deployment["approvalId"] != approval["approvalId"] or deployment["model"] != approval["model"]:
            raise SystemExit(f"Deployment {name} does not match approval {approval['approvalId']}.")
        sku_name = deployment["sku"]["name"]
        if requirement == "global" and not sku_name.startswith("Global"):
            raise SystemExit(f"Deployment {name} does not implement global processing.")
        if requirement.startswith("data-zone:") and not sku_name.startswith("DataZone"):
            raise SystemExit(f"Deployment {name} does not implement data-zone processing.")
        if requirement.startswith("region:") and sku_name not in {"Standard", "ProvisionedManaged"}:
            raise SystemExit(f"Deployment {name} does not implement regional processing.")

if linked_names != set(deployment_by_name):
    raise SystemExit("Every deployment must be linked from exactly one approval.")

parameter_text = (root / "environments/sandbox.bicepparam").read_text(encoding="utf-8")
match = re.search(r"(?m)^\s*param\s+foundryAccountName\s*=\s*'([^']+)'\s*$", parameter_text)
if not match or match.group(1) != foundry_name:
    raise SystemExit("sandbox.bicepparam must name the Foundry resource passed to preflight.")
PY

account_json="$(run_capture az account show --only-show-errors --output json)" || die 'Azure account lookup failed.'
current_subscription_id="$(printf '%s' "$account_json" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("id",""))')"
[[ "$current_subscription_id" == "$approved_subscription_id" ]] || die 'Azure CLI is not using the approved subscription.'

foundry_json="$(run_capture az cognitiveservices account show --name "$foundry_account_name" --resource-group "$resource_group_name" --only-show-errors --output json)" || die 'Foundry resource lookup failed.'
readarray -t foundry_values < <(printf '%s' "$foundry_json" | python3 -c 'import json,sys; x=json.load(sys.stdin); print(x.get("id","")); print(x.get("kind","")); print(x.get("location",""))')
expected_foundry_id="/subscriptions/$approved_subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.CognitiveServices/accounts/$foundry_account_name"
[[ "${foundry_values[0]}" == "$expected_foundry_id" ]] || die 'The Foundry resource is outside the approved subscription or resource group.'
[[ "${foundry_values[1]}" == 'AIServices' ]] || die 'The existing Foundry resource must have kind AIServices.'
foundry_location="${foundry_values[2]}"
[[ -n "$foundry_location" ]] || die 'The Foundry resource lookup did not return an account location.'

roles_json="$(run_capture az role assignment list --assignee-object-id "$operator_object_id" --fill-principal-name false --scope "$expected_foundry_id" --only-show-errors --output json)" || die 'Operator role lookup failed.'
printf '%s' "$roles_json" | python3 -c 'import json,sys; roles=json.load(sys.stdin); raise SystemExit(0 if any(x.get("roleDefinitionName") == "Cognitive Services Contributor" and x.get("scope","").lower() == sys.argv[1].lower() for x in roles) else "The operator lacks Cognitive Services Contributor on the exact Foundry resource.")' "$expected_foundry_id"

models_json="$(run_capture az cognitiveservices account list-models --name "$foundry_account_name" --resource-group "$resource_group_name" --only-show-errors --output json)" || die 'Foundry model availability lookup failed.'
existing_json="$(run_capture az cognitiveservices account deployment list --name "$foundry_account_name" --resource-group "$resource_group_name" --only-show-errors --output json)" || die 'Existing deployment lookup failed.'
if quota_json="$(run_capture az cognitiveservices usage list --location "$foundry_location" --only-show-errors --output json)"; then
  :
else
  quota_json='null'
fi

python3 - "$profile_path" "$approval_path" "$foundry_location" "$confirm_manual_data_zone" "$confirm_manual_lifecycle" "$confirm_manual_quota" \
  3< <(printf '%s\0%s\0%s' "$models_json" "$existing_json" "$quota_json") <<'PY'
import json
from datetime import date, datetime
import os
import sys

profiles = json.load(open(sys.argv[1], encoding="utf-8"))["deployments"]
approvals = json.load(open(sys.argv[2], encoding="utf-8"))["approvals"]
foundry_location = sys.argv[3].lower()
confirm_manual_data_zone = sys.argv[4] == "true"
confirm_manual_lifecycle = sys.argv[5] == "true"
confirm_manual_quota = sys.argv[6] == "true"
with os.fdopen(3, "rb") as stream:
    parts = stream.read().split(b"\0")
models, existing, usages = (json.loads(part) for part in parts)
approval_by_id = {item["approvalId"]: item for item in approvals}
existing_by_name = {item.get("name"): item for item in existing}
quota_increments = {}
headroom_by_usage = {}
manual_lifecycle = []
manual_quota = []
manual_data_zone = []

def parse_day(value):
    if not value:
        return None
    return datetime.fromisoformat(value.replace("Z", "+00:00")).date()

for deployment in profiles:
    matches = [
        item for item in models
        if item.get("name") == deployment["model"]["name"]
        and item.get("version") == deployment["model"]["version"]
        and item.get("format") == deployment["model"]["format"]
    ]
    if len(matches) != 1:
        raise SystemExit(f"Model for {deployment['deploymentName']} is not available to this Foundry resource.")
    model = matches[0]
    lifecycle = "".join(ch for ch in str(model.get("lifecycleStatus", "")).lower() if ch.isalnum())
    if not lifecycle:
        manual_lifecycle.append(f"{deployment['deploymentName']}: no lifecycleStatus was returned")
    if lifecycle in {"deprecating", "deprecated", "retired"}:
        raise SystemExit(f"Model for {deployment['deploymentName']} has lifecycle state {model.get('lifecycleStatus')}.")
    model_end = parse_day((model.get("deprecation") or {}).get("inference"))
    review_by = date.fromisoformat(approval_by_id[deployment["approvalId"]]["reviewBy"])
    requirement = approval_by_id[deployment["approvalId"]]["processingLocationRequirement"]
    if requirement.startswith("region:") and requirement.split(":", 1)[1].lower() != foundry_location:
        raise SystemExit(
            f"Regional processing for {deployment['deploymentName']} requires "
            f"{requirement.split(':', 1)[1]}, but the Foundry account is in {foundry_location}."
        )
    if requirement.startswith("data-zone:"):
        manual_data_zone.append(
            f"{deployment['deploymentName']}: confirm {foundry_location} belongs to "
            f"the approved {requirement.split(':', 1)[1]} data zone"
        )
    if model_end and model_end <= date.today():
        raise SystemExit(f"Model for {deployment['deploymentName']} has reached its inference deprecation date.")
    if model_end and review_by >= model_end:
        raise SystemExit(f"Review {deployment['approvalId']} before the live inference deprecation date {model_end}.")

    skus = [item for item in model.get("skus", []) if item.get("name") == deployment["sku"]["name"]]
    if len(skus) != 1:
        raise SystemExit(f"SKU for {deployment['deploymentName']} is not available for the exact model version.")
    sku = skus[0]
    sku_end = parse_day(sku.get("deprecationDate"))
    if sku_end and sku_end <= date.today():
        raise SystemExit(f"SKU for {deployment['deploymentName']} has reached its deprecation date.")
    if sku_end and review_by >= sku_end:
        raise SystemExit(f"Review {deployment['approvalId']} before the live SKU deprecation date {sku_end}.")
    capacity = sku.get("capacity") or {}
    requested = deployment["sku"]["capacity"]
    minimum, maximum, step = capacity.get("minimum"), capacity.get("maximum"), capacity.get("step")
    if minimum is not None and requested < int(minimum):
        raise SystemExit(f"Capacity for {deployment['deploymentName']} is below the live minimum {minimum}.")
    if maximum is not None and requested > int(maximum):
        raise SystemExit(f"Capacity for {deployment['deploymentName']} exceeds the live maximum {maximum}.")
    if step is not None and int(step) > 0 and (requested - int(minimum or 0)) % int(step):
        raise SystemExit(f"Capacity for {deployment['deploymentName']} does not follow the live step {step}.")

    usage_name = sku.get("usageName")
    if not usage_name:
        manual_quota.append(f"{deployment['deploymentName']}: model metadata has no quota usageName")
        continue
    current = existing_by_name.get(deployment["deploymentName"], {})
    current_capacity = 0
    current_model = (current.get("properties") or {}).get("model") or {}
    current_model_matches = [
        item for item in models
        if item.get("name") == current_model.get("name")
        and item.get("version") == current_model.get("version")
        and item.get("format") == current_model.get("format")
    ]
    if len(current_model_matches) == 1:
        current_sku_name = (current.get("sku") or {}).get("name")
        current_skus = [
            item for item in current_model_matches[0].get("skus", [])
            if item.get("name") == current_sku_name
        ]
        if len(current_skus) == 1 and current_skus[0].get("usageName") == usage_name:
            current_capacity = int((current.get("sku") or {}).get("capacity") or 0)
    quota_increments[usage_name] = quota_increments.get(usage_name, 0) + max(requested - current_capacity, 0)
    headroom_by_usage[usage_name] = max(
        headroom_by_usage.get(usage_name, 0),
        approval_by_id[deployment["approvalId"]]["minimumUnusedQuotaPercent"],
    )

usage_by_name = {
    (item.get("name") or {}).get("value"): item
    for item in usages or []
    if isinstance(item.get("name"), dict)
}
for usage_name, increment in quota_increments.items():
    usage = usage_by_name.get(usage_name)
    if not usage:
        manual_quota.append(f"{usage_name}: no exact live quota metric was returned")
        continue
    limit = float(usage.get("limit") or 0)
    current = float(usage.get("currentValue") or 0)
    if limit <= 0:
        raise SystemExit(f"Live quota limit for {usage_name} is zero.")
    remaining_percent = ((limit - current - increment) / limit) * 100
    if remaining_percent < headroom_by_usage[usage_name]:
        raise SystemExit(
            f"Projected unused quota for {usage_name} is {remaining_percent:.1f}%; "
            f"policy requires {headroom_by_usage[usage_name]}%."
        )

if manual_data_zone and not confirm_manual_data_zone:
    raise SystemExit(
        "Azure CLI does not expose a stable data-zone membership mapping. Verify the Foundry "
        "account location against the current Microsoft data-zone region list, then rerun with "
        "--confirm-manual-data-zone. Details: " + "; ".join(manual_data_zone)
    )
if manual_data_zone:
    print("MANUAL DATA-ZONE CHECK CONFIRMED: " + "; ".join(manual_data_zone))
if manual_lifecycle and not confirm_manual_lifecycle:
    raise SystemExit(
        "Azure CLI did not return lifecycleStatus for every model. Check the current model details "
        "and retirement notice, then rerun with --confirm-manual-lifecycle. Details: "
        + "; ".join(manual_lifecycle)
    )
if manual_lifecycle:
    print("MANUAL LIFECYCLE CONFIRMED: " + "; ".join(manual_lifecycle))
if manual_quota and not confirm_manual_quota:
    raise SystemExit(
        "Azure CLI could not map every deployment to live quota. Check the Foundry Quota page, "
        "then rerun with --confirm-manual-quota. Details: " + "; ".join(manual_quota)
    )
if manual_quota:
    print("MANUAL QUOTA CONFIRMED: " + "; ".join(manual_quota))
PY

run_capture az bicep build --file "$template_path" --stdout --only-show-errors >/dev/null || die "Bicep build failed: $template_path"
what_if_json="$(run_capture az deployment group what-if --resource-group "$resource_group_name" --name rvas-s04-preflight --template-file "$template_path" --parameters "$parameter_path" --result-format FullResourcePayloads --no-pretty-print --only-show-errors --output json)" || die 'Bicep what-if failed.'

python3 - "$expected_foundry_id" "$profile_path" \
  3< <(printf '%s' "$what_if_json") <<'PY'
import json
import os
import sys

base = sys.argv[1].lower()
profiles = json.load(open(sys.argv[2], encoding="utf-8"))["deployments"]
allowed = {f"{base}/deployments/{item['deploymentName']}".lower() for item in profiles}
with os.fdopen(3, encoding="utf-8") as stream:
    result = json.load(stream)
for change in result.get("changes", []):
    resource_id = str(change.get("resourceId", "")).lower()
    change_type = str(change.get("changeType", ""))
    if resource_id not in allowed:
        raise SystemExit(f"What-if includes an unrelated resource: {resource_id or '<missing resource ID>'}")
    if change_type not in {"Create", "Modify", "NoChange"}:
        raise SystemExit(f"What-if change {change_type} is not allowed for {resource_id}.")
PY

printf '%s\n' "$what_if_json"
printf 'PASS: Session 04 approval, deployment plan, operator role, live availability and lifecycle, quota gate, Bicep, and scoped what-if are ready.\n'
