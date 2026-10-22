#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
design_record_path="$script_dir/../artifacts/gateway-design-record.json"
implementation_args=()
named_sentinels=(
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_APIM_DEPLOYMENT_MODEL__"
  "__REQUIRED_APIM_INSTANCE__"
  "__REQUIRED_APIM_NAME__"
  "__REQUIRED_APIM_TIER__"
  "__REQUIRED_APIM_VIRTUAL_NETWORK_TYPE__"
  "__REQUIRED_API_AUDIENCE__"
  "__REQUIRED_API_PRODUCT_OWNER__"
  "__REQUIRED_APPROVED_ENDPOINT_REFERENCE__"
  "__REQUIRED_APPROVED_SCOPE__"
  "__REQUIRED_APP_INSIGHTS_LOGGER_NAME__"
  "__REQUIRED_APP_ROLE__"
  "__REQUIRED_BACKEND_IDENTITY__"
  "__REQUIRED_BACKEND_NETWORK_PATH__"
  "__REQUIRED_BACKEND_ROLE_STATE__"
  "__REQUIRED_CHANGE_REFERENCE__"
  "__REQUIRED_CLIENT_APPLICATION_ID__"
  "__REQUIRED_CLIENT_IDENTITY__"
  "__REQUIRED_CONTENT_SAFETY_BACKEND_ID__"
  "__REQUIRED_CONTENT_SAFETY_DECISION__"
  "__REQUIRED_CONTENT_SAFETY_PUBLIC_NETWORK_ACCESS__"
  "__REQUIRED_CONTENT_SAFETY_REFERENCE__"
  "__REQUIRED_CONTENT_SAFETY_RESOURCE_ID__"
  "__REQUIRED_DELIVERY_OWNER__"
  "__REQUIRED_DESIGN_APPROVER__"
  "__REQUIRED_ENTRA_TENANT_ID__"
  "__REQUIRED_ENVIRONMENT__"
  "__REQUIRED_FOUNDRY_ACCOUNT_NAME__"
  "__REQUIRED_FOUNDRY_PROJECT_NAME__"
  "__REQUIRED_FOUNDRY_PUBLIC_NETWORK_ACCESS__"
  "__REQUIRED_GAP_OWNER__"
  "__REQUIRED_GAP_RESOLUTION__"
  "__REQUIRED_IDENTITY_OWNER__"
  "__REQUIRED_IMPLEMENTATION_VARIANT__"
  "__REQUIRED_INBOUND_NETWORK_PATH__"
  "__REQUIRED_INGRESS_PATTERN__"
  "__REQUIRED_NETWORK_OWNER__"
  "__REQUIRED_OPERATIONS_OWNER__"
  "__REQUIRED_PLATFORM_OWNER__"
  "__REQUIRED_PRIVATE_DNS_STATE__"
  "__REQUIRED_PRODUCT_OWNER__"
  "__REQUIRED_READINESS_GAP_DESCRIPTION__"
  "__REQUIRED_RECORD_STATUS__"
  "__REQUIRED_REQUEST_LIMIT__"
  "__REQUIRED_RESOURCE_GROUP_NAME__"
  "__REQUIRED_RESTORE_DECISION__"
  "__REQUIRED_ROUTING_DECISION__"
  "__REQUIRED_SAFETY_OWNER__"
  "__REQUIRED_SAFETY_POLICY__"
  "__REQUIRED_TARGET_BACKEND_TYPE__"
  "__REQUIRED_TELEMETRY_BODY_POLICY__"
  "__REQUIRED_TELEMETRY_SINK__"
  "__REQUIRED_TOKEN_LIMIT_DECISION__"
)
[[ -f "$design_record_path" ]] || { echo "ERROR: The gateway design record is missing: $design_record_path" >&2; exit 1; }
command -v bash >/dev/null 2>&1 || { echo "ERROR: bash is required." >&2; exit 1; }
artifact_root="$script_dir/../artifacts"
mapfile -t found_sentinels < <(grep -RhoE '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
for sentinel in "${found_sentinels[@]}"; do
  known=false
  for named in "${named_sentinels[@]}"; do
    [[ "$sentinel" == "$named" ]] && { known=true; break; }
  done
  $known || { echo "ERROR: Preflight has no named coverage for $sentinel." >&2; exit 1; }
done
(( ${#found_sentinels[@]} == 0 )) || { echo 'ERROR: Resolve every __REQUIRED_*__ decision before deployment.' >&2; exit 1; }

while (($# > 0)); do
  case "$1" in
    --design-record-path)
      [[ $# -ge 2 ]] || { echo 'ERROR: --design-record-path requires a value.' >&2; exit 2; }
      design_record_path=$2
      implementation_args+=("$1" "$2")
      shift 2
      ;;
    *)
      implementation_args+=("$1")
      shift
      ;;
  esac
done

"$script_dir/preflight-design.sh" --design-record-path "$design_record_path"
"$script_dir/preflight-implementation.sh" "${implementation_args[@]}"
