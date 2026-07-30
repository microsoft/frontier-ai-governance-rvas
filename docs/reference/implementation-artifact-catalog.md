# Implementation artifact catalog

Use this catalog to connect each S0-S12 decision session to the reusable
implementation artifact family that can move customer adoption forward. It is
the bridge between the decision-oriented lab kits in `labs/` and the
implementation skeletons in the repository root.

## Asset boundary

| Asset type | Purpose | What it is not |
|---|---|---|
| Decision lab | Facilitates a bounded customer decision and records safe references. | A deployed control or production approval. |
| Implementation skeleton | Provides a reusable non-production starting point for an artifact, policy, agent, dashboard, playbook, or IaC pattern. | Customer evidence, live configuration, or proof of enforcement. |
| Customer evidence | Lives in the customer's approved records system and proves what the customer observed, approved, or changed. | Repository content. |

Keep customer identifiers, tenant configuration, credentials, prompts, outputs,
telemetry exports, screenshots, live policy exports, and evidence payloads out
of this repository.

## S0-S12 artifact map

| Session | Maturity level | Decision output | Implementation artifact family | Repo path | Acceptance signal | Customer handoff |
|---|---|---|---|---|---|---|
| S0 · Technical Intake & Feasibility Triage | Discover | Bounded use case, decision owner, evidence location, and first blocker. | Intake checklist and implementation work-package wrapper. | `checklists/`, `templates/implementation/` | Candidate has owner, safe stop condition, and next session route. | Governance lead and evidence owner. |
| S1 · Identity Path Trace | Secure | Identity and authority decision with implementation handoff. | Entra Agent ID, workload identity, RBAC, and credential-review skeletons. | `infra/`, `checklists/` | Identity path has sponsor, owner, authorization boundary, and recheck trigger. | Identity admin and platform owner. |
| S2 · Foundry Purview Compliance | Secure | Data-use and enforcement decision with evidence handoff. | Data-classification, DLP, retention, and compliance checklist skeletons. | `policies/azure-policy/`, `checklists/` | Data path has owner, classification, permitted use, and control route. | Data owner and compliance lead. |
| S3 · Platform Plumbing Verification | Secure | Platform-route readiness decision and implementation work package. | Landing-zone, gateway-proof, private-network, and telemetry IaC skeletons. | `reference-implementations/`, `infra/bicep/`, `infra/terraform/` | Non-production route has expected control points, telemetry pointer, and owner. | Platform owner and architecture review process. |
| S4 · Agent Build Path & Admission | Govern | Agent admission and promotion decision with build handoff. | Agent metadata, admission checklist, and build-path reference skeletons. | `agents/governance/`, `checklists/` | Candidate has authority classification, build path, admission criteria, and change owner. | AI engineering lead and change process. |
| S5 · API and Tool Admission Workflow | Govern | Tool/API publication decision with controlled handoff. | API Center, APIM policy, MCP/tool publication, and withdrawal skeletons. | `policies/apim/`, `checklists/` | Tool has owner, schema, permission boundary, gateway route, and withdrawal path. | API owner and platform owner. |
| S6 · Runtime Path Evidence & Response | Secure | Runtime enforcement decision with acceptance evidence. | Prompt firewall, APIM policy, Content Safety, correlation, and response skeletons. | `policies/apim/`, `dashboards/azure-monitor/`, `playbooks/sentinel/` | Non-production request path produces expected policy and response signal. | Security owner, SOC owner, and telemetry owner. |
| S7 · Foundry Evaluation Runbook | Operate | Evaluation and release-gate decision with evidence package. | Foundry evaluation plan, CI/CD gate, and threshold-governance skeletons. | `evaluations/foundry/`, `templates/implementation/` | Candidate and baseline have approved evaluator, threshold owner, and release route. | AI engineering lead and release authority. |
| S8 · Authorized Red Teaming Runbook | Operate | Authorized finding, remediation, and residual-risk decision. | Red-team authorization, safe test harness, remediation, and retest skeletons. | `playbooks/sentinel/`, `checklists/` | Rules of engagement, supported target, finding route, and retest owner are recorded. | Security owner and SOC/remediation process. |
| S9 · Control-Plane Reconciliation & Lifecycle | Discover / Scale | Control-plane record and lifecycle decision with cadence. | Agent inventory, reconciliation helper, lifecycle policy, and governance-agent skeletons. | `labs/helpers/`, `agents/governance/`, `reference-implementations/` | Explicit IDs reconcile across registry, identity, tool, telemetry, and portfolio records. | Governance lead and registry steward. |
| S10 · Operating Evidence & FinOps | Operate / Scale | Operating review, FinOps, drift hypothesis, and remediation handoff. | Azure Monitor, Grafana, OpenTelemetry, cost, capacity, and incident dashboard skeletons. | `dashboards/azure-monitor/`, `dashboards/grafana/`, `playbooks/sentinel/` | Operating signals have query owner, cadence, remediation owner, and cost/capacity route. | Operations owner, FinOps owner, and service owner. |
| S11 · LLMOps Change Control | Govern | Model and prompt operating-model decision and lifecycle backlog. | Prompt policy, model lifecycle, evaluation linkage, and change-control skeletons. | `templates/implementation/`, `evaluations/foundry/`, `checklists/` | Material changes have versioning, approval, rollback, incident, and deprecation routes. | LLMOps owner and change authority. |
| S12 · Portfolio Evidence & Roadmap | Discover / Scale | Portfolio triage decision and dated governance roadmap. | Executive dashboard, portfolio rollup, roadmap, and continuous-governance skeletons. | `dashboards/azure-monitor/`, `reference-implementations/`, `agents/governance/` | Portfolio has ranked actions, stale-source visibility, owners, and recurrence model. | Executive sponsor and portfolio owner. |

## How to add a future implementation lab

1. Start from the session decision output and maturity level.
2. Choose the artifact family and repo path from this catalog.
3. Create or update a skeleton with safe defaults and customer-supplied
   parameters.
4. Document required roles, non-production validation, rollback or stop
   condition, and evidence references.
5. Link the implementation artifact from the matching session page or lab README
   only after the safety boundary is explicit.

## Required safety language

Every implementation artifact should state:

- intended session and maturity level;
- customer owner and implementation owner;
- required customer-supplied parameters;
- non-production validation path;
- evidence that must remain in the customer records system;
- what the artifact does not prove or approve.
