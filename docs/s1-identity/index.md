# S1 · Identity & Ownership Review

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Identity admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

For every agent in scope, the customer can answer: **who owns it, and can we
prove it?**

They leave with:

- A list of the agents in scope, taken from an admin source they trust, usually
  **Microsoft Entra Agent ID**, with a plain note of what the list
  covers and what it misses.
- A named human sponsor and a lifecycle decision (keep, review, retire) for each
  agent on the list.
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
gaps, assess Entra Agent ID coverage, route RBAC/OBO/Conditional Access work to
the identity-change process, or pause dependent sessions.

### What the list captures

For each agent, the review records: where the record came from, what the source
covers and excludes, the identity type, the agent it maps to, the human sponsor,
its lifecycle and purpose, how it gets access and how far that access reaches,
any related access or risk notes, and review details (who reviewed it, when, what
they found, the decision, and the next review date). Real IDs and personal data
stay in the customer's approved system, never in this repo.

## 2. Prerequisites

- A customer identity admin who can open the right admin source for the workload
  in scope (for example, Entra Agent ID).
- A place the customer already trusts to store the list, evidence, and decisions.
- A named governance lead who can accept gaps in coverage and sign off on ownership.

You do **not** need Conditional Access licensing, a break-glass design, Graph
PowerShell, or any particular Entra Agent ID setup to run this session.

## 3. Why this session matters

You cannot govern an agent you cannot name or tie to an owner. S1 produces a
trusted list, a human sponsor for each agent, and an honest coverage statement.
A directory search is not an agent inventory.

Read the [S1 Concepts](concepts.md) for how Entra Agent ID, ownership, OBO, and
the gateway boundary fit together.

## 4. Change boundary

This kit changes nothing in the tenant. The customer's identity-change process
owns any Conditional Access, break-glass, access remediation, rollback,
verification, and evidence retention.
