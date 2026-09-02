#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
target_scope=""

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

while (($# > 0)); do
  case "$1" in
    --target-scope)
      (($# >= 2)) || fail "--target-scope requires a value."
      target_scope=$2
      shift 2
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$target_scope" ]] || fail "--target-scope is required."
command -v python3 >/dev/null 2>&1 || fail "python3 is required."

standard_path="$artifact_root/portfolio-standard.json"
decision_path="$artifact_root/portfolio-decision.json"
model_path="$artifact_root/governance/operating-model.md"
for path in "$standard_path" "$decision_path" "$model_path"; do
  [[ -f "$path" ]] || fail "Required module artifact is missing: $path"
done

covered_sentinels=(
  __REQUIRED_AGENT_IDENTITY_REFERENCE__
  __REQUIRED_AGENT_INVENTORY_REFERENCE__
  __REQUIRED_AGENT_TYPE__
  __REQUIRED_API_CATALOG_REFERENCE__
  __REQUIRED_APPROVED_PORTFOLIO_SCOPE__
  __REQUIRED_BUSINESS_SPONSOR_ROLE__
  __REQUIRED_DUPLICATE_DECISION_OWNER_ROLE__
  __REQUIRED_DUPLICATE_INVENTORY_REFERENCE__
  __REQUIRED_DUPLICATE_REVIEW_DECISION__
  __REQUIRED_FRAMEWORK_DECISION__
  __REQUIRED_GATEWAY_POLICY_REFERENCE__
  __REQUIRED_LIFECYCLE_APPROVAL_REFERENCE__
  __REQUIRED_PORTFOLIO_OWNER_ROLE__
  __REQUIRED_RELEASE_OWNER_ROLE__
  __REQUIRED_REQUESTED_LIFECYCLE_STATE__
  __REQUIRED_RETIREMENT_COORDINATOR_ROLE__
  __REQUIRED_RETIREMENT_PLAN_REFERENCE__
  __REQUIRED_SOURCE_PLATFORM__
  __REQUIRED_SOURCE_PLATFORM_REFERENCE__
)
mapfile -t unresolved < <(grep -R -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$artifact_root" | sort -u || true)
for sentinel in "${unresolved[@]}"; do
  [[ " ${covered_sentinels[*]} " == *" $sentinel "* ]] ||
    fail "Preflight does not cover new required field: $sentinel"
done
((${#unresolved[@]} == 0)) || fail "Resolve every portfolio decision before review: ${unresolved[*]}"

python3 - "$standard_path" "$decision_path" "$model_path" "$target_scope" <<'PY'
import json
import re
import sys

standard_path, decision_path, model_path, target_scope = sys.argv[1:]
with open(standard_path, encoding="utf-8") as handle:
    standard = json.load(handle)
with open(decision_path, encoding="utf-8") as handle:
    decision = json.load(handle)
with open(model_path, encoding="utf-8") as handle:
    operating_model = handle.read()

marker = "enterprise-agent-portfolio-standards"
for item in (standard, decision):
    if item.get("implementationModule") != marker or item.get("implementationSession") != marker:
        raise SystemExit("An artifact has the wrong implementation marker.")

if standard.get("approvedPortfolioScope") != target_scope:
    raise SystemExit("Target scope must match portfolio-standard.json.")
if decision.get("portfolioScope") != target_scope:
    raise SystemExit("Target scope must match portfolio-decision.json.")

references = decision.get("authoritativeReferences", {})
expected_systems = {
    "agentInventory": "Microsoft Agent 365",
    "apiAndToolCatalog": "Azure API Center",
    "agentIdentity": "Microsoft Entra ID",
    "gatewayPolicy": "Azure API Management",
}
for name, system in expected_systems.items():
    reference = references.get(name, {})
    if reference.get("system") != system or not reference.get("recordReference"):
        raise SystemExit(f"The {name} authoritative reference is incomplete or uses the wrong system.")

source = references.get("sourcePlatform", {})
if source.get("system") not in standard["architectureDecisions"]["allowedSourcePlatforms"]:
    raise SystemExit("The source platform is outside the approved standard.")
if not source.get("recordReference"):
    raise SystemExit("The source-platform reference is missing.")

if decision.get("classificationDecision", {}).get("agentType") not in standard["classification"]["allowedTypes"]:
    raise SystemExit("The agent classification is outside the approved taxonomy.")

framework = decision.get("frameworkDecision", {})
if framework.get("selectedPath") not in standard["architectureDecisions"]["approvedFrameworks"]:
    raise SystemExit("The framework decision is outside the approved standard.")
if framework.get("selectedPath") == "other-by-exception" and framework.get("exceptionApprovalReference") == "N/A":
    raise SystemExit("Another framework needs an approved exception reference.")

owners = decision.get("owners", {})
missing_roles = sorted(role for role in standard["ownership"]["requiredRoles"] if not owners.get(role))
if missing_roles:
    raise SystemExit(f"The portfolio decision is missing required owner roles: {missing_roles}")

lifecycle = decision.get("lifecycleDecision", {})
transition = f"{lifecycle.get('currentState')}:{lifecycle.get('requestedState')}"
if transition not in standard["lifecycle"]["allowedTransitions"]:
    raise SystemExit(f"Lifecycle transition is not approved: {transition}")

duplicate = decision.get("duplicateDecision", {})
if duplicate.get("possibleMatchesReviewed") is not True:
    raise SystemExit("The duplicate review must inspect possible matches.")
if duplicate.get("decision") not in {"new-capability", "reuse-existing", "approved-overlap"}:
    raise SystemExit("The duplicate decision is incomplete.")

retirement = decision.get("retirementCoordination", {})
if retirement.get("crossPlatformPlanConfirmed") is not True or not retirement.get("planReference"):
    raise SystemExit("Cross-platform retirement coordination is incomplete.")

text = json.dumps(decision) + operating_model
if re.search(r"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b", text, re.I):
    raise SystemExit("Use role aliases, not personal email addresses.")
PY

echo "PASS: Portfolio decisions are complete for '$target_scope'."
