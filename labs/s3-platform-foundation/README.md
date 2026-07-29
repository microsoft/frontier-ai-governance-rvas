# S3 Platform Boundary Readiness Work Package

This lab helps the customer make one bounded platform-boundary readiness decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, sensitive diagrams, deployment details, network test results, access grants, or tenant changes in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, platform question, decision owner, implementation owner, evidence owner, approved customer records location, and receiving platform owners. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Work package outcome

By the end of the lab, the customer has:

- set the platform question for a bounded workload or portfolio slice;
- built a platform profile across landing zone, Foundry or equivalent AI platform, gateway, private route, identity boundary, policy guardrail, telemetry, correlation, and retention;
- mapped the trust boundaries between application, gateway, model/platform route, data plane, control plane, operations, and security monitoring;
- inspected the gateway route, network/private assumptions, telemetry coverage, correlation, and retention using customer-owned records only;
- identified prerequisites for S6 runtime proof, S7 evaluation evidence, and S9 catalog handoff;
- recorded approve, defer, reject, or route with owner and target date;
- created blocker or implementation backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Required record

| Record | Use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the session decision, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |

## Facilitation flow

1. Set the platform question: **Is this workload ready to cross the platform boundary into the target Microsoft platform path, and which owner accepts the next action?**
2. Build the platform profile for **Azure landing zones, Microsoft Foundry or equivalent AI platform record, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, identity boundary, Azure Policy, Azure Monitor, correlation, and retention**.
3. Map trust boundaries across application, gateway, model/platform route, data plane, control plane, operations, and security monitoring.
4. Inspect the gateway route without copying live configuration or running traffic.
5. Inspect network and private-route assumptions without deployments, network tests, access grants, or tenant changes.
6. Inspect telemetry coverage, correlation, and retention without exporting telemetry or pasting event payloads.
7. Confirm S6 runtime proof, S7 evaluation prerequisite, and S9 catalog handoff are identified or assigned as blockers.
8. Copy the required decision record into the customer's approved records system and complete the platform profile, readiness fields, owner, evidence location, acceptance, exception, target date, backlog, and handoff fields.
9. Record one result: approve, defer, reject, or route.
10. Create a platform-boundary backlog item for each missing platform owner, trust-boundary record, gateway route, network/private route, identity boundary, policy assignment, telemetry coverage, correlation approach, retention record, S6 runtime proof prerequisite, S7 evaluation prerequisite, S9 catalog handoff, or exception approval.

## Decision criteria

- **Approve** when the platform profile, trust boundary, gateway route, network/private route, identity boundary, telemetry coverage, correlation, retention, S6 prerequisite, S7 prerequisite, and S9 handoff are present, owned, evidenced, and accepted by the receiving owner.
- **Defer** when a record, owner, acceptance test, evidence reference, prerequisite, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope.
- **Route** when another Microsoft control owner must decide first.

## Session-specific considerations

When completing the shared decision record, capture the platform boundary review, platform control profile, and runtime-assurance handoff references.

## Handoff

Handoff to cloud platform team, network/security team, identity owner, observability owner, security runtime owner, evaluation owner, control-plane/catalog steward, and application delivery owner as applicable. The receiving owner accepts only backlog items with clear acceptance tests, target dates, and evidence locations. Keep final records in the customer-approved system.
