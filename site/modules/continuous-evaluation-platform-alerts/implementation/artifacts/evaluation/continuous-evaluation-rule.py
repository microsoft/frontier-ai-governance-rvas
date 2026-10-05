from __future__ import annotations

import argparse
import json
import os
import re
from pathlib import Path
from typing import Any

from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import (
    ContinuousEvaluationRuleAction,
    EvaluationRule,
    EvaluationRuleEventType,
    EvaluationRuleFilter,
)
from azure.identity import DefaultAzureCredential


SENTINEL_PATTERN = re.compile(r"__REQUIRED_[A-Z0-9_]+__")


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def load_decision(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    unresolved = sorted(set(SENTINEL_PATTERN.findall(text)))
    if unresolved:
        fail("Resolve required decisions before configuring continuous evaluation: " + ", ".join(unresolved))
    decision = json.loads(text)
    if decision.get("implementationSession") != "optional-module-continuous-evaluation-platform-alerts":
        fail("Decision file has the wrong implementationSession marker.")
    return decision


def positive_int(value: Any, label: str, maximum: int) -> int:
    try:
        parsed = int(value)
    except (TypeError, ValueError):
        fail(f"{label} must be an integer.")
    if parsed < 1 or parsed > maximum:
        fail(f"{label} must be from 1 through {maximum}.")
    return parsed


def evaluator_criteria(decision: dict[str, Any]) -> list[dict[str, str]]:
    criteria: list[dict[str, str]] = []
    for item in decision["continuousEvaluation"]["evaluators"]:
        name = item["name"]
        evaluator_name = item["evaluatorName"]
        if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_-]{2,63}", name):
            fail(f"Evaluator name is not a safe identifier: {name}")
        if not evaluator_name.startswith("builtin."):
            fail(f"Evaluator must come from the approved Foundry evaluator catalog: {evaluator_name}")
        criteria.append(
            {
                "type": "azure_ai_evaluator",
                "name": name,
                "evaluator_name": evaluator_name,
            }
        )
    if not criteria:
        fail("At least one evaluator is required.")
    return criteria


def build_client(decision: dict[str, Any]) -> tuple[DefaultAzureCredential, AIProjectClient]:
    env_name = decision["foundry"].get("projectEndpointEnvironmentVariable", "AZURE_AI_PROJECT_ENDPOINT")
    endpoint = os.environ.get(env_name)
    if not endpoint:
        fail(f"Set {env_name} to the approved Foundry project endpoint before running this script.")
    credential = DefaultAzureCredential()
    return credential, AIProjectClient(endpoint=endpoint, credential=credential)


def create_or_update_rule(decision_path: Path) -> None:
    decision = load_decision(decision_path)
    max_hourly_runs = positive_int(
        decision["continuousEvaluation"]["sampling"]["maxHourlyRuns"],
        "continuousEvaluation.sampling.maxHourlyRuns",
        1000,
    )
    agent_name = decision["foundry"]["agentName"]
    evaluation = decision["continuousEvaluation"]
    criteria = evaluator_criteria(decision)

    credential, project_client = build_client(decision)
    with credential, project_client, project_client.get_openai_client() as openai_client:
        eval_object = openai_client.evals.create(
            name=evaluation["evaluationName"],
            data_source_config={"type": "azure_ai_source", "scenario": "responses"},  # type: ignore[arg-type]
            testing_criteria=criteria,  # type: ignore[arg-type]
        )
        rule = project_client.evaluation_rules.create_or_update(
            id=evaluation["ruleId"],
            evaluation_rule=EvaluationRule(
                display_name=evaluation["displayName"],
                description=evaluation["description"],
                action=ContinuousEvaluationRuleAction(eval_id=eval_object.id, max_hourly_runs=max_hourly_runs),
                event_type=EvaluationRuleEventType.RESPONSE_COMPLETED,
                filter=EvaluationRuleFilter(agent_name=agent_name),
                enabled=bool(evaluation["enabled"]),
            ),
        )
        print(
            json.dumps(
                {
                    "status": "configured",
                    "agentName": agent_name,
                    "evaluationId": eval_object.id,
                    "evaluationName": eval_object.name,
                    "ruleId": rule.id,
                    "ruleDisplayName": rule.display_name,
                    "maxHourlyRuns": max_hourly_runs,
                },
                indent=2,
            )
        )


def list_runs(evaluation_id: str, limit: int) -> None:
    if SENTINEL_PATTERN.search(evaluation_id):
        fail("Pass a resolved evaluation ID.")
    endpoint = os.environ.get("AZURE_AI_PROJECT_ENDPOINT")
    if not endpoint:
        fail("Set AZURE_AI_PROJECT_ENDPOINT to the approved Foundry project endpoint before listing runs.")
    credential = DefaultAzureCredential()
    with credential, AIProjectClient(endpoint=endpoint, credential=credential) as project_client:
        with project_client.get_openai_client() as openai_client:
            runs = openai_client.evals.runs.list(eval_id=evaluation_id, order="desc", limit=limit)
            summary = [
                {
                    "id": item.id,
                    "status": item.status,
                    "createdAt": str(getattr(item, "created_at", "")),
                    "reportUrlPresent": bool(getattr(item, "report_url", None)),
                }
                for item in runs.data
            ]
            print(json.dumps({"evaluationId": evaluation_id, "runCount": len(summary), "runs": summary}, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(description="Create or inspect a Microsoft Foundry continuous evaluation rule.")
    parser.add_argument("--decision-file", type=Path, default=Path(__file__).with_name("continuous-evaluation-decision.json"))
    parser.add_argument("--list-runs", action="store_true", help="List recent runs instead of creating or updating the rule.")
    parser.add_argument("--evaluation-id", help="Evaluation ID to inspect when --list-runs is used.")
    parser.add_argument("--limit", type=int, default=10)
    args = parser.parse_args()

    if args.list_runs:
        if not args.evaluation_id:
            fail("--evaluation-id is required with --list-runs.")
        list_runs(args.evaluation_id, positive_int(args.limit, "--limit", 100))
    else:
        create_or_update_rule(args.decision_file)


if __name__ == "__main__":
    main()
