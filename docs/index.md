# Frontier AI Governance - RVAS

Governing AI agents in your tenant, session by session.

This is a **co-delivered curriculum** for putting Microsoft AI-agent governance in place inside your own tenant. It is not training for its own sake - each session is a working session that leaves durable governance artifacts running in your environment. It operationalizes Microsoft's [Foundry Citadel Platform](reference/reference-architectures.md) reference architecture, session by session.

For the full integrated path, connect or deploy the recommended [AI Hub Gateway / Citadel Governance Hub](reference/citadel-rvas-playbook.md). Customers can also begin baseline and operating-model work while an equivalent foundation is connected or platform readiness is scheduled. S0-S6 govern the agents, data, security posture, evaluation, red-team evidence, and lifecycle records around that platform.

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capabilities marked <span class="rvas-badge rvas-preview">Preview</span> may change. Pricing is *publicly announced - verify current*.

## What makes this different

- **Done *with* you, in *your* tenant.** A facilitator guides your admins through real configuration - not a demo tenant.
- **Every session leaves something lasting:** exported policies, scripts, evaluation/red-team pipelines, runbooks, evidence, and a maturity scorecard. Azure-plane platform IaC belongs to Citadel.
- **Safe by default.** Report-only / audit-first, with a documented rollback for every change.
- **One integrated path.** Connect or deploy the recommended Citadel foundation when ready, then run the governance playbook. Platform readiness becomes an owned workstream, not a parallel RVAS platform.

## The governance stack you will implement

![The governance stack you implement, session by session: agents you build climb an identity → data → security → evaluation → control pipeline, framed by the S0 operating model and re-scored each loop.](assets/diagrams/journey.svg)

## Before the sessions: what we provide

Start with [Why AI-agent governance now](start/why-governance.md), then follow the introductory sequence. It explains the simple framing:

- Citadel provides the governed AI runtime platform: gateway, access contracts, API Center, safety controls, PII masking, auth, telemetry, and FinOps.
- RVAS provides the governance operating model on top: owners, policies, evidence, evaluation gates, red-team findings, registry reconciliation, maturity scoring, and backlog.
- If a capability belongs to Citadel, RVAS does not duplicate it. Connect or deploy the foundation when ready, then govern what runs through it.

## The 7 sessions

| # | Session | Durable outcome |
|---|---------|-----------------|
| [S0](s0-foundations/index.md) | Foundations & Operating Model | Baseline maturity assessment + prioritized roadmap |
| [S1](s1-identity/index.md) | Identity & Access | Entra Agent ID blueprints + Conditional Access + ID Protection |
| [S2](s2-data-compliance/index.md) | Data & Compliance | Purview DSPM for AI + DLP + IRM + audit |
| [S3](s3-security-runtime/index.md) | Security Posture & Runtime | Defender AI-SPM + threat protection + Content Safety |
| [S4](s4-evaluation/index.md) | Quality & Safety Evaluation | Foundry evaluation suite + CI/CD gate |
| [S5](s5-red-teaming/index.md) | Adversarial Testing | PyRIT / AI Red Teaming Agent scan + ASR scorecard |
| [S6](s6-control-plane/index.md) | Control Plane & Operationalization | Agent 365 registry + capstone re-score |

## Start here

1. Follow [Why AI-agent governance now](start/why-governance.md), [Citadel + RVAS together](governance-on-citadel.md), and [Your journey](start/your-journey.md).
2. Read **[How to Deliver](how-to-deliver.md)** - the delivery model, safety protocol, and room setup.
3. Use the [Citadel + RVAS Playbook](reference/citadel-rvas-playbook.md) when the platform team needs detailed cooperation guidance.
4. Run the [Readiness Assessment](assessment/index.md) with the customer to baseline maturity and prioritize sessions.
5. Deliver the sessions in the recommended order (or the order the assessment prioritizes).

!!! note "Scope"
    All content references only publicly documented Microsoft capabilities, with citations in the [Reference](reference/index.md) section.
