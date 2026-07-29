# S5 · API, Tool & MCP Governance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm the customer's applicable policies,
    technical constraints, and approval authorities before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Platform owner</span> <span class="rvas-badge rvas-persona">Security reviewer</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & what the customer keeps

For each in-scope tool, API, or MCP service, the customer can answer: **can we
publish it, hold it, suspend it, or withdraw it safely?**

They leave with:

- A catalog record with an accountable owner, workspace decision, naming
  decision, classification, caller identity, authority scope, and version.
- A publication decision with criteria, evidence references, remaining gaps, and
  a named approver.
- Lifecycle decisions for proposed, published, suspended, and withdrawn entries.

The customer keeps the completed record in its approved records system.
`labs/s5-tool-api-governance/` contains offline templates and a report-only
runbook. Customer evidence stays in the customer system and is referenced, not
copied into this repository.

### What happens next

**Next customer action:** give the publication or lifecycle decision to the
catalog, platform, identity, and release owners who can complete the required
work.

### Plain decision and default path

**Decision question:** *Approve, defer, reject, or route this bounded tool, API,
or MCP version for controlled publication?* Approve means the record may enter
the customer's separate change process; it is never a publication or production
approval.

The default is an Azure/Microsoft path: record the candidate in Azure API
Center (where available), expose an approved route through Azure API Management,
and use Microsoft Entra workload or delegated identity with least privilege.
Use an existing approved catalog, gateway, or identity pattern only when it
covers the same owner, version, authority, lifecycle, and evidence fields.
Document the exception owner, reason, compensating control, review date, and
route back to the default. Verify service availability, licensing, and feature
fit before relying on any named service.

S5 produces a publication backlog and records the approve, defer, reject, or
route result. A route result names the runtime-evidence owner and the
catalog/control-plane owner for lifecycle reconciliation.

It also names the execution path: API Center or catalog entry, [Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts)
or AI Gateway route, caller identity, MCP or connector path, version boundary,
lifecycle owner, and customer change or release process.

## 2. Prerequisites

- A bounded candidate list and a customer-owned source record for each candidate.
- An accountable catalog owner, technical owner, evidence owner, and decision owner.
- The classification method, workspace rules, naming rules, identity requirements,
  and publication authority that apply.
- An approved customer records location and a safe review scope.

## 3. Why this session matters

A tool or API is governable when a reviewer can name its owner, placement,
caller, authority, and version. A catalog helps find those facts; it does not
prove safety, configuration, authorization, or live behavior.

S5 creates the decision record before publication or lifecycle action. It does
not publish a service, grant permission, create a caller identity, configure an
integration, or test a live connection. Read [S5 Concepts](concepts.md) for the
reasoning behind the record and its boundaries.

## 4. Change boundary and handoff

S5 changes no catalog, workspace, service, identity, permission, integration, or
lifecycle state. Any publication, permission grant, suspension, or withdrawal is
customer-owned and follows the customer's approved change, rollback,
communication, and verification process. Runtime handoff includes the approved
route and authority boundary; catalog/control-plane handoff includes the
catalog identifier, owner, version, lifecycle state, and open exceptions.
