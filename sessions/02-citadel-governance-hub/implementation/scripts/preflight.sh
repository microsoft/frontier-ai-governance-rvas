#!/usr/bin/env bash
set -euo pipefail

# Required profile sentinels checked before deployment:
# __REQUIRED_HUB_RESOURCE_GROUP__ __REQUIRED_NETWORK_RESOURCE_GROUP__ __REQUIRED_VNET_NAME__
# __REQUIRED_APIM_SUBNET_NAME__ __REQUIRED_PRIVATE_ENDPOINT_SUBNET_NAME__
# __REQUIRED_LOG_ANALYTICS_RESOURCE_GROUP__ __REQUIRED_LOG_ANALYTICS_NAME__

usage() {
  echo "Usage: preflight.sh --citadel-path PATH --subscription-id ID"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

citadel_path=""
subscription_id=""
while (($#)); do
  case "$1" in
    --citadel-path) citadel_path="${2:-}"; shift 2 ;;
    --subscription-id) subscription_id="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown option: $1" ;;
  esac
done

[[ -n "$citadel_path" ]] || fail "--citadel-path is required."
[[ -n "$subscription_id" ]] || fail "--subscription-id is required."
for command_name in git az azd jq; do
  command -v "$command_name" >/dev/null 2>&1 || fail "$command_name is required."
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
release_path="$script_dir/../artifacts/citadel/release.json"
profile_path="$script_dir/../artifacts/citadel/deployment-profile.json"
[[ -f "$release_path" && -f "$profile_path" ]] || fail "Citadel release and deployment profile are required."
[[ -d "$citadel_path/.git" ]] || fail "The Citadel path is not a Git checkout."

expected_commit="$(jq -r '.commit' "$release_path")"
actual_commit="$(git -C "$citadel_path" rev-parse HEAD)"
[[ "$actual_commit" == "$expected_commit" ]] || fail "Citadel checkout must resolve to $expected_commit."

if grep -R -q -E '__REQUIRED_[A-Z0-9_]+__' "$script_dir/../artifacts"; then
  fail "Resolve every __REQUIRED_*__ value in the Citadel deployment profile."
fi

active_subscription="$(az account show --query id --output tsv --only-show-errors)"
[[ "$active_subscription" == "$subscription_id" ]] || fail "Azure CLI is not using the approved subscription."

template_path="$(jq -r '.templatePath' "$release_path")"
parameter_path="$(jq -r '.parameterPath' "$release_path")"
[[ -f "$citadel_path/$template_path" && -f "$citadel_path/$parameter_path" ]] || fail "The pinned Citadel deployment files are missing."

echo "PASS: pinned Citadel source, deployment profile, tools, and Azure subscription are ready."
