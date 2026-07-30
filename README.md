# AI Governance Platform

**Operational AI Governance for Microsoft AI Platforms.**

This repository publishes a lab-oriented S0-S12 curriculum for establishing and
operating AI-agent governance across Microsoft AI platforms. It is built for
customer adoption, not certification: each session turns a bounded governance
question into a customer-owned decision, implementation work package, reusable
artifact, or evidence reference. The repository contains only safe templates,
offline tools, and guidance.

The practical goal is that customers leave with work they can take into their
tenant, backlog, dashboard, policy, or operating process the next day. Customer
administrators still perform privileged actions, and production promotion
remains a separate customer change decision.

## Curriculum journey

The curriculum follows a practical maturity progression rather than a product
tour.

| Level | Goal | Customer outcome |
|---|---|---|
| **1. Discover** | Know what AI exists. | Inventory, ownership, lifecycle state, and portfolio visibility. |
| **2. Secure** | Prevent obvious mistakes. | Identity, data, platform, and runtime-control decisions. |
| **3. Govern** | Standardize delivery. | Admission standards, tool/API rules, and prompt/model change control. |
| **4. Operate** | Observe production-like behavior. | Evaluation, red-team, telemetry, cost, and incident-action signals. |
| **5. Scale** | Automate governance. | Reconciled records, governance automation, and continuous improvement. |

| Phase | Sessions | Purpose |
|---|---|---|
| Govern | S0-S2 | Establish ownership, identity/authority, and data responsibilities. |
| Establish | S3-S5 | Define the platform, engineering, and tool/API governance that makes controls enforceable. |
| Assure | S6-S8 | Review runtime security, quality/release assurance, and adversarial resilience. |
| Operate | S9-S12 | Steward lifecycle and control records, operate with evidence, govern LLM and prompt changes, and improve the portfolio. |

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
| S10 | Operate, Monitor & FinOps | Workload operating-review decision with remediation handoff |
| S11 | LLMOps | End-to-end LLMOps lifecycle decision and implementation backlog |
| S12 | Portfolio Governance & Continuous Improvement | Portfolio triage decision and dated governance roadmap |

Sessions are selected by the S0 scope, evidence, dependencies, and customer
priorities. Every session should answer: what changes in the customer's tenant,
repo, backlog, dashboard, policy, or operating process tomorrow? No session
authorizes a production change. Use the
[Implementation artifact catalog](docs/reference/implementation-artifact-catalog.md)
to map each session to a reusable implementation skeleton.

## Repository layout

```text
docs/     Static session site, delivery guidance, and references
labs/     Per-session README work packages, required templates, and shared offline helpers
reference-implementations/  Cross-session non-production reference implementation packages
infra/    Bicep and Terraform skeletons for future implementation labs
policies/ Azure Policy and API Management policy skeletons
agents/   Governance-agent skeletons
evaluations/  Foundry evaluation skeletons
dashboards/   Azure Monitor and Grafana dashboard skeletons
playbooks/    Sentinel and operations playbook skeletons
checklists/   Implementation readiness and acceptance checklists
templates/implementation/  Reusable implementation work-package templates
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
curriculum is operational and evidence-first, with report-only or
non-production-safe defaults. A template, mock result, or offline tool output
never proves a deployed or operating control.

## Maintenance

See [`MAINTENANCE.md`](MAINTENANCE.md) for review cadence and source-refresh
guidance.
