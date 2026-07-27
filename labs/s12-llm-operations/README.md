# S12 LLMOps Lifecycle Work Package

This lab helps the customer make one bounded LLMOps lifecycle decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, the decision owner, implementation owner, evidence owner, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Work package outcome

By the end of the lab, the customer has:

- inspected the data-curation record, experiment/candidate artifact, Foundry evaluation, validate/deploy release record, inference route, Azure Monitor/Application Insights signal, and governed feedback route;
- recorded the model lifecycle state for approved baseline, candidate, fallback, deprecated, and retired model versions;
- decided who can approve testing, rollout, traffic switching, rollback, and retirement, plus the evidence needed before those steps can be automated;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Required record

| Record | Use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the session decision, lifecycle state, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |

## Facilitation flow

1. Inspect the Microsoft control path: **Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**.
2. Confirm the record exists, has an accountable owner, names the environment or scope, and can be referenced from the customer record system.
3. Inspect the model lifecycle record for the workload: approved baseline model or deployment alias, candidate versions, fallback model, deprecated versions, retirement condition, comparison evidence, switch authority, rollout stage, and rollback trigger.
4. Copy the required decision record into the customer's approved records system and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, backlog, handoff, and model lifecycle fields.
5. Ask: **Which Microsoft record proves this decision is ready to hand off, and who operates it next?**
6. Ask: **What must be true before testing, canary rollout, alias switching, fallback routing, or retirement can be automated for a new model version?**
7. Record one result: approve, defer, reject, or route.
8. Create an LLMOps backlog item for each lifecycle stage missing an owner, gate, Microsoft record location, rollback route, feedback-to-curation control, model lifecycle decision, or target date.

## Decision criteria

- **Approve** when the Microsoft control path is present, owned, evidenced, and accepted by the receiving owner.
- **Defer** when a record, owner, acceptance test, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope.
- **Route** when another Microsoft control owner must decide first.

## Handoff

Handoff to data owner, experiment owner, evaluation owner, platform/change owner, service operations, and governance owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and model version or deployment alias where relevant. Keep final records in the customer-approved system.
