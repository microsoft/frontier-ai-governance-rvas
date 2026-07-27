# S1 · Identity & Ownership Review

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Identity admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

For every agent in scope, the customer can answer: **which identity is being
reviewed, who sponsors it, what authority it can use, where its boundary is, and
what lifecycle decision was made?**

They leave with:

- A list of the agents or agent-like workloads in scope, taken from an admin
  source they trust, such as **Microsoft Entra Agent ID** where it is available,
  with a plain note of what the list covers and what it misses.
- A governance record that separates the agent identity, workload credential,
  delegated/on-behalf-of authority, and runtime access boundary instead of
  treating them as one "owner" field.
- A named human sponsor, credential or federation owner, and lifecycle decision
  for each reviewed item.
- The list reference and each decision saved in the customer's own records system
  or the generated delivery workspace.

`labs/s1-identity/` holds the runbook and a blank review template. It does **not**
hold real identity data, exports, Conditional Access policies, break-glass
templates, or customer records: those stay in the customer's own systems.

### Plain decision

**Question:** **Do we approve, defer, reject, or route this identity,
sponsorship, and authority decision?** Default to Microsoft Entra and the
customer's existing sponsorship/access-review process. An exception requires a
documented coverage limit, owner, Entra record location, acceptance criterion, and
target date. This result does not grant access, change the tenant, or approve
production.

### What happens next

**Next customer action:** give the identity or lifecycle owner the named gap,
then start dependent work only when the required coverage is clear.

S1 produces an identity backlog: retain the current setup, close source or owner
gaps, assess Entra Agent ID or Agent 365 coverage where those capabilities apply,
route RBAC/OBO/Conditional Access work to the identity-change process, recertify
or rotate credentials, retire unused identities, block unclear authority paths, or
pause dependent sessions.

### What the list captures

For each agent or agent-like workload, the review records:

- **Evidence source:** where the record came from, which product or tenant scope
  it covers, and what it explicitly excludes.
- **Agent identity:** whether there is an Agent ID/Agent 365 record, another
  directory object, an app registration, a managed identity, or no governable
  identity yet.
- **Workload credential:** which credential, secret, certificate, managed
  identity, or workload-federation path is used, who owns it, and when it must be
  rotated or recertified.
- **Delegated authority:** whether the agent acts on behalf of a user, service,
  or workflow, and where OBO or consent telemetry should be reviewed.
- **Access boundary:** which gateway, API, environment, data zone, or RBAC scope
  limits the runtime action; gateway authentication evidence does not replace the
  identity record.
- **Lifecycle review:** the human sponsor, purpose, review trigger, decision
  path (keep, review, retire, or block), reviewer, review date, findings, and
  next review date.

Real IDs, customer identity payloads, tokens, and personal data stay in the
customer's approved system, never in this repo.

## 2. Prerequisites

- A customer identity admin who can open the right admin source for the workload
  in scope (for example, Entra Agent ID).
- A place the customer already trusts to store the list, evidence, and decisions.
- A named governance lead who can accept gaps in coverage and sign off on ownership.

You do **not** need Conditional Access licensing, a break-glass design, Graph
PowerShell, or any particular Entra Agent ID setup to run this session.

## 3. Why this session matters

You cannot govern an agent by finding a row and writing down an owner. A real
identity-governance review distinguishes:

- the **agent identity** that should be accountable in the tenant;
- the **workload credential** or federation path that lets code authenticate;
- the **delegated/OBO authority** that may let the agent act for a user or
  workflow;
- the **access boundary** that limits which APIs, data zones, or gateways it can
  reach; and
- the **lifecycle decision** that says whether the sponsor keeps, reviews,
  retires, or blocks the setup.

S1 produces a trusted list, named accountability, and an honest coverage
statement. A directory search is not an agent inventory, OBO telemetry is not an
ownership record, and gateway authentication is not production approval.

Read the [S1 Concepts](concepts.md) for how Entra Agent ID, ownership, OBO, and
the gateway boundary fit together.

## 4. Change boundary

This kit changes nothing in the tenant. The customer's identity-change process
owns any Conditional Access, break-glass, access remediation, rollback,
verification, and evidence retention.
