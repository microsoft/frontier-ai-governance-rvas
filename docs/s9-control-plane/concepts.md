# S9 · Control Plane, Catalog & Lifecycle Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15

S9 establishes a customer-owned, evidence-first operating view of agents and
tools. It is a 90-minute read-only session: it reviews records and decisions;
it does not query live data or change a catalog, identity, access setting, or
lifecycle state.

## A catalog is an accountable operating record

An agent or tool catalog is useful only when each entry identifies its purpose,
accountable owner, technical steward, lifecycle state, and review references.
Names, dashboards, and exports are supporting evidence—not automatic truth.
Unknown fields remain unknown and become owned findings.

Agent and tool stewardship are related but distinct. An agent entry identifies
the accountable service; a tool entry identifies the callable capability, its
steward, its parent agent or approved shared-use relationship, and its own
lifecycle decision. This prevents an approved agent from silently extending
its authority through an unreviewed tool.

## Lifecycle is a decision trail, not a label

Proposed, active, exception, suspended, retired, and decommissioned states
make the intended operating posture visible. A transition needs an accountable
decision, a review reference, and a permitted destination. Material changes to
authority, tool use, data handling, model behavior, operating scope, or
ownership require a separately recorded review before they are treated as
accepted.

Suspension contains immediate use while review occurs. Retirement ends intended
use but preserves the record for accountability. Decommissioning additionally
requires evidence that the agreed closure actions were reviewed. S9 records
these distinctions; it never performs them.

## Reconciliation keeps gaps visible

S9 compares explicit identity identifiers in the catalog with the normalized
identity inventory. It does not infer matches from names, aliases, or adjacent
fields. Unmatched identities, catalog-only entries, missing owners, invalid
lifecycle states, unreviewed material changes, and incomplete closure records
are findings for accountable owners.

The authoritative record may come from multiple customer systems: an agent
registry or Agent 365 view, Entra Agent ID records, API Center or gateway
records for tools and APIs, platform telemetry, and approved lifecycle or
change-review records. S9 does not choose a system of record; it asks which
record is authoritative for the bounded population and preserves gaps where the
records disagree.

## Reconciliation becomes lifecycle backlog

The S9 recommendation should state whether the bounded population can close,
close with owned gaps, defer, or remain open. Typical backlog rows include
Agent 365/Entra Agent ID/API Center reconciliation, steward assignment,
parent-tool relationship, lifecycle-state fix, material-change review,
suspension, withdrawal, retirement, recurrence check, exception escalation,
S11 operating cadence, and S12 portfolio risk.

S9 does not execute catalog, identity, access, policy, or retirement changes.
It routes them to the customer-owned steward or change process.

## Closeout accepts accountability, not absence of findings

Closeout can occur with owned gaps only when the decision owner records the
residual-risk disposition, accountable owner, due date, validation reference,
recurrence check, exception route, and next review. A blank template, a local
tool result, or a no-result is not proof that a control operates.

## Related official references

## Fleet governance and workflow controls have different altitudes

A fleet control plane can make agents, ownership, lifecycle state, and
cross-system gaps visible. An in-process control can make a decision within an
agent workflow before a particular tool action. S9 reconciles the fleet-level
records and their dependencies; it does not infer that a workflow control is
installed, nor that a catalog entry proves runtime behavior.

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for Agent 365, Purview, identity, audit, and lifecycle sources that can inform
customer-owned control-plane stewardship.
