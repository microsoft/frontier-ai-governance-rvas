# Frontier AI Governance — RVAS

**Governing AI agents in your tenant, session by session.**

This is a **co‑delivered curriculum** for putting Microsoft AI‑agent governance in place inside your own tenant. It is not training for its own sake — each session is a working session that leaves **durable governance artifacts** running in your environment.

!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · Capabilities marked <span class="rvas-badge rvas-preview">Preview</span> may change. Pricing is *publicly announced — verify current*.

## What makes this different

- **Done *with* you, in *your* tenant.** A facilitator guides your admins through real configuration — not a demo tenant.
- **Every session leaves something lasting:** Infrastructure as Code, exported policies, scripts, evaluation/red‑team pipelines, runbooks, and a maturity scorecard.
- **Safe by default.** Report‑only / audit‑first, with a documented rollback for every change.
- **Two prerequisite tiers.** <span class="rvas-badge rvas-tierA">Tier A</span> full production path · <span class="rvas-badge rvas-tierB">Tier B</span> baseline/simulation — so a session always produces an artifact even without every license.

## The governance stack you will implement

![The governance stack you implement, session by session: agents you build climb an identity → data → security → evaluation → control pipeline, framed by the S0 operating model and re-scored each loop.](assets/diagrams/journey.svg)

## The 7 sessions

| # | Session | Durable outcome |
|---|---------|-----------------|
| [S0](s0-foundations/index.md) | Foundations & Operating Model | Baseline maturity assessment + prioritized roadmap |
| [S1](s1-identity/index.md) | Identity & Access | Entra Agent ID blueprints + Conditional Access + ID Protection |
| [S2](s2-data-compliance/index.md) | Data & Compliance | Purview DSPM for AI + DLP + IRM + audit |
| [S3](s3-security-runtime/index.md) | Security Posture & Runtime | Defender AI‑SPM + threat protection + Content Safety |
| [S4](s4-evaluation/index.md) | Quality & Safety Evaluation | Foundry evaluation suite + CI/CD gate |
| [S5](s5-red-teaming/index.md) | Adversarial Testing | PyRIT / AI Red Teaming Agent scan + ASR scorecard |
| [S6](s6-control-plane/index.md) | Control Plane & Operationalization | Agent 365 registry + capstone re‑score |

## Start here

1. Read **[How to Deliver](how-to-deliver.md)** — the delivery model, safety protocol, and room setup.
2. Run the **[Readiness Assessment](assessment/index.md)** with the customer to baseline maturity and prioritize sessions.
3. Deliver the sessions in the recommended order (or the order the assessment prioritizes).

!!! note "Scope"
    All content references only **publicly documented** Microsoft capabilities, with citations in the [Reference](reference/index.md) section.
