#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  deploy-agent.sh --approved-subscription-id SUBSCRIPTION_ID --resource-group-name RESOURCE_GROUP --foundry-account-name FOUNDRY_ACCOUNT --project-name PROJECT --read-api-base-url HTTPS_URL
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
    local content_type='application/json'
    [[ "$method" == 'PATCH' ]] && content_type='application/merge-patch+json'
    args+=(-H "Content-Type: $content_type" --data @"$body_file")
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
approved_subscription_id=""
resource_group_name=""
foundry_account_name=""
project_name=""
read_api_base_url=""
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

require_command az
require_command curl
require_command jq
require_command python3

for path in "$artifact_root" "$config_path" "$instructions_path" "$tool_path"; do
  [[ -e "$path" ]] || fail "Required implementation file is missing: $path"
done

validate_https_base_url "$read_api_base_url" || fail "ReadApiBaseUrl must be an HTTPS base URL without a query string or fragment."

export TMPDIR="$script_dir/.tmp"
mkdir -p "$TMPDIR"
temp_dir=$(mktemp -d "$TMPDIR/deploy.XXXXXX")
trap 'rm -rf "$temp_dir"' EXIT

mapfile -t unresolved_sentinels < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved_sentinels[@]} > 0)); then
  fail "Resolve every Session 03 customer decision before deployment: ${unresolved_sentinels[*]}"
fi

account_json=$(az_json 'Azure account lookup' account show)
[[ $(jq -r '.id' <<<"$account_json") == "$approved_subscription_id" ]] || fail "Azure CLI is not using the approved subscription."
foundry_json=$(az_json 'Microsoft Foundry resource lookup' cognitiveservices account show --name "$foundry_account_name" --resource-group "$resource_group_name")
[[ $(jq -r '.kind' <<<"$foundry_json") == 'AIServices' ]] || fail "The existing Microsoft Foundry resource must have the Azure resource property kind set to AIServices."
expected_foundry_id="/subscriptions/$approved_subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.CognitiveServices/accounts/$foundry_account_name"
[[ $(jq -r '.id' <<<"$foundry_json") == "$expected_foundry_id" ]] || fail "The Foundry resource is outside the approved subscription or resource group."

agent_name=$(jq -r '.agentName' "$config_path")
model_deployment_name=$(jq -r '.modelDeploymentName' "$config_path")
rai_policy_name=$(jq -r '.raiPolicyName' "$config_path")
temperature=$(jq -r '.temperature' "$config_path")
instructions=$(cat "$instructions_path")

tool_runtime_path="$temp_dir/tool-runtime.json"
jq --arg url "${read_api_base_url%/}" '.tools[0] | .openapi.spec.servers[0].url = $url' "$tool_path" > "$tool_runtime_path"
create_body="$temp_dir/create-body.json"
jq -n \
  --arg name "$agent_name" \
  --arg model "$model_deployment_name" \
  --arg instructions "$instructions" \
  --arg rai "$rai_policy_name" \
  --argjson temperature "$temperature" \
  --slurpfile tool "$tool_runtime_path" \
  '{name:$name, definition:{kind:"prompt", model:$model, instructions:$instructions, temperature:$temperature, rai_config:{rai_policy_name:$rai}, tools:$tool}}' > "$create_body"

project_endpoint="https://$foundry_account_name.services.ai.azure.com/api/projects/$project_name"
escaped_agent_name=$(python3 - <<'PY' "$agent_name"
from urllib.parse import quote
import sys
print(quote(sys.argv[1], safe=""))
PY
)
agent_uri="$project_endpoint/agents/$escaped_agent_name?api-version=v1"
token=$(get_ai_token)
api_request GET "$agent_uri" "$token"
if [[ "$API_STATUS" == '200' ]]; then
  existing_description=$(jq -r '.agent_card.description // ""' "$API_BODY_FILE")
  [[ "$existing_description" == *'03-citadel-agent-spoke'* ]] || fail "An agent with this name exists without the Session 03 implementation marker."
elif [[ "$API_STATUS" != '404' ]]; then
  fail "Unable to inspect the configured Session 03 agent name."
fi

api_request POST "$project_endpoint/agents?api-version=v1" "$token" "$create_body"
[[ "$API_STATUS" == '200' || "$API_STATUS" == '201' ]] || fail "Foundry agent creation failed."
created_version=$(jq -r '.version // empty' "$API_BODY_FILE")
[[ -n "$created_version" ]] || fail "Foundry created the agent version but did not return its version identifier."

patch_body="$temp_dir/patch-body.json"
jq -n \
  --arg version "$created_version" \
  --arg session "03-citadel-agent-spoke" \
  '{agent_endpoint:{version_selector:{version_selection_rules:[{type:"FixedRatio", agent_version:$version, traffic_percentage:100}]}, protocol_configuration:{responses:{}}, authorization_schemes:[{type:"Entra"}]}, agent_card:{version:"1.0.0", description:("Internal policy assistant. implementationSession=" + $session), skills:[{id:"policy-lookup", name:"Policy lookup", description:"Reads an approved policy record by identifier without changing state.", tags:["policy","read-only","governed"], examples:["Summarize policy POL-001."]}]}}' > "$patch_body"
api_request PATCH "$agent_uri" "$token" "$patch_body"
[[ "$API_STATUS" == '200' ]] || fail "Foundry agent endpoint configuration failed."
principal_id=$(jq -r '.instance_identity.principal_id // empty' "$API_BODY_FILE")
[[ -n "$principal_id" ]] || fail "The created agent does not expose a unique Entra Agent Identity."

echo "PASS: Created agent version $created_version, pinned the stable Responses endpoint, enforced Entra authorization, and confirmed a unique agent identity."
