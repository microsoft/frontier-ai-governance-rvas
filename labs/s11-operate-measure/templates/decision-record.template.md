# Decision Record

Copy this template into the customer's approved records system. Use it to record the required operating-review decision for S11 Operate & Measure.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, incident payloads, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Operating review question | |
| Decision owner | |
| Service operations owner | |
| Telemetry owner | |
| FinOps owner | |
| Escalation owner | |
| Evidence owner | |
| Receiving owner / process | |
| Approved records location | |
| Target date | |

## Operating route

Default path: **Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit**

| Route field | Record |
|---|---|
| Foundry observability reference | |
| Azure Monitor metric / alert reference | |
| Application Insights trace reference | |
| Log Analytics query reference | |
| Cost Management scope reference | |
| FinOps Toolkit / review cadence reference | |
| Evidence-reference location | |

## Signal population and correlation

| Signal / field | Record |
|---|---|
| Usage signal status | populated / missing / sampled / planned / unavailable / blocked |
| Quality signal status | populated / missing / sampled / planned / unavailable / blocked |
| Latency signal status | populated / missing / sampled / planned / unavailable / blocked |
| Error/failure signal status | populated / missing / sampled / planned / unavailable / blocked |
| Safety signal status | populated / missing / sampled / planned / unavailable / blocked |
| Cost signal status | populated / missing / sampled / planned / unavailable / blocked |
| Capacity signal status | populated / missing / sampled / planned / unavailable / blocked |
| Drift signal or hypothesis | |
| Scope and time window reviewed | |
| Correlation key or mapping | |
| Correlation propagation point | |
| Known blind spots / sampling limits | |

## Retention, thresholds, FinOps, and escalation

| Field | Record |
|---|---|
| Telemetry retention owner | |
| Query/output/evidence retention owner | |
| Threshold / alert owner | |
| Threshold tuning cadence | |
| Severity and alert destination | |
| FinOps allocation rule | |
| Budget / anomaly owner | |
| Escalation path | |
| Incident / problem / product-review route | |
| Evaluation or model-owner handoff if drift is suspected | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route / blocked) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Review impact | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected operating signal or route | |
| Unsupported or unverified measurement path | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review impact | |
| Review trigger | |

## Backlog and handoff

Create an operations backlog item for each missing signal, correlation key, retention owner, query owner, threshold owner, alert, FinOps allocation rule, cost owner, escalation path, drift owner, unsupported workload, access/license blocker, or evidence location.

Handoff to service operations, product owner, FinOps owner, platform monitoring, evaluation/model owner, and operations governance. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "review pilot operating signals"; evidence location "customer-approved Foundry observability reference, Application Insights query reference, Cost Management scope reference, and FinOps review reference; no telemetry copied here"; accepted when operations confirms signal population, correlation key, retention, threshold owner, FinOps rule, escalation path, drift/review trigger, backlog owner, and handoff.
