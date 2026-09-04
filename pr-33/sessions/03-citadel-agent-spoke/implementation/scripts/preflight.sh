#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --source-path PATH --approved-subscription-id ID --deployment-principal-id ID [--parameters-output PATH]
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
}

normalize_repo_url() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's#^git@github.com:#https://github.com/#; s#\.git/?$##; s#/$##'
}

source_path=""
approved_subscription_id=""
deployment_principal_id=""
parameters_output=""

while (($#)); do
  case "$1" in
    --source-path) source_path="${2:-}"; shift 2 ;;
    --approved-subscription-id) approved_subscription_id="${2:-}"; shift 2 ;;
    --deployment-principal-id) deployment_principal_id="${2:-}"; shift 2 ;;
    --parameters-output) parameters_output="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown option: $1" ;;
  esac
done

[[ -n "$source_path" ]] || fail "--source-path is required."
[[ -n "$approved_subscription_id" ]] || fail "--approved-subscription-id is required."
[[ -n "$deployment_principal_id" ]] || fail "--deployment-principal-id is required."

require_command az
require_command git
require_command jq
require_command python3

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
artifact_root="$(cd -- "$script_dir/../artifacts" && pwd)"
release_path="$artifact_root/citadel/release.json"
profile_path="$artifact_root/citadel/spoke-profile.json"
agent_path="$artifact_root/agents/policy-assistant/agent.json"

for path in "$release_path" "$profile_path" "$agent_path"; do
  [[ -f "$path" ]] || fail "Required implementation file is missing: $path"
done
[[ -d "$source_path/.git" ]] || fail "The AI Landing Zones Bicep source must be a Git checkout."

required_sentinels=(
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_AGENT_SUBNET_PREFIX__"
  "__REQUIRED_APPLICATION_INSIGHTS_NAME__"
  "__REQUIRED_DOWNSTREAM_API_AUTHORIZATION_OWNER__"
  "__REQUIRED_DOWNSTREAM_API_READ_ROLE_ID__"
  "__REQUIRED_DOWNSTREAM_API_READ_SCOPE__"
  "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
  "__REQUIRED_FOUNDRY_PROJECT_NAME__"
  "__REQUIRED_HUMAN_CHANGE_ROUTE__"
  "__REQUIRED_MODEL_API_VERSION__"
  "__REQUIRED_MODEL_CAPACITY__"
  "__REQUIRED_MODEL_DEPLOYMENT_NAME__"
  "__REQUIRED_MODEL_FORMAT__"
  "__REQUIRED_MODEL_NAME__"
  "__REQUIRED_MODEL_SKU__"
  "__REQUIRED_MODEL_VERSION__"
  "__REQUIRED_PROHIBITED_WRITE_ACTION__"
  "__REQUIRED_PRIVATE_ENDPOINT_SUBNET_PREFIX__"
  "__REQUIRED_RAI_POLICY_NAME__"
  "__REQUIRED_READ_PATH__"
  "__REQUIRED_SPOKE_RESOURCE_GROUP__"
  "__REQUIRED_SPOKE_ROUTE_TABLE_RESOURCE_ID__"
  "__REQUIRED_SPOKE_VNET_RESOURCE_ID__"
  "__REQUIRED_TARGET_AUDIENCE__"
)

