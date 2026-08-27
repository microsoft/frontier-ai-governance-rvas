#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --approved-nonproduction-scope <resource-group-id> \
  --approved-production-scope <resource-group-id> --approved-release-sha <40-character-sha> \
  [--phase decisions|ready]

Runs the Session 14 Bash preflight. The script validates required files, tools, sentinels, the two
approved scopes, immutable release metadata, fixed file interfaces, static dependencies,
and the read-only Azure deployment previews for nonproduction and production.

Required options:
  --approved-nonproduction-scope <resource-group-id>  Exact approved nonproduction scope.
  --approved-production-scope <resource-group-id>     Exact approved production scope.
  --approved-release-sha <40-character-sha>           Approved release commit held outside that commit.

Optional options:
  --phase <decisions|ready>                           Preflight phase. Default: ready.
  --help                                              Show this help text.

Do not pass tokens, secrets, or client credentials as arguments. Use the approved GitHub
environment values and workload identities instead.
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
    decisions) printf '%s\n' 'decisions' ;;
    ready) printf '%s\n' 'ready' ;;
    *) fail "Unsupported phase: $raw" ;;
  esac
}

validate_scope() {
  local name="$1"
  local value="$2"
  [[ "$value" =~ ^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$ ]] || fail "$name must be an exact Azure resource-group resource ID."
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
temp_dir="$(mktemp -d)"
matches_file="$temp_dir/sentinel-matches.txt"
state_json="$temp_dir/state.json"
secret_scanning_alerts_json="$temp_dir/secret-scanning-alerts.json"
trap 'rm -rf "$temp_dir"' EXIT

phase='ready'
approved_nonproduction_scope=''
approved_production_scope=''
approved_release_sha=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --phase)
      [[ $# -ge 2 ]] || fail 'Missing value for --phase'
      phase="$(map_phase "$2")"
      shift 2
      ;;
    --approved-nonproduction-scope)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-nonproduction-scope'
      approved_nonproduction_scope="$2"
      shift 2
      ;;
    --approved-production-scope)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-production-scope'
      approved_production_scope="$2"
      shift 2
      ;;
    --approved-release-sha)
      [[ $# -ge 2 ]] || fail 'Missing value for --approved-release-sha'
      approved_release_sha="$2"
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

[[ -n "$approved_nonproduction_scope" ]] || { usage >&2; fail 'The --approved-nonproduction-scope option is required.'; }
[[ -n "$approved_production_scope" ]] || { usage >&2; fail 'The --approved-production-scope option is required.'; }
[[ "$approved_release_sha" =~ ^[0-9a-f]{40}$ ]] ||
  { usage >&2; fail 'The --approved-release-sha option must be a full 40-character commit SHA.'; }
validate_scope 'Approved nonproduction scope' "$approved_nonproduction_scope"
validate_scope 'Approved production scope' "$approved_production_scope"

require_directory "$artifact_root"
for path in \
  "$artifact_root/control-definition.json" \
  "$artifact_root/environments/nonproduction.parameters.json" \
  "$artifact_root/environments/production.parameters.json" \
  "$artifact_root/github/promotion.yml" \
  "$artifact_root/github/restore-previous-release.yml" \
  "$artifact_root/pipeline/release-manifest.template.json"; do
  require_file "$path"
done

for command_name in git gh az python; do
  require_command "$command_name"
done

covered_decision_sentinels=(
  "__REQUIRED_ACTIONS_CHECKOUT_FULL_SHA__"
  "__REQUIRED_ACTIONS_SETUP_PYTHON_FULL_SHA__"
  "__REQUIRED_ACTIONS_UPLOAD_ARTIFACT_FULL_SHA__"
  "__REQUIRED_ADMIN_BYPASS_DISABLED_TRUE__"
  "__REQUIRED_AGENT_NAME_OR_ID__"
  "__REQUIRED_AGENT_VERSION__"
  "__REQUIRED_APIM_POLICY_PATH__"
  "__REQUIRED_APIM_POLICY_VERSION__"
  "__REQUIRED_APPROVED_RELEASE_STORE__"
  "__REQUIRED_AZURE_LOGIN_FULL_SHA__"
  "__REQUIRED_AZURE_TENANT_ID__"
  "__REQUIRED_BICEP_ENTRYPOINT_PATH__"
  "__REQUIRED_CANDIDATE_ROUTING_SELECTOR__"
  "__REQUIRED_EVALUATION_RUN_ID__"
  "__REQUIRED_EVALUATION_THRESHOLD_POLICY_SHA256__"
  "__REQUIRED_EVALUATION_THRESHOLD_POLICY_VERSION__"
  "__REQUIRED_EXISTING_ROUTING_SUPPORT_CONFIRMED_TRUE_OR_FALSE__"
  "__REQUIRED_GITHUB_OWNER__"
  "__REQUIRED_GITHUB_REPOSITORY__"
  "__REQUIRED_MODEL_DEPLOYMENT_VERSION_ALIAS__"
  "__REQUIRED_NONPRODUCTION_AZURE_CLIENT_ID__"
  "__REQUIRED_NONPRODUCTION_EXACT_OIDC_SUBJECT__"
  "__REQUIRED_NONPRODUCTION_FEDERATED_CREDENTIAL_NAME__"
  "__REQUIRED_NONPRODUCTION_PREVIEW_EXACT_OIDC_SUBJECT__"
  "__REQUIRED_NONPRODUCTION_PREVIEW_FEDERATED_CREDENTIAL_NAME__"
  "__REQUIRED_NONPRODUCTION_PREVENT_SELF_REVIEW_TRUE__"
  "__REQUIRED_NONPRODUCTION_REVIEWER_TEAM_SLUG__"
  "__REQUIRED_NONPRODUCTION_RESOURCE_GROUP__"
  "__REQUIRED_NONPRODUCTION_SUBSCRIPTION_ID__"
  "__REQUIRED_PREVENT_SELF_REVIEW_TRUE__"
  "__REQUIRED_PREVIOUS_APPROVED_RELEASE_ID__"
  "__REQUIRED_PRODUCTION_AZURE_CLIENT_ID__"
  "__REQUIRED_PRODUCTION_BRANCH_OR_TAG_RESTRICTION__"
  "__REQUIRED_PRODUCTION_ENVIRONMENT_PLAN_SUPPORT_CONFIRMED_TRUE__"
  "__REQUIRED_PRODUCTION_EXACT_OIDC_SUBJECT__"
  "__REQUIRED_PRODUCTION_FEDERATED_CREDENTIAL_NAME__"
  "__REQUIRED_PRODUCTION_PREVIEW_EXACT_OIDC_SUBJECT__"
  "__REQUIRED_PRODUCTION_PREVIEW_FEDERATED_CREDENTIAL_NAME__"
  "__REQUIRED_PRODUCTION_RESOURCE_GROUP__"
  "__REQUIRED_PRODUCTION_REVIEWER_ROLE__"
  "__REQUIRED_PRODUCTION_REVIEWER_TEAM_SLUG__"
  "__REQUIRED_PRODUCTION_SUBSCRIPTION_ID__"
  "__REQUIRED_PROMPT_VERSION__"
  "__REQUIRED_PROTECTED_DEFAULT_BRANCH__"
  "__REQUIRED_RELEASE_STORE_SCRIPT_PATH__"
  "__REQUIRED_ROUTING_CONTROL_SCRIPT_PATH__"
  "__REQUIRED_ROUTING_STRATEGY_CANARY_OR_BLUE_GREEN__"
  "__REQUIRED_SESSION11_APPROVED_BASELINE_RECORD_PATH__"
  "__REQUIRED_SESSION11_CANDIDATE_RECORD_PATH__"
  "__REQUIRED_STABLE_ROUTING_SELECTOR__"
  "__REQUIRED_UNIT_TEST_SCRIPT_PATH__"
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
  printf 'Resolve every named customer decision before any state change:\n%s\n' "$(printf '%s\n' "${unresolved_locations[@]}")" >&2
  exit 1
fi

approved_branch="$(python - "$artifact_root/control-definition.json" <<'PY'
import json, sys
print(json.load(open(sys.argv[1]))['repository']['defaultBranch'])
PY
)"
expected_repository="$(python - "$artifact_root/control-definition.json" <<'PY'
import json, sys
control = json.load(open(sys.argv[1]))
print(f"{control['repository']['owner']}/{control['repository']['name']}")
PY
)"
approved_github_host="$(python - "$artifact_root/control-definition.json" <<'PY'
import json, sys
print(json.load(open(sys.argv[1]))['repository']['host'])
PY
)"
remote_url="$(git -C "$repo_root" config --get remote.origin.url)"
trusted_fetch_url="$(python - "$remote_url" "$approved_github_host" "$expected_repository" <<'PY'
import re
import sys
import urllib.parse

