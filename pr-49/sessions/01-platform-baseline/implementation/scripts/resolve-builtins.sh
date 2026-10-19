#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
temp_paths=()

cleanup() {
  local path
  for path in "${temp_paths[@]:-}"; do
    [[ -e "$path" ]] && rm -rf -- "$path"
  done
  [[ -d "$tmpdir" ]] && rm -rf -- "$tmpdir"
}
trap cleanup EXIT

usage() {
  cat <<'USAGE'
Usage: ./scripts/resolve-builtins.sh

Resolve the current Allowed locations and Require a tag on resources built-ins and print
sanitized implementation inputs as JSON.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

register_temp() { temp_paths+=("$1"); }
make_temp_file() {
  local prefix="$1"
  local path
  path="$(mktemp "$tmpdir/${prefix}.XXXXXX")"
  register_temp "$path"
  printf '%s\n' "$path"
}
run_capture() {
  local stdout_file stderr_file status
  stdout_file="$(make_temp_file stdout)"
  stderr_file="$(make_temp_file stderr)"
  if "$@" >"$stdout_file" 2>"$stderr_file"; then
    cat "$stdout_file"
    return 0
  fi
  status=$?
  [[ -s "$stderr_file" ]] && cat "$stderr_file" >&2
  return "$status"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "Unknown option: $1"
      ;;
  esac
done

command -v az >/dev/null 2>&1 || die 'Azure CLI is required and was not found on PATH.'
command -v python3 >/dev/null 2>&1 || die 'Python 3 is required and was not found on PATH.'

definitions_json="$(run_capture az policy definition list --only-show-errors --output json)" || die 'Failed to read built-in policy definitions.'

PYTHON_JSON_INPUT="$definitions_json" python3 - <<'PY'
import json
import os
import re
import sys

def get_built_in(definitions, display_name: str, required_parameter_name: str):
    matches = [
        definition for definition in definitions
        if definition.get('policyType') == 'BuiltIn' and definition.get('displayName') == display_name
    ]
    if len(matches) != 1:
        raise SystemExit(
            f"Expected one current built-in named '{display_name}'; found {len(matches)}. Confirm the display name before implementation."
        )
    definition = matches[0]
    metadata = definition.get('metadata') or {}
    deprecated = metadata.get('deprecated')
    if str(deprecated).lower() == 'true':
        raise SystemExit(
            f"Built-in '{display_name}' is deprecated. Select and inspect a replacement before implementation."
        )

    effect_expression = str((((definition.get('policyRule') or {}).get('then') or {}).get('effect')) or '')
    effective_effect = effect_expression
    effect_parameter_name = None
    parameters = definition.get('parameters') or {}
    if effect_expression.lower() != 'deny':
        match = re.fullmatch(r"\[parameters\((?:'([^']+)'|\"([^\"]+)\")\)\]", effect_expression)
        if not match:
            raise SystemExit(
                f"Built-in '{display_name}' now uses effect '{effect_expression}'; the deployed initiative expects Deny."
            )
        effect_parameter_name = match.group(1) or match.group(2)
        effect_parameter = parameters.get(effect_parameter_name)
        if not effect_parameter:
            raise SystemExit(
                f"Built-in '{display_name}' references missing effect parameter '{effect_parameter_name}'."
            )
        default_value = effect_parameter.get('defaultValue')
        if str(default_value).lower() != 'deny':
            raise SystemExit(
                f"Built-in '{display_name}' no longer defaults '{effect_parameter_name}' to Deny."
            )
        allowed_values = [str(value) for value in effect_parameter.get('allowedValues') or []]
        if allowed_values and 'Deny' not in allowed_values:
            raise SystemExit(
                f"Built-in '{display_name}' no longer permits Deny through '{effect_parameter_name}'."
            )
        effective_effect = str(default_value)

    parameter_names = list(parameters.keys())
    if required_parameter_name not in parameter_names:
        raise SystemExit(
            f"Built-in '{display_name}' no longer exposes required parameter '{required_parameter_name}'."
        )

    version = str(definition.get('version') or metadata.get('version') or '')
    return {
        'id': str(definition.get('id') or ''),
        'name': str(definition.get('name') or ''),
        'displayName': str(definition.get('displayName') or ''),
        'version': version,
        'effect': effective_effect,
        'effectExpression': effect_expression,
        'effectParameter': effect_parameter_name,
        'parameterNames': parameter_names,
    }

payload = json.loads(os.environ['PYTHON_JSON_INPUT'])
resolved = {
    'allowedLocations': get_built_in(payload, 'Allowed locations', 'listOfAllowedLocations'),
    'requireTag': get_built_in(payload, 'Require a tag on resources', 'tagName'),
}
print(json.dumps(resolved, indent=2))
PY
