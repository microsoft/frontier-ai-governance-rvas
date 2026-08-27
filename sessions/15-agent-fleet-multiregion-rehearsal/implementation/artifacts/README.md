# Implementation artifacts

Session 15 keeps only the definitions needed to repeat one governed-agent and one MCP regional
rehearsal.

| Path | Purpose |
|---|---|
| `control-definition.json` | Approved scope, owners, source paths, stable Azure resource IDs, and operational store |
| `fleet/agent-inventory.md` | Dated operator snapshot for agent version, Agent 365 registry, Entra identity, and MCP inventory reconciliation |
| `regional/region.parameters.json` | Bicep parameter contract for topology, routing, health, and platform limits |
| `regional/failover-runbook.md` | Failover and restore sequence |

Preflight requires the same Foundry project ID and Application Insights ID in the control and
regional parameters, then queries those stable Azure resources live. The dated snapshot records
Confirmed visibility in Foundry Control Plane, Agent 365, Purview, and Defender. Those observations
do not stand in for live state.

The paired PowerShell and Bash health and routing scripts remain customer-owned. Session wrappers
call their fixed interfaces, reject empty or equal selectors, and ask for confirmation before
traffic moves. Both failover wrappers rerun ready preflight immediately before health and routing.
Runtime output goes only to the approved operational store.
