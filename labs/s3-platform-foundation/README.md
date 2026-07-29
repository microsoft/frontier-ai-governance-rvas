# S3 Platform-Route Readiness Work Package

This lab helps the customer trace one bounded platform route and hand the right
platform blockers to the right owner. The facilitator guides the method; the
customer inspects its own Microsoft records, chooses the decision, and keeps
completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, sensitive diagrams, deployment details, network test results, access grants, or tenant changes in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, platform question, decision owner, implementation owner, evidence owner, approved customer records location, and receiving platform owners. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Work package outcome

By the end of the lab, the customer has:

- set the platform question for a bounded workload or portfolio slice;
- built a platform-route trace card across caller, application/orchestrator,
  landing zone, Foundry or equivalent AI platform, gateway ingress, model/tool/API
  egress, private route, identity boundary, telemetry, correlation, retention,
  export, and registry/catalog record;
- mapped the trust boundaries between caller, application, gateway,
  model/platform route, tool/API egress, data plane, control plane, operations,
  and security monitoring;
- inspected the gateway route, network/private assumptions, identity boundary,
  telemetry coverage, correlation, retention/export, and catalog records using
  customer-owned records only;
- identified prerequisites for runtime proof, evaluation evidence, and
  catalog/control-plane handoff;
- recorded approve, defer, reject, or route with owner and target date;
- created blocker or implementation backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Required record

| Record | Use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the session decision, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |

## Facilitation flow

1. Set the platform question: **Can this pilot route be used as a named platform
   path for later runtime, evaluation, and control-plane work without pretending
   it is deployed, private, observable, or production-ready?**
2. Build the platform-route trace card for **Azure landing zones, Microsoft
   Foundry or equivalent AI platform record, Azure API Management AI Gateway or
   customer-approved gateway, model/tool/API egress, private networking, identity
   boundary, Azure Policy, Azure Monitor/Application Insights, correlation,
   retention/export, and API Center/catalog record**.
3. Map trust boundaries across caller, application/orchestrator, gateway,
   model/platform route, tool/API egress, data plane, control plane, operations,
   and security monitoring.
4. Inspect the gateway ingress and egress route without copying live
   configuration or running traffic.
5. Inspect network and private-route assumptions without deployments, network
   tests, access grants, or tenant changes.
6. Inspect identity boundaries without granting access or approving
   least-privilege state.
7. Inspect telemetry coverage, correlation, retention, and export without
   exporting telemetry or pasting event payloads.
8. Confirm runtime proof, evaluation prerequisite, and catalog/control-plane
   handoff are identified or assigned as blockers.
9. Copy the required decision record into the customer's approved records system
   and complete the route trace, readiness fields, owner, evidence location,
   acceptance, exception, target date, backlog, and handoff fields.
10. Record one result: proceed with assumptions, defer, reject, route, or
   blocked.
11. Create a platform-route backlog item for each missing platform owner,
   trust-boundary record, gateway ingress/egress route, network/private route,
   identity boundary, policy assignment, telemetry coverage, correlation
   approach, retention/export record, registry/catalog entry, runtime-proof
   prerequisite, evaluation prerequisite, catalog handoff, unsupported support
   condition, bypass, or exception approval.

## Decision criteria

- **Approve** when the platform-route trace, trust boundary, gateway ingress and
  egress route, network/private route, identity boundary, telemetry coverage,
  correlation, retention/export, registry/catalog handoff, runtime prerequisite,
  evaluation prerequisite, and catalog handoff are present, owned, referenced,
  and accepted by the receiving owner.
- **Defer** when a record, owner, acceptance test, evidence reference, prerequisite, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope.
- **Route** when another Microsoft control owner must decide first.

## Session-specific considerations

When completing the shared decision record, capture the platform boundary review, platform control profile, and runtime-assurance handoff references.

## Handoff

Handoff to cloud platform team, network/security team, identity owner,
observability owner, API Center/catalog steward, security runtime owner,
evaluation owner, control-plane owner, and application delivery owner as
applicable. The receiving owner accepts only backlog items with clear acceptance
tests, target dates, evidence locations, and release impact. Keep final records
in the customer-approved system.
