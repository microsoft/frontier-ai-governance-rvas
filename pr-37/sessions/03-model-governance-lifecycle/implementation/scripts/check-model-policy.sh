#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
resource_group=""
approved_models_assignment="rvas-mod-approved-models"
eligibility_assignment="rvas-mod-model-eligibility"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

while (($# > 0)); do
  case "$1" in
    --resource-group)
      (($# >= 2)) || fail "--resource-group requires a value."
      resource_group=$2
      shift 2
      ;;
    --approved-models-assignment)
      (($# >= 2)) || fail "--approved-models-assignment requires a value."
      approved_models_assignment=$2
      shift 2
      ;;
    --eligibility-assignment)
      (($# >= 2)) || fail "--eligibility-assignment requires a value."
      eligibility_assignment=$2
      shift 2
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$resource_group" ]] || fail "--resource-group is required."
command -v az >/dev/null 2>&1 || fail "The Azure CLI is required."
command -v python3 >/dev/null 2>&1 || fail "python3 is required."

scope=$(az group show --name "$resource_group" --query id --output tsv)
APPROVED_ASSIGNMENT_JSON=$(az policy assignment show --name "$approved_models_assignment" --scope "$scope" --output json)
ELIGIBILITY_ASSIGNMENT_JSON=$(az policy assignment show --name "$eligibility_assignment" --scope "$scope" --output json)
export APPROVED_ASSIGNMENT_JSON ELIGIBILITY_ASSIGNMENT_JSON

python3 - "$artifact_root/model-approval-register.json" <<'PY'
import json
import os
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    register = json.load(handle)

approved = json.loads(os.environ["APPROVED_ASSIGNMENT_JSON"])
eligibility = json.loads(os.environ["ELIGIBILITY_ASSIGNMENT_JSON"])


def value(assignment, name):
    return (assignment.get("parameters") or {}).get(name, {}).get("value")


problems = []
if value(approved, "effect") != register["assignmentEffect"]:
    problems.append("The approved-models effect does not match the register.")
if value(eligibility, "effect") != register["assignmentEffect"]:
    problems.append("The eligibility effect does not match the register.")
if sorted(value(approved, "allowedAssetIds") or []) != sorted(register["allowedAssetIds"]):
    problems.append("The live allowed asset IDs do not match the register.")
if sorted(value(approved, "allowedPublishers") or []) != sorted(register["allowedPublishers"]):
    problems.append("The live allowed publishers do not match the register.")
for toggle in ("onlyAllowDirectFromAzure", "denyPreviewModels"):
    if value(eligibility, toggle) != register["eligibility"][toggle]:
        problems.append(f"The live {toggle} value does not match the register.")

if problems:
    raise SystemExit("FAIL: " + " ".join(problems))

print(
    f"PASS: Both assignments use effect {register['assignmentEffect']} with "
    f"{len(register['allowedAssetIds'])} approved model asset ID(s) and "
    f"{len(register['allowedPublishers'])} approved publisher(s) from the register."
)
PY