remote, approved_host, expected_repository = sys.argv[1:]
if approved_host != 'github.com' or not re.fullmatch(
    r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+',
    expected_repository,
):
    raise SystemExit('The approved GitHub host, owner, or repository name is invalid.')
owner, repository = expected_repository.split('/')
parsed = urllib.parse.urlsplit(remote)
if parsed.scheme.casefold() == 'https':
    try:
        parsed.port
    except ValueError as error:
        raise SystemExit('Repository origin has an invalid HTTPS port.') from error
    path = parsed.path.removeprefix('/')
    if (
        parsed.scheme != 'https'
        or (parsed.hostname or '').casefold() != approved_host.casefold()
        or parsed.netloc.casefold() != approved_host.casefold()
        or parsed.username is not None
        or parsed.password is not None
        or parsed.query
        or parsed.fragment
        or path.casefold() not in {
            expected_repository.casefold(),
            f'{expected_repository}.git'.casefold(),
        }
    ):
        raise SystemExit(
            'Repository origin must use the exact approved GitHub HTTPS host and path.'
        )
    print(f'https://{approved_host}/{owner}/{repository}.git')
else:
    match = re.fullmatch(
        rf'git@{re.escape(approved_host)}:([^/:\s]+)/([^/\s]+)',
        remote,
        re.IGNORECASE,
    )
    if not match:
        raise SystemExit(
            'Repository origin must use the documented GitHub HTTPS or SSH form.'
        )
    actual_owner, actual_repository = match.groups()
    if actual_repository.casefold().endswith('.git'):
        actual_repository = actual_repository[:-4]
    if (
        actual_owner.casefold() != owner.casefold()
        or actual_repository.casefold() != repository.casefold()
    ):
        raise SystemExit(
            'Repository origin must use the exact approved GitHub SSH host and path.'
        )
    print(f'git@{approved_host}:{owner}/{repository}.git')
