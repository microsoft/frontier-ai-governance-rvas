#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --approved-tenant-id TENANT_ID --agent-instance-id AGENT_ID
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
}

approved_tenant_id=""
agent_instance_id=""
while (($# > 0)); do
  case "$1" in
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

[[ "$approved_tenant_id" =~ ^[0-9a-fA-F-]{36}$ ]] || fail '--approved-tenant-id must be a GUID.'
[[ -n "$agent_instance_id" ]] || fail '--agent-instance-id is required.'
require_command az
require_command python3

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
handoff_path="$artifact_root/governance/coverage-handoff.md"
query_path="$artifact_root/operations/agent-activity-audit-query.json"
[[ -f "$handoff_path" ]] || fail "Required implementation artifact is missing: $handoff_path"
[[ -f "$query_path" ]] || fail "Required implementation artifact is missing: $query_path"
grep -Fq '| Review cadence | Quarterly |' "$handoff_path" || fail 'The coverage handoff must name its quarterly review cadence.'
if grep -R -q -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root"; then
  fail 'Resolve every __REQUIRED_*__ sentinel before changing Purview state.'
fi

python3 - "$query_path" <<'PY'
import json
import sys

query = json.load(open(sys.argv[1], encoding="utf-8"))
if (
    query.get("schemaVersion") != 1
    or query.get("implementationSession") != "09-purview-data-governance"
    or query.get("microsoftGraphApplicationPermission") != "AuditLogsQuery.Read.All"
    or not isinstance(query.get("lookbackHours"), int)
    or not 1 <= query["lookbackHours"] <= 168
    or sorted(query.get("operations", [])) != sorted(["AIInvokeAgent", "AIExecuteTool", "AIInferenceCall", "AIGuardrail"])
    or sorted(query.get("safeOutputFields", [])) != sorted(["CreationDate", "Operation", "AgentId", "AgentName", "ResultStatus"])
    or not query.get("excludedContent")
):
    raise SystemExit("The Agent 365 audit query must retain its approved operations and payload-free output contract.")
PY

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

echo "PASS: Session 09 accepts the supplied tenant and agent scope, validates the payload-free audit query, and leaves Purview state in Microsoft Purview."
