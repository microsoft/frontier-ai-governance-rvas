# Catalog Stewardship

Copy this template into the customer's approved records system. Use it to turn the S9 Control Plane decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, and platform telemetry**.

Inspect: the Agent 365 or agent catalog record, Entra Agent ID/workload identity, API Center entry, ownership metadata, telemetry reference, and stewardship cadence.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, and platform telemetry | | | | | control-plane steward, identity owner, API platform owner, and portfolio governance |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create a control-plane backlog item for each missing catalog record, owner, identity link, API dependency, telemetry pointer, stale record, or review cadence. |
| Handoff owner and customer process | control-plane steward, identity owner, API platform owner, and portfolio governance |
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

Example: Work item “link agent record to API dependency”; evidence location “Agent 365 record and API Center entry”; accepted when steward review shows owner, identity, and telemetry links.
