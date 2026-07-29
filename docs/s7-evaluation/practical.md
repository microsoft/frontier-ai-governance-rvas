# Practical workshop: evaluation evidence package

**Microsoft default:** Microsoft Foundry evaluations, agent evaluators, cloud
evaluation, CI/CD integration, and Azure Load Testing where applicable.

**Customer decision:** Continue, hold, defer, reject, route, block, or mark
diagnostic-only for one bounded candidate change. This is an evidence-readiness
and handoff decision only; it is not automatic release approval.

## Work the decision

1. **Choose the candidate change.** Select one pilot, prompt/instruction,
   agent capability, model version, retrieval change, tool/API change,
   policy/control change, deployment alias, or release package. Name the model
   or agent owner, scenario owner, evaluation owner, threshold owner, evidence
   owner, release/hold owner, rollback/remediation owner, and approved records
   location.
2. **Confirm runtime prerequisite.** If accepted runtime-path evidence exists
   for the route and environment, reference it safely. If it does not, mark the
   package diagnostic-only and do not use it for release reliance.
3. **Build the scenario-set package.** Record scenario-set reference, source,
   owner, population, sampling method, included and excluded slices, data/tool
   boundary, environment assumption, reviewer role, time window, and
   material-change triggers.
4. **Choose the evaluation route.** Use the smallest route that fits the
   question and evidence available:

| Route | Use when | Practical decision cue |
|---|---|---|
| Foundry evaluator route | Microsoft Foundry evaluations cover the selected dimension and environment. | Continue only when scenario set, evaluator names and versions, baseline, thresholds, run reference, limitation, and interpretation owner are recorded. |
| Agent evaluator route | Tool use, task completion, intent resolution, or agent behavior must be reviewed. | Record tool boundary, trace reference, task rubric, unsupported paths, and re-evaluation trigger. |
| Manual rubric route | SME, domain, policy, legal, or human-review judgment is the current control. | Defer automation until rubric version, sample method, reviewer role, pass/fail rule, adjudication owner, and evidence reference are recorded. |
| CI/CD gate route | Release pipeline should stop or warn based on evaluation results. | Record gate mode, pipeline identity, threshold owner, exception owner, evidence storage, failure behavior, release/hold owner, and rollback path. |
| Load-test route | Latency, throughput, cost, quota, saturation, or regression tolerance affects the decision. | Link Azure Load Testing or equivalent customer-approved performance evidence to evaluation acceptance and operating reconciliation. |
| Diagnostic-only route | Runtime assurance, telemetry, gateway, evaluator support, or environment prerequisites are missing. | Mark the package diagnostic-only and defer release reliance until prerequisites and evidence owners are named. |

5. **Confirm baseline and threshold ownership.** Name the baseline run or score,
   candidate run, comparison rule, selected metrics, pass/fail thresholds,
   regression tolerance, threshold owner, exception owner, rollback/remediation
   owner, and re-evaluation criterion.
6. **Review gate execution path.** Record whether the gate is manual review,
   blocking CI/CD, warning CI/CD, diagnostic-only, mixed, or not applicable.
   Name the process that receives exceptions. The workshop may prepare gate
   evidence; it does not approve production or change tenant policy.
7. **Map findings to action.** Turn every result into release blocker, accepted
   exception, diagnostic-only observation, operating hypothesis, engineering
   backlog, data/retrieval backlog, tool-contract backlog, safety review,
   rollback option, or repeat-evaluation criterion.
8. **Record the outcome and handoff.** Continue only when the receiving owner
   accepts that the evaluation evidence package is complete enough for the next
   customer process. Otherwise hold, defer, reject, route, block, or mark
   diagnostic-only with owner, target date, evidence reference, and review
   trigger.

## Decision record

Fill this record in the customer-approved records system. Store only safe
references here; completed customer evidence remains in customer systems.

