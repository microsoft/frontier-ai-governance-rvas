#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --phase dlp|install --approved-tenant-id TENANT_ID --agent-instance-id AGENT_ID
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
}

phase=""
approved_tenant_id=""
agent_instance_id=""
while (($# > 0)); do
  case "$1" in
    --phase)
      [[ $# -ge 2 ]] || fail '--phase requires a value.'
      phase=$2
      shift 2
      ;;
    --approved-tenant-id)
      [[ $# -ge 2 ]] || fail '--approved-tenant-id requires a value.'
      approved_tenant_id=$2
      shift 2
      ;;
    --agent-instance-id)
      [[ $# -ge 2 ]] || fail '--agent-instance-id requires a value.'
      agent_instance_id=$2
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

[[ "$phase" == "dlp" || "$phase" == "install" ]] || fail '--phase must be dlp or install.'
[[ "$approved_tenant_id" =~ ^[0-9a-fA-F-]{36}$ ]] || fail '--approved-tenant-id must be a GUID.'
[[ -n "$agent_instance_id" ]] || fail '--agent-instance-id is required.'
require_command jq
require_command python3

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
deployment_path="$artifact_root/agent-deployment.json"
handoff_path="$artifact_root/governance/coverage-handoff.md"
query_path="$artifact_root/operations/agent-activity-audit-query.json"
approved_target_scope="nonproduction-agent365-group-pilot"
supported_platforms=("foundry" "copilot-studio" "agent-builder")
required_sentinels=(
  "__REQUIRED_AGENT_ALIAS__"
  "__REQUIRED_AGENT_INSTANCE_ID__"
  "__REQUIRED_AGENT_PLATFORM__"
  "__REQUIRED_AGENT_REGISTRY_ID__"
  "__REQUIRED_APPROVED_USE_CASE__"
  "__REQUIRED_DLP_POLICY_STATE__"
  "__REQUIRED_DLP_PROPAGATION_STATE__"
  "__REQUIRED_EXCLUDED_USER_ALIAS__"
  "__REQUIRED_HOST_PRODUCT__"
  "__REQUIRED_TENANT_ALIAS__"
  "__REQUIRED_TEST_GROUP_ALIAS__"
  "__REQUIRED_TEST_GROUP_MEMBER_ALIAS__"
  "__REQUIRED_TEST_GROUP_OBJECT_ID__"
)

for path in "$deployment_path" "$handoff_path" "$query_path"; do
  [[ -f "$path" ]] || fail "Required Session 06 implementation artifact is missing: $path"
done
mapfile -t unresolved_sentinels < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved_sentinels[@]} > 0)); then
  unknown=()
  for sentinel in "${unresolved_sentinels[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      [[ "$required" == "$sentinel" ]] && known=true && break
    done
    $known || unknown+=("$sentinel")
  done
  ((${#unknown[@]} == 0)) || fail "Add explicit Session 06 preflight checks for new sentinels: ${unknown[*]}"
  fail "Resolve every Session 06 decision before changing DLP or Microsoft 365 state: ${unresolved_sentinels[*]}"
fi

[[ $(jq -r '.implementationSession' "$deployment_path") == "06-agent-365-access-boundary" ]] ||
  fail "agent-deployment.json has the wrong implementationSession marker."
[[ $(jq -r '.targetScope' "$deployment_path") == "$approved_target_scope" ]] ||
  fail "agent-deployment.json must use the approved target scope '$approved_target_scope'."
[[ $(jq -r '.agent.instanceId' "$deployment_path") == "$agent_instance_id" ]] ||
  fail 'The supplied Agent 365 instance ID must match agent.instanceId in agent-deployment.json.'
[[ $(jq -r '.agent.requiredStatus' "$deployment_path") == "Available" ]] ||
  fail "The selected Agent Registry agent must be Available before installation."
agent_platform=$(jq -r '.agent.platform' "$deployment_path")
platform_supported=false
for supported_platform in "${supported_platforms[@]}"; do
  [[ "$agent_platform" == "$supported_platform" ]] && platform_supported=true && break
done
$platform_supported || fail "agent.platform must be one of: ${supported_platforms[*]}."
[[ $(jq -r '.deployment.adminConsent' "$deployment_path") == "Approved" ]] ||
  fail "The Entra owner must approve the requested agent permissions before installation."
[[ $(jq -r '.deployment.action' "$deployment_path") == "InstallAfterDlpPropagation" &&
   $(jq -r '.deployment.restoreAction' "$deployment_path") == "RemoveScopedInstallation" ]] ||
  fail "Session 06 requires scoped installation after DLP propagation and a scoped-installation removal route."
[[ $(jq -r '.dlpGate.requiredInstallState' "$deployment_path") == "EnabledAndPropagated" ]] ||
  fail "The DLP readiness gate must require EnabledAndPropagated before installation."
[[ $(jq -r '.dataBoundary.allowedData' "$deployment_path") == "SyntheticOnly" &&
   $(jq -r '.dataBoundary.userAccess' "$deployment_path") == "ScopedAfterDlpPropagation" ]] ||
  fail "Session 06 permits labelled synthetic data and scoped access only after DLP propagation."
[[ $(jq -r '.deployment.hostProducts | length' "$deployment_path") == "1" &&
   -n $(jq -r '.deployment.hostProducts[0]' "$deployment_path") ]] ||
  fail "Configure exactly one approved host product for the scoped pilot."
grep -Fq '| Review cadence | Quarterly |' "$handoff_path" ||
  fail 'The coverage handoff must name its quarterly review cadence.'

python3 - "$query_path" <<'PY'
import json
import sys

query = json.load(open(sys.argv[1], encoding="utf-8"))
if (
    query.get("schemaVersion") != 1
    or query.get("implementationSession") != "06-agent-365-access-boundary"
    or query.get("microsoftGraphApplicationPermission") != "AuditLogsQuery.Read.All"
    or not isinstance(query.get("lookbackHours"), int)
    or not 1 <= query["lookbackHours"] <= 168
    or sorted(query.get("operations", [])) != sorted(["AIInvokeAgent", "AIExecuteTool", "AIInferenceCall", "AIGuardrail"])
    or sorted(query.get("safeOutputFields", [])) != sorted(["CreationDate", "Operation", "AgentId", "AgentName", "ResultStatus"])
    or not query.get("excludedContent")
):
    raise SystemExit("The Agent 365 audit query must retain its approved operations and payload-free output contract.")
PY

if [[ "$phase" == "dlp" ]]; then
  [[ $(jq -r '.dlpGate.policyState' "$deployment_path") == "ReadyForSimulation" &&
     $(jq -r '.dlpGate.propagationState' "$deployment_path") == "NotStarted" ]] ||
    fail 'DLP preflight requires ReadyForSimulation and NotStarted. Inspect the approved change before configuring Purview.'
  echo "PASS: Session 06 is ready to configure the scoped DLP policy in TestWithNotifications. This phase does not authorize installation."
  exit 0
fi

[[ $(jq -r '.dlpGate.policyState' "$deployment_path") == "EnabledAndPropagated" &&
   $(jq -r '.dlpGate.propagationState' "$deployment_path") == "Confirmed" ]] ||
  fail 'Installation requires the recorded EnabledAndPropagated policy state and Confirmed propagation. Inspect Purview and the approved change before updating the gate.'
require_command az
graph_token=$(az account get-access-token --tenant "$approved_tenant_id" --resource-type ms-graph --query accessToken --output tsv --only-show-errors 2>/dev/null || true)
if [[ -z "$graph_token" ]]; then
  graph_token=$(az account get-access-token --tenant "$approved_tenant_id" --scope https://graph.microsoft.com/.default --query accessToken --output tsv --only-show-errors)
fi
[[ -n "$graph_token" ]] || fail 'Unable to acquire a Microsoft Graph token for the approved tenant.'

python3 - "$graph_token" "$approved_tenant_id" <<'PY'
import base64
import json
import sys

parts = sys.argv[1].split(".")
if len(parts) != 3:
    raise SystemExit("The Microsoft Graph token is not a JWT.")
claims = json.loads(base64.urlsafe_b64decode(parts[1] + "=" * (-len(parts[1]) % 4)))
if "AuditLogsQuery.Read.All" not in claims.get("roles", []):
    raise SystemExit("The Microsoft Graph application token must include AuditLogsQuery.Read.All with administrator consent.")
if str(claims.get("tid", "")).lower() != sys.argv[2].lower():
    raise SystemExit("The Microsoft Graph application token does not identify the approved tenant.")
PY

echo "PASS: Session 06 accepts the approved scoped installation after recorded DLP propagation and validates the payload-free audit query."
