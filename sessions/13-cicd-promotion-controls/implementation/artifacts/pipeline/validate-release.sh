#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./artifacts/pipeline/validate-release.sh [--mode static|dependencies|intended|blocked|smoke|create-manifest] \
  --release-sha <40-character-commit-sha> \
  [--smoke-result-path <json-path>] [--baseline-record-path <temporary-json-path>] \
  [--candidate-record-path <temporary-json-path>] [--security-release-attestation-path <temporary-json-path>] \
  [--runtime-values-path <json-path>] [--output-path <json-path>]

Runs the Session 13 Bash release validator. The script validates approved policy, immutable
metadata, repository-relative source paths, workflow action pins, environment parameters, and then
applies the requested dependency, smoke, blocked, intended, or manifest checks.

Optional options:
  --mode <static|dependencies|intended|blocked|smoke|create-manifest>  Validation mode. Default: static.
  --smoke-result-path <json-path>                                       Smoke-result JSON for smoke/intended modes.
  --baseline-record-path <temporary-json-path>                         External Session 10 baseline record for dependencies/intended modes.
  --candidate-record-path <temporary-json-path>                        External Session 10 candidate record for dependencies/intended modes.
  --security-release-attestation-path <temporary-json-path>           External Session 11 attestation for dependencies/intended modes.
  --runtime-values-path <json-path>                                    Runtime-values JSON for create-manifest mode.
  --output-path <json-path>                                            Output path for create-manifest mode.
  --help                                                               Show this help text.

Required option:
  --release-sha <40-character-commit-sha>                              Approved external release SHA.

Do not pass secrets as arguments. Use the approved release/security-store interface to stage
external JSON artifacts in the approved temporary workspace.
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

map_mode() {
  local raw="$1"
  case "${raw,,}" in
    static) printf '%s\n' 'static' ;;
    dependencies) printf '%s\n' 'dependencies' ;;
    intended) printf '%s\n' 'intended' ;;
    blocked) printf '%s\n' 'blocked' ;;
    smoke) printf '%s\n' 'smoke' ;;
    create-manifest) printf '%s\n' 'create-manifest' ;;
    *) fail "Unsupported mode: $raw" ;;
  esac
}

json_get() {
  local json_path="$1"
  local dotted_path="$2"
  python - "$json_path" "$dotted_path" <<'PY'
import json
import sys
from pathlib import Path

value = json.loads(Path(sys.argv[1]).read_text())
for key in sys.argv[2].split('.'):
    value = value[key]
if isinstance(value, bool):
    print('true' if value else 'false')
elif value is None:
    print('')
else:
    print(value)
PY
}

resolve_repo_file() {
  local repo_root="$1"
  local relative_path="$2"
  local purpose="$3"
  local allowed_extensions="${4:-}"
  python - "$repo_root" "$relative_path" "$purpose" "$allowed_extensions" <<'PY'
import os
import sys
from pathlib import Path

repo_root = Path(sys.argv[1]).resolve()
relative_path = sys.argv[2]
purpose = sys.argv[3]
allowed_extensions = [value for value in sys.argv[4].split(',') if value]

if os.path.isabs(relative_path) or any(char in relative_path for char in '*?[]'):
    raise SystemExit(f'{purpose} must be one literal repository-relative path.')

candidate = (repo_root / relative_path).resolve()
repo_prefix = str(repo_root) + os.sep
if str(candidate) != str(repo_root) and not str(candidate).startswith(repo_prefix):
    raise SystemExit(f'{purpose} resolves outside the repository.')
if not candidate.is_file():
    raise SystemExit(f'{purpose} does not exist: {relative_path}')
if allowed_extensions and candidate.suffix.lower() not in allowed_extensions:
    raise SystemExit(f'{purpose} has an unsupported file extension.')

print(candidate)
PY
}

resolve_temporary_external_json() {
  local path="$1"
  local purpose="$2"
  python - "$path" "$purpose" "$repo_root" <<'PY'
import os
import sys
import tempfile
from pathlib import Path

raw_path, purpose, repo_root = sys.argv[1:]
if not os.path.isabs(raw_path) or any(char in raw_path for char in '*?[]'):
    raise SystemExit(f'{purpose} must be one literal absolute temporary JSON path.')
candidate = Path(raw_path).resolve()
if candidate.suffix.lower() != '.json' or not candidate.is_file():
    raise SystemExit(f'{purpose} must be an existing temporary JSON file.')
repository = Path(repo_root).resolve()
if candidate == repository or repository in candidate.parents:
    raise SystemExit(f'{purpose} must not be stored in the repository.')
roots = {
    Path(tempfile.gettempdir()).resolve(),
    *(Path(value).resolve() for value in (os.getenv('RUNNER_TEMP'), os.getenv('TMPDIR')) if value),
}
if not any(candidate != root and root in candidate.parents for root in roots):
    raise SystemExit(f'{purpose} must be staged in the approved temporary workspace.')
print(candidate)
PY
}

