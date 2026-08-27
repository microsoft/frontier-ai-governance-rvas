#!/usr/bin/env python3
"""Run implementation-file manifest and table validator fixtures."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path


FIXTURE_ROOT = Path(__file__).resolve().parent
SKILL_ROOT = FIXTURE_ROOT.parents[1]


def load_validator():
    path = SKILL_ROOT / "scripts" / "validate_session.py"
    spec = importlib.util.spec_from_file_location("validate_session", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load validator: {path}")
    validator = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(validator)
    return validator


def main() -> int:
    validator = load_validator()
    fixtures = json.loads((FIXTURE_ROOT / "retained-files.json").read_text(encoding="utf-8"))

    for case in fixtures["manifestCases"]:
        failures: list[str] = []
        manifest = {}
        if "retainedFiles" in case:
            manifest["retained_files"] = case["retainedFiles"]
        validator.validate_retained_file_manifest(
            manifest,
            case["leaveBehind"],
            failures,
        )
        if failures != case["expectedFailures"]:
            raise AssertionError(
                f"{case['name']}: expected {case['expectedFailures']!r}, got {failures!r}"
            )

    for case in fixtures["tableCases"]:
        failures = []
        validator.validate_retained_file_table(
            case["table"],
            set(case["implementationFiles"]),
            case["retainedMetadata"],
            failures,
        )
        if failures != case["expectedFailures"]:
            raise AssertionError(
                f"{case['name']}: expected {case['expectedFailures']!r}, got {failures!r}"
            )

    print(
        f"Passed {len(fixtures['manifestCases'])} manifest and "
        f"{len(fixtures['tableCases'])} table fixtures."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
