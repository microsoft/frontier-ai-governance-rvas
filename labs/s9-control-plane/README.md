# S9 Control Plane Work Package

This lab helps the customer make one bounded control-plane registry reconciliation and lifecycle closeout decision. It is not a catalog deployment, tenant query, access change, lifecycle change, runtime proof, enforcement exercise, or production approval. The facilitator guides the method; the customer inspects its own Microsoft and customer-owned records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, tenant IDs, object IDs, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, retirement artifacts, or production approval claims in this repository.

## Entry condition

Bring one bounded population or portfolio slice, scope question, decision owner, control-plane steward, lifecycle owner, finding owners, evidence owner, approved customer records location, and receiving governance/operations owner. If any owner, steward, join-key source, or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the registry population card, canonical fields, source-of-record map, explicit join keys, reconciliation findings, lifecycle/material-change checks, closeout-with-gaps decision, evidence references, exception status, backlog, target date, recurrence check, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned control-plane reconciliation package that summarizes:

- **Registry population card:** scope question, included/excluded records, environment boundary, steward, evidence owner, lifecycle owner, approved records location, closure owner, and review cadence.
- **Canonical registry fields:** agent/workload, identity, tool/API/action, model/deployment, data source, telemetry, lifecycle, exception, and closeout fields.
- **Source-of-record map:** field-level authority for Agent 365 where available, Entra Agent ID/workload identity, Foundry, API Center, API Management/gateway, Azure Monitor/Application Insights, customer register/GRC/CMDB, and lifecycle/change records.
- **Explicit join keys:** registry ID, platform object ID, agent identity ID, application ID, API ID, route ID, tool schema ID, Foundry reference, deployment alias, telemetry correlation key, or customer record reference.
- **Reconciliation result:** matched, missing, duplicate, stale, conflicting, unsupported, no-steward, blocked, or close-with-owned-gaps, with safe evidence references only.
- **Lifecycle controls:** proposed, active_review, publish_ready, published, hold, suspended, deprecated, retired, or withdrawn state; transition owner; review reference; material-change trigger; retained-record location; and reopen trigger.
- **Blockers and backlog:** missing source-of-record rule, steward, join key, owner, identity link, API/tool dependency, Foundry/API Center linkage, telemetry pointer, lifecycle state, conflict rule, retirement evidence, recurrence check, or evidence location captured with owner, acceptance test, target date, and review trigger.
- **Handoff:** control-plane steward, identity owner, API/tool owner, Foundry/platform owner, telemetry/operations owner, lifecycle/catalog owner, portfolio owner, and release/change owner accept the decision or backlog with clear acceptance criteria.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Registry population | Population, scope question, included/excluded records, environment/lifecycle boundary, steward, evidence owner, records location, cadence. |
| Canonical fields | Agent/workload, identity, tool/API/action, model, data source, telemetry, lifecycle, owner, exception, and closeout fields. |
| Source-of-record joins | Agent 365, Entra Agent ID/workload identity, Foundry, API Center, API Management, Azure Monitor/Application Insights, customer register, and change/lifecycle join keys. |
| Reconciliation finding | Missing owner, stale version, orphan identity, uncataloged API/tool, route mismatch, telemetry gap, lifecycle conflict, exception aging, unsupported coverage, owner, target date, validation reference, recurrence check, and route. |
| Lifecycle | Proposed, active_review, publish_ready, published, hold, suspended, deprecated, retired, or withdrawn state with transition owner, review reference, closure route, and reopen trigger. |
| Closeout | Close, close-with-owned-gaps, defer, reject, route, or block; every open gap gets owner, acceptance test, evidence reference, target date, recurrence check, and next review trigger. |

## Facilitation flow

1. Confirm the customer has a bounded population, scope question, steward, lifecycle owner, evidence owner, approved records location, and receiving owners. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Complete only safe references in this repository.
3. Build the registry population card and list canonical fields before discussing closeout.
4. Inspect the Microsoft control path: **Agent 365 where available, Microsoft Entra Agent ID, Azure API Center, API Management/gateway, Microsoft Foundry, federated registers, and Azure Monitor/Application Insights telemetry references**.
5. Ask: **Which field-level record is authoritative, which explicit join key proves it, what happens when records conflict, and who operates the record next?**
6. Classify reconciliation findings and lifecycle/material-change gaps.
7. Decide close, close with owned gaps, defer, reject, route, or block.
8. Create a control-plane backlog item for each missing catalog record, source-of-record rule, steward, join key, identity link, API/tool dependency, Foundry/API Center pointer, telemetry pointer, lifecycle state, material-change trigger, retirement evidence route, exception expiry, or review cadence.
9. Handoff the completed decision record and backlog references to receiving owners. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Close** when the population, canonical fields, source-of-record rules, explicit join keys, findings, lifecycle state, material-change triggers, closure route, evidence references, recurrence checks, and handoff are complete.
- **Close with owned gaps** when every remaining gap has named owner, target date, acceptance test, evidence reference, recurrence check, exception route if needed, and next review trigger.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped control-plane path cannot meet the required control-plane or stewardship expectation.
- **Route** when another control owner, portfolio owner, API/tool owner, identity owner, platform/Foundry owner, telemetry owner, lifecycle owner, release/change owner, or exception process must decide first.
- **Blocked** when scope, steward, evidence location, field-level source, explicit join key, conflict rule, lifecycle clarity, or approved record location prevents a decision.

## Session-specific considerations

When completing the shared decision record, capture the population card, canonical fields, source-of-record route, join keys, steward, reconciliation status, conflict rule, lifecycle state, material-change trigger, retirement evidence route, exception status, closeout decision, recurrence check, and receiving handoff.

## Handoff

Handoff to the control-plane steward, identity owner, API/tool owner, Foundry/platform owner, telemetry/operations owner, lifecycle/catalog owner, portfolio governance, and release/change owner. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, recurrence checks, and review triggers. Keep final records in the customer-approved system.
