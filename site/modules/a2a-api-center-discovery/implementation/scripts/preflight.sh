#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh \
    --target-scope one-approved-a2a-discovery-asset \
    --source-integration git|api-management \
    --runtime-source-reference URL
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

target_scope=""
source_integration=""
runtime_source_reference=""
while (($# > 0)); do
  case "$1" in
    --target-scope)
      [[ $# -ge 2 ]] || fail "--target-scope requires a value."
      target_scope=$2
      shift 2
      ;;
    --source-integration)
      [[ $# -ge 2 ]] || fail "--source-integration requires a value."
      source_integration=$2
      shift 2
      ;;
    --runtime-source-reference)
      [[ $# -ge 2 ]] || fail "--runtime-source-reference requires a value."
      runtime_source_reference=$2
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
[[ "$target_scope" == "one-approved-a2a-discovery-asset" ]] ||
  fail "--target-scope must be one-approved-a2a-discovery-asset."
[[ "$source_integration" == "git" || "$source_integration" == "api-management" ]] ||
  fail "--source-integration must be git or api-management."
[[ -n "$runtime_source_reference" ]] ||
  fail "--runtime-source-reference is required."
[[ ! "$runtime_source_reference" =~ __REQUIRED_[A-Z0-9_]+__ ]] ||
  fail "Resolve every __REQUIRED_ source reference before discovery setup."
[[ "$runtime_source_reference" =~ ^https?:// ]] ||
  fail "--runtime-source-reference must be an absolute HTTP or HTTPS URI."
[[ ! "$runtime_source_reference" =~ https?://[^/:[:space:]@]+:[^/[:space:]@]+@ ]] ||
  fail "--runtime-source-reference must not contain embedded credentials."

echo "PASS: the selected API Center source integration and runtime-owned source reference are ready for the live platform check."
