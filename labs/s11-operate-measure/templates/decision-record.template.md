# Decision Record

Copy this template into the customer's approved records system. Use it to record the required customer decision for S11 Operate & Measure.

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

Default path: **Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit**

Inspect: inspect the Foundry observability view, Azure Monitor metric/alert, Application Insights trace, Log Analytics query, Cost Management view, and FinOps review record. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit | | | | | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Next review trigger | |

## Required considerations

Use the prompts below only to make the single decision complete. Do not create separate customer records unless the receiving owner asks for them.

- Operating Review
- Performance Telemetry Review
- Quality Cost Latency Review
- Remediation Closure
- Telemetry Alert Operating Model


## Session-specific prompts

Use this table to preserve the lesson-specific questions or prompt references that shaped the decision. Keep the entries short and references-only; do not paste sensitive prompts, outputs, or customer data.

| Prompt or question | Customer answer / reference | Decision impact |
|---|---|---|
| | | |

## Exception

Complete this section only when the Microsoft default is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Equivalent control | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Backlog and handoff

Create an operations backlog item for missing telemetry, alert threshold, quality/cost/latency review, remediation owner, operating cadence, or FinOps action.

Handoff to service operations, FinOps owner, platform monitoring, and product owner. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.

## Filled example

Work item “add latency/cost alert for production agent”; evidence location “Azure Monitor alert and Cost Management view”; accepted when operations and FinOps owners accept the cadence.
