# Practical workshop: evaluation gate

**Microsoft default:** Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable.

**Customer decision:** Approve, defer, reject, route, or block the evaluation gate for one bounded workload. This is an evidence-readiness and handoff decision only; it is not automatic release approval.

## Work the decision

1. **Choose the gate scope.** Select one pilot, prompt flow, agent capability, model version, retrieval change, or backlog item. Name the customer decision owner, evaluation owner, release/hold owner, evidence owner, implementation owner, and approved records location.
2. **Choose the evaluation route.** Use the smallest route that fits the evidence available:

| Route | Use when | Practical decision cue |
|---|---|---|
| Foundry evaluator route | Microsoft Foundry evaluations or agent evaluators are configured for the scoped workload | Approve only when scenario set, evaluator names and versions, baseline, thresholds, run reference, and gate owner are recorded. |
| Manual rubric route | SME review or red-team rubric is the current control | Defer automation until rubric version, sample method, reviewer role, pass/fail rule, adjudication owner, and evidence reference are recorded. |
| CI/CD gate route | Release pipeline should stop or warn based on evaluation results | Record gate mode, threshold owner, exception owner, release/hold owner, and rollback/handoff path. Do not treat the record as production approval. |
| Load-test route | Latency, throughput, cost, quota, or regression tolerance affects the decision | Link Azure Load Testing or equivalent customer-approved performance evidence to evaluation acceptance. |
| Diagnostic-only route | S6 runtime assurance, telemetry, gateway, or environment prerequisites are missing | Mark the gate diagnostic-only and defer release reliance until S6/S3 prerequisites and evidence owners are named. |

3. **Inspect scenario and evaluator coverage.** Record the scenario set, source of scenarios, scenario owner, environment assumption, data/tool boundary, evaluator/scorer names, evaluator version, rubric version, and any unsupported slice. Empty or passing results are not enough unless scope, time window, reviewer, and baseline are recorded.
4. **Confirm baseline and threshold ownership.** Name the baseline run or score, candidate run, pass/fail thresholds, regression tolerance, threshold owner, and exception owner. If no baseline exists for groundedness, safety, task success, latency, cost, or quality regression, defer with an acceptance test.
5. **Review gate execution path.** Record whether the gate is Foundry-only, manual review, pipeline check, diagnostic-only, or paired with load testing. Name the release/hold owner and the process that receives exceptions. The workshop may prepare gate evidence; it does not approve production or change tenant policy.
6. **Record the outcome and handoff.** Approve only when the receiving owner accepts that the evaluation record is complete enough for the next customer process. Otherwise defer, reject, route, or block with owner, target date, evidence reference, and review trigger.

## Decision record

Fill this record in the customer-approved records system. Store only safe references here; completed customer evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Pilot evaluation-gate decision |
| Gate scope | Workload, capability, model/prompt/retrieval change, environment assumption, and decision owner |
| Evaluation route | Foundry evaluator, manual rubric, CI/CD gate, load test, diagnostic-only, or mixed route |
| Scenario set | Scenario-set reference, source, owner, reviewer, time window, and unsupported slices |
| Evaluator / rubric | Evaluator names, evaluator version, rubric version, scorer configuration reference, and limitation |
| Baseline and candidate | Baseline run/score reference, candidate run reference, comparison rule, and regression tolerance |
| Threshold owner | Owner for pass/fail thresholds, threshold changes, and exception criteria |
| CI/CD gate | Pipeline/check reference, gate mode, evidence requirement, exception path, and receiving release/hold owner |
| Load test | Performance, latency, quota, cost, or regression evidence reference and owner, when applicable |
| S6/S3 dependency | Runtime, telemetry, gateway, environment, or platform prerequisite that limits release reliance |
| Defer criteria | Missing scenario set, evaluator version, baseline, threshold owner, load-test evidence, S6 prerequisite, release/hold owner, or evidence location |
| Accepted when | Scenario set, evaluator/rubric version, baseline, threshold owner, evidence reference, exception status, release/hold owner, target date, and handoff are complete |

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Scenario set | scoped scenarios, owner, source, reviewed time window, environment assumption, and excluded slices are recorded | Evaluation owner |
| Evaluator version | Foundry evaluator, agent evaluator, scorer, or manual rubric version is named with limitation and reviewer | Evaluation owner |
| Threshold owner | pass/fail thresholds, regression tolerance, and exception criteria have an accountable owner | Product/evaluation owner |
| Baseline | baseline and candidate references exist for quality, safety, groundedness, task success, latency, or other selected metrics | Model/agent owner |
| CI/CD gate | gate mode, release/hold owner, exception owner, and pipeline evidence reference are recorded without claiming automatic release approval | Release owner |
| Load test | performance evidence owner and acceptance rule are recorded when latency, quota, throughput, or cost matters | Performance owner |
| Diagnostic-only path | missing S6/S3/runtime prerequisites are named and the record is not used as release reliance | Runtime/platform owner |
| Workshop safety | no customer evidence is copied here, no tenant/live-policy change is made, and no runtime-proof or production-approval claim is made | Facilitator |

## Decision tree

- **Approve readiness** when the Microsoft path fits, evidence references and owners are complete, and the receiving owner accepts the handoff for the next customer process.
- **Defer** when records, scenario coverage, evaluator version, baseline, thresholds, load-test evidence, or owners are missing. Include owner, target date, acceptance test, and review trigger.
- **Reject** when the scoped evaluation path cannot meet the bounded question safely.
- **Route** when release engineering, product, security, runtime assurance, platform, legal/compliance, or an exception owner must decide first.
- **Block** when missing approved records location, owner, access, S6/S3 prerequisite, or scope clarity prevents a decision.

For an exception, record: reason, affected scenario, unsupported evaluator or gate, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, receiving owner, and review trigger.

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. This workshop changes no tenant policy, proves no runtime enforcement, and does not approve production.
