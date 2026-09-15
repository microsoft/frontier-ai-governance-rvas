#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  preflight.sh --project-endpoint URL --approved-target-scope SCOPE

Checks the approved nonproduction scope, public-preview decision, API Center
reconciliation record, Foundry project connection, and dedicated Toolbox name.
EOF
}

project_endpoint=""
approved_target_scope=""

while (($# > 0)); do
  case "$1" in
    --project-endpoint)
      [[ $# -ge 2 ]] || { echo "ERROR: --project-endpoint requires a value." >&2; exit 2; }
      project_endpoint=$2
      shift 2
      ;;
    --approved-target-scope)
      [[ $# -ge 2 ]] || { echo "ERROR: --approved-target-scope requires a value." >&2; exit 2; }
      approved_target_scope=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -n "$project_endpoint" ]] || { echo "ERROR: --project-endpoint is required." >&2; exit 2; }
[[ -n "$approved_target_scope" ]] || { echo "ERROR: --approved-target-scope is required." >&2; exit 2; }
[[ "$project_endpoint" =~ ^https://.+/api/projects/[^/]+/?$ ]] || {
  echo "ERROR: --project-endpoint must be the exact HTTPS Microsoft Foundry project endpoint." >&2
  exit 2
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

for command in az azd python3; do
  command -v "$command" >/dev/null 2>&1 || fail "$command is required."
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
binding_path="$artifact_root/governance/catalog-toolbox-binding.json"
toolbox_path="$artifact_root/toolbox/toolbox-version.json"
check_path="$artifact_root/operations/check_toolbox.py"
required_files=("$binding_path" "$toolbox_path" "$check_path")
required_sentinels=(
  "__REQUIRED_AGENT_RELEASE_OWNER_ROLE__"
  "__REQUIRED_ALLOWED_TOOL_NAME__"
  "__REQUIRED_API_CATALOG_OWNER_ROLE__"
  "__REQUIRED_API_CENTER_NAME__"
  "__REQUIRED_API_CENTER_WORKSPACE_NAME__"
  "__REQUIRED_APPROVAL_REFERENCE__"
  "__REQUIRED_APPROVED_TARGET_SCOPE__"
  "__REQUIRED_CATALOG_DISCOVERY_CONFIRMATION__"
  "__REQUIRED_CONNECTION_AUTHENTICATION_MODE__"
  "__REQUIRED_FOUNDRY_PROJECT_NAME__"
  "__REQUIRED_FOUNDRY_TOOL_OWNER_ROLE__"
  "__REQUIRED_MCP_ASSET_NAME__"
  "__REQUIRED_MCP_ASSET_VERSION__"
  "__REQUIRED_MCP_DEPLOYMENT_NAME__"
  "__REQUIRED_MCP_ENDPOINT_SHA256__"
  "__REQUIRED_MCP_SERVER_URL__"
  "__REQUIRED_NAMESPACED_TOOL_NAME__"
  "__REQUIRED_PREVIEW_DECISION__"
  "__REQUIRED_PREVIEW_DECISION_OWNER_ROLE__"
  "__REQUIRED_PROJECT_CONNECTION_NAME__"
  "__REQUIRED_RESTORE_OWNER_ROLE__"
  "__REQUIRED_SERVER_LABEL__"
  "__REQUIRED_SOURCE_AUTHENTICATION_MODE__"
  "__REQUIRED_TOOLBOX_NAME__"
)

[[ -d "$artifact_root" ]] || fail "Required implementation artifacts folder is missing: $artifact_root"
for path in "${required_files[@]}"; do
  [[ -f "$path" ]] || fail "Required module file is missing: $path"
done

mapfile -t unresolved_sentinels < <(
  grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true
)
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
    fail "Add explicit preflight checks for new sentinels: ${unknown[*]}"
  fi
  grep -R -n -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" >&2
  fail "Resolve every catalog and Toolbox decision before change."
fi

readarray -t values < <(
  python3 - "$binding_path" "$toolbox_path" "$approved_target_scope" <<'PY'
import hashlib
import json
import sys

binding_path, toolbox_path, approved_target_scope = sys.argv[1:]
with open(binding_path, encoding="utf-8") as handle:
    binding = json.load(handle)
with open(toolbox_path, encoding="utf-8") as handle:
    toolbox = json.load(handle)

if binding.get("implementationSession") != "optional-module-foundry-tool-catalog-integration":
    raise SystemExit("The binding record has the wrong implementationSession marker.")
if binding.get("targetScope") != approved_target_scope:
    raise SystemExit("The target scope does not match the approved target scope in the binding record.")
preview = binding.get("previewDecision", {})
if preview.get("privateToolCatalog") != "accepted-for-approved-nonproduction-scope":
    raise SystemExit("The public-preview private tool catalog must be explicitly accepted for the approved nonproduction scope.")
if preview.get("catalogDiscovery") != "confirmed-in-foundry-tools":
    raise SystemExit("Confirm the API Center record is visible under Build > Tools in the intended Foundry project.")

foundry = binding.get("foundryBinding", {})
if foundry.get("initialToolboxState") != "absent":
    raise SystemExit("This module creates one dedicated Toolbox and requires its initial state to be absent.")
if foundry.get("requireApproval") != "always":
    raise SystemExit("The binding record must require approval for every tool call.")
source = binding.get("sourceRecord", {})
if source.get("lifecycleState") != "approved":
    raise SystemExit("The API Center source record lifecycleState must be approved.")
if source.get("authenticationMode") != foundry.get("connectionAuthenticationMode"):
    raise SystemExit("The API Center and Foundry project connection authentication modes do not match.")

tools = toolbox.get("tools", [])
if not isinstance(tools, list) or len(tools) != 1:
    raise SystemExit("toolbox-version.json must define exactly one tool.")
tool = tools[0]
if tool.get("type") != "mcp":
    raise SystemExit("The Toolbox definition must contain one MCP tool.")
allowed = tool.get("allowed_tools", [])
if not isinstance(allowed, list) or len(allowed) != 1:
    raise SystemExit("The MCP binding must allow exactly one tool.")
if tool.get("require_approval") != "always":
    raise SystemExit("The MCP tool must require approval for every call.")
if tool.get("server_label") != foundry.get("serverLabel"):
    raise SystemExit("The Toolbox server_label does not match the binding record.")
if allowed[0] != foundry.get("allowedToolName"):
    raise SystemExit("The Toolbox allowed_tools entry does not match the binding record.")
if tool.get("project_connection_id") != foundry.get("projectConnectionName"):
    raise SystemExit("The Toolbox project_connection_id does not match the binding record.")
if f"{tool.get('server_label')}.{allowed[0]}" != foundry.get("expectedNamespacedTool"):
    raise SystemExit("The expected namespaced tool must be '<server_label>.<allowed_tool_name>'.")

endpoint = tool.get("server_url", "").rstrip("/")
endpoint_hash = hashlib.sha256(endpoint.encode("utf-8")).hexdigest()
if endpoint_hash.lower() != source.get("mcpEndpointSha256", "").lower():
    raise SystemExit("The Toolbox MCP endpoint does not match the approved API Center deployment endpoint hash.")

description = toolbox.get("description", "")
if "implementationSession=optional-module-foundry-tool-catalog-integration" not in description:
    raise SystemExit("The Toolbox description must retain the implementationSession marker.")

print(foundry.get("projectConnectionName", ""))
print(foundry.get("toolboxName", ""))
PY
)

connection_name=${values[0]}
toolbox_name=${values[1]}
[[ -n "$connection_name" ]] || fail "The project connection name is empty."
[[ -n "$toolbox_name" ]] || fail "The Toolbox name is empty."

az account show --output none
azd ai toolbox --help >/dev/null
azd ai project set "$project_endpoint" >/dev/null
azd ai connection show "$connection_name" --output json >/dev/null

set +e
toolbox_lookup=$(azd ai toolbox show "$toolbox_name" --output json 2>&1)
toolbox_lookup_status=$?
set -e
if [[ $toolbox_lookup_status -eq 0 ]]; then
  fail "The dedicated Toolbox '$toolbox_name' already exists. Stop rather than adding a version to an unreviewed Toolbox."
fi
if ! grep -Eqi '(not found|could not be found|404)' <<<"$toolbox_lookup"; then
  fail "Could not confirm that Toolbox '$toolbox_name' is unused: $toolbox_lookup"
fi

echo "No read-only deployment preview is supported for Toolbox version creation."
echo "PASS: the exact target scope, preview decision, API Center reconciliation, project connection, one-tool payload, and no-collision gate are ready."
