#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
target_scope=""
workbook_subscription_id=""
workbook_resource_group=""

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

while (($# > 0)); do
  case "$1" in
    --target-scope)
      (($# >= 2)) || fail "--target-scope requires a value."
      target_scope=$2
      shift 2
      ;;
    --workbook-subscription-id)
      (($# >= 2)) || fail "--workbook-subscription-id requires a value."
      workbook_subscription_id=$2
      shift 2
      ;;
    --workbook-resource-group)
      (($# >= 2)) || fail "--workbook-resource-group requires a value."
      workbook_resource_group=$2
      shift 2
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$target_scope" ]] || fail "--target-scope is required."
if [[ -n "$workbook_subscription_id" || -n "$workbook_resource_group" ]]; then
  [[ -n "$workbook_subscription_id" && -n "$workbook_resource_group" ]] || fail \
    "--workbook-subscription-id and --workbook-resource-group must be supplied together."
  [[ "$workbook_subscription_id" =~ ^[0-9a-fA-F-]{36}$ ]] || fail \
    "--workbook-subscription-id must be a GUID."
fi
command -v python3 >/dev/null 2>&1 || fail "python3 is required."
command -v az >/dev/null 2>&1 || fail "The Azure CLI is required."

report_script="$script_dir/build-estate-report.sh"
[[ -x "$report_script" ]] || fail \
  "The estate report cannot run because build-estate-report.sh is missing or not executable: $report_script"

scope_path="$artifact_root/estate-scope.json"
query_path="$artifact_root/queries/foundry-accounts.kql"
service_health_query_path="$artifact_root/queries/service-health-retirements.kql"
advisor_query_path="$artifact_root/queries/advisor-retirement-findings.kql"
report_python_path="$script_dir/build-estate-report.py"
workbook_template_path="$artifact_root/infra/main.bicep"
workbook_definition_path="$artifact_root/monitoring/estate-lifecycle-workbook.json"
[[ -f "$scope_path" ]] || fail "Required module artifact is missing: $scope_path"
[[ -f "$query_path" ]] || fail "Required module artifact is missing: $query_path"
[[ -f "$service_health_query_path" ]] || fail "Required module artifact is missing: $service_health_query_path"
[[ -f "$advisor_query_path" ]] || fail "Required module artifact is missing: $advisor_query_path"
[[ -f "$report_python_path" ]] || fail "The estate report helper is missing: $report_python_path"
[[ -f "$workbook_template_path" ]] || fail "Workbook deployment template is missing: $workbook_template_path"
[[ -f "$workbook_definition_path" ]] || fail "Workbook definition is missing: $workbook_definition_path"

required_sentinels=(
  "__REQUIRED_APPROVED_ESTATE_SCOPE_ALIAS__"
  "__REQUIRED_APPROVED_MANAGEMENT_GROUP_ID__"
  "__REQUIRED_APPROVED_PRIMARY_REGION__"
  "__REQUIRED_COST_TAG_KEY__"
  "__REQUIRED_ENVIRONMENT_TAG_KEY__"
  "__REQUIRED_ESTATE_REVIEW_DATE__"
  "__REQUIRED_EXCEPTION_ACCOUNT_NAME__"
  "__REQUIRED_EXCEPTION_EXPIRY_DATE__"
  "__REQUIRED_EXCEPTION_OWNER_ROLE__"
  "__REQUIRED_EXCEPTION_REASON__"
  "__REQUIRED_INVENTORY_OWNER_ROLE__"
  "__REQUIRED_LIFECYCLE_OWNER_ROLE__"
  "__REQUIRED_OWNER_TAG_KEY__"
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
  fail "Resolve every estate scope decision before the estate read: ${unresolved[*]}"
fi

az extension show --name resource-graph >/dev/null 2>&1 || fail \
  "Install the Resource Graph extension first: az extension add --name resource-graph"

python3 - "$scope_path" "$target_scope" <<'PY'
import json
import sys

scope_path, target_scope = sys.argv[1:]
with open(scope_path, encoding="utf-8") as handle:
    scope = json.load(handle)

if scope.get("implementationModule") != "foundry-estate-inventory":
    raise SystemExit("The estate scope record has the wrong implementationModule marker.")
if scope.get("implementationSession") != "foundry-estate-inventory":
    raise SystemExit("The estate scope record has the wrong implementationSession marker.")
if scope.get("approvedScope") != target_scope:
    raise SystemExit("The estate scope record must match --target-scope.")

for name in ("managementGroups", "inScopeAccountKinds", "approvedRegions", "requiredTagKeys"):
    values = scope.get(name)
    if not isinstance(values, list) or not values:
        raise SystemExit(f"{name} must be a non-empty list.")
    if any(not str(value).strip() for value in values):
        raise SystemExit(f"{name} contains an empty value.")

for key in ("ownerTagKey", "costTagKey"):
    if scope.get(key) not in scope["requiredTagKeys"]:
        raise SystemExit(f"{key} must also appear in requiredTagKeys.")

for owner in ("inventoryOwner", "lifecycleOwner"):
    if not str(scope.get(owner, "")).strip():
        raise SystemExit(f"Record the {owner} role.")

cadence = scope.get("reviewCadenceDays")
if not isinstance(cadence, int) or cadence <= 0:
    raise SystemExit("reviewCadenceDays must be a positive whole number of days.")

warning_days = scope.get("modelRetirementWarningDays")
if not isinstance(warning_days, int) or warning_days <= 0:
    raise SystemExit("modelRetirementWarningDays must be a positive whole number of days.")

for exception in scope.get("recordedExceptions", []):
    for field in ("accountName", "reason", "owner", "expiryDate"):
        if not str(exception.get(field, "")).strip():
            raise SystemExit(f"Every recorded exception needs {field}.")

print(
    f"Estate scope covers {len(scope['managementGroups'])} management group(s), "
    f"{len(scope['inScopeAccountKinds'])} account kind(s), and "
    f"{len(scope['requiredTagKeys'])} required tag key(s)."
)
PY

echo "Checking read access to the approved management groups..."
mapfile -t management_groups < <(python3 -c "
import json, sys
with open(sys.argv[1], encoding='utf-8') as handle:
    print('\n'.join(json.load(handle)['managementGroups']))
" "$scope_path")

for group in "${management_groups[@]}"; do
  az graph query \
    --graph-query "Resources | where type =~ 'microsoft.cognitiveservices/accounts' | summarize accounts = count()" \
    --management-groups "$group" \
    --output none || fail "Cannot read management group '$group' through Resource Graph."
  echo "  read access confirmed: $group"
done

az graph query \
  --graph-query "ServiceHealthResources | where type =~ 'microsoft.resourcehealth/events' | take 1" \
  --management-groups "${management_groups[0]}" \
  --output none || fail "Cannot read Service Health events through Resource Graph."

if [[ -n "$workbook_subscription_id" ]]; then
  az group show --subscription "$workbook_subscription_id" --name "$workbook_resource_group" \
    --output none || fail "Cannot read workbook resource group '$workbook_resource_group'."
  preview=$(az deployment group what-if \
    --subscription "$workbook_subscription_id" \
    --resource-group "$workbook_resource_group" \
    --name rvas-foundry-estate-lifecycle-workbook \
    --template-file "$workbook_template_path" \
    --result-format FullResourcePayloads \
    --only-show-errors \
    --output json) || fail "The workbook deployment preview failed."
  python3 -c '
import json
import sys

preview = json.load(sys.stdin)
changes = preview.get("changes", [])
unexpected = [
    change for change in changes
    if "/providers/microsoft.insights/workbooks/" not in str(change.get("resourceId", "")).lower()
]
if unexpected:
    raise SystemExit("Workbook preview contains a resource outside the workbook scope.")
' <<<"$preview" || fail "The workbook deployment preview contains an unexpected resource."
fi

echo "PASS: The estate scope record and Resource Graph access are ready for scope '$target_scope'."
[[ -n "$workbook_subscription_id" ]] && echo "PASS: The workbook deployment preview targets '$workbook_resource_group'."
