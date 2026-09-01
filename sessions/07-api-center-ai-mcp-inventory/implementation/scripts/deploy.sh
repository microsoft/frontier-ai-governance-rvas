#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  deploy.sh --approved-subscription-id SUBSCRIPTION_ID --session04-agent-base-url HTTPS_URL --remote-mcp-server-url HTTPS_URL
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
environment_path="$script_dir/../artifacts/environments/sandbox.json"
bicep_path="$script_dir/../artifacts/api-center/main.bicep"
openapi_path="$script_dir/../artifacts/catalog/specs/policy-assistant-agent.openapi.json"
agent_definition_path="$script_dir/../artifacts/api-center/agent-api-definition.json"
[[ -f "$environment_path" ]] || fail "Required implementation file is missing: $environment_path"
[[ -f "$bicep_path" ]] || fail "Required implementation file is missing: $bicep_path"
[[ -f "$openapi_path" ]] || fail "Required implementation file is missing: $openapi_path"
[[ -f "$agent_definition_path" ]] || fail "Required implementation file is missing: $agent_definition_path"

approved_subscription_id=""
session04_agent_base_url=""
remote_mcp_server_url=""
while (($# > 0)); do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail "--approved-subscription-id requires a value."
      approved_subscription_id=$2
      shift 2
      ;;
    --session04-agent-base-url)
      [[ $# -ge 2 ]] || fail "--session04-agent-base-url requires a value."
      session04_agent_base_url=$2
      shift 2
      ;;
    --remote-mcp-server-url)
      [[ $# -ge 2 ]] || fail "--remote-mcp-server-url requires a value."
      remote_mcp_server_url=$2
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

[[ -n "$approved_subscription_id" ]] || fail "--approved-subscription-id is required."
[[ -n "$session04_agent_base_url" ]] || fail "--session04-agent-base-url is required."
[[ -n "$remote_mcp_server_url" ]] || fail "--remote-mcp-server-url is required."

"$script_dir/preflight.sh" --approved-subscription-id "$approved_subscription_id" --session04-agent-base-url "$session04_agent_base_url" --remote-mcp-server-url "$remote_mcp_server_url"

environment_json=$(cat "$environment_path")
deployment_json=$(az deployment group create \
  --name session08-api-center-inventory \
  --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" \
  --template-file "$bicep_path" \
  --parameters \
    "apiManagementResourceGroupName=$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")" \
    "apiManagementName=$(jq -r '.apiManagementName' <<<"$environment_json")" \
    "apiCenterName=$(jq -r '.apiCenterName' <<<"$environment_json")" \
    "location=$(jq -r '.location' <<<"$environment_json")" \
    "session04AgentBaseUrl=$session04_agent_base_url" \
  --only-show-errors \
  --output json 2>&1) || fail "Session 08 API Center deployment failed.\n$deployment_json"

specification='{"name":"openapi","version":"3.0.3"}'
import_output=$(az apic api definition import-specification \
  --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" \
  --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" \
  --api-id "$(jq -r '.api.apiId' "$agent_definition_path")" \
  --version-id "$(jq -r '.api.versionId' "$agent_definition_path")" \
  --definition-id "$(jq -r '.api.definitionId' "$agent_definition_path")" \
  --format inline \
  --value @"$openapi_path" \
  --specification "$specification" \
  --only-show-errors \
  --output none 2>&1) || fail "Importing the authoritative agent OpenAPI definition failed.\n$import_output"

apim_id="/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")/providers/Microsoft.ApiManagement/service/$(jq -r '.apiManagementName' <<<"$environment_json")"
existing_integration=$(az apic integration show --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" --integration-name "$(jq -r '.integrationName' <<<"$environment_json")" --only-show-errors --output json 2>/dev/null || true)
if [[ -n "$existing_integration" ]]; then
  [[ "$existing_integration" == *"$apim_id"* ]] || fail 'The current integration name points to a different API source.'
  echo 'The current APIM integration already exists.'
else
  integration_output=$(az apic integration create apim \
    --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" \
    --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" \
    --integration-name "$(jq -r '.integrationName' <<<"$environment_json")" \
    --azure-apim "$apim_id" \
    --import-specification always \
    --target-lifecycle-stage testing \
    --only-show-errors \
    --output none 2>&1) || fail "Creating the Session 07 APIM integration failed.\n$integration_output"
fi

echo 'Deployed the marked Session 08 API Center control.'
echo "API Center: $(jq -r '.properties.outputs.apiCenterId.value // empty' <<<"$deployment_json")"
echo 'APIM synchronization can take up to 24 hours.'
echo "Confirm the current '$(jq -r '.apiCenterPlan' <<<"$environment_json")' plan in the API Center portal; the stable 2024-03-01 Bicep service resource does not expose plan selection."
echo 'Register the registered remote MCP server through the current native API Center portal flow, using only the supplied runtime URL.'
echo 'After synchronization and MCP registration, run check-inventory.sh with the portal MCP title.'