PY
)" || fail "Current repository origin is not the approved GitHub repository."
git -C "$repo_root" check-ref-format "refs/heads/$approved_branch" ||
  fail 'The configured protected release branch is not a valid Git branch.'
fetch_arguments=(--no-tags --prune)
if [[ "$(git -C "$repo_root" rev-parse --is-shallow-repository)" == 'true' ]]; then
  fetch_arguments+=(--unshallow)
fi
git -C "$repo_root" fetch "${fetch_arguments[@]}" \
  "$trusted_fetch_url" "+refs/heads/$approved_branch:refs/remotes/trusted-release/$approved_branch" ||
  fail 'Could not fetch the full protected release-branch history.'
git -C "$repo_root" cat-file -e "$approved_release_sha^{commit}" ||
  fail 'Approved release SHA is not available after fetching the protected release branch.'
git -C "$repo_root" merge-base --is-ancestor \
  "$approved_release_sha" "refs/remotes/trusted-release/$approved_branch" ||
  fail 'Approved release SHA is not reachable from the protected release branch.'

python - "$artifact_root" "$repo_root" "$approved_nonproduction_scope" "$approved_production_scope" "$phase" "$state_json" <<'PY'
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

artifact_root = Path(sys.argv[1])
repo_root = Path(sys.argv[2]).resolve()
approved_nonproduction_scope = sys.argv[3]
approved_production_scope = sys.argv[4]
phase = sys.argv[5]
state_json = Path(sys.argv[6])

control = json.loads((artifact_root / 'control-definition.json').read_text())
nonprod_params = json.loads((artifact_root / 'environments' / 'nonproduction.parameters.json').read_text())
prod_params = json.loads((artifact_root / 'environments' / 'production.parameters.json').read_text())
promotion_workflow = (artifact_root / 'github' / 'promotion.yml').read_text()
restore_workflow = (artifact_root / 'github' / 'restore-previous-release.yml').read_text()

if control.get('implementationSession') != '14-cicd-promotion-controls':
    raise SystemExit('Session 14 implementation files have the wrong implementationSession marker.')
if control['targetScopes']['nonproduction'] != approved_nonproduction_scope or control['targetScopes']['production'] != approved_production_scope:
    raise SystemExit('Approved scopes do not match the operational control definition.')
if control['azure']['clientSecretAllowed'] is not False or 'OIDC' not in control['azure']['authentication']:
    raise SystemExit('Azure authentication must use OIDC workload identity federation without client secrets.')
