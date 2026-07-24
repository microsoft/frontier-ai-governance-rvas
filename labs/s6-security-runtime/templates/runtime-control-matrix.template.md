# Runtime Control Matrix

Copy this template into the customer's approved records system. Use it to turn the S6 Security Runtime decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, and Application Insights**.

Inspect: the APIM AI Gateway policy, Prompt Shields configuration, Defender for Cloud AI posture finding, Defender XDR/Sentinel incident route, and Application Insights correlation fields.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, and Application Insights | | | | | security engineering, SOC, platform operations, and application owner |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create a runtime-security backlog item for each missing gateway policy, prompt shield, posture finding owner, detection rule, incident route, or telemetry correlation field. |
| Handoff owner and customer process | security engineering, SOC, platform operations, and application owner |
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

Example: Work item “correlate prompt shield event to Sentinel case”; evidence location “Application Insights operation id and Sentinel incident”; accepted when SOC can trace and triage the event.
