# S11 Operate & Measure Work Package

This lab helps the customer make one bounded operating-review decision and hand it to the right owner. It is not a tenant change, live-control validation, deployment, runtime proof, or production approval. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, incident payloads, or production approval claims in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, decision owner, service operations owner, telemetry owner, FinOps owner, escalation owner, evidence owner, approved customer records location, and receiving product/operations owner. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`runbook.md`](runbook.md) | Step-by-step operating review flow, including signal population, correlation key, retention, threshold owner, FinOps rule, escalation path, drift hypothesis, decision state, blockers, and handoff. |
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the operating-review decision, evidence references, acceptance test, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Operating route:** Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, FinOps Toolkit, custom telemetry, or an approved customer telemetry path.
- **Signal population:** usage, quality, latency, error, safety, cost, capacity, and drift signals are populated, missing, sampled, planned, unavailable, or blocked for the bounded scope.
- **Correlation:** the key or mapping that joins workload, agent/model, API/tool call, request/trace, owner, environment, and cost allocation; plus known blind spots.
- **Retention and evidence handling:** retention owner, query/export owner, evidence notes location, investigation route, and safe-reference-only handling.
- **Operating ownership:** threshold owner, FinOps rule owner, escalation path, review cadence, and drift/problem-review route.
- **Blockers and backlog:** missing telemetry, correlation key, signal population, threshold owner, FinOps allocation rule, alert, retention owner, escalation path, drift owner, evidence location, or review cadence captured with owner, acceptance test, target date, and review trigger.
- **Handoff:** service operations, product owner, FinOps owner, platform monitoring, evaluation/model owner, and operations governance accept the decision or backlog with clear acceptance criteria.

## Facilitation flow

1. Confirm the customer has a bounded scope, owners, escalation path, and approved records location. If not, stop the decision and create a blocker backlog item.
2. Follow [`runbook.md`](runbook.md), then copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Complete only safe references in this repository.
3. Inspect the Microsoft control path: **Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit**.
4. Ask: **Which customer-owned Microsoft record lets operations explain current health, cost, drift, threshold ownership, and escalation without exporting telemetry?**
5. Record one result in the customer system: approve, defer, reject, route, or blocked.
6. Create an operations backlog item for each missing signal, correlation key, retention owner, threshold owner, alert, quality/cost/latency review, FinOps rule, drift hypothesis owner, escalation path, remediation owner, operating cadence, or evidence location.
7. Handoff the completed decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when signal population, correlation key, retention, threshold owner, FinOps rule, escalation path, drift/review trigger, evidence reference, acceptance test, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped operating-measurement path cannot support the bounded review.
- **Route** when another Microsoft control owner, service owner, telemetry owner, FinOps owner, product owner, evaluation/model owner, or exception process must decide first.
- **Blocked** when access, evidence location, signal population, correlation, ownership, retention, escalation, or scope clarity prevents a decision.

## Session-specific considerations

When completing the shared decision record, capture signal population, correlation key, retention, threshold owner, FinOps allocation rule, escalation path, drift hypothesis, alert gaps, exception status, and receiving handoff.

## Handoff

Handoff to service operations, product owner, FinOps owner, platform monitoring, evaluation/model owner, and operations governance. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.
