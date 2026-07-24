# Technical Decision Record

Copy this template into the customer's approved records system. Use it to turn the S10 In-Process Governance decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Agent Governance Toolkit only when gateway controls cannot make the needed in-process decision**.

Inspect: the existing gateway/platform control, the runtime decision point, Agent Governance Toolkit applicability record, policy owner, and evidence route.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Agent Governance Toolkit only when gateway controls cannot make the needed in-process decision | | | | | agent engineering owner, policy owner, runtime operations, and release manager |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create an in-process-governance backlog item only for decisions the gateway cannot enforce; include policy owner, runtime evidence, test, target date, and rollback route. |
| Handoff owner and customer process | agent engineering owner, policy owner, runtime operations, and release manager |
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

Example: Work item “add in-process policy for tool result summarization”; evidence location “Agent Governance Toolkit policy record”; accepted when gateway limits are documented and release owner approves rollback.
