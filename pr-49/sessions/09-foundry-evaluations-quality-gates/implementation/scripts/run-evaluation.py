#!/usr/bin/env python3
"""Run one Foundry agent evaluation and write only an aggregate release record to the approved release store."""

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
from azure.core.exceptions import ResourceNotFoundError
from azure.identity import DefaultAzureCredential


IMPLEMENTATION_SESSION = "09-foundry-evaluations-quality-gates"
TERMINAL_STATUSES = {"completed", "failed", "cancelled"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, required=True)
    parser.add_argument("--target", choices=("approved", "candidate"))
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check-only", action="store_true")
    parser.add_argument("--timeout-minutes", type=int, default=90)
    args = parser.parse_args()
    if not args.check_only and not args.target:
        parser.error("--target is required unless --check-only is used")
    if not args.check_only and args.output is None:
        parser.error("--output is required for an evaluation run")
    if args.timeout_minutes < 1 or args.timeout_minutes > 360:
        parser.error("--timeout-minutes must be between 1 and 360")
    return args


def require_external_output(path: Path) -> Path:
    output_path = path.resolve()
    repository_root = Path(__file__).resolve().parents[4]
    if output_path.is_relative_to(repository_root):
        raise ValueError(
            "--output must point to the approved release store outside this repository"
        )
    return output_path


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


def binding(reference: str) -> str:
    return ("{" * 2) + reference + ("}" * 2)


def dataset_details(spec_path: Path, spec: dict[str, Any]) -> tuple[Path, str, int]:
    dataset_path = (spec_path.parent / spec["dataset"]["path"]).resolve()
    raw = dataset_path.read_bytes()
    rows = [line for line in raw.decode("utf-8").splitlines() if line.strip()]
    digest = hashlib.sha256(raw).hexdigest()
    return dataset_path, digest, len(rows)


