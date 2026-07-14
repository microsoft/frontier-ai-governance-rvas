#!/usr/bin/env python3
"""Offline S6 reconciliation smoke test.

Loads the shipped sample registry and S1 inventory, runs the reconciliation core,
and asserts the invariants expected by the capstone lab.
"""
from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path
from types import ModuleType

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "reconcile-registry.py"
REGISTRY = ROOT / "data" / "agent-registry.sample.json"
INVENTORY = ROOT / "data" / "s1-agent-inventory.sample.json"
LIFECYCLE_STATES = ROOT / "policies" / "lifecycle-states.json"


def load_reconcile_module() -> ModuleType:
    spec = importlib.util.spec_from_file_location("reconcile_registry", SCRIPT)
    if spec is None or spec.loader is None:
        raise SystemExit(f"FAIL: could not import {SCRIPT}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def main() -> int:
    module = load_reconcile_module()
    registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    inventory = json.loads(INVENTORY.read_text(encoding="utf-8"))
    lifecycle_policy = json.loads(LIFECYCLE_STATES.read_text(encoding="utf-8"))
    allowed_states = {item["name"] for item in lifecycle_policy["states"]}
    for agent in registry["agents"]:
        state = agent.get("lifecycleState")
        if state is not None and state not in allowed_states:
            fail(f"sample registry has lifecycle state outside policy: {state}")

    report = module.reconcile(registry, inventory, {state.casefold() for state in allowed_states})
    summary = report.get("summary", {})

    if summary.get("matchedCount", 0) < 1:
        fail("expected at least one registry/inventory match")
    if summary.get("shadowAgentCount", 0) < 1:
        fail("expected at least one shadow agent")
    if summary.get("unmanagedOrOboCount", 0) < 1:
        fail("expected at least one unmanaged/OBO finding")
    if summary.get("missingSponsorCount", 0) < 1:
        fail("expected at least one missing-sponsor finding")

    json.dumps(report)
    print("PASS: S6 sample reconciliation detects matched, shadow, unmanaged/OBO, and missing-sponsor findings.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
