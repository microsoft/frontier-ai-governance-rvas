# Identity Inventory Review

Copy this template into the customer's approved records system. Use it to turn the S1 Identity & Access decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available**.

Inspect: the Entra application or managed identity record, Agent ID/Agent 365 record when available, Conditional Access assignment, Azure RBAC scope, and identity owner record.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available | | | | | identity platform owner, application owner, and security operations |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create an identity backlog item for each missing agent/workload identity record, least-privilege role assignment, Conditional Access control, or owner review. |
| Handoff owner and customer process | identity platform owner, application owner, and security operations |
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

Example: Work item “register support-agent workload identity”; evidence location “Entra app record and RBAC assignment”; accepted when the app owner and identity owner verify least privilege and review date.