if control['azure']['nonproductionRoleAssignment'] != 'Contributor' or control['azure']['productionRoleAssignment'] != 'Contributor':
    raise SystemExit('Both workload identities require the built-in Contributor role at their exact resource-group scopes.')
for key, name in (
    ('nonproductionPreview', 'nonproduction-preview'),
    ('nonproduction', 'nonproduction'),
    ('productionPreview', 'production-preview'),
    ('production', 'production'),
):
    if not control['githubEnvironments'][key]['oidcSubject'].endswith(f':environment:{name}'):
        raise SystemExit(f'The approved {name} OIDC subject must end with the exact GitHub environment name.')
if control['githubEnvironments']['nonproduction']['preventSelfReview'] is not True:
    raise SystemExit('Nonproduction apply approval must prevent self-review.')
production = control['githubEnvironments']['production']
if production['planSupportsRequiredProtection'] is not True or production['preventSelfReview'] is not True or production['adminBypassDisabled'] is not True:
    raise SystemExit('Production plan support, prevent-self-review, and disabled administrator bypass must be true.')
if control['records']['manifestFinalizationFailureBehavior'] != 'stop-and-require-manual-restore':
    raise SystemExit('Manifest finalization failure must stop for manual restore.')
if control['routing']['strategy'] not in {'canary', 'blue-green'}:
    raise SystemExit('Routing strategy must be canary or blue-green.')
if control['routing']['existingSession06Or07SupportConfirmed'] is not True:
    raise SystemExit('Existing Session 06 or 07 routing support is not confirmed.')
if control.get('releaseCommit') != {
    'source': 'workflow_dispatch.release_sha',
    'format': 'full-40-character-git-sha',
    'approvedBranchSource': 'repository.defaultBranch',
    'workflowRefMustMatchApprovedBranch': True,
    'mustBeReachableFromApprovedBranch': True,
    'checkoutMustMatch': True,
    'manifestMustMatch': True,
}:
    raise SystemExit('Control must bind workflow ref, protected-branch lineage, checkout, and manifest to the approved release SHA.')
for field in ('promptVersion', 'agentName', 'agentVersion', 'modelDeploymentAlias', 'apimPolicyVersion', 'evaluationRunId', 'evaluationThresholdPolicyVersion', 'evaluationThresholdPolicySha256', 'previousApprovedReleaseId'):
    value = str(control['immutableRelease'][field])
    if not value or re.search(r'(?i)(^|[/@:._-])(latest|current)([/@:._-]|$)', value):
        raise SystemExit(f'immutableRelease.{field} must be immutable.')
for workflow_text in (promotion_workflow, restore_workflow):
    for match in re.finditer(r'(?m)^\s*uses:\s*([^#\r\n]+)', workflow_text):
        use_value = match.group(1).strip().strip('"\'')
        if use_value.startswith('./'):
            continue
        ref = use_value.rsplit('@', 1)[-1] if '@' in use_value else ''
        if not re.fullmatch(r'[0-9a-fA-F]{40}', ref):
            raise SystemExit('Every external workflow action must use a full 40-character commit SHA.')
checkout_count = len(re.findall(r'(?m)^\s*uses:\s*actions/checkout@', promotion_workflow))
release_ref_count = len(re.findall(r'(?m)^\s*ref:\s*\$\{\{\s*inputs\.release_sha\s*\}\}', promotion_workflow))
protected_branch_ref_count = len(re.findall(r'(?m)^\s*ref:\s*\$\{\{\s*github\.event\.repository\.default_branch\s*\}\}', promotion_workflow))
if checkout_count < 2 or protected_branch_ref_count != 1 or release_ref_count != checkout_count - 1:
    raise SystemExit('Promotion must validate one protected-branch checkout before every exact release checkout.')
lineage_step = promotion_workflow.find('Prove the release commit belongs to the protected branch')
first_release_checkout = promotion_workflow.find('Check out the exact release commit after lineage validation')
if lineage_step < 0 or first_release_checkout < 0 or lineage_step > first_release_checkout:
    raise SystemExit('Release content must not be checked out before protected-branch lineage validation.')
