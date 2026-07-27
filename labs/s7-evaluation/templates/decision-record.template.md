# Evaluation Gate Decision Record

Copy this template into the customer's approved records system. Use it to record the required evaluation-gate decision for S7 Evaluation.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Gate question | |
| Decision owner | |
| Evaluation owner | |
| Model / agent owner | |
| Implementation owner | |
| Evidence owner | |
| Release / hold owner | |
| Approved records location | |
| Target date | |

## Evaluation route

Default path: **Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable**

| Route field | Record |
|---|---|
| Route selected (Foundry evaluator / manual rubric / CI/CD gate / load test / diagnostic-only / mixed) | |
| Microsoft control path reference | |
| Environment or scope assumption | |
| S6/S3 prerequisite or diagnostic-only limit | |
| Evidence-reference location | |

## Scenario set and evaluator

| Field | Record |
|---|---|
| Scenario set reference | |
| Scenario source and owner | |
| Reviewer and review time window | |
| Data / tool boundary and excluded slices | |
| Foundry evaluator / agent evaluator / scorer name | |
| Evaluator version | |
| Manual rubric version if used | |
| Evaluator or rubric limitation | |

## Baseline, thresholds, and gate

| Field | Record |
|---|---|
| Baseline run or score reference | |
| Candidate run reference | |
| Metrics in scope (for example groundedness, safety, task success, latency, cost, regression) | |
| Pass/fail thresholds | |
| Regression tolerance | |
| Threshold owner | |
| Exception owner | |
| CI/CD gate mode (blocking / warning / manual / diagnostic-only / not applicable) | |
| Pipeline or manual gate reference | |
| Azure Load Testing or performance evidence reference if applicable | |
| Release / hold process and owner | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route / blocked) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Release or backlog impact | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected scenario or metric | |
| Unsupported or unverified evaluator/gate | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Backlog and handoff

Create an evaluation backlog item for each missing scenario set, evaluator version, rubric version, baseline, threshold owner, CI/CD gate, load-test evidence, S6/S3 prerequisite, exception owner, release/hold owner, unsupported capability, or access/license blocker.

Handoff to the evaluation owner, model/agent owner, QA/release owner, runtime/platform owner where applicable, and governance owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, exception status, and release/hold ownership. Keep final records in the customer-approved system.

## Filled example

Work item "gate retrieval update on scenario set"; evidence location "customer-approved Foundry evaluation run reference, evaluator version, baseline reference, threshold-owner note, and pipeline gate reference"; accepted when scenario coverage, evaluator version, baseline comparison, thresholds, exception status, release/hold owner, and handoff are recorded.
