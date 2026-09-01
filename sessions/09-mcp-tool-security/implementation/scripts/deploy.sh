#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  deploy.sh --approved-subscription-id SUBSCRIPTION_ID
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
environment_path="$script_dir/../artifacts/environments/sandbox.json"
bicep_path="$script_dir/../artifacts/apim/main.bicep"
[[ -f "$environment_path" ]] || fail "Required implementation file is missing: $environment_path"
[[ -f "$bicep_path" ]] || fail "Required implementation file is missing: $bicep_path"

approved_subscription_id=""
while (($# > 0)); do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail '--approved-subscription-id requires a value.'
      approved_subscription_id=$2
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
[[ -n "$approved_subscription_id" ]] || fail '--approved-subscription-id is required.'

"$script_dir/preflight.sh" --approved-subscription-id "$approved_subscription_id"

environment_json=$(cat "$environment_path")
deployment_json=$(az deployment group create --name session09-mcp-tool-security --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --template-file "$bicep_path" --parameters "apiManagementName=$(jq -r '.apiManagementName' <<<"$environment_json")" --only-show-errors --output json 2>&1) || fail "Session 09 APIM deployment failed.\n$deployment_json"
[[ $(jq -r '.properties.provisioningState // empty' <<<"$deployment_json") == 'Succeeded' ]] || fail 'Session 09 APIM deployment did not reach Succeeded.'
echo 'PASS: Deployed the marked MCP server, one read tool, identity policy, throttle, correlation trace, and payload-free diagnostic.'
echo 'Next: create the candidate Foundry agent version from agent-mcp-binding.json. Do not pin it before both extended checks.'