for fragment in (
    'release_sha:',
    'run-name: Controlled AI release ${{ inputs.release_sha }} (${{ inputs.evaluation_record }})',
    'ref: ${{ github.event.repository.default_branch }}',
    'fetch-depth: 0',
    'git merge-base --is-ancestor $releaseSha "refs/remotes/origin/$approvedBranch"',
    'releaseCommitSha="${{ inputs.release_sha }}"',
    '-Mode CreateManifest -ReleaseSha "${{ inputs.release_sha }}"',
):
    if fragment not in promotion_workflow:
        raise SystemExit(f'Promotion workflow does not bind the approved release SHA: {fragment}')
threshold_policy_path = repo_root / control['sourcePaths']['session11ThresholdPolicy']
if hashlib.sha256(threshold_policy_path.read_bytes()).hexdigest() != control['immutableRelease']['evaluationThresholdPolicySha256']:
    raise SystemExit('The approved Session 11 threshold policy hash does not match immutable release metadata.')

def resolve_repo_path(relative_path: str) -> str:
    candidate = (repo_root / relative_path).resolve()
    if os.path.isabs(relative_path) or not str(candidate).startswith(str(repo_root) + os.sep):
        raise SystemExit('A customer source path resolves outside the repository.')
    if not candidate.is_file():
        raise SystemExit(f'Customer source path is missing: {relative_path}')
    return str(candidate)

bicep_path = resolve_repo_path(control['sourcePaths']['bicepEntrypoint'])
apim_policy_path = resolve_repo_path(control['sourcePaths']['apimPolicy'])
unit_script_path = resolve_repo_path(control['sourcePaths']['unitTestScript'])
smoke_powershell_path = resolve_repo_path(control['sourcePaths']['session13SmokePowerShell'])
smoke_bash_path = resolve_repo_path(control['sourcePaths']['session13SmokeBash'])
routing_script_path = resolve_repo_path(control['sourcePaths']['routingControlScript'])
release_store_script_path = resolve_repo_path(control['sourcePaths']['releaseStoreScript'])

for parameters, environment_name in ((nonprod_params['parameters'], 'nonproduction'), (prod_params['parameters'], 'production')):
    if parameters['environment']['value'] != environment_name or parameters['implementationSession']['value'] != '14-cicd-promotion-controls':
        raise SystemExit(f'{environment_name} parameters have the wrong environment or implementation marker.')
    if 'releaseCommitSha' in parameters:
        raise SystemExit(f'{environment_name} parameters must receive releaseCommitSha at runtime.')
    for parameter_name, control_name in (('promptVersion', 'promptVersion'), ('agentVersion', 'agentVersion'), ('modelDeploymentAlias', 'modelDeploymentAlias'), ('apimPolicyVersion', 'apimPolicyVersion')):
        if parameters[parameter_name]['value'] != control['immutableRelease'][control_name]:
            raise SystemExit(f'{environment_name} parameters disagree on {parameter_name}.')

release_gate = repo_root / control['sourcePaths']['session11ReleaseGate']
release_policy = repo_root / control['sourcePaths']['session11ReleasePolicy']
self_test = repo_root / control['sourcePaths']['session11GateSelfTest']
thresholds = repo_root / control['sourcePaths']['session11ThresholdPolicy']
spec = repo_root / control['sourcePaths']['session11EvaluationSpec']
dataset = repo_root / control['sourcePaths']['session11Dataset']
baseline = repo_root / control['sourcePaths']['session11BaselineRecord']
candidate = repo_root / control['sourcePaths']['session11CandidateRecord']
subprocess.check_call([sys.executable, str(release_gate), '--policy', str(thresholds), '--spec', str(spec), '--dataset', str(dataset), '--baseline-result', str(baseline), '--candidate-result', str(candidate), '--release-policy', str(release_policy), '--require-enabled', '--evaluated-target', 'candidate', '--expect', 'pass', '--phase', 'candidate'])
subprocess.check_call([sys.executable, str(self_test), '--mode', 'blocked-tool-process'])
report = json.loads((repo_root / control['sourcePaths']['session12AdversarialReport']).read_text())
if report.get('status') != 'confirmed' or not report['comparison']['lowerOverallAttackSuccessRate'] or not report['comparison']['perRiskNonRegressionPassed'] or not report['comparison']['prohibitedActionsBlocked']:
    raise SystemExit('The confirmed Session 12 adversarial report is not confirmed in the required state.')
if report.get('target', {}).get('name') != control['immutableRelease']['agentName'] or report.get('target', {}).get('postRemediationVersion') != control['immutableRelease']['agentVersion']:
    raise SystemExit('The confirmed Session 12 adversarial report targets another agent name or immutable version.')
