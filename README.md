# AI Governance Platform

**A composable S0-S12 curriculum for governing enterprise AI agents.**

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
| Operate | S9-S12 | Steward lifecycle and control records, operate with evidence, and improve the portfolio. |

| # | Session | Durable outcome |
|---|---|---|
| S0 | Foundations & Governance Operating Model | Baseline maturity assessment and prioritised roadmap |
| S1 | Agent Identity, Authority & Access | Identity, sponsorship, authority-boundary, and ownership review |
| S2 | Data Governance & Compliance | Data posture findings, evidence, and review actions |
| S3 | Enterprise Platform & Trust Boundaries | Trust-boundary decision and platform implementation backlog |
| S4 | Agent Engineering & Admission Standards | Admission standard and material-change review record |
| S5 | API, Tool & MCP Governance | Controlled publication and lifecycle governance model |
| S6 | Security Posture & Runtime Assurance | Runtime assurance evidence and response ownership |
| S7 | Quality, Safety Evaluation & Release Assurance | Quality/safety and release-assurance decision |
| S8 | Adversarial Testing & Remediation | Authorized-test findings and remediation decision |
| S9 | Control Plane, Catalog & Lifecycle | Reconciliation and lifecycle stewardship record |
| S10 | In-Process Agent Governance | Applicability and adoption decision for a tool-call policy boundary |
| S11 | Operate, Monitor & FinOps | Operating review, drift, cost, and remediation cadence |
| S12 | Portfolio Governance & Continuous Improvement | Portfolio decision and next maturity roadmap |

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
