# S10 · Operating Evidence & FinOps

!!! info "Freshness"
    Last reviewed: 2026-07-29 · Verify current Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, FinOps Toolkit, alerting, and export capabilities before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Service owner</span> <span class="rvas-badge rvas-persona">Cost owner</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer has an **operating review package** for one bounded workload and review period. The package makes operating evidence usable for governance without copying telemetry, creating dashboards, changing thresholds, or claiming production approval.

**Plain decision question:** *Can this workload and review period be operated from customer-owned evidence with known signal coverage, correlation keys, retention, alert ownership, cost allocation, drift interpretation, remediation validation, exception handling, and recurrence checks?*

They leave with:

- An **operating review card**: workload, capability, environment, model/agent/app/API/tool path, review period, population, excluded paths, decision owner, operations owner, telemetry owner, FinOps owner, product owner, escalation owner, evidence owner, approved records location, and review cadence.
- A **signal coverage package** for usage, quality, safety, latency, errors, dependency health, tool/API behavior, identity/security, cost, capacity, feedback, business outcome, and control-coverage signals.
- An **end-to-end correlation package** that names the join method across gateway, orchestration/model/agent, execution host, tool/data dependency, monitor/log store, and decision record.
- An **alert and response package** with threshold owner, action group or SOC route, acknowledgment expectation, suppression review, escalation path, validation method, and incident/problem/change handoff.
- A **FinOps and capacity package** with billing source, tags or dimensions, PTU/committed-capacity allocation, quota/capacity owner, shared-cost assumptions, budget/anomaly route, and review cadence.
- A **drift hypothesis and quality review package** that records production signal changes as hypotheses with owners, evidence limits, test plans, and action routes.
- A **remediation validation and exception package** with owner, target date, validation reference, recurrence check, remaining risk, and next review trigger.

`labs/s10-operate-measure/` holds offline templates and a runbook. It does **not** connect to live data, create a dashboard, calculate metrics, set thresholds, store customer data, configure alerts, export telemetry, set budgets, or implement a change.

### What happens next

**Next customer action:** put the adopted review package on the customer operating cadence, then assign its alerts, remediation checks, exceptions, cost actions, drift hypotheses, and recurrence checks to named owners.

S10 creates an operating backlog for customer-owned work. The recommendation states whether to adopt, defer, reject, route, or block the review package. It names the next owner for telemetry coverage, correlation, alert response, remediation validation, FinOps/cost allocation, drift investigation, exception review, portfolio visibility, support, or release/change action.

## 2. Prerequisites

- Current registry/control-plane findings or known inventory gaps for the workload under review.
- A bounded workload, route, and review period.
- A governance lead who can assign the review decision and cadence.
- Operations, telemetry, FinOps, product, escalation, and evidence owners who can describe available records and coverage limits.
- An approved customer records location for references, decisions, validation notes, and review outcomes.

## 3. Why this session matters

Operating governance needs a repeatable review package, not just a dashboard. The customer needs a clear path from signal coverage to correlation, interpretation, decision, escalation, remediation validation, recurrence review, and exception accountability.

Microsoft Foundry observability can provide traces, token usage, latency, and evaluation signals when the customer enables and retains them. Azure Monitor, Application Insights, and Log Analytics can provide application and platform telemetry. FinOps evidence can show spend ownership and allocation limits. None of these closes a finding by itself.

Empty, planned, sampled, excluded, or unavailable signals are coverage limits. They are not zero results, health proof, or control proof. A cost view without allocation owner is not an action. A remediation item is not closed until a reviewer accepts validation evidence.

Read the [S10 Concepts](concepts.md) before delivery.

## 4. Change boundary

S10 makes no live-data query and no platform, dashboard, alert, metric, threshold, budget, identity, policy, telemetry export, remediation, exception, runtime, enforcement, or production change. Any action uses the customer's approved engineering, operations, incident, FinOps, records-management, and change process.
