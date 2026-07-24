# S0 · Foundations & Operating Model

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

## 4. Detailed facilitation reference

Read [Technical decisions](technical.md) first. It covers operating-model and
control-framework options and selection criteria.

!!! warning "Offline baseline only"
    S0 makes no tenant changes or tenant queries. Copy the blank templates to
    the customer's approved record location before entering any customer data.

**Timebox:** 90 minutes. **Roles:** facilitator, governance lead, executive
sponsor, evidence owner, and domain reviewers. **To start:** sponsor, governance
lead, approved evidence location, and a bounded pilot question. If one is
missing, stop that part and assign the blocker. Keep substitute records out of
Git.

**What the customer actually does:** the governance lead scores the baseline with customer participants, then the sponsor chooses the next owned governance work.

1. **Set the room and question** *(10 min)* - the facilitator asks: **"Which governance capability must we prioritize for this pilot, and who can decide?"** The customer confirms the session stays offline, and names the decision owner, evidence location, and stop condition. A useful start has named roles and an approved record location. If there is no sponsor, owner, or records location, mark that area blocked. Record the working agreement reference.
2. **Create the customer copy** *(10 min)* - the governance lead copies `labs/s0-foundations/assessment/scorecard.csv`, `coe/operating-model.md`, and `coe/raci.csv` to the approved customer system. The facilitator asks: **"Which evidence would justify a 1 instead of a 4?"** and **"Who resolves a disagreement?"** A completed customer copy is evidence. A facilitator-held template is not. If the customer cannot retain the copy safely, mark the activity blocked and assign the records-location owner.
3. **Customer scores the baseline** *(35 min)* - customer participants score the 39 questions and record rationale and dissent in their copy. The facilitator asks: **"What current practice supports this score?"**, **"What is the real gap, not the aspiration?"**, and **"Which owner can change it?"** A useful result is a score or an explicitly unanswered item with rationale. If the evidence cannot support a score, record what was checked, the scope, and the reviewer. If a required owner or source is missing, stop that domain and continue only with independent domains.
4. **Generate and read the roadmap** *(20 min)* - the customer runs the offline scorer against its copy:
   ```bash
   python labs/s0-foundations/assessment/score.py /approved/customer/path/scorecard.csv
   ```
   The facilitator asks: **"Which option from the Technical decisions menus does this ranking support, and which alternative is rejected or deferred?"** and **"Which prerequisite must be owned before S1 or S2 can start?"** The scorer ranks lower scores first and breaks ties by total question weight. It recommends a roadmap; it does not make the decision. If the tool cannot run, keep the completed baseline reference, record the blocker, and assign remediation. Accept only customer-entered scores.
5. **Decide and hand off** *(15 min)* - the decision owner chooses the next
   piece of work, defers with a date, or accepts a stated gap. The decision uses
   maturity evidence, business risk, accountable ownership, and prerequisites.
   The facilitator reads back the control state (`designed`, `accepted_risk`, or
   `blocked`), next owner, date, backlog item, identity/data dependency, and the
   reference to `templates/technical-decision-record.template.md`. If the
   decision owner is missing, mark the decision deferred with an owner and
   review date.

## 5. Verification & evidence capture

- [ ] The customer scorecard has all 39 questions scored or explicitly marked unanswered.
- [ ] The offline scorer produces an overall maturity score and prioritized roadmap.
- [ ] The customer record names the governance owner, sponsor, decision, and next review date.
- [ ] The evidence register contains references only, not copied scorecards, roadmaps, names, or meeting notes.
- [ ] Any unanswered, unsupported, or blocked domain has a checked scope, owner, customer record location, and review date.

Register the customer baseline reference and retention/classification metadata in `04-operate/evidence-register.json`. Register the roadmap decision in `04-operate/decision-register.json` in the generated delivery workspace. Keep the baseline, roadmap, operating model, and RACI out of this repository.

## 6. Change boundary

S0 makes no tenant changes. Customer capability, licensing, ownership, and delivery gaps go to the customer backlog. Any later change uses the customer's approved process.
