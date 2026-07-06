#!/usr/bin/env python3
"""Mock-target validation for S2 Microsoft Purview policy exports.

Statically asserts the audit-first safety invariants WITHOUT touching any tenant:

  * DLP mode is simulation/test only
  * DLP rules do not block or restrict access
  * DSPM baseline remains audit-only
  * JSON is well-formed and placeholders are warnings, not failures

Exit code 0 = safe; non-zero = a safety invariant is violated.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
POLICY_DIR = ROOT / "policies"
DLP_POLICY = POLICY_DIR / "dlp-ai-simulation.json"
DSPM_POLICY = POLICY_DIR / "dspm-ai-baseline.json"
SIMULATION_MODES = {"TestWithoutNotifications", "TestWithNotifications", "Simulation", "Test"}


def fail(msg: str) -> None:
    print(f"FAIL: {msg}")
    raise SystemExit(1)


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        fail(f"policy not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def warn_placeholders(path: Path, data: dict[str, Any]) -> None:
    encoded = json.dumps(data, sort_keys=True)
    if "REPLACE-WITH" in encoded:
        print(f"WARN: {path.name} contains placeholders — customer must fill tenant-specific IDs before live use.")


def validate_dlp(data: dict[str, Any]) -> None:
    mode = data.get("mode")
    if mode not in SIMULATION_MODES:
        fail(f"DLP mode must be simulation/test, got {mode!r}")

    if data.get("workload") != "AI":
        fail(f"DLP workload must be 'AI', got {data.get('workload')!r}")

    rules = data.get("rules") or []
    if not rules:
        fail("DLP policy must contain at least one rule")

    for rule in rules:
        actions = rule.get("actions") or {}
        if actions.get("blockAccess") is True or actions.get("restrictAccess") is True:
            fail(f"rule {rule.get('name')!r} must not block or restrict access in simulation")
        conditions = rule.get("conditions") or {}
        if not conditions.get("contentContainsSensitiveInformation"):
            fail(f"rule {rule.get('name')!r} must include sensitive information conditions")


def validate_dspm(data: dict[str, Any]) -> None:
    if data.get("state") != "AuditOnly":
        fail(f"DSPM baseline state must be 'AuditOnly', got {data.get('state')!r}")
    signals = data.get("scanScope", {}).get("sensitiveDataSignals") or []
    required = {"SensitiveDataInPrompts", "OversharedFiles", "PotentialExfiltration"}
    missing = required.difference(signals)
    if missing:
        fail(f"DSPM baseline missing signals: {sorted(missing)}")


def main() -> int:
    dlp = load_json(DLP_POLICY)
    dspm = load_json(DSPM_POLICY)

    validate_dlp(dlp)
    validate_dspm(dspm)
    warn_placeholders(DLP_POLICY, dlp)
    warn_placeholders(DSPM_POLICY, dspm)

    for path in sorted(POLICY_DIR.glob("*.json")):
        load_json(path)

    print("PASS: S2 Purview policy exports satisfy simulation/test + audit-only invariants (static).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
