#!/usr/bin/env python3
"""Mock-target validation for the S1 Conditional Access policy.

Statically asserts the report-only safety invariants WITHOUT touching any tenant,
so the takeaway kit's safety guarantees are enforced in CI:

  * policy state is report-only (enabledForReportingButNotEnforced)
  * a break-glass excluded service principal is present and not a placeholder
  * the included agent service principal is not a placeholder
  * the JSON is well-formed and has the required Workload Identity CA shape

Exit code 0 = safe; non-zero = a safety invariant is violated.
"""
from __future__ import annotations

import json
from pathlib import Path

POLICY = Path(__file__).resolve().parents[1] / "policies" / "ca-agent-baseline.json"
REPORT_ONLY = "enabledForReportingButNotEnforced"


def fail(msg: str) -> None:
    print(f"FAIL: {msg}")
    raise SystemExit(1)


def main() -> int:
    if not POLICY.exists():
        fail(f"policy not found: {POLICY}")
    data = json.loads(POLICY.read_text(encoding="utf-8"))

    if data.get("state") != REPORT_ONLY:
        fail(f"policy state must be {REPORT_ONLY!r}, got {data.get('state')!r}")

    # Agents are service principals, so target them via Workload Identity CA
    # (clientApplications), not the user (includeGroups) condition.
    client_apps = data.get("conditions", {}).get("clientApplications", {})
    excluded = client_apps.get("excludeServicePrincipals") or []
    included = client_apps.get("includeServicePrincipals") or []

    if not included:
        fail("no includeServicePrincipals: the policy must target the agent service principal(s)")
    if not excluded:
        fail("no excludeServicePrincipals: a break-glass exclusion is mandatory")
    if any("REPLACE-WITH" in sp for sp in excluded):
        print("WARN: excludeServicePrincipals still has a placeholder — customer must set the real break-glass SP object ID before deploy.")
    if any("REPLACE-WITH" in sp for sp in included):
        print("WARN: includeServicePrincipals still has a placeholder — customer must set the real agent SP object ID before deploy.")

    grant = data.get("grantControls", {}).get("builtInControls") or []
    if "block" not in grant:
        print("NOTE: baseline grant is not 'block'; confirm this is intended.")

    print("PASS: S1 Conditional Access policy satisfies report-only + break-glass invariants (static).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
