# S1 Identity & Access Work Package

This lab helps the customer make one bounded identity and access decision and hand it to the right owner. The facilitator guides the review; the customer inspects Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, or tenant changes in this repository.

## Entry condition

Start only when the session has:

- **Decision owner:** accountable customer role that can approve, defer, reject, route, or block the identity decision.
- **Identity administrator:** customer role that can inspect Entra, workload identity, Conditional Access, RBAC, Agent ID/Agent 365, or related records.
- **Evidence owner:** customer role that records references in the approved customer evidence system.
- **Approved records location:** customer system where the decision record, supporting references, and backlog handoff will live.

Also bring a bounded agent, workload, or portfolio slice. If any owner, scope, or records location is missing, use the [Blocker path](#blocker-path) instead of completing the decision.

## Work package outcome

By the end of the lab, the customer has:

- stated the identity decision question for the bounded scope;
- mapped the agent identity and host workload;
- reviewed sponsor, lifecycle, credential/federation posture, and least-privilege scope;
- reviewed OBO/delegated authority when applicable;
- recorded approve, defer, reject, route, or blocked with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff.

## Required record

| Record | Use |
|---|---|
| [`../templates/decision-record.template.md`](../templates/decision-record.template.md) | Shared required customer-owned record for the identity decision, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |
| [`templates/identity-review.addendum.md`](templates/identity-review.addendum.md) | S1 addendum for identity source coverage, lifecycle, credential/federation, access scope, OBO/delegated authority, and identity backlog details. |

## Facilitation flow

1. Set the decision question: **Can this agent or host workload operate under an owned, least-privilege, reviewable identity path for the bounded scope?**
2. Inspect the Microsoft control path: **Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available**.
3. Map the agent identity, host workload, deployment environment, workload identity pattern, owner metadata, and disable or rotation route using safe record references only.
4. Review sponsor and lifecycle: business sponsor, technical owner, identity owner, security reviewer, operations handoff owner, lifecycle state, review cadence, emergency disable path, credential/federation review trigger, and decommission condition.
5. Review credential/federation and access scope: credential type or federation pattern, token issuer or trust boundary, rotation or expiration expectation, Conditional Access dependency, RBAC/API/connector permission, and minimum required scope.
6. Review OBO/delegated authority when the agent acts on behalf of a user or invokes tools that inherit user context.
7. Copy the required decision record into the customer's approved records system and complete the identity path review, decision, exception, backlog, and handoff sections.

## Decision criteria

- **Approve:** identity path is present, owned, least-privilege for the bounded scope, lifecycle-reviewed, evidence-referenced, and accepted by the receiving owner.
- **Defer:** owner, evidence, acceptance test, review cadence, or target date is missing but the path may be made acceptable.
- **Reject:** proposed identity path cannot meet the bounded scope safely.
- **Route:** another Microsoft control owner must decide first.
- **Blocked:** entry condition or critical review dependency is absent.

## Backlog categories

Create customer-owned backlog items for missing sponsor, Agent ID coverage investigation, credential hygiene, least-privilege RBAC, Conditional Access scope, OBO audit route, or S9 reconciliation. Each backlog item must include dependency, owner, impact, acceptance test, target date, approved records location, and receiving process.

## Blocker path

Use this path whenever a required owner, scope, evidence location, permission, record, or review route is missing.

- Stop only the dependent decision step; do not infer readiness from facilitator notes, screenshots, empty dashboards, or mock data.
- Create a customer-owned blocker backlog item with dependency, owner, target date, impact, acceptance test, and approved records location.
- Classify the blocker: missing owner, missing evidence location, missing identity record, unknown credential/federation, excessive or unowned access, unresolved OBO/delegated authority, unsupported capability, licensing/role limitation, or route-to-control-owner.
- Read back what can continue, what must stop, who owns the unblock, and where the customer record will be updated.

## Handoff

Handoff to identity platform owner, application/workload owner, and security operations. The receiving owner accepts only backlog items with a clear Microsoft control path, owner, evidence location, acceptance test, exception state if any, target date, and customer handoff process. Keep final records in the customer-approved system.
