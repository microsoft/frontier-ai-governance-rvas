# Practical workshop: scenario-driven tool and API admission path

**Microsoft default:** Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, allow-lists, and MCP publication controls.

**Customer decision:** Approve, defer, reject, route, withdraw, or block the scoped tool/API admission decision. This is an admission and handoff decision only; it is not deployment, enforcement proof, live-policy change, or production approval.

## Work the decision

1. **Choose the tool/API scenario.** Select one bounded API, tool, connector, MCP server/tool, action group, allow-list request, or consuming-agent need. Name the tool owner, API platform owner, identity owner, consuming-agent owner, evidence owner, and customer-approved records location.
2. **Classify the admission route.** Use the route table below before drafting controls.

| Scenario | Route | Practical decision cue |
|---|---|---|
| Existing or new API needs catalog, lifecycle, and consumer visibility | API Center/APIM | Approve admission only when API Center metadata, APIM route or exception, owner, version, auth, rate/quotas, audit route, and consumer review are recorded. |
| Narrow tool use in a bounded pilot | Allow-list | Defer or approve only with owner, allowed operations, consumers, expiry/review date, revocation owner, and evidence reference. No open-ended write access. |
| Platform or SaaS connector provides the action | Connector | Route through connector governance when permission model, admin consent, DLP/data boundary, environment, owner, and withdrawal path are recorded. |
| MCP server/tool is shared with agents or developers | MCP publication | Approve publication only when tool schema, auth scopes, version, owner, audit, rate/quotas, revocation, consumer review, and catalog state are complete. |
| Tool implies runtime guardrail, enforcement, monitoring, or gateway proof | S10 referral | Route to S10 or runtime/security owner; S5 may record admission criteria but must not claim enforcement or production runtime proof. |
| Tool has unsafe authority, missing owner, unbounded data/action scope, or no revocation path | Reject unsafe tool | Reject or block until bounded scope, owner, auth, audit, rate/quotas, revocation, and consumer review are feasible. |

3. **Inspect required records.** Record safe references for API Center entry, APIM product/API policy route or exception, Entra app/JWT contract, connector approval, MCP publication criteria, allow-list, and consumer review.
   - Evidence-reference example: customer records name owner, version, environment, allowed operations, auth audience/scopes, rate/quotas, audit route, revocation owner, and consumer review.
   - Defer blocker example: the tool can invoke write actions without a contract, least-privilege scopes, rate limit, audit route, version owner, or withdrawal path.
4. **Complete tool admission checks.** For each operation, record owner, version, auth scopes, data/action boundary, rate/quotas, audit route, revocation path, consumer review, expiry/review date, and receiving owner.
5. **Run withdrawal checks.** Record how the customer would disable, remove, deprecate, rotate credential, withdraw connector consent, unpublish MCP entry, remove allow-list entry, notify consumers, and preserve audit/investigation references. Defer if the withdrawal owner or consumer impact is unknown.
6. **Set downstream handoffs.** Route identity gaps to identity owner, platform route gaps to S3, runtime/enforcement proof to S6/S10, evaluation or tool behavior evidence to S7, and catalog/control-plane lifecycle to S9.
7. **Record the outcome.** Approve only when admission and withdrawal checks are complete with owner, target date, evidence reference, accepted-when checks, and consumer handoff. Otherwise defer, reject, route, withdraw, or block.

## Decision record

Fill this record in the customer-approved records system. Store only safe references here; completed evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Pilot tool/API admission decision |
| Route decision | API Center/APIM, allow-list, connector, MCP publication, S10 referral, reject unsafe tool, withdraw, defer, or route |
| Tool/API identity | Name/reference, owner, business purpose, environment, consuming agent/app, and approved records location |
| Version and lifecycle | Version, state, change owner, review cadence, expiry date, deprecation/withdrawal trigger |
| Operation boundary | Read/write/admin operations, data classes, side effects, human approval need, and blocked operations |
| Auth and scopes | Entra app/JWT audience, scopes/roles, consent owner, credential/secret owner, and least-privilege gap |
| Rate/quotas | Rate limit, quota, throttling behavior, abuse owner, and exception path |
| Audit and investigation | Audit route, correlation field, log/evidence owner, investigation path, and retention/export expectation |
| Revocation and withdrawal | Disable path, permission removal, connector consent withdrawal, MCP unpublish, allow-list removal, consumer notification, and rollback owner |
| Consumer review | Consuming agent/app owner, review result, accepted operations, over-scope handling, and next review trigger |
| S10/S6/S7/S9 handoff | Runtime/enforcement referral, runtime-assurance prerequisite, evaluation evidence need, and catalog/control-plane owner |
| Defer criteria | Missing owner, version, auth scope, rate/quota, audit route, revocation path, consumer review, or unsafe operation boundary |
| Acceptance checks | Admission route, owners, version, auth, rate/quotas, audit, revocation, consumer review, exception status, target date, and handoff are complete |

## Decision tree

- **Approve admission** when the route fits, owner and version are clear, auth scopes are least-privilege, rate/quotas and audit are named, revocation is actionable, and consumers have reviewed the tool.
- **Defer** when a record, owner, scope, quota, audit route, revocation owner, consumer review, evidence reference, target date, or downstream prerequisite is missing.
- **Reject** when the tool has unsafe authority, unbounded scope, unsupported operation, no owner, no auditability, or no feasible withdrawal path.
- **Route** when API platform, identity, connector governance, M365, runtime/security, evaluation, catalog/control-plane, legal/privacy, or exception owners must decide first.
- **Withdraw** when an admitted tool no longer has an owner, version, approved consumer, acceptable scope, audit route, or revocation path.

For an exception, record: reason, affected operation, unsupported or unverified control, equivalent customer-owned control if one exists, owner, evidence location, acceptance test, target date, consumer impact, and review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Route | API Center/APIM, allow-list, connector, MCP publication, S10 referral, or rejection route is justified for the bounded scenario | API governance owner |
| Owner and version | tool/API owner, platform owner, identity owner, consumer owner, version, lifecycle state, and review cadence are named | Tool owner |
| Auth scopes | audience, scopes/roles, consent owner, credential owner, and least-privilege gaps are recorded | Identity owner |
| Rate/quotas | rate limit, quota, throttling behavior, abuse owner, and exception path are explicit | API platform owner |
| Audit | audit route, correlation field, evidence owner, investigation path, and retention/export expectation are named | Security/compliance owner |
| Revocation | disable, permission removal, allow-list removal, connector withdrawal, MCP unpublish, credential rotation, consumer notification, and rollback owner are recorded | Tool/API owner |
| Consumer review | consuming agent/app owner accepts allowed operations, over-scope handling, and next review trigger | Consuming-agent owner |
| Withdrawal | withdrawal can be executed without tenant/live-policy changes during the workshop and has consumer impact and evidence references recorded | Release/control owner |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, changes no tenant policy, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Workshop facilitator |

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. This workshop changes no tenant policy, proves no runtime enforcement, and does not approve production.
