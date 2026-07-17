# S1 · Identity & Access Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Check Agent ID and Conditional Access availability in the [Governance capability guide](../reference/governance-capability-guide.md).

These concepts explain why S1 starts with an authoritative inventory boundary and
ownership review. Return to [S1 Prepare](index.md) for the delivery sequence.

## An agent needs an accountable identity

Microsoft Entra Agent ID models an agent through connected objects such as a blueprint, blueprint principal, agent identity, and agent user account. The important governance outcome is not the object taxonomy by itself: every agent needs a human sponsor who is accountable for its lifecycle and use.[^entra]

This is why Prepare begins with an authoritative inventory review and sponsor
decision. A tenant cannot apply proportionate controls or investigate an
incident if it cannot say what its source covers, which identity belongs to
which agent, and who owns it.

An agent identity is more than an app registration: its sponsor and lifecycle context belong in the governance record.

## Identity findings become backlog decisions

The S1 recommendation should separate inventory evidence from implementation
work. A reviewed source can support a sponsor decision, lifecycle review,
Agent ID investigation, RBAC/OBO follow-up, access review, or blocker. It does
not create an identity, assign access, configure Conditional Access, or approve
production use.

Typical backlog rows include Entra Agent ID applicability, accountable human
sponsor, workload identity or service principal review, OBO boundary,
Conditional Access or access-review owner, gateway-authentication dependency,
and S9 catalog/lifecycle reconciliation.

## Inventory is the first control

Agent identities can be created as makers build agents in supported surfaces.
That means agents may arrive through normal development activity rather than a
dedicated governance onboarding step.[^entra] An inventory is starting evidence
only when its source and workload coverage are explicit.

S1 deliberately does not export or infer inventory data. A general
service-principal, managed-identity, application, or OBO view can corroborate a
customer record, but cannot by itself prove Agent ID status or complete
coverage. The customer records its authoritative source, coverage statement,
limitations, sponsor, lifecycle, and decision in its approved system.

## Conditional Access is a separate customer change

Conditional Access design for workload identities depends on the tenant,
licensing, workload support, scope, exclusions, and approved change process.
It is not safely represented by a generic policy or break-glass template.

**In Co-deliver:** S1 identifies ownership and source-coverage gaps. If the
customer chooses to pursue an identity control, its approved identity-change
process owns design, report-only observation where appropriate, rollout,
rollback, verification, and evidence retention.

## Visibility is not the same as control

An agent that acts on behalf of a user (OBO) may be visible in telemetry without having a distinct Agent ID that can be governed independently. S1 records such cases as residual gaps rather than treating visibility as complete governance.[^a365]

Gateway authentication is a related but separate enforcement point. Citadel's
APIM-layer JWT validation protects access to a gateway at runtime; Entra Agent
ID and sponsorship govern the tenant identity plane. Both may be necessary, but
neither replaces the other.[^citadel]

[^entra]: Microsoft Learn - [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
[^a365]: Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview).
[^citadel]: Microsoft - [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform); [AI Hub Gateway](https://aka.ms/ai-hub-gateway).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for Entra, RBAC, Conditional Access, and agent-governance sources.
