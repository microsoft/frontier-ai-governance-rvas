# S11 · Operate, Monitor & FinOps: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, FinOps Toolkit, PTU/committed capacity, alerts, and pricing vary by tenant, region, SKU, and configuration. Verify official docs and customer status before delivery.

## Microsoft default

Default to Microsoft Foundry observability for Foundry agents/models, Azure Monitor and Application Insights/Log Analytics for application and platform telemetry, Azure Cost Management plus FinOps Toolkit for cost analysis, and customer operations/SOC routes for alerts and drift response.

![S11 illustrative operating-evidence pattern: gateway, agent-host, model or orchestration, and data-dependency signals are correlated with stated coverage and retention limits before owners make operating, remediation, or exception decisions.](../assets/diagrams/s11-operating-review-flow.svg)

## Decision tree

1. **If Foundry owns the AI runtime**, use Foundry traces/evaluations plus Azure Monitor/Application Insights for surrounding app and platform signals.
2. **If a custom app owns the path**, instrument OpenTelemetry/Application Insights and join model/gateway traces where available.
3. **If cost allocation is required**, start with Azure Cost Management source records, then apply tags, Foundry context, PTU/committed-capacity allocation, or FinOps Toolkit analysis.
4. **If an alert lacks owner, threshold, population, or route**, backlog coverage before claiming operating control.
5. **If production signals diverge from S7 evidence**, create a drift hypothesis and test plan rather than immediate root-cause claims.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Observability | Foundry observability + Application Insights/Azure Monitor/Log Analytics | existing observability estate carries correlation, retention, and alert routes |
| Cost attribution | Azure Cost Management with tags, Foundry project/model context, PTU allocation, FinOps Toolkit | customer finance system is authoritative and maps source records |
| Alert/drift route | Azure Monitor alerts, Defender/SOC as needed, operating review cadence | governance review route is more appropriate for non-urgent quality/risk signals |

### End-to-end traceability model

For an Azure agent platform, S11 should record which signals let an operating
review follow one request across the route. The flow below is illustrative and
must be mapped to the customer's actual platform records.

![End-to-end traceability flow across gateway, orchestration, execution host, data/tool dependency, monitor, shared correlation method, and operating decision record.](../assets/diagrams/s11-end-to-end-traceability-flow.svg)

| Hop | Signal to identify | Operating question |
|---|---|---|
| Gateway | Request ID, caller identity, API/product/backend, policy decisions, quota and token metrics, latency, error code. | Did the approved entry route receive and handle the request within the expected policy boundary? |
| Orchestration | Agent or run ID, model deployment, prompt/context references, tool decisions, token usage, safety/evaluation signals. | Did the AI runtime behave within the reviewed route and emit usable trace references? |
| Execution host | App trace, dependency call, exception, tool parameters, tool response summary, managed identity. | Did custom or external code perform expected work and preserve correlation? |
| Data or tool service | Query/dependency trace, data classification boundary, authorization result, latency, failure. | Which dependency was used, and are data/tool records within the approved scope? |
| Monitor or log store | Operation/trace ID, time window, retained events, sampling, retention/export rule, reviewer query. | Can an owner reconstruct the bounded path without copying raw customer evidence into the repo? |

The common correlation key may be W3C `traceparent`, an Application Insights
`operation_Id`, a gateway request ID, a run ID, or a documented join method.
S11 records the join method and its blind spots; it does not run live queries or
declare an uninstrumented path healthy.

### Alert and operating-review taxonomy

Alerts are useful only when they have an owner, threshold, population, action,
suppression rule, and review cadence.

| Area | Example signal | Decision route |
|---|---|---|
| Entry layer | Gateway 5xx rate, latency, throttling, policy block, quota breach. | Service/platform owner, S6/S11 evidence route, FinOps owner where cost-related. |
| Agent or orchestration | Execution failure, high latency, unexpected tool count, quality/safety score drop, anomalous token usage. | Agent owner, S7 drift hypothesis, S11 operating review. |
| Execution host | App errors, dependency failures, CPU/memory saturation, instance restart, managed identity failure. | Engineering/SRE owner, incident or remediation backlog. |
| Identity and security | Repeated authentication failure, unauthorized access, unexpected agent sign-in, non-approved model or tool route. | Identity/security/SOC owner, S1/S6/S9 handoff. |
| Model and FinOps | High token consumption, capacity saturation, backend failover, inference errors, slow model response. | Model/platform owner, capacity owner, FinOps route. |
| Data and compliance | Unexpected data dependency, failed private endpoint/DNS path, retention/export gap, sensitive-data alert. | Data/compliance owner, S2/S3/S11 handoff. |

### Export and SIEM route

If telemetry must leave the Azure monitoring estate, record the export path
before relying on it for operations:

