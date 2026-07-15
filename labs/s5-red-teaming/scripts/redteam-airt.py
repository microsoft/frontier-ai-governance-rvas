#!/usr/bin/env python3
"""Customer-operated target-adapter contract for Microsoft Foundry AI Red Teaming.

The customer supplies ``--target-adapter MODULE:CALLABLE`` from its approved
codebase. That async callable receives ``(prompt, endpoint)`` and returns the
target response. It owns endpoint authentication, secret handling, and
non-production target selection; this kit contains no endpoint client.

This script is intentionally import-guarded so static validation does not require
Azure packages. Run it only in the customer's environment, against the written-scope
non-production test endpoint, after SOC notification and authorization.
"""
from __future__ import annotations

import argparse
import asyncio
import importlib
import inspect
import json
from collections.abc import Callable, Coroutine
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT / "evidence" / "airt-asr-scorecard.json"

TargetAdapter = Callable[[str, str], Coroutine[Any, Any, str]]
TargetCallback = Callable[[str], Coroutine[Any, Any, str]]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run an AI Red Teaming Agent scan.")
    parser.add_argument("--azure-ai-project", required=True, help="Azure AI Foundry project endpoint or connection string.")
    parser.add_argument("--target-endpoint", required=True, help="Authorized customer-owned non-production endpoint URL.")
    parser.add_argument(
        "--target-adapter",
        required=True,
        metavar="MODULE:CALLABLE",
        help="Customer-owned async adapter, for example customer_redteam_adapter:target.",
    )
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT), help="Path for the exported ASR scorecard JSON.")
    parser.add_argument("--num-objectives", type=int, default=5, help="Objectives (attack prompts) generated per risk category for a scoped run.")
    return parser.parse_args()


def load_redteam_deps() -> tuple[type[Any], Any, Any]:
    try:
        from azure.ai.evaluation.red_team import RedTeam, RiskCategory
        from azure.identity import DefaultAzureCredential
    except ImportError as exc:
        raise SystemExit(
            "Missing optional dependency. Install in the customer environment with: "
            "python -m pip install 'azure-ai-evaluation[redteam]' azure-identity"
        ) from exc
    return RedTeam, RiskCategory, DefaultAzureCredential


def load_target_adapter(spec: str) -> TargetAdapter:
    module_name, separator, callable_name = spec.partition(":")
    if not separator or not module_name or not callable_name:
        raise SystemExit("--target-adapter must use the form MODULE:CALLABLE")
    try:
        adapter = getattr(importlib.import_module(module_name), callable_name)
    except (ImportError, AttributeError) as exc:
        raise SystemExit(f"could not load customer target adapter {spec!r}: {exc}") from exc
    if not callable(adapter):
        raise SystemExit(f"customer target adapter {spec!r} is not callable")
    return adapter


def build_target_callback(endpoint: str, adapter: TargetAdapter) -> TargetCallback:
    async def target_callback(prompt: str) -> str:
        response = adapter(prompt, endpoint)
        if not inspect.isawaitable(response):
            raise TypeError("customer target adapter must return an awaitable response")
        result = await response
        if not isinstance(result, str):
            raise TypeError("customer target adapter must resolve to a string response")
        return result

    return target_callback


async def run_redteam(args: argparse.Namespace) -> dict[str, Any]:
    RedTeam, RiskCategory, DefaultAzureCredential = load_redteam_deps()
    target_callback = build_target_callback(
        args.target_endpoint,
        load_target_adapter(args.target_adapter),
    )

    # Managed Red Teaming covers content-harm categories. The offline S5 mock
    # harness separately covers jailbreak and injection scenarios; the scopes
    # are complementary and must not be treated as the same measurement.
    red_team = RedTeam(
        azure_ai_project=args.azure_ai_project,
        credential=DefaultAzureCredential(),
        risk_categories=[
            RiskCategory.Violence,
            RiskCategory.HateUnfairness,
            RiskCategory.Sexual,
            RiskCategory.SelfHarm,
        ],
        num_objectives=args.num_objectives,
    )
    result = await red_team.scan(
        target=target_callback,
        output_path=str(args.output),
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
