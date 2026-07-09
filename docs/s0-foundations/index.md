# S0 · Foundations & Operating Model

!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · Concepts sourced from [Reference - Landscape](../reference/index.md). Preview/GA status in [Product Status](../reference/product-status.md).

<span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

By the end of this session the customer leaves with, **in their own repository / records**:

- A completed **AI-agent governance maturity baseline** (7 domains, 1–4 scale) - the starting score for the whole engagement.
- A **prioritized session roadmap** generated from that baseline (which sessions to run first, and why).
- A lightweight **AI Center of Excellence operating model**: named owner/sponsor, a RACI, and a use-case intake + risk-classification stub.

**Durable artifact:** `labs/s0-foundations/` - the filled `scorecard.csv`, the generated roadmap, and the CoE `operating-model.md` / `raci.csv`, all committed to the customer's governance repo.

## 2. Prerequisites

=== "Tier A - Full production"
    - Microsoft 365 E5/E7 and an Azure subscription (needed by later sessions, confirmed now).
    - A named executive sponsor available for the operating-model conversation.
    - <span class="rvas-badge rvas-persona">Governance lead</span> with **AI Administrator** or equivalent to inventory existing AI/agent usage.

=== "Tier B - Baseline / simulation"
    - No licenses required. The assessment and operating-model artifacts are authored from workshop inputs.
    - A "what changes at Tier A" note is captured wherever a Tier-A signal (e.g. an existing agent inventory export) was unavailable.

There are **no privileged changes** in S0 - it is discovery + planning, so it is safe to run first with any audience.

## 3. Concepts

- **Operating model first.** Microsoft's Cloud Adoption Framework **for AI** sequences governance as *Strategy → Plan → Ready → Govern → Secure → Manage*; the **AI Center of Excellence** is the cross-functional team that owns it.[^caf]
- **Govern before you build.** NIST AI RMF's **Govern** function (culture, roles, accountability, inventory) is the foundation the other functions (Map, Measure, Manage) depend on - which is why this is S0.
- **Maturity, not pass/fail.** We score on a 1–4 maturity scale (Ad-hoc → Repeatable → Defined → Optimized) so progress is measurable across the engagement.
- **Agents change the risk surface.** Non-human identities, autonomous actions, and OBO execution mean human- and app-era governance has gaps this curriculum closes.[^a365]
- **The target architecture.** The operating model governs a concrete reference architecture - Microsoft's **Foundry Citadel Platform** (four layers: Governance Hub → AI Control Plane → Agent Identity → Security Fabric). See [Reference Architectures](../reference/reference-architectures.md) for how each session maps to a Citadel layer.[^citadel]

See the [Reference landscape](../reference/index.md) for the full stack and citations.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    S0 makes **no tenant changes**. Everything produced here is documentation and a score. Privileged work begins in S1.

1. **Frame the operating model** *(facilitator + <span class="rvas-badge rvas-persona">Governance lead</span> + sponsor)* - walk the CAF-for-AI phases; agree who owns AI governance (the CoE) and confirm the executive sponsor.
2. **Stand up the CoE stub** - copy `labs/s0-foundations/coe/operating-model.md` and `raci.csv` into the customer's governance repo; fill owner, sponsor, and the five persona role holders.
3. **Run the baseline assessment** *(whole room)* - open `labs/s0-foundations/assessment/scorecard.csv`; for each of the 21 questions across 7 domains, agree a 1–4 score. Be honest - this is the number S6 will beat.
4. **Generate the roadmap** - run:
   ```bash
   python labs/s0-foundations/assessment/score.py labs/s0-foundations/assessment/scorecard.csv
   ```
   The output ranks domains by lowest maturity × weight and prints the recommended session order.
5. **Agree the sequence** - the roadmap is a recommendation; the CoE decides the actual order and records it in `operating-model.md`.

## 5. Verification & evidence capture

- [ ] `scorecard.csv` has all 21 questions scored (no blanks - `score.py` warns on blanks).
- [ ] `score.py` prints an overall maturity and a 7-item prioritized roadmap.
- [ ] `operating-model.md` and `raci.csv` name a real owner and sponsor.

**Evidence to capture** (into `labs/s0-foundations/evidence/`): the committed baseline `scorecard.csv`, the roadmap output (`roadmap.txt`), and the signed-off operating model. This is the customer's dated governance baseline.

```bash
python labs/s0-foundations/assessment/score.py \
  labs/s0-foundations/assessment/scorecard.csv \
  | tee labs/s0-foundations/evidence/roadmap.txt
```

## 6. Rollback

S0 creates **documents only**, no tenant state. "Rollback" = discard the working branch. See `labs/s0-foundations/rollback.md`.

## 7. Governance mapping

| Artifact | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|----------|-------------|---------------|-----------|
| Maturity baseline + roadmap | **Govern** (1.1 accountability, inventory) | A.2 (policies), A.3 (roles & responsibilities) | Art. 17 (quality management system) |
| CoE operating model + RACI | **Govern** (2.x roles) | A.3, A.4 (resources) | Art. 17 |
| Use-case intake + risk classification | **Map** (1.x context) | A.5 (impact assessment) | Art. 9 (risk management) |

Consolidated in [Reference - Governance Mapping](../reference/governance-mapping.md).

## 8. Facilitator notes

- **Timing:** ~half day. Operating model ~60 min, assessment ~90 min (the discussion *is* the value - don't rush scores), roadmap + sequencing ~30 min.
- **RACI:** Governance lead = **R**, executive sponsor = **A**, other four personas = **C** (they'll own their sessions later).
- **Common blockers:** no clear owner (resolve before proceeding - everything downstream needs one); "we don't have any agents yet" (score to intent/plans; the point is to be ready); over-scoring optimism (anchor each level to the definitions in the [Assessment](../assessment/index.md)).
- **Hand-off:** the roadmap sets the order for S1–S6; S6 re-runs this exact scorecard as the capstone.

[^caf]: Microsoft Learn - [CAF for AI](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai/strategy); [AI Center of Excellence](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai/center-of-excellence).
[^a365]: Microsoft 365 Blog - *Microsoft Agent 365: the control plane for AI agents* (2025-11-18); Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview).
[^citadel]: Microsoft - [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform) (aka.ms/foundry-citadel) - the four-layer reference architecture for AI Foundry governance; see [Reference Architectures](../reference/reference-architectures.md).
