# Decision Record

Copy this template into the customer's approved records system. Use it to record the required customer decision for S12 LLMOps Lifecycle.

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

Default path: **Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**

Inspect: inspect the data-curation record, experiment/candidate artifact, Foundry evaluation, validate/deploy release record, inference route, Azure Monitor/Application Insights signal, and governed feedback route. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection | | | | | |

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

- Incident, rollback, and retirement plan
- Model and prompt operations register
- Operating model material-change decision


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

Create an LLMOps backlog item for each lifecycle stage missing an owner, gate, Microsoft record location, rollback route, feedback-to-curation control, or target date.

Handoff to data owner, experiment owner, evaluation owner, platform/change owner, service operations, and governance owner. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.

## Filled example

Work item “connect feedback to curated dataset review”; evidence location “feedback queue and S2 data-curation record”; accepted when no production observation mutates prompts or data without gate review.
