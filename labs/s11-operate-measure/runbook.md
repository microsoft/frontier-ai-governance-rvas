# S11 Operate & Measure Runbook

Use this runbook to guide the required operating-review path. The customer inspects its own Microsoft records, records safe references in its approved system, and decides whether the scoped workload has usable operating evidence and an accepted handoff.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, incident payloads, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry gate

Confirm the customer has a bounded workload or portfolio slice, decision owner, service operations owner, telemetry owner, FinOps owner, escalation owner, evidence owner, receiving owner, and approved records location. If any are missing, stop the decision and create a blocker backlog item with the missing owner, record, or approval path.

## Required operating review flow

1. **Set the operating question.** Record whether the customer is reviewing current health, cost allocation, alert ownership, drift hypothesis, operating cadence, or a handoff from pilot to operations backlog.
2. **Inspect Foundry observability.** Reference the Foundry project/agent/model view, scope, environment, populated signals, owner, retention expectation, and known blind spots. Empty views require scope, time window, and reviewer before they can inform a decision.
3. **Inspect custom app telemetry.** Reference Azure Monitor, Application Insights, Log Analytics, or customer-approved telemetry records. Record request, trace, dependency, failure, tool/API, model, and workload context coverage.
4. **Confirm signal population.** For usage, quality, latency, error, safety, cost, capacity, and drift indicators, record `populated`, `missing`, `sampled`, `planned`, `unavailable`, or `blocked`; plus owner, time window, and decision impact.
5. **Confirm correlation key.** Name the key or mapping that joins workload, tenant/environment, agent/model, API/tool call, request/trace, owner, and cost allocation. Record propagation point and blind spots.
6. **Confirm retention and evidence handling.** Name retention owner for telemetry, alert records, cost review, query outputs, evidence notes, and investigation records. Do not export telemetry into this repository.
7. **Review thresholds and alerts.** Record threshold owner, severity, alert destination, tuning cadence, escalation path, and missing-alert backlog. Dashboards without owned thresholds are not sufficient for approval.
8. **Review FinOps rule.** Record Cost Management scope, tag or dimension, budget owner, allocation rule, anomaly route, review cadence, and exception path.
9. **Review drift or quality hypothesis.** If signals suggest drift, degradation, unexpected usage, cost anomaly, or quality issue, route to product, evaluation, model, incident, or problem-review owner with hypothesis, signal, scope, target date, and review trigger.
10. **Set decision state.** Use one state:
    - `approve`: signal population, correlation key, retention, threshold owner, FinOps rule, escalation path, drift/review trigger, evidence reference, acceptance test, and handoff are complete;
    - `defer`: a gap has a named owner and target date;
    - `reject`: the scoped operating-measurement path cannot support the review;
    - `route`: another service, telemetry, FinOps, product, evaluation/model, incident/problem, or exception owner must decide first;
    - `blocked`: access, evidence location, signal population, correlation, retention, threshold ownership, escalation, or scope clarity prevents a decision.
11. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, review impact, and next review trigger.
12. **Handoff.** Send the completed decision record and backlog references to service operations, product owner, FinOps owner, platform monitoring, evaluation/model owner, and operations governance.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `record-location-missing`, `foundry-observability-missing`, `custom-telemetry-missing`, `signal-population-absent`, `correlation-key-missing`, `retention-unresolved`, `threshold-owner-missing`, `alert-gap`, `finops-rule-missing`, `cost-allocation-missing`, `escalation-path-missing`, `drift-hypothesis-unowned`, `query-owner-missing`, `access-or-license`, `unsupported-workload`, `empty-result-not-scoped`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes signal population, correlation key, retention, threshold owner, FinOps rule, escalation path, drift/review trigger, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
