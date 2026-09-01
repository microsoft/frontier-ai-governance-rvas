#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-subscription-id <guid> [--phase baseline|candidate]

Runs the Session 10 Bash preflight. The script validates required files, tools, sentinels, target
scope, implementation file consistency, dependency imports, and the exact evaluation target before it
prints the safe read-only preview summary.

Required options:
  --approved-subscription-id <guid>   Approved Azure subscription ID.

Optional options:
  --phase <baseline|candidate>        Preflight phase. Default: baseline.
  --help                              Show this help text.

Do not pass tokens, keys, endpoints, or other secrets as arguments. Use the approved runtime
environment variables and secretless identity path instead.
USAGE
}

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "Required command is unavailable: $command_name"
  fi
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Required implementation file is missing: $path"
}

require_directory() {
  local path="$1"
  [[ -d "$path" ]] || fail "Required implementation artifact tree is missing: $path"
}

map_phase() {
  local raw="$1"
  case "${raw,,}" in
    baseline) printf '%s\n' 'baseline' ;;
    candidate) printf '%s\n' 'candidate' ;;
    *) fail "Unsupported phase: $raw" ;;
  esac
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
temp_dir="$(mktemp -d)"
matches_file="$temp_dir/sentinel-matches.txt"
trap 'rm -rf "$temp_dir"' EXIT

phase='baseline'
approved_subscription_id=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase)
      [[ $# -ge 2 ]] || fail 'Missing value for --phase'
      phase="$(map_phase "$2")"
      shift 2
      ;;
    --approved-subscription-id)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-subscription-id'
      approved_subscription_id="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$approved_subscription_id" ]] || { usage >&2; fail 'The --approved-subscription-id option is required.'; }
[[ "$approved_subscription_id" =~ ^[0-9a-fA-F-]{36}$ ]] || fail 'Approved subscription ID must be a GUID.'

require_directory "$artifact_root"
for path in \
  "$artifact_root/release/release-policy.json" \
  "$artifact_root/eval/evaluation-spec.json" \
  "$artifact_root/eval/data/golden-v1.jsonl" \
  "$artifact_root/eval/thresholds.yaml" \
  "$script_dir/run-evaluation.py" \
  "$script_dir/release-gate.py" \
  "$script_dir/test_release_gate.py" \
  "$script_dir/requirements.txt"; do
  require_file "$path"
done

for command_name in az python; do
  require_command "$command_name"
done

covered_decision_sentinels=(
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_APPROVED_AGENT_VERSION__"
  "__REQUIRED_CANDIDATE_AGENT_VERSION__"
  "__REQUIRED_COST_OWNER_ROLE__"
  "__REQUIRED_CURRENT_SUPPORT_STATUS_SUPPORTED__"
  "__REQUIRED_EVALUATION_REGION__"
  "__REQUIRED_EXCEPTION_AUTHORITY_ROLE__"
  "__REQUIRED_FOUNDRY_PROJECT_ALIAS__"
  "__REQUIRED_GOLDEN_DATASET_SHA256__"
  "__REQUIRED_JUDGE_MODEL_DEPLOYMENT_ALIAS__"
  "__REQUIRED_NETWORK_MODE_PUBLIC_OR_ISOLATED__"
  "__REQUIRED_QUALITY_OWNER_ROLE__"
  "__REQUIRED_RELEASE_OWNER_ROLE__"
  "__REQUIRED_SAFETY_OWNER_ROLE__"
  "__REQUIRED_SUPPORT_CHECK_DATE__"
  "__REQUIRED_TOOL_EVALUATOR_COMPATIBILITY_STATUS__"
  "__REQUIRED_TOOL_OWNER_ROLE__"
)
declare -A covered=()
for sentinel in "${covered_decision_sentinels[@]}"; do
  covered["$sentinel"]=1
done

unresolved_locations=()
unknown_sentinels=()
if grep -RnoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" >"$matches_file"; then
  while IFS=: read -r match_path match_line match_value; do
    if [[ -z "${covered[$match_value]+x}" ]]; then
      unknown_sentinels+=("$match_value")
    fi
    relative_path="${match_path#"$repo_root"/}"
    unresolved_locations+=("$match_value at $relative_path:$match_line")
  done <"$matches_file"
fi

