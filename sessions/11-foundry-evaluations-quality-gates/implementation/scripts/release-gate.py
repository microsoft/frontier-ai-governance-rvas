#!/usr/bin/env python3
"""Apply baseline-derived release thresholds to payload-free evaluation records."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from collections import defaultdict
from datetime import date
from pathlib import Path
from typing import Any

import yaml


IMPLEMENTATION_SESSION = "11-foundry-evaluations-quality-gates"
LAYERS = {"final-answer-quality", "tool-process", "safety"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--policy", type=Path, required=True)
    parser.add_argument("--spec", type=Path)
    parser.add_argument("--dataset", type=Path)
    parser.add_argument("--baseline-result", type=Path)
    parser.add_argument("--candidate-result", type=Path)
    parser.add_argument("--release-policy", type=Path)
    parser.add_argument("--require-enabled", action="store_true")
    parser.add_argument(
        "--evaluated-target",
        choices=("approved", "candidate"),
        default="candidate",
    )
    parser.add_argument("--expect", choices=("pass", "block"), default="pass")
    parser.add_argument("--validate-policy", action="store_true")
    parser.add_argument("--phase", choices=("baseline", "candidate"), default="candidate")
    args = parser.parse_args()
    if args.require_enabled and args.release_policy is None:
        parser.error("--release-policy is required with --require-enabled")
    if args.require_enabled and args.validate_policy:
        parser.error("--require-enabled cannot be used with --validate-policy")
    if not args.validate_policy:
        required = ("spec", "dataset", "baseline_result", "candidate_result")
        missing = [
            name.replace("_", "-")
            for name in required
            if getattr(args, name) is None
        ]
        if missing:
            parser.error("missing required gate arguments: " + ", ".join(missing))
    return args


def load_json(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        value = json.load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain one JSON object")
    return value


def load_policy(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        value = yaml.safe_load(handle)
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain one YAML mapping")
    return value


def validate_policy(policy: dict[str, Any], phase: str) -> None:
    if policy.get("implementation_session") != IMPLEMENTATION_SESSION:
        raise ValueError("Threshold policy has the wrong implementation_session marker")
    rules = policy.get("rules")
    if not isinstance(rules, list) or not rules:
        raise ValueError("Threshold policy needs at least one metric rule")
    names: set[str] = set()
    blocking_layers: set[str] = set()
    for rule in rules:
        name = str(rule.get("metric", ""))
        layer = str(rule.get("layer", ""))
        if not name or name in names:
            raise ValueError("Threshold metric names must be present and unique")
        names.add(name)
        if layer not in LAYERS:
            raise ValueError(f"{name} has an unknown metric layer")
        if bool(rule.get("preview")) and bool(rule.get("blocking")):
            raise ValueError(f"Preview metric {name} cannot block release")
        maximum_errored = rule.get("maximum_errored")
        if not isinstance(maximum_errored, int) or maximum_errored < 0:
            raise ValueError(
                f"{name}.maximum_errored must be a nonnegative integer"
            )
        minimum = rule.get("minimum_pass_rate")
        if minimum is not None and (
            isinstance(minimum, bool)
            or not isinstance(minimum, (int, float))
            or float(minimum) < 0
            or float(minimum) > 1
        ):
            raise ValueError(
                f"{name}.minimum_pass_rate must be null or between 0 and 1"
            )
        regression_floor = rule.get("regression_floor")
        if regression_floor is not None:
            floor = regression_floor.get("minimum_pass_rate")
            if floor is not None and (
                isinstance(floor, bool)
                or not isinstance(floor, (int, float))
                or float(floor) < 0
                or float(floor) > 1
            ):
                raise ValueError(
                    f"{name}.regression_floor.minimum_pass_rate must be null or between 0 and 1"
                )
            if regression_floor.get("retained_in") != "eval/thresholds.yaml":
                raise ValueError(f"{name} regression floor must be saved in eval/thresholds.yaml")
            if phase == "candidate":
                if floor is None or not regression_floor.get("approved_by") or not regression_floor.get("approved_on"):
                    raise ValueError(
                        f"Candidate policy needs an approved metric-specific regression floor for {name}"
                    )
                if minimum is not None and float(minimum) < float(floor):
                    raise ValueError(
                        f"Threshold for {name} is below its approved regression floor"
                    )
        if bool(rule.get("blocking")):
            blocking_layers.add(layer)
            if phase == "candidate" and minimum is None:
                raise ValueError(
                    f"Candidate policy needs a baseline-derived threshold for {name}"
                )
            if phase == "candidate" and float(minimum) <= 0:
                raise ValueError(
                    f"Blocking threshold for {name} must be greater than zero"
                )
    if phase == "candidate":
        baseline = policy.get("baseline") or {}
        if not baseline.get("source_run_id") or not baseline.get("established_on"):
            raise ValueError(
                "Candidate policy needs the approved baseline run ID and establishment date"
            )
        if policy.get("policy_state") != "active":
            raise ValueError("Candidate policy_state must be active")
        if blocking_layers != LAYERS:
            raise ValueError(
                "Candidate policy must block independently on final-answer, "
                "tool-process, and safety layers"
            )
    exception = policy.get("exception") or {}
    if exception.get("may_override_safety_failure") is not False:
        raise ValueError("The exception policy must not override safety failures")
    if exception.get("may_override_tool_process_failure") is not False:
        raise ValueError("The exception policy must not override tool-process failures")


def validate_record(
    record: dict[str, Any],
    label: str,
) -> dict[str, dict[str, Any]]:
    if record.get("implementationSession") != IMPLEMENTATION_SESSION:
        raise ValueError(
            f"{label} record has the wrong implementationSession marker"
        )
    run = record.get("run") or {}
    if run.get("status") != "completed":
        raise ValueError(f"{label} run is not completed")
    privacy = record.get("privacy") or {}
    if any(
        privacy.get(field) is not False
        for field in (
            "containsQueries",
            "containsResponses",
            "containsToolPayloads",
            "containsEvaluatorReasons",
        )
    ):
        raise ValueError(f"{label} record is not payload-free")
    metrics = record.get("metrics")
    if not isinstance(metrics, list) or not metrics:
        raise ValueError(f"{label} record has no aggregate metrics")
    by_name: dict[str, dict[str, Any]] = {}
    for metric in metrics:
        name = str(metric.get("name", ""))
        if not name or name in by_name:
            raise ValueError(f"{label} metric names must be present and unique")
        if metric.get("layer") not in LAYERS:
            raise ValueError(f"{label} metric {name} has an unknown layer")
        passed = metric.get("passed")
        failed = metric.get("failed")
        errored = metric.get("errored")
        total = metric.get("total")
        if not all(
            isinstance(value, int) and value >= 0
            for value in (passed, failed, errored, total)
        ):
            raise ValueError(f"{label} metric {name} has invalid counts")
        if passed + failed + errored != total:
            raise ValueError(f"{label} metric {name} counts do not equal total")
        expected_rate = round(passed / (passed + failed), 6) if passed + failed else 0.0
        if abs(float(metric.get("passRate", -1)) - expected_rate) > 0.000001:
            raise ValueError(f"{label} metric {name} has an invalid passRate")
        by_name[name] = metric
    return by_name


def validate_activation(
    release_policy: dict[str, Any],
    threshold_policy: dict[str, Any],
    baseline: dict[str, Any],
    candidate: dict[str, Any],
) -> None:
    if release_policy.get("implementationSession") != IMPLEMENTATION_SESSION:
        raise ValueError("Release policy has the wrong implementationSession marker")
    gate = release_policy.get("gate") or {}
    contract = release_policy.get("activationContract") or {}
    expected_contract = {
        "requiredState": "enabled",
        "requiredDecision": "approved",
        "decisionDateRequired": True,
        "thresholdPolicyState": "active",
        "thresholdPolicyPath": "implementation/artifacts/eval/thresholds.yaml",
        "baselineRunIdMustMatchThresholdPolicyAndBaselineRecord": True,
        "candidateRunIdMustMatchCandidateRecord": True,
    }
    if release_policy.get("schemaVersion") != 2 or contract != expected_contract:
        raise ValueError("Release policy activationContract is incomplete or unsupported")
    if gate.get("state") != contract.get("requiredState") or gate.get("state") != "enabled":
        raise ValueError("Release policy gate.state must be enabled")
    if gate.get("decision") != contract.get("requiredDecision") or gate.get("decision") != "approved":
        raise ValueError("Release policy gate.decision must be approved")
    decision_date = gate.get("decisionDate")
    if contract.get("decisionDateRequired") is not True or not decision_date:
        raise ValueError("Release policy needs an approved decision date")
    try:
        parsed_date = date.fromisoformat(str(decision_date))
    except ValueError as exc:
        raise ValueError("Release policy decisionDate must use YYYY-MM-DD") from exc
    if parsed_date > date.today():
        raise ValueError("Release policy decisionDate cannot be in the future")
    if threshold_policy.get("policy_state") != contract.get("thresholdPolicyState"):
        raise ValueError("Threshold policy must be active")
    baseline_run_id = baseline.get("run", {}).get("runId")
    candidate_run_id = candidate.get("run", {}).get("runId")
    threshold_baseline_run_id = threshold_policy.get("baseline", {}).get(
        "source_run_id"
    )
    if not baseline_run_id or not candidate_run_id:
        raise ValueError("Baseline and candidate records need run IDs")
    if (
        contract.get("baselineRunIdMustMatchThresholdPolicyAndBaselineRecord")
        is not True
        or gate.get("baselineRunId") != baseline_run_id
        or threshold_baseline_run_id != baseline_run_id
    ):
        raise ValueError(
            "Release policy, threshold policy, and baseline record run IDs must match"
        )
    if (
        contract.get("candidateRunIdMustMatchCandidateRecord") is not True
        or gate.get("candidateRunId") != candidate_run_id
    ):
        raise ValueError("Release policy and candidate record run IDs must match")


def evaluate_metrics(
    policy: dict[str, Any],
    configured: dict[str, dict[str, Any]],
    baseline_metrics: dict[str, dict[str, Any]],
    candidate_metrics: dict[str, dict[str, Any]],
) -> tuple[str, dict[str, list[str]], list[str]]:
    reasons: list[str] = []
    layer_status: dict[str, list[str]] = defaultdict(list)
    for rule in policy["rules"]:
        name = rule["metric"]
        if name not in configured:
            raise ValueError(
                f"Threshold metric {name} is not in the evaluation specification"
            )
        if name not in baseline_metrics or name not in candidate_metrics:
            raise ValueError(f"Release records are missing metric {name}")
        if configured[name]["layer"] != rule["layer"]:
            raise ValueError(f"Metric layer mismatch for {name}")
        candidate_metric = candidate_metrics[name]
        status = "advisory"
        if bool(rule["blocking"]):
            failures: list[str] = []
            if candidate_metric["errored"] > rule["maximum_errored"]:
                failures.append(
                    f"{candidate_metric['errored']} errored > "
                    f"{rule['maximum_errored']}"
                )
            if candidate_metric["passRate"] < float(rule["minimum_pass_rate"]):
                failures.append(
                    f"{candidate_metric['passRate']:.3f} < "
                    f"{float(rule['minimum_pass_rate']):.3f}"
                )
            if failures:
                status = "blocked"
                reasons.append(f"{rule['layer']}/{name}: " + ", ".join(failures))
            else:
                status = "passed"
        layer_status[rule["layer"]].append(
            f"{name}={candidate_metric['passRate']:.3f} [{status}]"
        )
    return ("block" if reasons else "pass"), layer_status, reasons


def main() -> int:
    args = parse_args()
    policy = load_policy(args.policy.resolve())
    validate_policy(policy, args.phase)
    if args.validate_policy:
        print(f"PASS: threshold policy is valid for the {args.phase} phase.")
        return 0

    spec = load_json(args.spec.resolve())
    baseline = load_json(args.baseline_result.resolve())
    candidate = load_json(args.candidate_result.resolve())
    if args.require_enabled:
        release_policy = load_json(args.release_policy.resolve())
        validate_activation(release_policy, policy, baseline, candidate)
    if spec.get("implementationSession") != IMPLEMENTATION_SESSION:
        raise ValueError(
            "Evaluation specification has the wrong implementationSession marker"
        )

    dataset_hash = hashlib.sha256(args.dataset.resolve().read_bytes()).hexdigest()
    for label, record in (("baseline", baseline), ("candidate", candidate)):
        dataset = record.get("dataset") or {}
        if dataset.get("sha256") != dataset_hash:
            raise ValueError(
                f"{label} record does not use the current golden dataset"
            )
        if dataset.get("name") != spec["dataset"]["name"]:
            raise ValueError(f"{label} record has the wrong dataset name")

    if baseline["run"]["runId"] != policy["baseline"]["source_run_id"]:
        raise ValueError(
            "Threshold policy does not reference the supplied baseline run"
        )
    if baseline["run"]["target"]["version"] != spec["target"]["approvedVersion"]:
        raise ValueError("Baseline record does not target the approved version")
    expected_version = (
        spec["target"]["approvedVersion"]
        if args.evaluated_target == "approved"
        else spec["target"]["candidateVersion"]
    )
    if candidate["run"]["target"]["version"] != expected_version:
        raise ValueError(
            f"Evaluated record does not target the approved {args.evaluated_target} version"
        )
    if (
        baseline["run"]["target"]["name"] != spec["target"]["agentName"]
        or candidate["run"]["target"]["name"] != spec["target"]["agentName"]
    ):
        raise ValueError("Release records do not target the approved agent")

    baseline_metrics = validate_record(baseline, "baseline")
    candidate_metrics = validate_record(candidate, "candidate")
    configured = {item["name"]: item for item in spec["evaluators"]}
    outcome, layer_status, reasons = evaluate_metrics(
        policy,
        configured,
        baseline_metrics,
        candidate_metrics,
    )
    print(f"Release gate outcome: {outcome.upper()}")
    for layer in sorted(layer_status):
        print(f"  {layer}: {', '.join(layer_status[layer])}")
    for reason in reasons:
        print(f"  BLOCK: {reason}")
    if outcome != args.expect:
        print(
            f"ERROR: expected {args.expect.upper()} but observed {outcome.upper()}",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
