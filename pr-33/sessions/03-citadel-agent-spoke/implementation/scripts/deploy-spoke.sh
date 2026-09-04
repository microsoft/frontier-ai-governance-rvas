#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  deploy-spoke.sh --source-path PATH --approved-subscription-id ID --deployment-principal-id ID --apply
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

source_path=""
approved_subscription_id=""
deployment_principal_id=""
apply=false

while (($#)); do
  case "$1" in
    --source-path) source_path="${2:-}"; shift 2 ;;
    --approved-subscription-id) approved_subscription_id="${2:-}"; shift 2 ;;
    --deployment-principal-id) deployment_principal_id="${2:-}"; shift 2 ;;
    --apply) apply=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown option: $1" ;;
  esac
done

[[ "$apply" == true ]] || fail "--apply is required after review of the deployment preview."

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
profile_path="$script_dir/../artifacts/citadel/spoke-profile.json"
release_path="$script_dir/../artifacts/citadel/release.json"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
parameters_path="$temp_dir/main.parameters.json"

"$script_dir/preflight.sh" \
  --source-path "$source_path" \
  --approved-subscription-id "$approved_subscription_id" \
  --deployment-principal-id "$deployment_principal_id" \
  --parameters-output "$parameters_path"

resource_group="$(jq -r '.resourceGroupName' "$profile_path")"
entry_point="$(jq -r '.implementation.entryPoint' "$release_path")"
az deployment group create \
  --name session03-agent-spoke \
  --resource-group "$resource_group" \
  --template-file "$source_path/$entry_point" \
  --parameters "@$parameters_path" \
  --only-show-errors >/dev/null

foundry_account="$(jq -r '.foundry.accountName' "$profile_path")"
project_name="$(jq -r '.foundry.projectName' "$profile_path")"
app_insights_name="$(jq -r '.observability.applicationInsightsName' "$profile_path")"

az cognitiveservices account show --name "$foundry_account" --resource-group "$resource_group" --only-show-errors >/dev/null
az resource show \
  --ids "/subscriptions/$approved_subscription_id/resourceGroups/$resource_group/providers/Microsoft.CognitiveServices/accounts/$foundry_account/projects/$project_name" \
  --only-show-errors >/dev/null
az monitor app-insights component show --app "$app_insights_name" --resource-group "$resource_group" --only-show-errors >/dev/null

echo "PASS: The pinned AI Landing Zones Bicep implementation deployed the approved Agent Spoke profile."
