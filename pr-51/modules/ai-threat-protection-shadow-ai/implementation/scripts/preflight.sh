#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh \
    --target-scope <scope-alias> \
    --target-subscription-id <subscription-id> \
    --sentinel-resource-group-name <resource-group> \
    --sentinel-workspace-name <workspace> \
    --deployment-location <azure-region>

Checks artifacts, unresolved decisions, approved scope, Bicep syntax, and read-only deployment
previews for the AI threat protection and shadow AI module.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

target_scope=""
target_subscription_id=""
sentinel_resource_group_name=""
sentinel_workspace_name=""
deployment_location=""

while (($# > 0)); do
  case "$1" in
    --target-scope)
      (($# >= 2)) || fail "--target-scope requires a value."
      target_scope=$2
      shift 2
      ;;
    --target-subscription-id)
      (($# >= 2)) || fail "--target-subscription-id requires a value."
      target_subscription_id=$2
      shift 2
      ;;
    --sentinel-resource-group-name)
      (($# >= 2)) || fail "--sentinel-resource-group-name requires a value."
      sentinel_resource_group_name=$2
      shift 2
      ;;
    --sentinel-workspace-name)
      (($# >= 2)) || fail "--sentinel-workspace-name requires a value."
      sentinel_workspace_name=$2
      shift 2
      ;;
    --deployment-location)
      (($# >= 2)) || fail "--deployment-location requires a value."
      deployment_location=$2
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
[[ -n "$target_subscription_id" ]] || fail "--target-subscription-id is required."
[[ -n "$sentinel_resource_group_name" ]] || fail "--sentinel-resource-group-name is required."
[[ -n "$sentinel_workspace_name" ]] || fail "--sentinel-workspace-name is required."
[[ -n "$deployment_location" ]] || fail "--deployment-location is required."

command -v grep >/dev/null 2>&1 || fail "grep is required."
command -v python3 >/dev/null 2>&1 || fail "python3 is required."

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
artifact_root="$(cd -- "$script_dir/../artifacts" && pwd -P)"
implementation_session="optional-module-ai-threat-protection-shadow-ai"

defender_template="$artifact_root/defender/defender-ai-plan.bicep"
defender_params="$artifact_root/defender/defender-ai-plan.bicepparam"
defender_decisions="$artifact_root/defender/defender-ai-plan-decisions.json"
defender_alert_query="$artifact_root/defender/defender-ai-alerts.kql"
sentinel_template="$artifact_root/sentinel/copilot-threat-detections.bicep"
sentinel_params="$artifact_root/sentinel/copilot-threat-detections.bicepparam"
jailbreak_query="$artifact_root/sentinel/copilot-jailbreak-analytics.kql"
external_ip_query="$artifact_root/sentinel/copilot-external-ip-hunting.kql"
shadow_decisions="$artifact_root/shadow-ai/shadow-ai-sanction-decisions.json"

required_files=(
  "$defender_template"
  "$defender_params"
  "$defender_decisions"
  "$defender_alert_query"
  "$sentinel_template"
  "$sentinel_params"
  "$jailbreak_query"
  "$external_ip_query"
  "$shadow_decisions"
)
for path in "${required_files[@]}"; do
  [[ -f "$path" ]] || fail "Required implementation artifact is missing: $path"
done

required_sentinels=(
  "__REQUIRED_AI_PLATFORM_OWNER__"
  "__REQUIRED_BLOCKING_OWNER__"
  "__REQUIRED_DEFENDER_FOR_CLOUD_OWNER__"
  "__REQUIRED_DEFENDER_PLAN_RESTORE_REFERENCE__"
  "__REQUIRED_DEFENDER_XDR_QUEUE_OWNER__"
  "__REQUIRED_GENERATIVE_AI_APP_NAME__"
  "__REQUIRED_PRIVACY_OWNER__"
  "__REQUIRED_PROMPT_EVIDENCE_PRIVACY_DECISION_REFERENCE__"
  "__REQUIRED_PROMPT_EVIDENCE_TRUE_OR_FALSE__"
  "__REQUIRED_PURVIEW_SHARING_TRUE_OR_FALSE__"
  "__REQUIRED_RISK_REVIEW_REFERENCE__"
  "__REQUIRED_SANCTION_OR_UNSANCTION__"
  "__REQUIRED_SANCTION_TAG__"
  "__REQUIRED_SENTINEL_OWNER__"
  "__REQUIRED_SENTINEL_RESOURCE_GROUP_NAME__"
  "__REQUIRED_SENTINEL_WORKSPACE_NAME__"
  "__REQUIRED_SHADOW_AI_DISCOVERY_POLICY_NAME__"
  "__REQUIRED_SHADOW_AI_MONITORING_OWNER__"
  "__REQUIRED_SHADOW_AI_RESTORE_REFERENCE__"
  "__REQUIRED_SOC_RUNBOOK_REFERENCE__"
  "__REQUIRED_TARGET_SCOPE_ALIAS__"
)

mapfile -t unresolved < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
if ((${#unresolved[@]} > 0)); then
  unknown=()
  for sentinel in "${unresolved[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      if [[ "$sentinel" == "$required" ]]; then
        known=true
        break
      fi
    done
    $known || unknown+=("$sentinel")
  done
  ((${#unknown[@]} == 0)) || fail "Add explicit preflight coverage for new sentinels: ${unknown[*]}"
  fail "Resolve every AI threat protection and shadow AI decision before deployment: ${unresolved[*]}"
fi

python3 - \
  "$implementation_session" \
  "$target_scope" \
  "$sentinel_resource_group_name" \
  "$sentinel_workspace_name" \
  "$defender_decisions" \
  "$shadow_decisions" \
  "$defender_params" \
  "$sentinel_params" \
  "$defender_alert_query" \
  "$jailbreak_query" \
  "$external_ip_query" <<'PY'
import json
import re
import sys
from pathlib import Path

(
    implementation_session,
    target_scope,
    sentinel_resource_group_name,
    sentinel_workspace_name,
    defender_decisions_path,
    shadow_decisions_path,
    defender_params_path,
    sentinel_params_path,
    defender_alert_query_path,
    jailbreak_query_path,
    external_ip_query_path,
) = sys.argv[1:]


def stop(message: str) -> None:
    raise SystemExit(message)


def read_json(path: str) -> dict:
    with open(path, encoding="utf-8") as handle:
        return json.load(handle)


def read_text(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def bicep_param(path: str, name: str) -> str:
    pattern = re.compile(rf"^\s*param\s+{re.escape(name)}\s*=\s*'([^']*)'\s*$", re.MULTILINE)
    match = pattern.search(read_text(path))
    if not match:
        stop(f"Could not read string parameter {name} from {path}.")
    return match.group(1)


def require_marker(record: dict, label: str) -> None:
    if record.get("implementationSession") != implementation_session:
        stop(f"{label} must use implementationSession={implementation_session}.")


def canonical_boolean_string(value: object, label: str) -> str:
    if not isinstance(value, str):
        stop(f"{label} must be True or False.")
    normalized = value.strip().lower()
    if normalized not in {"true", "false"}:
        stop(f"{label} must be True or False.")
    return normalized


defender = read_json(defender_decisions_path)
shadow = read_json(shadow_decisions_path)
require_marker(defender, "defender-ai-plan-decisions.json")
require_marker(shadow, "shadow-ai-sanction-decisions.json")

if defender.get("targetScopeAlias") != target_scope or shadow.get("targetScopeAlias") != target_scope:
    stop("Target scope must match both decision records.")
plan = defender.get("defenderPlan", {})
if plan.get("pricingResourceName") != "AI" or plan.get("pricingTier") != "Standard":
    stop("The Defender plan decision must target Microsoft.Security/pricings name AI with Standard tier.")
decision_prompt_evidence = canonical_boolean_string(plan.get("promptEvidence"), "defenderPlan.promptEvidence")
decision_purview_sharing = canonical_boolean_string(plan.get("purviewSharing"), "defenderPlan.purviewSharing")
parameter_prompt_evidence = canonical_boolean_string(
    bicep_param(defender_params_path, "isAIPromptEvidenceEnabled"),
    "defender-ai-plan.bicepparam isAIPromptEvidenceEnabled",
)
parameter_purview_sharing = canonical_boolean_string(
    bicep_param(defender_params_path, "isAIPromptSharingWithPurviewEnabled"),
    "defender-ai-plan.bicepparam isAIPromptSharingWithPurviewEnabled",
)
if decision_prompt_evidence != parameter_prompt_evidence:
    stop("defenderPlan.promptEvidence must match defender-ai-plan.bicepparam isAIPromptEvidenceEnabled.")
if decision_purview_sharing != parameter_purview_sharing:
    stop("defenderPlan.purviewSharing must match defender-ai-plan.bicepparam isAIPromptSharingWithPurviewEnabled.")
soc = defender.get("socRouting", {})
if soc.get("sentinelWorkspaceName") != sentinel_workspace_name:
    stop("Sentinel workspace must match defender-ai-plan-decisions.json.")
if soc.get("sentinelResourceGroupName") != sentinel_resource_group_name:
    stop("Sentinel resource group must match defender-ai-plan-decisions.json.")

if shadow.get("changeMode") != "monitor-first" or shadow.get("category") != "Generative AI":
    stop("Shadow AI decisions must stay monitor-first for the Generative AI category.")
for decision in shadow.get("sanctionDecisions", []):
    if decision.get("enforcementMode") != "monitor":
        stop("Every shadow AI decision must start with enforcementMode=monitor.")
    if decision.get("decision") not in {"Sanction", "Unsanction", "sanction", "unsanction"}:
        stop("Each shadow AI decision must be Sanction or Unsanction.")
    if decision.get("tagToApply") not in {"Sanctioned", "Unsanctioned"}:
        stop("Each shadow AI tag must be Sanctioned or Unsanctioned.")

if bicep_param(defender_params_path, "targetScopeAlias") != target_scope:
    stop("defender-ai-plan.bicepparam must target the approved scope alias.")
if bicep_param(sentinel_params_path, "targetScopeAlias") != target_scope:
    stop("copilot-threat-detections.bicepparam must target the approved scope alias.")
if bicep_param(sentinel_params_path, "sentinelWorkspaceName") != sentinel_workspace_name:
    stop("copilot-threat-detections.bicepparam must target the approved Sentinel workspace.")

if "SecurityAlert" not in read_text(defender_alert_query_path):
    stop("The Defender AI alert query must inspect SecurityAlert.")
jailbreak_query = read_text(jailbreak_query_path)
if "CopilotActivity" not in jailbreak_query or "JailbreakDetected" not in jailbreak_query:
    stop("The Copilot jailbreak analytics query must inspect CopilotActivity and JailbreakDetected.")
if "SrcIpAddr" not in read_text(external_ip_query_path):
    stop("The Copilot external-IP hunting query must inspect SrcIpAddr.")
PY

command -v az >/dev/null 2>&1 || fail "Azure CLI is required for Bicep compilation and what-if previews."

az bicep build --file "$defender_template" --stdout >/dev/null
az bicep build-params --file "$defender_params" --stdout >/dev/null
az bicep build --file "$sentinel_template" --stdout >/dev/null
az bicep build-params --file "$sentinel_params" --stdout >/dev/null

current_subscription_id="$(az account show --query id --output tsv --only-show-errors)"
[[ "$current_subscription_id" == "$target_subscription_id" ]] ||
  fail "Azure CLI is not set to approved subscription '$target_subscription_id'."

echo "Preview 1 of 2: Defender for Cloud AI services plan at subscription $target_subscription_id"
az deployment sub what-if \
  --subscription "$target_subscription_id" \
  --location "$deployment_location" \
  --template-file "$defender_template" \
  --parameters "$defender_params" \
  --no-pretty-print \
  --only-show-errors

echo "Preview 2 of 2: Sentinel Copilot detections in $sentinel_resource_group_name/$sentinel_workspace_name"
az deployment group what-if \
  --subscription "$target_subscription_id" \
  --resource-group "$sentinel_resource_group_name" \
  --template-file "$sentinel_template" \
  --parameters "$sentinel_params" \
  --no-pretty-print \
  --only-show-errors

echo "PASS: artifact syntax, decision records, approved scope, and both read-only previews are ready."