if set(report.get('privacy', {})) != {'containsAttackPrompts', 'containsAgentResponses', 'containsToolPayloads', 'containsEvaluatorReasons', 'containsPromptEvidence'}:
    raise SystemExit('The confirmed Session 12 adversarial report has an incomplete privacy schema.')
for field in ('containsAttackPrompts', 'containsAgentResponses', 'containsToolPayloads', 'containsEvaluatorReasons', 'containsPromptEvidence'):
    if report['privacy'][field] is not False:
        raise SystemExit('The confirmed Session 12 adversarial report must remain payload-free.')
metrics = report.get('comparison', {}).get('metrics')
if not isinstance(metrics, list) or not metrics:
    raise SystemExit('The confirmed Session 12 adversarial report has no per-risk comparison rows.')
keys = set()
required_metric_fields = {'evaluatorName', 'riskCategory', 'attackStrategy', 'baselineAttackSuccessRate', 'postRemediationAttackSuccessRate', 'change', 'nonRegressionPassed'}
for metric in metrics:
    if set(metric) != required_metric_fields:
        raise SystemExit('The confirmed Session 12 per-risk comparison schema is incomplete.')
    key = tuple(str(metric.get(field, '')).strip() for field in ('evaluatorName', 'riskCategory', 'attackStrategy'))
    baseline_rate = metric.get('baselineAttackSuccessRate')
    post_rate = metric.get('postRemediationAttackSuccessRate')
    change = metric.get('change')
    if not all(key) or key in keys or metric.get('nonRegressionPassed') is not True or isinstance(baseline_rate, bool) or isinstance(post_rate, bool) or isinstance(change, bool) or not isinstance(baseline_rate, (int, float)) or not isinstance(post_rate, (int, float)) or not isinstance(change, (int, float)) or not 0 <= baseline_rate <= 1 or not 0 <= post_rate <= 1 or abs((post_rate - baseline_rate) - change) > 0.000001 or post_rate > baseline_rate:
        raise SystemExit('The required Session 12 adversarial per-risk schema is incomplete, duplicated, or regressed.')
    keys.add(key)
state_json.write_text(json.dumps({
    'bicepPath': bicep_path,
    'apimPolicyPath': apim_policy_path,
    'unitScriptPath': unit_script_path,
    'smokePowerShellPath': smoke_powershell_path,
    'smokeBashPath': smoke_bash_path,
    'routingScriptPath': routing_script_path,
    'releaseStoreScriptPath': release_store_script_path,
}))
PY

bicep_path="$(python - "$state_json" <<'PY'
import json, sys
print(json.load(open(sys.argv[1]))['bicepPath'])
PY
)"

az bicep version >/dev/null
az bicep lint --file "$bicep_path"
az bicep build --file "$bicep_path" --stdout >/dev/null

if [[ "$phase" == 'decisions' ]]; then
  printf 'PASS: release policy, immutable metadata, source paths, action pins, dependencies, and environment parameters are consistent.\n'
  exit 0
fi

repo_json="$(gh api "repos/$expected_repository")"
python - "$repo_json" <<'PY'
import json, sys
repository = json.loads(sys.argv[1])
security = repository.get('security_and_analysis')
if not security or security.get('secret_scanning', {}).get('status') != 'enabled' or security.get('secret_scanning_push_protection', {}).get('status') != 'enabled':
    raise SystemExit('Native secret scanning and push protection must be accessible and enabled.')
PY
repo_default_branch="$(python - "$repo_json" <<'PY'
import json, sys
print(json.loads(sys.argv[1])['default_branch'])
PY
)"
expected_default_branch="$approved_branch"
[[ "$repo_default_branch" == "$expected_default_branch" ]] || fail 'Protected default branch decision does not match the GitHub repository.'
encoded_approved_branch="$(python - "$approved_branch" <<'PY'
import sys
import urllib.parse
print(urllib.parse.quote(sys.argv[1], safe=''))
PY
)"
release_branch_json="$(gh api "repos/$expected_repository/branches/$encoded_approved_branch")"
python - "$release_branch_json" <<'PY'
import json, sys
branch = json.loads(sys.argv[1])
if branch.get('protected') is not True:
    raise SystemExit('The approved default release branch is not protected.')
