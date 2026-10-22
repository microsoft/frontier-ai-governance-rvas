#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
target_scope=""
resource_group=""

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
    --resource-group)
      (($# >= 2)) || fail "--resource-group requires a value."
      resource_group=$2
      shift 2
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$target_scope" ]] || fail "--target-scope is required."
[[ -n "$resource_group" ]] || fail "--resource-group is required."
command -v python3 >/dev/null 2>&1 || fail "python3 is required."
command -v az >/dev/null 2>&1 || fail "The Azure CLI is required."

register_path="$artifact_root/model-approval-register.json"
template_path="$artifact_root/policy/model-governance.bicep"
parameter_path="$artifact_root/policy/model-governance.bicepparam"
for required in "$register_path" "$template_path" "$parameter_path"; do
  [[ -f "$required" ]] || fail "Required Session 03 policy artifact is missing: $required"
done

required_sentinels=(
  "__REQUIRED_APPROVED_DATA_CLASSIFICATION__"
  "__REQUIRED_APPROVED_DEPLOYMENT_TYPE__"
  "__REQUIRED_APPROVED_MODEL_ASSET_ID__"
  "__REQUIRED_APPROVED_POLICY_SCOPE_ALIAS__"
  "__REQUIRED_APPROVED_PROCESSING_LOCATION__"
  "__REQUIRED_APPROVED_PUBLISHER_NAME__"
  "__REQUIRED_APPROVED_USE_CASE_BOUNDARY__"
  "__REQUIRED_DATA_OWNER_ROLE__"
  "__REQUIRED_EVALUATION_REFERENCE__"
  "__REQUIRED_MODEL_REVIEW_DATE__"
  "__REQUIRED_PLATFORM_OWNER_ROLE__"
  "__REQUIRED_PREVIOUS_ASSIGNMENT_REFERENCE__"
  "__REQUIRED_REGISTER_REVIEW_DATE__"
  "__REQUIRED_SECURITY_OWNER_ROLE__"
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
  fail "Resolve every model approval decision before assigning policy: ${unresolved[*]}"
fi

[[ -n "${RVAS_APPROVED_MODELS_POLICY_ID:-}" ]] || fail \
  "Set RVAS_APPROVED_MODELS_POLICY_ID to the built-in approved-models policy definition ID."
[[ -n "${RVAS_MODEL_ELIGIBILITY_POLICY_ID:-}" ]] || fail \
  "Set RVAS_MODEL_ELIGIBILITY_POLICY_ID to the built-in eligibility policy definition ID."

python3 - "$register_path" "$target_scope" <<'PY'
import json
import re
import sys

register_path, target_scope = sys.argv[1:]
with open(register_path, encoding="utf-8") as handle:
    register = json.load(handle)

if register.get("implementationSession") != "03-model-governance-lifecycle":
    raise SystemExit("The register has the wrong implementationSession marker.")
if register.get("approvedScope") != target_scope:
    raise SystemExit("The register scope must match --target-scope.")

effect = register.get("assignmentEffect")
if effect not in {"Audit", "Deny"}:
    raise SystemExit("assignmentEffect must be Audit or Deny.")

eligibility = register.get("eligibility", {})
for name in ("onlyAllowDirectFromAzure", "denyPreviewModels"):
    if not isinstance(eligibility.get(name), bool):
        raise SystemExit(f"eligibility.{name} must be true or false.")

models = register.get("approvedModels", [])
if not models:
    raise SystemExit("The register must contain at least one approved model.")

asset_pattern = re.compile(r"^azureml://registries/[^/]+/models/[^/]+/(?:versions/[^/]+)?$")
required_fields = (
    "assetId",
    "publisher",
    "sourceCategory",
    "lifecycleStatus",
    "hostingRoute",
    "processingLocation",
    "useCaseBoundary",
    "dataClassificationCeiling",
    "evaluationReference",
    "reviewDate",
)
allowed_sources = {"SoldByAzure", "PartnersAndCommunity"}
allowed_lifecycle = {"GenerallyAvailable", "Preview"}

for model in models:
    for field in required_fields:
        if not str(model.get(field, "")).strip():
            raise SystemExit(f"Approved model entry is missing {field}.")
    if model["sourceCategory"] not in allowed_sources:
        raise SystemExit("sourceCategory must be SoldByAzure or PartnersAndCommunity.")
    if model["lifecycleStatus"] not in allowed_lifecycle:
        raise SystemExit("lifecycleStatus must be GenerallyAvailable or Preview.")
    if not asset_pattern.fullmatch(model["assetId"]):
        raise SystemExit(
            "Each assetId must be a registry model ID ending in a trailing slash or an explicit "
            f"version, so prefix matching cannot allow a longer model name: {model['assetId']}"
        )
    if not model.get("approvedDeploymentTypes"):
        raise SystemExit(f"Record the approved deployment types for {model['assetId']}.")
    approvers = model.get("approvers", {})
    for role in ("platformOwner", "securityOwner", "dataOwner"):
        if not str(approvers.get(role, "")).strip():
            raise SystemExit(f"Record the {role} who approved {model['assetId']}.")

    if eligibility["onlyAllowDirectFromAzure"] and model["sourceCategory"] != "SoldByAzure":
        raise SystemExit(
            "onlyAllowDirectFromAzure is true, so the policy denies "
            f"{model['assetId']} even though the register approves it."
        )
    if eligibility["denyPreviewModels"] and model["lifecycleStatus"] == "Preview":
        raise SystemExit(
            "denyPreviewModels is true, so the policy denies "
            f"{model['assetId']} even though the register approves it."
        )

register_assets = sorted({model["assetId"] for model in models})
register_publishers = sorted({model["publisher"] for model in models})
if sorted(set(register.get("allowedAssetIds", []))) != register_assets:
    raise SystemExit("allowedAssetIds must contain exactly the approved model asset IDs.")
if sorted(set(register.get("allowedPublishers", []))) != register_publishers:
    raise SystemExit("allowedPublishers must contain exactly the approved model publishers.")

print(f"Register holds {len(models)} approved model(s) with effect {effect}.")
PY

echo "Previewing the policy assignment deployment in resource group '$resource_group'..."
az deployment group what-if \
  --resource-group "$resource_group" \
  --template-file "$template_path" \
  --parameters "$parameter_path"

echo "PASS: The model approval register and policy assignment preview are ready for scope '$target_scope'."
echo "Review the what-if output before deploying, then keep the effect at Audit until compliance is reviewed."
