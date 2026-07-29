# S4 · Agent Engineering: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Foundry Agent Service, Copilot Studio, Microsoft 365 Copilot extensibility, model availability, fine-tuning, and deployment features vary by tenant, region, license, quota, and product maturity. Verify official docs before delivery.

## Microsoft default

Default to the Microsoft implementation path that fits the candidate: Copilot Studio, Microsoft Foundry Agent Service, Microsoft 365 Copilot extensibility, workflow automation, or a custom Azure app on Foundry models. S4 records path selection, model/deployment choice, admission, and promotion gates.

## Workshop route: build the agent package

1. **Choose one bounded candidate.** Name product owner, engineering owner,
   service owner, model/latency/cost owner, release owner, evidence owner, and
   approved records location.
2. **Classify authority and action.** Record inform, draft, recommend,
   act-with-approval, autonomous, coordinating, or blocked. Inventory allowed
   actions, prohibited actions, human-control point, exception path, fallback,
   rollback owner, and stop condition.
3. **Compare Microsoft build paths.** Check Copilot Studio, Microsoft Foundry
   Agent Service, Microsoft 365 Copilot extensibility, custom Azure app, workflow
   automation, and prototype-only. Record why one fits and why others are
   rejected or deferred.
4. **Build the selected-path package.** Record instruction/workflow/package
   reference, model route, tools/actions/APIs/connectors, data sources, identity
   mode, runtime controls, evaluation, telemetry, release/rollback, support
   boundary, lifecycle state, and material-change triggers.
5. **Decide model, latency, cost, quota, and fallback.** Record owner, model
   route, capacity/quota limit, latency target, cost guardrail, fallback
   behavior, fine-tuning rationale if any, and review cadence.
6. **Define DEV/PRE/PRO gates.** Record gate owner, gate purpose,
   accepted-when criteria, blocker rule, evidence reference, receiving process,
   rollback/decommission trigger, and what remains out of scope.
7. **Route downstream prerequisites.** Name platform, identity, data, tool/API,
   runtime, evaluation, red-team, catalog/control-plane, operations, and
   retirement owners where needed.
8. **Close the admission decision.** Approve the engineering path only when the
   package and next-stage gate are complete enough for receiving owners to act.
   Otherwise defer, reject, route, block, or mark prototype-only.

### Agent candidate card

Record references only. Do not copy customer code, prompts, outputs, endpoints,
tenant IDs, telemetry, live configuration, repository contents, or credentials
into this repository.

| Field | What to record |
|---|---|
| Candidate scope | Scenario, users, business purpose, environment, lifecycle state, customer record location. |
| Authority | Inform, draft, recommend, act-with-approval, autonomous, coordinating, or blocked. |
| Action inventory | Allowed tools/actions/targets, prohibited actions, approval point, exception route, fallback, rollback owner, stop condition. |
| Channel and UX | Copilot Studio channel, Microsoft 365 Copilot surface, custom app UI/API, workflow trigger, or prototype boundary. |
| Data and tools | Data categories, retrieval/source path, tool/API/connector needs, data owner, minimization or exclusion. |
| Build route | Selected Microsoft path, rejected alternatives, assumptions, unsupported route caveats. |
| Package owner | Engineering owner, service owner, support owner, release owner, evidence owner. |
| Model/cost/latency | Model route, quota/capacity owner, latency target, cost guardrail, fallback, fine-tuning review. |
| Gates | DEV/PRE/PRO owner, accepted-when criteria, blocker, rollback/decommission trigger. |
| Downstream prerequisites | Platform, identity, data, tool/API, runtime, evaluation, red-team, catalog, operations, retirement. |
| Decision | Approve, defer, reject, route, blocked, or prototype-only with owner, target date, review trigger. |

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

### Route comparison: when not to use a path

| Path | Do not use when... | Safer route |
|---|---|---|
| Copilot Studio | The candidate needs bespoke orchestration, custom runtime code, non-governed connectors, or engineering lifecycle controls outside the environment strategy. | Foundry Agent Service, custom Azure app, or workflow automation. |
| Foundry Agent Service | The scenario is a simple deterministic workflow, the tenant/region/SKU does not support required features, or tool/data/identity owners are unknown. | Workflow automation, prototype-only, or defer with Foundry backlog. |
| Microsoft 365 Copilot extensibility | The candidate needs a custom UX/runtime outside M365, unreviewed Graph permissions, or action governance the tenant cannot support. | Custom Azure app, Copilot Studio, or defer to M365 admin owner. |
| Custom Azure app | The team cannot own SDLC, platform route, gateway/API exposure, telemetry, rollback, support, or catalog records. | Foundry Agent Service, Copilot Studio, or route to platform engineering. |
| Workflow automation | The task requires reasoning, dynamic tool selection, contextual response generation, or non-deterministic planning. | Copilot Studio, Foundry Agent Service, or custom app. |
| Prototype-only | The candidate needs real users, production data, external actions, or promotion without admission. | Reopen admission and select an operational route. |

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

### Model, latency, cost, and fine-tuning checklist

| Check | Question |
|---|---|
| Model route | Which model family, deployment alias, provider path, region, residency assumption, and version owner apply? |
| Capability fit | Which task, language, context, tool-use, grounding, or safety requirement drives the model choice? |
| Latency | What user-facing latency target exists, which component owns it, and what happens when it is missed? |
| Cost and quota | Who owns token budget, quota/capacity, rate limits, allocation limits, and spending review? |
| Fallback | Which fallback model, no-answer behavior, queue, or manual route applies when model/service capacity is unavailable? |
| Fine-tuning | Which bounded capability gap justifies it, who owns training data, and what base-versus-tuned evaluation comparison is required? |
| Review trigger | Which model, prompt, package, data, tool, quota, or cost change forces reapproval? |

### Gate outcome table

| Gate | Purpose | Accepted when | Hard stop |
|---|---|---|---|
| DEV | Controlled engineering/prototype work. | Candidate card, authority, selected route, package owner, data boundary, and non-production label are recorded. | No owner, unclear authority, no evidence location, or prototype using real users/data/actions outside isolation. |
| PRE | Integration or certification readiness. | Platform route, tool/API dependencies, identity boundary, runtime proof plan, evaluation plan, rollback owner, and support owner are recorded. | No gate owner, no rollback, unresolved action authority, unsupported route, or missing runtime/evaluation prerequisite. |
| PRO | Customer production decision outside S4. | Customer change process has accepted lifecycle, support, monitoring, evaluation evidence, and production approval records. | S4 record alone is being treated as production approval. |

### Downstream handoff checklist

| Handoff | Required question |
|---|---|
| Platform | Which environment, gateway, network, telemetry, and deployment assumptions must platform owners accept? |
| Identity | Which user, host, agent, delegated, managed identity, RBAC, or app permission path must identity owners review? |
| Data | Which source, retrieval, prompt, output, telemetry, or evaluation-data boundary must data/compliance owners review? |
| Tool/API | Which tools, connectors, APIs, actions, schemas, permissions, publication, and withdrawal routes must owners accept? |
| Runtime | Which safeguards, denied actions, human controls, telemetry, correlation, and incident routes must runtime owners assess later? |
| Evaluation | Which scenario set, dataset, rubric, threshold, scorecard, and release decision owner must be ready? |
| Red-team | Which authorization, scope, target, rules of engagement, and remediation route are required before adversarial testing? |
| Catalog/control-plane | Which agent/tool/API/model route, lifecycle state, version, owner, exception, and retirement record must be registered? |

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