| Field | Record |
|---|---|
| Candidate change | Workload, capability, model/prompt/retrieval/tool/policy/deployment change, environment assumption, lifecycle state, and release question |
| Runtime prerequisite | Accepted runtime-path evidence reference or diagnostic-only limit |
| Scenario set | Scenario-set reference, source, owner, population, sampling method, reviewer, time window, data/tool boundary, and unsupported slices |
| Evaluator / rubric | Foundry evaluator, agent evaluator, manual rubric, CI/CD route, load route, evaluator version, scorer configuration reference, limitation, and fallback |
| Baseline and candidate | Baseline reference, candidate run reference, comparison rule, selected metrics, and regression tolerance |
| Threshold and exception | Threshold owner, pass/fail rule, exception owner, expiry, compensating review, and re-evaluation criterion |
| Gate behavior | Manual, blocking CI/CD, warning CI/CD, mixed, diagnostic-only, or not applicable; pipeline identity, evidence storage, failure behavior, override owner, and release/hold owner |
| Performance and cost | Workload model, latency targets, throughput, error/saturation, quota/capacity, token cost, fallback/cache, evidence reference, and operating owner |
| Finding-to-action | Release blocker, accepted exception, diagnostic-only observation, operating hypothesis, backlog item, rollback/remediation, or repeat evaluation |
| Defer criteria | Missing scenario set, evaluator version, baseline, threshold owner, performance evidence, runtime prerequisite, release/hold owner, rollback route, or evidence location |
| Accepted when | Runtime prerequisite or diagnostic-only limit, scenario set, evaluator/rubric version, baseline, threshold owner, exception status, release/hold owner, target date, and handoff are complete |

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Candidate card | scoped change, release question, owners, environment, approved records location, and material-change triggers are recorded | Evaluation owner |
| Runtime prerequisite | accepted runtime-path evidence is referenced, or diagnostic-only status is explicit | Runtime/platform owner |
| Scenario set | scoped scenarios, source, owner, sampling method, reviewed time window, environment assumption, and excluded slices are recorded | Scenario owner |
| Evaluator version | Foundry evaluator, agent evaluator, scorer, or manual rubric version is named with limitation and reviewer | Evaluation owner |
| Baseline | baseline and candidate references exist for selected quality, safety, groundedness, task success, latency, cost, or regression metrics | Model/agent owner |
| Threshold owner | pass/fail thresholds, regression tolerance, exception criteria, and re-evaluation rule have an accountable owner | Product/evaluation owner |
| CI/CD gate | gate mode, release/hold owner, exception owner, failure behavior, override route, and evidence reference are recorded without claiming automatic release approval | Release owner |
| Load test | performance evidence owner and acceptance rule are recorded when latency, quota, throughput, saturation, or cost matters | Performance owner |
| Diagnostic-only path | missing prerequisites are named and the record is not used as release reliance | Evaluation owner |
| Workshop safety | no customer evidence is copied here, no tenant/live-policy change is made, and no runtime-proof or production-approval claim is made | Facilitator |

## Decision tree

- **Continue** when the Microsoft path fits, runtime prerequisite is accepted,
  scenario/evaluator/baseline/threshold records are complete, and the release
  owner accepts the handoff for the next customer process.
- **Hold** when the evidence package shows a release blocker, unacceptable
  regression, missing rollback route, unsafe finding, or threshold failure.
- **Defer** when records, scenario coverage, evaluator version, baseline,
  thresholds, performance evidence, or owners are missing but can be completed.
- **Reject** when the scoped evaluation path cannot meet the bounded question
  safely.
- **Route** when release engineering, product, security, runtime/platform,
  legal/compliance, performance, or an exception owner must decide first.
- **Block** when missing approved records location, owner, access, runtime
  prerequisite, evaluator support, or scope clarity prevents a decision.
- **Diagnostic-only** when the package can inform backlog but cannot support
  release reliance.

For an exception, record: reason, affected scenario, unsupported evaluator or
gate, equivalent customer-owned control if one exists, owner, evidence location
reference, acceptance test, target date, receiving owner, expiry, and review
trigger.

**Boundary:** Keep customer data and evidence in customer-approved systems; store
references only. This workshop changes no tenant policy, configures no
evaluator, proves no runtime enforcement, and does not approve production.
