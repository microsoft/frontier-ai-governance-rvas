#!/usr/bin/env bash
set -euo pipefail

tenant_id="__REQUIRED_TENANT_ID__"
resource="api://__REQUIRED_GATEWAY_CLIENT_ID__"
if [[ "$tenant_id$resource" == *"__REQUIRED_"* ]]; then
    printf 'Configure the gateway tenant and audience before installing this helper.\n' >&2
    exit 1
fi
command -v az >/dev/null || { printf 'Azure CLI is required.\n' >&2; exit 1; }

if ! token="$(az account get-access-token --tenant "$tenant_id" --resource "$resource" --query accessToken --output tsv)"; then
    printf 'Gateway token acquisition failed. Signing in to the approved tenant.\n' >&2
    az login --tenant "$tenant_id" --scope "$resource/.default" --output none >&2
    token="$(az account get-access-token --tenant "$tenant_id" --resource "$resource" --query accessToken --output tsv)"
fi
[[ -n "$token" ]] || { printf 'Azure CLI returned an empty token.\n' >&2; exit 1; }
printf '%s\n' "$token"
