# Purview product-boundary ownership record

This record names the ownership split that Microsoft Purview does not show in one product view. Do
not copy service state, simulation results, findings, or approval records here.

| Field | Value |
|---|---|
| Maintained by | Data governance owner |
| Reviewed by | Information protection, Agent 365, source-platform, and audit owners |
| Consumer | The Purview change path and the quarterly cross-product control review |
| Update trigger | A change to an agent, source-platform application, DLP boundary, label policy, or audit operation |
| Review cadence | Quarterly |

## Product boundary

| Product path | Platform holds the state | Named owner |
|---|---|---|
| Agent 365 DLP policy, simulation, enablement, and incident routing | Microsoft Purview DLP and the approved change record | Purview operator and Agent 365 owner |
| Selected agent publication and runtime | Microsoft Foundry, Copilot Studio, or Agent Builder, as recorded in the Session 06 contract | Source-platform owner |
| Sensitivity label, publishing, encryption rights, and generated-content handling | Microsoft Purview Information Protection and the approved change record | Information protection owner |
| DSPM and Insider Risk findings | Microsoft Purview DSPM and Insider Risk Management | Data owner and information protection owner |
| Foundry Data Security enablement, app-scoped DLP rule, and `processContent` enforcement, when `agent.platform` is `foundry` | Microsoft Foundry, Microsoft Purview, and the application change record | Foundry platform owner, Purview operator, and application developer |
| Agent activity | Microsoft Purview Audit | Audit owner |

## Operating boundary

The Agent 365 DLP policy governs the selected agent's use in Microsoft 365. It does not replace the
runtime controls owned by Microsoft Foundry, Copilot Studio, or Agent Builder.

When `agent.platform` is `foundry`, the Agent 365 policy does not govern Foundry calls. Foundry DLP
is active only when the Purview operator scopes the rule to the Entra-registered application and
the application developer enforces the Microsoft Graph `processContent` result with signed-in user
context.

Use the approved Purview change path for the DLP policy in the approved nonproduction scope. The
change record holds the agent instance, group, label, directions, locations, action, simulation
outcome, propagation time, intended match, out-of-scope non-match, and restore decision. Do not
duplicate those values here.
