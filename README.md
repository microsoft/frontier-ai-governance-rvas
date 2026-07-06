# Frontier AI Governance — RVAS

**Governing AI agents in your tenant, session by session.**

This repository publishes a **co-delivered curriculum** for putting Microsoft AI‑agent governance in place inside a customer's own tenant. It is not upskilling for its own sake: every session is a **"done‑with‑you"** working session that leaves **durable governance artifacts** behind — Infrastructure as Code, exported policies, runnable scripts, evaluation and red‑team pipelines, runbooks/checklists, and a readiness scorecard.

The content is **public and source‑cited** (grounded in Microsoft Learn) and covers the full stack: Microsoft Entra Agent ID, Microsoft Purview, Microsoft Defender for Cloud, Microsoft Foundry evaluations, PyRIT / AI Red Teaming Agent, Microsoft Agent 365, and the CAF / WAF / AI Center of Excellence operating model.

## The 7 sessions

| # | Session | Durable outcome |
|---|---------|-----------------|
| S0 | Foundations & Operating Model | Baseline maturity assessment + prioritized governance roadmap |
| S1 | Identity & Access | Entra Agent ID blueprints + Conditional Access (report‑only) + ID Protection |
| S2 | Data & Compliance | Purview DSPM for AI + DLP (test mode) + IRM + audit/eDiscovery |
| S3 | Security Posture & Runtime | Defender AI‑SPM + AI threat protection + Content Safety / Prompt Shields |
| S4 | Quality & Safety Evaluation | Foundry evaluation suite + CI/CD quality gate |
| S5 | Adversarial Testing | PyRIT / AI Red Teaming Agent scan + ASR scorecard |
| S6 | Control Plane & Operationalization | Agent 365 registry + Copilot Control System + capstone re‑score |

## Repository layout

```
docs/     MkDocs Material site (sessions, reference, assessment)
labs/     Per-session takeaway kits (infra, scripts, policies, pipelines, runbooks)
```

## Build the site locally

The fastest path is the **[dev container](.devcontainer/README.md)** — open the repo in VS Code (*Reopen in Container*) or GitHub Codespaces and every site + lab-lint tool is preinstalled.

Or set it up manually:

```bash
pip install -r requirements.txt
mkdocs serve      # preview at http://127.0.0.1:8000
mkdocs build --strict
```

## How the labs are validated

Lab assets are **statically validated** (Bicep build/lint, PowerShell/Python/bash lint, JSON schema, mock‑target pipeline runs) in CI. They are **not** executed against a live customer tenant here — live execution is the customer's co‑delivery step. Assets carry a `Verified: static-only` badge accordingly.

## Delivery model

One **facilitator** guides customer admins (who hold the tenant privileges) through each session. Everything is **report‑only / audit‑first by default**, with a documented rollback for every change. See [How to Deliver](docs/how-to-deliver.md).

## Maintenance

This is a fast‑moving, preview‑heavy domain. See [`MAINTENANCE.md`](MAINTENANCE.md) for the review cadence, "last reviewed" convention, and how to refresh the research reference.

## License

[MIT](LICENSE). Content references only publicly documented Microsoft capabilities; pricing/preview status is flagged "publicly announced — verify current."
