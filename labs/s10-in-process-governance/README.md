# S10 Conditional In-Process Governance Work Package

This optional lab helps the customer decide whether one bounded tool-call boundary should stay gateway-only, add an in-process decision, use both, or be marked not applicable. The facilitator guides the method; the customer inspects its own Microsoft records and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant policy, or customer evidence in this repository.

## Entry condition

Bring one bounded workload or portfolio slice, the decision owner, code or implementation owner, policy owner, evidence owner, audit-record route, and the approved customer records location. If there is no real pre-tool decision with delegated authority, use the skip path and record **not applicable** instead of opening an AGT or in-process-governance adoption task.

## Work package outcome

By the end of the lab, the customer has recorded one conditional decision: **gateway-only**, **in-process candidate**, **both**, or **not applicable**; then **approve**, **defer**, **reject**, or **route** the resulting record. Any in-process candidate remains a separate customer engineering assessment. AGT is only one possible implementation candidate and is subject to Public Preview status, limitations, customer code ownership, and support review.

## Required record

| Record | Use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | S10-specific customer-owned record for the applicability decision, exact pre-tool decision, delegated authority, owner, audit route, evidence reference, skip reason, acceptance test, caveat, backlog, target date, and handoff. |

## Facilitation flow

1. Confirm the candidate tool action and the exact decision needed immediately before the tool runs: allow, deny, approval, or route.
2. Confirm delegated authority, code or implementation owner, policy owner, evidence owner, and audit-record route. If any required owner or route is missing, **defer** or **route**; do not treat the lab as adoption approval.
3. Compare the existing gateway/platform control with the proposed local decision. If the gateway can make the meaningful decision, record **gateway-only** and hand off through the normal control path.
4. If both gateway and local context are needed, record **both** and name the correlation, conflict-review, and audit owners.
5. If only local pre-tool context can make the decision, record **in-process candidate** and create a customer-owned engineering assessment backlog item. Include AGT Public Preview caveat only if AGT is considered.
6. If there is no real in-process decision point or delegated authority, record **not applicable**, name the alternate S11/S13 or customer-backlog path, and stop S10.
7. Copy the decision record into the customer's approved records system and complete only safe references in this repository.

## Decision criteria

- **Approve** when the selected path is bounded, owned, evidenced by safe reference, and accepted by the receiving owner.
- **Defer** when the exact pre-tool decision, delegated authority, owner, audit route, evidence reference, acceptance test, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope or would imply unsupported customer-system change.
- **Route** when another Microsoft control owner, code owner, policy owner, audit owner, or exception owner must decide first.

## Session-specific considerations

Capture why the gateway path is sufficient, why a local pre-tool decision is needed, why both are needed, or why S10 is not applicable. Keep AGT conditional: note its Public Preview status and limitations only as inputs to a future assessment, not as a required adoption task.

## Handoff

Handoff to the named gateway/runtime owner, application engineering owner, policy owner, audit-record owner, and release or backlog owner as applicable. The receiving owner accepts only records or backlog items with clear acceptance tests, target dates, evidence locations, exception status, and safe customer-approved references.
