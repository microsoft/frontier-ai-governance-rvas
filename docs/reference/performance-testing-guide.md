# Agent performance-testing governance

!!! info "Freshness"
    Last reviewed: 2026-07-17. Verify capability, service availability, region,
    quota, and pricing before delivery.

Use this guide with S4, S7, and S11 to turn agent performance questions —
"how fast is first response?", "does it hold up under load?", "is production
drifting?" — into customer-owned records. It does not run a load test, query
live telemetry, set a service-level objective, or authorize a production change.

Agent performance is governed with **two complementary evidence sources, never
one**:

1. **Pre-production synthetic load** (S7) — a bounded workload run against a
   test environment to observe behaviour under controlled concurrency before
   release.
2. **Production telemetry** (S11) — OpenTelemetry, Application Insights, or
   Foundry traces on real traffic, reconciled against the synthetic baseline.

A synthetic benchmark is not a production service-level objective, and a
production sample is not a controlled experiment. Each source has a different
population; record both and record what neither can attribute.

## Metric taxonomy

Record targets and evidence against a shared metric vocabulary. For a streaming
agent, an end-to-end p95 alone hides the experience: measure first-token latency
separately.

| Metric | What it captures | Why it matters for agents |
|---|---|---|
| Time to first token / first byte (TTFT/TTFB) | Latency from request to the first streamed token or byte | Dominates perceived responsiveness for streaming agents; invisible in end-to-end p95 alone |
| Inter-token latency / tokens per second | Steady-state generation rate after the first token | Governs how long a long completion takes to finish rendering |
| End-to-end latency (p50 / p95 / p99) | Full request-to-final-response duration | The bounded interaction expectation; tail percentiles expose worst-case experience |
| Throughput / concurrency / requests per second | Sustained load the path serves before degrading | Establishes the capacity envelope and the point of saturation |
| Error rate & saturation | Failed, throttled (429), or timed-out requests as load rises | Rate limits, quota, and PTU ceilings surface here, not in median latency |
| Per-component attribution | Split across model inference, retrieval, tool calls, orchestration, gateway/network | Locates the bottleneck and records what the evidence cannot attribute |

Every metric travels with its population, sampling, coverage limit, and
interpretation owner. A number without those is not evidence.

## Pre-production synthetic load (S7)

Synthetic load answers a bounded question — "does this interaction hold its
first-token and end-to-end targets at the expected concurrency?" — in a test
environment whose fidelity limits are recorded.

- **Workload model.** Interaction types, concurrency and arrival profile, ramp,
  duration, prompt/payload mix, and whether streaming is on. A load run that
  does not resemble real usage produces a number without meaning.
- **Load engine.** **Azure Load Testing** is a suitable customer-run engine for
  generating and scaling synthetic load and collecting client-side latency and
  error metrics; equivalent engines (for example k6 or Apache JMeter) are valid
  alternatives. This kit references the engine and its outputs as customer
  evidence — it does not run a load test or provision the service.
- **Environment fidelity.** Record test-versus-production parity: model
  deployment, quota and PTU ceiling, data residency, and whether downstream
  tools and retrieval are live or stubbed. Load against a shared model
  deployment can throttle unrelated workloads — record the quota and cost of the
  run itself.
- **Interpretation.** The customer owns the baseline, the regression owner, and
  the release-decision use. A passed load run is assurance evidence for S7, not a
  production sign-off.

## Production measurement (S11)

Production telemetry answers a different question — "is real traffic meeting the
recorded expectation, and is it drifting?" — using the customer's own
instrumentation.

- **Sources.** OpenTelemetry spans, Application Insights, and Foundry traces
  where the customer enables tracing can provide TTFT, end-to-end latency,
  per-component spans, and error/throttle signals. Record the project, model
  deployment, agent or run identifier where available, correlation IDs,
  sampling, and retention.
- **Coverage limits.** A trace sample is a population with sampling and retention
  bounds. An uninstrumented or excluded path is a coverage gap, not a zero
  result.
- **Reconciliation.** Compare production percentiles against the S7 synthetic
  baseline. A gap is a drift *hypothesis* — the cause may be workload mix,
  configuration, model version, quota pressure, or evidence coverage — to be
  recorded with an owner and a test plan, not called confirmed drift.

## Governance boundaries

- A benchmark is not a service-level objective; the customer sets and owns any
  SLO separately.
- Synthetic and production evidence cover different populations; a conclusion
  needs both plus the recorded attribution limits.
- This kit references Azure Load Testing, OpenTelemetry, Application Insights,
  and Foundry observability as evidence sources. It does not execute them,
  create dashboards, or store customer telemetry.

## Related sessions and references

- [S4 latency budget](../s4-agent-engineering/index.md) records the bounded
  interaction target and component attribution this guide measures against.
- [S7 evaluation and release assurance](../s7-evaluation/index.md) hosts the
  synthetic load-test plan as pre-release assurance evidence.
- [S11 operate, monitor, and FinOps](../s11-operate-measure/index.md) hosts the
  production performance-telemetry review and drift handling.
- [Quality, cost, latency, and rollout governance](quality-cost-latency-guide.md)
  places latency alongside quality, model selection, cost, and rollout.

## Related official references

- [Azure Load Testing overview](https://learn.microsoft.com/en-us/azure/load-testing/overview-what-is-azure-load-testing)
- [Application Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [OpenTelemetry on Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/app/opentelemetry-overview)
- [Microsoft Foundry observability](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability)
- [Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/overview)
