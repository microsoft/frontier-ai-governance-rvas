#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --target-scope one-approved-fabric-ai-grounding-lakehouse [--artifact-root PATH]

Checks local Fabric, Purview, and access-check artifacts before any service change.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

target_scope=""
artifact_root=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-scope)
      [[ $# -ge 2 ]] || fail "--target-scope requires a value."
      target_scope="$2"
      shift 2
      ;;
    --artifact-root)
      [[ $# -ge 2 ]] || fail "--artifact-root requires a value."
      artifact_root="$2"
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

command -v grep >/dev/null 2>&1 || fail "Required command is unavailable: grep"

required_target_scope="one-approved-fabric-ai-grounding-lakehouse"
module_marker="optional-module-fabric-purview-ai-data-governance"
[[ "$target_scope" == "$required_target_scope" ]] ||
  fail "--target-scope must be $required_target_scope."

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if [[ -z "$artifact_root" ]]; then
  artifact_root="$script_dir/../artifacts"
fi
artifact_root="$(cd -- "$artifact_root" && pwd -P)"

required_files=(
  "fabric/tenant-settings-baseline.json"
  "fabric/onelake-ai-consumer-role.json"
  "purview/fabric-label-dlp-decision.json"
  "verification/access-check-plan.json"
)
for relative_path in "${required_files[@]}"; do
  [[ -f "$artifact_root/$relative_path" ]] ||
    fail "Required implementation artifact is missing: $relative_path"
done

required_sentinels=(
  "__REQUIRED_AI_CONSUMER_GROUP_NAME__"
  "__REQUIRED_AI_CONSUMER_GROUP_OBJECT_ID__"
  "__REQUIRED_ALLOWED_COLUMN_NAME__"
  "__REQUIRED_APPROVED_ITEMS_REVIEW_OWNER__"
  "__REQUIRED_BLOCKED_ERROR_OR_EMPTY_RESULT__"
  "__REQUIRED_COPILOT_CAPACITY_ADMIN_GROUP__"
  "__REQUIRED_CURRENT_DATA_ACCESS_ROLE_ETAG__"
  "__REQUIRED_DATA_ACCESS_OWNER__"
  "__REQUIRED_DELIVERY_OWNER_ROLE__"
  "__REQUIRED_DLP_ALERT_OWNER__"
  "__REQUIRED_DLP_CHANGE_REFERENCE__"
  "__REQUIRED_DLP_RESTORE_REFERENCE__"
  "__REQUIRED_DLP_TEST_MODE_OWNER__"
  "__REQUIRED_EXPECTED_ALLOWED_RESULT_SHAPE__"
  "__REQUIRED_FABRIC_ADMIN_ROLE__"
  "__REQUIRED_FABRIC_COPILOT_AI_PILOT_GROUP__"
  "__REQUIRED_FABRIC_LAKEHOUSE_ITEM_ID__"
  "__REQUIRED_FABRIC_WORKSPACE_ID__"
  "__REQUIRED_FOUNDRY_OBSERVABILITY_OWNER__"
  "__REQUIRED_GOLD_LAKEHOUSE_NAME__"
  "__REQUIRED_GOLD_TABLE_NAME__"
  "__REQUIRED_LABEL_DISPLAY_NAME__"
  "__REQUIRED_LABEL_GUID__"
  "__REQUIRED_PERMITTED_CONSUMER_ALIAS__"
  "__REQUIRED_PROTECTION_POLICY_REFERENCE__"
  "__REQUIRED_PURVIEW_DLP_POLICY_NAME__"
  "__REQUIRED_PURVIEW_POLICY_OWNER__"
  "__REQUIRED_RESTRICTED_CONSUMER_ALIAS__"
  "__REQUIRED_RESTRICTED_CONSUMER_GROUP_OBJECT_ID__"
  "__REQUIRED_RLS_PREDICATE__"
  "__REQUIRED_TARGET_TENANT_ID__"
  "__REQUIRED_TENANT_BASELINE_OWNER__"
)

mapfile -t unresolved < <(
  grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" --exclude='README.md' | sort -u || true
)
if ((${#unresolved[@]} > 0)); then
  for sentinel in "${unresolved[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      [[ "$required" != "$sentinel" ]] || known=true
    done
    $known || fail "Add an explicit preflight check for the new decision: $sentinel"
  done
  printf 'Unresolved decision: %s\n' "${unresolved[@]}" >&2
  fail "Resolve every Fabric, Purview, and access-check decision before any service change."
fi

for command in az jq; do
  command -v "$command" >/dev/null 2>&1 || fail "Required command is unavailable: $command"
done

tenant_baseline="$artifact_root/fabric/tenant-settings-baseline.json"
onelake_role="$artifact_root/fabric/onelake-ai-consumer-role.json"
dlp_decision="$artifact_root/purview/fabric-label-dlp-decision.json"
access_plan="$artifact_root/verification/access-check-plan.json"

for file in "$tenant_baseline" "$onelake_role" "$dlp_decision" "$access_plan"; do
  [[ "$(jq -r '.implementationSession' "$file")" == "$module_marker" ]] ||
    fail "$file has the wrong implementationSession marker."
  [[ "$(jq -r '.targetScope' "$file")" == "$required_target_scope" ]] ||
    fail "$file targetScope must be $required_target_scope."
done

tenant_id="$(jq -r '.tenantId' "$tenant_baseline")"
[[ "$(jq -r '.tenantId' "$onelake_role")" == "$tenant_id" ]] ||
  fail "Tenant IDs must match between tenant-settings-baseline.json and onelake-ai-consumer-role.json."

workspace_id="$(jq -r '.fabric.workspaceId' "$onelake_role")"
item_id="$(jq -r '.fabric.lakehouseItemId' "$onelake_role")"
[[ "$(jq -r '.fabricItem.workspaceId' "$dlp_decision")" == "$workspace_id" ]] ||
  fail "Purview workspace ID must match the OneLake artifact."
[[ "$(jq -r '.fabricItem.lakehouseItemId' "$dlp_decision")" == "$item_id" ]] ||
  fail "Purview lakehouse item ID must match the OneLake artifact."
[[ "$(jq -r '.fabric.workspaceId' "$access_plan")" == "$workspace_id" ]] ||
  fail "Access plan workspace ID must match the OneLake artifact."
[[ "$(jq -r '.fabric.lakehouseItemId' "$access_plan")" == "$item_id" ]] ||
  fail "Access plan lakehouse item ID must match the OneLake artifact."

role_member_count="$(jq '[.rolePayload.value[] | select(.name=="AiGroundingConsumerRead") | .members.microsoftEntraMembers[]? | select(.objectType=="Group")] | length' "$onelake_role")"
[[ "$role_member_count" == "1" ]] ||
  fail "The OneLake role must name one Microsoft Entra group member."

expected_member="$(jq -r '.accessBoundary.aiConsumerGroupObjectId' "$onelake_role")"
actual_member="$(jq -r '.rolePayload.value[] | select(.name=="AiGroundingConsumerRead") | .members.microsoftEntraMembers[]? | select(.objectType=="Group") | .objectId' "$onelake_role")"
[[ "$actual_member" == "$expected_member" ]] ||
  fail "The OneLake role member must match accessBoundary.aiConsumerGroupObjectId."
actual_member_tenant="$(jq -r '.rolePayload.value[] | select(.name=="AiGroundingConsumerRead") | .members.microsoftEntraMembers[]? | select(.objectType=="Group") | .tenantId' "$onelake_role")"
approved_tenant="$(jq -r '.tenantId' "$onelake_role")"
[[ "$actual_member_tenant" == "$approved_tenant" ]] ||
  fail "The OneLake role member tenant must match the approved tenant."

[[ "$(jq -r '.dlpPolicy.location' "$dlp_decision")" == "Fabric" ]] ||
  fail "The DLP policy location must be Fabric."
[[ "$(jq -r '.dlpPolicy.mode' "$dlp_decision")" == "simulation" ]] ||
  fail "The DLP policy mode must be simulation."
[[ "$(jq '.checks | length' "$access_plan")" == "2" ]] ||
  fail "The access-check plan must contain intended-path and blocked-path checks."

echo "PASS: local artifacts, target scope, owner records, and role payload are ready."
echo "PREVIEW: OneLake role application supports Fabric REST dryRun=true with If-Match. Purview DLP uses portal simulation mode; this module has no read-only API deployment preview for the DLP policy."
