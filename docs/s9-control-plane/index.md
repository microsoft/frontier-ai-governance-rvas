# S9 · Control Plane, Catalog & Lifecycle

!!! info "Freshness"
    Last reviewed: 2026-07-15

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Catalog steward</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer can see whether agent, identity, tool, and lifecycle records agree for one bounded population.

They leave with:

- A read-only reconciliation of catalog identity identifiers against the normalized identity inventory.
- A stewardship view of agents and tools, including ownership, lifecycle state, material-change review, and closure owner.
- A residual-gap backlog with owners, dates, validation references, recurrence checks, exceptions, and next-review decisions.

`labs/s9-control-plane/` provides blank stewardship and closeout templates, sample-only schemas, and read-only reconciliation tooling. Customer evidence stays in approved records and is referenced, not copied into this repository.

### What happens next

**Next customer action:** assign every open catalog, ownership, lifecycle, or
reconciliation gap to its steward and set the next review before closing it.

### Plain decision and default path

**Decision question:** *Approve, defer, reject, or route closure for this
bounded catalog and lifecycle population?* Approval accepts the stewardship
record and its owned gaps; it does not approve a lifecycle or production change.

The default is an authoritative Azure/Microsoft-backed catalog view: Azure API
Center for eligible APIs and tools, Microsoft Foundry records for supported
agents, and Microsoft Entra identity references, reconciled in a
customer-controlled register. Use an existing system or federated record only
when field ownership, coverage, identifiers, lifecycle rules, and reconciliation
cadence are explicit. Record the exception owner, reason, compensating
reconciliation, target date, and review trigger. Verify current product
availability and feature scope first.

S9 produces a catalog and lifecycle backlog for customer-owned work. The recommendation says whether to close, close with owned gaps, defer, or keep open. It also names the next owner for Agent 365, Entra Agent ID, API Center, catalog stewardship, lifecycle, material-change review, reconciliation, retirement, recurrence, S11, or S13.

## 2. Prerequisites

- A baseline scorecard and a normalized identity inventory with explicit object identifiers.
- A customer-normalized agent and tool catalog using `rvas.s9.control-plane-registry.v1`.
- A governance lead who can assign owners, residual-risk decisions, and review dates.
- An approved records location for evidence references and decisions.

## 3. Why this session matters

Agent governance breaks when Entra, the tool catalog, and lifecycle records disagree. S9 makes those gaps visible.

The session does not guess, match by name, or fix records during the workshop. It reconciles the records the customer provides and turns gaps into owned backlog.

Read the [S9 Concepts](concepts.md) before delivery.

## 4. Change boundary

S9 makes no live-data query and no catalog, lifecycle, identity, policy, access, or production change. Any change follows the customer's separate approved implementation, rollback, and verification process.
Handoff to S11 includes reconciliation findings, evidence references, owners,
exceptions, and cadence; handoff to S13 includes the approved closeout decision,
residual risk, lifecycle status, and target dates.
