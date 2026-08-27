#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  preflight.sh --target-scope SCOPE [--preview-command COMMAND [ARG...]]

Checks the implementation artifacts and approved target scope. When the deployment
inputs require a preview, pass the read-only preview command and its arguments
after --preview-command.
EOF
}

target_scope=""
preview_command=()

while (($# > 0)); do
  case "$1" in
    --target-scope)
      [[ $# -ge 2 ]] || { echo "ERROR: --target-scope requires a value." >&2; exit 2; }
      target_scope=$2
      shift 2
      ;;
    --preview-command)
      shift
      (($# > 0)) || { echo "ERROR: --preview-command requires a command." >&2; exit 2; }
      preview_command=("$@")
      break
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

[[ -n "$target_scope" ]] || { echo "ERROR: --target-scope is required." >&2; exit 2; }

for command in az jq; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "ERROR: $command is required." >&2
    exit 1
  }
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
deployment_inputs_path="$artifact_root/deployment-inputs.json"
required_sentinels=(
  "__REQUIRED_DEPLOYMENT_NAME__"
  "__REQUIRED_OWNER__"
  "__REQUIRED_PREVIEW_CAPABILITY__"
  "__REQUIRED_TARGET_SCOPE__"
)

[[ -d "$artifact_root" ]] || {
  echo "ERROR: Required implementation artifacts folder is missing: $artifact_root" >&2
  exit 1
}
[[ -f "$deployment_inputs_path" ]] || {
  echo "ERROR: Required deployment inputs are missing: $deployment_inputs_path" >&2
  exit 1
}

mapfile -t unresolved_sentinels < <(
  grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true
)
if ((${#unresolved_sentinels[@]} > 0)); then
  for sentinel in "${unresolved_sentinels[@]}"; do
    if [[ ! " ${required_sentinels[*]} " =~ [[:space:]]${sentinel}[[:space:]] ]]; then
      echo "ERROR: Add an explicit preflight check for new sentinel: $sentinel" >&2
    fi
  done
  echo "ERROR: Resolve every required customer decision in implementation/artifacts before deployment." >&2
  exit 1
fi

deployment_name=$(jq -er '.deploymentName | strings | select(length > 0)' "$deployment_inputs_path")
owner=$(jq -er '.owner | strings | select(length > 0)' "$deployment_inputs_path")
approved_scope=$(jq -er '.targetScope | strings | select(length > 0)' "$deployment_inputs_path")
[[ "$approved_scope" == "$target_scope" ]] || {
  echo "ERROR: Target scope does not match the approved scope in deployment-inputs.json." >&2
  exit 1
}

preview_supported=$(jq -er '.previewSupported | select(. == "Supported" or . == "NotSupported")' "$deployment_inputs_path")
if [[ "$preview_supported" == "Supported" ]]; then
  ((${#preview_command[@]} > 0)) || {
    echo "ERROR: A read-only preview command is required for this target platform." >&2
    exit 1
  }
  "${preview_command[@]}"
else
  echo "No read-only deployment preview is supported for this target platform."
fi

echo "PASS: prerequisites, files, decisions, target scope, and preview gate are ready."