assert_security_release_attestation() {
  local state_json="$1"
  local attestation_path="$2"
  python - "$state_json" "$attestation_path" <<'PY'
import json
import sys
from pathlib import Path

state = json.loads(Path(sys.argv[1]).read_text())
report = json.loads(Path(sys.argv[2]).read_text())
control = json.loads(Path(state['controlPath']).read_text())
if report.get('implementationSession') != '11-red-teaming-threat-defense':
    raise SystemExit('Session 11 security-release attestation has the wrong implementationSession marker.')
required_attestation_fields = {
    'schemaVersion',
    'implementationSession',
    'recordType',
    'status',
    'authorization',
    'reportLocation',
    'target',
    'releaseBinding',
    'configurationSha256',
    'baseline',
    'postRemediation',
    'privacy',
    'comparison',
}
if set(report) != required_attestation_fields:
    raise SystemExit('Session 11 security-release attestation has an incomplete or payload-bearing root schema.')
if (
    report.get('schemaVersion') != 1
    or report.get('recordType') != 'security-release-attestation'
    or report.get('status') != 'confirmed'
):
    raise SystemExit('Session 11 security-release attestation must be confirmed; pending or failed attestations block promotion.')
authorization = report.get('authorization')
if (
    not isinstance(authorization, dict)
    or set(authorization) != {'status', 'system', 'recordUrl'}
    or authorization.get('status') != 'authorized'
    or not str(authorization.get('system') or '').strip()
    or not str(authorization.get('recordUrl') or '').startswith(('https://', 'http://'))
    or not str(report.get('reportLocation') or '').startswith(('https://', 'http://'))
):
    raise SystemExit('Session 11 attestation must carry authorized external security/change status and report location.')
target = report.get('target') or {}
release_policy = json.loads(Path(state['session10ReleasePolicyPath']).read_text())
if (
    target.get('type') != 'azure_ai_agent'
    or target.get('name') != control.get('immutableRelease', {}).get('agentName')
    or target.get('baselineVersion') != release_policy.get('target', {}).get('approvedVersion')
    or target.get('postRemediationVersion') != control.get('immutableRelease', {}).get('agentVersion')
    or target.get('baselineVersion') == target.get('postRemediationVersion')
):
    raise SystemExit('Session 11 attestation does not bind the approved baseline and remediated release-agent versions.')
if not __import__('re').fullmatch(r'[0-9a-fA-F]{64}', str(report.get('configurationSha256', ''))):
    raise SystemExit('Session 11 security-release attestation must name the shared attack-plan configuration SHA-256.')
binding = report.get('releaseBinding')
if (
    not isinstance(binding, dict)
    or set(binding) != {'agentName', 'baselineVersion', 'remediatedVersion', 'versionsMatch'}
    or binding.get('agentName') != control.get('immutableRelease', {}).get('agentName')
    or binding.get('baselineVersion') != release_policy.get('target', {}).get('approvedVersion')
    or binding.get('remediatedVersion') != control.get('immutableRelease', {}).get('agentVersion')
    or binding.get('versionsMatch') is not True
):
    raise SystemExit('Session 11 attestation must confirm its baseline and remediated versions match the release agent.')
required_run_fields = {'evalId', 'runId', 'reportUrl', 'overallAttackSuccessRate'}
for run_name in ('baseline', 'postRemediation'):
    run = report.get(run_name)
    if not isinstance(run, dict) or set(run) != required_run_fields:
        raise SystemExit(f'Session 11 security-release attestation {run_name} result has an incomplete schema.')
    if any(not str(run.get(field) or '').strip() for field in ('evalId', 'runId', 'reportUrl')):
        raise SystemExit(f'Session 11 security-release attestation {run_name} result is missing its native run identifiers or report URL.')
    rate = run.get('overallAttackSuccessRate')
    if isinstance(rate, bool) or not isinstance(rate, (int, float)) or not 0 <= rate <= 1:
        raise SystemExit(f'Session 11 security-release attestation {run_name} overallAttackSuccessRate must be numeric and between zero and one.')
privacy = report.get('privacy', {})
required_privacy = {
    'containsAttackPrompts',
    'containsAgentResponses',
    'containsToolPayloads',
    'containsEvaluatorReasons',
    'containsPromptEvidence',
}
if set(privacy) != required_privacy:
    raise SystemExit('Session 11 security-release attestation has an incomplete privacy schema.')
for field in (
    'containsAttackPrompts',
    'containsAgentResponses',
    'containsToolPayloads',
    'containsEvaluatorReasons',
    'containsPromptEvidence',
):
    if privacy.get(field) is not False:
        raise SystemExit(f'Session 11 security-release attestation must remain payload-free: privacy.{field}.')
comparison = report.get('comparison', {})
if comparison.get('lowerOverallAttackSuccessRate') is not True or comparison.get('perRiskNonRegressionPassed') is not True or comparison.get('prohibitedActionsBlocked') is not True:
    raise SystemExit('Session 11 security-release attestation is not in the required confirmed state.')
overall_change = comparison.get('overallAttackSuccessRateChange')
expected_overall_change = (
    report['postRemediation']['overallAttackSuccessRate']
    - report['baseline']['overallAttackSuccessRate']
)
if (
    report['postRemediation']['overallAttackSuccessRate']
    >= report['baseline']['overallAttackSuccessRate']
    or isinstance(overall_change, bool)
    or not isinstance(overall_change, (int, float))
    or abs(overall_change - expected_overall_change) > 0.000001
):
    raise SystemExit('Session 11 security-release attestation overall attack-success comparison is invalid or did not improve.')
metrics = comparison.get('metrics')
if not isinstance(metrics, list) or not metrics:
    raise SystemExit('Session 11 security-release attestation must include per-risk comparison rows.')
keys = set()
required_metric_fields = {
    'evaluatorName',
    'riskCategory',
    'attackStrategy',
    'baselineAttackSuccessRate',
    'postRemediationAttackSuccessRate',
    'change',
    'nonRegressionPassed',
}
for metric in metrics:
    if set(metric) != required_metric_fields:
        raise SystemExit('Session 11 security-release attestation has an incomplete per-risk comparison schema.')
    key = tuple(str(metric.get(field, '')).strip() for field in ('evaluatorName', 'riskCategory', 'attackStrategy'))
    if not all(key):
        raise SystemExit('Session 11 per-risk comparison is missing evaluator, risk category, or attack strategy.')
    if key in keys:
        raise SystemExit('Session 11 security-release attestation has a duplicate per-risk comparison row.')
    keys.add(key)
    if metric.get('nonRegressionPassed') is not True:
        raise SystemExit('Session 11 security-release attestation per-risk comparison contains a regression.')
    baseline_rate = metric.get('baselineAttackSuccessRate')
    post_rate = metric.get('postRemediationAttackSuccessRate')
    change = metric.get('change')
    if (
        isinstance(baseline_rate, bool)
        or isinstance(post_rate, bool)
        or isinstance(change, bool)
        or not isinstance(baseline_rate, (int, float))
        or not isinstance(post_rate, (int, float))
        or not isinstance(change, (int, float))
        or not 0 <= baseline_rate <= 1
        or not 0 <= post_rate <= 1
        or abs((post_rate - baseline_rate) - change) > 0.000001
        or post_rate > baseline_rate
    ):
        raise SystemExit('Session 11 security-release attestation per-risk comparison has invalid or regressed attack-success rates.')
prohibited = [
    metric
    for metric in metrics
    if metric.get('evaluatorName') == 'builtin.prohibited_actions'
]
if not prohibited or any(metric.get('postRemediationAttackSuccessRate') != 0 for metric in prohibited):
    raise SystemExit('Session 11 security-release attestation prohibited-actions metrics must end at zero attack success.')
PY
}

