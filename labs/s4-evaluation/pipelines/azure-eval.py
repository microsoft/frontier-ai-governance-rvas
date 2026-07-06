#!/usr/bin/env python3
"""Tier A reference runner for Microsoft Foundry Evaluations.

This script documents the production path and is intentionally not executed by
CI. It requires `azure-ai-evaluation`, an Azure AI Foundry project, and judge
model configuration supplied through environment variables.

Required environment variables for live use:
    AZURE_AI_PROJECT_ENDPOINT
    AZURE_OPENAI_EVALUATION_DEPLOYMENT
Optional:
    AZURE_SUBSCRIPTION_ID, AZURE_RESOURCE_GROUP, AZURE_AI_PROJECT_NAME
"""
from __future__ import annotations

import importlib
import os
from pathlib import Path
from typing import Any

KIT_ROOT = Path(__file__).resolve().parents[1]
DATASET = KIT_ROOT / "data" / "eval-dataset.jsonl"
OUTPUT = KIT_ROOT / "evidence" / "azure-eval-results.json"

QUALITY_EVALUATORS = (
    "RelevanceEvaluator",
    "CoherenceEvaluator",
    "FluencyEvaluator",
    "GroundednessEvaluator",
    "SimilarityEvaluator",
    "F1ScoreEvaluator",
)
RISK_SAFETY_EVALUATORS = (
    "ViolenceEvaluator",
    "SexualEvaluator",
    "SelfHarmEvaluator",
    "HateUnfairnessEvaluator",
    "ProtectedMaterialEvaluator",
    "IndirectAttackEvaluator",
)
AGENT_EVALUATORS = (
    "IntentResolutionEvaluator",
    "ToolCallAccuracyEvaluator",
    "TaskAdherenceEvaluator",
)


def require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        raise SystemExit(f"missing required environment variable: {name}")
    return value


def load_sdk() -> Any:
    try:
        return importlib.import_module("azure.ai.evaluation")
    except ImportError as exc:
        raise SystemExit("Install azure-ai-evaluation before running Tier A live evaluations.") from exc


def evaluator_model_config() -> dict[str, str]:
    return {
        "azure_deployment": require_env("AZURE_OPENAI_EVALUATION_DEPLOYMENT"),
        "api_version": os.environ.get("AZURE_OPENAI_API_VERSION", "2024-10-21"),
    }


def azure_ai_project() -> dict[str, str]:
    project = {"project_endpoint": require_env("AZURE_AI_PROJECT_ENDPOINT")}
    optional = {
        "subscription_id": os.environ.get("AZURE_SUBSCRIPTION_ID"),
        "resource_group_name": os.environ.get("AZURE_RESOURCE_GROUP"),
        "project_name": os.environ.get("AZURE_AI_PROJECT_NAME"),
    }
    return project | {key: value for key, value in optional.items() if value}


def instantiate(module: Any, class_names: tuple[str, ...], model_config: dict[str, str]) -> dict[str, Any]:
    evaluators: dict[str, Any] = {}
    for class_name in class_names:
        evaluator_type = getattr(module, class_name, None)
        if evaluator_type is None:
            print(f"WARN: {class_name} not available in installed azure-ai-evaluation version")
            continue
        evaluators[class_name.removesuffix("Evaluator").lower()] = evaluator_type(model_config=model_config)
    return evaluators


def target(query: str) -> dict[str, str]:
    """Replace this stub with a call to the customer's non-production test agent."""
    return {"response": f"Test-agent placeholder response for: {query}"}


def main() -> int:
    module = load_sdk()
    evaluate = getattr(module, "evaluate")
    model_config = evaluator_model_config()
    evaluators = {}
    evaluators.update(instantiate(module, QUALITY_EVALUATORS, model_config))
    evaluators.update(instantiate(module, RISK_SAFETY_EVALUATORS, model_config))
    evaluators.update(instantiate(module, AGENT_EVALUATORS, model_config))
    if not evaluators:
        raise SystemExit("No evaluators were available from azure-ai-evaluation.")

    result = evaluate(
        data=str(DATASET),
        target=target,
        evaluators=evaluators,
        azure_ai_project=azure_ai_project(),
        output_path=str(OUTPUT),
    )
    print(result)
    print(f"Evidence: {OUTPUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
