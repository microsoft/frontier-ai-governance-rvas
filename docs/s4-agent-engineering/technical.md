# S4 · Agent Engineering: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Foundry Agent Service, Copilot Studio, Microsoft 365 Copilot extensibility, model availability, fine-tuning, and deployment features vary by tenant, region, license, quota, and product maturity. Verify official docs before delivery.

## Microsoft default

Default to the Microsoft implementation path that fits the candidate: Copilot Studio, Microsoft Foundry Agent Service, Microsoft 365 Copilot extensibility, workflow automation, or a custom Azure app on Foundry models. S4 records path selection, model/deployment choice, admission, and promotion gates.

## Decision tree

1. **If a low-code business workflow fits**, choose Copilot Studio and apply Power Platform governance.
2. **If a pro-code agent needs tools, traces, evaluations, or custom orchestration**, choose Microsoft Foundry Agent Service or a custom Azure app on Foundry models.
3. **If the agent lives in the Microsoft 365 productivity surface**, choose Microsoft 365 Copilot extensibility and Agent 365 governance where available.
4. **If deterministic automation is enough**, choose workflow automation instead of an agent.
5. **If production evidence is missing**, hold at DEV or PRE and route runtime, evaluation, catalog, and operating prerequisites.

| Path | Microsoft control surface to inspect | Admission emphasis |
|---|---|---|
| Copilot Studio | Power Platform environment, DLP policy, connector inventory, maker ownership | connector and environment governance |
| Foundry Agent Service | Foundry project, agent, model deployment, tool, trace, evaluation records | tool, model, telemetry, and evaluation readiness |
| Custom Azure app | app repo/release, managed identity, API Management route, Azure Monitor telemetry | full engineering ownership |
| M365 Copilot extensibility | M365 Copilot admin/extension records, Agent 365 where available, Graph connector/data controls | M365 data and extension governance |
| Workflow automation | Power Automate/Logic Apps/run history/connector records | deterministic change control |
| Prototype isolation | sandbox owner, data boundary, expiration date | explicit non-production constraint |

### Implementation path anatomy

Use this matrix to make the path decision concrete. Record the selected path in
the customer system of record; do not create or deploy the agent from S4.

| Path | Technical package to identify | Required route before PRE/PRO |
|---|---|---|
| Copilot Studio | Environment, solution, maker/admin owner, topics/actions, connectors, DLP policy, authentication, publication channel, monitoring and audit route. | Power Platform governance, data classification, connector/tool decision, runtime route where applicable, lifecycle entry. |
| Foundry Agent Service | Foundry project, agent type, instructions or hosted code package, model deployment, tools, connected data, identity/RBAC, tracing, evaluation, safety settings. | Identity, platform profile, tool/API route, runtime controls, evaluation, catalog, and operations. |
| Microsoft 365 Copilot extensibility | Declarative instructions, knowledge sources, actions/plugins, Graph permissions, app metadata, tenant distribution route, admin review, user experience owner. | M365 admin/app review, delegated/app authority, data boundary, action/API decision, Agent 365 lifecycle where available. |
| Custom Azure app | Repository/release, model/API backend, gateway route, managed identity or federation, data dependencies, app telemetry, deployment IaC, rollback path, support owner. | Identity, platform, tool/API, runtime, evaluation, catalog, and operations handoffs plus customer SDLC and change control. |
| Workflow automation | Trigger, deterministic steps, connector list, AI step if any, human approval, run history, exception handling, owner, retirement route. | Power Platform/Logic Apps governance, data and connector checks, change owner, operating route if production. |
| Prototype isolation | Sandbox boundary, excluded data/actions/users, expiry date, learning objective, evidence owner, promotion trigger. | Reclassification before integration; no PRE/PRO route until admission is reopened. |

### Agent package record

Every selected path should produce a package record with enough technical detail
for later sessions to validate changes without reading source code or live
configuration.

