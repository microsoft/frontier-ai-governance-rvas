#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --approved-subscription-id SUBSCRIPTION_ID --session04-agent-base-url HTTPS_URL --remote-mcp-server-url HTTPS_URL
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

validate_runtime_uri() {
  python3 - "$1" <<'PY'
import sys
from urllib.parse import urlparse
value = sys.argv[1]
uri = urlparse(value)
if uri.scheme != 'https' or not uri.netloc or uri.username or uri.password or uri.query or uri.fragment or uri.hostname in {'localhost', '127.0.0.1', '::1'}:
    raise SystemExit(1)
PY
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
bicep_path="$artifact_root/api-center/main.bicep"
metadata_path="$artifact_root/api-center/metadata-schemas.json"
agent_definition_path="$artifact_root/api-center/agent-api-definition.json"
openapi_path="$artifact_root/catalog/specs/policy-assistant-agent.openapi.json"
environment_path="$artifact_root/environments/sandbox.json"
required_sentinels=(
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_APIM_NAME__"
  "__REQUIRED_APIM_RESOURCE_GROUP_NAME__"
  "__REQUIRED_API_CENTER_LOCATION__"
  "__REQUIRED_API_CENTER_NAME__"
  "__REQUIRED_API_CENTER_PLAN__"
  "__REQUIRED_API_CENTER_RESOURCE_GROUP_NAME__"
  "__REQUIRED_BUSINESS_OWNER__"
  "__REQUIRED_COST_CENTER__"
  "__REQUIRED_CRITICALITY__"
  "__REQUIRED_DATA_CLASSIFICATION__"
  "__REQUIRED_EVALUATION_RESULTS_URL__"
  "__REQUIRED_EXPIRY_DATE__"
  "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
  "__REQUIRED_FOUNDRY_PROJECT_NAME__"
  "__REQUIRED_LAST_REVIEW_DATE__"
  "__REQUIRED_MODEL_PROVIDER__"
  "__REQUIRED_PERMITTED_CONSUMER__"
  "__REQUIRED_RESIDENCY_PROFILE__"
  "__REQUIRED_RISK_TIER__"
  "__REQUIRED_TECHNICAL_OWNER__"
)

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

require_command az
require_command jq
require_command python3

[[ -d "$artifact_root" ]] || fail "Required implementation artifacts folder is missing: $artifact_root"
for path in "$bicep_path" "$metadata_path" "$agent_definition_path" "$openapi_path" "$environment_path"; do
  [[ -f "$path" ]] || fail "Required implementation file is missing: $path"
done

validate_runtime_uri "$session04_agent_base_url" || fail "session04AgentBaseUrl must be a remote HTTPS URL without credentials, query string, or fragment."
validate_runtime_uri "$remote_mcp_server_url" || fail "RemoteMcpServerUrl must be a remote HTTPS URL without credentials, query string, or fragment."

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
    fail "Add explicit Session 06 preflight checks for new sentinels: ${unknown[*]}"
  fi
  fail "Resolve every Session 06 customer decision before deployment: ${unresolved_sentinels[*]}"
fi

python3 - "$metadata_path" "$agent_definition_path" "$openapi_path" "$environment_path" <<'PY'
import json
import sys
from datetime import datetime

metadata_path, agent_definition_path, openapi_path, environment_path = sys.argv[1:]
metadata = json.load(open(metadata_path, encoding='utf-8'))
agent = json.load(open(agent_definition_path, encoding='utf-8'))['api']
openapi = json.load(open(openapi_path, encoding='utf-8'))
environment = json.load(open(environment_path, encoding='utf-8'))

if environment.get('implementationSession') != '07-api-center-ai-mcp-inventory':
    raise SystemExit('The approved environment has the wrong implementationSession marker.')
if json.load(open(agent_definition_path, encoding='utf-8')).get('implementationSession') != '07-api-center-ai-mcp-inventory':
    raise SystemExit('The direct agent definition has the wrong implementationSession marker.')
if environment.get('apiCenterPlan') not in {'Free', 'Standard'}:
    raise SystemExit('apiCenterPlan must be Free or Standard.')
if len(metadata) != 12:
    raise SystemExit('The API Center metadata schema must define all 12 required governance properties.')
metadata_names = {item['name'] for item in metadata}
required_names = set(agent['customProperties'].keys())
missing = required_names - metadata_names
if missing:
    raise SystemExit('The API Center metadata schema must define all 12 required governance properties.')
for definition in metadata:
    json.loads(definition['schema'])
    if not definition.get('required'):
        raise SystemExit(f"Metadata '{definition['name']}' must remain required for APIs.")

def validate_record(record, description):
    required = {
        'businessOwner', 'technicalOwner', 'assetKind', 'dataClassification', 'permittedConsumers',
        'modelProvider', 'residencyProfile', 'riskTier', 'evaluationResultsUrl', 'lastReviewDate',
        'expiryDate', 'implementationSession'
    }
    props = record['customProperties']
    missing_props = sorted(required - props.keys())
    if missing_props:
        raise SystemExit(f"{description} is missing required metadata: {', '.join(missing_props)}.")
    if props['assetKind'] not in {'ai-api', 'agent-api', 'mcp-server'}:
        raise SystemExit(f"{description} has an unsupported assetKind.")
    if props['dataClassification'] not in {'public', 'internal', 'confidential', 'restricted'}:
        raise SystemExit(f"{description} has an unsupported dataClassification.")
    if props['riskTier'] not in {'low', 'moderate', 'high', 'critical'}:
        raise SystemExit(f"{description} has an unsupported riskTier.")
    if not props['permittedConsumers']:
        raise SystemExit(f"{description} must name at least one permitted consumer.")
    if not str(props['evaluationResultsUrl']).startswith('https://'):
        raise SystemExit(f"{description} evaluationResultsUrl must use HTTPS.")
    last_review = datetime.strptime(props['lastReviewDate'], '%Y-%m-%d')
    expiry = datetime.strptime(props['expiryDate'], '%Y-%m-%d')
    if expiry <= last_review:
        raise SystemExit(f"{description} expiryDate must be later than lastReviewDate.")
    if props['implementationSession'] != '07-api-center-ai-mcp-inventory':
        raise SystemExit(f"{description} has the wrong implementationSession marker.")

validate_record(agent, 'Agent API definition')
if openapi.get('openapi') != '3.0.3' or openapi.get('paths', {}).get('/responses', {}).get('post') is None:
    raise SystemExit('The authoritative agent definition must be OpenAPI 3.0.3 with POST /responses.')
if 'servers' in openapi:
    raise SystemExit('The authoritative OpenAPI definition must not commit a runtime server URL.')
PY

environment_json=$(cat "$environment_path")
expected_agent_url="https://$(jq -r '.foundryAccountName' <<<"$environment_json").services.ai.azure.com/api/projects/$(jq -r '.foundryProjectName' <<<"$environment_json")/agents/$(jq -r '.agentName' <<<"$environment_json")/endpoint/protocols/openai"
[[ ${session04_agent_base_url%/} == "$expected_agent_url" ]] || fail "session04AgentBaseUrl does not match the existing Session 04 Foundry account, project, and agent."

version_ge() {
  local current=$1
  local minimum=$2
  [[ $(printf '%s\n%s\n' "$minimum" "$current" | sort -V | tail -n1) == "$current" ]]
}

cli_version=$(az_json 'Azure CLI version lookup' version)
cli_version_number=$(jq -r '."azure-cli"' <<<"$cli_version")
version_ge "$cli_version_number" '2.57.0' || fail 'Azure CLI 2.57.0 or later is required.'
extension_json=$(az_json 'apic-extension lookup' extension show --name apic-extension)
[[ -n $(jq -r '.version // empty' <<<"$extension_json") ]] || fail 'Install the current apic-extension before delivery.'
az apic integration create apim --help >/dev/null 2>&1 || fail 'The installed apic-extension does not expose the GA APIM integration command.'

account_json=$(az_json 'Azure account lookup' account show)
[[ $(jq -r '.id' <<<"$account_json") == "$approved_subscription_id" ]] || fail 'Azure CLI is not using the approved subscription.'
resource_group_json=$(az_json 'API Center resource group lookup' group show --name "$(jq -r '.resourceGroupName' <<<"$environment_json")")
[[ $(jq -r '.id' <<<"$resource_group_json") == "/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.resourceGroupName' <<<"$environment_json")" ]] || fail 'The API Center resource group is outside the approved subscription.'

provider_json=$(az_json 'API Center provider lookup' provider show --namespace Microsoft.ApiCenter)
python3 - <<'PY' "$provider_json" "$(jq -r '.location' <<<"$environment_json")"
import json
import sys
provider = json.loads(sys.argv[1])
location = ''.join(sys.argv[2].split()).lower()
service_types = [item for item in provider.get('resourceTypes', []) if item.get('resourceType') == 'services']
if len(service_types) != 1:
    raise SystemExit('The Microsoft.ApiCenter provider did not return one services resource type.')
locations = {''.join(item.split()).lower() for item in service_types[0].get('locations', [])}
if location not in locations:
    raise SystemExit('The approved location is not currently advertised for Microsoft.ApiCenter/services in this subscription.')
PY

apim_json=$(az_json 'API Management lookup' apim show --name "$(jq -r '.apiManagementName' <<<"$environment_json")" --resource-group "$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")")
expected_apim_id="/subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")/providers/Microsoft.ApiManagement/service/$(jq -r '.apiManagementName' <<<"$environment_json")"
[[ $(jq -r '.id' <<<"$apim_json") == "$expected_apim_id" ]] || fail 'API Management is outside the approved subscription or existing resource group.'
if [[ $(jq -r '.apiCenterPlan' <<<"$environment_json") == 'Standard' ]]; then
  apim_sku=$(jq -r '.sku.name' <<<"$apim_json")
  case "$apim_sku" in
    Standard|StandardV2|Premium|PremiumV2) ;;
    *) fail 'The approved Standard plan decision requires an eligible linked APIM tier or separate cost approval.' ;;
  esac
