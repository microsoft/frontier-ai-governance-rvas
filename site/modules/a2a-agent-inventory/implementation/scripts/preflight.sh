#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh \
    --target-scope one-approved-a2a-agent \
    --integration-path built-in|registry-sync|sdk \
    --runtime-source-reference URL \
    [--registry-sync-platform PLATFORM]
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

target_scope=""
integration_path=""
runtime_source_reference=""
registry_sync_platform=""
while (($# > 0)); do
  case "$1" in
    --target-scope)
      [[ $# -ge 2 ]] || fail "--target-scope requires a value."
      target_scope=$2
      shift 2
      ;;
    --integration-path)
      [[ $# -ge 2 ]] || fail "--integration-path requires a value."
      integration_path=$2
      shift 2
      ;;
    --runtime-source-reference)
      [[ $# -ge 2 ]] || fail "--runtime-source-reference requires a value."
      runtime_source_reference=$2
      shift 2
      ;;
    --registry-sync-platform)
      [[ $# -ge 2 ]] || fail "--registry-sync-platform requires a value."
      registry_sync_platform=$2
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

command -v date >/dev/null 2>&1 || fail "date is required."
[[ -d "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" ]] ||
  fail "The module script directory is unavailable."
[[ "$target_scope" == "one-approved-a2a-agent" ]] ||
  fail "--target-scope must be one-approved-a2a-agent."
case "$integration_path" in
  built-in|registry-sync|sdk) ;;
  *) fail "--integration-path must be built-in, registry-sync, or sdk." ;;
esac
[[ -n "$runtime_source_reference" ]] ||
  fail "--runtime-source-reference is required."
[[ ! "$runtime_source_reference" =~ __REQUIRED_[A-Z0-9_]+__ ]] ||
  fail "Resolve every __REQUIRED_ source reference before onboarding."
[[ "$runtime_source_reference" =~ ^https?:// ]] ||
  fail "--runtime-source-reference must be an absolute HTTP or HTTPS URI."
[[ ! "$runtime_source_reference" =~ https?://[^/:[:space:]@]+:[^/[:space:]@]+@ ]] ||
  fail "--runtime-source-reference must not contain embedded credentials."

if [[ "$integration_path" == "registry-sync" ]]; then
  case "$registry_sync_platform" in
    "Amazon Bedrock"|"Anthropic Claude Managed Agents"|"Databricks Genie"|"Google Vertex AI"|"Oracle Generative AI Agents"|"Salesforce Agentforce") ;;
    "") fail "--registry-sync-platform is required when --integration-path is registry-sync." ;;
    *) fail "--registry-sync-platform is not currently supported by this module." ;;
  esac
elif [[ -n "$registry_sync_platform" ]]; then
  fail "--registry-sync-platform is valid only when --integration-path is registry-sync."
fi

echo "PASS: the selected Agent 365 onboarding path and runtime-owned source reference are ready for the live platform check."
