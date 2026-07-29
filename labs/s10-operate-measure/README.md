# S10 Operating Evidence & FinOps Work Package

This lab helps the customer make one bounded operating-review decision and hand it to the right owner. It is not a tenant change, live-control validation, deployment, runtime proof, telemetry export, dashboard build, alert configuration, budget setting, or production approval. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, tenant IDs, object IDs, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, incident payloads, cost exports, dashboard exports, or production approval claims in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, review period, decision owner, service operations owner, telemetry owner, FinOps owner, product owner, escalation owner, evidence owner, approved customer records location, and receiving product/operations owner. If any owner, review period, evidence location, or escalation path is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the operating review card, signal coverage, correlation contract, retention/evidence handling, alert route, FinOps/capacity package, drift hypothesis, validation package, exception status, backlog, target date, recurrence check, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned operating review package that summarizes:

- **Operating review card:** workload, route, environment, review period, population, excluded paths, decision use, owners, approved records location, and cadence.
- **Signal coverage:** usage, quality, safety, latency, error, dependency, tool/API, identity/security, cost, capacity, feedback, outcome, and control signals are populated, missing, sampled, planned, unavailable, blocked, or diagnostic-only.
- **Correlation contract:** key or mapping that joins workload, agent/model, API/tool call, request/trace, owner, environment, and cost allocation; plus propagation points and blind spots.
- **Retention and evidence handling:** telemetry retention owner, query/export owner, evidence notes location, sensitive-data boundary, investigation route, and safe-reference-only handling.
- **Alert and response ownership:** threshold owner, action group or SOC route, severity, acknowledgment expectation, suppression review, tuning cadence, escalation path, and validation method.
- **FinOps and capacity:** cost source, allocation rule, tag/dimension, budget/anomaly owner, quota/PTU/capacity owner, shared-cost assumption, action rule, and review cadence.
- **Drift hypothesis:** changed signal, population, time window, possible causes, evidence limits, owner, test or observation plan, action route, and next review trigger.
- **Remediation validation:** validation reference, reviewer, remaining risk, recurrence check, exception route, and closure owner.
- **Blockers and backlog:** missing telemetry, correlation key, signal coverage, retention owner, threshold owner, alert route, FinOps allocation rule, cost owner, escalation path, drift owner, validation owner, export owner, evidence location, or review cadence captured with owner, acceptance test, target date, and review trigger.
- **Handoff:** service operations, product owner, FinOps owner, platform monitoring, telemetry owner, evaluation baseline owner, SOC/incident owner, and operations governance accept the decision or backlog with clear acceptance criteria.

## Facilitation flow

1. Confirm the customer has a bounded scope, review period, owners, escalation path, and approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Complete only safe references in this repository.
3. Inspect the Microsoft control path: **Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit**.
4. Ask: **Which customer-owned record lets operations explain current health, cost, drift, alert ownership, validation, and recurrence without exporting telemetry?**
5. Record one result in the customer system: adopt, defer, reject, route, or blocked.
6. Create an operations backlog item for each missing signal, correlation key, retention owner, threshold owner, alert, quality/cost/latency review, FinOps rule, drift hypothesis owner, escalation path, remediation validation owner, operating cadence, export/SIEM owner, or evidence location.
7. Handoff the completed decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Adopt** when review card, signal coverage, correlation key, retention, threshold owner, FinOps rule, escalation path, drift/review trigger, validation route, evidence reference, recurrence check, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped operating-measurement path cannot support the bounded review.
- **Route** when another control owner, service owner, telemetry owner, FinOps owner, product owner, evaluation baseline owner, SOC/incident owner, export owner, or exception process must decide first.
- **Blocked** when access, evidence location, signal population, correlation, ownership, retention, escalation, validation, or scope clarity prevents a decision.

## Session-specific considerations

When completing the shared decision record, capture operating review card, signal coverage, correlation key, retention, threshold owner, FinOps allocation rule, escalation path, drift hypothesis, alert gaps, validation route, exception status, recurrence check, and receiving handoff.

## Handoff

Handoff to service operations, product owner, FinOps owner, platform monitoring, telemetry owner, evaluation baseline owner, SOC/incident owner, export owner, and operations governance. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, validation references, recurrence checks, and review triggers. Keep final records in the customer-approved system.
