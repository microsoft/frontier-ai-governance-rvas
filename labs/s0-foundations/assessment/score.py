#!/usr/bin/env python3
"""Auto-scorer for the RVAS AI governance maturity assessment.

Reads a scorecard CSV (see scorecard.csv) where each row has a 1-4 ``score``
and a ``weight``. Prints per-domain weighted maturity, overall maturity, and a
prioritized session roadmap (lowest maturity + highest weight first).

Usage:
    python score.py [path/to/scorecard.csv]

Static-only: no network or tenant calls. Safe to run in CI.
"""
from __future__ import annotations

import csv
import sys
from collections import OrderedDict
from dataclasses import dataclass, field
from pathlib import Path

MIN_SCORE, MAX_SCORE = 1, 4

# Domain -> the session that closes its gaps.
DOMAIN_TO_SESSION = {
    "D0": "S0 Foundations & Operating Model",
    "D1": "S1 Identity & Access",
    "D2": "S2 Data & Compliance",
    "D3": "S3 Security Posture & Runtime",
    "D4": "S4 Quality & Safety Evaluation",
    "D5": "S5 Adversarial Testing",
    "D6": "S6 Control Plane & Operationalization",
}


@dataclass
class Domain:
    code: str
    name: str
    weighted_sum: float = 0.0
    weight_total: float = 0.0
    answered: int = 0
    total: int = 0
    unanswered: list[str] = field(default_factory=list)

    @property
    def maturity(self) -> float | None:
        if self.weight_total == 0:
            return None
        return self.weighted_sum / self.weight_total


def load(path: Path) -> "OrderedDict[str, Domain]":
    domains: "OrderedDict[str, Domain]" = OrderedDict()
    with path.open(newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        required = {"domain", "domain_name", "question_id", "weight", "score"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise SystemExit(f"scorecard missing columns: {', '.join(sorted(missing))}")
        for row in reader:
            code = row["domain"].strip()
            dom = domains.setdefault(code, Domain(code=code, name=row["domain_name"].strip()))
            dom.total += 1
            weight = float(row["weight"]) if row["weight"].strip() else 1.0
            raw = row["score"].strip()
            if not raw:
                dom.unanswered.append(row["question_id"].strip())
                continue
            score = float(raw)
            if not (MIN_SCORE <= score <= MAX_SCORE):
                raise SystemExit(
                    f"{row['question_id']}: score {score} out of range {MIN_SCORE}-{MAX_SCORE}"
                )
            dom.weighted_sum += score * weight
            dom.weight_total += weight
            dom.answered += 1
    return domains


def bar(value: float, width: int = 20) -> str:
    filled = round((value - MIN_SCORE) / (MAX_SCORE - MIN_SCORE) * width)
    return "█" * filled + "·" * (width - filled)


def main(argv: list[str]) -> int:
    path = Path(argv[1]) if len(argv) > 1 else Path(__file__).with_name("scorecard.csv")
    if not path.exists():
        raise SystemExit(f"scorecard not found: {path}")
    domains = load(path)

    print(f"\nRVAS AI Governance Maturity — {path.name}\n" + "=" * 52)
    scored = [d for d in domains.values() if d.maturity is not None]
    for dom in domains.values():
        if dom.maturity is None:
            print(f"{dom.code} {dom.name:<38} —   (unanswered)")
        else:
            print(
                f"{dom.code} {dom.name:<38} {dom.maturity:.2f}  [{bar(dom.maturity)}]"
                + (f"  ({len(dom.unanswered)} blank)" if dom.unanswered else "")
            )

    if not scored:
        print("\nNo questions answered yet — fill the 'score' column (1-4).")
        return 1

    overall = sum(d.weighted_sum for d in scored) / sum(d.weight_total for d in scored)
    print("-" * 52)
    print(f"Overall maturity: {overall:.2f} / {MAX_SCORE}  [{bar(overall)}]")

    print("\nPrioritized roadmap (lowest maturity + highest weight first):")
    ranked = sorted(scored, key=lambda d: (d.maturity, -d.weight_total))
    for rank, dom in enumerate(ranked, 1):
        gap = MAX_SCORE - (dom.maturity or MAX_SCORE)
        flag = "  ← start here" if rank == 1 else ""
        print(
            f"  {rank}. {DOMAIN_TO_SESSION.get(dom.code, dom.code)}"
            f"  (maturity {dom.maturity:.2f}, gap {gap:.2f}){flag}"
        )

    blanks = [q for d in domains.values() for q in d.unanswered]
    if blanks:
        print(f"\nNote: {len(blanks)} unanswered question(s): {', '.join(blanks)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
