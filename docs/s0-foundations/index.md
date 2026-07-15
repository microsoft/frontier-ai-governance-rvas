# S0 · Foundations & Operating Model

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

By the end of this session the customer leaves with:

- A customer-owned **AI-agent governance maturity baseline** (7 domains, 1–4
  scale) and a prioritised roadmap.
- A decision on the accountable governance lead, executive sponsor, and
  sequence of follow-on sessions.
- References to the baseline and decision in the customer's approved records
  system or generated delivery workspace.

`labs/s0-foundations/` contains only blank templates and offline scoring tools.
Completed scorecards, roadmaps, names, notes, and evidence stay in the
customer's approved records system and are never committed to this repository.

### Baseline schema

The customer copy of the scorecard has one row per assessment question:

| Field | Purpose |
|---|---|
| `domain`, `domain_name` | Stable governance-domain identifier and name |
| `question_id`, `question`, `concept_explanation` | Question identity, prompt, and scoring guidance |
| `weight` | Relative weighting for the offline roadmap |
| `score` | Customer-agreed blank or `1`–`4` maturity value |

The scorer requires every field except `concept_explanation`; it neither sends
nor stores the customer baseline.

## 2. Prerequisites

- A named executive sponsor available for the operating-model conversation.
- <span class="rvas-badge rvas-persona">Governance lead</span> to own the
  baseline decision and its handoff.

There are no tenant checks or privileged changes in S0. Capability, licensing,
and delivery dependencies are customer-owned follow-up decisions, not S0
automated prerequisites.

## 3. Why this session

Before a customer enables controls, it needs an accountable operating model: named owners, a baseline, and a way to prioritize the gaps that matter most. S0 establishes that foundation so the later technical sessions become owned governance work rather than disconnected tooling exercises.

Read the [S0 Concepts](concepts.md) for the operating-model, maturity, risk, and target-architecture context before the delivery chapters.

## 4. Co-delivery walkthrough

!!! warning "Offline baseline only"
    S0 makes no tenant changes or tenant queries. Copy the blank templates to
    the customer's approved record location before entering any customer data.

**Timebox:** 90 minutes. **Roles:** facilitator (method and timebox), governance
lead (customer activity owner), executive sponsor (decision owner), and evidence
owner; invite domain representatives as specialist reviewers. **Entry condition:**
the sponsor, governance lead, a customer-approved evidence location, and a
bounded pilot question are available. Stop at the first missing owner or
evidence location; do not create a substitute record in Git.

**Purposeful customer action:** establish a dated, customer-owned maturity
baseline and choose the next owned governance work—not merely complete a
scorecard.

1. **Set the room and question** *(10 min)* — facilitator asks the customer to
   state: “Which governance capability must we prioritize for this pilot, and
   who can decide?” The customer confirms the safe offline posture, decision
   owner, evidence reference location, and stop condition. **Observe:** a
   meaningful start has named roles and an approved record location; no-result
   is an intentionally unanswered baseline question; blocked is no sponsor,
   owner, or records location. Record the working agreement reference.
2. **Create the customer copy** *(10 min)* — the governance lead copies
   `labs/s0-foundations/assessment/scorecard.csv`, `coe/operating-model.md`,
   and `coe/raci.csv` to the approved customer system. The facilitator asks,
   “Which evidence would justify a 1 versus a 4?” and “Who resolves a
   disagreement?” **Observe:** a completed customer copy is evidence; a
   facilitator-held template is not. If the customer cannot retain it
   appropriately, mark the activity blocked and hand off record-location
   ownership.
3. **Customer-led baseline review** *(35 min)* — customer participants score
   the 21 questions and record rationale and dissent in their copy. The
   facilitator asks, “What observed practice supports this score?”, “What is
   the gap rather than the aspiration?”, and “Which owner can change it?”
   **Meaningful result:** a score or explicitly unanswered item with rationale.
   **No-result:** the question was reviewed but evidence cannot support a
   score—record that fact, scope, and reviewer, not a pass. **Unsupported:**
   the customer cannot assess a capability with the available evidence—record
   the limitation and backlog owner. **Blocked:** a required owner or source is
   absent—stop the dependent domain and continue only with independent domains.
4. **Generate and interpret the roadmap** *(20 min)* — the customer runs the
   offline scorer against its copy:
   ```bash
   python labs/s0-foundations/assessment/score.py /approved/customer/path/scorecard.csv
   ```
   The facilitator asks, “Does the ranking match the risk and dependency we
   heard?” and “What must happen before S1 or S2?” The output ranks lower
   scores first and breaks ties by total question weight; it is a
   recommendation, not a decision or audit result. A meaningful result is an
   interpretable roadmap reference. If the tool cannot run, record the
   blocker, preserve the completed baseline reference, and assign remediation;
   do not manually invent a score.
5. **Decide and hand off** *(15 min)* — decision owner chooses the next
   session(s), defers with a date, or accepts a stated residual gap. Decision
   criteria are evidence-supported maturity, business risk, accountable owner,
   and prerequisites—not the numerical ranking alone. Evidence references are
   the dated baseline, RACI/operating-model record, scorer output reference,
   and decision record in the customer system. The facilitator reads back the
   control state (`designed`, `accepted_risk`, or `blocked`), next owner, date,
   and S1/S2 dependency. Missing authority means **deferred**, with an owner
   and review date.

## 5. Verification & evidence capture

- [ ] The customer scorecard has all 21 questions scored or explicitly
  identified as unanswered.
- [ ] The offline scorer produces an overall maturity and prioritised roadmap.
- [ ] The customer record names the governance owner, sponsor, decision, and
  next review date.
- [ ] The evidence register contains references—not copied scorecards,
  roadmaps, names, or meeting notes—and identifies any no-result, unsupported,
  or blocked domain.

Register a reference and retention/classification metadata for the customer
baseline in `04-operate/evidence-register.json`, and the roadmap decision in
`04-operate/decision-register.json` in the generated delivery workspace. Do
not copy the baseline, roadmap, operating model, or RACI into this repository.

## 6. Change boundary

S0 makes no tenant changes. Customer capability, licensing, ownership, or
delivery gaps are handed to the customer backlog; any later change uses that
customer's approved process.

## 7. Facilitator notes

- **Decision guardrail:** do not call a high score a deployed control; the
  baseline is evidence of an assessment and a prioritization decision.
- **Blocker path:** no clear owner → assign sponsor/governance-lead resolution;
  no agents yet → assess approved intent and plans; unsupported evidence →
  record the gap rather than optimistic scoring. Revisit in the named review.
- **Hand-off:** the customer roadmap sets the order for S1–S6; S6 repeats the
  same customer-held instrument as a capstone comparison.
