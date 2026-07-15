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

## Closeout accepts accountability, not absence of findings

Closeout can occur with owned gaps only when the decision owner records the
residual-risk disposition, accountable owner, due date, validation reference,
recurrence check, exception route, and next review. A blank template, a local
tool result, or a no-result is not proof that a control operates.