fi
if [[ $(jq -r '.apiCenterPlan' <<<"$environment_json") == 'Free' ]]; then
  warn 'The Free plan has limited features and no Microsoft support. Confirm its limits fit this nonproduction scope.'
fi

session07_api_json=$(az_json 'Session 06 APIM API lookup' apim api show --api-id policy-assistant-responses --service-name "$(jq -r '.apiManagementName' <<<"$environment_json")" --resource-group "$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")")
[[ $(jq -r '.description // ""' <<<"$session07_api_json") == *'implementationSession=06-apim-ai-gateway'* ]] || fail 'The APIM source does not contain the marked Session 06 API.'
[[ $(jq -r '.displayName' <<<"$session07_api_json") == 'Governed policy assistant Responses API' ]] || fail 'The Session 06 APIM display name does not match the approved synchronized API.'

role_json=$(az_json 'API Management Service Reader Role lookup' role definition list --name 71522526-b88f-4d52-b57f-d31fc3546d0d)
[[ $(jq -r 'length' <<<"$role_json") == '1' && $(jq -r '.[0].roleName' <<<"$role_json") == 'API Management Service Reader Role' ]] || fail 'Role definition 71522526-b88f-4d52-b57f-d31fc3546d0d is not the current API Management Service Reader Role.'

