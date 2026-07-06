#!/usr/bin/env python3
"""Tier A reference runner for Microsoft Foundry AI Red Teaming Agent.

This script is intentionally import-guarded so static validation does not require
Azure packages. Run it only in the customer's environment, against the written-scope
non-production test endpoint, after SOC notification and authorization.
"""
from __future__ import annotations

import argparse
import asyncio
import json
from collections.abc import Callable, Coroutine
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT / "evidence" / "airt-asr-scorecard.json"

TargetCallback = Callable[[str], Coroutine[Any, Any, str]]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run a Tier A AI Red Teaming Agent scan.")
    parser.add_argument("--azure-ai-project", required=True, help="Azure AI Foundry project endpoint or connection string.")
    parser.add_argument("--target-endpoint", required=True, help="Authorized customer-owned non-production endpoint URL.")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="Path for the exported ASR scorecard JSON.")
    parser.add_argument("--max-risk-categories", type=int, default=4, help="Limit categories for an initial scoped run.")
    return parser.parse_args()


def load_redteam_class() -> type[Any]:
    try:
        from azure.ai.evaluation import RedTeam
    except ImportError as exc:
        raise SystemExit(
            "Missing optional dependency. Install in the customer environment with: "
            "python -m pip install 'azure-ai-evaluation[redteam]' azure-ai-projects"
        ) from exc
    return RedTeam


def build_target_callback(endpoint: str) -> TargetCallback:
    async def target_callback(prompt: str) -> str:
        raise RuntimeError(
            "Connect this callback to the authorized non-production endpoint "
            f"({endpoint}) using the customer's approved client."
        )

    return target_callback


async def run_redteam(args: argparse.Namespace) -> dict[str, Any]:
    RedTeam = load_redteam_class()
    target_callback = build_target_callback(args.target_endpoint)

    red_team = RedTeam(azure_ai_project=args.azure_ai_project, credential=None)
    result = await red_team.scan(
        target=target_callback,
        max_risk_categories=args.max_risk_categories,
    )
    if hasattr(result, "to_dict"):
        return dict(result.to_dict())
    if isinstance(result, dict):
        return result
    return {"result": repr(result)}


def main() -> int:
    args = parse_args()
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    scorecard = asyncio.run(run_redteam(args))
    output.write_text(json.dumps(scorecard, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
