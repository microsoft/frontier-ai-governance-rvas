#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  check-compliance.sh --target-scope SCOPE [--assignment-name NAME] [--decision-file PATH]
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

target_scope=""
assignment_name="rvas-ai-services-guardrails"
decision_file=""
while (($# > 0)); do
  case "$1" in
    --target-scope)
      (($# >= 2)) || fail "--target-scope requires a value."
      target_scope="$2"
      shift 2
      ;;
    --assignment-name)
      (($# >= 2)) || fail "--assignment-name requires a value."
      assignment_name="$2"
      shift 2
      ;;
    --decision-file)
      (($# >= 2)) || fail "--decision-file requires a value."
      decision_file="$2"
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

[[ -n "$target_scope" ]] || fail "--target-scope is required."
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
[[ -n "$decision_file" ]] || decision_file="$script_dir/../artifacts/policy/guardrail-decisions.json"
[[ -f "$decision_file" ]] || fail "Decision file is missing: $decision_file"
command -v jq >/dev/null 2>&1 || fail "jq is required."
command -v az >/dev/null 2>&1 || fail "az is required."

if grep -q -E '__REQUIRED_[A-Z0-9_]+__' "$decision_file"; then
  fail "Resolve every guardrail decision before checking live compliance."
fi
[[ "$(jq -r '.implementationSession' "$decision_file")" == "optional-module-ai-services-guardrail-policy" ]] ||
  fail "Decision file has the wrong implementationSession marker."
[[ "$(jq -r '.targetScopeResourceId' "$decision_file")" == "$target_scope" ]] ||
  fail "Target scope must match guardrail-decisions.json targetScopeResourceId."

scope_args=()
if [[ "$target_scope" =~ ^/subscriptions/([^/]+)$ ]]; then
  scope_args=(--subscription "${BASH_REMATCH[1]}")
elif [[ "$target_scope" =~ ^/subscriptions/([^/]+)/resourceGroups/([^/]+)$ ]]; then
  scope_args=(--subscription "${BASH_REMATCH[1]}" --resource-group "${BASH_REMATCH[2]}")
elif [[ "$target_scope" =~ ^/providers/Microsoft\.Management/managementGroups/([^/]+)$ ]]; then
  scope_args=(--management-group "${BASH_REMATCH[1]}")
else
  fail "Target scope must be a subscription, resource group, or management-group resource ID."
fi

if ! assignment_id="$(az policy assignment show \
  --name "$assignment_name" \
  --scope "$target_scope" \
  --query id \
  --output tsv \
  --only-show-errors)"; then
  fail "Policy assignment lookup failed for '$assignment_name' at '$target_scope'."
fi
[[ -n "$assignment_id" ]] || fail "Policy assignment lookup returned no ID."

if ! states="$(az policy state list \
  "${scope_args[@]}" \
  --policy-assignment "$assignment_name" \
  --query '[].{reference:policyDefinitionReferenceId,state:complianceState}' \
  --output json \
  --only-show-errors)"; then
  fail "Policy state lookup failed for assignment '$assignment_name' ($assignment_id)."
fi

if [[ "$(jq 'length' <<<"$states")" == "0" ]]; then
  printf "No policy state records were returned for assignment '%s'. Trigger or wait for evaluation before promotion.\n" "$assignment_name"
  exit 0
fi

jq -r '
  group_by(.reference, .state)
  | map({reference: .[0].reference, state: .[0].state, count: length})
  | sort_by(.reference, .state)
  | (["Reference", "ComplianceState", "Count"] | @tsv),
    (.[] | [.reference, .state, (.count | tostring)] | @tsv)
' <<<"$states"
