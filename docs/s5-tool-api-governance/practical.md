# Practical workshop: trace one tool call

**Microsoft default:** Azure API Center, Azure API Management, Entra/JWT,
managed identity or delegated OAuth, access contracts, connector governance,
allow-lists, and MCP publication controls.

**Customer decision:** Approve, defer, reject, route, withdraw, or block this
bounded tool/API operation for this bounded consumer. This is an admission and
handoff decision only; it is not deployment, enforcement proof, live-policy
change, or production approval.

## Facilitation flow

1. **Choose one consumer and one operation.** Select a bounded API, tool,
   connector, MCP server/tool, action group, allow-list request, or consuming
   agent need. Name the consumer, operation, tool owner, API platform owner,
   identity owner, consuming-agent owner, evidence owner, and customer-approved
   records location.
2. **Classify operation risk.** Mark read-only, write/update, approval-gated,
   admin/destructive, external side effect, bulk/export, sensitive-data, or
   dynamic tool-chaining. Record blocked operations and hard stops.
3. **Compare admission routes.** Use the route table before drafting controls.
   Record why the selected route fits and why alternatives are rejected,
   deferred, or routed.
4. **Build the control-path package.** Record safe references for API Center or
   catalog entry, APIM product/API/backend/policy route or exception, Entra
   app/JWT/managed identity/OBO contract, connector approval, MCP publication,
   allow-list, audit route, and consumer review.
5. **Check identity, scope, quota, and audit.** For each operation, record
   audience, scopes/roles, consent owner, credential owner, data/action boundary,
   rate/quota, abuse owner, audit route, correlation field, retention/export
   expectation, and receiving owner.
6. **Collect consumer acceptance.** The consuming owner accepts allowed
   operations, blocked operations, over-scope handling, failure/retry/fallback,
   response contract, correlation fields, review cadence, and material-change
   triggers.
7. **Design withdrawal first.** Record how the customer would disable, remove,
   revoke, deprecate, rotate credential, withdraw connector consent, unpublish
   MCP entry, remove allow-list entry, notify consumers, preserve investigation
   references, verify withdrawal, and close or reconsider.
8. **Route downstream handoffs.** Route identity gaps to identity owners,
   platform route gaps to platform owners, runtime/enforcement proof to runtime
   or in-process governance owners, tool behavior evidence to evaluation owners,
   data/privacy gaps to data owners, and lifecycle reconciliation to catalog
   owners.
9. **Record the outcome.** Approve only when admission and withdrawal checks are
   complete with owner, target date, evidence reference, accepted-when checks,
   and consumer handoff. Otherwise defer, reject, route, withdraw, or block.

## Admission route scenarios

| Scenario | Route | Practical decision cue |
|---|---|---|
| Existing or new API needs catalog, lifecycle, and consumer visibility | API Center/APIM | Approve admission only when API Center metadata, APIM route or exception, owner, version, auth, rate/quotas, audit route, consumer review, and withdrawal path are recorded. |
| Narrow tool use in a bounded pilot | Allow-list | Defer or approve only with owner, allowed operations, consumers, expiry/review date, revocation owner, and evidence reference. No open-ended write access. |
| Platform or SaaS connector provides the action | Connector | Route through connector governance when permission model, admin consent, DLP/data boundary, environment, owner, consumer, and withdrawal path are recorded. |
| MCP server/tool is shared with agents or developers | MCP publication | Approve publication only when tool schema, auth scopes, version, owner, audit, rate/quotas, revocation, consumer review, catalog state, and unpublish trigger are complete. |
| Tool implies per-call guardrail, enforcement, monitoring, or gateway proof | Runtime-control referral | Route to runtime or in-process governance owner; S5 records admission criteria but must not claim enforcement or production runtime proof. |
| Tool has unsafe authority, missing owner, unbounded data/action scope, or no revocation path | Reject unsafe tool | Reject or block until bounded scope, owner, auth, audit, rate/quotas, revocation, and consumer review are feasible. |
| Admitted route no longer has owner, consumer, audit, or revocation | Withdraw | Trigger withdrawal backlog with disable, revoke, notify, preserve evidence, verify, and closure owner. |

## Tool-call artifact

