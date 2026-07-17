# Performance test plan (pre-production synthetic load)

Copy this blank plan into the customer's approved records system. It is an
optional S7 addendum for bounded synthetic load testing before release. It
records customer-owned targets, the workload model, environment fidelity, and
ownership; it does not run a load test, provision a load service, or set a
production service-level objective.

See the [agent performance-testing guide](../../../docs/reference/performance-testing-guide.md)
for the metric taxonomy and the two-evidence-source model.

## Bounded scenario and workload model

| Field | Record |
|---|---|
| Interaction type and user population | |
| Streaming on / off | |
| Concurrency / arrival profile and ramp | |
| Test duration and think time | |
| Prompt / payload mix and representativeness | |
| Load run owner | |
| Evidence location and review date | |

## Metric targets

| Metric | Target | Evidence reference | Coverage / attribution limit |
|---|---|---|---|
| Time to first token / first byte (p50 / p95 / p99) | | | |
| Inter-token latency / tokens per second | | | |
| End-to-end latency (p50 / p95 / p99) | | | |
| Throughput / concurrency / requests per second | | | |
| Error rate & saturation (429 / timeout) | | | |
| Per-component attribution (model / retrieval / tool / orchestration / gateway) | | | |

A benchmark is not a service-level objective. The customer owns the baseline,
the interpretation, and any release-decision use.

## Environment and fidelity

| Field | Record |
|---|---|
| Test-versus-production parity | |
| Model deployment, quota, and PTU ceiling | |
| Data residency and dataset parity | |
| Downstream tools / retrieval: live or stubbed | |
| Load-run cost and rate-limit / quota risk to shared deployments | |

## Load engine reference

| Field | Record |
|---|---|
| Load engine (e.g. Azure Load Testing; k6 / JMeter are alternatives) | |
| Who runs the load test | |
| Where results and run configuration are stored | |
| Correlation reference to runtime / gateway telemetry | |

This kit references the load engine and its outputs as customer evidence. It
does not run the engine or provision the service.

## Baseline and interpretation

| Field | Record |
|---|---|
| Baseline version, model, and dataset references | |
| Current version and comparison reference | |
| Regression owner and hold / escalation route | |
| Interpretation owner | |
| Linkage to the S7 assurance outcome | |

## Implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Later session or customer process |
|---|---|---|---|---|---|
| Workload model and synthetic-load coverage | | | | | Customer engineering / platform operations |
| First-token and end-to-end target evidence source | | | | | Customer evaluation process |
| Environment fidelity and quota / PTU risk | | | | | Platform operations |
| Regression baseline, threshold, and release-decision owner | | | | | Customer release process |
| Production reconciliation handoff for performance drift | | | | | S11 |
