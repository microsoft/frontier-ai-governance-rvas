#!/usr/bin/env python3
"""Static validation for the S3 Security Posture & Runtime kit.

No network calls are made. The check enforces audit-first defaults, valid JSON,
and script references needed for the live customer runbook.
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POLICIES = ROOT / "policies"
SCRIPTS = ROOT / "scripts"


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"invalid JSON in {path}: {exc}")


def require_text(path: Path, expected: str) -> None:
    text = path.read_text(encoding="utf-8")
    if expected not in text:
        fail(f"{path} must contain {expected!r}")


def validate_policies() -> None:
    baseline = load_json(POLICIES / "content-safety-runtime-baseline.json")
    if baseline.get("mode") != "audit-first":
        fail("Content Safety baseline must stay audit-first")

    shields = baseline.get("promptShields", {})
    if shields.get("directAttackDetection") != "enabled":
        fail("direct Prompt Shield detection must be enabled")
    if shields.get("indirectAttackDetection") != "enabled":
        fail("indirect Prompt Shield detection must be enabled")
    if shields.get("action") != "record-result-only":
        fail("Prompt Shield action must be record-result-only")

    template = load_json(POLICIES / "defender-ai-assessment-export-template.json")
    if not template.get("findings"):
        fail("Defender assessment template must include a findings array")


def validate_scripts() -> None:
    require_text(SCRIPTS / "export_defender_ai_recommendations.sh", "az graph query")
    print("PASS: Track A (Defender) script references Azure Resource Graph.")
    require_text(SCRIPTS / "test_prompt_shield.sh", "shieldPrompt")
    require_text(SCRIPTS / "test_prompt_shield.sh", "Authorization=Bearer $TOKEN")
    print("PASS: Track B (Citadel) script uses the acquired bearer token.")


def main() -> int:
    validate_policies()
    validate_scripts()
    print("PASS: S3 kit satisfies static audit-first invariants.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
