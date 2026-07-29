# S5 Tool & API Governance Work Package

This lab helps the customer make one bounded tool/API governance decision and hand it to the right owner. It is not a deployment, enforcement, runtime-proof, live-policy change, or production-approval exercise. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository.

## Entry condition

Bring a bounded API, tool, connector, MCP publication, allow-list request, or consuming-agent need; the decision owner, tool owner, API platform owner, identity owner, consuming-agent owner, evidence owner, receiving owners, and approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Required records

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for route decision, admission checks, withdrawal checks, evidence references, acceptance test, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Admission route:** API Center/APIM, allow-list, connector, MCP publication, S10 referral, reject unsafe tool, withdraw, defer, or route.
- **Tool/API profile:** owner, version, business purpose, environment, operation boundary, consuming agent/app, and approved records location.
- **Control checks:** auth audience/scopes, consent owner, rate/quotas, audit route, correlation field, revocation path, consumer review, and review cadence.
- **Withdrawal readiness:** disable path, permission removal, connector consent withdrawal, MCP unpublish, allow-list removal, credential rotation, consumer notification, rollback owner, and investigation references.
- **Downstream handoffs:** S3 platform route, S6/S10 runtime or enforcement referral, S7 evaluation evidence, S9 control-plane/catalog lifecycle, and blockers.
- **Blockers and backlog:** missing owner, version, auth scope, rate/quota, audit route, revocation owner, withdrawal path, consumer review, record location, unsafe authority, or scope clarity captured with owner, target date, evidence location, acceptance test, and review trigger.

## Facilitation flow

1. Confirm the customer has a bounded tool/API scenario, owners, and an approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system.
3. Classify the route across **API Center/APIM, allow-list, connector, MCP publication, S10 referral, and reject unsafe tool**.
4. Ask: **Which customer-owned Microsoft record proves this tool is admissible, bounded, reviewable, and withdrawable, and who accepts each consumer?**
5. Record one result: approve, defer, reject, route, withdraw, or blocked.
6. Create a tool/API backlog item for each missing catalog record, owner, version, auth contract, APIM policy route, rate/quota, audit route, connector approval, MCP publication guardrail, revocation path, withdrawal path, consumer review, S10 referral, or unsafe operation boundary.
7. Handoff the completed decision record and backlog references to receiving owners. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the route, owner, version, auth scopes, rate/quotas, audit route, revocation path, consumer review, evidence reference, acceptance checks, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the tool/API has unsafe authority, unbounded scope, unsupported operation, no owner, no auditability, or no feasible withdrawal path.
- **Route** when API platform, identity, connector governance, M365, runtime/security, evaluation, catalog/control-plane, legal/privacy, or exception owners must decide first.
- **Withdraw** when an admitted tool no longer has an owner, version, approved consumer, acceptable scope, audit route, or revocation path.
- **Blocked** when access, ownership, record location, version, auth, rate/quota, audit, revocation, consumer review, or scope clarity prevents a decision.

## Handoff

Handoff to API platform owner, tool owner, identity owner, connector owner, consuming-agent owner, security/compliance owner, runtime/S10 owner, evaluation owner, and control-plane/catalog owner as applicable. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.
