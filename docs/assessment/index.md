# Readiness Assessment

!!! info "Freshness"
    Last reviewed: 2026-07-06

A single, reusable **S0-S12 AI maturity assessment**. Run it twice:

- **S0 - baseline.** Establishes the current state and produces a prioritized session roadmap.
- **S12 - exit score.** Re-run the same instrument to compare the current state with the baseline and record the remaining gaps.

## How it works

Thirteen domains map directly to the canonical S0-S12 sessions. Each is scored on a 1–4 maturity scale. Blank answers remain visible and are excluded from weighted maturity until assessed.

| Level | Name | Meaning |
|-------|------|---------|
| 1 | Ad-hoc | No consistent control; reactive |
| 2 | Repeatable | Some controls exist but are manual / inconsistent |
| 3 | Defined | Documented, enforced, and owned |
| 4 | Optimized | Automated, measured, and continuously improved |

### Domains

| # | Domain (canonical session) |
|---|------------------------------|
| D0 | Operating model (S0) |
| D1 | Identity / authority (S1) |
| D2 | Data (S2) |
| D3 | Platform / trust boundaries (S3) |
| D4 | Engineering / admission (S4) |
| D5 | Tool / API / MCP (S5) |
| D6 | Runtime security (S6) |
| D7 | Evaluation / release (S7) |
| D8 | Adversarial testing (S8) |
| D9 | Control plane / lifecycle (S9) |
| D10 | In-process governance (S10) |
| D11 | Operate / monitor / FinOps (S11) |
| D12 | Portfolio governance (S12) |

## Fillable scorecard

The scorecard and auto-scorer live in the S0 takeaway kit:

- `labs/s0-foundations/assessment/scorecard.csv` - fill the `score` column (1–4) with accountable stakeholders.
- `labs/s0-foundations/assessment/score.py` - computes per-domain and overall weighted maturity and ranks lower-scoring domains first; total question weight breaks ties.
- `labs/s0-foundations/assessment/compare.py` - at S12, computes the weighted baseline-to-exit lift per domain and the residual-gap backlog.

```bash
python labs/s0-foundations/assessment/score.py labs/s0-foundations/assessment/scorecard.csv
```

## Reading the result

![How the S0 baseline becomes a session plan: fill scorecard.csv (1–4 per question), run score.py, review per-domain and overall maturity, then agree the delivery order with accountable stakeholders.](../assets/diagrams/assessment.svg)

Session artifacts provide evidence for reassessing specific questions. Change a score only when accountable stakeholders can show that the relevant control is in place and operating.
