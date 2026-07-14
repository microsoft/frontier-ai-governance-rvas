# S1 · Identity & Access Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Check Agent ID and Conditional Access availability in the [Governance capability guide](../reference/governance-capability-guide.md).

These concepts explain why S1 starts with inventory and report-only policy. Return to [S1 Prepare](index.md) for the delivery sequence.

## An agent needs an accountable identity

Microsoft Entra Agent ID models an agent through connected objects such as a blueprint, blueprint principal, agent identity, and agent user account. The important governance outcome is not the object taxonomy by itself: every agent needs a human sponsor who is accountable for its lifecycle and use.[^entra]

This is why Prepare begins with an inventory and sponsor register. A tenant cannot apply proportionate controls or investigate an incident if it cannot say which identity belongs to which agent and who owns it.

An agent identity is more than an app registration: its sponsor and lifecycle context belong in the governance record.

## Inventory is the first control

Agent identities can be created as makers build agents in supported surfaces. That means agents may arrive through normal development activity rather than a dedicated governance onboarding step.[^entra] An inventory is the starting evidence: it shows what exists before a team decides how to protect it.

The S1 export is deliberately read-only. It lets the customer find missing sponsors, unknown identities, and candidates for further review before a policy affects any automation.

## Conditional Access for agents uses the workload-identity path

Agents are non-interactive service principals, so their Conditional Access design differs from a user policy. There is no MFA prompt to satisfy; the relevant controls focus on the identity, network, risk, and application context. Workload Identity Conditional Access is the path that targets service principals, and licensing and feature behavior must be confirmed for the customer's tenant.[^entra]

**In Co-deliver:** the policy definition targets the agent service principals and explicitly excludes break-glass access. It is a reviewed starting point, not a universal policy to apply unchanged.

## Report-only protects the learning phase

A report-only Conditional Access policy records what its decision would have been without blocking sign-in. This is especially important for non-interactive workloads: a wrongly scoped policy can interrupt automation without an obvious user-facing failure.

The safe sequence is therefore inventory, policy review, report-only observation, and only then a customer-owned decision to enforce. Evidence from sign-in logs informs that decision.

## Visibility is not the same as control

An agent that acts on behalf of a user (OBO) may be visible in telemetry without having a distinct Agent ID that can be governed independently. S1 records such cases as residual gaps rather than treating visibility as complete governance.[^a365]

Gateway authentication is a related but separate enforcement point. Citadel's APIM-layer JWT validation protects access to a gateway at runtime; Entra Agent ID, sponsorship, and workload-identity policy govern the tenant identity plane. Both may be necessary, but neither replaces the other.[^citadel]

[^entra]: Microsoft Learn - [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
[^a365]: Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview).
[^citadel]: Microsoft - [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform); [AI Hub Gateway](https://aka.ms/ai-hub-gateway).
