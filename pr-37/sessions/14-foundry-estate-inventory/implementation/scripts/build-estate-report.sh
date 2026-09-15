#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
output_path=""

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

while (($# > 0)); do
  case "$1" in
    --output-path)
      (($# >= 2)) || fail "--output-path requires a value."
      output_path=$2
      shift 2
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

command -v python3 >/dev/null 2>&1 || fail "python3 is required."
command -v az >/dev/null 2>&1 || fail "The Azure CLI is required."

args=(
  --scope-path "$artifact_root/estate-scope.json"
  --account-query-path "$artifact_root/queries/foundry-accounts.kql"
  --service-health-query-path "$artifact_root/queries/service-health-retirements.kql"
  --advisor-query-path "$artifact_root/queries/advisor-retirement-findings.kql"
)
if [[ -n "$output_path" ]]; then
  args+=(--output-path "$output_path")
fi

python3 "$script_dir/build-estate-report.py" "${args[@]}"
