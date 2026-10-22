#!/usr/bin/env python3
"""Prepare or run one payload-free Microsoft Foundry cloud red-team exercise."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import time
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import (
    AgentTaxonomyInput,
    AzureAIAgentTarget,
    EvaluationTaxonomy,
    RiskCategory,
)
from azure.identity import DefaultAzureCredential


IMPLEMENTATION_SESSION = "10-red-teaming-threat-defense"
TERMINAL_STATUSES = {"completed", "failed", "cancelled", "canceled"}
RISK_CATEGORY_KEYS = {"riskcategory"}
ATTACK_STRATEGY_KEYS = {"attackstrategy", "attacktechnique", "strategy"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=Path, required=True)
    parser.add_argument(
        "--phase",
        choices=("baseline", "post-remediation"),
        default="baseline",
    )
    parser.add_argument("--prepare-taxonomy", action="store_true")
    parser.add_argument("--check-only", action="store_true")
    parser.add_argument("--taxonomy-id")
    parser.add_argument("--post-remediation-version")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--timeout-minutes", type=int, default=120)
    args = parser.parse_args()
    selected_modes = sum((args.prepare_taxonomy, args.check_only))
    if selected_modes > 1:
        parser.error("--prepare-taxonomy and --check-only are mutually exclusive")
    if not args.prepare_taxonomy and not args.check_only and args.output is None:
        parser.error("--output is required for a red-team run")
    if not args.prepare_taxonomy and not args.check_only and not args.taxonomy_id:
        parser.error("--taxonomy-id is required for a red-team run")
    if args.phase == "post-remediation" and not args.check_only and not args.post_remediation_version:
        parser.error("--post-remediation-version is required for the post-remediation run")
    if args.timeout_minutes < 1 or args.timeout_minutes > 360:
        parser.error("--timeout-minutes must be between 1 and 360")
    return args


def load_json(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain one JSON object")
    return value


def require_environment(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise RuntimeError(f"{name} is required")
    return value


def model_dump(value: Any) -> dict[str, Any]:
    if hasattr(value, "model_dump"):
        return value.model_dump(mode="json")
    if isinstance(value, dict):
        return value
    raise TypeError(f"Cannot serialize {type(value).__name__}")


def canonical_hash(value: dict[str, Any]) -> str:
    payload = json.dumps(value, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def normalized_key(value: str) -> str:
    return "".join(character for character in value.lower() if character.isalnum())


def scalar_dimension(value: Any) -> str | None:
    if isinstance(value, str) and value.strip():
        return value.strip()
    if isinstance(value, dict):
        for key in ("value", "name", "label"):
            candidate = value.get(key)
            if isinstance(candidate, str) and candidate.strip():
                return candidate.strip()
    return None


def find_dimension(value: Any, keys: set[str]) -> set[str]:
    found: set[str] = set()
    if isinstance(value, dict):
        for key, candidate in value.items():
            if normalized_key(str(key)) in keys:
                dimension = scalar_dimension(candidate)
                if dimension:
                    found.add(dimension)
            if isinstance(candidate, (dict, list)):
                found.update(find_dimension(candidate, keys))
    elif isinstance(value, list):
        for item in value:
            found.update(find_dimension(item, keys))
    return found


def resolve_dimension(
    result: dict[str, Any],
    item: dict[str, Any],
    keys: set[str],
    label: str,
) -> str:
    result_values = find_dimension(result, keys)
    item_context = {
        key: value
        for key, value in item.items()
        if normalized_key(str(key)) not in {"results", "evaluations"}
    }
    values = result_values or find_dimension(item_context, keys)
    if len(values) != 1:
        raise ValueError(
            f"Each red-team output item must expose one {label}; observed {sorted(values)}"
        )
    return next(iter(values))


def write_record(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    with temporary.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(record, handle, indent=2)
        handle.write("\n")
    temporary.replace(path)


def require_external_output(path: Path) -> Path:
    output_path = path.resolve()
    repository_root = Path(__file__).resolve().parents[4]
    if output_path.is_relative_to(repository_root):
        raise ValueError(
            "--output must point to the approved security record store outside this repository"
        )
    return output_path


def aggregate_results(
    output_items: list[Any],
    criteria: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    definitions = {
        str(item["name"]).lower(): {
            "name": str(item["name"]),
            "evaluatorName": str(item["evaluatorName"]),
        }
        for item in criteria
    }
    counts: dict[tuple[str, str, str], dict[str, int]] = {}
    for output_item in output_items:
        item = model_dump(output_item)
        observed: set[tuple[str, str, str]] = set()
        for result in item.get("results") or []:
            if not isinstance(result, dict):
                continue
            name = str(result.get("name", "")).lower()
            if name not in definitions:
                continue
            risk_category = resolve_dimension(
                result,
                item,
                RISK_CATEGORY_KEYS,
                "risk category",
            )
            attack_strategy = resolve_dimension(
                result,
                item,
                ATTACK_STRATEGY_KEYS,
                "attack strategy",
            )
            key = (name, risk_category, attack_strategy)
            observed.add(key)
            metric = counts.setdefault(
                key,
                {"passed": 0, "failed": 0, "errored": 0},
            )
            passed = result.get("passed")
            label = str(result.get("label", "")).lower()
            if passed is True or label == "pass":
                metric["passed"] += 1
            elif passed is False or label == "fail":
                metric["failed"] += 1
            else:
                metric["errored"] += 1
        observed_evaluators = {key[0] for key in observed}
        missing_evaluators = set(definitions) - observed_evaluators
        if missing_evaluators:
            observed_dimensions = {(key[1], key[2]) for key in observed}
            if len(observed_dimensions) == 1:
                item_risk, item_strategy = next(iter(observed_dimensions))
            else:
                item_risk = resolve_dimension(
                    {},
                    item,
                    RISK_CATEGORY_KEYS,
                    "risk category",
                )
                item_strategy = resolve_dimension(
                    {},
                    item,
                    ATTACK_STRATEGY_KEYS,
                    "attack strategy",
                )
        for missing in missing_evaluators:
            key = (missing, item_risk, item_strategy)
            metric = counts.setdefault(
                key,
                {"passed": 0, "failed": 0, "errored": 0},
            )
            metric["errored"] += 1

    metrics: list[dict[str, Any]] = []
    for key in sorted(counts):
        evaluator_key, risk_category, attack_strategy = key
        definition = definitions[evaluator_key]
        metric = counts[key]
        scored = metric["passed"] + metric["failed"]
        asr = round(metric["failed"] / scored, 6) if scored else 0.0
        metrics.append(
            {
                **definition,
                "riskCategory": risk_category,
                "attackStrategy": attack_strategy,
                **metric,
                "total": sum(metric.values()),
                "attackSuccessRate": asr,
            }
        )
    return metrics


def testing_criteria(
    config: dict[str, Any],
    judge_model: str,
) -> list[dict[str, Any]]:
    criteria: list[dict[str, Any]] = []
    for item in config["testingCriteria"]:
        criterion: dict[str, Any] = {
            "type": "azure_ai_evaluator",
            "name": item["name"],
            "evaluator_name": item["evaluatorName"],
            "evaluator_version": item["evaluatorVersion"],
        }
        if item["judgeModelRequired"]:
            criterion["initialization_parameters"] = {
                "deployment_name": judge_model,
            }
        criteria.append(criterion)
    return criteria


def main() -> int:
    args = parse_args()
    config_path = args.config.resolve()
    config = load_json(config_path)
    if config.get("implementationSession") != IMPLEMENTATION_SESSION:
        raise ValueError("Attack plan has the wrong implementationSession marker")

    endpoint = require_environment("FOUNDRY_PROJECT_ENDPOINT")
    judge_model = require_environment("FOUNDRY_MODEL_NAME")
    agent_name = str(config["target"]["name"])
    baseline_version = require_environment("FOUNDRY_BASELINE_AGENT_VERSION")
    post_version = args.post_remediation_version or os.environ.get(
        "FOUNDRY_POST_REMEDIATION_AGENT_VERSION", ""
    ).strip()
    agent_version = baseline_version if args.phase == "baseline" else post_version
    if args.phase == "post-remediation" and not post_version:
        raise ValueError("FOUNDRY_POST_REMEDIATION_AGENT_VERSION is required")
    if post_version and baseline_version == post_version:
        raise ValueError("Baseline and post-remediation versions must differ")

    target = AzureAIAgentTarget(name=agent_name, version=agent_version)
    with (
        DefaultAzureCredential() as credential,
        AIProjectClient(endpoint=endpoint, credential=credential) as project_client,
    ):
        project_client.agents.get_version(
            agent_name=agent_name,
            agent_version=agent_version,
        )
        if args.check_only:
            print(
                "PASS: Foundry project, judge deployment context, and exact "
                f"{args.phase} agent version are resolvable."
            )
            return 0

        if args.prepare_taxonomy:
            baseline_target = AzureAIAgentTarget(
                name=agent_name,
                version=baseline_version,
            )
            taxonomy = project_client.beta.evaluation_taxonomies.create(
                name=str(config["taxonomy"]["name"]),
                body=EvaluationTaxonomy(
                    description=(
                        "Session 10 prohibited-action taxonomy for the authorized "
                        "nonproduction policy assistant"
                    ),
                    taxonomy_input=AgentTaxonomyInput(
                        risk_categories=[RiskCategory.PROHIBITED_ACTIONS],
                        target=baseline_target,
                    ),
                ),
            )
            print(f"Prepared taxonomy: {taxonomy.id}")
            print(
                "Review and approve it in Foundry, then supply its current ID through "
                "--taxonomy-id for a red-team run."
            )
            return 0

        taxonomy_id = args.taxonomy_id

        with project_client.get_openai_client() as openai_client:
            evaluation = openai_client.evals.create(
                name=str(config["name"]),
                data_source_config={
                    "type": "azure_ai_source",
                    "scenario": "red_team",
                },
                testing_criteria=testing_criteria(config, judge_model),
            )
            run = openai_client.evals.runs.create(
                eval_id=evaluation.id,
                name=f"{config['name']}-{args.phase}-{agent_version}",
                metadata={
                    "implementationSession": IMPLEMENTATION_SESSION,
                    "phase": args.phase,
                },
                data_source={
                    "type": "azure_ai_red_team",
                    "item_generation_params": {
                        "type": "red_team_taxonomy",
                        "attack_strategies": list(config["attackStrategies"]),
                        "num_turns": int(config["numTurns"]),
                        "source": {"type": "file_id", "id": taxonomy_id},
                    },
                    "target": target.as_dict(),
                },
            )

            deadline = time.monotonic() + (args.timeout_minutes * 60)
            while str(run.status).lower() not in TERMINAL_STATUSES:
                if time.monotonic() >= deadline:
                    raise TimeoutError(
                        f"Red-team run {evaluation.id}/{run.id} did not finish "
                        f"within {args.timeout_minutes} minutes"
                    )
                time.sleep(10)
                run = openai_client.evals.runs.retrieve(
                    run_id=run.id,
                    eval_id=evaluation.id,
                )
            if str(run.status).lower() != "completed":
                raise RuntimeError(f"Red-team run ended with status {run.status}")

            output_items = list(
                openai_client.evals.runs.output_items.list(
                    run_id=run.id,
                    eval_id=evaluation.id,
                )
            )
            metrics = aggregate_results(output_items, config["testingCriteria"])
            scored = sum(item["passed"] + item["failed"] for item in metrics)
            successful = sum(item["failed"] for item in metrics)
            record = {
                "schemaVersion": 1,
                "implementationSession": IMPLEMENTATION_SESSION,
                "recordType": "foundry-red-team-aggregate",
                "generatedAt": datetime.now(timezone.utc)
                .isoformat()
                .replace("+00:00", "Z"),
                "phase": args.phase,
                "configurationSha256": canonical_hash(config),
                "run": {
                    "evalId": evaluation.id,
                    "runId": run.id,
                    "status": str(run.status).lower(),
                    "reportUrl": str(run.report_url) if run.report_url else None,
                    "target": {
                        "type": "azure_ai_agent",
                        "name": agent_name,
                        "version": agent_version,
                    },
                },
                "summary": {
                    "outputItemCount": len(output_items),
                    "scoredResults": scored,
                    "successfulAttacks": successful,
                    "overallAttackSuccessRate": (
                        round(successful / scored, 6) if scored else 0.0
                    ),
                    "metrics": metrics,
                },
                "privacy": {
                    "containsAttackPrompts": False,
                    "containsAgentResponses": False,
                    "containsToolPayloads": False,
                    "containsEvaluatorReasons": False,
                    "containsPromptEvidence": False,
                },
                "implementationMarker": (
                    "implementationSession=10-red-teaming-threat-defense"
                ),
            }
            output_path = require_external_output(args.output)
            write_record(output_path, record)
            print(
                f"Completed {args.phase} red-team run {run.id}; "
                f"aggregate record: {output_path}"
            )
            print(
                "  overall attack success rate: "
                f"{record['summary']['overallAttackSuccessRate']:.3f}"
            )
            for metric in metrics:
                print(
                    f"  {metric['name']}: "
                    f"ASR={metric['attackSuccessRate']:.3f}, "
                    f"errors={metric['errored']}"
                )
            return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
