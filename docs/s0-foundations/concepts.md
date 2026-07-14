# S0 · Foundations & Operating Model Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Shared platform context is in the [Platform technical guide](../reference/platform-technical-guide.md).

This page explains the ideas behind the S0 Runbook. Read it before the workshop if the operating-model vocabulary is unfamiliar; use the [S0 Runbook](index.md) to facilitate the session.

## Operating model before technology

An operating model answers who decides, who performs work, how decisions are recorded, and how disagreements are resolved. For AI agents, that matters before any tool is enabled: an agent can access data, call tools, and act with delegated authority, so a technical control without an accountable owner becomes an unmanaged exception.

In S0, the CoE stub and RACI make that ownership concrete. They are deliberately lightweight: the aim is not a new committee, but a named sponsor, a governance lead, and a repeatable way to accept or reject new agent use cases. The Cloud Adoption Framework for AI provides the broader sequence: strategy and planning precede governance, security, and ongoing management.[^caf]

An operating model becomes useful when the customer records real owners, decisions, and follow-up actions in the durable artifacts.

## Govern before you build

NIST AI RMF's **Govern** function establishes culture, roles, accountability, and inventory. It is the foundation for the later work of understanding context (**Map**), measuring outcomes (**Measure**), and treating risk (**Manage**).[^nist]

S0 therefore does not try to configure a tenant control. It establishes the conditions under which later controls can be made responsibly: who owns an agent, who accepts residual risk, where evidence lives, and what happens when a use case cannot meet the agreed bar.

**In the Runbook:** use this model when framing the sponsor and RACI discussion. It explains why an executive sponsor and a governance lead are prerequisites rather than administrative overhead.

## Maturity is a baseline, not a pass/fail test

A maturity score describes the repeatability and strength of a capability over time. The S0 assessment uses four levels—Ad-hoc, Repeatable, Defined, and Optimized—to make the starting point visible without pretending every domain must be equally mature today.

The discussion behind the score matters. A low score can reveal a missing owner, absent evidence, or an untested control; a high score should be supported by proof. S6 repeats the same instrument to compare the current state with the baseline and assign the remaining gaps.

The baseline is a prioritization tool, not an audit verdict. It helps the customer choose the next session and assess whether the work had an effect.

## Why agents change the governance problem

Agents are more than chat interfaces. They can use non-human identities, retrieve enterprise data, call downstream tools, and sometimes act on behalf of a user (OBO). Those capabilities create ownership, access, and traceability gaps that traditional app inventories may not show.[^a365]

S0 makes these gaps visible before the technical sessions begin. The use-case intake and risk-classification stub should capture intended capability, data exposure, human oversight, the accountable sponsor, and the product name.

**Boundary:** S0 identifies and prioritizes risk. It does not replace the identity controls in S1, data controls in S2, runtime protections in S3, or validation in S4 and S5.

## The target architecture gives the model somewhere to land

The Foundry Citadel Platform organizes AI governance into Governance Hub, AI Control Plane, Agent Identity, and Security Fabric layers.[^citadel] The operating model is the human layer across those components: it assigns ownership for decisions made in each technical domain.

S0 does not require the platform to be deployed. Instead, it gives the customer a way to decide who will own the platform evidence and exceptions once it exists. See the [Platform technical guide](../reference/platform-technical-guide.md) for the technical mapping.

[^caf]: Microsoft Learn - [Cloud Adoption Framework for AI strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai/strategy); [AI Center of Excellence](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai/center-of-excellence).
[^nist]: NIST - [AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework).
[^a365]: Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview).
[^citadel]: Microsoft - [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform) (aka.ms/foundry-citadel).
