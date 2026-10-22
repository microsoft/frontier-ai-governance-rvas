#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/verify-access.sh --target-scope one-approved-fabric-ai-grounding-lakehouse [--role-file PATH]

Reads live OneLake security roles and confirms the approved AI consumer group is present while the
restricted group is not in the role. The delivery owner still observes the live permitted and
restricted identity checks from access-check-plan.json.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

target_scope=""
role_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-scope)
      [[ $# -ge 2 ]] || fail "--target-scope requires a value."
      target_scope="$2"
      shift 2
      ;;
    --role-file)
      [[ $# -ge 2 ]] || fail "--role-file requires a value."
      role_file="$2"
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

for command in az curl jq grep; do
  command -v "$command" >/dev/null 2>&1 || fail "Required command is unavailable: $command"
done

[[ "$target_scope" == "one-approved-fabric-ai-grounding-lakehouse" ]] ||
  fail "--target-scope must be one-approved-fabric-ai-grounding-lakehouse."

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
[[ -n "$role_file" ]] || role_file="$script_dir/../artifacts/fabric/onelake-ai-consumer-role.json"
[[ -f "$role_file" ]] || fail "OneLake role file is missing: $role_file"

if grep -q -E '__REQUIRED_[A-Z0-9_]+__' "$role_file"; then
  grep -o -E '__REQUIRED_[A-Z0-9_]+__' "$role_file" | sort -u >&2
  fail "Resolve OneLake decisions before reading live roles."
fi

workspace_id="$(jq -r '.fabric.workspaceId' "$role_file")"
item_id="$(jq -r '.fabric.lakehouseItemId' "$role_file")"
expected_group="$(jq -r '.accessBoundary.aiConsumerGroupObjectId' "$role_file")"
restricted_group="$(jq -r '.accessBoundary.restrictedConsumerGroupObjectId' "$role_file")"

token="$(az account get-access-token --resource "https://api.fabric.microsoft.com" --query accessToken --output tsv --only-show-errors)"
[[ -n "$token" ]] || fail "Could not get a Fabric API access token with Azure CLI."

roles_json='[]'
uri="https://api.fabric.microsoft.com/v1/workspaces/$workspace_id/items/$item_id/dataAccessRoles"
while [[ -n "$uri" && "$uri" != "null" ]]; do
  response="$(curl -fsS -H "Authorization: Bearer $token" "$uri")"
  roles_json="$(jq -s '.[0] + (.[1].value // [])' <(printf '%s' "$roles_json") <(printf '%s' "$response"))"
  uri="$(jq -r '.continuationUri // empty' <<<"$response")"
done

role="$(jq -c '.[] | select(.name == "AiGroundingConsumerRead")' <<<"$roles_json" | head -n 1)"
[[ -n "$role" ]] || fail "Live OneLake role AiGroundingConsumerRead was not found."

jq -e --arg group "$expected_group" '(.members.microsoftEntraMembers // []) | any(.objectId == $group and .objectType == "Group")' <<<"$role" >/dev/null ||
  fail "Live OneLake role does not include the approved AI consumer group."
if jq -e --arg group "$restricted_group" '(.members.microsoftEntraMembers // []) | any(.objectId == $group)' <<<"$role" >/dev/null; then
  fail "Restricted consumer group is a member of the AI grounding role."
fi
jq -e --arg group "$restricted_group" '.accessBoundary.restrictedPrincipalsRemovedFromDefaultReader | index($group)' "$role_file" >/dev/null ||
  fail "The DefaultReader review does not record removal of the restricted consumer group."

echo "PASS: live OneLake role includes the approved AI consumer group and excludes the restricted group."
echo "NEXT: run the intended-path and blocked-path identity checks in access-check-plan.json with the delivery owner present."

