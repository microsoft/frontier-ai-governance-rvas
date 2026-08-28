#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-subscription-id <guid> [--phase prepare-taxonomy|baseline|post-remediation]

Runs the Session 11 Bash preflight. The script validates required files, tools, sentinels, target
scope, implementation file consistency, dependency imports, and the exact red-team target before it
prints the safe read-only preview summary.

Required options:
  --approved-subscription-id <guid>                 Approved Azure subscription ID.

Optional options:
  --phase <prepare-taxonomy|baseline|post-remediation>
                                                  Preflight phase. Default: prepare-taxonomy.
  --help                                          Show this help text.

Do not pass tokens, keys, endpoints, prompt evidence, or other secrets as arguments. Use the
approved runtime environment variables and secretless identity path instead.
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
    prepare-taxonomy) printf '%s\n' 'PrepareTaxonomy' ;;
    baseline) printf '%s\n' 'Baseline' ;;
    post-remediation) printf '%s\n' 'PostRemediation' ;;
    *) fail "Unsupported phase: $raw" ;;
  esac
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"

phase='PrepareTaxonomy'
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
  "$artifact_root/red-team/authorization-scope.json" \
  "$artifact_root/red-team/attack-plan.json" \
  "$artifact_root/red-team/taxonomy-review-checklist.md" \
  "$artifact_root/red-team/safe-seed-examples.json" \
  "$artifact_root/governance/release-gate-mapping.md" \
  "$artifact_root/governance/risk-change-handoff.json" \
  "$artifact_root/reports/red-team-scorecard-template.json" \
  "$artifact_root/reports/evidence-retention-record.md" \
  "$artifact_root/defender/ai-alert-hunt.kql" \
  "$artifact_root/operations/soc-triage-playbook.md" \
  "$script_dir/run-red-team.py" \
  "$script_dir/compare-runs.py" \
  "$script_dir/requirements.txt"; do
  require_file "$path"
done

for command_name in az python; do
  require_command "$command_name"
done

covered_decision_sentinels=(
  "__REQUIRED_AGENT_NAME__"
  "__REQUIRED_AGENT_OWNER_ROLE__"
  "__REQUIRED_AGENT_VERSION__"
  "__REQUIRED_AUTHORIZATION_DATE__"
  "__REQUIRED_AUTHORIZATION_EXPIRY__"
  "__REQUIRED_AUTHORIZATION_ID__"
  "__REQUIRED_CHANGE_REFERENCE__"
  "__REQUIRED_CONNECTED_OR_NOT_APPLICABLE__"
  "__REQUIRED_COST_OWNER_ROLE__"
  "__REQUIRED_CURRENT_SUPPORT_STATUS_SUPPORTED__"
  "__REQUIRED_DEFENDER_CONFIRMATION_DATE__"
  "__REQUIRED_DEFENDER_FOR_CLOUD_OR_AGENT365__"
  "__REQUIRED_DEFENDER_INCIDENT_SENTINEL_INCIDENT_OR_ITSM__"
  "__REQUIRED_DEFENDER_OWNER_ROLE__"
  "__REQUIRED_ENABLED_OR_DISABLED__"
  "__REQUIRED_ENABLED__"
  "__REQUIRED_FOUNDRY_PROJECT_ALIAS__"
  "__REQUIRED_JUDGE_MODEL_DEPLOYMENT_ALIAS__"
  "__REQUIRED_POST_REMEDIATION_AGENT_VERSION__"
  "__REQUIRED_PROMPT_EVIDENCE_ACCESS_ROLE__"
  "__REQUIRED_RED_TEAM_REGION__"
  "__REQUIRED_REMEDIATION_COMMIT__"
  "__REQUIRED_RELEASE_OWNER_ROLE__"
  "__REQUIRED_RESIDUAL_RISK_AUTHORITY_ROLE__"
  "__REQUIRED_SECURITY_OWNER_ROLE__"
  "__REQUIRED_SOC_DESTINATION_ALIAS__"
  "__REQUIRED_SOC_OWNER_ROLE__"
  "__REQUIRED_STOP_CONTACT_ROLE__"
  "__REQUIRED_SUPPORT_CHECK_DATE__"
  "__REQUIRED_SUBSCRIPTION_ALIAS__"
  "__REQUIRED_TAXONOMY_NAME__"
  "__REQUIRED_TOOL_OWNER_ROLE__"
  "__REQUIRED_YES_OR_NO__"
)
declare -A covered=()
for sentinel in "${covered_decision_sentinels[@]}"; do
  covered["$sentinel"]=1
done

unresolved_locations=()
unknown_sentinels=()
while IFS=: read -r match_path match_line match_value; do
  if [[ -n "$match_path" ]]; then
    if [[ -z "${covered[$match_value]+x}" ]]; then
      unknown_sentinels+=("$match_value")
    fi
    relative_path="${match_path#"$repo_root"/}"
    unresolved_locations+=("$match_value at $relative_path:$match_line")
  fi
