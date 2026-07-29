# S12 LLMOps Lifecycle Work Package

This lab helps the customer make one bounded LLMOps lifecycle decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system. The decision record prepares lifecycle evidence for the customer's next process; it is not automatic release approval.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry condition

Bring a bounded workload or portfolio slice, decision owner, data owner, experiment owner, evaluation owner, platform/change owner, service operations owner, evidence owner, governance owner, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the lifecycle decision, safe evidence references, acceptance test, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |
| [`templates/model-lifecycle.addendum.md`](templates/model-lifecycle.addendum.md) | Required addendum when model-version rollout, alias switching, fallback, rollback, retirement, or automation readiness is in scope. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Seven-stage lifecycle:** data curation, experiment, evaluation, validate/deploy, inference, monitor, and feedback/data collection records, each with owner, evidence reference, acceptance check, blocker, and handoff.
- **Model lifecycle state:** approved baseline, candidate versions, fallback route, deprecated versions, retired versions, switch authority, rollback trigger, rollback target, retirement trigger, and removal owner.
- **Rollout/fallback path:** release manifest or alias reference, canary criteria, customer change process, fallback activation criteria, rollback owner, monitoring signal, and release/hold owner.
- **Automation prerequisites:** evidence required before test automation, canary rollout, alias switching, fallback routing, feedback-to-curation, or retirement automation is enabled.
- **Blockers and backlog:** missing baseline/candidate/fallback, S7 evaluation, switch authority, rollback trigger, retirement owner, monitoring owner, feedback gate, evidence location, access/license, or scope clarity captured with owner, acceptance test, target date, evidence location, and review trigger.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Release manifest | Release reference, prompt/instruction version, retrieval config, tool schema, model alias, evaluation reference, runtime-control reference, telemetry reference, rollback target, approver. |
| Version contracts | Prompt, model, dataset, evaluation rubric, retrieval index, tool schema, deployment alias, owner, review trigger, retirement route. |
| Alias/fallback/canary | Switch authority, traffic stage, failover trigger, monitoring signal, rollback target, stop condition, exception path. |
| Feedback curation | S11 signal, hypothesis, S2 privacy/retention route, curation owner, dataset/scenario candidate, S7 evaluation route, mutation gate. |

## Facilitation flow

1. Confirm the customer has a bounded scope, owners, and an approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Use [`templates/model-lifecycle.addendum.md`](templates/model-lifecycle.addendum.md) when rollout, fallback, rollback, or retirement details are in scope. Complete only safe references in this repository.
3. Inspect the Microsoft control path: **Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**.
4. Walk the seven stages and record owner, evidence reference, acceptance check, blocker, and handoff for each stage.
5. Ask: **Which baseline, candidate, fallback, switch authority, rollback trigger, retirement condition, and S7 evaluation record make this lifecycle gate ready for handoff?**
6. Ask: **What must be true before testing, canary rollout, alias switching, fallback routing, feedback-to-curation, or retirement can be automated for a new model version?**
7. Record one result in the customer system: approve, defer, reject, route, or blocked.
8. Create an LLMOps backlog item for each lifecycle stage missing an owner, gate, Microsoft record location, baseline/candidate/fallback state, switch authority, rollback route, feedback-to-curation control, model lifecycle decision, automation prerequisite, or target date.
9. Handoff the completed decision record and backlog references to the data owner, experiment owner, evaluation owner, platform/change owner, service operations owner, and governance owner. Keep final evidence only in the customer-approved system.

## Decision criteria

- **Approve** when all seven stages, baseline/candidate/fallback states, S7 evaluation dependency, switch authority, rollback trigger, retirement condition, monitoring/feedback path, automation prerequisites, evidence references, exception status, acceptance test, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped lifecycle path cannot meet the required control path or acceptance expectation.
- **Route** when another data, experiment, evaluation, platform/change, operations, legal/compliance, governance, or exception owner must decide first.
- **Blocked** when access, licensing, evidence location, ownership, model lineage, switch authority, fallback, rollback, retirement, monitoring, or scope clarity prevents a decision.

## Session-specific considerations

When completing the decision record, capture data-curation, experiment, S7 evaluation, release manifest, deployment alias, canary, inference route, monitor/alert, feedback-to-curation, incident, rollback, retirement, model/prompt operations register, material-change decision, switch authority, and automation-readiness references.

## Handoff

Handoff to data owner, experiment owner, evaluation owner, platform/change owner, service operations, and governance owner. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, exception status, model version or deployment alias where relevant, switch authority, rollback trigger, and retirement owner. Keep final records in the customer-approved system.
