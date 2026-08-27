#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --approved-tenant-id TENANT_ID
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "$1 is required."
}

get_graph_token() {
  local token
  if token=$(az account get-access-token --tenant "$approved_tenant_id" --resource-type ms-graph --query accessToken --output tsv --only-show-errors 2>/dev/null); then
    [[ -n "$token" ]] && { printf '%s' "$token"; return 0; }
  fi
  if token=$(az account get-access-token --tenant "$approved_tenant_id" --scope https://graph.microsoft.com/.default --query accessToken --output tsv --only-show-errors 2>/dev/null); then
    [[ -n "$token" ]] && { printf '%s' "$token"; return 0; }
  fi
  fail 'Unable to acquire a Microsoft Graph token for the approved tenant.'
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
coverage_path="$artifact_root/governance/coverage-handoff.md"
audit_path="$artifact_root/operations/agent-activity-audit-query.json"
required_sentinels=(
  "__REQUIRED_AGENT365_LICENSE_STATUS__"
  "__REQUIRED_AGENT_INSTANCE_ALIAS__"
  "__REQUIRED_AGENT_INSTANCE_ID__"
  "__REQUIRED_AGENT_LABEL_RIGHTS_STATUS__"
  "__REQUIRED_AGENT_OWNER_ROLE__"
  "__REQUIRED_AUDIT_ENTITLEMENT__"
  "__REQUIRED_AUDIT_OWNER_ROLE__"
  "__REQUIRED_COVERAGE_REVIEW_DATE__"
  "__REQUIRED_DATA_CLASSIFICATION__"
  "__REQUIRED_DATA_OWNER_ROLE__"
  "__REQUIRED_DLP_ACTION__"
  "__REQUIRED_DLP_ENTITLEMENT__"
  "__REQUIRED_DLP_INCIDENT_OWNER_ROLE__"
  "__REQUIRED_DLP_NAME_AVAILABILITY_STATUS__"
  "__REQUIRED_DLP_NAME_VERIFIED_DATE__"
  "__REQUIRED_DLP_NOTIFICATION_DECISION__"
  "__REQUIRED_DLP_POLICY_NAME__"
  "__REQUIRED_DLP_PROPAGATION_HOURS__"
  "__REQUIRED_DSPM_ENTITLEMENT__"
  "__REQUIRED_E5_STATUS__"
  "__REQUIRED_EDISCOVERY_ENTITLEMENT__"
  "__REQUIRED_FINDINGS_DATE__"
  "__REQUIRED_FOUNDRY_AUDIT_STATUS__"
  "__REQUIRED_FOUNDRY_ENABLEMENT_ROUTE__"
  "__REQUIRED_FOUNDRY_PURVIEW_STATUS__"
  "__REQUIRED_FOUNDRY_SUBSCRIPTION_ALIAS__"
  "__REQUIRED_FOUNDRY_USER_CONTEXT_STATUS__"
  "__REQUIRED_GENERATED_CONTENT_COMPENSATING_CONTROL__"
  "__REQUIRED_GENERATED_CONTENT_DECISION__"
  "__REQUIRED_GENERATED_CONTENT_LABEL_OBSERVATION__"
  "__REQUIRED_GENERATED_CONTENT_SUMMARY__"
  "__REQUIRED_INFORMATION_PROTECTION_OWNER_ROLE__"
  "__REQUIRED_LABELLED_SYNTHETIC_ITEM_ALIAS__"
  "__REQUIRED_LABEL_ENCRYPTION_DECISION__"
  "__REQUIRED_LABEL_IDENTITY_STATUS__"
  "__REQUIRED_LABEL_IDENTITY_VERIFIED_DATE__"
  "__REQUIRED_LABEL_POLICY_SCOPE_ALIAS__"
  "__REQUIRED_OVERSHARING_DECISION__"
  "__REQUIRED_OVERSHARING_SUMMARY__"
  "__REQUIRED_PURVIEW_OPERATOR_ROLE__"
  "__REQUIRED_PURVIEW_PAYG_STATUS__"
  "__REQUIRED_SENSITIVE_GROUNDING_DECISION__"
  "__REQUIRED_SENSITIVE_GROUNDING_SUMMARY__"
  "__REQUIRED_SENSITIVITY_LABEL_ID__"
  "__REQUIRED_SENSITIVITY_LABEL_NAME__"
  "__REQUIRED_SHAREPOINT_LABEL_SUPPORT_STATUS__"
  "__REQUIRED_SOURCE_EXPIRY_DATE__"
  "__REQUIRED_SOURCE_REVIEW_DATE__"
  "__REQUIRED_SYNTHETIC_SOURCE_ALIAS__"
  "__REQUIRED_TEST_GROUP_ALIAS__"
)

approved_tenant_id=""
while (($# > 0)); do
  case "$1" in
    --approved-tenant-id)
      [[ $# -ge 2 ]] || fail '--approved-tenant-id requires a value.'
      approved_tenant_id=$2
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
[[ -n "$approved_tenant_id" ]] || fail '--approved-tenant-id is required.'

require_command az
require_command python3

for path in "$coverage_path" "$audit_path"; do
  [[ -f "$path" ]] || fail "Required implementation artifact is missing: $path"
done

mapfile -t unresolved_sentinels < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved_sentinels[@]} > 0)); then
  unknown=()
  for sentinel in "${unresolved_sentinels[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      if [[ "$required" == "$sentinel" ]]; then
        known=true
        break
      fi
    done
    $known || unknown+=("$sentinel")
  done
  if ((${#unknown[@]} > 0)); then
    fail "Add explicit Session 10 preflight checks for new sentinels: ${unknown[*]}"
  fi
  locations=$(grep -R -n -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u)
  fail "Resolve every required customer decision before tenant changes:\n$locations"
fi

python3 - "$coverage_path" "$audit_path" <<'PY'
import datetime
import json
import re
import sys

coverage_text = open(sys.argv[1], encoding='utf-8').read()
audit = json.load(open(sys.argv[2], encoding='utf-8'))
marker = '10-purview-data-governance'
required_operations = ['AIInvokeAgent', 'AIExecuteTool', 'AIInferenceCall', 'AIGuardrail']
required_output_fields = ['CreationDate', 'Operation', 'AgentId', 'AgentName', 'ResultStatus']

def markdown_lines(markdown):
    visible = []
    in_comment = False
    fence_character = None
    fence_length = 0
    html_tag_pattern = re.compile(
        r'<(?:/?[A-Za-z][A-Za-z0-9:_-]*(?:\s+[^<>]*?)?\s*/?|![A-Za-z][^<>]*|\?[A-Za-z][^<>]*)>'
    )
    for raw_line in markdown.splitlines():
        if fence_character is not None:
            closing = re.fullmatch(r'\s{0,3}(`{3,}|~{3,})\s*', raw_line)
            if (
                closing
                and closing.group(1)[0] == fence_character
                and len(closing.group(1)) >= fence_length
            ):
                fence_character = None
            continue

        line = ''
        remaining = raw_line
        while remaining:
            if in_comment:
                comment_end = remaining.find('-->')
                if comment_end < 0:
                    remaining = ''
                    continue
                in_comment = False
                remaining = remaining[comment_end + 3:]
                continue
            comment_start = remaining.find('<!--')
            if comment_start < 0:
                line += remaining
                remaining = ''
                continue
            line += remaining[:comment_start]
            remaining = remaining[comment_start + 4:]
            in_comment = True

        opening = re.match(r'^\s{0,3}(`{3,}|~{3,}).*$', line)
        if opening:
            marker = opening.group(1)
            fence_character = marker[0]
            fence_length = len(marker)
            continue
        if html_tag_pattern.search(line):
            raise SystemExit('coverage-handoff.md contains raw HTML outside fenced code.')
        visible.append(line)

    if fence_character is not None:
        raise SystemExit('coverage-handoff.md contains an unclosed fenced code block.')
    if html_tag_pattern.search('\n'.join(visible)):
        raise SystemExit('coverage-handoff.md contains raw HTML outside fenced code.')
    return visible

def section(lines, heading):
    indexes = [index for index, line in enumerate(lines) if line.strip() == heading]
    if not indexes:
        raise SystemExit(f"coverage-handoff.md is missing heading '{heading}'.")
    if len(indexes) > 1:
        raise SystemExit(f"coverage-handoff.md contains duplicate heading '{heading}'.")
    start = indexes[0] + 1
    end = next(
        (
            index
            for index in range(start, len(lines))
            if re.match(r'^#{1,6}\s+', lines[index].strip())
        ),
        len(lines),
    )
    return lines[start:end]

def field(lines, name, heading):
    headers = (
        ('Capability', 'Status')
        if heading == '## Purview entitlements'
        else ('Field', 'Decision')
    )
    header = re.compile(
        rf'^\|\s*{re.escape(headers[0])}\s*\|\s*{re.escape(headers[1])}\s*\|\s*$'
    )
    separator = re.compile(r'^\|\s*:?-{3,}:?\s*\|\s*:?-{3,}:?\s*\|\s*$')
    pattern = re.compile(rf'^\|\s*{re.escape(name)}\s*\|\s*(.*?)\s*\|\s*$')
    matches = []
    for index in range(len(lines) - 1):
        if not header.fullmatch(lines[index]) or not separator.fullmatch(lines[index + 1]):
            continue
        for row in lines[index + 2:]:
            if not re.fullmatch(r'\|.*\|\s*', row):
                break
            if match := pattern.fullmatch(row):
                matches.append(match.group(1).strip())
    if not matches:
        raise SystemExit(f"coverage-handoff.md section '{heading}' is missing field '{name}'.")
    if len(matches) > 1:
        raise SystemExit(f"coverage-handoff.md section '{heading}' contains duplicate field '{name}'.")
    value = matches[0]
    if len(value) >= 2 and value[0] == value[-1] == '`':
        value = value[1:-1].strip()
    if not value:
        raise SystemExit(f"coverage-handoff.md field '{name}' in section '{heading}' is empty.")
    return value

def expect(lines, name, expected, heading):
    value = field(lines, name, heading)
    if value != expected:
        raise SystemExit(
            f"coverage-handoff.md field '{name}' in section '{heading}' must be '{expected}', not '{value}'."
        )
    return value

def iso_date(lines, name, heading):
    value = field(lines, name, heading)
    try:
        datetime.date.fromisoformat(value)
    except ValueError as error:
        raise SystemExit(
            f"coverage-handoff.md field '{name}' in section '{heading}' must be a real yyyy-mm-dd date."
        ) from error
    return value

summary_heading = '# Purview coverage handoff'
verification_heading = '## Verification boundary'
agent_heading = '### Microsoft Agent 365'
foundry_heading = '### Microsoft Foundry'
entitlements_heading = '## Purview entitlements'
label_heading = '## Sensitivity label'
source_heading = '## Source access'
dlp_heading = '## DLP policy'

coverage_lines = markdown_lines(coverage_text)
summary = section(coverage_lines, summary_heading)
verification = section(coverage_lines, verification_heading)
agent = section(coverage_lines, agent_heading)
foundry = section(coverage_lines, foundry_heading)
entitlements = section(coverage_lines, entitlements_heading)
label = section(coverage_lines, label_heading)
source = section(coverage_lines, source_heading)
dlp = section(coverage_lines, dlp_heading)

expect(summary, 'Target scope', 'Approved nonproduction Microsoft 365 tenant', summary_heading)
expect(agent, 'Qualifying license', 'Confirmed', agent_heading)
if field(agent, 'E5 prerequisite', agent_heading) not in {'Confirmed', 'ExceptionApproved'}:
    raise SystemExit('The E5 prerequisite must be Confirmed or ExceptionApproved.')
expect(foundry, 'Purview Data Security status', 'Enabled', foundry_heading)
if field(foundry, 'Enablement route', foundry_heading) not in {'FoundryControlPlane', 'DefenderForCloud'}:
    raise SystemExit('The Foundry enablement route must be FoundryControlPlane or DefenderForCloud.')
expect(foundry, 'Pay-as-you-go policy billing', 'Approved', foundry_heading)
expect(foundry, 'Audit license status', 'Confirmed', foundry_heading)
if field(foundry, 'User context status', foundry_heading) not in {'Implemented', 'DocumentedGap'}:
    raise SystemExit('The Foundry user context status must be Implemented or DocumentedGap.')
for entitlement in ('DSPM', 'Data Loss Prevention', 'Audit', 'eDiscovery'):
    expect(entitlements, entitlement, 'Confirmed', entitlements_heading)

label_id = field(label, 'Label ID', label_heading)
if not re.fullmatch(r'[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}', label_id):
    raise SystemExit('The sensitivity label ID must be a GUID.')
expect(label, 'SharePoint and OneDrive label support', 'Enabled', label_heading)
encryption = field(label, 'Encryption decision', label_heading)
if encryption not in {'Encrypted', 'NotEncrypted'}:
    raise SystemExit('The label encryption decision must be Encrypted or NotEncrypted.')
rights = field(label, 'Agent instance VIEW and EXTRACT rights', label_heading)
if encryption == 'Encrypted' and rights != 'Confirmed':
    raise SystemExit('An encrypted label requires Confirmed VIEW and EXTRACT rights.')
if encryption == 'NotEncrypted' and rights not in {'Confirmed', 'NotApplicable'}:
    raise SystemExit('A non-encrypted label requires VIEW and EXTRACT rights to be Confirmed or NotApplicable.')
expect(label, 'Generated content inherits the source label', 'No', label_heading)
field(label, 'Generated-content observation', label_heading)
field(label, 'Compensating control', label_heading)

expect(verification, 'Label identity status', 'Confirmed', verification_heading)
iso_date(verification, 'Label identity verified on', verification_heading)
expect(verification, 'DLP policy name availability status', 'Available', verification_heading)
iso_date(verification, 'DLP policy name verified on', verification_heading)

expect(source, 'Synthetic only', 'Yes', source_heading)
agent_alias = field(agent, 'Agent instance alias', agent_heading)
source_agent_alias = field(source, 'Agent instance alias', source_heading)
dlp_agent_alias = field(dlp, 'Agent instance alias', dlp_heading)
if agent_alias != source_agent_alias or agent_alias != dlp_agent_alias:
    raise SystemExit(
        'The Microsoft Agent 365, Source access, and DLP policy sections must use the same agent instance alias.'
    )
if field(source, 'Sensitivity label ID', source_heading) != label_id:
    raise SystemExit('The source and sensitivity-label sections must use the same label ID.')

expect(dlp, 'Environment', 'Nonproduction', dlp_heading)
expect(dlp, 'Description', f'implementationSession={marker}', dlp_heading)
expect(dlp, 'Initial mode', 'TestWithNotifications', dlp_heading)
expect(dlp, 'Final mode', 'Enable', dlp_heading)
if field(dlp, 'Action', dlp_heading) not in {'Block', 'Audit'}:
    raise SystemExit('The DLP action must be Block or Audit.')
propagation_text = field(dlp, 'Propagation allowance in hours', dlp_heading)
if not re.fullmatch(r'\d+', propagation_text) or not 1 <= int(propagation_text) <= 24:
    raise SystemExit('The DLP propagation allowance must be an integer from 1 through 24 hours.')
directions = [item.strip() for item in field(dlp, 'Supported interaction directions', dlp_heading).split(';')]
if directions != ['Human-to-agent', 'agent-to-human']:
    raise SystemExit('The DLP policy must retain both supported interaction directions.')
locations = [item.strip() for item in field(dlp, 'Supported locations', dlp_heading).split(';')]
if locations != ['Microsoft Teams', 'OneDrive or SharePoint', 'Exchange email']:
    raise SystemExit('The DLP policy must retain exactly the three documented locations.')
if field(dlp, 'Rule label ID', dlp_heading) != label_id:
    raise SystemExit('The DLP rule and sensitivity-label sections must use the same label ID.')
dlp_agent_instance_id = field(dlp, 'Agent instance ID', dlp_heading)
field(dlp, 'Policy name', dlp_heading)

if (
    audit.get('schemaVersion') != 1
    or audit.get('implementationSession') != marker
    or audit.get('microsoftGraphApplicationPermission') != 'AuditLogsQuery.Read.All'
    or audit.get('agentInstanceId') != dlp_agent_instance_id
    or not str(audit.get('ownerRole', '')).strip()
    or sorted(audit.get('operations', [])) != sorted(required_operations)
):
    raise SystemExit('The audit query structure, DLP agent instance binding, or required Agent 365 operations are invalid.')
if sorted(audit.get('safeOutputFields', [])) != sorted(required_output_fields):
    raise SystemExit('The audit query must keep the approved payload-free output fields.')
if not audit.get('excludedContent'):
    raise SystemExit('The audit query must name the content excluded from its output.')
lookback = audit.get('lookbackHours')
if type(lookback) is not int or not 1 <= lookback <= 168:
    raise SystemExit('Audit lookbackHours must be between 1 and 168.')
PY

graph_token=$(get_graph_token)
python3 - "$graph_token" "$approved_tenant_id" <<'PY'
import base64
import json
import sys
parts = sys.argv[1].split('.')
if len(parts) != 3:
    raise SystemExit('The Microsoft Graph token is not a JWT.')
payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=' * (-len(parts[1]) % 4)))
if 'AuditLogsQuery.Read.All' not in payload.get('roles', []):
    raise SystemExit('The Microsoft Graph application token must include AuditLogsQuery.Read.All with administrator consent.')
if str(payload.get('tid', '')).lower() != sys.argv[2].lower():
    raise SystemExit('The Microsoft Graph application token does not identify the approved tenant.')
PY

echo 'PASS: Session 10 Markdown safety decisions, DLP and audit bindings, approved tenant, and AuditLogsQuery.Read.All token are ready.'
