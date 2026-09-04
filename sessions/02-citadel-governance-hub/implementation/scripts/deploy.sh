#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: deploy.sh --citadel-path PATH --subscription-id ID"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

citadel_path=""
subscription_id=""
while (($#)); do
  case "$1" in
    --citadel-path) citadel_path="${2:-}"; shift 2 ;;
    --subscription-id) subscription_id="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown option: $1" ;;
  esac
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$script_dir/preflight.sh" --citadel-path "$citadel_path" --subscription-id "$subscription_id"

profile_path="$script_dir/../artifacts/citadel/deployment-profile.json"
export AZURE_ENV_NAME="$(jq -r '.environmentName' "$profile_path")"
export AZURE_LOCATION="$(jq -r '.location' "$profile_path")"
export AZURE_RESOURCE_GROUP="$(jq -r '.resourceGroupName' "$profile_path")"
export USE_EXISTING_VNET="$(jq -r '.network.useExistingVnet' "$profile_path")"
export EXISTING_VNET_RG="$(jq -r '.network.existingVnetResourceGroup' "$profile_path")"
export VNET_NAME="$(jq -r '.network.vnetName' "$profile_path")"
export APIM_SUBNET_NAME="$(jq -r '.network.apimSubnetName' "$profile_path")"
export PRIVATE_ENDPOINT_SUBNET_NAME="$(jq -r '.network.privateEndpointSubnetName' "$profile_path")"
export USE_EXISTING_LOG_ANALYTICS="$(jq -r '.monitoring.useExistingLogAnalytics' "$profile_path")"
export EXISTING_LOG_ANALYTICS_RG="$(jq -r '.monitoring.workspaceResourceGroup' "$profile_path")"
export EXISTING_LOG_ANALYTICS_NAME="$(jq -r '.monitoring.workspaceName' "$profile_path")"
export ENABLE_API_CENTER="$(jq -r '.features.enableApiCenter' "$profile_path")"
export ENABLE_PII_REDACTION="$(jq -r '.features.enablePiiRedaction' "$profile_path")"
export ENABLE_MANAGED_REDIS="$(jq -r '.features.enableManagedRedis' "$profile_path")"
export ENABLE_AZURE_AI_SEARCH="$(jq -r '.features.enableAzureAiSearch' "$profile_path")"
export ENABLE_DOCUMENT_INTELLIGENCE="$(jq -r '.features.enableDocumentIntelligence' "$profile_path")"

(cd "$citadel_path" && azd env select "$AZURE_ENV_NAME" >/dev/null 2>&1 || azd env new "$AZURE_ENV_NAME")
(cd "$citadel_path" && azd provision)
(cd "$citadel_path" && azd deploy)

echo "PASS: Citadel Governance Hub deployment completed through the pinned source."
