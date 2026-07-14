# S6 · Control Plane & Operationalization Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Confirm Agent 365 licensing and feature availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the operational model behind S6. Use [S6 Prepare](index.md) to begin reconciliation and capture the exit evidence.

## A control plane is the operating view of the estate

An enterprise control plane provides a place to observe and govern AI agents across their lifecycle. Microsoft Agent 365 describes capability areas including Registry, Access Control, Visualization, Interoperability, and Security, alongside an Observe / Govern / Secure framing.[^a365]

For S6, the key question is practical: can the customer identify every known agent, its owner, lifecycle state, access context, and unresolved governance gaps from an operational record?

**Boundary:** a registry is not automatically a source of truth. It becomes one only after it is reconciled against the identity inventory, maker knowledge, and platform evidence.

## Reconciliation exposes the gaps between inventories

Different inventories answer different questions. S1's Entra Agent ID export shows governed identities; an Agent 365 registry shows the control-plane view; API Center or Access Contract evidence can show the gateway/platform view. Reconciliation compares these sources to reveal records that are missing, duplicated, or contradictory.

The delivery chapters treat a missing record as a finding, not an error to hide. A shadow agent may be unknown to the control plane; a registry-only record may need identity or owner confirmation.

## Ownership and lifecycle state make evidence actionable

An agent that has a name but no accountable sponsor cannot be safely accepted as operational. Lifecycle states—such as proposed, active, exception, suspended, retired, and decommissioned—give the customer a consistent way to decide what may run and what needs attention.

S6 starts read-only because writing ownership or access metadata changes the operational record. The customer must review findings, approve a change, and retain the previous state before any write is made.

## Visibility is not full governance

An OBO agent may appear in logs or registry data but not have a distinct identity that can be independently controlled. Treating this as “fully governed” creates a false sense of assurance. S6 flags such cases and turns them into an owned migration or compensating-control backlog.[^a365]

This is why S6 closes the loop with S1 rather than treating the registry as an isolated dashboard.

## Citadel and Agent 365 provide adjacent views

In the Citadel model, the Governance Hub and API Center provide an Azure-plane registry view, while Agent 365 and Entra Agent ID contribute control-plane and identity views.[^citadel] S6 does not deploy either platform. It brings their evidence together so the governance team can operate a coherent record.

The S0 baseline is repeated at the end because operationalization is measured by evidence and ownership, not by the number of tools enabled.

[^a365]: Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview).
[^citadel]: Microsoft - [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform); [AI Hub Gateway](https://aka.ms/ai-hub-gateway).
