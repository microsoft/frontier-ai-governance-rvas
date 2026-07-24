# Platform Boundary Review

Copy this template into the customer's approved records system. Use it to turn the S3 Platform Foundation decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, and Azure Monitor**.

Inspect: the landing-zone subscription/resource group, Foundry project, API gateway configuration, private networking route, Azure Policy assignment, and Azure Monitor workspace.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, and Azure Monitor | | | | | cloud platform team, network/security team, and application delivery owner |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create a platform-foundation backlog item for each missing boundary control, environment separation, network route, policy assignment, monitor, or runtime handoff. |
| Handoff owner and customer process | cloud platform team, network/security team, and application delivery owner |
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

Example: Work item “route PRE inference through APIM AI Gateway”; evidence location “APIM policy record”; accepted when PRE traffic has private network, policy, and monitor references.
