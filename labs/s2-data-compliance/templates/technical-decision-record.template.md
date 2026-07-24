# Technical Decision Record

Copy this template into the customer's approved records system. Use it to turn the S2 Data Compliance decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, and eDiscovery**.

Inspect: the Purview DSPM finding, sensitivity-label policy, DLP policy, audit/eDiscovery retention setting, data source record, and data owner decision.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, and eDiscovery | | | | | data owner, privacy/compliance team, and Purview administrator |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create a data-governance backlog item for each missing label, DLP rule, audit route, retention decision, or data-owner approval. |
| Handoff owner and customer process | data owner, privacy/compliance team, and Purview administrator |
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

Example: Work item “label retrieval corpus”; evidence location “Purview sensitivity-label policy”; accepted when the data owner approves the label and DLP route before ingestion.
