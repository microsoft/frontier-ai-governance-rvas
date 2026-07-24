# Remediation Closure

Copy this template into the customer's approved records system. Use it to turn the S11 Operate & Measure decision into a Microsoft-platform control record and backlog handoff.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Decision owner | |
| Implementation owner | |
| Evidence owner | |
| Approved records location | |
| Target date | |

## Microsoft control path

Default path: **Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit**.

Inspect: the Foundry observability view, Azure Monitor metric/alert, Application Insights trace, Log Analytics query, Cost Management view, and FinOps review record.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit | | | | | service operations, FinOps owner, platform monitoring, and product owner |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create an operations backlog item for missing telemetry, alert threshold, quality/cost/latency review, remediation owner, operating cadence, or FinOps action. |
| Handoff owner and customer process | service operations, FinOps owner, platform monitoring, and product owner |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used.

| Exception field | Record |
|---|---|
| Reason | |
| Equivalent control | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Filled example

Example: Work item “add latency/cost alert for production agent”; evidence location “Azure Monitor alert and Cost Management view”; accepted when operations and FinOps owners accept the cadence.
