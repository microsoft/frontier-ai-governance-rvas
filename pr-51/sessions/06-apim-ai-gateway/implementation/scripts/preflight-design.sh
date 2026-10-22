#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  preflight.sh [--design-record-path PATH]

Checks the Session 06 gateway design record. This command does not sign in to Azure
or change Azure resources.
EOF
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
design_record_path="$script_dir/../artifacts/gateway-design-record.json"

while (($# > 0)); do
  case "$1" in
    --design-record-path)
      [[ $# -ge 2 ]] || { echo "ERROR: --design-record-path requires a value." >&2; exit 2; }
      design_record_path=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

command -v python3 >/dev/null 2>&1 || {
  echo "ERROR: python3 is required to inspect the JSON design record." >&2
  exit 1
}
[[ -f "$design_record_path" ]] || {
  echo "ERROR: The gateway design record is missing: $design_record_path" >&2
  exit 1
}

python3 - "$design_record_path" <<'PY'
import json
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
raw = path.read_text(encoding="utf-8")
try:
    record = json.loads(raw)
except json.JSONDecodeError as error:
    raise SystemExit(f"ERROR: The gateway design record must be valid JSON: {error}")

unresolved = sorted(set(re.findall(r"_{2}REQUIRED_[A-Z0-9_]+_{2}", raw)))
if unresolved:
    raise SystemExit("ERROR: Resolve every required gateway design decision before sharing this record.")

if record.get("recordVersion") != 1:
    raise SystemExit("ERROR: gateway-design-record.json must use recordVersion 1.")
approved_target_scope = str(record.get("approvedImplementationScope", {}).get("scopeReference", "")).strip()
if not approved_target_scope:
    raise SystemExit("ERROR: The approved target scope must be recorded before the design is shared.")
if record.get("recordStatus") not in {"approved-with-gaps", "ready-for-implementation"}:
    raise SystemExit(
        "ERROR: recordStatus must be approved-with-gaps or ready-for-implementation."
    )

paths = [
    ("approvedImplementationScope", "scopeReference"),
    ("approvedImplementationScope", "environment"),
    ("approvedImplementationScope", "changeReference"),
    ("apiManagement", "instanceName"),
    ("apiManagement", "tier"),
    ("apiManagement", "deploymentModel"),
    ("targetBackend", "type"),
    ("targetBackend", "implementationVariant"),
    ("targetBackend", "endpointReference"),
    ("ingress", "pattern"),
    ("ingress", "clientIdentity"),
    ("ingress", "backendIdentity"),
    ("ingress", "backendRoleState"),
    ("network", "inboundPath"),
    ("network", "backendPath"),
    ("network", "privateDnsState"),
    ("contentSafety", "decision"),
    ("contentSafety", "backendReference"),
    ("telemetry", "sink"),
    ("telemetry", "bodyCapturePolicy"),
    ("controls", "requestLimit"),
    ("controls", "tokenLimitDecision"),
    ("controls", "safetyPolicy"),
    ("controls", "routingDecision"),
    ("controls", "restoreDecision"),
    ("owners", "apiProduct"),
    ("owners", "identity"),
    ("owners", "network"),
    ("owners", "safety"),
    ("owners", "operations"),
    ("owners", "delivery"),
    ("approval", "designApprover"),
    ("approval", "approvalReference"),
]
if any(not str(record.get(section, {}).get(field, "")).strip() for section, field in paths):
    raise SystemExit("ERROR: The gateway design record has an empty required decision.")

gaps = record.get("readinessGaps")
if not isinstance(gaps, list) or not gaps:
    raise SystemExit(
        "ERROR: Record an explicit readiness-gaps entry, including 'none' when no gap remains."
    )
for gap in gaps:
    if gap.get("status") not in {"open", "resolved", "not-applicable"}:
        raise SystemExit(
            "ERROR: Each readiness gap must use open, resolved, or not-applicable status."
        )
    if any(not str(gap.get(field, "")).strip() for field in ("id", "description", "owner", "resolution")):
        raise SystemExit(
            "ERROR: Each readiness gap must identify its ID, description, owner, and resolution."
        )
open_gaps = [gap for gap in gaps if gap["status"] == "open"]
if record["recordStatus"] == "ready-for-implementation" and open_gaps:
    raise SystemExit(
        "ERROR: A record with open readiness gaps cannot be ready-for-implementation."
    )
if record["recordStatus"] == "approved-with-gaps" and not open_gaps:
    raise SystemExit("ERROR: approved-with-gaps requires at least one open readiness gap.")

print("PASS: Session 06 gateway design record is complete and its readiness state is inspectable. No Azure resources were changed.")
PY
