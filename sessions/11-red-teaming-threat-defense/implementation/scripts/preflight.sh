#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: preflight.sh --approved-subscription-id GUID --expected-region REGION \
  --authorization-reference REFERENCE --support-confirmed-on YYYY-MM-DD \
  --soc-route-reference REFERENCE [--phase prepare-taxonomy|baseline|post-remediation] \
  [--taxonomy-id ID] [--post-remediation-version VERSION]
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

approved_subscription_id=""
expected_region=""
authorization_reference=""
support_confirmed_on=""
soc_route_reference=""
phase="prepare-taxonomy"
taxonomy_id=""
post_remediation_version=""
while (($# > 0)); do
  case "$1" in
    --approved-subscription-id) approved_subscription_id=${2:?}; shift 2 ;;
    --expected-region) expected_region=${2:?}; shift 2 ;;
    --authorization-reference) authorization_reference=${2:?}; shift 2 ;;
    --support-confirmed-on) support_confirmed_on=${2:?}; shift 2 ;;
    --soc-route-reference) soc_route_reference=${2:?}; shift 2 ;;
    --phase) phase=${2:?}; shift 2 ;;
    --taxonomy-id) taxonomy_id=${2:?}; shift 2 ;;
    --post-remediation-version) post_remediation_version=${2:?}; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; fail "Unknown option: $1" ;;
  esac
done

[[ "$approved_subscription_id" =~ ^[0-9a-fA-F-]{36}$ ]] || fail '--approved-subscription-id must be a GUID.'
[[ -n "$expected_region" && -n "$authorization_reference" && -n "$soc_route_reference" ]] || fail 'Expected region, authorization reference, and SOC route reference are required.'
[[ "$support_confirmed_on" == "$(date +%F)" ]] || fail 'Confirm current Microsoft cloud red-teaming support on the day of the run.'
case "$phase" in
  prepare-taxonomy|baseline|post-remediation) ;;
  *) fail 'Phase must be prepare-taxonomy, baseline, or post-remediation.' ;;
esac
if [[ "$phase" != "prepare-taxonomy" && -z "$taxonomy_id" ]]; then
  fail '--taxonomy-id is required for a red-team run.'
fi
if [[ "$phase" == "post-remediation" && -z "$post_remediation_version" ]]; then
  fail '--post-remediation-version is required for the post-remediation run.'
fi

command -v az >/dev/null 2>&1 || fail 'az is required.'
command -v python >/dev/null 2>&1 || fail 'python is required.'
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
for path in "$artifact_root/red-team/attack-plan.json" "$artifact_root/defender/ai-alert-hunt.kql" "$artifact_root/operations/soc-triage-playbook.md" "$script_dir/run-red-team.py" "$script_dir/compare-runs.py" "$script_dir/requirements.txt"; do
  [[ -f "$path" ]] || fail "Required implementation file is missing: $path"
done
required_sentinels=(
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_SECURITY_OWNER_ROLE__"
  "__REQUIRED_TAXONOMY_NAME__"
)
if grep -R -q -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root"; then
  fail 'Resolve every __REQUIRED_*__ sentinel before a red-team run.'
fi

python - "$artifact_root/red-team/attack-plan.json" <<'PY'
import json
import sys

plan = json.load(open(sys.argv[1], encoding="utf-8"))
if (
    plan.get("implementationSession") != "11-red-teaming-threat-defense"
    or plan.get("target", {}).get("type") != "azure_ai_agent"
    or not plan.get("target", {}).get("name")
    or not plan.get("resultHandling", {}).get("retainAggregateOnly")
    or plan.get("resultHandling", {}).get("retainAttackPromptsInRepository")
    or plan.get("resultHandling", {}).get("retainAgentResponsesInRepository")
    or plan.get("resultHandling", {}).get("retainToolPayloadsInRepository")
    or not plan.get("resultHandling", {}).get("humanReviewRequired")
):
    raise SystemExit("The attack plan must retain its bounded target and payload-free result boundary.")
if not {"Jailbreak", "Flip", "Base64", "IndirectJailbreak"}.issubset(plan.get("attackStrategies", [])):
    raise SystemExit("The attack plan is missing a required attack strategy.")
evaluators = {item.get("evaluatorName") for item in plan.get("testingCriteria", [])}
if not {"builtin.prohibited_actions", "builtin.task_adherence", "builtin.sensitive_data_leakage"}.issubset(evaluators):
    raise SystemExit("The attack plan is missing a required evaluator.")
PY

: "${FOUNDRY_RESOURCE_ID:?Set FOUNDRY_RESOURCE_ID.}"
: "${FOUNDRY_PROJECT_ENDPOINT:?Set FOUNDRY_PROJECT_ENDPOINT.}"
: "${FOUNDRY_MODEL_NAME:?Set FOUNDRY_MODEL_NAME.}"
: "${FOUNDRY_BASELINE_AGENT_VERSION:?Set FOUNDRY_BASELINE_AGENT_VERSION.}"
[[ "$FOUNDRY_RESOURCE_ID" == "/subscriptions/$approved_subscription_id/"* ]] || fail 'FOUNDRY_RESOURCE_ID must identify the approved subscription.'
[[ "$FOUNDRY_PROJECT_ENDPOINT" =~ ^https://[^/]+\.services\.ai\.azure\.com/api/projects/[^/]+$ ]] || fail 'FOUNDRY_PROJECT_ENDPOINT must be an approved project endpoint.'
python -c 'import azure.ai.projects, azure.identity, openai' >/dev/null
[[ "$(az account show --query id --output tsv --only-show-errors)" == "$approved_subscription_id" ]] || fail 'Azure CLI is not using the approved subscription.'
actual_region=$(az resource show --ids "$FOUNDRY_RESOURCE_ID" --query location --output tsv --only-show-errors | tr -d ' ')
[[ "${actual_region,,}" == "${expected_region// /}" ]] || fail 'FOUNDRY_RESOURCE_ID is not in --expected-region.'

runner_args=( "$script_dir/run-red-team.py" --config "$artifact_root/red-team/attack-plan.json" --phase "$([[ "$phase" == "post-remediation" ]] && echo post-remediation || echo baseline)" --check-only )
if [[ "$phase" == "post-remediation" ]]; then
  runner_args+=( --post-remediation-version "$post_remediation_version" )
fi
python "${runner_args[@]}"

printf '%s\n' \
  'Red-team safe preview (read-only):' \
  "  Authorization: $authorization_reference" \
  "  Support confirmed: $support_confirmed_on" \
  "  Expected region: $expected_region" \
  "  SOC route: $soc_route_reference" \
  'No taxonomy or run was created. Foundry, Defender, and the SOC system remain authoritative for current state.'
