#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --approved-subscription-id SUBSCRIPTION_ID --primary-agent-base-url HTTPS_URL [--secondary-agent-base-url HTTPS_URL] [--design-record-path PATH]
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

warn() {
  echo "WARNING: $*" >&2
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
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

validate_agent_url() {
  python3 - "$1" "$2" <<'PY'
import sys
from urllib.parse import urlparse
value, allow_empty = sys.argv[1], sys.argv[2] == 'true'
if not value:
    raise SystemExit(0 if allow_empty else 1)
uri = urlparse(value)
if uri.scheme != 'https' or uri.query or uri.fragment or not uri.netloc:
    raise SystemExit(1)
PY
}

validate_design_record() {
  python3 - "$1" "$2" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
expected_apim_name = sys.argv[2]
try:
    raw = path.read_text(encoding="utf-8")
    record = json.loads(raw)
except (OSError, json.JSONDecodeError) as error:
    raise SystemExit(f"The Session 07 gateway design record is invalid: {error}")
if re.search(r"__REQUIRED_[A-Z0-9_]+__", raw):
    raise SystemExit("Resolve every required Session 07 gateway design decision before the Session 08 deployment.")
if record.get("recordStatus") != "ready-for-implementation":
    raise SystemExit("The Session 07 gateway design record must be ready-for-implementation.")
backend = record.get("targetBackend", {})
if backend.get("type") != "foundry-agent-service" or backend.get("implementationVariant") != "policy-assistant-responses":
    raise SystemExit("Session 08 implements the foundry-agent-service policy-assistant-responses variant recorded in Session 07.")
content_safety = record.get("contentSafety", {})
if content_safety.get("decision") != "enabled" or not str(content_safety.get("backendReference", "")).strip():
    raise SystemExit("The Session 07 design record must enable Content Safety and name its approved backend reference.")
if record.get("apiManagement", {}).get("instanceName") != expected_apim_name:
    raise SystemExit("The Session 07 design record APIM instance does not match sandbox.json.")
for section, field in (
    ("ingress", "clientIdentity"),
    ("ingress", "backendIdentity"),
    ("network", "inboundPath"),
    ("network", "backendPath"),
    ("network", "privateDnsState"),
):
    if not str(record.get(section, {}).get(field, "")).strip():
        raise SystemExit("The Session 07 design record must state the ingress identities and network paths.")
if any(gap.get("status") == "open" for gap in record.get("readinessGaps", [])):
    raise SystemExit("Resolve the open Session 07 readiness gaps before the Session 08 deployment.")
PY
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
gateway_root="$artifact_root/gateway"
control_path="$artifact_root/governance/gateway-control.json"
environment_path="$artifact_root/environments/sandbox.json"
bicep_path="$gateway_root/main.bicep"
openapi_path="$gateway_root/apis/policy-assistant-responses.openapi.json"
policy_path="$gateway_root/policies/policy.xml"
required_sentinels=(
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_APIM_VIRTUAL_NETWORK_TYPE__"
  "__REQUIRED_API_AUDIENCE__"
  "__REQUIRED_APIM_NAME__"
  "__REQUIRED_APP_INSIGHTS_LOGGER_NAME__"
  "__REQUIRED_APP_ROLE__"
  "__REQUIRED_CLIENT_APPLICATION_ID__"
  "__REQUIRED_CONTENT_SAFETY_BACKEND_ID__"
  "__REQUIRED_CONTENT_SAFETY_RESOURCE_ID__"
  "__REQUIRED_CONTENT_SAFETY_PUBLIC_NETWORK_ACCESS__"
  "__REQUIRED_ENTRA_TENANT_ID__"
  "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
  "__REQUIRED_FOUNDRY_PROJECT_NAME__"
  "__REQUIRED_FOUNDRY_PUBLIC_NETWORK_ACCESS__"
  "__REQUIRED_IDENTITY_OWNER__"
  "__REQUIRED_OPERATIONS_OWNER__"
  "__REQUIRED_PLATFORM_OWNER__"
  "__REQUIRED_PRODUCT_OWNER__"
  "__REQUIRED_RESOURCE_GROUP_NAME__"
  "__REQUIRED_SAFETY_OWNER__"
)

approved_subscription_id=""
primary_agent_base_url=""
secondary_agent_base_url=""
design_record_path="$script_dir/../../../07-apim-ai-gateway-design/implementation/artifacts/gateway-design-record.json"
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

require_command az
require_command jq
require_command python3

[[ -d "$artifact_root" ]] || fail "Required implementation artifacts folder is missing: $artifact_root"
for path in "$control_path" "$environment_path" "$bicep_path" "$openapi_path" "$policy_path"; do
  [[ -f "$path" ]] || fail "Required implementation file is missing: $path"
done
[[ -f "$design_record_path" ]] || fail "The approved Session 07 gateway design record is missing: $design_record_path"

validate_agent_url "$primary_agent_base_url" false || fail "PrimaryAgentBaseUrl must be an HTTPS base URL without a query string or fragment."
validate_agent_url "$secondary_agent_base_url" true || fail "SecondaryAgentBaseUrl must be an HTTPS base URL without a query string or fragment."

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
    fail "Add explicit Session 08 preflight checks for new sentinels: ${unknown[*]}"
  fi
  fail "Resolve every Session 08 customer decision before deployment: ${unresolved_sentinels[*]}"
fi

jq -e '.implementationSession == "08-apim-ai-gateway-implementation"' "$control_path" >/dev/null || fail "gateway-control.json has the wrong implementationSession marker."
jq -e '.implementationSession == "08-apim-ai-gateway-implementation"' "$environment_path" >/dev/null || fail "sandbox.json has the wrong implementationSession marker."
jq -e '.api.operationPath == "/responses"' "$control_path" >/dev/null || fail "Session 08 must expose one POST /responses operation."
jq -e '.paths["/responses"].post != null' "$openapi_path" >/dev/null || fail "Session 08 must expose one POST /responses operation."
jq -e '.components.schemas.ResponseRequest.properties.stream_options.properties.include_usage.type == "boolean"' "$openapi_path" >/dev/null || fail "The Responses contract must document stream_options.include_usage for streaming token metrics."
jq -e '.product.subscriptionRequired == true' "$control_path" >/dev/null || fail "The governed product must require an APIM subscription."
jq -e '.semanticCaching.enabled == false' "$control_path" >/dev/null || fail "Semantic caching is deferred for Session 08."
jq -e '.telemetry.requestBodyBytesLogged == 0 and .telemetry.responseBodyBytesLogged == 0 and .telemetry.clientIpLogged == false' "$control_path" >/dev/null || fail "Gateway diagnostics must keep request bodies, response bodies, and client IP logging disabled."
jq -e '.limits.tokensPerMinute > 0 and .limits.tokenQuota > 0 and .limits.requestMaxBytes > 0 and .limits.requestMaxBytes <= 4194304' "$control_path" >/dev/null || fail "Token and request-size limits must be positive; requestMaxBytes cannot exceed 4 MB."
jq -e '.limits.retryCount >= 1 and .limits.retryCount <= 3' "$control_path" >/dev/null || fail "Retry count must stay between 1 and 3 for the agent Responses call."
jq -e '.safety.harmThreshold >= 0 and .safety.harmThreshold <= 7' "$control_path" >/dev/null || fail "The eight-level Content Safety threshold must be between 0 and 7."

python3 - "$policy_path" <<'PY'
import re
import sys
import xml.etree.ElementTree as ET
text = open(sys.argv[1], encoding='utf-8').read()
root = ET.fromstring(text)
required = [
    'validate-azure-ad-token', 'validate-content', 'llm-token-limit', 'llm-content-safety',
    'llm-emit-token-metric', 'set-backend-service', 'authentication-managed-identity', 'retry', 'forward-request'
]
for name in required:
    if len(root.findall(f'.//{name}')) != 1:
        raise SystemExit(f"APIM policy must contain exactly one '{name}' element.")
managed_identity = root.find('.//authentication-managed-identity')
if managed_identity.get('resource') != 'https://ai.azure.com' or managed_identity.get('ignore-error') != 'false':
    raise SystemExit('The Foundry backend hop must use fail-closed APIM managed identity for https://ai.azure.com.')
token_limit = root.find('.//llm-token-limit')
if 'context.Subscription.Id' not in (token_limit.get('counter-key') or ''):
    raise SystemExit('Token limits must use the controlled APIM subscription as the counter key.')
for forbidden in ['llm-semantic-cache-lookup', 'llm-semantic-cache-store', 'log-to-eventhub', 'trace']:
    if re.search(re.escape(forbidden), text):
        raise SystemExit(f"The Session 08 policy must not contain '{forbidden}'.")
PY

environment_json=$(cat "$environment_path")
validate_design_record "$design_record_path" "$(jq -r '.apiManagementName' <<<"$environment_json")" || fail "Session 07 gateway design record validation failed."
expected_primary_base="https://$(jq -r '.foundryAccountName' <<<"$environment_json").services.ai.azure.com/api/projects/$(jq -r '.foundryProjectName' <<<"$environment_json")/agents/$(jq -r '.agentName' <<<"$environment_json")/endpoint/protocols/openai"
[[ ${primary_agent_base_url%/} == "$expected_primary_base" ]] || fail "PrimaryAgentBaseUrl does not match the existing Session 05 Foundry agent."
secondary_enabled=$(jq -r '.secondaryBackendEnabled' <<<"$environment_json")
if [[ "$secondary_enabled" == 'true' ]]; then
  [[ -n "$secondary_agent_base_url" ]] || fail "SecondaryAgentBaseUrl is required because the approved environment enables secondary routing."
  [[ ${secondary_agent_base_url%/} != ${primary_agent_base_url%/} ]] || fail "Primary and secondary agent base URLs must differ."
else
  [[ -z "$secondary_agent_base_url" ]] || fail "Remove SecondaryAgentBaseUrl or set secondaryBackendEnabled to true after approving the route."
fi

account_json=$(az_json 'Azure account lookup' account show)
[[ $(jq -r '.id' <<<"$account_json") == "$approved_subscription_id" ]] || fail "Azure CLI is not using the approved subscription."

apim_json=$(az_json 'API Management lookup' apim show --name "$(jq -r '.apiManagementName' <<<"$environment_json")" --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")")
expected_apim_id="/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.resourceGroupName' <<<"$environment_json")/providers/Microsoft.ApiManagement/service/$(jq -r '.apiManagementName' <<<"$environment_json")"
[[ $(jq -r '.id' <<<"$apim_json") == "$expected_apim_id" ]] || fail "API Management is outside the approved subscription or resource group."
[[ $(jq -r '.sku.name' <<<"$apim_json") != 'Consumption' ]] || fail "The deployed token-limit and content-safety policy set is not supported on the Consumption tier."
[[ $(jq -r '.apiManagement.tier' "$design_record_path") == "$(jq -r '.sku.name' <<<"$apim_json")" ]] || fail "The Session 07 design record APIM tier does not match the live APIM instance."
[[ $(jq -r '.virtualNetworkType // empty' <<<"$apim_json") == "$(jq -r '.network.apimVirtualNetworkType' <<<"$environment_json")" ]] || fail "API Management virtualNetworkType does not match sandbox.json."
apim_principal_id=$(jq -r '.identity.principalId // empty' <<<"$apim_json")
[[ -n "$apim_principal_id" ]] || fail "API Management must have a system-assigned managed identity."

agent_scope="/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.resourceGroupName' <<<"$environment_json")/providers/Microsoft.CognitiveServices/accounts/$(jq -r '.foundryAccountName' <<<"$environment_json")/projects/$(jq -r '.foundryProjectName' <<<"$environment_json")/agents/$(jq -r '.agentName' <<<"$environment_json")"
role_json=$(az_json 'Foundry Agent Consumer role lookup' role definition list --name eed3b665-ab3a-47b6-8f48-c9382fb1dad6)
[[ $(jq -r 'length' <<<"$role_json") == '1' && $(jq -r '.[0].roleName' <<<"$role_json") == 'Foundry Agent Consumer' ]] || fail "Role definition eed3b665-ab3a-47b6-8f48-c9382fb1dad6 is not the current Foundry Agent Consumer role."
assignments_json=$(az_json 'APIM Foundry Agent Consumer assignment lookup' role assignment list --assignee "$apim_principal_id" --role eed3b665-ab3a-47b6-8f48-c9382fb1dad6 --scope "$agent_scope" --include-inherited)
[[ $(jq -r 'length' <<<"$assignments_json") != '0' ]] || fail "Assign Foundry Agent Consumer to the APIM identity at the individual Session 05 agent scope."

content_safety_resource_id=$(jq -r '.contentSafetyResourceId' <<<"$environment_json")
[[ "$content_safety_resource_id" == /subscriptions/$approved_subscription_id/* ]] || fail "The Content Safety resource is outside the approved subscription."
content_safety_json=$(az_json 'Azure AI Content Safety lookup' resource show --ids "$content_safety_resource_id")
[[ $(jq -r '.kind' <<<"$content_safety_json") == 'ContentSafety' ]] || fail "contentSafetyResourceId must identify an Azure AI Content Safety resource."
[[ $(jq -r '.properties.publicNetworkAccess // empty' <<<"$content_safety_json") == "$(jq -r '.network.contentSafetyPublicNetworkAccess' <<<"$environment_json")" ]] || fail "Azure AI Content Safety publicNetworkAccess does not match sandbox.json."
content_safety_assignments=$(az_json 'APIM Content Safety role assignment lookup' role assignment list --assignee "$apim_principal_id" --role a97b65f3-24c7-4388-baec-2e87135dc908 --scope "$content_safety_resource_id" --include-inherited)
[[ $(jq -r 'length' <<<"$content_safety_assignments") != '0' ]] || fail "Assign Cognitive Services User to the APIM identity on the Content Safety resource."

foundry_resource_id="/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.resourceGroupName' <<<"$environment_json")/providers/Microsoft.CognitiveServices/accounts/$(jq -r '.foundryAccountName' <<<"$environment_json")"
foundry_json=$(az_json 'Foundry account network lookup' resource show --ids "$foundry_resource_id")
[[ $(jq -r '.properties.publicNetworkAccess // empty' <<<"$foundry_json") == "$(jq -r '.network.foundryPublicNetworkAccess' <<<"$environment_json")" ]] || fail "Foundry publicNetworkAccess does not match sandbox.json."

api_version='2024-05-01'
logger_json=$(az_json 'Application Insights logger lookup' rest --method get --url "https://management.azure.com$expected_apim_id/loggers/$(jq -r '.applicationInsightsLoggerName' <<<"$environment_json")?api-version=$api_version")
[[ $(jq -r '.properties.loggerType' <<<"$logger_json") == 'applicationInsights' ]] || fail "The configured logger name does not identify an Application Insights logger."
backend_json=$(az_json 'Content Safety backend lookup' rest --method get --url "https://management.azure.com$expected_apim_id/backends/$(jq -r '.contentSafetyBackendId' <<<"$environment_json")?api-version=$api_version")
python3 - <<'PY' "$(jq -r '.properties.url' <<<"$backend_json")"
import re
import sys
if not re.match(r'^https://[^/]+\.cognitiveservices\.azure\.com/?$', sys.argv[1]):
    raise SystemExit(1)
PY
if [[ $? -ne 0 ]]; then
  fail "The Content Safety backend URL must be an Azure Cognitive Services endpoint."
fi

api_id=$(jq -r '.api.id' "$control_path")
existing_api_raw=$(az rest --method get --url "https://management.azure.com$expected_apim_id/apis/$api_id?api-version=$api_version" --only-show-errors --output json 2>/dev/null || true)
if [[ -n "$existing_api_raw" ]]; then
  [[ $(jq -r '.properties.description // ""' <<<"$existing_api_raw") == *'implementationSession=08-apim-ai-gateway-implementation'* ]] || fail "An existing APIM API uses the configured ID without the Session 08 marker."
fi

echo 'Deployment preview:'
echo "  APIM: $expected_apim_id"
echo "  API path: /$(jq -r '.api.path' "$control_path")$(jq -r '.api.operationPath' "$control_path")"
echo "  Agent scope: $agent_scope"
echo "  Secondary backend enabled: $secondary_enabled"
echo "  APIM virtual network type: $(jq -r '.network.apimVirtualNetworkType' <<<"$environment_json")"
echo '  Request/response body logging: disabled'
echo '  Semantic caching: deferred'

az deployment group what-if \
  --name session08-apim-ai-gateway-implementation-preview \
  --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" \
  --template-file "$bicep_path" \
  --parameters \
    "primaryAgentBaseUrl=$primary_agent_base_url" \
    "secondaryAgentBaseUrl=$secondary_agent_base_url" \
    "apiManagementName=$(jq -r '.apiManagementName' <<<"$environment_json")" \
    "applicationInsightsLoggerName=$(jq -r '.applicationInsightsLoggerName' <<<"$environment_json")" \
    "contentSafetyBackendId=$(jq -r '.contentSafetyBackendId' <<<"$environment_json")" \
    "secondaryBackendEnabled=$secondary_enabled" \
  --only-show-errors \
  --no-pretty-print >/dev/null || fail 'The API Management deployment preview failed.'

echo 'PASS: Session 07 design, Session 08 files, actual backend, identities, network, safety backend, logger, and deployment preview are ready.'