| Export element | Record |
|---|---|
| Source | Log Analytics workspace, Application Insights, Azure Monitor diagnostic settings, Foundry export, or security tool. |
| Buffer or stream | Event Hub namespace, consumer group, checkpoint store, retention, throughput owner. |
| Collector or function | OTel Collector, Azure Function, SIEM connector, transformation owner, failure/retry behavior. |
| Destination | Customer SIEM, Logstash/Elasticsearch, SOC platform, retention and access owner. |
| Governance limit | Fields excluded, prompt/output handling boundary, PII/sensitive data treatment, deletion or legal-hold route. |

#### Kusto correlation reference

This query is a shape for customer-owned Log Analytics/Application Insights
records. Replace table names, dimensions, and filters with the customer's
approved schema and do not copy raw telemetry into this repository.

```kusto
union AppRequests, AppDependencies, AppTraces
| where TimeGenerated > ago(24h)
| where tostring(Properties["agentId"]) == "agent-id-placeholder"
| project
    TimeGenerated,
    OperationId,
    Name,
    Success,
    DurationMs,
    Caller = tostring(Properties["callerId"]),
    Agent = tostring(Properties["agentId"]),
    Tool = tostring(Properties["toolName"]),
    Policy = tostring(Properties["policyDecision"])
| order by TimeGenerated asc
```

#### OpenTelemetry instrumentation reference

For pro-code agents, record the expected span and metric names before S11 relies
on them. This is illustrative only.

```python
from opentelemetry import trace

tracer = trace.get_tracer("agent-runtime")

with tracer.start_as_current_span("tool_call") as span:
    span.set_attribute("agent.id", "agent-id-placeholder")
    span.set_attribute("tool.name", "approved-tool-name")
    span.set_attribute("tool.decision", "allowed")
    span.set_attribute("correlation.id", "operation-id-placeholder")
    # Invoke the tool through the approved route.
```

Recommended attributes for operating review:

| Attribute | Why it matters |
|---|---|
| `agent.id` | Ties runtime telemetry to the S1/S9 identity and catalog record. |
| `operation.id` or W3C trace context | Joins gateway, app, model, tool, and data records. |
| `model.deployment` | Supports quality, latency, quota, and cost attribution. |
| `tool.name` and `tool.decision` | Supports S5/S10 tool-governance review. |
| `token.input` and `token.output` | Supports FinOps and anomaly review. |
| `guardrail.decision` | Supports S6 safety placement and S11 alert review. |

#### OTel Collector export reference

If Event Hub is the buffer between Azure monitoring and an external destination,
record the receiver, checkpoint, processor, exporter, and owner for each part.

```yaml
receivers:
  azureeventhub/appinsights:
    connection: ${EVENT_HUB_CONNECTION}
    group: operating-review-consumer
    blob_checkpoint_store:
      container_name: checkpoints

processors:
  memory_limiter:
    limit_mib: 1024
  batch:
    send_batch_size: 512
  resource:
    attributes:
      - key: platform
        value: agent-platform
        action: upsert

exporters:
  otlp_http/customer_observability:
    logs_endpoint: https://observability.example/v1/logs
    encoding: json

service:
  pipelines:
    logs:
      receivers: [azureeventhub/appinsights]
      processors: [memory_limiter, batch, resource]
      exporters: [otlp_http/customer_observability]
```

The export design must say what happens when the collector falls behind, the
destination rejects data, a field is sensitive, or a retention/legal-hold rule
conflicts with operational needs.

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Traces and metrics | Foundry trace/evaluation records, Application Insights traces/requests/dependencies, Azure Monitor metrics, gateway token metrics |
| Logs and retention | Log Analytics workspace, diagnostic settings, retention/sampling policy, privacy review |
| Alerts | Azure Monitor alert rule/action group, SOC ticket/playbook, on-call route, suppression rule |
| Export route | Event Hub export, OTel Collector or function, SIEM connector, destination owner, data-handling boundary |
| Cost | Azure Cost Management export/view, tags, budget, PTU/committed-capacity record, FinOps Toolkit report |
| Drift review | S7 baseline reference, production population, hypothesis, test/observation plan, next review date |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Observability | signal, population, exclusions, correlation key, retention, interpretation owner, and decision route are recorded | Operations owner |
| Cost model | source billing record, allocation rule, tag/capacity owner, shared-cost assumption, and review cadence are recorded | FinOps owner |
| Alert route | threshold owner, action group/SOC route, acknowledgement expectation, suppression rule, and review cadence are recorded | Service/SOC owner |
| Drift response | production variance has hypothesis, alternatives, test plan, owner, and S7/S13 linkage | Operating review owner |

## Boundary note

S11 records operating decisions and owners; it creates no dashboard, alert, budget, or production change.

## Related references

- [S11 Concepts](concepts.md): operating review, Foundry observability, FinOps, drift, escalation, and closure boundaries.
- [S7 technical decisions](../s7-evaluation/technical.md): synthetic baseline and release evidence.
- [S13 technical decisions](../s13-portfolio-governance/technical.md): portfolio prioritization.
- [Quality, cost, latency, and rollout guide](../reference/quality-cost-latency-guide.md).
- [Agent performance-testing guide](../reference/performance-testing-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
