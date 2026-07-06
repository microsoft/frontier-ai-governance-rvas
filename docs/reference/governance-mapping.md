# Reference — Governance Mapping

!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · This page cross‑references every session's durable artifacts to the control frameworks customers are audited against. Each session also repeats its own mapping in section 7 of its page.

## Frameworks in scope

- **NIST AI RMF** — functions **Govern · Map · Measure · Manage**.
- **ISO/IEC 42001** — AI management system (AIMS) controls.
- **EU AI Act** — obligations for prohibited / high‑risk / limited‑risk AI. *(NIST alignment covers ~60–70% of EU AI Act obligations — legal review still required.)*

## Session → framework matrix

| Session | Durable artifact | NIST AI RMF | ISO 42001 (illustrative) | EU AI Act (illustrative) |
|---------|------------------|-------------|--------------------------|--------------------------|
| S0 Foundations | Maturity assessment + roadmap + CoE operating model | Govern | A.2 (policies), A.3 (roles) | Art. 17 (quality mgmt system) |
| S1 Identity | Entra Agent ID blueprints, Conditional Access, ID Protection | Govern, Manage | A.6 (lifecycle), A.9 (access) | Art. 14 (human oversight), Art. 12 (logging) |
| S2 Data & Compliance | DSPM for AI, DLP, IRM, audit | Map, Manage | A.7 (data), A.8 (impact) | Art. 10 (data governance), Art. 12 (logging) |
| S3 Security & Runtime | Defender AI‑SPM, threat protection, Content Safety | Measure, Manage | A.6, A.10 (operations) | Art. 15 (accuracy, robustness, cybersecurity) |
| S4 Evaluation | Foundry evaluation suite + CI/CD gate | Measure | A.6 (verification & validation) | Art. 15 (accuracy), Art. 9 (risk mgmt) |
| S5 Adversarial Testing | PyRIT / AI Red Teaming Agent scan + ASR scorecard | Measure, Manage | A.6, A.10 | Art. 15 (robustness, cybersecurity) |
| S6 Control Plane | Agent 365 registry + capstone re‑score | Govern, Manage | A.2, A.3, A.10 | Art. 17 (post‑market monitoring) |

!!! note "Detail is authored per session"
    The precise line‑item mapping for each artifact lives in **section 7** of each session page and is consolidated here during the final integration pass.