PY
gh api "repos/$expected_repository/secret-scanning/alerts?state=open&per_page=100" >"$secret_scanning_alerts_json"
open_alerts_count="$(python - "$secret_scanning_alerts_json" <<'PY'
import json, sys
from pathlib import Path
print(len(json.loads(Path(sys.argv[1]).read_text())))
PY
)"
[[ "$open_alerts_count" == '0' ]] || fail 'Resolve all open GitHub secret-scanning alerts before promotion.'

python - "$artifact_root/control-definition.json" "$expected_repository" "$approved_nonproduction_scope" "$approved_production_scope" <<'PY'
import json
import subprocess
import sys

control = json.load(open(sys.argv[1]))
repository = sys.argv[2]
scopes = {'nonproduction': sys.argv[3], 'production': sys.argv[4]}

def command_json(*args):
    return json.loads(subprocess.check_output(args, text=True))

environments = {}
variables = {}
for name in ('nonproduction-preview', 'nonproduction', 'production-preview', 'production'):
    environments[name] = command_json('gh', 'api', f'repos/{repository}/environments/{name}')
    response = command_json('gh', 'api', f'repos/{repository}/environments/{name}/variables?per_page=100')
    variables[name] = {item['name']: item['value'] for item in response.get('variables', [])}
    if environments[name].get('name') != name:
        raise SystemExit(f'GitHub environment {name} is missing or renamed.')

def require_approval(name, team_slug):
    rules = [rule for rule in environments[name].get('protection_rules', []) if rule.get('type') == 'required_reviewers']
    if len(rules) != 1:
        raise SystemExit(f'{name} requires one reviewer rule.')
    reviewers = rules[0].get('reviewers', [])
    slugs = [entry.get('reviewer', {}).get('slug') for entry in reviewers]
    if slugs != [team_slug] or rules[0].get('prevent_self_review') is not True:
        raise SystemExit(f'{name} reviewer team or prevent-self-review differs from the operational control.')

require_approval('nonproduction', control['githubEnvironments']['nonproduction']['requiredReviewerTeamSlug'])
require_approval('production', control['githubEnvironments']['production']['requiredReviewerTeamSlug'])
secret_response = command_json('gh', 'api', f'repos/{repository}/environments/nonproduction/secrets?per_page=100')
nonproduction_secret_names = {item['name'] for item in secret_response.get('secrets', [])}
for required_name in ('SESSION13_SMOKE_URL', 'SESSION13_SMOKE_FAILURE_URL', 'SESSION13_AI_RESOURCE_ID', 'SESSION13_LOG_ANALYTICS_WORKSPACE_ID'):
    if not str(variables['nonproduction'].get(required_name, '')).strip():
        raise SystemExit(f'nonproduction GitHub environment variable {required_name} is required for the Session 13 smoke.')
try:
    poll_timeout = int(str(variables['nonproduction'].get('SESSION13_SMOKE_TIMEOUT_SECONDS', '')).strip() or '180')
    poll_retry = int(str(variables['nonproduction'].get('SESSION13_SMOKE_RETRY_SECONDS', '')).strip() or '15')
except ValueError as error:
    raise SystemExit('Session 13 telemetry polling values must be integers.') from error
if not 30 <= poll_timeout <= 600 or not 5 <= poll_retry <= 60 or poll_retry > poll_timeout:
    raise SystemExit('Session 13 telemetry polling must use timeout 30-600 seconds and retry 5-60 seconds.')
if 'SESSION13_SMOKE_BEARER_TOKEN' not in nonproduction_secret_names:
    raise SystemExit('nonproduction GitHub environment secret SESSION13_SMOKE_BEARER_TOKEN is required.')
production = environments['production']
if production.get('can_admins_bypass') is not False:
    raise SystemExit('Production administrator bypass must be disabled.')
branch = production.get('deployment_branch_policy') or {}
if branch.get('protected_branches') is not True and branch.get('custom_branch_policies') is not True:
    raise SystemExit('Production requires a protected branch or custom branch policy.')
restriction = control['githubEnvironments']['production']['branchOrTagRestriction']
if branch.get('protected_branches') is True:
    if restriction != 'protected-branches-only':
        raise SystemExit("The approved production restriction must be 'protected-branches-only'.")
else:
    policies = command_json('gh', 'api', f'repos/{repository}/environments/production/deployment-branch-policies?per_page=100')
    patterns = [item.get('name') for item in policies.get('branch_policies', [])]
    if patterns != [restriction]:
        raise SystemExit('Production custom branch or tag policy differs from the one approved pattern.')

