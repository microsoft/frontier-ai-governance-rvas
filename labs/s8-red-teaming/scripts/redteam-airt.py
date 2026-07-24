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
import hashlib
import json
from collections.abc import Callable, Coroutine
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT / "evidence" / "airt-native-scorecard.json"
DEFAULT_COMPARISON_OUTPUT = ROOT / "evidence" / "airt-threshold-comparison.json"

TargetAdapter = Callable[[str, str], Coroutine[Any, Any, str]]
TargetCallback = Callable[[str], Coroutine[Any, Any, str]]


def positive_int(value: str) -> int:
    try:
        parsed = int(value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("must be a whole number") from exc
    if parsed < 1:
        raise argparse.ArgumentTypeError("must be at least 1")
    return parsed


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
    parser.add_argument(
        "--authorization-reference",
        required=True,
        help="Customer-approved authorization record reference; acknowledged but not verified by this script.",
    )
    parser.add_argument(
        "--soc-notification-reference",
        required=True,
        help="Customer SOC monitoring-window reference; acknowledged but not verified by this script.",
    )
    parser.add_argument(
        "--confirm-non-production-target",
        action="store_true",
        help="Required operator acknowledgement that the target is customer-owned and non-production.",
    )
    parser.add_argument(
        "--output",
        default=str(DEFAULT_OUTPUT),
        help="Path owned by the Foundry scan for its native scorecard output.",
    )
    parser.add_argument(
        "--threshold-review",
        type=Path,
        help=(
            "Customer-approved JSON review with category, observed_asr, and "
            "max_acceptable_asr values transcribed from the native scorecard."
        ),
    )
    parser.add_argument(
        "--comparison-output",
        type=Path,
        default=DEFAULT_COMPARISON_OUTPUT,
        help="Ignored customer-evidence path for the threshold-comparison sidecar.",
    )
    parser.add_argument(
        "--num-objectives",
        type=positive_int,
        default=5,
        help="Positive number of attack objectives generated per configured risk category.",
    )
    args = parser.parse_args()
    if not args.authorization_reference.strip() or not args.soc_notification_reference.strip():
        parser.error("authorization and SOC notification references must be non-empty")
    if not args.confirm_non_production_target:
        parser.error("--confirm-non-production-target is required")
    return args


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


async def run_redteam(args: argparse.Namespace) -> None:
    RedTeam, RiskCategory, DefaultAzureCredential = load_redteam_deps()
    target_callback = build_target_callback(
        args.target_endpoint,
        load_target_adapter(args.target_adapter),
    )

    # Managed Red Teaming covers the scoped content-harm categories. Any
    # additional jailbreak or injection testing is customer-owned and must be
    # recorded as a separate measurement.
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
    await red_team.scan(
        target=target_callback,
        output_path=str(args.output),
    )


def load_threshold_review(path: Path) -> list[dict[str, Any]]:
    try:
        review = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise SystemExit(f"threshold review not found: {path}") from exc
    if not isinstance(review, dict) or not isinstance(review.get("categories"), list):
        raise SystemExit("threshold review must be a JSON object with a categories array")

    categories: list[dict[str, Any]] = []
    for item in review["categories"]:
        if not isinstance(item, dict):
            raise SystemExit("threshold-review categories must be JSON objects")
        category = item.get("category")
        observed_asr = item.get("observed_asr")
        max_acceptable_asr = item.get("max_acceptable_asr")
        if not isinstance(category, str) or not category.strip():
            raise SystemExit("threshold-review category must be a non-empty string")
        if not all(
            isinstance(value, (int, float)) and not isinstance(value, bool)
            for value in (observed_asr, max_acceptable_asr)
        ):
            raise SystemExit("threshold-review ASR values must be numbers")
        if not 0 <= observed_asr <= 1 or not 0 <= max_acceptable_asr <= 1:
            raise SystemExit("threshold-review ASR values must be between 0 and 1")
        categories.append(
            {
                "category": category,
                "observed_asr": observed_asr,
                "max_acceptable_asr": max_acceptable_asr,
                "decision": "within_threshold"
                if observed_asr <= max_acceptable_asr
                else "above_threshold",
            }
        )
    if not categories:
        raise SystemExit("threshold-review categories must contain at least one category")
    return categories


def write_threshold_comparison(
    native_scorecard: Path,
    review_path: Path,
    comparison_output: Path,
) -> None:
    categories = load_threshold_review(review_path)
    if not native_scorecard.is_file():
        raise SystemExit(
            f"native scorecard not found: {native_scorecard}; do not create a comparison without it"
        )
    comparison_output.parent.mkdir(parents=True, exist_ok=True)
    sidecar = {
        "schema": "rvas.s8.threshold-comparison.v1",
        "native_scorecard_reference": str(native_scorecard),
        "native_scorecard_sha256": hashlib.sha256(native_scorecard.read_bytes()).hexdigest(),
        "customer_threshold_review_reference": str(review_path),
        "categories": categories,
        "decision_required": any(item["decision"] == "above_threshold" for item in categories),
    }
    comparison_output.write_text(json.dumps(sidecar, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    asyncio.run(run_redteam(args))
    if not output.is_file():
        raise SystemExit(
            f"Foundry scan returned without the expected native scorecard: {output}"
        )
    print(f"Foundry scan completed; native scorecard output is {output}")
    if args.threshold_review:
        write_threshold_comparison(output, args.threshold_review, args.comparison_output)
        print(f"Wrote threshold-comparison sidecar {args.comparison_output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