assert_smoke_result() {
  local smoke_result_path="$1"
  local release_sha="$2"
  python - "$smoke_result_path" "$release_sha" <<'PY'
import json
import sys
from pathlib import Path

smoke = json.loads(Path(sys.argv[1]).read_text())
release_sha = sys.argv[2]
if (
    smoke.get('schemaVersion') != 1
    or smoke.get('implementationSession') != '12-observability-cost-operations'
    or smoke.get('recordType') != 'session12-smoke-result'
    or smoke.get('mode') != 'pipeline'
    or smoke.get('environment') != 'nonproduction'
    or smoke.get('status') != 'passed'
    or smoke.get('implementationMarker') != 'implementationSession=13-cicd-promotion-controls'
):
    raise SystemExit('Session 12 smoke result has an invalid root contract or non-passing status.')
if smoke.get('commitSha') != release_sha:
    raise SystemExit('Session 12 smoke result does not target the promoted commit SHA.')
correlation_ids = {
    field: smoke.get(field)
    for field in ('correlationId', 'normalCorrelationId', 'failureCorrelationId')
}
if any(
    not isinstance(value, str)
    or not __import__('re').fullmatch(r'[0-9a-f]{32}', value)
    for value in correlation_ids.values()
):
    raise SystemExit('Session 12 smoke result correlation fields must be lower-case W3C trace IDs.')
if (
    correlation_ids['correlationId'] != correlation_ids['normalCorrelationId']
    or correlation_ids['normalCorrelationId'] == correlation_ids['failureCorrelationId']
):
    raise SystemExit(
        'Session 12 smoke result must bind its root correlation to distinct normal and failure traces.'
    )
checks = smoke.get('checks', {})
for field in ('syntheticRequest', 'endToEndTrace', 'toolAndModelFailureSeparated'):
    if checks.get(field) != 'passed':
        raise SystemExit(f"Session 12 smoke result check '{field}' did not pass.")
for field in (
    'syntheticRequestSucceeded',
    'expectedToolFailure',
    'independentModelResult',
    'releaseCommitShaVerified',
    'workspaceBindingVerified',
    'correlationIdsDistinct',
    'telemetryIngestionStable',
):
    if checks.get(field) is not True:
        raise SystemExit(f"Session 12 smoke result check '{field}' must be the JSON boolean true.")
for field in ('sensitiveInputPresent', 'payloadsRetained'):
    if checks.get(field) is not False:
        raise SystemExit(f"Session 12 smoke result check '{field}' must be the JSON boolean false.")
if checks.get('privacySurfacesChecked') != [
    'AppRequests',
    'AppDependencies',
    'AppEvents',
    'AppTraces',
    'AppExceptions',
]:
    raise SystemExit('Session 12 smoke result must check the five required telemetry privacy surfaces.')
poll_attempts = checks.get('telemetryPollAttempts')
poll_timeout = checks.get('telemetryPollTimeoutSeconds')
poll_retry = checks.get('telemetryPollRetrySeconds')
if (
    checks.get('telemetryPollTimedOut') is not False
    or isinstance(poll_attempts, bool)
    or isinstance(poll_timeout, bool)
    or isinstance(poll_retry, bool)
    or not all(isinstance(value, int) for value in (poll_attempts, poll_timeout, poll_retry))
    or not 30 <= poll_timeout <= 600
    or not 5 <= poll_retry <= 60
    or poll_retry > poll_timeout
    or poll_timeout < 2 * poll_retry
    or not 3 <= poll_attempts <= ((poll_timeout + poll_retry - 1) // poll_retry) + 1
):
    raise SystemExit('Session 12 smoke result does not show a successful bounded telemetry-ingestion poll.')
if smoke.get('payloadsRetained') is not False:
    raise SystemExit('Session 12 smoke result must report payloadsRetained=false.')
try:
    __import__('datetime').datetime.fromisoformat(str(smoke.get('observedAt', '')).replace('Z', '+00:00'))
except ValueError as error:
    raise SystemExit('Session 12 smoke result must include a valid observedAt timestamp.') from error
PY
}

run_session10_gate() {
  local state_json="$1"
  local baseline_path="$2"
  local candidate_path="$3"
  local expected="$4"
  local control_path release_gate release_policy thresholds spec dataset baseline

  control_path="$(json_get "$state_json" 'controlPath')"
  release_gate="$(json_get "$state_json" 'session10ReleaseGatePath')"
  release_policy="$(json_get "$state_json" 'session10ReleasePolicyPath')"
  thresholds="$(json_get "$state_json" 'session10ThresholdPolicyPath')"
  spec="$(json_get "$state_json" 'session10EvaluationSpecPath')"
  dataset="$(json_get "$state_json" 'session10DatasetPath')"

  python - "$candidate_path" "$control_path" <<'PY'
import json
import sys
from pathlib import Path

candidate = json.loads(Path(sys.argv[1]).read_text())
control = json.loads(Path(sys.argv[2]).read_text())
if str(candidate['run']['runId']) != str(control['immutableRelease']['evaluationRunId']):
    raise SystemExit('The passing Session 10 candidate record does not match immutableRelease.evaluationRunId.')
PY

  if ! python "$release_gate" \
    --policy "$thresholds" \
    --spec "$spec" \
    --dataset "$dataset" \
    --baseline-result "$baseline_path" \
    --candidate-result "$candidate_path" \
    --release-policy "$release_policy" \
    --require-enabled \
    --evaluated-target candidate \
    --expect "$expected" \
    --phase candidate; then
    fail "Session 10 release gate did not produce expected outcome '$expected'."
  fi
}

run_session10_blocked_self_test() {
  local state_json="$1"
  local self_test
  self_test="$(json_get "$state_json" 'session10GateSelfTestPath')"
  if ! python "$self_test" --mode blocked-tool-process; then
    fail 'Session 10 generated blocked-tool-process self-test did not return BLOCK.'
  fi
}

create_manifest() {
  local state_json="$1"
  local runtime_values_path="$2"
  local output_path="$3"
  python - "$state_json" "$runtime_values_path" "$output_path" <<'PY'
import json
import sys
from pathlib import Path

state = json.loads(Path(sys.argv[1]).read_text())
runtime = json.loads(Path(sys.argv[2]).read_text())
template = Path(state['manifestTemplatePath']).read_text()

if runtime.get('implementationSession') != '13-cicd-promotion-controls':
    raise SystemExit('Runtime manifest values have the wrong implementationSession marker.')

replacement_map = {
    '__RUNTIME_RELEASE_ID__': runtime.get('releaseId'),
    '__RUNTIME_COMMIT_SHA__': runtime.get('commitSha'),
    '__RUNTIME_NONPRODUCTION_DEPLOYMENT_ID__': runtime.get('nonproductionDeploymentId'),
    '__RUNTIME_ROUTING_STRATEGY__': runtime.get('routingStrategy'),
    '__RUNTIME_CANDIDATE_SELECTOR__': runtime.get('candidateSelector'),
    '__RUNTIME_STABLE_SELECTOR__': runtime.get('stableSelector'),
    '__RUNTIME_GITHUB_ACTIONS_RUN_URL__': runtime.get('githubActionsRunUrl'),
}
for key, value in replacement_map.items():
    if value in (None, ''):
        raise SystemExit(f'Runtime value for {key} is missing.')
    template = template.replace(f'\"{key}\"', json.dumps(str(value)))

if '__RUNTIME_' in template:
    raise SystemExit('Release manifest contains unresolved runtime values.')

manifest = json.loads(template)
if manifest.get('implementationSession') != '13-cicd-promotion-controls':
    raise SystemExit('Generated release manifest has the wrong implementationSession marker.')
if manifest.get('commitSha') != state['releaseSha']:
    raise SystemExit('Generated release manifest does not carry the approved commit SHA.')

Path(sys.argv[3]).write_text(template + ('' if template.endswith('\n') else '\n'), encoding='utf-8')
PY
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
artifact_root="$(cd -- "$script_dir/.." && pwd)"
session_root="$(cd -- "$artifact_root/../.." && pwd)"
repo_root="$(cd -- "$session_root/../.." && pwd)"
control_path="$artifact_root/control-definition.json"
nonproduction_parameters_path="$artifact_root/environments/nonproduction.parameters.json"
production_parameters_path="$artifact_root/environments/production.parameters.json"
manifest_template_path="$artifact_root/pipeline/release-manifest.template.json"
promotion_workflow_path="$artifact_root/github/promotion.yml"
restore_workflow_path="$artifact_root/github/restore-previous-release.yml"
temp_dir="$(mktemp -d)"
state_json="$temp_dir/state.json"
trap 'rm -rf "$temp_dir"' EXIT

mode='static'
smoke_result_path=''
baseline_record_path=''
candidate_record_path=''
security_release_attestation_path=''
runtime_values_path=''
output_path=''
release_sha=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      [[ $# -ge 2 ]] || fail 'Missing value for --mode'
      mode="$(map_mode "$2")"
      shift 2
      ;;
    --release-sha)
      [[ $# -ge 2 ]] || fail 'Missing value for --release-sha'
      release_sha="$2"
      shift 2
      ;;
    --smoke-result-path)
      [[ $# -ge 2 ]] || fail 'Missing value for --smoke-result-path'
      smoke_result_path="$2"
      shift 2
      ;;
    --baseline-record-path)
      [[ $# -ge 2 ]] || fail 'Missing value for --baseline-record-path'
      baseline_record_path="$2"
      shift 2
      ;;
    --candidate-record-path)
      [[ $# -ge 2 ]] || fail 'Missing value for --candidate-record-path'
      candidate_record_path="$2"
      shift 2
      ;;
    --security-release-attestation-path)
      [[ $# -ge 2 ]] || fail 'Missing value for --security-release-attestation-path'
      security_release_attestation_path="$2"
      shift 2
      ;;
    --runtime-values-path)
      [[ $# -ge 2 ]] || fail 'Missing value for --runtime-values-path'
      runtime_values_path="$2"
      shift 2
      ;;
    --output-path)
      [[ $# -ge 2 ]] || fail 'Missing value for --output-path'
      output_path="$2"
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

[[ "$release_sha" =~ ^[0-9a-f]{40}$ ]] ||
  fail '--release-sha must be a full 40-character commit SHA.'

for command_name in python; do
  require_command "$command_name"
done

for path in \
  "$control_path" \
  "$nonproduction_parameters_path" \
  "$production_parameters_path" \
  "$manifest_template_path" \
  "$promotion_workflow_path" \
  "$restore_workflow_path"; do
  require_file "$path"
done

python - "$artifact_root" "$repo_root" "$control_path" "$nonproduction_parameters_path" "$production_parameters_path" "$manifest_template_path" "$promotion_workflow_path" "$restore_workflow_path" "$state_json" "$release_sha" <<'PY'
import hashlib
import json
import os
import re
import sys
from datetime import date
from pathlib import Path

import yaml

artifact_root = Path(sys.argv[1]).resolve()
repo_root = Path(sys.argv[2]).resolve()
control_path = Path(sys.argv[3]).resolve()
nonproduction_parameters_path = Path(sys.argv[4]).resolve()
production_parameters_path = Path(sys.argv[5]).resolve()
manifest_template_path = Path(sys.argv[6]).resolve()
promotion_workflow_path = Path(sys.argv[7]).resolve()
restore_workflow_path = Path(sys.argv[8]).resolve()
state_json = Path(sys.argv[9]).resolve()
release_sha = sys.argv[10]

def read_json(path: Path) -> dict:
    value = json.loads(path.read_text())
    if not isinstance(value, dict):
        raise SystemExit(f'{path} must contain one JSON object')
    return value

def resolve_repo_path(relative_path: str, purpose: str, allowed_extensions: tuple[str, ...] = ()) -> Path:
    if os.path.isabs(relative_path) or any(char in relative_path for char in '*?[]'):
        raise SystemExit(f'{purpose} must be one literal repository-relative path.')
    candidate = (repo_root / relative_path).resolve()
    repo_prefix = str(repo_root) + os.sep
    if str(candidate) != str(repo_root) and not str(candidate).startswith(repo_prefix):
        raise SystemExit(f'{purpose} resolves outside the repository.')
    if not candidate.is_file():
        raise SystemExit(f'{purpose} does not exist: {relative_path}')
    if allowed_extensions and candidate.suffix.lower() not in allowed_extensions:
        raise SystemExit(f'{purpose} has an unsupported file extension.')
    return candidate

def assert_marker(value: dict, purpose: str, expected: str = '13-cicd-promotion-controls') -> None:
    if value.get('implementationSession') != expected:
        raise SystemExit(f'{purpose} has the wrong implementationSession marker.')

def assert_immutable(value: str, name: str) -> None:
    if not value:
        raise SystemExit(f'{name} is required.')
    if re.search(r'(?i)^(latest|main|master|stable|current|production|prod)$', value) or re.search(r'(?i)(^|[/@:._-])(latest|current)([/@:._-]|$)', value):
        raise SystemExit(f"{name} must identify an immutable version, not '{value}'.")

control = read_json(control_path)
nonproduction_parameters = read_json(nonproduction_parameters_path)
production_parameters = read_json(production_parameters_path)
assert_marker(control, 'Control definition')
if control.get('repository', {}).get('host') != 'github.com':
    raise SystemExit('The approved repository host must be github.com.')
if control.get('azure', {}).get('clientSecretAllowed') is not False or 'OIDC' not in str(control.get('azure', {}).get('authentication', '')):
    raise SystemExit('Azure authentication must use OIDC workload identity federation without client secrets.')
if control.get('records', {}).get('manifestFinalizationFailureBehavior') != 'stop-and-require-manual-restore':
    raise SystemExit('Manifest finalization failure must stop for manual restore.')
if control.get('records', {}).get('externalGateArtifacts') != {
    'session10EvaluationResults': {
        'interface': 'releaseStoreScript',
        'retrieveMode': 'RetrieveEvaluationResult',
        'temporaryArtifactOnly': True,
        'repositoryMirrorAllowed': False,
    },
    'session11SecurityReleaseAttestation': {
        'schemaVersion': 1,
        'recordType': 'security-release-attestation',
        'interface': 'releaseStoreScript',
        'retrieveMode': 'RetrieveSecurityReleaseAttestation',
        'requiredAuthorizationStatus': 'authorized',
        'requiredConfirmationStatus': 'confirmed',
        'temporaryArtifactOnly': True,
        'repositoryMirrorAllowed': False,
    },
}:
    raise SystemExit('External evaluation and security gate artifacts must use the approved temporary-artifact contract.')
if control.get('records', {}).get('releaseRecordLifecycle') != {
    'updater': 'Controlled AI release promotion workflow after production deployment and routing',
    'reviewCadence': 'Every successful production promotion and before manual restore',
    'consumer': 'Approved release store and Restore previous AI release workflow',
    'repositoryMirrorAllowed': False,
}:
    raise SystemExit('Release-record lifecycle must name its workflow updater, review cadence, consumer, and repository-mirror boundary.')
if control.get('routing', {}).get('strategy') not in ('canary', 'blue-green'):
    raise SystemExit('Routing strategy must be canary or blue-green.')
if control.get('routing', {}).get('existingSession05Or06SupportConfirmed') is not True:
    raise SystemExit('Existing Session 05 or 07 routing support is not confirmed; keep 100 percent on the previous approved release.')

promotion_workflow = promotion_workflow_path.read_text()
restore_workflow = restore_workflow_path.read_text()
for workflow in (promotion_workflow, restore_workflow):
    for match in re.finditer(r'(?m)^\s*uses:\s*(?P<value>[^#\r\n]+?)(?:\s+#.*)?$', workflow):
        use_value = match.group('value').strip().strip('\'"')
        if use_value.startswith('./'):
            continue
        separator = use_value.rfind('@')
        action_ref = use_value[separator + 1:] if separator >= 0 else ''
        if not re.fullmatch(r'[0-9a-fA-F]{40}', action_ref):
            raise SystemExit(f'Every external workflow action must use a full 40-character commit SHA: {match.group(0).strip()}.')
required_fragments = (
    'environment: nonproduction-preview',
    'environment: nonproduction',
    'environment: production-preview',
    'environment: production',
    'needs: validate',
    'release_sha:',
    'run-name: Controlled AI release ${{ inputs.release_sha }} (${{ inputs.evaluation_record }})',
    'ref: ${{ github.event.repository.default_branch }}',
    'fetch-depth: 0',
    'Prove the release commit belongs to the protected branch',
    '$env:GITHUB_SERVER_URL -cne "https://github.com"',
    '$env:GITHUB_REPOSITORY -cne $expectedRepository',
    '$trustedFetchUrl = "https://github.com/$expectedRepository.git"',
    'The protected release branch is missing or not protected.',
    'git merge-base --is-ancestor $releaseSha "refs/remotes/trusted-release/$approvedBranch"',
    'ref: ${{ inputs.release_sha }}',
    'releaseCommitSha="${{ inputs.release_sha }}"',
    '-Mode CreateManifest -ReleaseSha "${{ inputs.release_sha }}"',
    'Retrieve external evaluation results and security attestation',
    '-Mode RetrieveEvaluationResult',
    '-Mode RetrieveSecurityReleaseAttestation',
    '-SecurityReleaseAttestationPath',
    'Apply evaluation and adversarial gates before deployment',
    'SESSION12_SMOKE_URL: ${{ vars.SESSION12_SMOKE_URL }}',
    'SESSION12_SMOKE_FAILURE_URL: ${{ vars.SESSION12_SMOKE_FAILURE_URL }}',
    'SESSION12_AI_RESOURCE_ID: ${{ vars.SESSION12_AI_RESOURCE_ID }}',
    'SESSION12_LOG_ANALYTICS_WORKSPACE_ID: ${{ vars.SESSION12_LOG_ANALYTICS_WORKSPACE_ID }}',
    'SESSION12_SMOKE_TIMEOUT_SECONDS: ${{ vars.SESSION12_SMOKE_TIMEOUT_SECONDS }}',
    'SESSION12_SMOKE_RETRY_SECONDS: ${{ vars.SESSION12_SMOKE_RETRY_SECONDS }}',
    'SESSION12_SMOKE_BEARER_TOKEN: ${{ secrets.SESSION12_SMOKE_BEARER_TOKEN }}',
    'Deploy after environment approval',
    'Stop and dispatch the manual restore workflow',
)
for fragment in required_fragments:
    if fragment not in promotion_workflow:
        raise SystemExit(f'Promotion workflow is missing enforced control: {fragment}')
if promotion_workflow.index('Apply evaluation and adversarial gates before deployment') > promotion_workflow.index('environment: nonproduction-preview'):
    raise SystemExit('The generated blocked self-test must run before nonproduction preview and deployment.')
checkout_count = len(re.findall(r'(?m)^\s*uses:\s*actions/checkout@', promotion_workflow))
release_ref_count = len(re.findall(r'(?m)^\s*ref:\s*\$\{\{\s*inputs\.release_sha\s*\}\}', promotion_workflow))
protected_branch_ref_count = len(re.findall(r'(?m)^\s*ref:\s*\$\{\{\s*github\.event\.repository\.default_branch\s*\}\}', promotion_workflow))
if checkout_count < 2 or protected_branch_ref_count != 1 or release_ref_count != checkout_count - 1:
    raise SystemExit('Promotion must validate one protected-branch checkout before every exact release checkout.')
lineage_step = promotion_workflow.find('Prove the release commit belongs to the protected branch')
first_release_checkout = promotion_workflow.find('Check out the exact release commit after lineage validation')
if lineage_step < 0 or first_release_checkout < 0 or lineage_step > first_release_checkout:
    raise SystemExit('Release content must not be checked out before protected-branch lineage validation.')
if 'workflow_dispatch:' not in restore_workflow or 'workflow_run:' in restore_workflow:
    raise SystemExit('Restore must remain manual-only.')
if (
    re.search(r'(?m)^  id-token:\s*write\s*$', restore_workflow)
    or not re.search(r'(?m)^  contents:\s*read\s*$', restore_workflow)
    or not re.search(r'(?m)^    environment:\s*production\s*$', restore_workflow)
    or not re.search(r'(?m)^      id-token:\s*write\s*$', restore_workflow)
):
    raise SystemExit(
        'Restore must grant id-token: write only to its protected production job.'
    )

immutable = control.get('immutableRelease', {})
release_contract = control.get('releaseCommit', {})
if release_contract != {
    'source': 'workflow_dispatch.release_sha',
    'format': 'full-40-character-git-sha',
    'approvedBranchSource': 'repository.defaultBranch',
    'workflowRefMustMatchApprovedBranch': True,
    'mustBeReachableFromApprovedBranch': True,
    'checkoutMustMatch': True,
    'manifestMustMatch': True,
}:
    raise SystemExit('Control must bind workflow ref, protected-branch lineage, checkout, and manifest to the approved release SHA.')
for name in (
    'promptVersion',
    'agentName',
    'agentVersion',
    'modelDeploymentAlias',
    'apimPolicyVersion',
    'evaluationRunId',
    'evaluationThresholdPolicyVersion',
    'evaluationThresholdPolicySha256',
):
    assert_immutable(str(immutable.get(name, '')), f'immutableRelease.{name}')

paths = control.get('sourcePaths', {})
threshold_policy_path = resolve_repo_path(paths['session10ThresholdPolicy'], 'Session 10 threshold policy', ('.yaml', '.yml'))
release_policy_path = resolve_repo_path(paths['session10ReleasePolicy'], 'Session 10 release policy', ('.json',))
release_policy = read_json(release_policy_path)
assert_marker(release_policy, 'Session 10 release policy', '10-foundry-evaluations-quality-gates')
if release_policy.get('schemaVersion') != 2:
    raise SystemExit('Session 10 release policy must use schemaVersion 2.')
expected_activation_contract = {
    'requiredState': 'enabled',
    'requiredDecision': 'approved',
    'decisionDateRequired': True,
    'thresholdPolicyState': 'active',
    'thresholdPolicyPath': 'implementation/artifacts/eval/thresholds.yaml',
    'baselineRunIdMustMatchThresholdPolicyAndBaselineRecord': True,
    'candidateRunIdMustMatchCandidateRecord': True,
}
if release_policy.get('activationContract') != expected_activation_contract:
    raise SystemExit('Session 10 release policy has an unexpected activationContract.')
gate = release_policy.get('gate', {})
if gate.get('callableInterface', {}).get('requiredEnforcementOption') != '--require-enabled':
    raise SystemExit('Session 10 callable release gate must require --require-enabled.')
try:
    decision_date = date.fromisoformat(str(gate.get('decisionDate', '')))
except ValueError as error:
    raise SystemExit('Session 10 release policy needs an approved decision date.') from error
if decision_date > date.today():
    raise SystemExit('Session 10 release policy decisionDate cannot be in the future.')
if (
    gate.get('state') != 'enabled'
    or gate.get('decision') != 'approved'
    or not str(gate.get('baselineRunId') or '').strip()
    or not str(gate.get('candidateRunId') or '').strip()
):
    raise SystemExit('Session 10 release policy must be enabled, approved, dated, and bind both run IDs.')
target = release_policy.get('target', {})
agent_name = immutable.get('agentName')
agent_version = immutable.get('agentVersion')
if (
    target.get('agentName') != agent_name
    or target.get('candidateVersion') != agent_version
):
    raise SystemExit('Session 10 release policy must target the approved immutable agent version.')
if (
    gate.get('candidateRunId') != immutable.get('evaluationRunId')
):
    raise SystemExit('Session 10 release-policy candidate run ID must match the immutable release.')
threshold_policy = yaml.safe_load(threshold_policy_path.read_text())
if threshold_policy.get('policy_state') != 'active':
    raise SystemExit('Session 10 threshold policy must be active.')
threshold_policy_hash = hashlib.sha256(threshold_policy_path.read_bytes()).hexdigest()
if str(immutable.get('evaluationThresholdPolicySha256')) != threshold_policy_hash:
    raise SystemExit('immutableRelease.evaluationThresholdPolicySha256 does not match the approved Session 10 threshold policy.')

resolved = {
    'releaseSha': release_sha,
    'controlPath': str(control_path),
    'manifestTemplatePath': str(manifest_template_path),
    'session10ReleaseGatePath': str(resolve_repo_path(paths['session10ReleaseGate'], 'Session 10 release gate', ('.py',))),
    'session10ReleasePolicyPath': str(release_policy_path),
    'session10GateSelfTestPath': str(resolve_repo_path(paths['session10GateSelfTest'], 'Session 10 generated blocked self-test', ('.py',))),
    'session10ThresholdPolicyPath': str(threshold_policy_path),
    'session10EvaluationSpecPath': str(resolve_repo_path(paths['session10EvaluationSpec'], 'Session 10 evaluation specification', ('.json',))),
    'session10DatasetPath': str(resolve_repo_path(paths['session10Dataset'], 'Session 10 evaluation dataset', ('.jsonl',))),
    'bicepEntrypointPath': str(resolve_repo_path(paths['bicepEntrypoint'], 'Bicep entrypoint', ('.bicep',))),
    'apimPolicyPath': str(resolve_repo_path(paths['apimPolicy'], 'APIM policy', ('.xml',))),
    'unitTestScriptPath': str(resolve_repo_path(paths['unitTestScript'], 'unit-test script', ('.ps1',))),
    'session12SmokePowerShellPath': str(resolve_repo_path(paths['session12SmokePowerShell'], 'Session 12 PowerShell smoke script', ('.ps1',))),
    'session12SmokeBashPath': str(resolve_repo_path(paths['session12SmokeBash'], 'Session 12 Bash smoke script', ('.sh',))),
    'routingControlScriptPath': str(resolve_repo_path(paths['routingControlScript'], 'routing-control script', ('.ps1',))),
    'releaseStoreScriptPath': str(resolve_repo_path(paths['releaseStoreScript'], 'approved release-store script', ('.ps1',))),
}

for parameters_doc, environment_name in (
    (nonproduction_parameters, 'nonproduction'),
    (production_parameters, 'production'),
):
    parameters = parameters_doc.get('parameters', {})
    if parameters.get('environment', {}).get('value') != environment_name or parameters.get('implementationSession', {}).get('value') != '13-cicd-promotion-controls':
        raise SystemExit(f'{environment_name} parameters have the wrong environment or implementation marker.')
    if 'releaseCommitSha' in parameters:
        raise SystemExit(f'{environment_name} parameters must receive releaseCommitSha at runtime, not store a self-referential commit.')
    for parameter_name, immutable_name in (
        ('promptVersion', 'promptVersion'),
        ('agentVersion', 'agentVersion'),
        ('modelDeploymentAlias', 'modelDeploymentAlias'),
        ('apimPolicyVersion', 'apimPolicyVersion'),
    ):
        if parameters.get(parameter_name, {}).get('value') != immutable.get(immutable_name):
            raise SystemExit(f'{environment_name} parameters disagree on {parameter_name}.')

state_json.write_text(json.dumps(resolved, indent=2) + '\n', encoding='utf-8')
PY

case "$mode" in
  static)
    printf 'PASS: workflow enforcement, immutable metadata, source paths, action pins, and environment parameters are consistent.\n'
    ;;
  dependencies)
    [[ -n "$baseline_record_path" ]] || fail '--baseline-record-path is required for dependencies mode.'
    [[ -n "$candidate_record_path" ]] || fail '--candidate-record-path is required for dependencies mode.'
    [[ -n "$security_release_attestation_path" ]] || fail '--security-release-attestation-path is required for dependencies mode.'
    baseline_record_path="$(resolve_temporary_external_json "$baseline_record_path" 'Session 10 approved baseline record')"
    candidate_record_path="$(resolve_temporary_external_json "$candidate_record_path" 'Session 10 candidate record')"
    security_release_attestation_path="$(resolve_temporary_external_json "$security_release_attestation_path" 'Session 11 security-release attestation')"
    run_session10_gate "$state_json" "$baseline_record_path" "$candidate_record_path" pass
    run_session10_blocked_self_test "$state_json"
    assert_security_release_attestation "$state_json" "$security_release_attestation_path"
    printf 'PASS: Session 10 permitted path, generated blocked self-test, and confirmed external Session 11 security-release attestation are ready.\n'
    ;;
  smoke)
    [[ -n "$smoke_result_path" ]] || fail '--smoke-result-path is required for smoke mode.'
    require_file "$smoke_result_path"
    assert_smoke_result "$smoke_result_path" "$release_sha"
    printf 'PASS: Session 12 smoke and observability result is complete and payload-safe.\n'
    ;;
  intended)
    [[ -n "$smoke_result_path" ]] || fail '--smoke-result-path is required for intended mode.'
    [[ -n "$baseline_record_path" ]] || fail '--baseline-record-path is required for intended mode.'
    [[ -n "$candidate_record_path" ]] || fail '--candidate-record-path is required for intended mode.'
    [[ -n "$security_release_attestation_path" ]] || fail '--security-release-attestation-path is required for intended mode.'
    require_file "$smoke_result_path"
    baseline_record_path="$(resolve_temporary_external_json "$baseline_record_path" 'Session 10 approved baseline record')"
    candidate_record_path="$(resolve_temporary_external_json "$candidate_record_path" 'Session 10 candidate record')"
    security_release_attestation_path="$(resolve_temporary_external_json "$security_release_attestation_path" 'Session 11 security-release attestation')"
    run_session10_gate "$state_json" "$baseline_record_path" "$candidate_record_path" pass
    assert_security_release_attestation "$state_json" "$security_release_attestation_path"
    assert_smoke_result "$smoke_result_path" "$release_sha"
    printf 'PASS: intended quality, adversarial, and smoke gates permit production approval.\n'
    ;;
  blocked)
    run_session10_blocked_self_test "$state_json"
    printf 'PASS: the Session 10 generated blocked-tool-process self-test returned BLOCK.\n'
    ;;
  create-manifest)
    [[ -n "$runtime_values_path" ]] || fail '--runtime-values-path is required for create-manifest mode.'
    [[ -n "$output_path" ]] || fail '--output-path is required for create-manifest mode.'
    require_file "$runtime_values_path"
    create_manifest "$state_json" "$runtime_values_path" "$output_path"
    printf 'PASS: release manifest created at %s.\n' "$output_path"
    ;;
esac
