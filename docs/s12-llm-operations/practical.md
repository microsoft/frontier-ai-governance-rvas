# Practical workshop: LLMOps lifecycle gate

**Microsoft default:** Microsoft Learn LLMOps inner/outer-loop lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection.

**Customer decision:** Approve, defer, reject, route, or block the next lifecycle gate for one bounded workload. This is a lifecycle-readiness and handoff decision only; it is not automatic release approval.

## Work the decision

1. **Choose the lifecycle scope.** Select one model, deployment alias, prompt/model change, agent capability, data-curation queue, or backlog item. Name the decision owner, data owner, experiment owner, evaluation owner, platform/change owner, service operations owner, governance owner, and approved records location.
2. **Walk the seven-stage lifecycle.** Record the customer-owned evidence reference, owner, decision, blocker, and handoff for each stage:

| Stage | Inspect | Practical decision cue |
|---|---|---|
| Data curation | source, label/classification dependency, feedback queue, training/eval split, approval owner | Defer when feedback or customer evidence is not in approved systems or data rights/quality owner is missing. |
| Experiment | candidate model or prompt, parameters, training/prompt change record, cost/capacity assumption | Defer when candidate lineage, experiment owner, or baseline comparison is missing. |
| Evaluation | S7 evaluation record, safety/quality/cost/latency thresholds, regression tolerance | Route to S7 when thresholds, baseline, evaluator version, or exception owner is missing. |
| Validate/deploy | release manifest, deployment alias, canary criteria, change owner, rollback target | Do not treat lifecycle record as deployment approval; record the customer process that approves or holds the change. |
| Inference | route, gateway/API boundary, fallback route, cost/quota/SLA owner | Defer when inference route, switch authority, fallback, or rollback trigger is unowned. |
| Monitor | Azure Monitor/Application Insights or equivalent signal, reviewer, cadence, alert route | Defer when monitoring is planned but not owned or cannot support rollback/fallback decisions. |
| Feedback/data collection | feedback capture, triage, privacy/data review, curation handoff | Defer when production observations would mutate data or prompts without gate review. |

3. **Record model lifecycle state.** Name the approved baseline model/deployment alias, candidate versions, fallback model or route, deprecated versions, retirement condition, comparison evidence, switch authority, rollback trigger, rollback owner, and retirement owner.
4. **Check rollout and fallback authority.** Record who can approve testing, promote or switch traffic, activate fallback, roll back, retire a version, or enable automation. If authority is ambiguous, defer or route.
5. **Confirm automation prerequisites.** Before automating tests, canary rollout, alias switching, fallback routing, feedback-to-curation, or retirement, require baseline/candidate/fallback references, thresholds, rollback trigger, switch authority, evidence owner, monitoring owner, and exception path.
6. **Record the outcome and handoff.** Approve only when the lifecycle record is complete enough for the receiving owner to act in the customer's next process. Otherwise defer, reject, route, or block with owner, target date, evidence reference, and review trigger.

## Decision record

Fill this record in the customer-approved records system. Store only safe references here; completed customer evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Pilot LLMOps lifecycle decision |
| Lifecycle scope | Model, deployment alias, prompt/model change, agent capability, data queue, environment assumption, and decision owner |
| Data curation | data/feedback reference, owner, quality/data-rights check, and handoff |
| Experiment | candidate artifact, lineage, parameters or prompt-change reference, owner, and cost/capacity assumption |
| Evaluation | S7 evaluation reference, thresholds, evaluator version, baseline, exception owner, and limitation |
| Validate/deploy | release manifest, deployment alias, canary criteria, change process, and release/hold owner |
| Inference | route, gateway/API boundary, fallback route, quota/cost/SLA owner, and switch authority |
| Monitor | signal source, reviewer, cadence, alert route, rollback/fallback decision input, and blind spots |
| Feedback/data collection | feedback route, triage owner, privacy/data review, curation handoff, and mutation gate |
| Model lifecycle state | approved baseline, candidate, fallback, deprecated/retired versions, rollback target, retirement trigger, and removal owner |
| Automation readiness | prerequisites before testing, rollout, alias switching, fallback, feedback-to-curation, or retirement automation |
| Defer criteria | missing baseline/candidate/fallback, switch authority, rollback trigger, retirement owner, monitoring owner, evaluation record, or approved evidence location |
| Accepted when | seven-stage lifecycle, baseline/candidate/fallback states, switch authority, rollback, retirement, automation prerequisites, exception status, target date, and handoff are complete |

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Baseline/candidate/fallback | approved baseline alias, candidate versions, fallback route, and comparison evidence are recorded | Model owner |
| Switch authority | authority for testing, canary, traffic switch, fallback, rollback, retirement, and automation enablement is named | Platform/change owner |
| Rollback | trigger, owner, target, evidence source, and customer process are recorded | Service operations |
| Retirement | deprecated/retired versions, retirement trigger, removal owner, review date, and residual dependency check are recorded | Model/platform owner |
| Evaluation dependency | S7 record has evaluator version, thresholds, baseline, exception owner, and limitations | Evaluation owner |
| Monitoring and feedback | monitor signal, review cadence, alert/fallback route, feedback triage, data/privacy review, and curation handoff are owned | Operations/data owner |
| Automation prerequisites | all evidence required before test, rollout, alias switch, fallback, feedback-to-curation, or retirement automation is named | MLOps owner |
| Workshop safety | no customer evidence is copied here, no tenant/live-policy change is made, and no deployment, runtime-proof, or production-approval claim is made | Facilitator |

## Decision tree

- **Approve readiness** when the seven-stage lifecycle path fits, evidence references and owners are complete, and the receiving owner accepts the handoff for the next customer process.
- **Defer** when records, owners, baseline/candidate/fallback state, S7 evaluation, monitoring, rollback, retirement, or automation prerequisites are missing. Include owner, target date, acceptance test, and review trigger.
- **Reject** when the scoped lifecycle path cannot meet the bounded question safely.
- **Route** when data, experiment, evaluation, platform/change, service operations, governance, legal/compliance, or an exception owner must decide first.
- **Block** when missing approved records location, owner, access, model lineage, switch authority, fallback, rollback, or scope clarity prevents a decision.

For an exception, record: reason, affected lifecycle stage, unsupported or unverified control, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, receiving owner, and review trigger.

Future automation prompt: **What evidence must pass before the team can automate testing, canary rollout, alias switching, fallback routing, feedback-to-curation, or retirement of a model version?**

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. This workshop changes no tenant policy, proves no runtime enforcement, and does not approve production.