| Field | Record |
|---|---|
| Package identity | Agent/package name, version or release reference, environment, owner, lifecycle state, support boundary. |
| Instructions or workflow | Prompt/instruction reference, workflow definition, hosted code package, or declarative manifest reference; no raw prompts in this repo. |
| Model route | Model family/deployment alias, region/residency assumption, quota/capacity owner, fallback model if any, model-version review trigger. |
| Tools and APIs | Tool/action/API list, version/schema, gateway route, allowed/prohibited actions, publication state. |
| Data sources | Source category, classification, retrieval/search path, minimization point, data owner. |
| Identity | User, host workload, agent, delegated/OBO, and resource authorization assumptions; identity owner. |
| Runtime controls | Gateway/model/app/in-process safety placement, human-control point, denial behavior, runtime owner. |
| Evaluation | Scenario/dataset/rubric reference, threshold owner, unsupported dimensions, evaluation owner. |
| Telemetry | Trace/correlation method, token/cost metric route, alert/support owner, operating owner. |
| Release and rollback | DEV/PRE/PRO gate, approver, release manifest, rollback target, decommissioning trigger. |

### Authority-to-gate matrix

| Authority archetype | Human control | Required technical handoffs |
|---|---|---|
| Inform | User acts outside the agent; no consequential action by the agent. | Data boundary, quality/relevance evaluation, monitoring if production. |
| Draft | Agent prepares content or action for human review. | Data handling, output safety, quality/safety evaluation, versioned prompt/package record. |
| Recommend | Agent ranks or recommends an action with business impact. | Source fitness, runtime safety, threshold/rubric owner, drift review. |
| Act with approval | Agent prepares or invokes action only after a named approval point. | Authority, tool/API route, correlation, negative cases, lifecycle, approval audit. |
| Bounded autonomous | Agent executes defined actions without per-action approval. | Least privilege, controlled platform/tool route, layered controls, assurance, catalog, alerts. |
| Coordinating | Agent sequences or delegates across multiple components. | All bounded-autonomous gates plus dependency map, recovery path, per-component evidence, escalation owner. |

### Material-change trigger reference

| Change | Why it matters | Route |
|---|---|---|
| Prompt/instruction, workflow, or hosted package | May alter behavior, authority, or safety claim. | Engineering reapproval and regression review. |
| Model deployment, alias, family, provider, region, or fallback | Changes capability, cost, latency, residency, and baseline. | Engineering, evaluation, operations, and model-lifecycle review where in scope. |
| Tool/API schema, action, connector, or permission | Changes what the agent can cause. | Tool/API, runtime, catalog, and local pre-call policy review where applicable. |
| Data source, retrieval index, label, or minimization point | Changes compliance and grounding assumptions. | Data-governance and groundedness/context review. |
| Identity, RBAC, OBO, managed identity, or gateway product | Changes authority and auditability. | Identity, tool/API, and runtime review. |
| Telemetry, correlation, alert, or retention route | Changes operating evidence and proof limits. | Runtime and operating review. |
| Owner, support process, environment, or publication channel | Changes accountability and lifecycle state. | Catalog/portfolio and customer change process. |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Path fit | Copilot Studio, Foundry, M365 Copilot extensibility, Power Platform, or Azure app architecture record |
| Model/deployment | Foundry model deployment alias, quota/capacity, region, version owner, fine-tuning proposal if any |
| Admission | authority archetype, human-control point, runtime-proof need, evaluation plan, red-team trigger |
| Promotion | DEV/PRE/PRO labels, release manifest, rollback owner, customer change approval record |
| Catalog/handoff | Azure API Center or control-plane register entry, operations owner |

## Decision matrix

| Stage | Entry decision | Accepted when... | Next route |
|---|---|---|---|
| DEV | bounded engineering/prototype admission | owner, data boundary, path choice, and non-production label are recorded | runtime/evaluation backlog |
| PRE | integration/certification admission | platform profile, runtime proof plan, evaluation plan, and rollback owner are recorded | customer release process |
| PRO | customer production decision | lifecycle entry, support/alert route, accepted evaluation evidence, and customer approvals are in the approved record | operations |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Path selection | selected path, rejected alternatives, assumptions, and owner are recorded | Engineering owner |
| Model selection | deployment alias, model/version owner, residency/quota/cost limits, and fine-tuning rationale if any are recorded | Platform/model owner |
| Admission | authority archetype maps to required safety, evaluation, red-team, and human-control gates | Release owner |
| Promotion | DEV/PRE/PRO gate, rollback owner, and material-change trigger are recorded | Change authority |

## Boundary note

S4 selects and admits a path; deployment, configuration, and production approval stay with the customer process.

## Related references

- [S4 Concepts](concepts.md): authority model, path choices, material changes, retirement.
- [Runtime security decisions](../s6-security-runtime/technical.md), [evaluation decisions](../s7-evaluation/technical.md), and [control-plane decisions](../s9-control-plane/technical.md).
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
