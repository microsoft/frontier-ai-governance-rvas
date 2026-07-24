# Technical Decision Record

Copy this template into the customer's approved records system. Use it to turn the S8 Red Teaming decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes**.

Inspect: the red-team plan/run record, PyRIT or AI Red Teaming Agent finding, Azure AI Content Safety result, Defender/Sentinel case, and remediation owner record.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes | | | | | red team lead, safety owner, SOC, product owner, and release manager |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create a red-team remediation backlog item for each confirmed finding, missing safety control, unowned risk, retest requirement, or SOC escalation route. |
| Handoff owner and customer process | red team lead, safety owner, SOC, product owner, and release manager |
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

Example: Work item “remediate jailbreak finding RT-014”; evidence location “red-team finding and retest record”; accepted when the safety owner confirms the control and SOC route.
