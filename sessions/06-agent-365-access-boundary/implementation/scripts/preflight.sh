#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
deployment_path="$artifact_root/agent-deployment.json"
approved_target_scope="nonproduction-agent365-group-pilot"
required_sentinels=(
  "__REQUIRED_AGENT_ALIAS__"
  "__REQUIRED_AGENT_PLATFORM__"
  "__REQUIRED_AGENT_REGISTRY_ID__"
  "__REQUIRED_APPROVED_USE_CASE__"
  "__REQUIRED_EXCLUDED_USER_ALIAS__"
  "__REQUIRED_HOST_PRODUCT__"
  "__REQUIRED_TENANT_ALIAS__"
  "__REQUIRED_TEST_GROUP_ALIAS__"
  "__REQUIRED_TEST_GROUP_MEMBER_ALIAS__"
  "__REQUIRED_TEST_GROUP_OBJECT_ID__"
)

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || fail "jq is required."
[[ -f "$deployment_path" ]] || fail "Required Agent 365 deployment configuration is missing: $deployment_path"

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
  fail "Resolve every Session 06 group-deployment decision before changing Microsoft 365 state: ${unresolved_sentinels[*]}"
fi

[[ $(jq -r '.implementationSession' "$deployment_path") == "06-agent-365-access-boundary" ]] ||
  fail "agent-deployment.json has the wrong implementationSession marker."
[[ $(jq -r '.targetScope' "$deployment_path") == "$approved_target_scope" ]] ||
  fail "agent-deployment.json must use the approved target scope '$approved_target_scope'."
[[ $(jq -r '.agent.requiredStatus' "$deployment_path") == "Available" ]] ||
  fail "The selected Agent Registry agent must be Available before installation."
[[ $(jq -r '.deployment.adminConsent' "$deployment_path") == "Approved" ]] ||
  fail "The Entra owner must approve the requested agent permissions before installation."
[[ $(jq -r '.deployment.action' "$deployment_path") == "PrepareOnly" &&
   $(jq -r '.deployment.restoreAction' "$deployment_path") == "NoInstallationToRemove" ]] ||
  fail "Session 06 prepares the scoped deployment only. Session 10 may install it after DLP confirmation."
[[ $(jq -r '.dataBoundary.allowedData' "$deployment_path") == "SyntheticOnly" &&
   $(jq -r '.dataBoundary.userAccess' "$deployment_path") == "WithheldPendingSession10DlpConfirmation" ]] ||
  fail "Session 06 permits synthetic-data setup only. Withhold user access until Session 10 confirms the DLP policy."
[[ $(jq -r '.deployment.hostProducts | length' "$deployment_path") == "1" ]] ||
  fail "Configure exactly one approved host product for the scoped pilot."
[[ -n $(jq -r '.deployment.hostProducts[0]' "$deployment_path") ]] ||
  fail "Configure exactly one approved host product for the scoped pilot."

echo "No read-only deployment preview is supported for this Microsoft 365 admin center action. Preflight validates the approved target scope and the exact change contract."
echo "PASS: The Agent 365 deployment contract is complete for one Available agent, one test group, one host product, approved permission consent, and an uninstall restore path."
