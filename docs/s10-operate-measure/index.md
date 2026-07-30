# S10 · Operating Evidence & FinOps

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Verify current Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, FinOps Toolkit, alerting, quota/capacity, and export capabilities before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Service owner</span> <span class="rvas-badge rvas-persona">Cost owner</span>

!!! abstract "What is at stake"
    Signals about risk, drift, quality, and cost only matter when a named owner
    can interpret them and take the next action.

## 1. Run an operating review

Run an operating review for one bounded workload and review period. Make
operating evidence useful for governance without copying telemetry, creating
dashboards, changing thresholds, or claiming production approval.

**Plain decision question:** *Can this workload and review period be operated from customer-owned evidence with known signal coverage, correlation keys, retention, alert ownership, cost allocation, drift interpretation, remediation validation, exception handling, and recurrence checks?*

Work through these checks:

- Open Application Insights for the app or agent host. Check requests,
  dependencies, failures, availability, sampling, and the `operation_Id` or W3C
  trace context used to join the route.
- Open the Log Analytics workspace. Run approved KQL placeholders for latency,
  errors, model/tool route, token or cost proxy where available, dependency
  failures, and safety/security signals.
- Open Azure Monitor alerts and action groups. Check rule state, severity,
  threshold owner, action group/SOC route, suppression, and validation status.
- Open Azure Monitor workbooks or customer dashboards. Verify population,
  filters, review period, exclusions, query owner, and interpretation owner.
- Open Cost Management exports, cost analysis, budgets, and FinOps reports.
  Check tags/dimensions, shared-cost assumptions, export cadence, budget owner,
  and anomaly route.
- Open quota/capacity views for Azure OpenAI, Foundry, or the relevant service.
  Check quota, PTU/committed capacity, saturation, throttling, fallback rule,
  and owner.
- Open Defender for Cloud and Sentinel/SOC queues where used. Check active
  security findings, accepted no-result scope, incident route, and playbook owner.
- Run the operating review and classify each area as normal, investigate,
  missing, sampled, delayed, unsupported, blocked, or route-to-owner.

`labs/s10-operate-measure/` holds offline templates and a runbook. It does **not** connect to live data, create a dashboard, calculate metrics, set thresholds, store customer data, configure alerts, export telemetry, set budgets, or implement a change.

### What happens next

**Next customer action:** put the adopted review on the customer operating cadence, then assign its alerts, remediation checks, exceptions, cost actions, drift hypotheses, and recurrence checks to named owners.

S10 assigns an operating backlog for customer-owned work. The recommendation states whether to adopt, defer, reject, route, or block the review. It names the next owner for telemetry coverage, correlation, alert response, remediation validation, FinOps/cost allocation, drift investigation, exception review, portfolio visibility, support, or release/change action.

## 2. Prerequisites

- Current registry/control-plane findings or known inventory gaps for the workload under review.
- A bounded workload, route, and review period.
- A governance lead who can assign the review decision and cadence.
- Operations, telemetry, FinOps, product, escalation, and evidence owners who can describe available records and coverage limits.
- An approved customer records location for references, decisions, validation notes, and review outcomes.

## 3. Turn operating signals into action

Operating governance needs a repeatable review, not just a dashboard. The customer needs a clear path from signal coverage to correlation, interpretation, decision, escalation, remediation validation, recurrence review, and exception accountability.

Microsoft Foundry observability can provide traces, token usage, latency, and evaluation signals when the customer enables and retains them. Azure Monitor, Application Insights, and Log Analytics can provide application and platform telemetry. FinOps evidence can show spend ownership and allocation limits. None of these closes a finding by itself.

Empty, planned, sampled, excluded, or unavailable signals are coverage limits. They are not zero results, health proof, or control proof. A cost view without allocation owner is not an action. A remediation item is not closed until a reviewer accepts validation evidence.

Use [Technical decisions](technical.md) for signal coverage, correlation,
alert routing, FinOps, drift, and validation checks.

## 4. Expected operating states

| State | Meaning | Next action |
|---|---|---|
| Normal | Queries, alerts, cost view, capacity view, and handoff match the reviewed population and period. | Adopt review cadence. |
| Investigate | Latency, errors, dependency failures, safety/security signal, cost anomaly, capacity pressure, or drift hypothesis needs owner review. | Open incident/problem/backlog/cost action. |
| Missing telemetry | No approved query, correlation key, workspace/app reference, alert, workbook, or retention path. | Route to telemetry owner; do not claim operating coverage. |
| Sampled or aggregate-only | Signal exists but cannot support detailed route reconstruction. | Record limitation and owner acceptance. |
| Delayed | Export, report, workbook, or log ingestion is not current. | Assign recheck owner and time. |
| Unsupported | The source cannot cover this model, route, connector, region, SKU, or security handoff. | Route to platform/product owner. |
| Blocked | Required owner, access, evidence handling, records location, or change route is missing. | Stop the review until fixed. |

## 5. Change boundary

S10 makes no live-data query and no platform, dashboard, alert, metric, threshold, budget, identity, policy, telemetry export, remediation, exception, runtime, enforcement, or production change. Any action uses the customer's approved engineering, operations, incident, FinOps, records-management, and change process.
