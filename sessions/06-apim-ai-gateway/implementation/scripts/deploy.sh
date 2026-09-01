#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  deploy.sh --approved-subscription-id SUBSCRIPTION_ID --primary-agent-base-url HTTPS_URL [--secondary-agent-base-url HTTPS_URL] [--design-record-path PATH]
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
environment_path="$script_dir/../artifacts/environments/sandbox.json"
bicep_path="$script_dir/../artifacts/gateway/main.bicep"
[[ -f "$environment_path" ]] || fail "Required implementation file is missing: $environment_path"
[[ -f "$bicep_path" ]] || fail "Required implementation file is missing: $bicep_path"

approved_subscription_id=""
primary_agent_base_url=""
secondary_agent_base_url=""
design_record_path="$script_dir/../../../06-apim-ai-gateway-design/implementation/artifacts/gateway-design-record.json"
while (($# > 0)); do
  case "$1" in
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail "--approved-subscription-id requires a value."
      approved_subscription_id=$2
      shift 2
      ;;
    --primary-agent-base-url)
      [[ $# -ge 2 ]] || fail "--primary-agent-base-url requires a value."
      primary_agent_base_url=$2
      shift 2
      ;;
    --secondary-agent-base-url)
      [[ $# -ge 2 ]] || fail "--secondary-agent-base-url requires a value."
      secondary_agent_base_url=$2
      shift 2
      ;;
    --design-record-path)
      [[ $# -ge 2 ]] || fail "--design-record-path requires a value."
      design_record_path=$2
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
[[ -n "$primary_agent_base_url" ]] || fail "--primary-agent-base-url is required."

"$script_dir/preflight.sh" --approved-subscription-id "$approved_subscription_id" --primary-agent-base-url "$primary_agent_base_url" --secondary-agent-base-url "$secondary_agent_base_url" --design-record-path "$design_record_path"

deployment_json=$(az deployment group create \
  --name session07-apim-ai-gateway-implementation \
  --resource-group "$(jq -r '.resourceGroupName' "$environment_path")" \
  --template-file "$bicep_path" \
  --parameters \
    "primaryAgentBaseUrl=$primary_agent_base_url" \
    "secondaryAgentBaseUrl=$secondary_agent_base_url" \
    "apiManagementName=$(jq -r '.apiManagementName' "$environment_path")" \
    "applicationInsightsLoggerName=$(jq -r '.applicationInsightsLoggerName' "$environment_path")" \
    "contentSafetyBackendId=$(jq -r '.contentSafetyBackendId' "$environment_path")" \
    "secondaryBackendEnabled=$(jq -r '.secondaryBackendEnabled' "$environment_path")" \
  --only-show-errors \
  --output json 2>&1) || fail "Session 07 API Management deployment failed.\n$deployment_json"

gateway_path=$(jq -r '.properties.outputs.gatewayPath.value // empty' <<<"$deployment_json")
echo 'Deployed Session 07 API Management control.'
echo "Gateway path: $gateway_path"
echo 'The product owner must issue or approve a workload-specific product subscription before client use.'
