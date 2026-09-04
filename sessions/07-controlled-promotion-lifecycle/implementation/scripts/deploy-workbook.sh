#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
target_scope=""
subscription_id=""
resource_group=""

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
    --subscription-id)
      (($# >= 2)) || fail "--subscription-id requires a value."
      subscription_id=$2
      shift 2
      ;;
    --resource-group)
      (($# >= 2)) || fail "--resource-group requires a value."
      resource_group=$2
      shift 2
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$target_scope" && -n "$subscription_id" && -n "$resource_group" ]] || fail \
  "--target-scope, --subscription-id, and --resource-group are required."

"$script_dir/preflight.sh" \
  --target-scope "$target_scope" \
  --workbook-subscription-id "$subscription_id" \
  --workbook-resource-group "$resource_group"

az deployment group create \
  --subscription "$subscription_id" \
  --resource-group "$resource_group" \
  --name rvas-foundry-estate-lifecycle-workbook \
  --template-file "$artifact_root/infra/main.bicep" \
  --only-show-errors
