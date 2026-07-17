# Production performance-telemetry review

Use this optional addendum with the operating-review template when production
agent performance — first-token latency, end-to-end latency, throughput, or
error/saturation under real traffic — is in scope. It references customer-held
telemetry only; it does not query live data, create a dashboard, or draw a
conclusion from an incomplete sample.

See the [agent performance-testing guide](../../../docs/reference/performance-testing-guide.md)
for the metric taxonomy and the synthetic-versus-production model. Pair this with
the S7 `performance-test-plan.template.md` baseline where one exists.

## Scope and accountability

| Field | Record |
|---|---|
| Bounded population and review period | |
| Telemetry source (OpenTelemetry / Application Insights / Foundry traces) | |
| Sampling, retention, and correlation reference | |
| Performance owner | |
| Interpretation owner | |
| Review cadence | |

## Production performance observations

| Metric | Prior-period reference | Current-period reference | Observation | Coverage / sampling limit | Interpretation owner | Decision or escalation |
|---|---|---|---|---|---|---|
| Time to first token / first byte (p95) | | | | | | |
| End-to-end latency (p95 / p99) | | | | | | |
| Throughput / concurrency | | | | | | |
| Error rate & saturation (429 / timeout) | | | | | | |
| Per-component attribution | | | | | | |

An uninstrumented or excluded path is a coverage gap, not a zero result.

## Synthetic baseline reconciliation

| Field | Record |
|---|---|
| S7 synthetic baseline reference | |
| Production-versus-synthetic gap observed | |
| Drift hypothesis (workload mix / config / model version / quota / coverage) | |
| Alternative explanation | |
| Test or observation plan | |
| Owner and escalation trigger | |

A production-versus-synthetic gap is a drift hypothesis, not confirmed drift.

## Implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Later session or customer process |
|---|---|---|---|---|---|
| Production performance telemetry coverage (OTel / App Insights / Foundry) | | | | | Platform operations |
| First-token / end-to-end / saturation observation or attribution gap | | | | | Platform operations |
| Synthetic-baseline reconciliation and drift investigation | | | | | Evaluation / S7 handoff |
| Alert route and recurrence check for performance regression | | | | | Customer operating process |
