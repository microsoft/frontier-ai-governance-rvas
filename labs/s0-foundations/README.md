# S0 Foundations & Operating Model Work Package

This lab helps the customer make one bounded governance operating-model decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry condition

Bring a bounded workload or portfolio slice, the decision owner, implementation owner, evidence owner, receiving forum or process, and the approved customer records location. If any owner, forum, or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the S0 decision, baseline mapping, forum, evidence references, acceptance test, exception status, backlog, target date, recheck trigger, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Foundation question:** the bounded workload, pilot, portfolio slice, or backlog item under review.
- **Decision route:** approve, defer, reject, route, or blocked with rationale and owner.
- **Forum and operating model:** accountable governance forum, approval path, RACI or split-ownership issue, and receiving process.
- **Baseline:** Cloud Adoption Framework for AI, Well-Architected Framework for AI, AI Center of Excellence guidance, or mapped customer baseline reference.
- **Record location:** customer-approved decision register and evidence-reference location.
- **Exceptions:** reason, equivalent control, owner, acceptance test, target date, evidence reference, and review trigger when the default path is not used.
- **Backlog and handoff:** missing owner/forum, split ownership, baseline gap, unclear exception path, or missing acceptance criteria captured with owner, target date, evidence location, accepted-when check, and recheck trigger.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Decision rights | Sponsor, governance lead, product, platform, identity, data, security, release, operations, portfolio RACI. |
| Exception | Risk statement, compensating control, owner, approver, review date, expiry, evidence reference, escalation route, closure criterion. |
| Escalation | Trigger, target forum, SLA/cadence, owner, target decision date, stop condition. |
| Evidence model | Decision reference, scope, owner, decision state, evidence reference, limits, exception, backlog, review trigger. |

## Facilitation flow

1. Confirm the customer has a bounded scope, owners, receiving forum, and approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Complete only safe references in this repository.
3. Inspect the Microsoft control path: **Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance**.
4. Map the customer baseline: governance charter, AI CoE or equivalent forum, RACI, decision register, exception route, and backlog location.
5. Ask: **Which forum owns this foundation decision, what baseline is it mapped to, and who accepts the next action?**
6. Classify the route: no owner/forum, split ownership, missing baseline, unclear exception path, missing acceptance criteria, or complete handoff.
7. Record one result in the customer system: approve, defer, reject, route, or blocked.
8. Create a foundation backlog item for each missing owner/forum, split-ownership issue, missing baseline, unclear exception path, missing acceptance test, missing record location, or S13 re-baseline trigger.
9. Handoff the decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the governance forum is named, baseline is mapped, decision record location is known, exception path is clear, and the receiving owner accepts the handoff.
- **Defer** when a forum, owner, record, baseline mapping, acceptance test, target date, or recheck trigger is missing but can be completed by a named owner.
- **Reject** when the proposed operating model cannot meet the bounded scope or leaves accountability unresolved.
- **Route** when another customer governance, risk, security, data, platform, finance, or business owner must decide first.
- **Blocked** when ownership, forum authority, evidence location, scope clarity, or baseline access prevents a decision.

## Scenario routes

| Scenario | Route | Required handoff |
|---|---|---|
| No owner or decision forum | Defer / blocked | Name accountable owner, forum, approval path, target date, and recheck trigger. |
| Split ownership | Route | Identify affected owners, interim accountability, resolving forum, and acceptance test. |
| Missing baseline | Defer | Map Microsoft/customer baseline, scope, exclusions, evidence location, owner, and target date. |
| Exception path unclear | Route | Name risk/governance forum, residual-risk owner, equivalent control, review cadence, and stop condition. |
| Backlog lacks acceptance | Defer | Add gap owner, accepted-when check, evidence reference, target date, and receiving process. |
| S13 indicates roadmap, risk, value, capacity, or cost change | Route to re-baseline | Record S13 decision reference, S0 baseline owner, trigger, target date, and forum. |

## Session-specific considerations

When completing the shared decision record, capture the technical decision record reference that supports the selected operating model, baseline framework, accountable owner, receiving governance process, exception path, and S13 re-baseline trigger.

## Handoff

Handoff to AI governance lead, executive sponsor, baseline owner, exception/risk owner, and the next session owner. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, exception status, and recheck triggers. Keep final records in the customer-approved system.
