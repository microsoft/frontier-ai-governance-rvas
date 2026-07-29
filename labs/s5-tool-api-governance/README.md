# S5 Tool-Call Admission Work Package

This lab helps the customer select an admission route for one bounded tool/API
operation and one bounded consumer. It is not a deployment, enforcement,
runtime-proof, live-policy change, or production-approval exercise. The
facilitator guides the method; the customer inspects its own Microsoft records,
chooses the decision, and keeps completed evidence in its approved records
system.

> **Safety boundary:** Use safe references only. Do not place customer
> identifiers, secrets, prompt text, model outputs, telemetry exports, live
> configuration, tenant-change details, runtime proof, enforcement evidence, or
> production approval claims in this repository.

## Entry condition

Bring one bounded API, tool, connector, MCP publication, allow-list request, or
consuming-agent need; one consuming agent/app/workflow; the operation or
operation group under review; the decision owner, tool owner, API platform
owner, identity owner, consuming-agent owner, evidence owner, receiving owners,
and approved customer records location.

If any consumer, operation, owner, identity path, audit route, withdrawal owner,
or record location is missing, create a blocker backlog item instead of
completing the decision.

## Required records

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for tool-call trace, route comparison, operation-risk record, control-path package, consumer acceptance, withdrawal plan, evidence references, acceptance test, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that
summarizes:

- **Tool-call trace:** consumer, caller identity, route, operation, version,
  data class, side effect, owner, lifecycle state, and approved records location.
- **Admission route:** API Center/APIM, allow-list, connector, MCP publication,
  runtime-control referral, reject unsafe tool, withdraw, defer, or route.
- **Operation risk:** read, write, admin/destructive, external side effect,
  bulk/export, sensitive-data, dynamic tool-chaining, blocked operation, or hard
  stop.
- **Control-path package:** catalog/API Center metadata, APIM route or
  exception, identity/auth/scope/consent, connector/MCP/allow-list record,
  quota/cost/abuse controls, audit/correlation, and diagnostics.
- **Consumer acceptance:** accepted operations, over-scope handling,
  failure/retry/fallback, review cadence, and material-change triggers.
- **Withdrawal readiness:** disable path, permission removal, connector consent
  withdrawal, MCP unpublish, allow-list removal, credential rotation, consumer
  notification, verification, closure owner, and investigation references.
- **Blockers and backlog:** missing owner, version, auth scope, rate/quota,
  audit route, revocation owner, withdrawal path, consumer review, record
  location, unsafe authority, unsupported route, or scope clarity captured with
  owner, target date, evidence location, acceptance test, and review trigger.

## Technical capture fields

Capture these fields in the customer-owned decision record when they apply. Use
references and placeholders only; do not store prompts, outputs, endpoints,
telemetry exports, live policy, or live configuration in this repository.

| Area | Fields to capture |
|---|---|
| Tool-call trace | Consumer, identity path, route, operation, version, environment, lifecycle, data class, side effect, owner, records location. |
| Route comparison | API Center/APIM, allow-list, connector, MCP publication, runtime-control referral, reject/block, withdraw, rejected alternatives. |
| Operation risk | Read/write/admin/destructive, external side effect, bulk/export, sensitive data, dynamic tool chaining, approval need, blocked operations. |
| Control path | Catalog/API Center record, APIM product/API/backend/policy intent, connector approval, MCP publication, allow-list, auth, scopes, quota, audit. |
| Consumer acceptance | Accepted operations, over-scope handling, failure/retry/fallback, correlation fields, review cadence, material-change triggers. |
| Withdrawal | Disable, revoke, remove, unpublish, rotate, notify, verify, preserve investigation references, close or reconsider. |

## Facilitation flow

1. Confirm the customer has one bounded consumer, one operation, owners, and an
   approved records location. If not, stop the decision and create a blocker
   backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md)
   into the customer-owned records system.
3. Build the tool-call trace card before discussing product fit.
4. Classify operation risk and hard stops.
5. Compare **API Center/APIM, allow-list, connector, MCP publication,
   runtime-control referral, reject/block, and withdraw** routes.
6. Ask: **Which customer-owned Microsoft record proves this operation is
   bounded, callable, observable, consumer-accepted, and withdrawable?**
7. Record one result: approve, defer, reject, route, withdraw, or blocked.
8. Create a tool/API backlog item for each missing trace field, route rationale,
   owner, version, auth contract, APIM policy route, connector or MCP record,
   rate/quota, audit/correlation route, consumer acceptance, material-change
   trigger, revocation path, withdrawal path, runtime-control referral, or unsafe
   operation boundary.
9. Handoff the completed decision record and backlog references to receiving
   owners. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the trace, route, owner, version, operation boundary, auth
  scopes, rate/quotas, audit route, revocation path, withdrawal plan, consumer
  review, evidence reference, acceptance checks, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence
  location, and next review trigger.
- **Reject** when the tool/API has unsafe authority, unbounded scope,
  unsupported operation, no owner, no auditability, or no feasible withdrawal
  path.
- **Route** when API platform, identity, connector governance, M365,
  runtime/security, evaluation, data/privacy, catalog/control-plane, legal, or
  exception owners must decide first.
- **Withdraw** when an admitted tool no longer has an owner, version, approved
  consumer, acceptable scope, audit route, or revocation path.
- **Blocked** when access, ownership, record location, version, auth,
  rate/quota, audit, revocation, consumer review, or scope clarity prevents a
  decision.

## Handoff

Handoff to API platform owner, tool owner, identity owner, connector owner, MCP
publication owner, consuming-agent owner, security/compliance owner, runtime or
in-process governance owner, evaluation owner, data/privacy owner,
control-plane/catalog owner, release owner, and operations owner as applicable.
The receiving owner accepts only decisions or backlog items with clear
acceptance tests, target dates, evidence locations, and review triggers. Keep
final records in the customer-approved system.
