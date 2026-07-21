# S1 · Identity & Access Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Check Agent ID and Conditional Access availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains why S1 starts with a trusted list and an owner for every
agent. Go back to [S1 Prepare](index.md) for the run order.

## Every agent needs an owner you can name

![Entra Agent ID links sponsored agent identities to tenant controls, while runtime access controls remain separate.](../assets/diagrams/s1-agent-identity-model.svg)

**Microsoft Entra Agent ID** gives an agent a real identity in the tenant, built
from a few connected objects (a blueprint, a blueprint principal, an agent
identity, and an agent user account). The object model isn't the point. The
point is simple: **every agent needs a human sponsor who is accountable for what
it does and how long it lives.**[^entra]

That's why the session starts by reviewing a trusted list and naming a sponsor.
If something goes wrong, you can't respond well unless you can say what your
list covers, which identity is which agent, and who owns it.

An agent identity is more than an app registration: its sponsor and lifecycle
belong in the governance record.

## Findings turn into a short backlog

Keep findings separate from follow-up. A reviewed list can support a sponsor
decision, lifecycle review, Agent ID coverage investigation, RBAC/OBO follow-up,
access review, or blocker. It does not create an identity, grant access, set up
Conditional Access, or approve production use.

The backlog names the sponsor, identity/OBO review, access-control owner,
gateway-authentication dependency, and S9 reconciliation.

## The list is your first control

Agents get identities as makers build them in supported tools. So agents can
show up through normal development, not through a tidy governance onboarding
step.[^entra] A list is only useful evidence when it says which source it came
from and which workload it covers.

S1 does not export or guess at identity data. Service-principal,
managed-identity, app, or OBO views can support a record but cannot prove an
agent identity or complete coverage. Record the trusted source, its limits,
sponsor, lifecycle, and decision.

## Conditional Access is a separate change the customer owns

Setting up Conditional Access for workload identities depends on the tenant,
licensing, which workloads support it, scope, exclusions, and the customer's
change process. A generic policy or break-glass template can't stand in for that.

**In Co-deliver:** S1 finds owner and coverage gaps. Identity controls proceed
through the customer's identity-change process.

## Seeing an agent isn't the same as controlling it

An agent acting for a user (OBO) can show up in telemetry without having its own
Agent ID you can govern on its own. S1 records these as gaps, not as "handled."[^a365]

Gateway authentication is a related but separate control. The gateway's
JWT validation at the API Management layer guards runtime access to the gateway;
Entra Agent ID and sponsorship govern the identity plane in the tenant. You
often need both, and neither replaces the other.[^citadel]

[^entra]: Microsoft Learn - [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
[^a365]: Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview).
[^citadel]: Microsoft - [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform); [AI Hub Gateway](https://aka.ms/ai-hub-gateway).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for Entra, RBAC, Conditional Access, and agent-governance sources.
