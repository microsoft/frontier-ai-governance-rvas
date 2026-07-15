# S6 · Control Plane & Operationalization Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Confirm current control-plane capabilities in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the operating model behind S6. Use [S6 Prepare](index.md) to
begin the customer-operated reconciliation and closeout.

## A control plane is an operating view, not an automatic source of truth

An enterprise control plane can provide a view of agents across their lifecycle.
It becomes a trustworthy operating record only after the customer reconciles it
with the identity inventory, maker knowledge, and platform evidence.

S6 therefore does not treat a vendor export, dashboard, or display name as
truth. The customer normalizes a registry into an explicit schema before it is
compared with S1.

## Explicit reconciliation keeps uncertainty visible

S1 supplies `objectId` values for Entra agent identities. The S6 registry
explicitly supplies `entraObjectId`. Reconciliation matches only those fields;
it does not infer equivalence from names or alternate field names.

An unmatched S1 identity is a shadow-agent finding. An unmatched registry
record, a missing Entra object ID, or contradictory control metadata remains a
finding for the governance owner to resolve.

## Ownership and lifecycle state make evidence actionable

An agent without an accountable sponsor cannot be accepted as operational.
Lifecycle states such as proposed, active, exception, suspended, retired, and
decommissioned provide a consistent way to decide what may run and what needs
attention.

S6 is read-only because changing ownership, lifecycle, or access data changes
the operational record. Those customer changes require their own approved
implementation, rollback, and verification process.

## Visibility is not full governance

An OBO agent may be visible in a registry yet not have a distinct identity that
can be independently controlled. Treating it as fully governed creates a false
sense of assurance. S6 records such cases as owned migration or
compensating-control backlog items.

The S0 baseline is repeated at closeout because operationalization is measured
by evidence, ownership, and decisions—not by the number of tools enabled.
