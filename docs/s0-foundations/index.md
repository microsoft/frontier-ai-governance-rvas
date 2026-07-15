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

1. **Frame ownership** *(facilitator + <span class="rvas-badge rvas-persona">Governance lead</span> + sponsor)* - agree who owns AI governance and the decision record.
2. **Prepare the customer baseline** - copy `labs/s0-foundations/assessment/scorecard.csv`, `coe/operating-model.md`, and `raci.csv` to the customer-approved record location. The scorecard schema is `domain`, `domain_name`, `question_id`, `question`, `concept_explanation`, `weight`, and `score`; scores are blank or `1`–`4`.
3. **Perform the safe baseline review** *(whole room)* - score the 21 questions across 7 domains in the customer copy. Record rationale and disagreements only in the customer record.
4. **Generate the roadmap locally** - run:
   ```bash
   python labs/s0-foundations/assessment/score.py /approved/customer/path/scorecard.csv
   ```
   The offline output ranks lower-scoring domains first; total question weight breaks ties.
5. **Agree the sequence** - the roadmap is a recommendation. The customer records the actual order, owner, approver, and review date in its decision record.

## 5. Verification & evidence capture

- [ ] The customer scorecard has all 21 questions scored or explicitly
  identified as unanswered.
- [ ] The offline scorer produces an overall maturity and prioritised roadmap.
- [ ] The customer record names the governance owner, sponsor, decision, and
  next review date.

Register a reference and retention/classification metadata for the customer
baseline in `04-operate/evidence-register.json`, and the roadmap decision in
`04-operate/decision-register.json` in the generated delivery workspace. Do
not copy the baseline, roadmap, operating model, or RACI into this repository.

## 6. Change boundary

S0 makes no tenant changes. Customer capability, licensing, ownership, or
delivery gaps are handed to the customer backlog; any later change uses that
customer's approved process.

## 7. Facilitator notes

- **Timing:** ~half day. Operating model ~60 min, assessment ~90 min (the discussion *is* the value - don't rush scores), roadmap + sequencing ~30 min.
- **RACI:** Governance lead = R, executive sponsor = A, other four personas = C (they'll own their sessions later).
- **Common blockers:** no clear owner (resolve before proceeding - everything downstream needs one); "we don't have any agents yet" (score to intent/plans; the point is to be ready); over-scoring optimism (anchor each level to the definitions in the [Assessment](../assessment/index.md)).
- **Hand-off:** the roadmap sets the order for S1–S6; S6 re-runs this exact scorecard as the capstone.