def aggregate_results(
    output_items: list[Any],
    evaluators: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    definitions = {item["name"].lower(): item for item in evaluators}
    counts: dict[str, dict[str, int]] = {
        name: {"passed": 0, "failed": 0, "errored": 0}
        for name in definitions
    }

    for output_item in output_items:
        item = model_dump(output_item)
        observed: set[str] = set()
        for result in item.get("results") or []:
            if not isinstance(result, dict):
                continue
            name = str(result.get("name", "")).lower()
            if name not in definitions:
                continue
            observed.add(name)
            passed = result.get("passed")
            label = str(result.get("label", "")).lower()
            if passed is True or label == "pass":
                counts[name]["passed"] += 1
            elif passed is False or label == "fail":
                counts[name]["failed"] += 1
            else:
                counts[name]["errored"] += 1
        for missing in set(definitions) - observed:
            counts[missing]["errored"] += 1

    metrics: list[dict[str, Any]] = []
    for name, definition in definitions.items():
        metric_counts = counts[name]
        total = sum(metric_counts.values())
        denominator = metric_counts["passed"] + metric_counts["failed"]
        pass_rate = round(metric_counts["passed"] / denominator, 6) if denominator else 0.0
        metrics.append(
            {
                "name": definition["name"],
                "layer": definition["layer"],
                **metric_counts,
                "total": total,
                "passRate": pass_rate,
            }
        )
    return metrics


def write_record(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    with temporary.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(record, handle, indent=2)
        handle.write("\n")
    temporary.replace(path)


def main() -> int:
    args = parse_args()
    spec_path = args.spec.resolve()
    spec = load_json(spec_path)
    if spec.get("implementationSession") != IMPLEMENTATION_SESSION:
        raise ValueError("Evaluation specification has the wrong implementationSession marker")
    evaluation_definition_id = spec.get("evaluationDefinitionId")
    if (
        not isinstance(evaluation_definition_id, str)
        or not evaluation_definition_id.strip()
        or evaluation_definition_id.startswith("__REQUIRED_")
    ):
        raise ValueError(
            "Evaluation specification must record the approved Foundry evaluation definition ID"
        )
    evaluation_definition_id = evaluation_definition_id.strip()
    output_path = None if args.check_only else require_external_output(args.output)

    endpoint = require_environment("FOUNDRY_PROJECT_ENDPOINT")
    agent_name = str(spec["target"]["agentName"])
    approved_version = str(spec["target"]["approvedVersion"])
    candidate_version = str(spec["target"]["candidateVersion"])
    if approved_version == candidate_version:
        raise ValueError("Approved and candidate agent versions must be different")

    dataset_path, dataset_hash, case_count = dataset_details(spec_path, spec)
    expected_minimum = int(spec["dataset"]["minimumCases"])
    if case_count < expected_minimum:
        raise ValueError(
            f"Golden dataset has {case_count} cases; at least {expected_minimum} are required"
        )

    with (
        DefaultAzureCredential() as credential,
        AIProjectClient(endpoint=endpoint, credential=credential) as project_client,
        project_client.get_openai_client() as openai_client,
    ):
        evaluation = openai_client.evals.retrieve(eval_id=evaluation_definition_id)
        if str(evaluation.id) != evaluation_definition_id:
            raise RuntimeError("Foundry did not return the recorded evaluation definition")
        for version in (approved_version, candidate_version):
            project_client.agents.get_version(
                agent_name=agent_name,
                agent_version=version,
            )

        if args.check_only:
            print("PASS: Foundry project and both approved agent versions are resolvable.")
            return 0

        target_version = approved_version if args.target == "approved" else candidate_version
        dataset_version = f"{spec['dataset']['versionPrefix']}-{dataset_hash[:12]}"
        try:
            dataset = project_client.datasets.get(
                name=spec["dataset"]["name"],
                version=dataset_version,
            )
        except ResourceNotFoundError:
            dataset = project_client.datasets.upload_file(
                name=spec["dataset"]["name"],
                version=dataset_version,
                file_path=str(dataset_path),
            )
        if not dataset.id:
            raise RuntimeError("Foundry did not return a dataset ID")

        run = openai_client.evals.runs.create(
            eval_id=evaluation_definition_id,
            name=f"{spec['evaluationName']}-{args.target}-{target_version}",
            metadata={
                "implementationSession": IMPLEMENTATION_SESSION,
                "targetLabel": args.target,
                "datasetSha256": dataset_hash,
            },
            data_source={
                "type": "azure_ai_target_completions",
                "source": {"type": "file_id", "id": dataset.id},
                "input_messages": {
                    "type": "template",
                    "template": [
                        {
                            "type": "message",
                            "role": "user",
                            "content": {
                                "type": "input_text",
                                "text": binding("item.query"),
                            },
                        }
                    ],
                },
                "target": {
                    "type": "azure_ai_agent",
                    "name": agent_name,
                    "version": target_version,
                },
            },
        )

        deadline = time.monotonic() + (args.timeout_minutes * 60)
        while str(run.status).lower() not in TERMINAL_STATUSES:
            if time.monotonic() >= deadline:
                raise TimeoutError(
                    f"Evaluation {evaluation_definition_id}/{run.id} did not finish "
                    f"within {args.timeout_minutes} minutes"
                )
            time.sleep(10)
            run = openai_client.evals.runs.retrieve(
                run_id=run.id,
                eval_id=evaluation_definition_id,
            )

        if str(run.status).lower() != "completed":
            raise RuntimeError(f"Evaluation run ended with status {run.status}")

        output_items = list(
            openai_client.evals.runs.output_items.list(
                run_id=run.id,
                eval_id=evaluation_definition_id,
            )
        )
        metrics = aggregate_results(output_items, spec["evaluators"])
        record = {
            "schemaVersion": 1,
            "implementationSession": IMPLEMENTATION_SESSION,
            "recordType": "foundry-evaluation-aggregate",
            "generatedAt": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "run": {
                "evalId": evaluation.id,
                "runId": run.id,
                "status": str(run.status).lower(),
                "reportUrl": str(run.report_url) if run.report_url else None,
                "target": {
                    "type": "azure_ai_agent",
                    "name": agent_name,
                    "version": target_version,
                    "label": args.target,
                },
            },
            "dataset": {
                "name": spec["dataset"]["name"],
                "version": dataset_version,
                "sha256": dataset_hash,
                "caseCount": case_count,
            },
            "metrics": metrics,
            "privacy": {
                "containsQueries": False,
                "containsResponses": False,
                "containsToolPayloads": False,
                "containsEvaluatorReasons": False,
            },
        }

        if output_path is None:
            raise RuntimeError("An evaluation run requires an external output path")
        write_record(output_path, record)
        by_layer: dict[str, list[str]] = defaultdict(list)
        for metric in metrics:
            by_layer[metric["layer"]].append(
                f"{metric['name']}={metric['passRate']:.3f} "
                f"({metric['errored']} errored)"
            )
        print(f"Completed Foundry run {run.id}; aggregate record: {output_path}")
        for layer, values in by_layer.items():
            print(f"  {layer}: {', '.join(values)}")
        return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