| Field | Record |
|---|---|
| Tool-call trace | Consumer, caller identity, route, operation, version, environment, lifecycle state, owner, data class, side effect, and approved records location. |
| Operation risk | Read, write, admin/destructive, external side effect, bulk/export, sensitive data, dynamic tool selection, blocked operations, and hard stop. |
| Route decision | API Center/APIM, allow-list, connector, MCP publication, runtime-control referral, reject unsafe tool, withdraw, defer, or route. |
| Control-path package | Catalog/API Center entry, APIM route, identity contract, connector/MCP/allow-list record, quota, audit, correlation, and withdrawal path. |
| Consumer acceptance | Accepted operations, over-scope handling, failure/retry/fallback, review cadence, and material-change triggers. |
| Downstream handoff | Platform, identity, connector/MCP, runtime, evaluation, data/privacy, catalog/control-plane, release, and operations owners. |

## Decision record

Fill this record in the customer-approved records system. Store only safe
references here; completed evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Pilot tool/API admission decision |
| Route decision | API Center/APIM, allow-list, connector, MCP publication, runtime-control referral, reject unsafe tool, withdraw, defer, or route |
| Tool-call trace | Consumer, caller identity, route, operation, version, environment, lifecycle state, owner, data class, side effect, and approved records location |
| Operation boundary | Read/write/admin operations, data classes, side effects, human approval need, blocked operations, and over-scope handling |
| Auth and scopes | Entra app/JWT audience, managed identity or OBO path, scopes/roles, consent owner, credential owner, and least-privilege gap |
| Gateway/connector/MCP route | API Center record, APIM product/API/backend/policy intent, connector approval, MCP publication state, allow-list scope, or exception |
| Rate/quotas/cost | Rate limit, token quota, throttling behavior, abuse owner, cost owner, and exception path |
| Audit and investigation | Audit route, correlation field, diagnostic owner, investigation path, retention/export expectation, and blind spots |
| Consumer review | Consuming agent/app owner, accepted operations, failure behavior, over-scope handling, and next review trigger |
| Withdrawal | Disable path, permission removal, connector consent withdrawal, MCP unpublish, allow-list removal, credential rotation, consumer notification, verification, and closure owner |
| Defer criteria | Missing owner, version, auth scope, rate/quota, audit route, revocation path, consumer review, unsafe operation boundary, or unsupported route |
| Acceptance checks | Admission route, owners, version, operation boundary, auth, rate/quotas, audit, revocation, consumer review, exception status, target date, and handoff are complete |

## Decision tree

- **Approve admission** when the route fits, owner and version are clear, auth
  scopes are least-privilege, rate/quotas and audit are named, revocation is
  actionable, and consumers have accepted the operation boundary.
- **Defer** when a record, owner, scope, quota, audit route, revocation owner,
  consumer review, evidence reference, target date, or downstream prerequisite
  is missing.
- **Reject** when the tool has unsafe authority, unbounded scope, unsupported
  operation, no owner, no auditability, or no feasible withdrawal path.
- **Route** when API platform, identity, connector governance, M365,
  runtime/security, evaluation, data/privacy, catalog/control-plane, legal, or
  exception owners must decide first.
- **Withdraw** when an admitted tool no longer has an owner, version, approved
  consumer, acceptable scope, audit route, or revocation path.
- **Block** when access, ownership, record location, version, auth, rate/quota,
  audit, revocation, consumer review, or scope clarity prevents a safe decision.

For an exception, record: reason, affected operation, unsupported or unverified
control, equivalent customer-owned control if one exists, owner, evidence
location, acceptance test, target date, consumer impact, and review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Tool-call trace | consumer, caller identity, route, operation, data class, side effect, owner, version, and lifecycle state are recorded | API governance owner |
| Route | API Center/APIM, allow-list, connector, MCP publication, runtime-control referral, rejection, or withdrawal route is justified | API platform owner |
| Operation risk | allowed and blocked operations, data classes, side effects, approval need, and hard stops are explicit | Tool owner |
| Auth scopes | audience, scopes/roles, consent owner, credential owner, and least-privilege gaps are recorded | Identity owner |
| Rate/quotas | rate limit, token quota, throttling behavior, abuse owner, cost owner, and exception path are explicit | API platform owner |
| Audit/correlation | audit route, correlation field, evidence owner, investigation path, and retention/export expectation are named | Security/compliance owner |
| Consumer acceptance | consuming agent/app owner accepts allowed operations, over-scope handling, failure behavior, and next review trigger | Consuming-agent owner |
| Withdrawal | disable, permission removal, allow-list removal, connector withdrawal, MCP unpublish, credential rotation, consumer notification, verification, and closure owner are recorded | Release/control owner |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, changes no tenant policy, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Workshop facilitator |

**Boundary:** Keep customer data and evidence in customer-approved systems; store
references only. This workshop changes no tenant policy, proves no runtime
enforcement, and does not approve production.
