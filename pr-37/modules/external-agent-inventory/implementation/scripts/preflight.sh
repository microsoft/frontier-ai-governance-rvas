#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  preflight.sh --target-scope one-approved-external-agent [--decision-file PATH]

Checks the approved target scope, the recorded onboarding route, the runtime-owned
source reference, the connected-platform credential decision, and the retirement plan
in onboarding-decision.json before any Agent 365 change.
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

target_scope=""
decision_file=""
while (($# > 0)); do
  case "$1" in
    --target-scope)
      [[ $# -ge 2 ]] || fail "--target-scope requires a value."
      target_scope=$2
      shift 2
      ;;
    --decision-file)
      [[ $# -ge 2 ]] || fail "--decision-file requires a value."
      decision_file=$2
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

for command in python3 grep; do
  command -v "$command" >/dev/null 2>&1 || fail "$command is required."
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact_root=$(cd -- "$script_dir/../artifacts" && pwd)
[[ -d "$artifact_root" ]] || fail "The module artifacts folder is missing: $artifact_root"
[[ -n "$decision_file" ]] || decision_file="$artifact_root/onboarding-decision.json"
[[ -f "$decision_file" ]] || fail "The onboarding decision record is missing: $decision_file"

[[ "$target_scope" == "one-approved-external-agent" ]] ||
  fail "--target-scope must be one-approved-external-agent."

# Every decision below must be resolved in the record before the platform change.
required_sentinels=(
  "__REQUIRED_AGENT_365_ADMINISTRATOR_ROLE__"
  "__REQUIRED_AGENT_OWNER_ROLE__"
  "__REQUIRED_CREDENTIAL_GRANTED_SCOPE__"
  "__REQUIRED_CREDENTIAL_ISSUING_OWNER_ROLE__"
  "__REQUIRED_CREDENTIAL_REVOCATION_PATH__"
  "__REQUIRED_CREDENTIAL_ROTATION_OWNER_ROLE__"
  "__REQUIRED_CREDENTIAL_STORAGE_LOCATION__"
  "__REQUIRED_DELETE_CAPABILITY_DECISION__"
  "__REQUIRED_INTEGRATION_PATH__"
  "__REQUIRED_REGISTRY_SYNC_PLATFORM__"
  "__REQUIRED_RETIREMENT_COORDINATOR_ROLE__"
  "__REQUIRED_RETIREMENT_PLAN_REFERENCE__"
  "__REQUIRED_RUNTIME_OWNER_ROLE__"
  "__REQUIRED_RUNTIME_SOURCE_REFERENCE__"
)

mapfile -t unresolved < <(
  grep -h -o -E '__REQUIRED_[A-Z0-9_]+__' "$decision_file" | sort -u || true
)
if ((${#unresolved[@]} > 0)); then
  for sentinel in "${unresolved[@]}"; do
    known=false
    for required in "${required_sentinels[@]}"; do
      [[ "$required" != "$sentinel" ]] || known=true
    done
    $known || fail "Add an explicit preflight check for the new decision: $sentinel"
  done
  printf 'Unresolved decision: %s\n' "${unresolved[@]}" >&2
  fail "Resolve every onboarding decision before the Agent 365 change."
fi

python3 - "$decision_file" "$target_scope" <<'PY'
import json
import re
import sys

decision_path, target_scope = sys.argv[1:]
with open(decision_path, encoding="utf-8") as handle:
    decision = json.load(handle)

SUPPORTED_PLATFORMS = {
    "Amazon Bedrock",
    "Anthropic Claude Managed Agents",
    "Databricks Genie",
    "Google Vertex AI",
    "Oracle Generative AI Agents",
    "Salesforce Agentforce",
}
REQUIRED_RETIREMENT_ACTIONS = {
    "block-user-access",
    "revoke-connected-platform-credential",
    "remove-agent-registry-record",
    "retire-source-runtime",
    "preserve-required-audit-records",
}
SECRET_MARKER = re.compile(
    r"(?i)(secret|password|token|api[-_ ]?key|access[-_ ]?key|consumer[-_ ]?key)\s*[:=]"
)


def stop(message):
    raise SystemExit(f"ERROR: {message}")


def text(section, field):
    value = decision.get(section, {}).get(field)
    if not isinstance(value, str) or not value.strip():
        stop(f"{section}.{field} must be a non-empty string.")
    return value.strip()


if decision.get("implementationSession") != "optional-module-external-agent-inventory":
    stop("The decision record has the wrong implementationSession marker.")
if decision.get("targetScope") != "one-approved-external-agent":
    stop("targetScope must be one-approved-external-agent.")
if decision.get("targetScope") != target_scope:
    stop("targetScope does not match the approved target scope passed to preflight.")

integration_path = text("onboarding", "integrationPath")
if integration_path not in {"built-in", "registry-sync", "sdk"}:
    stop("onboarding.integrationPath must be built-in, registry-sync, or sdk.")

source_reference = text("onboarding", "runtimeSourceReference")
if not re.match(r"(?i)^https?://", source_reference):
    stop("onboarding.runtimeSourceReference must be an absolute HTTP or HTTPS URL.")
authority = re.split(r"[/?#]", source_reference.split("://", 1)[1], maxsplit=1)[0]
if not authority:
    stop("onboarding.runtimeSourceReference must name a host.")
if "@" in authority:
    stop("onboarding.runtimeSourceReference must not contain embedded credentials.")

for role in ("agent365Administrator", "runtimeOwner", "agentOwner", "retirementCoordinator"):
    if text("owners", role).upper() == "N/A":
        stop(f"owners.{role} must name a role that can act on the live system.")

credential_fields = (
    "issuingOwner",
    "grantedScope",
    "deleteCapabilityDecision",
    "storageLocation",
    "rotationAndRevocationOwner",
    "revocationPath",
)
registry_platform = text("onboarding", "registrySyncPlatform")
if integration_path == "registry-sync":
    if registry_platform not in SUPPORTED_PLATFORMS:
        stop("onboarding.registrySyncPlatform is not a supported connected platform.")
    values = {field: text("connectedPlatformCredential", field) for field in credential_fields}
    for field, value in values.items():
        if value.upper() == "N/A":
            stop(f"connectedPlatformCredential.{field} is required for Registry sync.")
    if values["deleteCapabilityDecision"] != "accepted-by-retirement-coordinator":
        stop(
            "The retirement coordinator must accept that the connection credential can delete "
            "agents on the external platform: set deleteCapabilityDecision to "
            "accepted-by-retirement-coordinator."
        )
    storage = values["storageLocation"]
    if storage.startswith((".", "/", "\\")) or re.match(r"^[A-Za-z]:[\\/]", storage):
        stop("connectedPlatformCredential.storageLocation must name a managed secret store, not a file path.")
    if "implementation/artifacts" in storage.replace("\\", "/"):
        stop("The connection credential must never live in this repository.")
    for field in ("grantedScope", "storageLocation", "revocationPath"):
        if SECRET_MARKER.search(values[field]):
            stop(f"connectedPlatformCredential.{field} looks like credential material; record a reference instead.")
else:
    if registry_platform.upper() != "N/A":
        stop("onboarding.registrySyncPlatform applies only to the registry-sync route; use N/A.")
    for field in credential_fields:
        if text("connectedPlatformCredential", field).upper() != "N/A":
            stop(f"connectedPlatformCredential.{field} applies only to the registry-sync route; use N/A.")

retirement = decision.get("retirementCoordination", {})
plan_reference = text("retirementCoordination", "planReference")
if plan_reference.upper() == "N/A":
    stop("retirementCoordination.planReference must link the approved cross-platform retirement plan.")
actions = set(retirement.get("requiredActions") or [])
missing = sorted(REQUIRED_RETIREMENT_ACTIONS - actions)
if missing:
    stop("The retirement plan must cover: " + ", ".join(missing))
PY

echo "PASS: the onboarding route, source reference, credential decision, and retirement plan are recorded."
echo "NOTE: a read-only deployment preview is unsupported; Agent 365 onboarding runs through the selected platform or runtime change path."
