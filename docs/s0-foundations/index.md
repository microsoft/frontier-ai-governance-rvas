# S0 · Governance Baseline & Operating Model

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

The customer leaves with a scored maturity baseline and prioritized governance roadmap.

They leave with:

- A customer-owned **AI-agent governance maturity baseline** across 13 S0-S13 domains on a 1-4 scale.
- A prioritized roadmap that shows which governance gap to close first.
- A named governance lead, executive sponsor, and decision owner for follow-on work.
- References to the baseline and roadmap decision in the customer's approved records system or generated delivery workspace.

`labs/s0-foundations/` contains blank templates and an offline scorer. Keep completed scorecards, roadmaps, names, notes, and evidence in the customer's approved system.

### Plain decision

**Question:** **Do we approve, defer, reject, or route the first governance
backlog item?** Default to the customer's existing governance forum and
backlog. Use another route only when the sponsor records the exception reason,
owner, customer record location, acceptance criterion, and target date. The result is
planning only; it does not change a customer system or approve production.

### What happens next

**Next customer action:** choose the first roadmap item and assign it to the
customer's existing governance, architecture, security, compliance, or change
process.

S0 turns the baseline into a governance backlog, naming the next track, owner,
evidence gap, assumptions, and follow-up process. Control deployment stays in the customer's approved change process.

| Pathway area | Example backlog decision |
|---|---|
| Operating model | Confirm the executive sponsor, governance lead, decision owner, exception route, and review cadence. |
| Session sequence | Prioritize identity, data, platform, admission, or other customer-owned work based on scored gaps and dependencies. |
| Microsoft capability track | Decide whether Entra/Agent ID, Purview, platform/gateway, Foundry/Copilot Studio, evaluation, catalog, observability, or FinOps needs readiness planning. |
| Customer change process | Assign the architecture, security, compliance, or release process that owns later deployment and configuration decisions. |

### Baseline schema

The customer's copy of the scorecard has one row per assessment question:

| Field | Purpose |
|---|---|
| `domain`, `domain_name` | Stable governance-domain identifier and name |
| `question_id`, `question`, `concept_explanation` | Question identity, prompt, and scoring guidance |
| `weight` | Relative weighting for the offline roadmap |
| `score` | Customer-agreed blank or `1`-`4` maturity value |

The scorer needs every field except `concept_explanation` and runs offline against the customer's retained baseline.

## 2. Prerequisites

- A named executive sponsor who can decide how governance work moves forward.
- <span class="rvas-badge rvas-persona">Governance lead</span> who owns the baseline decision and handoff.
- A customer-approved place to store the scorecard, RACI, roadmap, and decision.
- A bounded pilot question, such as which AI-agent use case or capability needs governance first.

S0 has no tenant checks and no privileged changes. Licensing, capability, and delivery gaps become customer-owned follow-up work.

## 3. Why this session matters

A customer should know who owns AI decisions before enabling controls. S0 establishes
those owners, the current baseline, and the next gap to address.

Read the [S0 Concepts](concepts.md) for the operating-model, maturity, risk, and target-architecture context.

## 4. Change boundary

S0 makes no tenant changes. Customer capability, licensing, ownership, and delivery gaps go to the customer backlog. Any later change uses the customer's approved process.
