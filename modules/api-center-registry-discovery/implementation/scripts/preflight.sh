#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
target_scope=""

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

while (($# > 0)); do
  case "$1" in
    --target-scope)
      (($# >= 2)) || fail "--target-scope requires a value."
      target_scope=$2
      shift 2
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$target_scope" ]] || fail "--target-scope is required."
command -v python3 >/dev/null 2>&1 || fail "python3 is required."

check_script="$script_dir/check-discovery.sh"
[[ -x "$check_script" ]] || fail \
  "The live discovery check cannot run because check-discovery.sh is missing or not executable: $check_script"

client_path="$artifact_root/registry-client-settings.json"
ownership_path="$artifact_root/registry-ownership.json"
[[ -f "$client_path" ]] || fail "Required module artifact is missing: $client_path"
[[ -f "$ownership_path" ]] || fail "Required module artifact is missing: $ownership_path"

required_sentinels=(
  "__REQUIRED_APPROVED_API_CENTER_SCOPE__"
  "__REQUIRED_API_CENTER_CONFIGURATION_OWNER_ROLE__"
  "__REQUIRED_API_CENTER_NAME__"
  "__REQUIRED_API_CENTER_REGION__"
  "__REQUIRED_API_CENTER_RESOURCE_SCOPE_ALIAS__"
  "__REQUIRED_APPROVED_MCP_SERVER_NAME__"
  "__REQUIRED_CLIENT_CONFIGURATION_OWNER_ROLE__"
  "__REQUIRED_DEVELOPER_GROUP_ALIAS__"
  "__REQUIRED_DISCOVERY_REVIEW_DATE__"
  "__REQUIRED_MCP_TRANSPORT__"
  "__REQUIRED_PORTAL_APP_CLIENT_ID_REFERENCE__"
  "__REQUIRED_PREVIOUS_VISIBILITY_CONFIG_REFERENCE__"
  "__REQUIRED_RUNTIME_OWNER_ROLE__"
  "__REQUIRED_SECURITY_OWNER_ROLE__"
  "__REQUIRED_SERVER_OWNER_ROLE__"
  "__REQUIRED_TENANT_ID_REFERENCE__"
)

mapfile -t unresolved < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved[@]} > 0)); then
  unknown=()
  for sentinel in "${unresolved[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      if [[ "$sentinel" == "$required" ]]; then
        known=true
        break
      fi
    done
    $known || unknown+=("$sentinel")
  done
  ((${#unknown[@]} == 0)) || fail "Add explicit preflight coverage for new sentinels: ${unknown[*]}"
  fail "Resolve every API Center registry discovery decision before the portal change: ${unresolved[*]}"
fi

python3 - "$client_path" "$ownership_path" "$target_scope" <<'PY'
import json
import sys
from urllib.parse import urlparse

client_path, ownership_path, target_scope = sys.argv[1:]
with open(client_path, encoding="utf-8") as handle:
    client = json.load(handle)
with open(ownership_path, encoding="utf-8") as handle:
    ownership = json.load(handle)

for record in (client, ownership):
    if record.get("implementationModule") != "api-center-registry-discovery":
        raise SystemExit("An artifact has the wrong implementationModule marker.")
    if record.get("implementationSession") != "api-center-registry-discovery":
        raise SystemExit("An artifact has the wrong implementationSession marker.")

if client.get("targetScope") != target_scope or ownership.get("approvedScope") != target_scope:
    raise SystemExit("Target scope must match both artifact scope values.")

registry = client.get("registry", {})
endpoint = urlparse(registry.get("endpoint", ""))
if endpoint.scheme != "https" or endpoint.path != "/workspaces/default/v0.1/servers":
    raise SystemExit(
        "The registry endpoint must use HTTPS and the documented "
        "/workspaces/default/v0.1/servers path."
    )
if registry.get("workspace") != "default" or registry.get("apiVersion") != "v0.1":
    raise SystemExit("The documented API Center registry path uses the default workspace and v0.1.")

authentication = registry.get("authentication", {})
developer_access = ownership.get("developerAccess", {})
if (
    authentication.get("mode") != "MicrosoftEntraID"
    or developer_access.get("authenticationMode") != "MicrosoftEntraID"
    or developer_access.get("anonymousAccess") is not False
):
    raise SystemExit("This module requires Microsoft Entra ID and rejects anonymous access.")
if (
    authentication.get("requiredAzureRole") != "Azure API Center Data Reader"
    or developer_access.get("azureRole") != "Azure API Center Data Reader"
):
    raise SystemExit("Developer discovery requires the Azure API Center Data Reader role.")
if authentication.get("delegatedScope") != "https://azure-apicenter.net/Data.Read.All":
    raise SystemExit("The client contract must use the documented data-plane delegated scope.")

conditions = ownership.get("visibility", {}).get("builtInConditions", [])
expected = {
    ("API type", "equals", "MCP"),
    ("Lifecycle stage", "equals", "Production"),
}
actual = {
    (item.get("property"), item.get("operator"), item.get("value"))
    for item in conditions
}
if len(conditions) != 2 or actual != expected:
    raise SystemExit(
        "Visibility must contain exactly API type = MCP and Lifecycle stage = Production."
    )
visibility = ownership.get("visibility", {})
if visibility.get("customMetadataIsAuthorization") is not False:
    raise SystemExit("Custom metadata is not an authorization control in this module.")
if visibility.get("perUserVisibility") is not False:
    raise SystemExit("Per-user visibility is outside the documented discovery boundary.")

client_names = sorted(set(client.get("approvedServerNames", [])))
owner_names = sorted(
    {entry.get("name") for entry in ownership.get("approvedServers", []) if entry.get("name")}
)
if not client_names or client_names != owner_names:
    raise SystemExit(
        "The client contract and ownership record must contain the same approved server names."
    )
PY

echo "PASS: Registry discovery artifacts are complete for approved scope '$target_scope'."
echo "Portal preview required: confirm the Data API visibility preview contains only MCP records at Production lifecycle stage."
