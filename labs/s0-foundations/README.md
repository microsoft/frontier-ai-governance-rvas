# S0 Foundations & Operating Model Work Package

This lab helps the customer make one bounded governance operating-model decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, the decision owner, implementation owner, evidence owner, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Work package outcome

By the end of the lab, the customer has:

- inspected the customer governance charter, AI CoE/RACI record, control-framework baseline, and approved decision register location;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Required record

| Record | Use |
|---|---|
| [`../templates/decision-record.template.md`](../templates/decision-record.template.md) | Shared required customer-owned record for the session decision, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |

## Facilitation flow

1. Inspect the Microsoft control path: **Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance**.
2. Confirm the record exists, has an accountable owner, names the environment or scope, and can be referenced from the customer record system.
3. Copy the required decision record into the customer's approved records system and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, backlog, and handoff fields.
4. Ask: **Which Microsoft record proves this decision is ready to hand off, and who operates it next?**
5. Record one result: approve, defer, reject, or route.
6. Create a foundation backlog item with selected operating model, baseline framework, accountable owner, acceptance test, target date, and receiving governance process.

## Decision criteria

- **Approve** when the Microsoft control path is present, owned, evidenced, and accepted by the receiving owner.
- **Defer** when a record, owner, acceptance test, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope.
- **Route** when another Microsoft control owner must decide first.

## Session-specific considerations

When completing the shared decision record, capture the technical decision record reference that supports the selected operating model, baseline framework, accountable owner, and receiving governance process.

## Handoff

Handoff to AI governance lead, executive sponsor, and the next session owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, and evidence locations. Keep final records in the customer-approved system.