if (( ${#unknown_sentinels[@]} > 0 )); then
  printf 'Preflight has no named coverage for:\n%s\n' "$(printf '%s\n' "${unknown_sentinels[@]}" | sort -u)" >&2
  exit 1
fi

if (( ${#unresolved_locations[@]} > 0 )); then
  printf 'Resolve every named customer decision before running evaluation:\n%s\n' "$(printf '%s\n' "${unresolved_locations[@]}")" >&2
  exit 1
fi

python - "$artifact_root" "$script_dir" "$approved_subscription_id" "$phase" <<'PY'
import hashlib
import json
import os
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path

artifact_root = Path(sys.argv[1])
script_dir = Path(sys.argv[2])
approved_subscription_id = sys.argv[3]
phase = sys.argv[4]
implementation_session = '10-foundry-evaluations-quality-gates'

release_policy = json.loads((artifact_root / 'release' / 'release-policy.json').read_text())
spec = json.loads((artifact_root / 'eval' / 'evaluation-spec.json').read_text())
dataset_path = artifact_root / 'eval' / 'data' / 'golden-v1.jsonl'
thresholds_path = artifact_root / 'eval' / 'thresholds.yaml'
runner_path = script_dir / 'run-evaluation.py'
gate_path = script_dir / 'release-gate.py'

for record in (release_policy, spec):
    if record.get('implementationSession') != implementation_session:
        raise SystemExit('A implementation file has the wrong implementationSession marker.')
if release_policy['target']['agentName'] != spec['target']['agentName']:
    raise SystemExit('The release policy and evaluation specification must target the same agent.')
if release_policy['target']['approvedVersion'] != spec['target']['approvedVersion']:
    raise SystemExit('The approved agent version differs between the release policy and evaluation specification.')
if release_policy['target']['candidateVersion'] != spec['target']['candidateVersion']:
    raise SystemExit('The candidate agent version differs between the release policy and evaluation specification.')
if release_policy['target']['approvedVersion'] == release_policy['target']['candidateVersion']:
    raise SystemExit('The approved and candidate agent versions must be different immutable versions.')
activation = release_policy.get('activationContract', {})
expected_activation = {
    'requiredState': 'enabled',
    'requiredDecision': 'approved',
    'decisionDateRequired': True,
    'thresholdPolicyState': 'active',
    'thresholdPolicyPath': 'implementation/artifacts/eval/thresholds.yaml',
    'baselineRunIdMustMatchThresholdPolicyAndBaselineRecord': True,
    'candidateRunIdMustMatchCandidateRecord': True,
}
if release_policy.get('schemaVersion') != 2 or activation != expected_activation:
    raise SystemExit('The release policy activation contract has changed or is incomplete.')
interface = release_policy.get('gate', {}).get('callableInterface', {})
if interface.get('requiredEnforcementOption') != '--require-enabled':
    raise SystemExit('The callable gate must require the --require-enabled enforcement option.')
gate_state = release_policy['gate'].get('state')
if gate_state == 'enabled':
    if release_policy['gate'].get('decision') != 'approved':
        raise SystemExit('An enabled gate needs an approved decision.')
    decision_date = release_policy['gate'].get('decisionDate')
    if not decision_date:
        raise SystemExit('An enabled gate needs a decision date.')
    datetime.strptime(decision_date, '%Y-%m-%d')
    if not release_policy['gate'].get('baselineRunId') or not release_policy['gate'].get('candidateRunId'):
        raise SystemExit('An enabled gate needs baseline and candidate run IDs.')
if release_policy['target']['networkMode'] not in {'public', 'isolated'}:
    raise SystemExit('networkMode must be public or isolated.')
support = release_policy['currentSupportGate']
if not support['manualGateRequired'] or support['stableDiscoveryApiAvailable'] or support['status'] != 'supported':
    raise SystemExit('The manual current-support gate must record supported; no stable discovery API is assumed.')
protected_material_decision = support.get('protectedMaterialDecision', {})
if (
    protected_material_decision.get('blocking') is not True
    or protected_material_decision.get('requiredRegion') != 'East US 2'
    or protected_material_decision.get('ifUnavailable') != 'stop-and-relocate-or-revise-policy'
):
    raise SystemExit('The protected-material decision must keep the blocking metric in East US 2 or stop for an explicit policy revision.')
if datetime.strptime(support['checkedOn'], '%Y-%m-%d').date() != date.today():
    raise SystemExit('Check current Microsoft evaluation support documentation on the day of the run.')
if not all(support['confirmedCapabilities'].values()):
    raise SystemExit('The current support check must confirm every selected evaluation capability.')
capability = release_policy['capability']
if not capability['projectManagedIdentityFoundryUserConfirmed'] or not capability['evaluationBudgetApproved']:
    raise SystemExit('Project identity access and the evaluation budget must be confirmed.')
if release_policy['target']['networkMode'] == 'isolated' and not capability['subnetDelegationConfirmed']:
    raise SystemExit('The release policy must confirm subnet delegation for isolated evaluation.')
if capability['previewEvaluators']['allowedAsSoleBlockingControl']:
    raise SystemExit('Preview evaluators cannot be the sole blocking control.')
tool_compatibility = capability.get('toolEvaluatorCompatibility', {})
if (
    tool_compatibility.get('status') != 'approved'
    or tool_compatibility.get('limitedSupportToolPresent')
    or tool_compatibility.get('evaluatedToolTypes') != ['Function Tool']
):
    raise SystemExit('The tool owner must approve tool-call evaluators for the supported Function Tool path.')
region = release_policy['target']['evaluationRegion'].lower().replace(' ', '')
if region != 'eastus2':
    raise SystemExit('The blocking protected_material evaluator requires East US 2. Relocate or revise the policy before running.')
rows = [line for line in dataset_path.read_text().splitlines() if line.strip()]
if len(rows) < int(spec['dataset']['minimumCases']) or len(rows) > int(spec['dataset']['maximumCases']):
    raise SystemExit('The golden dataset row count is outside the approved bounds.')
required_categories = set(spec['dataset']['requiredCategories'])
seen_categories = set()
seen_case_ids = set()
for line in rows:
    if len(line.encode('utf-8')) > int(spec['dataset']['maximumBytesPerRow']):
        raise SystemExit('A golden dataset row exceeds the current service limit.')
    row = json.loads(line)
    if not row.get('query') or not row.get('expected_behavior'):
        raise SystemExit('Every golden case needs a query and expected_behavior.')
    case_id = row.get('case_id')
    if case_id in seen_case_ids:
        raise SystemExit('Golden dataset case_id values must be unique.')
    seen_case_ids.add(case_id)
    seen_categories.add(row.get('category'))
missing_categories = required_categories - seen_categories
if missing_categories:
    raise SystemExit(f'Golden dataset category is missing: {sorted(missing_categories)[0]}')

evaluator_names = set()
for evaluator in spec['evaluators']:
    name = evaluator['name']
    if name in evaluator_names:
        raise SystemExit('Evaluator names must be unique.')
    evaluator_names.add(name)
    if evaluator.get('preview') and evaluator.get('blockingEligible'):
        raise SystemExit(f'Preview evaluator {name} cannot be blocking-eligible.')
    if evaluator.get('layer') not in {'final-answer-quality', 'tool-process', 'safety'}:
        raise SystemExit(f'Evaluator {name} has an unknown metric layer.')
evaluators_by_name = {evaluator['name']: evaluator for evaluator in spec['evaluators']}
for preview_safety_name in ('prohibited_actions', 'sensitive_data_leakage'):
    preview_safety = evaluators_by_name.get(preview_safety_name)
    if (
        not preview_safety
        or preview_safety.get('layer') != 'safety'
        or not preview_safety.get('preview')
        or preview_safety.get('blockingEligible')
    ):
        raise SystemExit(f'{preview_safety_name} must remain a nonblocking preview safety evaluator.')
result_handling = spec['resultHandling']
if not result_handling.get('retainAggregateOnly') or result_handling.get('retainOutputItemsInRepository') or result_handling.get('retainEvaluatorReasonsInRepository'):
    raise SystemExit('Release records must remain aggregate and payload-free.')

subprocess.check_call([sys.executable, '-c', 'import azure.ai.projects, azure.identity, openai, yaml'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
account = json.loads(subprocess.check_output(['az', 'account', 'show', '--output', 'json']))
if account.get('id') != approved_subscription_id:
    raise SystemExit('Azure CLI is not using the approved subscription.')
foundry_resource_id = os.environ.get('FOUNDRY_RESOURCE_ID', '')
project_endpoint = os.environ.get('FOUNDRY_PROJECT_ENDPOINT', '')
judge_model = os.environ.get('FOUNDRY_MODEL_NAME', '')
if not foundry_resource_id.startswith(f'/subscriptions/{approved_subscription_id}/'):
    raise SystemExit('FOUNDRY_RESOURCE_ID must identify the approved Foundry resource in the approved subscription.')
if not project_endpoint.startswith('https://') or '/api/projects/' not in project_endpoint:
    raise SystemExit('FOUNDRY_PROJECT_ENDPOINT must be the approved HTTPS project endpoint.')
if not judge_model:
    raise SystemExit('FOUNDRY_MODEL_NAME must name the approved judge-model deployment.')
foundry = json.loads(subprocess.check_output(['az', 'resource', 'show', '--ids', foundry_resource_id, '--output', 'json']))
if foundry.get('kind') != 'AIServices' or foundry.get('location', '').lower().replace(' ', '') != region:
    raise SystemExit('FOUNDRY_RESOURCE_ID must resolve to the approved AIServices resource in the approved evaluation region.')
subprocess.check_call([sys.executable, str(gate_path), '--policy', str(thresholds_path), '--validate-policy', '--phase', phase])
subprocess.check_call([sys.executable, str(runner_path), '--spec', str(artifact_root / 'eval' / 'evaluation-spec.json'), '--check-only'])
dataset_hash = hashlib.sha256(dataset_path.read_bytes()).hexdigest()
target_version = release_policy['target']['approvedVersion'] if phase == 'baseline' else release_policy['target']['candidateVersion']
print('Evaluation preview (read-only):')
print(f"  Project alias: {release_policy['target']['foundryProjectAlias']}")
print(f"  Region: {release_policy['target']['evaluationRegion']}")
print(f"  Agent: {release_policy['target']['agentName']}")
print(f"  Phase/version: {phase} / {target_version}")
print(f"  Golden cases: {len(rows)}; SHA-256: {dataset_hash}")
print(f"  Evaluators: {', '.join(sorted(evaluator_names))}")
print('  Repository output: aggregate metrics only')
print('Read-only deployment preview is unsupported by the Evals API. The safe preview is the exact scope above; the stable endpoint remains pinned.')
print(f'PASS: Session 10 release policy, current manual support gate, Foundry target, dataset, dependencies, and {phase} gate are ready.')
PY
