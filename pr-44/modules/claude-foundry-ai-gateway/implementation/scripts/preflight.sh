#!/usr/bin/env bash
set -euo pipefail

# Shared checker rejects these decisions before inspecting the approved target scope.
# __REQUIRED_SUBSCRIPTION_ID__ __REQUIRED_TENANT_ID__ __REQUIRED_APIM_RESOURCE_GROUP__
# __REQUIRED_APIM_NAME__ __REQUIRED_FOUNDRY_RESOURCE_GROUP__ __REQUIRED_FOUNDRY_NAME__
# __REQUIRED_GATEWAY_CLIENT_ID__ __REQUIRED_DESKTOP_CLIENT_ID__ __REQUIRED_GATEWAY_BASE_URL__
# __REQUIRED_GATEWAY_OWNER__ __REQUIRED_IDENTITY_OWNER__ __REQUIRED_CLIENT_OWNER__
# __REQUIRED_RESTORE_REFERENCE__ __REQUIRED_NETWORK_PATH__ __REQUIRED_HELPER_COMMAND__
# __REQUIRED_SONNET_DEPLOYMENT__ __REQUIRED_OPUS_DEPLOYMENT__ __REQUIRED_HAIKU_DEPLOYMENT__
command -v python3 >/dev/null || { printf 'Python 3 is required.\n' >&2; exit 1; }
command -v az >/dev/null || { printf 'Azure CLI is required.\n' >&2; exit 1; }
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$script_dir/preflight.py" ]] || { printf 'Missing shared preflight checker.\n' >&2; exit 1; }
python3 "$script_dir/preflight.py" "$@"
