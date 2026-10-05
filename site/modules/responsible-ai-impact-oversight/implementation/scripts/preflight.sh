#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/preflight.sh --target-scope one-approved-foundry-agent [--artifact-root PATH]

Checks responsible-AI inventory, impact, transparency, and oversight artifacts before runtime deployment.
USAGE
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
artifact_root="$(cd -- "$script_dir/../artifacts" && pwd)"
target_scope=""
required_target_scope="one-approved-foundry-agent"

while (($# > 0)); do
  case "$1" in
    --target-scope)
      (($# >= 2)) || fail "--target-scope requires a value."
      target_scope="$2"
      shift 2
      ;;
    --artifact-root)
      (($# >= 2)) || fail "--artifact-root requires a value."
      artifact_root="$2"
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

[[ "$target_scope" == "$required_target_scope" ]] || fail "--target-scope must be $required_target_scope."
command -v python3 >/dev/null 2>&1 || fail "python3 is required."
[[ -d "$artifact_root" ]] || fail "Artifact root is missing: $artifact_root"

required_files=(
  "records/ai-system-inventory-entry.schema.json"
  "records/ai-system-inventory-entry.json"
  "records/impact-assessment.md"
  "records/transparency-note.md"
  "oversight/oversight-decision.json"
  "runtime/foundry_human_approval_gate.py"
  "runtime/requirements.txt"
)
for relative in "${required_files[@]}"; do
  [[ -f "$artifact_root/$relative" ]] || fail "Required module artifact is missing: $relative"
done

required_sentinels=(
  "__REQUIRED_AFFECTED_GROUPS__"
  "__REQUIRED_AI_ACT_RISK_CLASS__"
  "__REQUIRED_AI_ACT_ROLE__"
  "__REQUIRED_AI_SYSTEM_ID__"
  "__REQUIRED_AI_SYSTEM_NAME__"
  "__REQUIRED_ANNEX_III_AREA__"
  "__REQUIRED_APPROVAL_RECORD_STORE__"
  "__REQUIRED_APPROVAL_SLA__"
  "__REQUIRED_APPROVER_ROLE__"
  "__REQUIRED_APPROVER_APP_ROLE_OR_GROUP__"
  "__REQUIRED_ARTICLE_50_OBLIGATIONS__"
  "__REQUIRED_ARTICLE_5_REVIEWER_ROLE__"
  "__REQUIRED_ARTICLE_5_SCREENING_OUTCOME__"
  "__REQUIRED_ASSESSMENT_OWNER_ROLE__"
  "__REQUIRED_BENEFITS_AND_HARMS__"
  "__REQUIRED_BUSINESS_UNIT__"
  "__REQUIRED_CHANGE_REVIEW_CADENCE__"
  "__REQUIRED_CONSEQUENTIAL_TOOL_NAME__"
  "__REQUIRED_DATA_CATEGORIES__"
  "__REQUIRED_DECISION_RETENTION__"
  "__REQUIRED_DISCLOSURE_TEXT__"
  "__REQUIRED_EVALUATION_SUMMARY__"
  "__REQUIRED_FOUNDRY_AGENT_REFERENCE__"
  "__REQUIRED_FOUNDRY_PROJECT_REFERENCE__"
  "__REQUIRED_AGENT_VERSION_REFERENCE__"
  "__REQUIRED_INTENDED_USE__"
  "__REQUIRED_LIMITATIONS__"
  "__REQUIRED_MISUSE_RISKS__"
  "__REQUIRED_MONITORING_ROUTE__"
  "__REQUIRED_PRODUCT_OWNER_ROLE__"
  "__REQUIRED_RAI_CHAMPION_ROLE__"
  "__REQUIRED_REVIEW_DATE__"
  "__REQUIRED_RISK_MITIGATIONS__"
  "__REQUIRED_ROLE_OF_HUMANS__"
  "__REQUIRED_SIGN_OFF_ROLES__"
  "__REQUIRED_STOP_MECHANISM__"
  "__REQUIRED_TECHNICAL_OWNER_ROLE__"
  "__REQUIRED_TOOL_ACTION_CLASS__"
  "__REQUIRED_TOOL_EXECUTION_ROUTE_REFERENCE__"
  "__REQUIRED_UPSTREAM_NOTES__"
  "__REQUIRED_USE_CASE_SUMMARY__"
  "__REQUIRED_USER_NOTICE_CHANNEL__"
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
  fail "Resolve every responsible AI oversight decision before runtime deployment: ${unresolved[*]}"
fi

python3 - "$artifact_root" "$target_scope" <<'PY'
import json
import sys
from pathlib import Path

artifact_root = Path(sys.argv[1]).resolve()
target_scope = sys.argv[2]
marker = "optional-module-responsible-ai-impact-oversight"

def fail(message: str) -> None:
    raise SystemExit(message)

def read_json(relative: str) -> dict:
    path = artifact_root / relative
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        fail(f"{relative} is not valid JSON: {error}")

schema = read_json("records/ai-system-inventory-entry.schema.json")
inventory = read_json("records/ai-system-inventory-entry.json")
oversight = read_json("oversight/oversight-decision.json")
impact = (artifact_root / "records/impact-assessment.md").read_text(encoding="utf-8")
transparency = (artifact_root / "records/transparency-note.md").read_text(encoding="utf-8")

if schema.get("title") != "Responsible AI system inventory entry":
    fail("Inventory schema title is unexpected.")
for record in (inventory, oversight):
    if record.get("implementationSession") != marker:
        fail("An artifact has the wrong implementationSession marker.")
    if record.get("targetScope") != target_scope:
        fail("Target scope must match both artifact scope values.")

roles = {"provider", "deployer", "provider-and-deployer", "distributor-importer", "downstream-provider"}
risk_classes = {
    "prohibited",
    "high-risk-annex-I",
    "high-risk-annex-III",
    "annex-III-exempt-art-6-3",
    "transparency-art-50",
    "gpai-based-system",
    "minimal",
}
annex_areas = {
    "biometrics",
    "critical-infrastructure",
    "education",
    "employment",
    "essential-services",
    "law-enforcement",
    "migration",
    "justice-democracy",
    "n/a",
}
article50 = {
    "interaction-disclosure",
    "synthetic-content-marking",
    "emotion-biometric-notice",
    "deepfake-label",
    "ai-text-public-interest-label",
    "none",
}
eu = inventory.get("euAiAct", {})
if eu.get("role") not in roles:
    fail("euAiAct.role is not an allowed value.")
if eu.get("riskClass") not in risk_classes:
    fail("euAiAct.riskClass is not an allowed value.")
if eu.get("riskClass") == "prohibited":
    fail("The module must stop for a prohibited AI Act risk class.")
if eu.get("annexIIIArea") not in annex_areas:
    fail("euAiAct.annexIIIArea is not an allowed value.")
screening = eu.get("article5Screening", {})
if screening.get("outcome") not in {"passed", "flagged-resolved", "blocked"}:
    fail("article5Screening.outcome is not an allowed value.")
if screening.get("outcome") == "blocked":
    fail("The module must stop because the Article 5 screening outcome is blocked.")
obligations = eu.get("article50Obligations", [])
if not obligations:
    fail("article50Obligations must contain at least one value.")
if any(item not in article50 for item in obligations):
    fail("article50Obligations contains an unsupported value.")
if len(obligations) > 1 and "none" in obligations:
    fail("article50Obligations cannot combine none with another value.")

tool = oversight.get("gatedTool", {})
if oversight.get("approvalPattern") != "foundry-hosted-agent-pause-resume":
    fail("approvalPattern must be foundry-hosted-agent-pause-resume.")
if tool.get("actionClass") not in {"write", "irreversible"}:
    fail("gatedTool.actionClass must be write or irreversible.")
if tool.get("approvalMode") != "always_require":
    fail("gatedTool.approvalMode must be always_require.")
if tool.get("rejectionBehavior") != "do-not-execute-tool":
    fail("Rejected calls must not execute the tool.")
authentication = oversight.get("authentication", {})
if authentication.get("principalSource") != "app-service-authentication-headers":
    fail("Approver identity must come from App Service authentication headers.")
if sorted(authentication.get("requiredHeaders", [])) != [
    "X-MS-CLIENT-PRINCIPAL",
    "X-MS-CLIENT-PRINCIPAL-ID",
    "X-MS-CLIENT-PRINCIPAL-NAME",
]:
    fail("requiredHeaders must contain X-MS-CLIENT-PRINCIPAL, X-MS-CLIENT-PRINCIPAL-ID, and X-MS-CLIENT-PRINCIPAL-NAME.")
approver_claim = authentication.get("approverClaim", {})
if approver_claim.get("claimType") not in {"roles", "groups"}:
    fail("approverClaim.claimType must be roles or groups.")
if not str(approver_claim.get("claimValue", "")).strip():
    fail("approverClaim.claimValue must name the approved app role or group claim value.")
if oversight.get("records", {}).get("pendingRequestStore") != "in-memory-nonproduction":
    fail("pendingRequestStore must record the nonproduction in-memory boundary for this module.")
verification = oversight.get("verification", {})
if verification.get("approvedDecision") != "approved-executed":
    fail("approvedDecision must remain approved-executed.")
if verification.get("rejectedDecision") != "rejected-not-executed":
    fail("rejectedDecision must remain rejected-not-executed.")
if "# Responsible AI impact assessment" not in impact:
    fail("Impact assessment record must keep its expected heading.")
if "# System transparency note" not in transparency:
    fail("Transparency note record must keep its expected heading.")
PY

echo "PASS: responsible AI records are complete for scope '$target_scope'."
echo "previewSupported=false. Foundry hosted-agent approval code and documentation records have no read-only deployment preview; use this preflight plus the deployed approved and rejected path checks."
