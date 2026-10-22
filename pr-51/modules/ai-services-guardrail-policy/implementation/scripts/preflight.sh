#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --target-scope SCOPE --deployment-location REGION [--artifacts-path PATH]

Validates the optional guardrail policy module artifacts, exact approved target scope,
required decisions, effect choices, Bicep syntax, and subscription-scope what-if previews.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

target_scope=""
deployment_location=""
artifacts_path=""
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
    --artifacts-path)
      (($# >= 2)) || fail "--artifacts-path requires a value."
      artifacts_path="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown option: $1"
      ;;
  esac
done

[[ -n "$target_scope" ]] || fail "--target-scope is required."
[[ -n "$deployment_location" ]] || fail "--deployment-location is required."

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if [[ -z "$artifacts_path" ]]; then
  artifacts_path="$script_dir/../artifacts"
fi
artifacts_path="$(cd -- "$artifacts_path" && pwd -P)"

required_files=(
  "policy/definitions/restrict-foundry-deployment-sku.json"
  "policy/guardrail-decisions.json"
  "policy/initiative.bicep"
  "policy/assignment.bicep"
  "environments/initiative.bicepparam"
  "environments/assignment.bicepparam"
)
for relative in "${required_files[@]}"; do
  [[ -f "$artifacts_path/$relative" ]] || fail "Required implementation artifact is missing: $relative"
done

required_sentinels=(
  "__REQUIRED_ALLOWED_RESOURCE_LOCATION__"
  "__REQUIRED_CHANGE_RECORD_REFERENCE__"
  "__REQUIRED_COMPLIANCE_REVIEW_OWNER__"
  "__REQUIRED_DATA_RESIDENCY_OWNER__"
  "__REQUIRED_DEPLOYMENT_LOCATION__"
  "__REQUIRED_DIAGNOSTIC_REMEDIATION_ROLE_STATUS__"
  "__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__"
  "__REQUIRED_PLATFORM_POLICY_OWNER__"
  "__REQUIRED_POLICY_STATE_REVIEW_STATUS__"
  "__REQUIRED_PROMOTION_AUTHORITY__"
  "__REQUIRED_RESTORE_REFERENCE__"
  "__REQUIRED_TARGET_SCOPE_RESOURCE_ID__"
)
mapfile -t unresolved < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifacts_path" | sort -u || true)
if ((${#unresolved[@]} > 0)); then
  unknown=()
  for sentinel in "${unresolved[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      [[ "$sentinel" == "$required" ]] && known=true && break
    done
    $known || unknown+=("$sentinel")
  done
  ((${#unknown[@]} == 0)) || fail "Add explicit preflight coverage for new sentinel(s): ${unknown[*]}."
  fail "Resolve every guardrail policy decision before Azure what-if: ${unresolved[*]}."
fi

command -v jq >/dev/null 2>&1 || fail "jq is required."
command -v az >/dev/null 2>&1 || fail "az is required."

decision_path="$artifacts_path/policy/guardrail-decisions.json"
jq empty "$decision_path" >/dev/null
jq empty "$artifacts_path/policy/definitions/restrict-foundry-deployment-sku.json" >/dev/null

[[ "$(jq -r '.implementationSession' "$decision_path")" == "optional-module-ai-services-guardrail-policy" ]] ||
  fail "guardrail-decisions.json has the wrong implementationSession marker."
[[ "$(jq -r '.targetScopeResourceId' "$decision_path")" == "$target_scope" ]] ||
  fail "Target scope must match guardrail-decisions.json targetScopeResourceId."
[[ "$(jq -r '.deploymentLocation' "$decision_path")" == "$deployment_location" ]] ||
  fail "Deployment location must match guardrail-decisions.json deploymentLocation."
[[ "$target_scope" =~ ^/subscriptions/[0-9a-fA-F-]{36}$ ]] ||
  fail "Target scope must be the approved subscription resource ID."

jq -e '
  (.effects.networkAccess | IN("Audit"; "Deny"; "Disabled"))
  and (.effects.localAuthentication | IN("Audit"; "Deny"; "Disabled"))
  and (.effects.deploymentSku | IN("Audit"; "Deny"; "Disabled"))
  and (.effects.contentFilterMinimum | IN("Audit"; "Disabled"))
  and (.effects.diagnosticLogs | IN("AuditIfNotExists"; "DeployIfNotExists"; "Disabled"))
  and (.effects.enforcementMode | IN("DoNotEnforce"; "Default"))
  and (.dataResidency.disallowedDeploymentSkus | type == "array" and length > 0)
  and (.contentFilters.minimumPromptSeverities | type == "array" and length > 0)
  and (.contentFilters.minimumCompletionSeverities | type == "array" and length > 0)
' "$decision_path" >/dev/null || fail "One or more effect, SKU, or content-filter settings are invalid."

if [[ "$(jq -r '.effects.enforcementMode' "$decision_path")" == "Default" &&
      "$(jq -r '.promotion.policyStateReviewStatus' "$decision_path")" != "Reviewed" ]]; then
  fail "Promotion to Default requires promotion.policyStateReviewStatus set to Reviewed."
fi
if [[ "$(jq -r '.effects.diagnosticLogs' "$decision_path")" == "DeployIfNotExists" &&
      "$(jq -r '.diagnosticLogs.remediationRoleStatus' "$decision_path")" != "LogAnalyticsContributorApproved" ]]; then
  fail "Diagnostic DeployIfNotExists requires remediationRoleStatus=LogAnalyticsContributorApproved."
fi

az bicep build --file "$artifacts_path/policy/initiative.bicep" --stdout >/dev/null
az bicep build --file "$artifacts_path/policy/assignment.bicep" --stdout >/dev/null
az bicep build-params --file "$artifacts_path/environments/initiative.bicepparam" --stdout >/dev/null
az bicep build-params --file "$artifacts_path/environments/assignment.bicepparam" --stdout >/dev/null

account_id="$(az account show --query id --output tsv --only-show-errors)"
scope_subscription="$(sed -E 's#^/subscriptions/([^/]+).*#\1#' <<<"$target_scope")"
[[ "${account_id,,}" == "${scope_subscription,,}" ]] ||
  fail "Azure CLI is not set to the approved subscription in --target-scope."

printf 'Preview 1 of 2: initiative and custom SKU policy in subscription %s.\n' "$account_id"
az deployment sub what-if \
  --location "$deployment_location" \
  --name "optional-ai-services-guardrail-policy-initiative-preflight" \
  --template-file "$artifacts_path/policy/initiative.bicep" \
  --parameters "$artifacts_path/environments/initiative.bicepparam" \
  --no-pretty-print \
  --only-show-errors

printf 'Preview 2 of 2: staged policy assignment for %s.\n' "$target_scope"
az deployment sub what-if \
  --location "$deployment_location" \
  --name "optional-ai-services-guardrail-policy-assignment-preflight" \
  --template-file "$artifacts_path/policy/assignment.bicep" \
  --parameters "$artifacts_path/environments/assignment.bicepparam" \
  --no-pretty-print \
  --only-show-errors

printf 'PASS: files, decisions, exact target scope, syntax checks, and subscription-scope what-if previews are ready.\n'