mapfile -t unresolved < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved[@]})); then
  unknown=()
  for sentinel in "${unresolved[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      [[ "$sentinel" == "$required" ]] && known=true && break
    done
    $known || unknown+=("$sentinel")
  done
  ((${#unknown[@]} == 0)) || fail "Add explicit Session 03 checks for new sentinels: ${unknown[*]}"
  fail "Resolve every Session 03 customer decision before deployment: ${unresolved[*]}"
fi

jq -e '
  .schemaVersion == 1 and
  .implementationSession == "03-citadel-agent-spoke" and
  .deploymentEngine == "bicep" and
  .deploymentMode == "ailz-integrated" and
  .networkIsolation == true and
  .foundry.disableLocalAuth == true and
  .foundry.deployAgentService == true and
  .components.deployPublicIngress == false and
  .components.deployAzureFirewall == false
' "$profile_path" >/dev/null || fail "spoke-profile.json does not match the approved integrated Bicep boundary."

expected_repo="$(jq -r '.implementation.repository' "$release_path")"
expected_commit="$(jq -r '.implementation.commit' "$release_path")"
entry_point="$(jq -r '.implementation.entryPoint' "$release_path")"
[[ "$(jq -r '.implementation.engine' "$release_path")" == "bicep" ]] || fail "release.json must select the Bicep implementation."
[[ -f "$source_path/$entry_point" ]] || fail "Pinned Bicep entry point is missing: $source_path/$entry_point"
actual_repo="$(git -C "$source_path" remote get-url origin)"
[[ "$(normalize_repo_url "$actual_repo")" == "$(normalize_repo_url "$expected_repo")" ]] || fail "The source checkout has the wrong Git remote."
actual_commit="$(git -C "$source_path" rev-parse HEAD)"
[[ "$actual_commit" == "$expected_commit" ]] || fail "The source checkout is not at the pinned AI Landing Zones Bicep commit."
[[ -z "$(git -C "$source_path" status --porcelain)" ]] || fail "The pinned upstream checkout contains local changes."

account_id="$(az account show --query id --output tsv --only-show-errors)"
[[ "$account_id" == "$approved_subscription_id" ]] || fail "Azure CLI is not using the approved subscription."

resource_group="$(jq -r '.resourceGroupName' "$profile_path")"
location="$(jq -r '.location' "$profile_path")"
vnet_id="$(jq -r '.existingVnetResourceId' "$profile_path")"
route_table_id="$(jq -r '.existingRouteTableResourceId' "$profile_path")"
az group show --name "$resource_group" --only-show-errors >/dev/null || fail "The approved Agent Spoke resource group does not exist."
az resource show --ids "$vnet_id" --only-show-errors >/dev/null || fail "The existing Agent Spoke VNet could not be read."
az resource show --ids "$route_table_id" --only-show-errors >/dev/null || fail "The platform-owned Agent Spoke route table could not be read."
[[ "${vnet_id,,}" == "/subscriptions/${approved_subscription_id,,}/"* ]] || fail "The existing VNet is outside the approved subscription."
[[ "${route_table_id,,}" == "/subscriptions/${approved_subscription_id,,}/"* ]] || fail "The existing route table is outside the approved subscription."

agent_model="$(jq -r '.modelDeploymentName' "$agent_path")"
profile_model="$(jq -r '.model.deploymentName' "$profile_path")"
[[ "$agent_model" == "$profile_model" ]] || fail "The agent and landing-zone profile must use the same model deployment name."

if [[ -z "$parameters_output" ]]; then
  parameters_output="$(mktemp)"
  trap 'rm -f "$parameters_output"' EXIT
else
  mkdir -p "$(dirname -- "$parameters_output")"
fi

jq -n \
  --arg environment_name "$(jq -r '.environmentName' "$profile_path")" \
  --arg location "$location" \
  --arg principal_id "$deployment_principal_id" \
  --arg principal_type "$(jq -r '.deploymentPrincipalType' "$profile_path")" \
  --arg deployment_mode "$(jq -r '.deploymentMode' "$profile_path")" \
  --arg vnet_id "$vnet_id" \
  --arg route_table_id "$route_table_id" \
  --arg agent_subnet_name "$(jq -r '.agentSubnetName' "$profile_path")" \
  --arg agent_subnet_prefix "$(jq -r '.agentSubnetPrefix' "$profile_path")" \
  --arg pe_subnet_name "$(jq -r '.privateEndpointSubnetName' "$profile_path")" \
  --arg pe_subnet_prefix "$(jq -r '.privateEndpointSubnetPrefix' "$profile_path")" \
  --arg foundry_account "$(jq -r '.foundry.accountName' "$profile_path")" \
  --arg foundry_project "$(jq -r '.foundry.projectName' "$profile_path")" \
  --arg app_insights "$(jq -r '.observability.applicationInsightsName' "$profile_path")" \
  --arg model_deployment "$(jq -r '.model.deploymentName' "$profile_path")" \
  --arg model_format "$(jq -r '.model.format' "$profile_path")" \
  --arg model_name "$(jq -r '.model.name' "$profile_path")" \
  --arg model_version "$(jq -r '.model.version' "$profile_path")" \
  --arg model_sku "$(jq -r '.model.sku' "$profile_path")" \
  --arg model_api_version "$(jq -r '.model.apiVersion' "$profile_path")" \
  --argjson model_capacity "$(jq -r '.model.capacity | tonumber' "$profile_path")" \
  --argjson deploy_subnets "$(jq '.deploySubnets' "$profile_path")" \
  --argjson policy_dns "$(jq '.policyManagedPrivateDns' "$profile_path")" \
  --argjson deploy_storage "$(jq '.components.deployStorageAccount' "$profile_path")" \
  --argjson deploy_key_vault "$(jq '.components.deployKeyVault' "$profile_path")" \
  --argjson deploy_search "$(jq '.components.deploySearchService' "$profile_path")" \
  --argjson deploy_cosmos "$(jq '.components.deployCosmosDb' "$profile_path")" \
  --argjson deploy_container_apps "$(jq '.components.deployContainerApps' "$profile_path")" \
  --argjson deploy_registry "$(jq '.components.deployContainerRegistry' "$profile_path")" \
  --argjson deploy_app_config "$(jq '.components.deployAppConfiguration' "$profile_path")" \
  --argjson tags "$(jq '.tags' "$profile_path")" \
  '{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    contentVersion: "1.0.0.0",
    parameters: {
      environmentName: {value: $environment_name},
      location: {value: $location},
      principalId: {value: $principal_id},
      principalType: {value: $principal_type},
      deploymentTags: {value: $tags},
      networkIsolation: {value: true},
      deploymentMode: {value: $deployment_mode},
      useExistingVNet: {value: true},
      existingVnetResourceId: {value: $vnet_id},
      hubIntegrationExistingRouteTableResourceId: {value: $route_table_id},
      deploySubnets: {value: $deploy_subnets},
      agentSubnetName: {value: $agent_subnet_name},
      agentSubnetPrefix: {value: $agent_subnet_prefix},
      peSubnetName: {value: $pe_subnet_name},
      peSubnetPrefix: {value: $pe_subnet_prefix},
      policyManagedPrivateDns: {value: $policy_dns},
      deployAiFoundry: {value: true},
      deployAAfAgentSvc: {value: true},
      aiFoundryDisableLocalAuth: {value: true},
      aiFoundryAccountName: {value: $foundry_account},
      aiFoundryProjectName: {value: $foundry_project},
      deployAppInsights: {value: true},
      appInsightsName: {value: $app_insights},
      deployLogAnalytics: {value: true},
      deployStorageAccount: {value: $deploy_storage},
      deployKeyVault: {value: $deploy_key_vault},
      deploySearchService: {value: $deploy_search},
      deployCosmosDb: {value: $deploy_cosmos},
      deployContainerApps: {value: $deploy_container_apps},
      deployContainerRegistry: {value: $deploy_registry},
      deployContainerEnv: {value: $deploy_container_apps},
      deployAppConfig: {value: $deploy_app_config},
      deployNsgs: {value: true},
      deployAzureFirewall: {value: false},
      publicIngress: {value: {enabled: false}},
      deployJumpbox: {value: false},
      deployBastion: {value: false},
      deployNatGateway: {value: false},
      deployVM: {value: false},
      deploySoftware: {value: false},
      modelDeploymentList: {value: [{
        name: $model_deployment,
        model: {format: $model_format, name: $model_name, version: $model_version},
        sku: {name: $model_sku, capacity: $model_capacity},
        canonical_name: "CHAT_DEPLOYMENT_NAME",
        apiVersion: $model_api_version
      }]}
    }
  }' > "$parameters_output"

az bicep build --file "$source_path/$entry_point" --stdout --only-show-errors >/dev/null
az deployment group what-if \
  --name session03-agent-spoke-preview \
  --resource-group "$resource_group" \
  --template-file "$source_path/$entry_point" \
  --parameters "@$parameters_output" \
  --only-show-errors

echo "PASS: The pinned AI Landing Zones Bicep source, customer profile, Azure scope, generated parameters, and deployment preview are ready."
