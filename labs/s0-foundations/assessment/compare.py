#!/usr/bin/env python3
"""Compare an S0 baseline scorecard against an S12 exit scorecard.

Computes per-domain and overall maturity lift and prints a residual-gap backlog
(domains still below a target maturity at exit). Reuses the loader and domain
mapping from ``score.py`` so the two tools stay consistent.

Usage:
    python compare.py <baseline.csv> <exit.csv> [--target 3.0]

Static-only: no network or tenant calls. Safe to run in CI.
"""
from __future__ import annotations

import sys
from pathlib import Path

from score import DOMAIN_TO_SESSION, MAX_SCORE, MIN_SCORE, bar, load


def parse_args(argv: list[str]) -> tuple[Path, Path, float]:
    args = [a for a in argv[1:] if not a.startswith("--")]
    target = 3.0
    for a in argv[1:]:
        if a.startswith("--target"):
            _, _, val = a.partition("=")
            if val:
                target = float(val)
            else:
                idx = argv.index(a)
                if idx + 1 < len(argv):
                    target = float(argv[idx + 1])
    if len(args) < 2:
        raise SystemExit("usage: python compare.py <baseline.csv> <exit.csv> [--target N]")
    return Path(args[0]), Path(args[1]), target


def main(argv: list[str]) -> int:
    baseline_path, exit_path, target = parse_args(argv)
    for p in (baseline_path, exit_path):
        if not p.exists():
            raise SystemExit(f"scorecard not found: {p}")

    baseline = load(baseline_path)
    exit_ = load(exit_path)

    print(f"\nS0-S12 Maturity Lift — baseline: {baseline_path.name} -> exit: {exit_path.name}")
    print("=" * 64)
    print(f"{'Domain':<40}{'Base':>6}{'Exit':>6}{'Lift':>7}")
    print("-" * 64)

    codes = list(dict.fromkeys(list(baseline.keys()) + list(exit_.keys())))
    base_weighted_sum = 0.0
    base_weight_total = 0.0
    exit_weighted_sum = 0.0
    exit_weight_total = 0.0
    backlog: list[tuple[str, float]] = []

    for code in codes:
        b = baseline.get(code)
        e = exit_.get(code)
        b_m = b.maturity if b else None
        e_m = e.maturity if e else None
        name = (e or b).name if (e or b) else code
        b_str = f"{b_m:.2f}" if b_m is not None else "—"
        e_str = f"{e_m:.2f}" if e_m is not None else "—"
        if b_m is not None and e_m is not None:
            lift = e_m - b_m
            base_weighted_sum += b.weighted_sum
            base_weight_total += b.weight_total
            exit_weighted_sum += e.weighted_sum
            exit_weight_total += e.weight_total
            arrow = "▲" if lift > 0 else ("▼" if lift < 0 else "=")
            print(f"{code} {name:<36}{b_str:>6}{e_str:>6}{lift:>+6.2f} {arrow}")
            if e_m < target:
                backlog.append((code, e_m))
        else:
            print(f"{code} {name:<36}{b_str:>6}{e_str:>6}{'—':>7}")

    if base_weight_total and exit_weight_total:
        b_overall = base_weighted_sum / base_weight_total
        e_overall = exit_weighted_sum / exit_weight_total
        print("-" * 64)
        print(
            f"{'Overall':<40}{b_overall:>6.2f}{e_overall:>6.2f}{e_overall - b_overall:>+6.2f}"
        )
        print(f"\nExit posture: {e_overall:.2f}/{MAX_SCORE}  [{bar(e_overall)}]")

    print(f"\nResidual-gap backlog (domains below target {target:.1f} at exit):")
    if not backlog:
        print("  none — all measured domains meet or exceed target. 🎉")
    else:
        for code, m in sorted(backlog, key=lambda x: x[1]):
            gap = target - m
            print(
                f"  - {DOMAIN_TO_SESSION.get(code, code)}"
                f"  (exit {m:.2f}, {gap:.2f} below target)"
            )

    # Guard: keep MIN_SCORE referenced so intent is explicit for readers/linters.
    assert MIN_SCORE <= target <= MAX_SCORE, "target must be within the 1-4 scale"
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
