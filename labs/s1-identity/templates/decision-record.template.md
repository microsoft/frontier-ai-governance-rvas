# Decision Record

Copy this template into the customer's approved records system. Use it to record the required customer decision for S1 Identity & Access.

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

Default path: **Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available**

Inspect: inspect the Entra application or managed identity record, Agent ID/Agent 365 record when available, Conditional Access assignment, Azure RBAC scope, and identity owner record. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available | | | | | |

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

- Identity Inventory Review


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

Create an identity backlog item for each missing agent/workload identity record, least-privilege role assignment, Conditional Access control, or owner review.

Handoff to identity platform owner, application owner, and security operations. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.

## Filled example

Work item “register support-agent workload identity”; evidence location “Entra app record and RBAC assignment”; accepted when the app owner and identity owner verify least privilege and review date.