existing_api_center=$(az apic show --name "$(jq -r '.apiCenterName' <<<"$environment_json")" --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --only-show-errors --output json 2>/dev/null || true)
if [[ -n "$existing_api_center" ]]; then
  [[ $(jq -r '.tags.implementationSession // empty' <<<"$existing_api_center") == '07-api-center-ai-mcp-inventory' ]] || fail 'An existing API Center uses the configured name without the Session 06 marker.'
  existing_integration=$(az apic integration show --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" --service-name "$(jq -r '.apiCenterName' <<<"$environment_json")" --integration-name "$(jq -r '.integrationName' <<<"$environment_json")" --only-show-errors --output json 2>/dev/null || true)
  if [[ -n "$existing_integration" ]] && [[ "$existing_integration" != *"$expected_apim_id"* ]]; then
    fail 'The current integration name already points to a different API source.'
  fi
fi

echo 'Deployment preview:'
echo "  API Center: /subscriptions/$approved_subscription_id/resourceGroups/$(jq -r '.resourceGroupName' <<<"$environment_json")/providers/Microsoft.ApiCenter/services/$(jq -r '.apiCenterName' <<<"$environment_json")"
echo "  Location: $(jq -r '.location' <<<"$environment_json")"
echo "  Plan decision: $(jq -r '.apiCenterPlan' <<<"$environment_json")"
echo "  APIM source: $expected_apim_id"
echo "  Agent API: $(jq -r '.api.title' "$agent_definition_path")"
echo '  Remote MCP server: supplied at registration and retained in API Center only'
echo '  Runtime URLs: supplied at delivery and not retained'

az bicep build --file "$bicep_path" --stdout >/dev/null || fail 'The API Center Bicep definition failed to compile.'
az deployment group what-if \
  --name session07-api-center-preview \
  --resource-group "$(jq -r '.resourceGroupName' <<<"$environment_json")" \
  --template-file "$bicep_path" \
  --parameters \
    "apiManagementResourceGroupName=$(jq -r '.apiManagementResourceGroupName' <<<"$environment_json")" \
    "apiManagementName=$(jq -r '.apiManagementName' <<<"$environment_json")" \
    "apiCenterName=$(jq -r '.apiCenterName' <<<"$environment_json")" \
    "location=$(jq -r '.location' <<<"$environment_json")" \
    "session04AgentBaseUrl=$session04_agent_base_url" \
  --only-show-errors \
  --no-pretty-print >/dev/null || fail 'The API Center deployment preview failed.'

echo 'PASS: Session 06 files, direct-agent desired state, APIM boundary, runtime coordinates, CLI integration, and deployment preview are ready.'
