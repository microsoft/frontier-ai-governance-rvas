# Technical Decision Record

Copy this template into the customer's approved records system. Use it to turn the S5 Tool & API Governance decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls**.

Inspect: the API Center entry, APIM product/API policy, Entra app/JWT validation, access contract, connector approval, and MCP publication record.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls | | | | | API platform owner, tool owner, identity owner, and consuming-agent owner |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create a tool/API backlog item for missing catalog metadata, owner, auth contract, APIM policy, connector approval, MCP publication guardrail, or consumer review. |
| Handoff owner and customer process | API platform owner, tool owner, identity owner, and consuming-agent owner |
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

Example: Work item “publish claims lookup API”; evidence location “API Center entry and APIM product”; accepted when Entra/JWT, schema, throttling, and consumer contract are approved.
