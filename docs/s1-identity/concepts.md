# S1 · Identity & Access Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Check Agent ID and Conditional Access availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains why S1 starts with a trusted list and an owner for every
agent. Go back to [S1 Prepare](index.md) for the run order.

## Every agent needs an owner you can name

![S1 object model: the Entra Agent ID chain (blueprint, blueprint principal, agent identity, agent user account) sits in the tenant identity plane with an accountable human sponsor, separate from the runtime access controls (Conditional Access and gateway authentication); on-behalf-of identities are recorded as a gap.](../assets/diagrams/s1-agent-identity-model.svg)

**Microsoft Entra Agent ID** gives an agent a real identity in the tenant, built
from a few connected objects (a blueprint, a blueprint principal, an agent
identity, and an agent user account). The object model isn't the point. The
point is simple: **every agent needs a human sponsor who is accountable for what
it does and how long it lives.**[^entra]

That's why the session starts by reviewing a trusted list and naming a sponsor.
If something goes wrong, you can't respond well unless you can say what your
list covers, which identity is which agent, and who owns it.

An agent identity is more than an app registration — its sponsor and lifecycle
belong in the governance record.

## Findings turn into a short backlog

Keep two things apart in the S1 recommendation: what you found, and what to build
next. A reviewed list can support a sponsor decision, a lifecycle review, a
"does Entra Agent ID cover more of these?" investigation, RBAC/OBO follow-up, an
access review, or a blocker. It does **not** create an identity, grant access,
set up Conditional Access, or approve production use.

Typical backlog rows: does Entra Agent ID apply here, who is the human sponsor,
review the workload identity or service principal, check the OBO boundary, name a
Conditional Access or access-review owner, note the gateway-authentication
dependency, and hand the S9 reconciliation the record.

## The list is your first control

Agents get identities as makers build them in supported tools. So agents can
show up through normal development, not through a tidy governance onboarding
step.[^entra] A list is only useful evidence when it says which source it came
from and which workload it covers.

S1 deliberately doesn't export or guess at identity data. A general
service-principal, managed-identity, app, or OBO view can back up a record, but
it can't prove an agent's identity or that you've found them all. The customer
records the source it trusts, what it covers, its gaps, the sponsor, the
lifecycle, and the decision — in its own system.

## Conditional Access is a separate change the customer owns

Setting up Conditional Access for workload identities depends on the tenant,
licensing, which workloads support it, scope, exclusions, and the customer's
change process. A generic policy or break-glass template can't stand in for that.

**In Co-deliver:** S1 finds the missing owners and coverage gaps. If the customer
decides to add an identity control, their own identity-change process owns the
design, the report-only trial where it makes sense, the rollout, the rollback,
the checks, and keeping the evidence.

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
