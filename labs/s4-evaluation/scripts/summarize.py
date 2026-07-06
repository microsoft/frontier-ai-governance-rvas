#!/usr/bin/env python3
"""Render the S4 evaluation evidence JSON as a compact table."""
from __future__ import annotations

import json
import sys
from pathlib import Path

DEFAULT_RESULTS = Path(__file__).resolve().parents[1] / "evidence" / "eval-results.json"


def main(argv: list[str]) -> int:
    path = Path(argv[1]) if len(argv) > 1 else DEFAULT_RESULTS
    if not path.exists():
        raise SystemExit(f"results not found: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    metrics = data.get("aggregate_metrics", {})
    thresholds = data.get("thresholds", {})
    metric_thresholds = thresholds.get("metrics", {})

    print(f"\nRVAS S4 Evaluation Evidence — {data.get('status', 'unknown').upper()}\n" + "=" * 58)
    for name, score in metrics.items():
        threshold = thresholds.get("aggregate") if name == "aggregate" else metric_thresholds.get(name)
        threshold_text = "n/a" if threshold is None else f"{float(threshold):.3f}"
        print(f"{name:<24} {float(score):.3f}  threshold {threshold_text}")
    print("-" * 58)
    for case in data.get("cases", []):
        case_metrics = case.get("metrics", {})
        summary = ", ".join(f"{key}={float(value):.2f}" for key, value in case_metrics.items())
        print(f"{case.get('case_id')}: {summary}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
