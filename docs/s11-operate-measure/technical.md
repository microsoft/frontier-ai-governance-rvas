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

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Traces and metrics | Foundry trace/evaluation records, Application Insights traces/requests/dependencies, Azure Monitor metrics |
| Logs and retention | Log Analytics workspace, diagnostic settings, retention/sampling policy, privacy review |
| Alerts | Azure Monitor alert rule/action group, SOC ticket/playbook, on-call route, suppression rule |
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
