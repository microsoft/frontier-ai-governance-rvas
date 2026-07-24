# Rollout Decision Record

Copy this template into the customer's approved records system. Use it to turn the S4 Agent Engineering decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Microsoft Foundry Agent Service, Copilot Studio, Microsoft 365 Copilot extensibility, or a custom Azure app path**.

Inspect: the Foundry agent, Copilot Studio agent, Microsoft 365 Copilot extension, or custom Azure app record plus model deployment, rollout, and release records.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Foundry Agent Service, Copilot Studio, Microsoft 365 Copilot extensibility, or a custom Azure app path | | | | | agent engineering owner, product owner, platform owner, and release manager |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create an engineering backlog item for any missing admission criterion, model-selection record, token/cost guardrail, latency budget, rollout gate, or retirement trigger. |
| Handoff owner and customer process | agent engineering owner, product owner, platform owner, and release manager |
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

Example: Work item “select Foundry Agent Service for claims assistant”; evidence location “model-selection record”; accepted when rollout, cost, latency, and retirement gates have owners.