tenant = str(control['azure']['tenantId'])
active_tenant = subprocess.check_output(('az', 'account', 'show', '--query', 'tenantId', '-o', 'tsv'), text=True).strip()
if active_tenant.lower() != tenant.lower():
    raise SystemExit('Azure CLI is not authenticated to the approved tenant.')

definitions = (
    ('nonproduction-preview', 'nonproduction', 'nonproductionClientId', 'nonproductionPreviewFederatedCredentialName', 'nonproductionPreview'),
    ('nonproduction', 'nonproduction', 'nonproductionClientId', 'nonproductionFederatedCredentialName', 'nonproduction'),
    ('production-preview', 'production', 'productionClientId', 'productionPreviewFederatedCredentialName', 'productionPreview'),
    ('production', 'production', 'productionClientId', 'productionFederatedCredentialName', 'production'),
)
for environment, stage, client_key, credential_key, subject_key in definitions:
    scope = scopes[stage]
    subscription_id = scope.split('/')[2]
    resource_group = scope.split('/')[4]
    expected = {
        'AZURE_CLIENT_ID': str(control['azure'][client_key]),
        'AZURE_TENANT_ID': tenant,
        'AZURE_SUBSCRIPTION_ID': subscription_id,
        'AZURE_RESOURCE_GROUP': resource_group,
    }
    for key, value in expected.items():
        if str(variables[environment].get(key, '')).lower() != value.lower():
            raise SystemExit(f'{environment} variable {key} differs from the operational identity or scope.')
    credentials = command_json('az', 'ad', 'app', 'federated-credential', 'list', '--id', expected['AZURE_CLIENT_ID'], '-o', 'json')
    matches = [item for item in credentials if item.get('name') == control['azure'][credential_key]]
    subject = control['githubEnvironments'][subject_key]['oidcSubject']
    if len(matches) != 1 or matches[0].get('issuer') != 'https://token.actions.githubusercontent.com' or matches[0].get('subject') != subject or 'api://AzureADTokenExchange' not in matches[0].get('audiences', []):
        raise SystemExit(f'{environment} federated credential does not match the approved GitHub OIDC subject.')
    object_id = subprocess.check_output(('az', 'ad', 'sp', 'show', '--id', expected['AZURE_CLIENT_ID'], '--query', 'id', '-o', 'tsv'), text=True).strip()
    assignments = command_json('az', 'role', 'assignment', 'list', '--assignee-object-id', object_id, '--scope', scope, '--include-inherited', '-o', 'json')
    accepted = [item for item in assignments if item.get('roleDefinitionName') == 'Contributor' and str(item.get('scope', '')).lower() == scope.lower()]
    if len(accepted) != 1 or len(assignments) != 1:
        raise SystemExit(f'{environment} identity must have only Contributor at the exact resource-group scope.')
PY

nonprod_sub="${approved_nonproduction_scope#/subscriptions/}"
nonprod_sub="${nonprod_sub%%/*}"
nonprod_rg="${approved_nonproduction_scope##*/resourceGroups/}"
prod_sub="${approved_production_scope#/subscriptions/}"
prod_sub="${prod_sub%%/*}"
prod_rg="${approved_production_scope##*/resourceGroups/}"

printf 'Preview 1 of 2: nonproduction at %s\n' "$approved_nonproduction_scope"
az deployment group what-if \
  --subscription "$nonprod_sub" \
  --resource-group "$nonprod_rg" \
  --name 's14-preflight-nonproduction' \
  --template-file "$bicep_path" \
  --parameters "$artifact_root/environments/nonproduction.parameters.json" \
  releaseCommitSha="$approved_release_sha" \
  --no-pretty-print

printf 'Preview 2 of 2: production at %s\n' "$approved_production_scope"
az deployment group what-if \
  --subscription "$prod_sub" \
  --resource-group "$prod_rg" \
  --name 's14-preflight-production' \
  --template-file "$bicep_path" \
  --parameters "$artifact_root/environments/production.parameters.json" \
  releaseCommitSha="$approved_release_sha" \
  --no-pretty-print

printf 'PASS: files, exact scopes, four live environments, apply approvals, native secret controls, four OIDC credentials, Contributor assignments, workflow enforcement, dependencies, and both read-only previews are ready.\n'
