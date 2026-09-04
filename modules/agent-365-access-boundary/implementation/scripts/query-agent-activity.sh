#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  query-agent-activity.sh --agent-instance-id AGENT_ID [--start-utc ISO_8601] [--end-utc ISO_8601] [--result-size COUNT]
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
}

get_graph_token() {
  local token
  if token=$(az account get-access-token --resource-type ms-graph --query accessToken --output tsv --only-show-errors 2>/dev/null); then
    [[ -n "$token" ]] && { printf '%s' "$token"; return 0; }
  fi
  if token=$(az account get-access-token --scope https://graph.microsoft.com/.default --query accessToken --output tsv --only-show-errors 2>/dev/null); then
    [[ -n "$token" ]] && { printf '%s' "$token"; return 0; }
  fi
  fail 'Unable to acquire a Microsoft Graph token for the unified audit log query.'
}

graph_request() {
  local method=$1
  local url=$2
  local token=$3
  local body=${4:-}
  local response
  local -a args=(-sS -w $'\n%{http_code}' -X "$method" -H "Authorization: Bearer $token")
  if [[ -n "$body" ]]; then
    args+=(-H 'Content-Type: application/json' --data "$body")
  fi
  if ! response=$(curl "${args[@]}" "$url"); then
    fail "Microsoft Graph request failed: $method $url"
  fi
  GRAPH_STATUS=${response##*$'\n'}
  GRAPH_BODY=${response%$'\n'*}
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
query_path="$script_dir/../artifacts/operations/agent-activity-audit-query.json"
[[ -f "$query_path" ]] || fail "Audit query definition is missing: $query_path"

start_utc=""
end_utc=""
result_size=1000
agent_instance_id=""
while (($# > 0)); do
  case "$1" in
    --agent-instance-id)
      [[ $# -ge 2 ]] || fail '--agent-instance-id requires a value.'
      agent_instance_id=$2
      shift 2
      ;;
    --start-utc)
      [[ $# -ge 2 ]] || fail '--start-utc requires a value.'
      start_utc=$2
      shift 2
      ;;
    --end-utc)
      [[ $# -ge 2 ]] || fail '--end-utc requires a value.'
      end_utc=$2
      shift 2
      ;;
    --result-size)
      [[ $# -ge 2 ]] || fail '--result-size requires a value.'
      result_size=$2
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
[[ -n "$agent_instance_id" ]] || fail '--agent-instance-id is required.'
[[ "$result_size" =~ ^[0-9]+$ ]] || fail '--result-size must be an integer.'
(( result_size >= 1 && result_size <= 5000 )) || fail '--result-size must be between 1 and 5000.'

require_command az
require_command curl
require_command jq
require_command python3

query_json=$(cat "$query_path")
python3 - "$query_path" <<'PY'
import json
import sys

query = json.load(open(sys.argv[1], encoding="utf-8"))
if (
    query.get("schemaVersion") != 1
    or query.get("implementationSession") != "optional-module-agent-365-access-boundary"
    or query.get("microsoftGraphApplicationPermission") != "AuditLogsQuery.Read.All"
    or not isinstance(query.get("lookbackHours"), int)
    or not 1 <= query["lookbackHours"] <= 168
    or sorted(query.get("operations", [])) != sorted(["AIInvokeAgent", "AIExecuteTool", "AIInferenceCall", "AIGuardrail"])
    or sorted(query.get("safeOutputFields", [])) != sorted(["CreationDate", "Operation", "AgentId", "AgentName", "ResultStatus"])
    or not query.get("excludedContent")
):
    raise SystemExit("The Agent 365 audit query must retain its approved operations and payload-free output contract.")
PY
if [[ -z "$end_utc" ]]; then
  end_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
fi
if [[ -z "$start_utc" ]]; then
  start_utc=$(python3 - <<'PY' "$end_utc" "$(jq -r '.lookbackHours' <<<"$query_json")"
from datetime import datetime, timedelta, timezone
import sys
end = datetime.fromisoformat(sys.argv[1].replace('Z', '+00:00'))
lookback = int(sys.argv[2])
print((end - timedelta(hours=lookback)).astimezone(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'))
PY
)
fi
if ! python3 - <<'PY' "$start_utc" "$end_utc"
from datetime import datetime
import sys
start = datetime.fromisoformat(sys.argv[1].replace('Z', '+00:00'))
end = datetime.fromisoformat(sys.argv[2].replace('Z', '+00:00'))
if start >= end:
    raise SystemExit(1)
PY
then
  fail 'StartUtc must be earlier than EndUtc.'
fi

graph_token=$(get_graph_token)
python3 - "$graph_token" "$(jq -r '.microsoftGraphApplicationPermission' "$query_path")" <<'PY'
import base64
import json
import sys
parts = sys.argv[1].split('.')
if len(parts) != 3:
    raise SystemExit('The Microsoft Graph token is not a JWT.')
payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=' * (-len(parts[1]) % 4)))
if sys.argv[2] not in payload.get('roles', []):
    raise SystemExit('The Microsoft Graph application token must include AuditLogsQuery.Read.All with administrator consent.')
PY
create_body=$(jq -n --arg start "$start_utc" --arg end "$end_utc" --argjson ops "$(jq -c '.operations' <<<"$query_json")" '{displayName:"Agent 365 module Agent 365 activity query", filterStartDateTime:$start, filterEndDateTime:$end, operationFilters:$ops}')
graph_request POST 'https://graph.microsoft.com/v1.0/security/auditLog/queries' "$graph_token" "$create_body"
[[ "$GRAPH_STATUS" == '201' || "$GRAPH_STATUS" == '200' ]] || fail 'Creating the unified audit log query failed.'
query_id=$(jq -r '.id // empty' <<<"$GRAPH_BODY")
[[ -n "$query_id" ]] || fail 'The unified audit log query did not return an identifier.'

status='running'
for _ in $(seq 1 30); do
  graph_request GET "https://graph.microsoft.com/v1.0/security/auditLog/queries/$query_id" "$graph_token"
  [[ "$GRAPH_STATUS" == '200' ]] || fail 'Reading the unified audit log query status failed.'
  status=$(jq -r '.status // empty' <<<"$GRAPH_BODY")
  case "$status" in
    succeeded) break ;;
    failed|cancelled) fail "The unified audit log query finished with status '$status'." ;;
    running|notStarted|unknownFutureValue|'') sleep 5 ;;
    *) sleep 5 ;;
  esac
done
[[ "$status" == 'succeeded' ]] || fail 'The unified audit log query did not complete before the polling window ended.'

graph_request GET "https://graph.microsoft.com/v1.0/security/auditLog/queries/$query_id/records?\$top=$result_size" "$graph_token"
[[ "$GRAPH_STATUS" == '200' ]] || fail 'Retrieving unified audit log records failed.'
python3 - "$GRAPH_BODY" "$agent_instance_id" <<'PY'
import json
import sys
records = json.loads(sys.argv[1]).get('value', [])
agent_instance_id = sys.argv[2]
rows = []
for record in records:
    audit_data = record.get('auditData') or {}
    if isinstance(audit_data, str):
        try:
            audit_data = json.loads(audit_data)
        except Exception:
            audit_data = {}
    agent_id = str(audit_data.get('AgentId', ''))
    if agent_id != agent_instance_id:
        continue
    rows.append({
        'CreationDate': record.get('createdDateTime', ''),
        'Operation': record.get('operation', ''),
        'AgentId': agent_id,
        'AgentName': audit_data.get('AgentName', ''),
        'ResultStatus': audit_data.get('ResultStatus', ''),
    })
if not rows:
    print('No matching Agent 365 activity found in the selected window.')
    raise SystemExit(0)
rows.sort(key=lambda item: item['CreationDate'])
widths = {key: max(len(key), *(len(str(row[key])) for row in rows)) for key in rows[0]}
header = '  '.join(key.ljust(widths[key]) for key in rows[0])
print(header)
print('  '.join('-' * widths[key] for key in rows[0]))
for row in rows:
    print('  '.join(str(row[key]).ljust(widths[key]) for key in row))
print(f"Returned {len(rows)} payload-free activity record(s). No audit export was written.")
PY
