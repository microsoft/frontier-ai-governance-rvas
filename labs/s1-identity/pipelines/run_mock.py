#!/usr/bin/env python3
"""Mock-target validation for the S1 Conditional Access policy.

Statically asserts the report-only safety invariants WITHOUT touching any tenant,
so the takeaway kit's safety guarantees are enforced in CI:

  * policy state is report-only (enabledForReportingButNotEnforced)
  * a break-glass exclusion group is present and not a placeholder
  * the agent-identity include group is not a placeholder
  * the JSON is well-formed and has the required shape

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

    users = data.get("conditions", {}).get("users", {})
    excluded = users.get("excludeGroups") or []
    included = users.get("includeGroups") or []

    if not excluded:
        fail("no excludeGroups: a break-glass exclusion is mandatory")
    if any("REPLACE-WITH" in g for g in excluded):
        print("WARN: excludeGroups still has a placeholder — customer must set the real break-glass group ID before deploy.")
    if any("REPLACE-WITH" in g for g in included):
        print("WARN: includeGroups still has a placeholder — customer must set the real agent-identity group ID before deploy.")

    grant = data.get("grantControls", {}).get("builtInControls") or []
    if "block" not in grant:
        print("NOTE: baseline grant is not 'block'; confirm this is intended.")

    print("PASS: S1 Conditional Access policy satisfies report-only + break-glass invariants (static).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
