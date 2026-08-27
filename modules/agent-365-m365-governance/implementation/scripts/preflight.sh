#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
approved_target_scope="nonproduction-agent365-m365-pilot"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

required_files=(
  "$artifact_root/governance/agent-inventory-template.csv"
  "$artifact_root/governance/agent-publishing-approval-checklist.md"
  "$artifact_root/identity/entra-agent-id-policy-template.json"
  "$artifact_root/connectors/connector-governance-matrix.csv"
  "$artifact_root/data/sharepoint-oversharing-assessment.md"
  "$artifact_root/defender/agent-security-hunting-queries.kql"
)

required_sentinels=(
  "__REQUIRED_ACCESS_SCOPE_ALIAS__"
  "__REQUIRED_ADVANCED_CONNECTOR_POLICY_ALIAS__"
  "__REQUIRED_AGENT_ALIAS__"
  "__REQUIRED_AGENT_MAP_NODE_ID__"
  "__REQUIRED_AGENT_OWNER_ROLE__"
  "__REQUIRED_AGENT_REGISTRY_ID__"
  "__REQUIRED_AGENT_SPONSOR_ROLE__"
  "__REQUIRED_AUTHENTICATION_MODE__"
  "__REQUIRED_BROAD_LINK_DECISION__"
  "__REQUIRED_CONDITIONAL_ACCESS_POLICY_NAME__"
  "__REQUIRED_CONNECTOR_ALIAS__"
  "__REQUIRED_CONNECTOR_OWNER_ROLE__"
  "__REQUIRED_DATA_MOVEMENT_CLASSIFICATION__"
  "__REQUIRED_DATA_OWNER_ROLE__"
  "__REQUIRED_DLP_POLICY_ALIAS__"
  "__REQUIRED_EEEU_DECISION__"
  "__REQUIRED_ENTRA_AGENT_ID__"
  "__REQUIRED_GROUNDING_ACCESS_DECISION__"
  "__REQUIRED_GROUNDING_SOURCE_ALIAS__"
  "__REQUIRED_IDENTITY_OWNER_ROLE__"
  "__REQUIRED_PUBLISHING_APPROVER_ROLE__"
  "__REQUIRED_RETIREMENT_REVIEW_DATE__"
  "__REQUIRED_REVIEW_DATE__"
  "__REQUIRED_SENSITIVE_CONTENT_DECISION__"
  "__REQUIRED_SHAREPOINT_OWNER_ROLE__"
  "__REQUIRED_STALE_ACCESS_DECISION__"
)

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
}

require_command python3

for path in "${required_files[@]}"; do
  [[ -f "$path" ]] || fail "Required module artifact is missing: $path"
done

mapfile -t unresolved_sentinels < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved_sentinels[@]} > 0)); then
  unknown=()
  for sentinel in "${unresolved_sentinels[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      if [[ "$required" == "$sentinel" ]]; then
        known=true
        break
      fi
    done
    $known || unknown+=("$sentinel")
  done
  if ((${#unknown[@]} > 0)); then
    fail "Add explicit Agent 365 module preflight checks for new sentinels: ${unknown[*]}"
  fi
  grep -R -n -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" >&2
  fail "Resolve every Agent 365 governance decision before owner review."
fi

python3 - "$artifact_root/identity/entra-agent-id-policy-template.json" <<'PY'
import json
import sys
record = json.load(open(sys.argv[1], encoding="utf-8"))
if record.get("implementationModule") != "agent-365-m365-governance":
    raise SystemExit("The Entra Agent ID policy template has the wrong implementationModule marker.")
if record.get("conditionalAccess", {}).get("mode") != "ReportOnly":
    raise SystemExit("The module starts Conditional Access in ReportOnly mode.")
PY

echo "PASS: Agent 365 governance artifacts are present for approved target scope '$approved_target_scope' and customer decisions are resolved."
