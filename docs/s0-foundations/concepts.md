# S0 · Governance Baseline & Operating Model Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Shared platform context is in the [Platform technical guide](../reference/platform-technical-guide.md).

This page explains the ideas behind S0. Read it before the workshop if the operating-model vocabulary is unfamiliar. Use the [S0 Prepare chapter](index.md) to begin the session.

## Operating model before technology

![Operating-model decisions become named ownership and a delivery backlog.](../assets/diagrams/s0-operating-model-handoff.svg)

An operating model answers four plain questions. Who decides? Who does the work? Where are decisions recorded? How are disagreements resolved?

That matters before any AI tool is enabled. An agent can reach data, call tools, and act with delegated authority. A technical control without an owner becomes an unmanaged exception.

In S0, the CoE stub and RACI make ownership concrete. The goal is not a new committee. The goal is a named sponsor, a governance lead, and a repeatable way to accept or reject agent use cases.

The Cloud Adoption Framework for AI gives the broader sequence. Strategy and planning come before governance, security, and ongoing management.[^caf]

It becomes useful when the customer records owners, decisions, and follow-up.

## The baseline becomes a work list

S0 ends with a foundation path, not just a maturity score. It can sequence
identity review before agent admission, prepare data evidence before data policy
work, assign a platform owner before platform or runtime assurance, or hold a
use case until sponsorship and records ownership are clear.

Use Microsoft capability names only when they route ownership. S0 does not
configure Entra, Purview, Foundry, Copilot Studio, a gateway, observability,
catalog, or FinOps. It names the capability track that needs an owner, evidence
source, or customer change process.

## Govern before you build

NIST AI RMF's **Govern** function sets culture, roles, accountability, and inventory. It supports the later work of understanding context (**Map**), measuring outcomes (**Measure**), and treating risk (**Manage**).[^nist]

S0 does not configure tenant controls. The customer decides agent ownership,
risk acceptance, evidence location, and the response when a use case misses the bar.

**In Prepare:** use this model when you frame the sponsor and RACI discussion. It explains why the executive sponsor and governance lead are required, not optional paperwork.

## Maturity is a baseline, not a pass/fail test

A maturity score describes how repeatable a capability is today. The S0 assessment uses four levels: Ad-hoc, Repeatable, Defined, and Optimized.

The discussion behind the score matters more than the number. A low score can show a missing owner, missing evidence, or an untested control. A high score should have proof behind it.

S12 repeats the same assessment later. The customer compares the current state with the baseline and assigns the remaining gaps.

The baseline prioritizes the next session; it is not an audit verdict.

## Why agents change the governance problem

Agents are more than chat interfaces. They can use non-human identities, retrieve enterprise data, call downstream tools, and act on behalf of a user. Those capabilities create ownership, access, and traceability gaps that older app inventories may miss.[^a365]

S0 surfaces those gaps before technical sessions. Intake captures intended
capability, data exposure, human oversight, accountable sponsor, and product.

**Boundary:** S0 identifies and prioritizes risk. Identity controls, data
controls, platform boundaries, and validation stay with the accountable domain
owners.

## The target architecture gives the model somewhere to land

The Foundry Citadel Platform organizes AI governance into Governance Hub, AI Control Plane, Agent Identity, and Security Fabric layers.[^citadel] The operating model defines the people and decisions across those components.

S0 does not require that platform to be deployed. It helps the customer decide who will own platform evidence and exceptions once the platform exists. See the [Platform technical guide](../reference/platform-technical-guide.md) for the technical mapping.

[^caf]: Microsoft Learn - [Cloud Adoption Framework for AI strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai/strategy); [AI Center of Excellence](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai/center-of-excellence).
[^nist]: NIST - [AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework).
[^a365]: Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview).
[^citadel]: Microsoft - [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform) (aka.ms/foundry-citadel).

## Related official references

## Policy, control, visibility, and proof

S0 frames the operating model through four questions. What does policy define? Which later controls can enforce it? What visibility will show what happened? Which customer record can support the decision?

This is not a maturity claim. It is a way to make sure a use-case decision has an owner and an evidence route before technical work starts.

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for the Policy-Control-Visibility-Proof lens, phase translation, and official sources that inform S0 backlog routing.
