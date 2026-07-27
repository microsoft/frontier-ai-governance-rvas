# S12 LLMOps Lifecycle Runbook

Use this runbook to guide the required lab path. The customer inspects its own Microsoft LLMOps records, records safe references in its approved system, and decides whether the scoped lifecycle gate is ready for handoff.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry gate

Confirm the customer has a bounded workload or portfolio slice, a decision owner, data owner, experiment owner, evaluation owner, platform/change owner, service operations owner, evidence owner, governance owner, and an approved records location. If any are missing, stop the decision and create a blocker backlog item with the missing owner, record, or approval path.

## Required seven-stage review flow

1. **Set the lifecycle question.** Record the bounded decision, such as whether a candidate model, prompt change, deployment alias, or feedback-to-curation path has enough lifecycle evidence for handoff.
2. **Data curation.** Record safe references for source data or feedback queue, data classification dependency, quality check, curation owner, training/evaluation split, data-rights/privacy review, and handoff. Keep customer evidence in approved systems.
3. **Experiment.** Record candidate model or prompt artifact, lineage, parameter or prompt-change reference, experiment owner, cost/capacity assumption, and baseline comparison target.
4. **Evaluation.** Reference the S7 evaluation record, evaluator version, scenario set, thresholds, baseline, candidate results, exception owner, and limitations. Route to S7 when these are missing.
5. **Validate/deploy.** Record release manifest, deployment alias, canary or phased rollout criteria, customer change process, release/hold owner, rollback target, and evidence required before deployment approval. Do not treat this record as deployment approval.
6. **Inference.** Record inference route, gateway/API boundary, traffic-switch authority, fallback model or route, quota/cost/SLA owner, unsupported paths, and change owner.
7. **Monitor.** Record Azure Monitor/Application Insights or equivalent signal reference, reviewer, review cadence, alert route, fallback/rollback decision input, blind spots, and retention owner.
8. **Feedback/data collection.** Record feedback route, triage owner, privacy/data review, curation handoff, mutation gate, and evidence reference. Production observations must not mutate prompts or data without gate review.
9. **Model rollout and fallback state.** Record approved baseline model or alias, candidate versions, fallback model/route, deprecated versions, retired versions, rollback trigger, rollback owner, retirement trigger, removal owner, and switch authority.
10. **Automation prerequisites.** Before enabling automation for testing, canary rollout, alias switching, fallback routing, feedback-to-curation, or retirement, record required evidence, owners, thresholds, exception path, rollback target, monitoring signal, and stop condition.
11. **Set decision state.** Use one state:
    - `approve`: seven stages, baseline/candidate/fallback, S7 evaluation, switch authority, rollback, retirement, automation prerequisites, evidence reference, acceptance test, and handoff are complete;
    - `defer`: a gap has a named owner and target date;
    - `reject`: the scoped lifecycle path cannot meet the lifecycle question safely;
    - `route`: another data, experiment, evaluation, platform/change, operations, governance, legal/compliance, or exception owner must decide first;
    - `blocked`: access, licensing, evidence location, ownership, model lineage, switch authority, fallback, rollback, retirement, monitoring, or scope clarity prevents a decision.
12. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, release or backlog impact, and next review trigger.
13. **Handoff.** Send the completed decision record, model lifecycle addendum, and backlog references to the data owner, experiment owner, evaluation owner, platform/change owner, service operations owner, and governance owner.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `record-location-missing`, `data-curation-gap`, `feedback-gate-missing`, `experiment-lineage-missing`, `baseline-missing`, `candidate-state-missing`, `fallback-route-missing`, `s7-evaluation-missing`, `threshold-owner-missing`, `validate-deploy-record-missing`, `switch-authority-missing`, `rollback-trigger-missing`, `rollback-target-missing`, `monitoring-signal-missing`, `retirement-owner-missing`, `automation-prerequisite-missing`, `access-or-license`, `unsupported-region-sku-tenant`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes the seven-stage lifecycle review, approved baseline, candidate versions, fallback route, deprecated/retired versions, switch authority, rollback trigger and target, retirement trigger and owner, S7 evaluation dependency, monitoring and feedback path, automation prerequisites, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
