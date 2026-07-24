# Performance Test Plan

Copy this template into the customer's approved records system. Use it to turn the S7 Evaluation decision into a Microsoft-platform control record and backlog handoff.

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

Default path: **Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable**.

Inspect: the Foundry evaluation run, evaluator/scorer configuration, dataset/scenario reference, CI/CD gate, release decision, and Azure Load Testing record when applicable.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable | | | | | evaluation owner, QA/release owner, model or agent owner, and operations owner |

## Decision and acceptance

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Accepted when | |
| Backlog item to create | Create an evaluation backlog item for missing scenarios, scoring thresholds, owner review, CI/CD gate, load-test coverage, or release decision evidence. |
| Handoff owner and customer process | evaluation owner, QA/release owner, model or agent owner, and operations owner |
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

Example: Work item “gate release on safety and groundedness eval”; evidence location “Foundry evaluation run”; accepted when thresholds, owner signoff, and CI gate are recorded.
