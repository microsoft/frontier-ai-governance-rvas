# Decision Record

Copy this template into the customer's approved records system. Use it to record the required operating-review decision for S10 Operating Evidence & FinOps.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, tenant IDs, object IDs, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, incident payloads, cost exports, dashboard exports, or production approval claims in this repository. Do not change tenant configuration, live policy, dashboard, alert, threshold, budget, telemetry export, or runtime control during the lab.

## Operating review card

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Operating review question | |
| Workload route (agent / model / app / API / tool path) | |
| Environment and production boundary | |
| Review period | |
| Review cadence | |
| Included population | |
| Excluded paths or unsupported sources | |
| Decision use (operating / incident / product / cost / drift / exception / portfolio) | |
| Decision owner | |
| Service operations owner | |
| Telemetry owner | |
| FinOps owner | |
| Product owner | |
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
| Customer telemetry / SIEM route if used | |
| Evidence-reference location | |

## Signal coverage

| Signal / field | Status | Source reference | Owner | Population / window | Sampling or retention limit | Decision use |
|---|---|---|---|---|---|---|
| Usage | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Quality | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Safety | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Latency | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Error / failure | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Dependency health | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Tool / API behavior | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Identity / security | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Cost | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Capacity | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Feedback / outcome | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |
| Control coverage | populated / missing / sampled / planned / unavailable / blocked / diagnostic-only | | | | | |

## Correlation contract

| Field | Record |
|---|---|
| Correlation key or mapping | |
| Gateway propagation point | |
| Orchestration / agent / model propagation point | |
| Execution host propagation point | |
| Tool / API / data dependency propagation point | |
| Monitor / log store propagation point | |
| Cost allocation join | |
| Known break points / blind spots | |
| Query owner | |
| Validation reference | |

## Retention, evidence handling, alerts, and response

| Field | Record |
|---|---|
| Telemetry retention owner | |
| Query/output/evidence retention owner | |
| Export owner if telemetry leaves Azure monitoring | |
| Sensitive-data / prompt-output handling boundary | |
| Threshold / alert owner | |
| Threshold tuning cadence | |
| Severity and alert destination | |
| Action group / SOC route | |
| Acknowledgment expectation | |
| Suppression rule and review cadence | |
| Escalation path | |
| Incident / problem / product-review route | |
| Validation method | |

## FinOps and capacity

| Field | Record |
|---|---|
| Billing source | |
| Allocation tag / dimension / rule | |
| Budget owner | |
| Anomaly owner and action route | |
| Shared-cost assumption | |
| PTU / committed-capacity / quota owner | |
| Inference cost boundary | |
| Training / fine-tuning cost boundary if applicable | |
| Telemetry / export / support cost boundary | |
| Review cadence | |

## Drift hypothesis and validation

| Field | Record |
|---|---|
| Drift signal or hypothesis | |
| Changed signal | |
| Population and period | |
| Possible causes | |
| Evidence limits | |
| Owner | |
| Test or observation plan | |
| Action route | |
| Validation reference | |
| Reviewer | |
| Remaining risk | |
| Recurrence check | |
| Next review trigger | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (adopt / defer / reject / route / blocked) | |
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
| Recurrence check | |
| Review trigger | |

## Backlog and handoff

Create an operations backlog item for each missing signal, correlation key, retention owner, query owner, threshold owner, alert, FinOps allocation rule, cost owner, escalation path, drift owner, validation owner, export owner, unsupported workload, access/license blocker, or evidence location.

Handoff to service operations, product owner, FinOps owner, platform monitoring, telemetry owner, evaluation baseline owner, SOC/incident owner, export owner, and operations governance. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, validation references, recurrence checks, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "review pilot operating signals"; evidence location "customer-approved Foundry observability reference, Application Insights query reference, Cost Management scope reference, and FinOps review reference; no telemetry copied here"; accepted when operations confirms signal coverage, correlation key, retention, threshold owner, FinOps rule, escalation path, drift/review trigger, validation reference, recurrence check, backlog owner, and handoff.
