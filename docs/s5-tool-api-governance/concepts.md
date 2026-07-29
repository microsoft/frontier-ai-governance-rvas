# S5 · Tool/API Admission & Withdrawal Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Apply the customer's current policy, service
    support, region, licensing, and approval model to every candidate and
    material change.

This page explains the operating model behind S5. Use [S5 Prepare](index.md) for
the customer co-delivery method.

## A tool call is the governance unit

An API or tool is not governable in the abstract. Reviewers need to trace one
consumer calling one operation through a known identity and route. The useful
question is:

> Can this caller perform this operation, on this data, through this route, with
> this audit trail, and can the customer stop it?

That trace turns tool governance from vague approval into a practical admission
package.

## A catalog is a decision record, not safety proof

A catalog or API Center entry makes a candidate discoverable and reviewable. It
can record ownership, intended use, classification, caller identity, authority,
version, lifecycle, and consumer scope. It cannot prove the caller is
authorized, APIM policy is enforced, a connector permission is safe, an MCP tool
behaves correctly, or a live integration is operating as claimed.

S5 records evidence references and a decision. Implementation, runtime
verification, and production release remain separate customer processes.

## Operation authority is more important than product label

Product categories are not enough. A low-risk route can become unsafe when it
allows broad writes, admin actions, data export, cross-tenant calls, or external
side effects. A useful admission record classifies the operation:

| Operation class | Admission implication |
|---|---|
| Read-only lookup | Requires caller identity, data boundary, audit, rate/quota, consumer acceptance, and withdrawal. |
| Write or update | Requires explicit allowed fields/actions, approval or rollback owner, stronger audit, and over-scope handling. |
| Admin or destructive | Usually block, route to exception, or require a separate high-authority review. |
| External side effect | Requires recipient/target boundary, notification or compensation path, and incident route. |
| Bulk export or sensitive data | Requires data owner, minimization, DLP/privacy route, retention/export handling, and consumer acceptance. |
| Tool chaining or dynamic selection | Requires consumer review, in-process or runtime-control handoff, and stricter material-change triggers. |

If the operation authority is unknown, the route is not ready.

## Admission decisions become a technical work list

The S5 decision names the selected route and rejected or deferred alternatives.
Its backlog may cover API Center registration, APIM product/API/backend policy
route, Entra app or managed identity, delegated/OBO scope, connector approval,
MCP publication, allow-list, quota, audit, correlation, consumer review,
withdrawal, record reconciliation, and change ownership.

Publishing, permission grants, APIM configuration, connector consent, MCP server
publication, and runtime-safety proof stay in customer implementation and
assurance processes.

## Ownership must follow the route

Catalog ownership answers who keeps the record current. Technical ownership
answers who understands the candidate behavior and version. Platform ownership
answers who owns the gateway, product, backend, diagnostics, and quota. Identity
ownership answers who owns app registration, managed identity, scopes, consent,
credential rotation, and revocation. Consumer ownership answers who accepts the
operation boundary for the agent or application that will call the tool.

An entry with no accountable owner, no consumer owner, or no withdrawal owner is
not ready for admission.

## Identity and authority are different controls

Caller identity answers *who or what is expected to invoke the candidate* and
how that identity is established. Authority scope answers *what that caller is
allowed to cause*, under which conditions, and what is prohibited.

An Entra app, managed identity, OAuth/OBO flow, or JWT audience without bounded
scopes and operation authority is incomplete. A scope without a consumer and
revocation owner cannot be reviewed.

State authority as minimum needed: allowed operations, resource or data
boundary, constraints, prohibited actions, approval route, exception owner,
rollback behavior, and revocation path. S5 neither grants authority nor tests it.

## APIM, connector, MCP, and allow-list routes are different packages

The same tool-call decision may land on different control surfaces:

| Route | Package focus |
|---|---|
| API Center/APIM | Catalog/API Center metadata, product/API/backend route, JWT validation, backend auth, quotas, policy intent, diagnostics, correlation, and withdrawal. |
| Allow-list | Source, package/version, allowed operations, consumers, expiry, review cadence, revocation owner, and stop condition. |
| Connector governance | Connector owner, environment, permission model, admin consent, DLP/data boundary, publication/withdrawal path, and consumer review. |
| MCP publication | Server/tool schema, version, auth scopes, consumer scope, rate/quota, audit, publication state, and unpublish trigger. |
| Runtime-control referral | Operation needs a per-call allow/deny/approval decision, runtime evidence, or in-process policy before use. |

Do not reuse one generic checklist for every route.

## Gateway policy intent is not runtime proof

APIM or AI Gateway policy families can express the intended publication
boundary: caller authentication, backend authentication, quotas, token limits,
content safety, prompt shields, blocklists, semantic cache, token metrics,
diagnostics, backend resilience, fallback, circuit breaker, and retry.

Those are admission-planning fields until the customer proves the configured
route with its own runtime evidence. S5 records policy intent, policy owner,
expected evidence reference, and runtime handoff. It does not paste live policy,
configure APIM, or claim enforcement.

## Consumer acceptance is required

Tool risk depends on the consumer. The consuming agent or app owner must accept:

- allowed operations and blocked operations;
- over-scope request handling;
- input and output contract assumptions;
- failure, retry, fallback, and timeout behavior;
- audit/correlation fields;
- review cadence and material-change triggers.

Without consumer acceptance, the same API may be technically valid but unsafe for
the proposed use.

## Withdrawability is an admission criterion

Before a tool is admitted, the customer should know how to stop its use. A
withdrawal-ready route names how to disable or remove publication, revoke
permissions, remove allow-list entries, withdraw connector consent, unpublish
MCP tools, rotate credentials, notify consumers, preserve audit or investigation
references, and record closure.

If withdrawal is not executable, admission should be deferred, rejected, routed,
or blocked.

## Versioning and material changes reopen admission

A decision applies to a specific version and stated configuration boundary. A
material change in schema, operation, data class, caller identity, auth scopes,
gateway route, policy family, connector permission, MCP tool definition, rate or
quota, telemetry, owner, consumer, or lifecycle state requires review.

A version label alone is accepted only as an identifier. The owner records the
assessment and disposition.

## Evidence-first keeps uncertainty visible

Every material statement needs a customer-held reference, owner, or explicit
unknown. "Nothing found" is useful only with checked scope, time range,
workload support, permissions, expected signal, and reviewer. The right result
for a gap is not guessed safety; it is defer, route, reject, block, or backlog.

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for API Management AI Gateway, Azure Policy, Entra, and data-governance
references that can inform a customer-owned admission, publication, and
enforcement backlog.
