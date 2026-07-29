# S9 Control Plane Work Package

This lab helps the customer make one bounded control-plane reconciliation decision and hand it to the right owner. It is not a catalog deployment, tenant change, runtime proof, enforcement exercise, or production approval. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, retirement artifacts, or production approval claims in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, decision owner, implementation owner, evidence owner, control-plane steward, approved customer records location, and receiving governance/operations owner. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the reconciliation decision, evidence references, acceptance test, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Control-plane route:** Agent 365 authoritative record where available, Entra Agent ID/workload identity, API Center dependency spine, Foundry record, federated register, or approved alternate catalog route.
- **Source of record:** the authoritative system or field-level authority for agent/workload, identity, API/tool dependency, telemetry pointer, owner, lifecycle state, exception status, and retirement route.
- **Stewardship:** named steward, record-quality owner, conflict resolver, review cadence, receiving process, and blocker path when no steward exists.
- **Reconciliation result:** matched, missing, duplicate, stale, conflicting, unsupported, no-steward, or blocked, with safe evidence references only.
- **Lifecycle controls:** proposed, pilot, active, exception, suspended, retiring, or retired state; material-change trigger; and retirement evidence route.
- **Blockers and backlog:** missing source of record, steward, owner, identity link, API/tool dependency, Foundry/API Center linkage, telemetry pointer, lifecycle state, conflict rule, retirement evidence, cadence, or evidence location captured with owner, acceptance test, target date, and review trigger.
- **Handoff:** control-plane steward, identity owner, API platform owner, Foundry/platform owner, portfolio governance, and operations governance accept the decision or backlog with clear acceptance criteria.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Registry fields | Agent/workload, identity, tool/API, model, data source, telemetry, lifecycle, owner, exception, and evidence-reference fields. |
| Source-of-record joins | Agent 365, Entra Agent ID/workload identity, Foundry, API Center, API Management, Azure Monitor/Application Insights, and customer register join keys. |
| Lifecycle | Proposed, active-review, publish-ready, published, hold, suspended, deprecated, retired, or withdrawn state with transition owner and review reference. |
| Drift finding | Missing owner, stale version, orphan identity, uncataloged API/tool, route mismatch, telemetry gap, lifecycle conflict, exception aging, owner, target date, and route. |

## Facilitation flow

1. Confirm the customer has a bounded scope, owners, steward, and approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Complete only safe references in this repository.
3. Inspect the Microsoft control path: **Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, Microsoft Foundry, federated registers, and platform telemetry references**.
4. Ask: **Which customer-owned Microsoft record is authoritative for this agent or workload, what happens when records conflict, and who operates the record next?**
5. Record one result in the customer system: approve, defer, reject, route, or blocked.
6. Create a control-plane backlog item for each missing catalog record, source-of-record rule, steward, identity link, API/tool dependency, Foundry/API Center pointer, telemetry pointer, lifecycle state, material-change trigger, retirement evidence route, or review cadence.
7. Handoff the completed decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the source of record, steward, identity link, dependency records, telemetry pointer, conflict rule, lifecycle state, material-change trigger, retirement evidence route, evidence reference, acceptance test, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped control-plane path cannot meet the required Microsoft control path or stewardship expectation.
- **Route** when another Microsoft control owner, portfolio owner, API owner, identity owner, Foundry/platform owner, or exception process must decide first.
- **Blocked** when access, evidence location, ownership, stewardship, catalog availability, conflict rule, lifecycle clarity, or scope clarity prevents a decision.

## Session-specific considerations

When completing the shared decision record, capture the source-of-record route, steward, reconciliation status, conflict rule, lifecycle state, material-change trigger, retirement evidence route, exception status, and receiving handoff.

## Handoff

Handoff to the control-plane steward, identity owner, API platform owner, Foundry/platform owner, portfolio governance, and operations governance. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.
