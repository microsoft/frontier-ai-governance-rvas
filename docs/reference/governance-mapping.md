# Reference - Governance Mapping

!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · This page cross-references every session's durable artifacts to the control frameworks customers are audited against. Each session also repeats its own mapping in section 7 of its page.

## Frameworks in scope

- **NIST AI RMF** - functions **Govern · Map · Measure · Manage**.
- **ISO/IEC 42001** - AI management system (AIMS) controls.
- **EU AI Act** - obligations for prohibited / high-risk / limited-risk AI. *(NIST alignment covers ~60–70% of EU AI Act obligations - legal review still required.)*

## Session → framework matrix

| Session | Durable artifact | NIST AI RMF | ISO 42001 (illustrative) | EU AI Act (illustrative) |
|---------|------------------|-------------|--------------------------|--------------------------|
| S0 Foundations | Maturity assessment + roadmap + CoE operating model | Govern | A.2 (policies), A.3 (roles) | Art. 17 (quality mgmt system) |
| S1 Identity | Entra Agent ID blueprints, Conditional Access, ID Protection | Govern, Manage | A.6 (lifecycle), A.9 (access) | Art. 14 (human oversight), Art. 12 (logging) |
| S2 Data & Compliance | DSPM for AI, DLP, IRM, audit | Map, Manage | A.7 (data), A.8 (impact) | Art. 10 (data governance), Art. 12 (logging) |
| S3 Security & Runtime | Defender AI-SPM, threat protection, Content Safety | Measure, Manage | A.6, A.10 (operations) | Art. 15 (accuracy, robustness, cybersecurity) |
| S4 Evaluation | Foundry evaluation suite + CI/CD gate | Measure | A.6 (verification & validation) | Art. 15 (accuracy), Art. 9 (risk mgmt) |
| S5 Adversarial Testing | PyRIT / AI Red Teaming Agent scan + ASR scorecard | Measure, Manage | A.6, A.10 | Art. 15 (robustness, cybersecurity) |
| S6 Control Plane | Agent 365 registry + capstone re-score | Govern, Manage | A.2, A.3, A.10 | Art. 72 (post-market monitoring) |

## Consolidated artifact-level matrix

Every durable artifact shipped across the seven sessions, mapped to the framework line items it satisfies. This is the auditor-facing index; each row is authored in **section 7** of the corresponding session page.

| Session | Durable artifact | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|---------|------------------|-------------|---------------|-----------|
| S0 | Maturity baseline + prioritized roadmap | Govern | A.2, A.3 | Art. 17 |
| S0 | CoE operating model + RACI | Govern | A.3, A.4 | Art. 17 |
| S0 | Use-case intake + risk classification | Map | A.5 | Art. 9 |
| S1 | Agent identity inventory + sponsor register | Govern, Map | A.6, A.9 | Art. 14 |
| S1 | Conditional Access policy (report-only) | Manage | A.9 | Art. 15 |
| S1 | Sign-in / report-only logs captured | Measure | A.10 | Art. 12 |
| S2 | DSPM for AI findings export | Map, Manage | A.7, A.8 | Art. 10, Art. 12 |
| S2 | DLP for AI policy (simulation/test) | Manage | A.7, A.8 | Art. 10 |
| S2 | IRM / Comms Compliance / Audit / eDiscovery evidence | Map, Manage | A.7, A.8 | Art. 12 |
| S3 | Defender AI-SPM AI-BOM + posture + attack paths | Measure, Manage | A.6, A.10 | Art. 15 |
| S3 | AI Threat Protection alerts → Defender XDR | Measure, Manage | A.10 | Art. 15 |
| S3 | Content Safety Prompt Shields runtime test evidence | Measure | A.6, A.10 | Art. 15 |
| S4 | Foundry evaluation suite + CI/CD gate | Measure | A.6 | Art. 15, Art. 9 |
| S4 | Offline mock-target scorecard | Measure | A.6 | Art. 15 |
| S4 | Continuous evaluation plan + trace lineage | Measure, Manage | A.10 | Art. 72, Art. 12 |
| S5 | PyRIT / AI Red Teaming scan + ASR scorecard | Measure, Manage | A.6, A.10 | Art. 15 |
| S5 | Written scope, RoE, SOC notification | Govern, Manage | A.3, A.10 | Art. 9, Art. 12 |
| S5 | Remediation backlog (categories above ASR threshold) | Manage | A.6, A.10 | Art. 15 |
| S6 | Agent 365 registry reconciliation + capstone re-score | Govern, Manage | A.2, A.3, A.10 | Art. 72 |
| S6 | Shadow / OBO residual-gap backlog | Map, Manage | A.6, A.10 | Art. 72 |

## Coverage rollups

**NIST AI RMF function → sessions that contribute evidence**

| Function | Sessions |
|----------|----------|
| **Govern** | S0, S1, S5, S6 |
| **Map** | S0, S1, S2, S6 |
| **Measure** | S1, S3, S4, S5 |
| **Manage** | S1, S2, S3, S4, S5, S6 |

**EU AI Act article → sessions that contribute evidence**

| Article | Theme | Sessions |
|---------|-------|----------|
| Art. 9 | Risk management system | S0, S4, S5 |
| Art. 10 | Data governance | S2 |
| Art. 12 | Record-keeping / logging | S1, S2, S4, S5 |
| Art. 14 | Human oversight | S1 |
| Art. 15 | Accuracy, robustness, cybersecurity | S1, S3, S4, S5 |
| Art. 17 | Quality management system | S0 |
| Art. 72 | Post-market monitoring | S4, S6 |

!!! note "Legal review still required"
    These mappings are practitioner guidance, not a legal conformity assessment. NIST AI RMF alignment covers an estimated ~60–70% of EU AI Act obligations; classification (prohibited / high-risk / limited-risk) and formal conformity remain the customer's legal responsibility.
