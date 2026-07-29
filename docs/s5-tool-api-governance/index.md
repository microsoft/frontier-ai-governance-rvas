# S5 · Tool/API Admission & Withdrawal

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm the customer's applicable policies,
    technical constraints, service availability, and approval authorities before
    each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Platform owner</span> <span class="rvas-badge rvas-persona">Security reviewer</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & what the customer keeps

For one bounded tool, API, connector, or MCP route, the customer can answer:
**can this consumer call this operation through an approved Microsoft control
path, and can we revoke or withdraw it safely?**

They leave with a customer-owned **tool/API admission package**:

- A tool-call trace card naming the consumer, caller identity, route, operation,
  data classes, side effects, version, owner, and lifecycle state.
- An admission route comparison across API Center/APIM, allow-list, connector
  governance, MCP publication, runtime-control referral, reject/block, and
  withdrawal.
- A control-path package with catalog/API Center fields, APIM or equivalent
  route, identity contract, operation boundary, rate/quota, audit/correlation,
  consumer acceptance, and material-change triggers.
- A withdrawal-first plan covering disable, permission removal, connector
  consent withdrawal, MCP unpublish, allow-list removal, credential rotation,
  consumer notification, rollback/closure owner, and preserved investigation
  references.

The customer keeps the completed record in its approved records system.
`labs/s5-tool-api-governance/` contains offline templates and a report-only
runbook. Customer evidence stays in the customer system and is referenced, not
copied into this repository.

### What happens next

**Next customer action:** hand the admission package or blocker backlog to the
API platform, tool/API, identity, connector/MCP, consuming-agent, runtime,
evaluation, catalog/control-plane, release, and operations owners who can
complete the required work.

### Plain decision and default path

**Decision question:** *Approve, defer, reject, route, withdraw, or block this
bounded tool/API operation for this bounded consumer?* Approve means the package
may enter the customer's separate change or release process; it is never a
publication, enforcement, runtime-proof, or production approval.

The default Microsoft path is:

1. record the candidate in Azure API Center or the approved catalog;
2. expose the approved route through Azure API Management or an accepted
   equivalent gateway where possible;
3. use Microsoft Entra workload identity, managed identity, delegated OAuth/OBO,
   or another approved identity path with least privilege;
4. record connector governance, MCP publication, or allow-list boundaries where
   those routes are selected;
5. capture rate/quota, audit/correlation, consumer acceptance, and withdrawal
   actions before admission.

Use an existing approved catalog, gateway, connector, allow-list, MCP, or
identity pattern only when it covers the same consumer, owner, operation,
version, authority, lifecycle, audit, revocation, and evidence fields. Document
the exception owner, reason, equivalent control, review date, and route back to
the default. Verify service availability, licensing, region, and feature fit
before relying on any named service.

## 2. Prerequisites

- One bounded tool/API/MCP/connector candidate and one bounded consumer.
- A known operation or operation group, not a broad "API access" request.
- Accountable decision, tool/API, platform, identity, consuming-agent, evidence,
  and release or backlog owners.
- Known data classes, side effects, operation authority, and prohibited actions.
- The customer's approved records location and safe review scope.

If the customer cannot name the consumer, operation, owner, identity path, audit
route, or withdrawal owner, the right result is defer, route, reject, or block.

## 3. Why this session matters

A tool call is a control boundary. The risk is not only that an API exists; it is
who can call it, through which identity, which route, with which scopes, against
which data, causing which side effects, producing which audit trail, and how fast
the customer can revoke or withdraw it.

A catalog helps reviewers find and classify the candidate. It does not prove the
route is safe, the caller is authorized, APIM policies are running, the consumer
is within scope, or withdrawal will work. S5 creates the admission package before
publication or lifecycle action. It does not publish a service, grant
permissions, create identities, configure APIM, approve connectors, register MCP
servers, test live calls, prove runtime enforcement, or approve production.

## 4. Change boundary and handoff

S5 changes no catalog, gateway, workspace, service, identity, permission,
connector, MCP server, allow-list, lifecycle state, live policy, or tenant
configuration. Any publication, permission grant, connector consent, gateway
policy, suspension, withdrawal, or production release is customer-owned and
follows the customer's approved change, rollback, communication, verification,
and evidence process.

Runtime handoff includes the intended route, operation boundary, policy-intent
fields, telemetry/correlation expectation, and unresolved runtime-proof needs.
Catalog/control-plane handoff includes the catalog identifier, owner, version,
lifecycle state, consumer scope, exceptions, and material-change triggers.
