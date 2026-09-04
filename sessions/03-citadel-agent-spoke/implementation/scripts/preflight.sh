#!/usr/bin/env bash
set -euo pipefail

# Agent Spoke profile sentinels:
# __REQUIRED_SPOKE_RESOURCE_GROUP__ __REQUIRED_SPOKE_VNET_NAME__ __REQUIRED_PRIVATE_ENDPOINT_SUBNET_NAME__

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --approved-subscription-id SUBSCRIPTION_ID --resource-group-name RESOURCE_GROUP --foundry-account-name FOUNDRY_ACCOUNT --project-name PROJECT --read-api-base-url HTTPS_URL --application-insights-resource-id RESOURCE_ID
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
}

validate_https_base_url() {
  python3 - "$1" <<'PY'
import sys
from urllib.parse import urlparse
value = sys.argv[1]
uri = urlparse(value)
if uri.scheme != 'https' or uri.query or uri.fragment or not uri.netloc:
    raise SystemExit(1)
PY
}

az_json() {
  local description=$1
  shift
  local raw
  if ! raw=$(az "$@" --only-show-errors --output json 2>&1); then
    fail "$description failed.\n$raw"
  fi
  printf '%s' "$raw"
}

get_ai_token() {
  local token
  if ! token=$(az account get-access-token --scope https://ai.azure.com/.default --query accessToken --output tsv --only-show-errors 2>&1); then
    fail "Unable to acquire a Microsoft Foundry data-plane token.\n$token"
  fi
  [[ -n "$token" ]] || fail "Unable to acquire a Microsoft Foundry data-plane token."
  printf '%s' "$token"
}

api_request() {
  local method=$1
  local url=$2
  local token=$3
  local body_file=${4:-}
  API_BODY_FILE="$temp_dir/api-body.json"
  API_HEADER_FILE="$temp_dir/api-headers.txt"
  rm -f "$API_BODY_FILE" "$API_HEADER_FILE"
  local -a args=(-sS -D "$API_HEADER_FILE" -o "$API_BODY_FILE" -w '%{http_code}' -X "$method" -H "Authorization: Bearer $token")
  if [[ -n "$body_file" ]]; then
    args+=(-H 'Content-Type: application/json' --data @"$body_file")
  fi
  if ! API_STATUS=$(curl "${args[@]}" "$url"); then
    fail "Request failed: $method $url"
  fi
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
agent_root="$artifact_root/agents/policy-assistant"
config_path="$agent_root/agent.json"
instructions_path="$agent_root/instructions.md"
tool_path="$agent_root/tool-manifest.json"
required_sentinels=(
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_DOWNSTREAM_API_AUTHORIZATION_OWNER__"
  "__REQUIRED_DOWNSTREAM_API_READ_ROLE_ID__"
  "__REQUIRED_DOWNSTREAM_API_READ_SCOPE__"
  "__REQUIRED_HUMAN_CHANGE_ROUTE__"
  "__REQUIRED_MODEL_DEPLOYMENT_NAME__"
  "__REQUIRED_PROHIBITED_WRITE_ACTION__"
  "__REQUIRED_RAI_POLICY_NAME__"
  "__REQUIRED_READ_PATH__"
  "__REQUIRED_TARGET_AUDIENCE__"
)

approved_subscription_id=""
resource_group_name=""
foundry_account_name=""
project_name=""
read_api_base_url=""
application_insights_resource_id=""

while (($# > 0)); do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail "--approved-subscription-id requires a value."
      approved_subscription_id=$2
      shift 2
      ;;
    --resource-group-name)
      [[ $# -ge 2 ]] || fail "--resource-group-name requires a value."
      resource_group_name=$2
      shift 2
      ;;
    --foundry-account-name)
      [[ $# -ge 2 ]] || fail "--foundry-account-name requires a value."
      foundry_account_name=$2
      shift 2
      ;;
    --project-name)
      [[ $# -ge 2 ]] || fail "--project-name requires a value."
      project_name=$2
      shift 2
      ;;
    --read-api-base-url)
      [[ $# -ge 2 ]] || fail "--read-api-base-url requires a value."
      read_api_base_url=$2
      shift 2
      ;;
    --application-insights-resource-id)
      [[ $# -ge 2 ]] || fail "--application-insights-resource-id requires a value."
      application_insights_resource_id=$2
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
[[ -n "$resource_group_name" ]] || fail "--resource-group-name is required."
[[ -n "$foundry_account_name" ]] || fail "--foundry-account-name is required."
[[ -n "$project_name" ]] || fail "--project-name is required."
[[ -n "$read_api_base_url" ]] || fail "--read-api-base-url is required."
[[ -n "$application_insights_resource_id" ]] || fail "--application-insights-resource-id is required."

require_command az
require_command curl
require_command jq
require_command python3

[[ -d "$artifact_root" ]] || fail "Required implementation artifacts folder is missing: $artifact_root"
for path in "$config_path" "$instructions_path" "$tool_path"; do
  [[ -f "$path" ]] || fail "Required implementation file is missing: $path"
done

validate_https_base_url "$read_api_base_url" || fail "ReadApiBaseUrl must be an HTTPS base URL without a query string or fragment."

export TMPDIR="$script_dir/.tmp"
mkdir -p "$TMPDIR"
temp_dir=$(mktemp -d "$TMPDIR/preflight.XXXXXX")
trap 'rm -rf "$temp_dir"' EXIT

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
    fail "Add explicit Session 03 preflight checks for new sentinels: ${unknown[*]}"
  fi
  fail "Resolve every Session 03 customer decision before deployment: ${unresolved_sentinels[*]}"
fi

jq -e '.implementationSession == "03-citadel-agent-spoke"' "$config_path" >/dev/null || fail "agent.json has the wrong implementation marker."
jq -e '.agentType == "prompt" and .runtimePattern == "persistent-prompt-agent"' "$config_path" >/dev/null || fail "Session 03 implements one persistent prompt agent."
jq -e '.endpoint.versionSelection == "pinned"' "$config_path" >/dev/null || fail "The stable endpoint must pin one explicit agent version."
jq -e '.endpoint.protocols == ["responses"]' "$config_path" >/dev/null || fail "The governed baseline exposes only the Responses protocol."
jq -e '.endpoint.authorizationSchemes == ["Entra"]' "$config_path" >/dev/null || fail "The governed endpoint must use Microsoft Entra authorization only."
jq -e '(.temperature | tonumber) >= 0 and (.temperature | tonumber) <= 2' "$config_path" >/dev/null || fail "Agent temperature must be between 0 and 2."
jq -e '.raiPolicyName | strings | length > 0' "$config_path" >/dev/null || fail "A named RAI policy is required."
grep -q 'Refuse requests to create, update, approve, publish, delete' "$instructions_path" &&
  grep -q '__REQUIRED_PROHIBITED_WRITE_ACTION__' "$instructions_path" &&
  grep -q '__REQUIRED_HUMAN_CHANGE_ROUTE__' "$instructions_path" ||
  fail "The approved instructions do not contain the prohibited-write refusal boundary."

jq -e '.tools | length == 1 and .tools[0].type == "openapi"' "$tool_path" >/dev/null || fail "The baseline must expose exactly one OpenAPI tool."
jq -e '(.tools[0].openapi.spec.paths | keys | length) == 1' "$tool_path" >/dev/null || fail "The OpenAPI manifest must contain exactly one path."
jq -e '(.tools[0].openapi.spec.paths | to_entries[0].value | keys) == ["get"]' "$tool_path" >/dev/null || fail "The OpenAPI manifest must expose exactly one GET operation and no write operation."
jq -e '.tools[0].openapi.spec.paths | to_entries[0].value.get.operationId | test("^[A-Za-z_-]+$")' "$tool_path" >/dev/null || fail "The OpenAPI operationId must contain only letters, hyphens, and underscores."
jq -e '.tools[0].openapi.spec.servers[0].url == "__RUNTIME_READ_API_BASE_URL__"' "$tool_path" >/dev/null || fail "The authoritative tool manifest must not contain a live API endpoint."
jq -e '.tools[0].openapi.auth.type == "managed_identity"' "$tool_path" >/dev/null || fail "The read tool must use managed identity authentication."

account_json=$(az_json 'Azure account lookup' account show)
[[ $(jq -r '.id' <<<"$account_json") == "$approved_subscription_id" ]] || fail "Azure CLI is not using the approved subscription."

foundry_json=$(az_json 'Microsoft Foundry resource lookup' cognitiveservices account show --name "$foundry_account_name" --resource-group "$resource_group_name")
[[ $(jq -r '.kind' <<<"$foundry_json") == 'AIServices' ]] || fail "The existing Microsoft Foundry resource must have the Azure resource property kind set to AIServices."
expected_foundry_id="/subscriptions/$approved_subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.CognitiveServices/accounts/$foundry_account_name"
[[ $(jq -r '.id' <<<"$foundry_json") == "$expected_foundry_id" ]] || fail "The Foundry resource is outside the approved subscription or resource group."
project_resource_id="$expected_foundry_id/projects/$project_name"
project_json=$(az_json 'Foundry project lookup' resource show --ids "$project_resource_id")
project_principal_id=$(jq -r '.identity.principalId // empty' <<<"$project_json")
[[ -n "$project_principal_id" ]] || fail "The Foundry project managed identity could not be resolved."
read_scope=$(jq -r '.tools[0].openapi.auth.assignmentScope' "$tool_path")
read_role_id=$(jq -r '.tools[0].openapi.auth.requiredRoleDefinitionId' "$tool_path")
read_assignments=$(az_json 'Downstream read assignment lookup' role assignment list --assignee-object-id "$project_principal_id" --scope "$read_scope" --include-inherited false)
[[ $(jq --arg scope "$read_scope" --arg role_id "$read_role_id" '[.[] | select(.scope == $scope and (.roleDefinitionId | endswith("/" + $role_id)))] | length' <<<"$read_assignments") == '1' ]] || fail "The exact downstream managed-identity read assignment is not ready."

model_deployment_name=$(jq -r '.modelDeploymentName' "$config_path")
model_json=$(az_json 'Model deployment lookup' cognitiveservices account deployment show --name "$foundry_account_name" --resource-group "$resource_group_name" --deployment-name "$model_deployment_name")
[[ $(jq -r '.properties.provisioningState' <<<"$model_json") == 'Succeeded' ]] || fail "The approved Session 03 model deployment is not ready."

ai_resource_json=$(az_json 'Application Insights lookup' resource show --ids "$application_insights_resource_id")
[[ $(jq -r '.type | ascii_downcase' <<<"$ai_resource_json") == 'microsoft.insights/components' ]] || fail "The supplied Application Insights resource ID does not identify a Microsoft.Insights/components resource."
[[ $(jq -r '.id' <<<"$ai_resource_json") == /subscriptions/$approved_subscription_id/* ]] || fail "Application Insights is outside the approved subscription."
project_endpoint="https://$foundry_account_name.services.ai.azure.com/api/projects/$project_name"
token=$(get_ai_token)
api_request GET "$project_endpoint/agents?api-version=v1" "$token"
[[ "$API_STATUS" == '200' ]] || fail "The approved Foundry project endpoint could not be read."
agent_name=$(jq -r '.agentName' "$config_path")
existing_count=$(jq -r --arg name "$agent_name" '[.data[]?, .value[]?] | map(select(.name == $name)) | length' "$API_BODY_FILE")
if (( existing_count > 1 )); then
  fail "The project returned more than one agent with the configured name."
fi
if (( existing_count == 1 )); then
  description=$(jq -r --arg name "$agent_name" '[.data[]?, .value[]?] | map(select(.name == $name))[0].agent_card.description // ""' "$API_BODY_FILE")
  [[ "$description" == *'03-citadel-agent-spoke'* ]] || fail "An existing agent uses the configured name but does not carry the Session 03 marker."
  principal_id=$(jq -r --arg name "$agent_name" '[.data[]?, .value[]?] | map(select(.name == $name))[0].instance_identity.principal_id // ""' "$API_BODY_FILE")
  [[ -n "$principal_id" ]] || fail "The existing agent is a legacy agent without a unique Entra Agent Identity. Create a new named agent instead."
  escaped_agent_name=$(python3 - "$agent_name" <<'PY'
from urllib.parse import quote
import sys
print(quote(sys.argv[1], safe=''))
PY
)
  api_request GET "$project_endpoint/agents/$escaped_agent_name?api-version=v1" "$token"
  [[ "$API_STATUS" == '200' ]] || fail "The approved agent could not be read for stable-endpoint validation."
  live_version=$(jq -r '.agent_endpoint.version_selector.version_selection_rules[0].agent_version // ""' "$API_BODY_FILE")
  [[ -n "$live_version" ]] || fail "The existing marked agent does not expose a pinned stable endpoint version."
fi

api_path=$(jq -r '.tools[0].openapi.spec.paths | keys[0]' "$tool_path")
echo 'Read-only preview:'
echo "  Project: $project_endpoint"
echo "  Agent: $agent_name"
echo "  Model deployment: $model_deployment_name"
echo "  Tool surface: GET $api_path only"
echo '  Endpoint: Responses, Entra authorization, pinned to the new version'
if (( existing_count == 1 )); then
  echo '  Existing marked agent: True'
else
  echo '  Existing marked agent: False'
fi
if (( existing_count == 1 )); then
  echo "  Current/live active version: $live_version"
fi
echo "Foundry doesn't expose a what-if operation for data-plane agent version creation. This read-only lookup and exact mutation summary are the preview gate."
echo 'PASS: Session 03 files, decisions, live release selector, approved Azure scope, model, Application Insights resource, Foundry project access, read-only tool boundary, unique-identity path, and preview gate are ready.'
