#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: deploy.sh --citadel-path PATH --resource-group NAME [--include-publish]"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

citadel_path=""
resource_group=""
include_publish=false
while (($#)); do
  case "$1" in
    --citadel-path) citadel_path="${2:-}"; shift 2 ;;
    --resource-group) resource_group="${2:-}"; shift 2 ;;
    --include-publish) include_publish=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown option: $1" ;;
  esac
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$script_dir/preflight.sh" --citadel-path "$citadel_path" --resource-group "$resource_group"
artifact_root="$script_dir/../artifacts"

deploy_contract() {
  local name="$1"
  local template="$2"
  local parameters="$3"
  az deployment group what-if --name "$name-preview" --resource-group "$resource_group" --template-file "$template" --parameters "$parameters" --only-show-errors
  az deployment group create --name "$name" --resource-group "$resource_group" --template-file "$template" --parameters "$parameters" --only-show-errors
}

deploy_contract "citadel-backend-contract" "$citadel_path/bicep/infra/llm-backend-onboarding/main.bicep" "$artifact_root/contracts/backend/main.bicepparam"
if [[ "$include_publish" == true ]]; then
  deploy_contract "citadel-publish-contract" "$citadel_path/bicep/infra/citadel-publish-contracts/main.bicep" "$artifact_root/contracts/publish/main.bicepparam"
fi
deploy_contract "citadel-access-contract" "$citadel_path/bicep/infra/citadel-access-contracts/main.bicep" "$artifact_root/contracts/access/main.bicepparam"

echo "PASS: Citadel contracts were previewed and deployed in dependency order."
