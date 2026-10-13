#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --target-scope /subscriptions/<subscription-id> --deployment-location <azure-region>

Validates the AI FinOps module artifacts and runs read-only Bicep previews. Do not pass secrets as
arguments.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Required command is unavailable: $1"
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
module_root="$(cd -- "$script_dir/../.." && pwd)"
artifact_root="$module_root/implementation/artifacts"
target_scope=""
deployment_location=""

while (($# > 0)); do
  case "$1" in
    --target-scope)
      (($# >= 2)) || fail "--target-scope requires a value."
      target_scope="$2"
      shift 2
      ;;
    --deployment-location)
      (($# >= 2)) || fail "--deployment-location requires a value."
      deployment_location="$2"
      shift 2
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

[[ -n "$target_scope" && -n "$deployment_location" ]] || { usage >&2; fail "Both --target-scope and --deployment-location are required."; }
[[ "$target_scope" =~ ^/subscriptions/([0-9a-fA-F-]{36})$ ]] || fail "Target scope must be the exact approved subscription scope, for example /subscriptions/<subscription-id>."
target_subscription_id="${BASH_REMATCH[1]}"

for command_name in az jq grep python3; do
  require_command "$command_name"
done

policy_template="$artifact_root/policy/tag-allocation.bicep"
policy_params="$artifact_root/policy/tag-allocation.bicepparam"
budget_template="$artifact_root/cost/ai-budget-with-filters.bicep"
budget_params="$artifact_root/cost/ai-budget-with-filters.bicepparam"
decisions_path="$artifact_root/finance/chargeback-decisions.json"
rate_table_path="$artifact_root/finance/token-rate-table.json"
apim_policy_path="$artifact_root/apim/token-chargeback-policy.xml"
query_path="$artifact_root/queries/token-chargeback.kql"

for path in \
  "$policy_template" \
  "$policy_params" \
  "$budget_template" \
  "$budget_params" \
  "$decisions_path" \
  "$rate_table_path" \
  "$apim_policy_path" \
  "$query_path"; do
  [[ -f "$path" ]] || fail "Required implementation artifact is missing: $path"
done

required_sentinels=(
  "__REQUIRED_ACTUAL_BUDGET_THRESHOLD_PERCENT__"
  "__REQUIRED_AI_BUDGET_NAME__"
  "__REQUIRED_AI_FINOPS_TARGET_SCOPE_RESOURCE_ID__"
  "__REQUIRED_AI_METER_CATEGORY__"
  "__REQUIRED_AI_RESOURCE_GROUP_NAME__"
  "__REQUIRED_APIM_PRODUCT_ID__"
  "__REQUIRED_APIM_SERVICE_NAME__"
  "__REQUIRED_APPLICATION_INSIGHTS_RESOURCE_ID__"
  "__REQUIRED_AZURE_SUBSCRIPTION_ID__"
  "__REQUIRED_BILLING_CURRENCY__"
  "__REQUIRED_BUDGET_ACTION_GROUP_RESOURCE_ID__"
  "__REQUIRED_BUDGET_END_DATE__"
  "__REQUIRED_BUDGET_START_DATE__"
  "__REQUIRED_CACHED_INPUT_TOKEN_RATE_OR_NA__"
  "__REQUIRED_CHARGEBACK_QUERY_OWNER_ROLE__"
  "__REQUIRED_COST_CENTER__"
  "__REQUIRED_COST_CENTER_FALLBACK__"
  "__REQUIRED_COST_NOTIFICATION_EMAIL__"
  "__REQUIRED_COST_OWNER_ROLE__"
  "__REQUIRED_FINANCE_APPROVED_RATE_SOURCE__"
  "__REQUIRED_FORECAST_BUDGET_THRESHOLD_PERCENT__"
  "__REQUIRED_GATEWAY_POLICY_OWNER_ROLE__"
  "__REQUIRED_INPUT_TOKEN_RATE__"
  "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__"
  "__REQUIRED_MODEL_ALIAS__"
  "__REQUIRED_MODEL_ROUTE_ALIAS__"
  "__REQUIRED_MONTHLY_AI_BUDGET_AMOUNT__"
  "__REQUIRED_MONTHLY_TOKEN_QUOTA__"
  "__REQUIRED_OUTPUT_TOKEN_RATE__"
  "__REQUIRED_POLICY_ASSIGNMENT_IDENTITY_LOCATION__"
  "__REQUIRED_POLICY_ASSIGNMENT_PREFIX__"
  "__REQUIRED_POLICY_REMEDIATION_PLAN_REFERENCE__"
  "__REQUIRED_RATE_EFFECTIVE_DATE__"
  "__REQUIRED_RATE_NOTES_OR_NA__"
  "__REQUIRED_RATE_OWNER_ROLE__"
  "__REQUIRED_RECONCILIATION_CADENCE__"
  "__REQUIRED_RESTORE_REFERENCE__"
  "__REQUIRED_TOKENS_PER_MINUTE__"
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
  fail "Resolve every AI FinOps decision before deployment: ${unresolved[*]}"
fi

find "$artifact_root" -name '*.json' -print0 | while IFS= read -r -d '' path; do
  jq empty "$path" >/dev/null
done

python3 - "$apim_policy_path" "$decisions_path" "$rate_table_path" "$target_scope" <<'PY'
import json
import sys
import xml.etree.ElementTree as ET

apim_path, decisions_path, rate_path, target_scope = sys.argv[1:]
ET.parse(apim_path)
with open(decisions_path, encoding="utf-8") as handle:
    decisions = json.load(handle)
with open(rate_path, encoding="utf-8") as handle:
    rates = json.load(handle)

if decisions.get("implementationModule") != "ai-finops-token-chargeback" or decisions.get("implementationSession") != "optional-module-ai-finops-token-chargeback":
    raise SystemExit("chargeback-decisions.json has the wrong module marker.")
if rates.get("implementationModule") != "ai-finops-token-chargeback" or rates.get("implementationSession") != "optional-module-ai-finops-token-chargeback":
    raise SystemExit("token-rate-table.json has the wrong module marker.")
if decisions.get("targetScope") != target_scope:
    raise SystemExit("Target scope must match chargeback-decisions.json targetScope.")
if decisions.get("budget", {}).get("budgetDoesNotStopResources") is not True:
    raise SystemExit("The budget record must state that budgets notify and do not stop resources.")
gateway = decisions.get("gateway", {})
if int(gateway.get("customMetricDimensionCount", 0)) > 5 or gateway.get("userLevelMetricDimensionAllowed") is not False or gateway.get("clientSuppliedChargebackDimensionsAllowed") is not False:
    raise SystemExit("Token metric dimensions must stay at five or fewer and cannot use user-level or client-supplied dimensions.")
mapping = gateway.get("dimensionMapping", {})
if mapping.get("costCenterSource") != "approvedProductMapping" or mapping.get("consumerSource") != "context.Subscription.Id" or mapping.get("modelRouteSource") != "approvedStaticAlias":
    raise SystemExit("Gateway chargeback dimensions must come from product mapping, APIM subscription, and an approved static model-route alias.")
required_tags = decisions.get("policy", {}).get("requiredTags", [])
if not required_tags or "CostCenter" not in required_tags:
    raise SystemExit("The tag taxonomy must include CostCenter.")
if not gateway.get("products"):
    raise SystemExit("At least one APIM product quota must be recorded.")
if not rates.get("modelRates"):
    raise SystemExit("At least one token rate row must be recorded.")
PY

expected_subscription_id="$(jq -r '.approvedSubscriptionId' "$decisions_path")"
[[ "$target_subscription_id" == "$expected_subscription_id" ]] || fail "TargetScope subscription '$target_subscription_id' must match approvedSubscriptionId '$expected_subscription_id'."
active_subscription_id="$(az account show --query id --output tsv --only-show-errors)"
[[ "$active_subscription_id" == "$expected_subscription_id" ]] || fail "Azure CLI is targeting subscription '$active_subscription_id' but the approved subscription is '$expected_subscription_id'."

az bicep build --file "$policy_template" --stdout >/dev/null
az bicep build --file "$budget_template" --stdout >/dev/null
az bicep build-params --file "$policy_params" --stdout >/dev/null
az bicep build-params --file "$budget_params" --stdout >/dev/null

printf '%s\n' "Running read-only subscription what-if for tag allocation policy."
az deployment sub what-if \
  --location "$deployment_location" \
  --parameters "$policy_params" \
  --only-show-errors

printf '%s\n' "Running read-only subscription what-if for filtered AI budget."
az deployment sub what-if \
  --location "$deployment_location" \
  --parameters "$budget_params" \
  --only-show-errors

printf "PASS: AI FinOps preflight completed for approved scope '%s'.\n" "$target_scope"
