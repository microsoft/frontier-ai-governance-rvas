# S0 · Foundations & Operating Model

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

By the end of this session the customer leaves with:

- A completed **AI-agent governance maturity baseline** (7 domains, 1–4 scale) - the starting score for the whole engagement.
- A prioritized session roadmap generated from that baseline (which sessions to run first, and why).
- A lightweight AI Center of Excellence operating model: named owner/sponsor, a RACI, and a use-case intake + risk-classification stub.

Durable artifact: `labs/s0-foundations/` - the filled `scorecard.csv`, the generated roadmap, and the CoE `operating-model.md` / `raci.csv`, all committed to the customer's governance repo.

## 2. Prerequisites

- Microsoft 365 E5/E7 and an Azure subscription (needed by later sessions, confirmed now).
- A named executive sponsor available for the operating-model conversation.
- <span class="rvas-badge rvas-persona">Governance lead</span> with **AI Administrator** or equivalent to inventory existing AI/agent usage.

There are no privileged changes in S0 - it is discovery + planning, so it is safe to run first with any audience.

## 3. Why this session

Before a customer enables controls, it needs an accountable operating model: named owners, a baseline, and a way to prioritize the gaps that matter most. S0 establishes that foundation so the later technical sessions become owned governance work rather than disconnected tooling exercises.

Read the [S0 Concepts](concepts.md) for the operating-model, maturity, risk, and target-architecture context behind this Runbook.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    S0 makes no tenant changes. Everything produced here is documentation and a score. Privileged work begins in S1.

1. **Frame the operating model** *(facilitator + <span class="rvas-badge rvas-persona">Governance lead</span> + sponsor)* - walk the CAF-for-AI phases; agree who owns AI governance (the CoE) and confirm the executive sponsor.
2. **Stand up the CoE stub** - copy `labs/s0-foundations/coe/operating-model.md` and `raci.csv` into the customer's governance repo; fill owner, sponsor, and the five persona role holders.
3. **Run the baseline assessment** *(whole room)* - open `labs/s0-foundations/assessment/scorecard.csv`; for each of the 21 questions across 7 domains, agree a 1–4 score. Record evidence for the score so S6 can compare the current state with this baseline.
4. **Generate the roadmap** - run:
   ```bash
   python labs/s0-foundations/assessment/score.py labs/s0-foundations/assessment/scorecard.csv
   ```
   The output ranks lower-scoring domains first; total question weight breaks ties.
5. **Agree the sequence** - the roadmap is a recommendation; the CoE decides the actual order and records it in `operating-model.md`.

## 5. Verification & evidence capture

- [ ] `scorecard.csv` has all 21 questions scored (no blanks - `score.py` warns on blanks).
- [ ] `score.py` prints an overall maturity and a 7-item prioritized roadmap.
- [ ] `operating-model.md` and `raci.csv` name a real owner and sponsor.

Evidence to capture (into `labs/s0-foundations/evidence/`): the committed baseline `scorecard.csv`, the roadmap output (`roadmap.txt`), and the signed-off operating model. This is the customer's dated governance baseline.

```bash
python labs/s0-foundations/assessment/score.py \
  labs/s0-foundations/assessment/scorecard.csv \
  | tee labs/s0-foundations/evidence/roadmap.txt
```

## 6. Rollback

S0 creates documents only, no tenant state. "Rollback" = discard the working branch. See `labs/s0-foundations/rollback.md`.

## 7. Facilitator notes

- **Timing:** ~half day. Operating model ~60 min, assessment ~90 min (the discussion *is* the value - don't rush scores), roadmap + sequencing ~30 min.
- **RACI:** Governance lead = R, executive sponsor = A, other four personas = C (they'll own their sessions later).
- **Common blockers:** no clear owner (resolve before proceeding - everything downstream needs one); "we don't have any agents yet" (score to intent/plans; the point is to be ready); over-scoring optimism (anchor each level to the definitions in the [Assessment](../assessment/index.md)).
- **Hand-off:** the roadmap sets the order for S1–S6; S6 re-runs this exact scorecard as the capstone.
