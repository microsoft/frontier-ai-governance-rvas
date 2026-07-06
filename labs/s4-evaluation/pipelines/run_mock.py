#!/usr/bin/env python3
"""Offline mock-target evaluator for RVAS S4.

Loads the bundled JSONL dataset, sends each query to a deterministic in-memory
mock target, computes local quality metrics, writes a scorecard to evidence, and
exits non-zero when a metric is below threshold.

Usage:
    python run_mock.py [dataset.jsonl] [thresholds.json]

Static-only: no network, Azure SDK, or tenant calls. Safe to run in CI.
"""
from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from statistics import mean
from typing import Any

KIT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DATASET = KIT_ROOT / "data" / "eval-dataset.jsonl"
DEFAULT_THRESHOLDS = KIT_ROOT / "policies" / "thresholds.json"
DEFAULT_EVIDENCE = KIT_ROOT / "evidence" / "eval-results.json"
TOKEN_RE = re.compile(r"[a-z0-9]+")
STOPWORDS = {
    "a",
    "an",
    "and",
    "are",
    "as",
    "be",
    "before",
    "by",
    "for",
    "in",
    "is",
    "it",
    "of",
    "or",
    "the",
    "to",
    "use",
    "used",
    "when",
    "with",
}


@dataclass(frozen=True)
class EvalCase:
    case_id: str
    query: str
    response: str
    ground_truth: str


@dataclass(frozen=True)
class CaseScore:
    case_id: str
    query: str
    response: str
    ground_truth: str
    metrics: dict[str, float]


def tokenize(text: str) -> list[str]:
    return TOKEN_RE.findall(text.lower())


def normalize(text: str) -> str:
    return " ".join(tokenize(text))


def exact_match(response: str, ground_truth: str) -> float:
    return 1.0 if normalize(response) == normalize(ground_truth) else 0.0


def f1(response: str, ground_truth: str) -> float:
    predicted = tokenize(response)
    expected = tokenize(ground_truth)
    if not predicted or not expected:
        return 0.0
    expected_counts: dict[str, int] = {}
    for token in expected:
        expected_counts[token] = expected_counts.get(token, 0) + 1
    overlap = 0
    for token in predicted:
        if expected_counts.get(token, 0) > 0:
            overlap += 1
            expected_counts[token] -= 1
    if overlap == 0:
        return 0.0
    precision = overlap / len(predicted)
    recall = overlap / len(expected)
    return 2 * precision * recall / (precision + recall)


def keyword_groundedness(response: str, ground_truth: str) -> float:
    expected_keywords = {token for token in tokenize(ground_truth) if token not in STOPWORDS}
    if not expected_keywords:
        return 1.0
    response_tokens = set(tokenize(response))
    return len(expected_keywords & response_tokens) / len(expected_keywords)


def load_dataset(path: Path) -> list[EvalCase]:
    if not path.exists():
        raise SystemExit(f"dataset not found: {path}")
    cases: list[EvalCase] = []
    for line_number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not raw.strip():
            continue
        row = json.loads(raw)
        missing = {"query", "response", "ground_truth"} - row.keys()
        if missing:
            raise SystemExit(f"{path}:{line_number} missing fields: {', '.join(sorted(missing))}")
        cases.append(
            EvalCase(
                case_id=f"case-{line_number:03d}",
                query=str(row["query"]),
                response=str(row["response"]),
                ground_truth=str(row["ground_truth"]),
            )
        )
    if not cases:
        raise SystemExit(f"dataset has no cases: {path}")
    return cases


def load_thresholds(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"thresholds not found: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    metrics = data.get("metrics")
    aggregate = data.get("aggregate")
    if not isinstance(metrics, dict) or not isinstance(aggregate, int | float):
        raise SystemExit("thresholds must include metrics object and aggregate number")
    return {"metrics": {str(k): float(v) for k, v in metrics.items()}, "aggregate": float(aggregate)}


def mock_target(case: EvalCase) -> str:
    """Return the deterministic stub response bundled with the dataset."""
    return case.response


def score_case(case: EvalCase) -> CaseScore:
    response = mock_target(case)
    return CaseScore(
        case_id=case.case_id,
        query=case.query,
        response=response,
        ground_truth=case.ground_truth,
        metrics={
            "exact_match": exact_match(response, case.ground_truth),
            "f1": f1(response, case.ground_truth),
            "keyword_groundedness": keyword_groundedness(response, case.ground_truth),
        },
    )


def aggregate(scores: list[CaseScore]) -> dict[str, float]:
    names = scores[0].metrics.keys()
    metric_scores = {name: mean(score.metrics[name] for score in scores) for name in names}
    metric_scores["aggregate"] = mean(metric_scores.values())
    return metric_scores


def failures(metrics: dict[str, float], thresholds: dict[str, Any]) -> list[str]:
    failed: list[str] = []
    metric_thresholds: dict[str, float] = thresholds["metrics"]
    for name, threshold in metric_thresholds.items():
        score = metrics.get(name)
        if score is None:
            failed.append(f"{name}: missing metric (threshold {threshold:.2f})")
        elif score < threshold:
            failed.append(f"{name}: {score:.3f} < {threshold:.3f}")
    aggregate_threshold = thresholds["aggregate"]
    if metrics["aggregate"] < aggregate_threshold:
        failed.append(f"aggregate: {metrics['aggregate']:.3f} < {aggregate_threshold:.3f}")
    return failed


def write_evidence(
    output: Path,
    dataset: Path,
    threshold_path: Path,
    scores: list[CaseScore],
    metrics: dict[str, float],
    thresholds: dict[str, Any],
    failed: list[str],
) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "dataset": str(dataset),
        "thresholds_file": str(threshold_path),
        "status": "pass" if not failed else "fail",
        "aggregate_metrics": metrics,
        "thresholds": thresholds,
        "failures": failed,
        "cases": [
            {
                "case_id": score.case_id,
                "query": score.query,
                "response": score.response,
                "ground_truth": score.ground_truth,
                "metrics": score.metrics,
            }
            for score in scores
        ],
    }
    output.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def print_scorecard(metrics: dict[str, float], thresholds: dict[str, Any], failed: list[str]) -> None:
    print("\nRVAS S4 Mock Evaluation Scorecard\n" + "=" * 38)
    for name, score in metrics.items():
        threshold = thresholds["aggregate"] if name == "aggregate" else thresholds["metrics"].get(name, 0.0)
        status = "PASS" if score >= threshold else "FAIL"
        print(f"{name:<22} {score:.3f}  threshold {threshold:.3f}  {status}")
    print("-" * 38)
    if failed:
        print("FAIL: " + "; ".join(failed))
    else:
        print("PASS: all metrics meet configured thresholds")


def main(argv: list[str]) -> int:
    dataset = Path(argv[1]) if len(argv) > 1 else DEFAULT_DATASET
    threshold_path = Path(argv[2]) if len(argv) > 2 else DEFAULT_THRESHOLDS
    thresholds = load_thresholds(threshold_path)
    cases = load_dataset(dataset)
    scores = [score_case(case) for case in cases]
    metrics = aggregate(scores)
    failed = failures(metrics, thresholds)
    write_evidence(DEFAULT_EVIDENCE, dataset, threshold_path, scores, metrics, thresholds, failed)
    print_scorecard(metrics, thresholds, failed)
    print(f"Evidence: {DEFAULT_EVIDENCE}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