done < <(grep -RnoE --binary-files=without-match '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" || true)

if (( ${#unknown_sentinels[@]} > 0 )); then
  printf 'Preflight has no named coverage for:\n%s\n' "$(printf '%s\n' "${unknown_sentinels[@]}" | sort -u)" >&2
  exit 1
fi

if (( ${#unresolved_locations[@]} > 0 )); then
  printf 'Resolve every Session 11 decision required for %s before continuing:\n%s\n' "$phase" "$(printf '%s\n' "${unresolved_locations[@]}")" >&2
  exit 1
fi

python - "$artifact_root" "$script_dir" "$approved_subscription_id" "$phase" <<'PY'
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
implementation_session = '11-red-teaming-threat-defense'

authorization = json.loads((artifact_root / 'red-team' / 'authorization-scope.json').read_text())
attack_plan = json.loads((artifact_root / 'red-team' / 'attack-plan.json').read_text())
safe_seeds = json.loads((artifact_root / 'red-team' / 'safe-seed-examples.json').read_text())
handoff = json.loads((artifact_root / 'governance' / 'risk-change-handoff.json').read_text())
runner_path = script_dir / 'run-red-team.py'

for record in (authorization, attack_plan, safe_seeds, handoff):
    if record.get('implementationSession') != implementation_session:
        raise SystemExit('A implementation file has the wrong implementationSession marker.')
seed_boundary = safe_seeds.get('targetBoundary', {})
customer_seed_boundary = safe_seeds.get('customerSeedBoundary', {})
if not seed_boundary.get('syntheticDataOnly') or seed_boundary.get('writeCapableToolsAllowed'):
    raise SystemExit('Safe seed examples must stay synthetic and read-only.')
if customer_seed_boundary.get('storeCustomerSeedsInRepository') or not customer_seed_boundary.get('retainAggregateOnly'):
    raise SystemExit('Customer seed examples must stay outside the repository; retain aggregate records only.')
for seed in safe_seeds.get('seedExamples', []):
    if seed.get('containsAttackPrompt') or any(token in str(seed.get(field, '')) for field in ('objectiveSummary', 'expectedSafeBehavior') for token in ('ignore previous instructions', 'bypass', 'exfiltrate', 'secret key')):
        raise SystemExit('Safe seed examples must not become reusable adversarial prompt text.')
agent_name = authorization['target']['agentName']
baseline_version = authorization['target']['agentVersion']
post_version = handoff['target']['postRemediationVersion']
if agent_name != attack_plan['target']['name'] or agent_name != handoff['target']['agentName']:
    raise SystemExit('The agent name is inconsistent across implementation files.')
if baseline_version != attack_plan['target']['version'] or baseline_version != handoff['target']['baselineVersion']:
    raise SystemExit('The baseline agent version is inconsistent across implementation files.')
if baseline_version == post_version:
    raise SystemExit('The post-remediation agent version must be a new immutable version.')
auth_safety = authorization['safety']
if not auth_safety['customerAuthorized'] or not auth_safety['agentOwnerPresent'] or not auth_safety['securityOwnerPresent'] or not auth_safety['socOwnerOnCall']:
    raise SystemExit('Required red-team owners are not present.')
if not auth_safety['previewApiAccepted'] or not auth_safety['projectManagedIdentityFoundryUserConfirmed'] or not auth_safety['redTeamBudgetApproved']:
    raise SystemExit('Preview API, project identity, and budget decisions must be confirmed.')
if auth_safety['stableEndpointChangeAllowed'] or auth_safety['writeCapableToolsAllowed']:
    raise SystemExit('Red-team authorization or endpoint boundary is incomplete.')
data_handling = authorization['dataHandling']
if not data_handling['syntheticInputsOnly'] or data_handling['productionDataAllowed'] or not data_handling['rawAttackPayloadsRemainInFoundry'] or not data_handling['repositoryContainsAggregateMetricsOnly']:
    raise SystemExit('The authorization data-handling boundary is not safe.')
authorized_on = datetime.strptime(authorization['approvedOn'], '%Y-%m-%d').date()
expires_on = datetime.strptime(authorization['expiresOn'], '%Y-%m-%d').date()
if expires_on < authorized_on or expires_on < date.today():
    raise SystemExit('The red-team authorization is expired or has an invalid date range.')
support = authorization['currentSupportGate']
if not support['manualGateRequired'] or support['stableDiscoveryApiAvailable'] or support['status'] != 'supported':
    raise SystemExit('The manual current-support gate must record supported; no stable discovery API is assumed.')
if datetime.strptime(support['checkedOn'], '%Y-%m-%d').date() != date.today():
    raise SystemExit('Check current Microsoft cloud red-teaming support documentation on the day of the run.')
region = authorization['target']['region'].lower().replace(' ', '')
if attack_plan['sdk']['apiVersion'] != '2025-11-15-preview':
    raise SystemExit('The attack plan must pin the approved preview API version.')
required_criteria = {'builtin.prohibited_actions', 'builtin.task_adherence', 'builtin.sensitive_data_leakage'}
criteria = {entry['evaluatorName'] for entry in attack_plan['testingCriteria']}
if not required_criteria.issubset(criteria):
    raise SystemExit('A required agentic evaluator is missing.')
required_strategies = {'Jailbreak', 'Flip', 'Base64', 'IndirectJailbreak'}
if not required_strategies.issubset(set(attack_plan['attackStrategies'])):
    raise SystemExit('A required attack strategy is missing.')
if phase != 'PrepareTaxonomy':
    taxonomy = attack_plan['taxonomy']
    if not taxonomy['customerReviewed'] or not taxonomy['approvedTaxonomyId']:
        raise SystemExit('Review the generated taxonomy and save its approved taxonomy ID in the attack plan before a red-team run.')
defender = handoff['defender']
if defender['aiServicesThreatProtection']['planState'] != 'enabled':
    raise SystemExit('Defender for Cloud AI services threat protection must be enabled.')
if defender['aiServicesThreatProtection']['suspiciousPromptEvidence'] not in {'enabled', 'disabled'}:
    raise SystemExit('The prompt-evidence decision must be enabled or disabled.')
if data_handling['promptEvidenceSetting'] != defender['aiServicesThreatProtection']['suspiciousPromptEvidence']:
    raise SystemExit('The prompt-evidence decision must agree across authorization and handoff.')
if defender['aiServicesThreatProtection']['suspiciousPromptEvidence'] == 'enabled' and not defender['aiServicesThreatProtection']['promptEvidenceDataHandlingApproved']:
    raise SystemExit('Enabled prompt evidence requires explicit data-handling approval.')
agent365 = defender['agent365']
if agent365['applicable'] not in {'yes', 'no'} or agent365['usedAsSoleOperationalControl']:
    raise SystemExit('The Agent 365 applicability or sole-control decision is invalid.')
if defender['selectedSignalPath'] == 'agent365-defender-preview' and (agent365['applicable'] != 'yes' or not agent365['onboarded'] or agent365['microsoft365Connector'] != 'connected'):
    raise SystemExit('The Agent 365 preview path requires onboarding and a connected Microsoft 365 connector.')
if defender['selectedSignalPath'] not in {'defender-for-cloud-ai-services', 'agent365-defender-preview'}:
    raise SystemExit('Select a supported Defender signal path.')
soc_delivery = handoff['socDelivery']
if soc_delivery['source'] != defender['selectedSignalPath'] or soc_delivery['routeType'] not in {'defender-incident', 'sentinel-incident', 'itsm-connector'}:
    raise SystemExit('The SOC route must use the selected Defender source and an approved route type.')
remediation = handoff['remediation']
if remediation['status'] != 'applied-to-new-version':
    raise SystemExit('Pre-work must apply the owned remediation to a new immutable version before this session.')
if any(change.get('status') != 'applied' for change in remediation.get('changes', [])):
    raise SystemExit('Every approved remediation change must be applied before this session.')
if phase == 'PostRemediation':
    baseline_record = artifact_root / 'reports' / 'baseline-aggregate.json'
    if not baseline_record.is_file():
        raise SystemExit('The payload-free baseline aggregate is required before the post-remediation run.')
subprocess.check_call([sys.executable, '-c', 'import azure.ai.projects, azure.identity, openai'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
account = json.loads(subprocess.check_output(['az', 'account', 'show', '--output', 'json']))
if account.get('id') != approved_subscription_id:
    raise SystemExit('Azure CLI is not using authorization-scope.json targetSubscriptionAlias.')
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
    raise SystemExit('FOUNDRY_RESOURCE_ID must resolve to the approved AIServices resource in the approved region.')
phase_argument = 'post-remediation' if phase == 'PostRemediation' else 'baseline'
subprocess.check_call([sys.executable, str(runner_path), '--config', str(artifact_root / 'red-team' / 'attack-plan.json'), '--phase', phase_argument, '--check-only'])
version = post_version if phase == 'PostRemediation' else baseline_version
print('Red-team safe preview (read-only):')
print(f"  Subscription alias: {authorization['target']['subscriptionAlias']}")
print(f"  Foundry project alias: {authorization['target']['foundryProjectAlias']}")
print(f"  Region: {authorization['target']['region']}")
print(f"  Agent/version: {agent_name} / {version}")
print(f"  Strategies: {', '.join(attack_plan['attackStrategies'])}")
print(f"  Evaluators: {', '.join(sorted(criteria))}")
print(f"  Defender route: {handoff['defender']['selectedSignalPath']} -> {handoff['socDelivery']['routeType']} -> {handoff['socDelivery']['destinationAlias']}")
print('  Repository output: aggregate metrics and alert/incident references only')
print('Read-only deployment preview is unsupported by the red-team API. No taxonomy or run was created.')
print(f'PASS: Session 11 authorization, current manual support gate, risk/change handoff, Foundry target, and {phase} phase are ready.')
PY
