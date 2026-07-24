# AI Governance Platform

**A practical S0-S13 curriculum for governing AI agents in enterprise environments.**

This repository publishes a co-delivered curriculum for establishing and
operating AI-agent governance in a customer's environment. Each session leaves
a durable, customer-owned decision or evidence reference; the repository
contains only safe templates, offline tools, and guidance.

## Curriculum journey

| Phase | Sessions | Purpose |
|---|---|---|
| Govern | S0-S2 | Establish ownership, identity/authority, and data responsibilities. |
| Establish | S3-S5 | Define the platform, engineering, and tool/API governance that makes controls enforceable. |
| Assure | S6-S8 | Review runtime security, quality/release assurance, and adversarial resilience. |
| Operate | S9-S13 | Steward lifecycle and control records, operate with evidence, govern LLM and prompt changes, and improve the portfolio. |

| # | Session | Durable outcome |
|---|---|---|
| S0 | Foundations & Governance Operating Model | Governance operating-model decision and first backlog |
| S1 | Agent Identity, Authority & Access | Agent identity and authority decision with implementation handoff |
| S2 | Data Governance & Compliance | Data-use and enforcement decision with evidence handoff |
| S3 | Enterprise Platform & Trust Boundaries | Platform readiness decision and implementation work package |
| S4 | Agent Engineering & Admission Standards | Agent admission and promotion decision with build handoff |
| S5 | API, Tool & MCP Governance | Tool/API publication decision with controlled handoff |
| S6 | Security Posture & Runtime Assurance | Runtime enforcement decision with acceptance evidence |
| S7 | Quality, Safety Evaluation & Release Assurance | Evaluation and release-gate decision with evidence package |
| S8 | Adversarial Testing & Remediation | Adversarial finding decision with remediation handoff |
| S9 | Control Plane, Catalog & Lifecycle | Control-plane record and lifecycle decision with cadence |
| S10 | In-Process Agent Governance | In-process control decision with engineering handoff |
| S11 | Operate, Monitor & FinOps | Workload operating-review decision with remediation handoff |
| S12 | LLMOps | End-to-end LLMOps lifecycle decision and implementation backlog |
| S13 | Portfolio Governance & Continuous Improvement | Portfolio triage decision and dated governance roadmap |

S10 is selected only when the customer's architecture includes a meaningful
in-process tool-call boundary. Every other session is selected by the S0 scope,
evidence, dependencies, and customer priorities; no session authorizes a
production change.

## Repository layout

```text
docs/     Static session site, delivery guidance, references, and assessment
labs/     Per-session offline kits: templates, schemas, scripts, and runbooks
tools/    Safe workspace generation and static validation
```

## Build the site locally

```bash
npm run build
python3 -m http.server -d docs 8000
```

## Generate a customer delivery workspace

```bash
npm run generate-workspace -- \
  --intake examples/engagement-intake.example.json \
  --out ../customer-agent-governance
```

Generated workspaces store templates and references only. Never store customer
identifiers, credentials, configuration, exports, logs, or evidence payloads in
this repository.

## Delivery model

The facilitator guides the method; customer administrators perform privileged
actions and customer decision owners approve changes and accept risk. The
curriculum is audit-first and report-only by default. A template, mock result,
or offline tool output never proves a deployed or operating control.

## Maintenance

See [`MAINTENANCE.md`](MAINTENANCE.md) for review cadence and source-refresh
guidance.
