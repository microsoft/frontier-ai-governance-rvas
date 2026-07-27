# Readiness Assessment

!!! info "Freshness"
    Last reviewed: 2026-07-06

Use the S0-S13 AI maturity assessment twice:

- **S0 - baseline.** Record the current state and create the prioritized session roadmap.
- **S13 - exit score.** Re-run the same assessment, compare it with the baseline, and record the remaining gaps.

## How it works

The assessment has fourteen domains. Each domain maps to one S0-S13 session and uses a 1-4 maturity scale. Blank answers stay visible and do not count toward weighted maturity until assessed.

| Level | Name | Meaning |
|-------|------|---------|
| 1 | Ad-hoc | No consistent control; reactive |
| 2 | Repeatable | Some controls exist but are manual or inconsistent |
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
| D12 | LLM operations (S12) |
| D13 | Portfolio governance (S13) |

## Fillable scorecard

The scorecard and auto-scorer are in the S0 takeaway kit:

- `labs/s0-foundations/optional/assessment/scorecard.csv` - fill the `score` column (1-4) with accountable stakeholders.
- `labs/s0-foundations/optional/assessment/score.py` - computes per-domain and overall weighted maturity and ranks lower-scoring domains first; total question weight breaks ties.
- `labs/s0-foundations/optional/assessment/compare.py` - at S13, computes the weighted baseline-to-exit lift per domain and the residual-gap backlog.

```bash
python labs/s0-foundations/optional/assessment/score.py labs/s0-foundations/optional/assessment/scorecard.csv
```

## Reading the result

![How the S0 baseline becomes a session plan: fill scorecard.csv (1-4 per question), run score.py, review per-domain and overall maturity, then agree the delivery order with accountable stakeholders.](../assets/diagrams/assessment.svg)

Session artifacts support reassessment. Change a score only when accountable stakeholders show the relevant control is in place and operating.
