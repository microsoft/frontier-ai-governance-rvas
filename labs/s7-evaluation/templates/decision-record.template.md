# Evaluation Evidence Decision Record

Copy this template into the customer's approved records system. Use it to record
the required evaluation evidence package for S7 Evaluation.

> **Safety boundary:** Use safe references only. Do not place customer
> identifiers, secrets, prompt text, model outputs, datasets, evaluator exports,
> telemetry exports, live configuration, access grants, tenant changes, runtime
> proof, enforcement evidence, or production approval claims in this repository.
> Do not change tenant configuration, evaluator configuration, CI/CD gates, or
> live policy during the lab.

## Evaluation candidate card

| Field | Record |
|---|---|
| Workload / capability | |
| Candidate change type (model / prompt / retrieval / tool or API / policy / orchestration / deployment alias / release package) | |
| Release question | |
| Environment and lifecycle state | |
| Decision owner | |
| Scenario owner | |
| Evaluation owner | |
| Model / agent owner | |
| Threshold owner | |
| Evidence owner | |
| Release / hold owner | |
| Rollback / remediation owner | |
| Approved records location | |
| Target date | |
| Material-change triggers | |

## Runtime prerequisite and diagnostic-only boundary

| Field | Record |
|---|---|
| Accepted runtime-path evidence reference | |
| Route and environment covered by the runtime evidence | |
| Runtime/platform gap, if any | |
| Diagnostic-only status (yes / no) | |
| Release-reliance limit if diagnostic-only | |
| Evidence-reference location | |

## Scenario-set package

| Field | Record |
|---|---|
| Scenario-set reference and version | |
| Scenario source and owner | |
| Population represented | |
| Sampling method | |
| Included slices | |
| Excluded or unsupported slices | |
| Data / tool boundary | |
| Environment assumption | |
| Reviewer role | |
| Review time window | |
| Re-entry trigger | |

## Evaluator and rubric package

Default path: **Microsoft Foundry evaluations, agent evaluators, cloud
evaluation, CI/CD integration, and Azure Load Testing where applicable**

| Route field | Record |
|---|---|
| Route selected (Foundry evaluator / agent evaluator / manual rubric / CI/CD gate / load test / diagnostic-only / mixed) | |
| Foundry evaluator / agent evaluator / scorer name | |
| Evaluator version | |
| Manual rubric version if used | |
| Scorer or configuration reference | |
| Evaluator or rubric limitation | |
| Interpretation owner | |
| Fallback route if unsupported or unavailable | |
| Raw prompt/output/dataset handling boundary | |

## Baseline, thresholds, and exceptions

| Field | Record |
|---|---|
| Baseline run, score, or accepted behavior reference | |
| Candidate run reference | |
| Comparison rule | |
| Metrics in scope (for example groundedness, safety, task success, tool accuracy, latency, cost, regression) | |
| Pass/fail thresholds | |
| Regression tolerance | |
| Threshold owner | |
| Exception owner | |
| Exception expiry or review date | |
| Compensating review if exception is accepted | |
| Re-evaluation criterion | |

## CI/CD gate behavior

| Field | Record |
|---|---|
| Gate mode (manual / blocking CI/CD / warning CI/CD / mixed / diagnostic-only / not applicable) | |
| Pipeline or manual gate reference | |
| Pipeline identity and secretless/federated route | |
| Evidence storage location | |
| Failure behavior | |
| Override or exception route | |
| Rollback / remediation owner | |
| Release / hold process and owner | |

## Performance and cost package

Complete when latency, throughput, quota, saturation, or cost affects the
release question.

| Field | Record |
|---|---|
| Workload model and request mix | |
| Concurrency or burst assumption | |
| First-token / TTFB target | |
| Inter-token target | |
| End-to-end p50 / p95 / p99 target | |
| Throughput target | |
| Error or saturation threshold | |
| Quota / PTU / capacity assumption | |
| Token cost or budget assumption | |
| Cache / fallback behavior | |
| Load-test or telemetry evidence reference | |
| Environment-fidelity limitation | |
| Operating reconciliation owner | |

## Finding-to-action map

| Finding field | Record |
|---|---|
| Finding summary | |
| Affected scenario or slice | |
| Finding type (groundedness / safety / tool use / task failure / regression / latency / cost / missing prerequisite / other) | |
| Release impact (continue / hold / defer / reject / route / block / diagnostic-only) | |
| Action type (release blocker / accepted exception / diagnostic-only observation / operating hypothesis / data backlog / engineering backlog / tool-contract backlog / safety review / rollback / repeat evaluation) | |
| Owner | |
| Closure evidence needed | |
| Target date | |
| Review trigger | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (continue / hold / defer / reject / route / blocked / diagnostic-only) | |
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

Complete this section only when the Microsoft default is not used, an evaluator
or gate is unsupported, diagnostic-only evidence is accepted for backlog, or the
customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected scenario, slice, or metric | |
| Unsupported or unverified evaluator/gate | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Expiry or review date | |
| Review trigger | |

## Backlog and handoff

Create an evaluation backlog item for each missing scenario set, evaluator
version, rubric version, baseline, threshold owner, CI/CD gate, load-test
evidence, runtime/platform prerequisite, exception owner, release/hold owner,
rollback/remediation owner, unsupported capability, or access/license blocker.

Handoff to the evaluation owner, model/agent owner, QA/release owner,
runtime/platform owner where applicable, performance owner where applicable,
rollback/remediation owner, and governance owner. The receiving owner accepts
only backlog items with clear acceptance tests, target dates, evidence
locations, exception status, diagnostic-only limits, and release/hold ownership.
Keep final records in the customer-approved system.

## Filled example

Work item "evaluate retrieval update on scenario set"; evidence location
"customer-approved Foundry evaluation run reference, evaluator version, baseline
reference, threshold-owner note, runtime-path acceptance reference, and pipeline
gate reference"; accepted when scenario coverage, evaluator version, baseline
comparison, thresholds, exception status, release/hold owner, rollback owner,
and handoff are recorded.
