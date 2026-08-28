# Purview coverage boundary handoff

This handoff records the ownership split that Microsoft Purview does not show in one product view.
It does not copy service state, simulation results, findings, or approval records.

| Field | Value |
|---|---|
| Maintained by | Data governance owner |
| Reviewed by | Information protection, Agent 365, Foundry, and audit owners |
| Consumer | The Purview change path and the quarterly cross-product control review |
| Update trigger | A change to an agent, Foundry application, DLP boundary, label policy, or audit operation |
| Review cadence | Quarterly |

## Product boundary

| Product path | Platform holds the state | Named owner |
|---|---|---|
| Agent 365 DLP policy, simulation, enablement, and incident routing | Microsoft Purview DLP and the approved change record | Purview operator and Agent 365 owner |
| Sensitivity label, publishing, encryption rights, and generated-content handling | Microsoft Purview Information Protection and the approved change record | Information protection owner |
| DSPM and Insider Risk findings | Microsoft Purview DSPM and Insider Risk Management | Data owner and information protection owner |
| Foundry Data Security enablement, app-scoped DLP rule, and `processContent` enforcement | Microsoft Foundry, Microsoft Purview, and the application change record | Foundry platform owner, Purview operator, and application developer |
| Agent activity | Microsoft Purview Audit | Audit owner |

## Operating boundary

The Agent 365 DLP policy does not govern Microsoft Foundry calls. Foundry DLP becomes active only
when the Purview operator has scoped the rule to the Entra-registered application and the application
developer enforces the Microsoft Graph `processContent` result with signed-in user context.

Use the approved Purview change path for the scoped nonproduction DLP policy. The change record
holds the agent instance, group, label, directions, locations, action, simulation outcome,
propagation time, intended match, out-of-scope non-match, and restore decision. Do not duplicate
those values here.
