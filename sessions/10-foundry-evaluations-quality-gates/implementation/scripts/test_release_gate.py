#!/usr/bin/env python3
"""Run stable in-memory checks against the Session 11 gate decision code."""

from __future__ import annotations

import argparse
import copy
import importlib.util
import json
from datetime import date
from pathlib import Path

import yaml


SCRIPT_DIR = Path(__file__).resolve().parent
IMPLEMENTATION_DIR = SCRIPT_DIR.parent
POLICY_PATH = IMPLEMENTATION_DIR / "artifacts" / "eval" / "thresholds.yaml"
SPEC_PATH = IMPLEMENTATION_DIR / "artifacts" / "eval" / "evaluation-spec.json"
RELEASE_POLICY_PATH = (
    IMPLEMENTATION_DIR / "artifacts" / "release" / "release-policy.json"
)

module_spec = importlib.util.spec_from_file_location(
    "session10_release_gate",
    SCRIPT_DIR / "release-gate.py",
)
if module_spec is None or module_spec.loader is None:
    raise RuntimeError("Could not load release-gate.py")
gate = importlib.util.module_from_spec(module_spec)
module_spec.loader.exec_module(gate)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--mode",
        choices=("blocked-tool-process", "activation-contract", "all"),
        required=True,
    )
    return parser.parse_args()


def aggregate_record(
    specification: dict,
    *,
    version: str,
    run_id: str,
    blocked_tool_process: bool,
) -> dict:
    metrics = []
    for evaluator in specification["evaluators"]:
        name = evaluator["name"]
        blocked = blocked_tool_process and name in {
            "tool_call_accuracy",
            "tool_call_success",
        }
        passed = 0 if blocked else 8
        failed = 8 if blocked else 0
        metrics.append(
            {
                "name": name,
                "layer": evaluator["layer"],
                "passed": passed,
                "failed": failed,
                "errored": 0,
                "total": 8,
                "passRate": round(passed / 8, 6),
            }
        )
    return {
        "schemaVersion": 1,
        "implementationSession": "11-foundry-evaluations-quality-gates",
        "recordType": "generated-gate-self-test",
        "run": {
            "runId": run_id,
            "status": "completed",
            "target": {
                "name": "generated-policy-assistant",
                "version": version,
            },
        },
        "metrics": metrics,
        "privacy": {
            "containsQueries": False,
            "containsResponses": False,
            "containsToolPayloads": False,
            "containsEvaluatorReasons": False,
        },
    }


def prepared_test_inputs() -> tuple[dict, dict, dict, dict]:
    threshold_policy = yaml.safe_load(POLICY_PATH.read_text(encoding="utf-8"))
    threshold_policy["policy_state"] = "active"
    threshold_policy["baseline"]["source_run_id"] = "generated-baseline"
    threshold_policy["baseline"]["approved_agent_version"] = "approved-v1"
    threshold_policy["baseline"]["established_on"] = "2026-08-26"
    for rule in threshold_policy["rules"]:
        if rule["blocking"]:
            rule["minimum_pass_rate"] = 0.75
        floor = rule.get("regression_floor")
        if floor is not None:
            floor["minimum_pass_rate"] = 0.5
            floor["approved_by"] = "generated-test-owner"
            floor["approved_on"] = "2026-08-26"
    gate.validate_policy(threshold_policy, "candidate")

    specification = json.loads(SPEC_PATH.read_text(encoding="utf-8"))
    baseline = aggregate_record(
        specification,
        version="approved-v1",
        run_id="generated-baseline",
        blocked_tool_process=False,
    )
    candidate = aggregate_record(
        specification,
        version="candidate-v2",
        run_id="generated-tool-process-regression",
        blocked_tool_process=True,
    )
    for metric in candidate["metrics"]:
        if metric["name"] in {"sensitive_data_leakage", "prohibited_actions"}:
            metric["passed"] = 0
            metric["failed"] = 8
            metric["passRate"] = 0.0
    return threshold_policy, specification, baseline, candidate


def run_blocked_tool_process() -> None:
    threshold_policy, specification, baseline, candidate = prepared_test_inputs()
    baseline_metrics = gate.validate_record(baseline, "generated baseline")
    candidate_metrics = gate.validate_record(candidate, "generated candidate")
    configured = {item["name"]: item for item in specification["evaluators"]}
    outcome, layer_status, reasons = gate.evaluate_metrics(
        threshold_policy,
        configured,
        baseline_metrics,
        candidate_metrics,
    )
    if outcome != "block":
        raise ValueError(f"Expected BLOCK, observed {outcome.upper()}")
    if not any(reason.startswith("tool-process/") for reason in reasons):
        raise ValueError("Generated case did not block the tool-process layer")
    if any(reason.startswith("final-answer-quality/") for reason in reasons):
        raise ValueError("Generated tool-process case blocked final-answer quality")

    safety_status = layer_status["safety"]
    for metric in ("sensitive_data_leakage", "prohibited_actions"):
        expected = f"{metric}=0.000 [advisory]"
        if expected not in safety_status:
            raise ValueError(f"Preview metric {metric} was not kept advisory")
        if any(f"/{metric}:" in reason for reason in reasons):
            raise ValueError(f"Preview metric {metric} incorrectly blocked the gate")
    print("PASS: stored tool-process case blocked while preview safety failures stayed advisory.")


def expect_activation_failure(
    release_policy: dict,
    threshold_policy: dict,
    baseline: dict,
    candidate: dict,
) -> None:
    try:
        gate.validate_activation(
            release_policy,
            threshold_policy,
            baseline,
            candidate,
        )
    except ValueError:
        return
    raise ValueError("Invalid activation contract was accepted")


def run_activation_contract() -> None:
    threshold_policy, _, baseline, candidate = prepared_test_inputs()
    release_policy = json.loads(RELEASE_POLICY_PATH.read_text(encoding="utf-8"))
    release_policy["gate"].update(
        {
            "state": "enabled",
            "decision": "approved",
            "decisionDate": date.today().isoformat(),
            "baselineRunId": baseline["run"]["runId"],
            "candidateRunId": candidate["run"]["runId"],
        }
    )
    gate.validate_activation(
        release_policy,
        threshold_policy,
        baseline,
        candidate,
    )
    pending = copy.deepcopy(release_policy)
    pending["gate"]["state"] = "disabled-pending-session-checkpoint"
    expect_activation_failure(pending, threshold_policy, baseline, candidate)
    mismatched = copy.deepcopy(release_policy)
    mismatched["gate"]["candidateRunId"] = "wrong-candidate"
    expect_activation_failure(mismatched, threshold_policy, baseline, candidate)
    print("PASS: strict release-policy activation contract accepted and rejected expected cases.")


def main() -> int:
    args = parse_args()
    if args.mode in {"blocked-tool-process", "all"}:
        run_blocked_tool_process()
    if args.mode in {"activation-contract", "all"}:
        run_activation_contract()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
