#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/verify.sh --check intended|blocked --release-sha <40-character-sha> \
  --promotion-run-id <github-actions-run-id>

Runs the Session 12 Bash verification entrypoint. The script validates the requested check, reads the
operational control, inspects the named GitHub Actions run, and confirms the intended or blocked path.

Required options:
  --check <intended|blocked>          Verification path.
  --promotion-run-id <run-id>         GitHub Actions run ID to inspect.
  --release-sha <40-character-sha>    Approved release commit supplied to the workflow.

Optional options:
  --help                              Show this help text.

Do not pass secrets as arguments. Use your approved GitHub CLI sign-in context.
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

map_check() {
  local raw="$1"
  case "${raw,,}" in
    intended) printf '%s\n' 'intended' ;;
    blocked) printf '%s\n' 'blocked' ;;
    *) fail "Unsupported check: $raw" ;;
  esac
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
session_root="$(cd -- "$script_dir/../.." && pwd)"
artifact_root="$session_root/implementation/artifacts"
control_path="$artifact_root/control-definition.json"
validator_path="$artifact_root/pipeline/validate-release.sh"
temp_dir="$(mktemp -d)"
run_json="$temp_dir/run.json"
jobs_json="$temp_dir/jobs.json"
trap 'rm -rf "$temp_dir"' EXIT

check=''
promotion_run_id=''
release_sha=''

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      [[ $# -ge 2 ]] || fail 'Missing value for --check'
      check="$(map_check "$2")"
      shift 2
      ;;
    --promotion-run-id)
      [[ $# -ge 2 ]] || fail 'Missing value for --promotion-run-id'
      promotion_run_id="$2"
      shift 2
      ;;
    --release-sha)
      [[ $# -ge 2 ]] || fail 'Missing value for --release-sha'
      release_sha="$2"
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

[[ -n "$check" ]] || { usage >&2; fail 'The --check option is required.'; }
[[ "$promotion_run_id" =~ ^[1-9][0-9]*$ ]] || fail 'Promotion run ID must be a positive integer.'
[[ "$release_sha" =~ ^[0-9a-f]{40}$ ]] ||
  fail 'Release SHA must be a full 40-character commit SHA.'

require_file "$control_path"
require_file "$validator_path"
for command_name in gh python; do
  require_command "$command_name"
done

grep -Eq '"implementationSession"[[:space:]]*:[[:space:]]*"12-cicd-promotion-controls"' "$control_path" ||
  fail 'Control definition has the wrong implementationSession marker.'

repository="$(json_get "$control_path" 'repository.owner')/$(json_get "$control_path" 'repository.name')"
workflow_path="$(json_get "$control_path" 'repository.workflowPath')"
if [[ "$check" == 'blocked' ]]; then
  "$validator_path" --mode blocked --release-sha "$release_sha"
fi

gh api "repos/$repository/actions/runs/$promotion_run_id" >"$run_json"
gh api "repos/$repository/actions/runs/$promotion_run_id/jobs?per_page=100" >"$jobs_json"
python - "$check" "$run_json" "$jobs_json" "$workflow_path" "$release_sha" <<'PY'
import json
import sys
from pathlib import Path

check = sys.argv[1]
run = json.loads(Path(sys.argv[2]).read_text())
jobs = json.loads(Path(sys.argv[3]).read_text()).get('jobs', [])
workflow_path = sys.argv[4]
release_sha = sys.argv[5]

validation_name = (
    'Validate release and gate evaluation (candidate)'
    if check == 'intended'
    else 'Validate release and gate evaluation (generated-blocked-tool-process-self-test)'
)
validation_job = next((job for job in jobs if job.get('name') == validation_name), None)
expected_run_name = f'Controlled AI release {release_sha} (' + (
    'candidate' if check == 'intended' else 'generated-blocked-tool-process-self-test'
) + ')'
nonproduction_preview_job = next((job for job in jobs if job.get('name') == 'Preview nonproduction'), None)
nonproduction_job = next((job for job in jobs if job.get('name') == 'Approve and deploy nonproduction'), None)
production_preview_job = next((job for job in jobs if job.get('name') == 'Preview production'), None)
production_job = next((job for job in jobs if job.get('name') == 'Approve and deploy production'), None)

if run.get('path') != workflow_path or run.get('display_title') != expected_run_name or run.get('event') != 'workflow_dispatch':
    raise SystemExit('The workflow run does not match the approved workflow path, approved release input, or dispatch event.')

if check == 'intended':
    if run.get('status') != 'completed' or run.get('conclusion') != 'success':
        raise SystemExit('The intended workflow run did not complete successfully.')
    gate_step = next((step for step in validation_job.get('steps', []) if step.get('name') == 'Apply evaluation and adversarial gates before deployment'), None)
    if gate_step is None or gate_step.get('conclusion') != 'success':
        raise SystemExit('The intended workflow did not complete the external evaluation and security gate step.')
    if any(job is None or job.get('conclusion') != 'success' for job in (validation_job, nonproduction_preview_job, nonproduction_job, production_preview_job, production_job)):
        raise SystemExit('The intended workflow run did not complete the nonproduction gate successfully.')
    print('PASS: the immutable release passed temporary external evaluation and security gates, nonproduction, and protected production. GitHub retains workflow and deployment metadata; the approved release store retains the restore record.')
else:
    if validation_job is None:
        raise SystemExit('The blocked workflow run does not identify the generated Session 09 self-test input.')
    gate_step = next((step for step in validation_job.get('steps', []) if step.get('name') == 'Apply evaluation and adversarial gates before deployment'), None)
    failed_before_gate = [
        step for step in validation_job.get('steps', [])
        if gate_step is not None and step.get('number', 0) < gate_step.get('number', 0) and step.get('conclusion') != 'success'
    ]
    if validation_job.get('conclusion') != 'failure' or gate_step is None or gate_step.get('conclusion') != 'failure' or failed_before_gate:
        raise SystemExit('The blocked workflow run must fail in the predeployment gate job.')
    for job in (nonproduction_preview_job, nonproduction_job, production_preview_job, production_job):
        if job is not None and job.get('conclusion') not in ('', 'skipped', 'cancelled', None):
            raise SystemExit('An Azure preview, approval, or deployment was reached by the blocked run.')
    if run.get('status') != 'completed' or run.get('conclusion') != 'failure':
        raise SystemExit('Blocked workflow run must complete with failure.')
    print('PASS: the generated blocked-tool-process self-test stopped promotion before Azure preview, approval, or deployment.')
PY
