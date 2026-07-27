# S10 In-Process Governance Work Package

This lab helps the customer make one bounded in-process governance decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, the decision owner, implementation owner, evidence owner, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Work package outcome

By the end of the lab, the customer has inspected the existing gateway/platform control, runtime decision point, Agent Governance Toolkit applicability record, policy owner, and evidence route; recorded approve, defer, reject, or route; created backlog for gaps; and documented any exception.

## Required record

| Record | Use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the session decision, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |

## Facilitation flow

1. Inspect the Microsoft control path: **Agent Governance Toolkit only when gateway controls cannot make the needed in-process decision**.
2. Confirm the record exists, has an accountable owner, names the environment or scope, and can be referenced from the customer record system.
3. Copy the required decision record into the customer's approved records system and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, backlog, and handoff fields.
4. Ask: **Which Microsoft record proves this decision is ready to hand off, and who operates it next?**
5. Record one result: approve, defer, reject, or route.
6. Create an in-process-governance backlog item only for decisions the gateway cannot enforce; include policy owner, runtime evidence, test, target date, and rollback route.

## Decision criteria

- **Approve** when the Microsoft control path is present, owned, evidenced, and accepted by the receiving owner.
- **Defer** when a record, owner, acceptance test, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope.
- **Route** when another Microsoft control owner must decide first.

## Handoff

Handoff to agent engineering owner, policy owner, runtime operations, and release manager. The receiving owner accepts only backlog items with clear acceptance tests, target dates, and evidence locations. Keep final records in the customer-approved system.
