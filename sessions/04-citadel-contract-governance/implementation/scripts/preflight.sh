#!/usr/bin/env bash
set -euo pipefail

# Contract and governance sentinels:
# __REQUIRED_SUBSCRIPTION_ID__ __REQUIRED_HUB_RESOURCE_GROUP__ __REQUIRED_APIM_NAME__
# __REQUIRED_APIM_IDENTITY_NAME__ __REQUIRED_FOUNDRY_ENDPOINT__ __REQUIRED_MODEL_DEPLOYMENT_NAME__
# __REQUIRED_MODEL_SKU__ __REQUIRED_MODEL_VERSION__ __REQUIRED_SPOKE_RESOURCE_GROUP__
# __REQUIRED_KEY_VAULT_NAME__ __REQUIRED_BUSINESS_UNIT__ __REQUIRED_API_CENTER_NAME__
# __REQUIRED_TOOL_OWNER__ __REQUIRED_TOOL_CONTACT__ __REQUIRED_MCP_SERVER_URL__
# __REQUIRED_MCP_AUDIENCE__ __REQUIRED_AGENT_NAME__ __REQUIRED_TOOL_DATA_CLASSIFICATION__
# __REQUIRED_FOUNDRY_MCP_CONNECTION_NAME__ __REQUIRED_BACKING_API_ID__
# __REQUIRED_BACKING_READ_OPERATION_ID__ __REQUIRED_PROHIBITED_WRITE_ACTION__
# __REQUIRED_HUMAN_CHANGE_ROUTE__ __REQUIRED_RELEASE_OWNER__ __REQUIRED_SECURITY_OWNER__
# __REQUIRED_APPROVED_READ_RECORD_ID__ __REQUIRED_ADVERSARIAL_RECORD_ID__
# __REQUIRED_MCP_CALLER_APP_ROLE__ __REQUIRED_BACKEND_AUDIENCE__
# __REQUIRED_BACKEND_AUTHORIZATION_SCOPE__ __REQUIRED_BACKEND_ROLE_DEFINITION_ID__

usage() {
  echo "Usage: preflight.sh --citadel-path PATH --resource-group NAME"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

citadel_path=""
resource_group=""
while (($#)); do
  case "$1" in
    --citadel-path) citadel_path="${2:-}"; shift 2 ;;
    --resource-group) resource_group="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown option: $1" ;;
  esac
done

[[ -n "$citadel_path" ]] || fail "--citadel-path is required."
[[ -n "$resource_group" ]] || fail "--resource-group is required."
for command_name in git az jq; do
  command -v "$command_name" >/dev/null 2>&1 || fail "$command_name is required."
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
release_path="$script_dir/../artifacts/citadel-release.json"
expected_commit="$(jq -r '.commit' "$release_path")"
actual_commit="$(git -C "$citadel_path" rev-parse HEAD)"
[[ "$actual_commit" == "$expected_commit" ]] || fail "Citadel checkout must resolve to $expected_commit."

if grep -R -q -E '__REQUIRED_[A-Z0-9_]+__' "$script_dir/../artifacts"; then
  fail "Resolve every __REQUIRED_*__ contract value before preview."
fi

for template in backendTemplate accessTemplate publishTemplate; do
  relative_path="$(jq -r --arg key "$template" '.[$key]' "$release_path")"
  [[ -f "$citadel_path/$relative_path" ]] || fail "Pinned Citadel template is missing: $relative_path"
done

az group show --name "$resource_group" --only-show-errors >/dev/null
echo "PASS: Citadel contract overlays, pinned templates, tools, and target resource group are ready."
