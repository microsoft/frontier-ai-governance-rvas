# Agent performance-testing governance

!!! info "Freshness"
    Last reviewed: 2026-07-17. Verify capability, service availability, region,
    quota, and pricing before delivery.

Use this guide with S4, S7, and S11 to turn agent-performance questions—first-response speed, load behaviour, and production drift—into customer-owned records. It does not run a load test, query live telemetry, set an SLO, or authorize a production change.

Use **two complementary evidence sources**:

1. **Pre-production synthetic load** (S7): a bounded test-environment workload under controlled concurrency before release.
2. **Production telemetry** (S11): OpenTelemetry, Application Insights, or Foundry traces on real traffic, reconciled with the synthetic baseline.

A synthetic benchmark is not a production SLO, and a production sample is not a controlled experiment. Record each source's population and attribution limits.

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

Record every metric with its population, sampling, coverage limit, and interpretation owner. A number without them is not evidence.

## Pre-production synthetic load (S7)

Synthetic load answers whether an interaction holds its first-token and end-to-end targets at expected concurrency in a test environment with recorded fidelity limits.

- **Workload model.** Record interaction types, concurrency and arrival profile, ramp, duration, prompt/payload mix, and streaming. A workload unlike real usage produces an unhelpful number.
- **Load engine.** **Azure Load Testing** is a suitable customer-run engine for synthetic load and client-side latency and error metrics; k6 and Apache JMeter are valid alternatives. This kit references the engine and outputs as customer evidence; it does not run a test or provision the service.
- **Environment fidelity.** Record test-to-production parity: model deployment, quota and PTU ceiling, data residency, and whether downstream tools and retrieval are live or stubbed. Shared model deployments can throttle unrelated workloads, so record run quota and cost.
- **Interpretation.** The customer owns the baseline, regression owner, and release-decision use. A passed load run is S7 assurance evidence, not production sign-off.

## Production measurement (S11)

Production telemetry asks whether real traffic meets its recorded expectation and is drifting, using customer instrumentation.

- **Sources.** OpenTelemetry spans, Application Insights, and customer-enabled Foundry traces can provide TTFT, end-to-end latency, per-component spans, and error/throttle signals. Record project, model deployment, agent or run identifier where available, correlation IDs, sampling, and retention.
- **Coverage limits.** An uninstrumented or excluded path is a coverage gap, not a zero result.
- **Reconciliation.** Compare production percentiles with the S7 synthetic baseline. A gap is a drift *hypothesis*—potentially workload mix, configuration, model version, quota pressure, or evidence coverage—to record with an owner and test plan, not confirmed drift.

## Governance boundaries

- A benchmark is not a service-level objective; the customer sets and owns any
  SLO separately.
- Synthetic and production evidence cover different populations; a conclusion needs both and their attribution limits.
- This kit references Azure Load Testing, OpenTelemetry, Application Insights, and Foundry observability as evidence sources. It does not execute them, create dashboards, or store customer telemetry.

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
