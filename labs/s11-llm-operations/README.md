# S11 LLMOps Change Control Work Package

This lab helps the customer build one bounded LLMOps change control package and
hand it to the right customer owner. The facilitator guides the method; the
customer inspects its own Microsoft and customer records, chooses the decision,
and keeps completed evidence in its approved records system. The decision record
prepares lifecycle evidence for the customer's next process; it is not automatic
release approval.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, datasets, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, traffic movement, alias changes, automation enablement, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry condition

Bring one bounded LLMOps change, the target customer process, named artifact
owners, decision owner, approved records location, and customer source, data,
change, incident, evidence, and retention processes. If any owner or location
is missing, create a blocker backlog item instead of completing the decision.

Examples of valid scope: prompt change, retrieval config change, tool schema
change, candidate model rollout, deployment alias switch, fallback route,
feedback reuse, evaluation rubric change, retirement, or automation-readiness
decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the LLMOps change card, seven-stage lifecycle, release manifest, version contracts, rollout/fallback/rollback, feedback gate, automation readiness, decision, exception, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |
| [`templates/model-lifecycle.addendum.md`](templates/model-lifecycle.addendum.md) | Required addendum when model/deployment lifecycle state, rollout, alias switching, fallback, rollback, retirement, or automation readiness is in scope. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned record that summarizes:

- **LLMOps change card:** workload, change type, lifecycle question,
  environment, target process, affected artifacts, owners, evidence limits,
  stop condition, and approved records location.
- **Seven-stage lifecycle package:** data curation, experimentation, evaluation,
  validate/deploy, inference, monitor, and feedback/data collection records,
  each with input, output, owner, accepted-when condition, blocker, trigger, and
  receiving handoff.
- **Release manifest and version contracts:** safe references for prompt,
  retrieval, tool schema, model/deployment alias, evaluation, runtime control,
  telemetry, rollout stage, stop condition, rollback target, and approver.
- **Model/deployment lifecycle state:** baseline, candidate, fallback,
  deprecated, retired, or blocked state with support/capacity/cost assumptions,
  switch authority, rollback trigger, retirement trigger, and removal owner.
- **Rollout/fallback/rollback path:** stage plan, entry conditions, traffic
  population, excluded users, monitoring signal, stop condition, fallback
  trigger, rollback target, review date, and authority.
- **Feedback-to-curation gate:** signal source, hypothesis, privacy route,
  curation rule, candidate artifact, evaluation route, and mutation gate.
- **Automation prerequisites:** evidence required before test automation,
  canary rollout, alias switching, fallback routing, feedback-to-curation, or
  retirement automation is enabled.
- **Blockers and backlog:** missing owner, artifact reference, baseline,
  candidate, fallback, switch authority, rollback target, monitoring owner,
  feedback gate, retirement route, evidence location, access/license, or scope
  clarity captured with owner, acceptance test, target date, evidence location,
  and review trigger.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Change card | Workload, change type, lifecycle question, environment, affected artifacts, intended stage, owners, records location, evidence limits, stop condition, target process. |
| Release manifest | Release reference, prompt/instruction version, retrieval config, tool schema, model aliases, evaluation reference, runtime-control reference, telemetry reference, rollout stage, stop condition, rollback target, approver. |
| Version contracts | Prompt, model, dataset/scenario, evaluation rubric, retrieval config, tool schema, deployment alias, feedback queue, rollout plan, owner, review trigger, retirement route. |
| Model/deployment lifecycle | Baseline, candidate, fallback, deprecated, retired, blocked, support owner, capacity owner, cost owner, switch authority, rollback target, removal owner. |
| Rollout/fallback/rollback | Stage plan, entry conditions, traffic population, excluded users, failover trigger, monitoring signal, stop condition, rollback target, review date, exception path. |
| Feedback curation | Operating signal or feedback source, hypothesis, data/privacy route, curation owner, sampling/quality rule, candidate dataset/scenario or artifact, evaluation owner, mutation gate. |
| Automation readiness | Trigger, prerequisite evidence, owner, stop condition, validation reference, manual override, exception path, review trigger. |

## Facilitation flow

1. Confirm the customer has a bounded change, target process, owners, and an
   approved records location. If not, stop the decision and create a blocker
   backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md)
   into the customer-owned records system. Use
   [`templates/model-lifecycle.addendum.md`](templates/model-lifecycle.addendum.md)
   when rollout, fallback, rollback, retirement, or model/deployment lifecycle
   details are in scope.
3. Walk the Microsoft Learn LLMOps lifecycle: data curation, experimentation,
   evaluation, validate/deploy, inference, monitor, and feedback/data
   collection.
4. Build the change card and record owner, input reference, output reference,
   accepted-when condition, blocker, material-change trigger, and receiving
   handoff for each stage.
5. Build the release manifest and version contracts. Ask: **Can the candidate
   be reconstructed without copying raw prompts, outputs, datasets, telemetry,
   policy exports, or tenant configuration into the record?**
6. Record model/deployment lifecycle state. Ask: **Which baseline, candidate,
   fallback, deprecated, retired, or blocked state applies, and who owns the
   authority to test, canary, switch, fall back, roll back, retire, or automate?**
7. Record rollout/fallback/rollback details. Ask: **What monitoring signal and
   stop condition pause expansion or trigger fallback or rollback?**
8. Gate feedback-to-curation. Ask: **What prevents production observations from
   mutating prompts, data, retrieval, models, or tools without review?**
9. Check automation readiness. Ask: **What evidence must exist before testing,
   canary rollout, alias switching, fallback, feedback-to-curation, or
   retirement can be automated?**
10. Record one result in the customer system: ready for next process, defer,
    reject, route, or blocked.
11. Create a backlog item for each lifecycle stage missing an owner, gate,
    Microsoft record location, baseline/candidate/fallback state, switch
    authority, rollback route, feedback-to-curation control, model lifecycle
    decision, automation prerequisite, exception, or target date.
12. Handoff the completed decision record and backlog references to the
    receiving owners. Keep final evidence only in the customer-approved system.

## Decision criteria

- **Ready for next process** when the seven-stage lifecycle, release manifest,
  version contracts, baseline/candidate/fallback states, switch authority,
  rollback trigger, retirement condition, monitoring/feedback path, automation
  prerequisites, evidence references, exception status, acceptance test, and
  handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence
  location, and next review trigger.
- **Reject** when the scoped change cannot meet the required lifecycle control
  path or acceptance expectation safely.
- **Route** when another data/privacy, experiment, engineering, evaluation,
  platform/change, operations, legal/compliance, governance, release, portfolio,
  or accepted-risk owner must decide first.
- **Blocked** when access, licensing, evidence location, ownership, artifact
  lineage, switch authority, fallback, rollback, retirement, feedback gate, or
  scope clarity prevents a decision.

## Handoff

Handoff to the owners named in the record: data/privacy, experiment,
engineering, evaluation, platform/change, operations, LLMOps, governance,
release, portfolio, legal/compliance, or accepted-risk authority as applicable.
The receiving owner accepts only decisions or backlog items with clear
acceptance tests, target dates, evidence locations, exception status, affected
artifact references, switch authority, rollback/fallback trigger, retirement
owner, and review trigger. Keep final records in the customer-approved system.
