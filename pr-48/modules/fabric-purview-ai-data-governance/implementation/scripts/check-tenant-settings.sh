#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/check-tenant-settings.sh --target-scope one-approved-fabric-ai-grounding-lakehouse [--baseline-file PATH]

Reads Fabric tenant settings through the Fabric Admin REST API and compares the Copilot and AI
settings group with tenant-settings-baseline.json.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

target_scope=""
baseline_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-scope)
      [[ $# -ge 2 ]] || fail "--target-scope requires a value."
      target_scope="$2"
      shift 2
      ;;
    --baseline-file)
      [[ $# -ge 2 ]] || fail "--baseline-file requires a value."
      baseline_file="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown option: $1"
      ;;
  esac
done

for command in az curl jq grep; do
  command -v "$command" >/dev/null 2>&1 || fail "Required command is unavailable: $command"
done

[[ "$target_scope" == "one-approved-fabric-ai-grounding-lakehouse" ]] ||
  fail "--target-scope must be one-approved-fabric-ai-grounding-lakehouse."

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
[[ -n "$baseline_file" ]] || baseline_file="$script_dir/../artifacts/fabric/tenant-settings-baseline.json"
[[ -f "$baseline_file" ]] || fail "Tenant settings baseline file is missing: $baseline_file"

if grep -q -E '__REQUIRED_[A-Z0-9_]+__' "$baseline_file"; then
  grep -o -E '__REQUIRED_[A-Z0-9_]+__' "$baseline_file" | sort -u >&2
  fail "Resolve tenant baseline decisions before reading Fabric settings."
fi

[[ "$(jq -r '.implementationSession' "$baseline_file")" == "optional-module-fabric-purview-ai-data-governance" ]] ||
  fail "The baseline file has the wrong implementationSession marker."
[[ "$(jq -r '.targetScope' "$baseline_file")" == "$target_scope" ]] ||
  fail "The baseline targetScope does not match the approved target scope."

token="$(az account get-access-token --resource "https://api.fabric.microsoft.com" --query accessToken --output tsv --only-show-errors)"
[[ -n "$token" ]] || fail "Could not get a Fabric API access token with Azure CLI."

settings_json='[]'
uri='https://api.fabric.microsoft.com/v1/admin/tenantsettings'
while [[ -n "$uri" && "$uri" != "null" ]]; do
  response="$(curl -fsS -H "Authorization: Bearer $token" "$uri")"
  settings_json="$(jq -s '.[0] + (.[1].value // [])' <(printf '%s' "$settings_json") <(printf '%s' "$response"))"
  uri="$(jq -r '.continuationUri // empty' <<<"$response")"
done

drift_count=0
while IFS= read -r expected; do
  title="$(jq -r '.title' <<<"$expected")"
  expected_enabled="$(jq -r '.expectedEnabled' <<<"$expected")"
  actual="$(jq --arg title "$title" '.[] | select(.title == $title)' <<<"$settings_json")"
  if [[ -z "$actual" ]]; then
    printf 'Missing setting: %s\n' "$title"
    drift_count=$((drift_count + 1))
    continue
  fi
  actual_enabled="$(jq -r '.enabled' <<<"$actual")"
  if [[ "$actual_enabled" != "$expected_enabled" ]]; then
    printf 'Enabled drift: %s\n' "$title"
    drift_count=$((drift_count + 1))
  fi
  expected_scope="$(jq -r '.expectedScope' <<<"$expected")"
  expected_groups_json="$(jq -c '[.expectedSecurityGroups[]? | select(. != null and . != "")] | sort | unique' <<<"$expected")"
  actual_groups_json="$(jq -c '[.enabledSecurityGroups[]?.name | select(. != null and . != "")] | sort | unique' <<<"$actual")"
  case "$expected_scope" in
    specific-security-groups)
      if [[ "$actual_groups_json" != "$expected_groups_json" ]]; then
        printf 'Group scope drift: %s\n' "$title"
        drift_count=$((drift_count + 1))
      fi
      ;;
    tenant)
      if [[ "$(jq 'length' <<<"$actual_groups_json")" != "0" ]]; then
        printf 'Tenant scope drift: %s\n' "$title"
        drift_count=$((drift_count + 1))
      fi
      ;;
    *)
      printf "Unknown expectedScope '%s': %s\n" "$expected_scope" "$title"
      drift_count=$((drift_count + 1))
      ;;
  esac
done < <(jq -c '.watchList[]' "$baseline_file")

if ((drift_count > 0)); then
  printf 'DRIFT: %s Copilot and AI tenant setting difference(s) found.\n' "$drift_count"
  exit 2
fi

echo "PASS: Copilot and AI tenant settings match the recorded baseline."
