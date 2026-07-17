# S4 · Agent Engineering & Admission Standards

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Engineering owner</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & durable artifact

The customer leaves with a decision-ready, product-anchored implementation
decision package for one bounded agent candidate:

- a classification and intended authority boundary;
- a recommended Microsoft implementation path, confidence, assumptions, and
  rejected alternatives;
- a configuration backlog for the selected path and lightweight backlog notes
  for other plausible paths;
- cross-cutting governance-service applicability decisions;
- named owners, later-session routing, and customer change-process handoffs;
- proportionate admission requirements and test expectations;
- a lifecycle-entry decision, deferral, or rejection; and
- a material-change and retirement plan.

The durable artifact is the customer-owned implementation decision package,
referenced from the approved records system. `labs/s4-agent-engineering/`
provides blank, offline templates and a runbook. It contains no customer code,
data, credentials, integration settings, executable deployment instructions, or
production approval.

### Implementation pathway

S4 is the formal implementation-path decision point. It compares Microsoft
agent implementation paths, recommends one with confidence and assumptions,
records rejected alternatives, builds the selected-path configuration backlog,
and routes execution to later sessions or customer architecture, engineering,
security, change, release, and production-approval processes.

## 2. Prerequisites

- One bounded candidate described in business and engineering terms.
- A governance lead who can make or defer the admission decision.
- A named engineering owner and service owner.
- An approved records location for evidence references and decisions.
- Existing risk, architecture, security, and change processes available by
  reference where they apply.

No source code, live integration, endpoint access, tenant configuration, or
production environment is required. Product documentation may be referenced to
decide the implementation path and backlog, but the session does not execute
deployment steps.

## 3. Why this session

An agent is not admitted because it has a persuasive description, a working
prototype, or a preferred product name. Admission starts with a clear
classification, a bounded authority, accountable ownership, and a Microsoft
implementation path that can be reviewed. The result is a controlled
lifecycle-entry decision and a concrete configuration backlog—not permission to
deploy or operate in production.

Read [S4 Concepts](concepts.md) for the classification model, implementation
path taxonomy, Foundry Agent Service worked example, admission evidence,
material changes, and retirement.

## 4. Co-delivery walkthrough

!!! warning "Evidence-first, report-only boundary"
    This 90-minute session reviews customer-held evidence and records
    references and decisions only. Do not generate or change customer code,
    configure Microsoft services, connect to live systems, run integrations,
    publish an agent, or grant production approval.

**Roles:** the facilitator maintains the method and boundaries; the engineering
owner explains the candidate; the service owner accepts operational ownership;
the governance lead owns the admission decision; the evidence owner records
approved references. Include risk, security, data, architecture, or operations
specialists when their requirements apply.

**Entry condition:** the candidate has a stated purpose, intended users,
proposed authority boundary, owners, and an approved records location. If any
is absent, record a dependency and stop the affected decision; do not infer it.

| Activity | Time | Customer action | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set the scope and stop condition | 10 min | State one candidate's purpose, users, intended outcome, excluded use, and decision sought. | “What is in scope for this review?” “What evidence or owner is required to continue?” A vague candidate is a blocker, not a reason to broaden the session. |
| Classify the candidate | 10 min | Select the closest authority archetype and describe the proposed tool/action boundary, human involvement, and escalation path. | “Does it advise, request confirmation, act within a bounded authority, or coordinate actions?” Unclear authority is an unclassified finding, not an admission result. |
| Compare Microsoft implementation paths | 20 min | Complete the six-path matrix: Copilot Studio, Foundry Agent Service, custom Azure service, Microsoft 365 Copilot extensibility, workflow automation, or research/prototype. | “Which path fits the authority, users, engineering ownership, data boundary, and operating model?” Record a recommendation with confidence, assumptions, and rejected alternatives. |
| Build the selected-path backlog | 20 min | For the recommended path, record configuration backlog rows, owners, dependencies, evidence references, and later-session or change-process routing. | “What would the customer actually configure, validate, or approve next?” For Foundry Agent Service, cover project/model, agent type, tools, identity, runtime controls, telemetry, evaluation, red-team, catalog, and change process. Where in scope, use the model-selection, latency-budget, and token-cost-estimate records to name the decision owner and limitation. |
| Review cross-cutting governance services | 15 min | Mark each relevant governance surface as applies, does not apply, unknown, or later-session item. | “Does this path need Entra/Agent ID, Purview, telemetry, Foundry observability, Content Safety, Power Platform DLP, M365 Copilot governance, Agent 365, API Center, or a customer change record?” Consideration is mandatory; deployment is not. |
| Decide lifecycle entry and hand off | 15 min | Admit to the next controlled lifecycle stage, defer, reject, or return for evidence. Name the decision owner, review date, material-change triggers, and retirement trigger. | “What is authorized now—and explicitly not authorized?” Admission enables only the recorded non-production lifecycle activity; production approval remains separate. |

### Results, evidence, and handoff

Use `labs/s4-agent-engineering/templates/admission-record.template.md` as the
implementation decision package in the approved records system. Reference only
the candidate description, architecture or design record, risk decisions, test
evidence, product-path decision, backlog item, change record, and lifecycle
decision. Record the scope, recommended path, assumptions, rejected
alternatives, observed result or no-result, limitations, decision, owner, next
review, later-session routing, and dependencies.

Where applicable, the engineering owner also records model and fine-tuning
governance in `model-selection-record.template.md`, component expectations in
`latency-budget.template.md`, and token assumptions in
`token-cost-estimate.template.md`. After S6 and S7 references exist, the
customer may assemble `rollout-decision-record.template.md` for its own staged
change decision.

A blank template, a facilitator note, a prototype description, or a planned
test does not prove implementation quality, control operation, integration
safety, or production readiness.

### Blocker pathways

| If | Then |
|---|---|
| Purpose, authority boundary, classification, recommended implementation path, or required owner is missing | Stop the admission decision. Record the missing item, owner, target date, and the lifecycle activity that cannot proceed. |
| A participant requests code generation, tenant configuration, live connection, deployment execution, or production approval | Stop that request in this session. Create a separate customer-owned engineering or change item under the appropriate process. |
| Test evidence is incomplete, fails, or does not cover the claimed authority | Record the limitation and decision dependency. Do not reinterpret a planned, partial, or failed test as an admission pass. |
| A material change is already proposed or the candidate is no longer needed | Require reapproval before the change, or route to the retirement process. Do not carry forward an admission decision by assumption. |

## 5. Verification & evidence capture

- [ ] The candidate has a purpose, classification, intended authority boundary,
  recommended Microsoft implementation path, and named owners.
- [ ] The path matrix records confidence, assumptions, and rejected
  alternatives.
- [ ] The selected-path backlog records configuration decisions, owners,
  evidence references, later-session routing, and customer change-process
  dependencies.
- [ ] Cross-cutting governance-service rows are marked applies, does not apply,
  unknown, or later-session item.
- [ ] Admission requirements match the selected archetype and are supported by
  approved evidence references or recorded gaps.
- [ ] Test expectations identify the boundary, negative or failure cases,
  human-control points where applicable, and known limitations.
- [ ] The decision states the permitted lifecycle stage, explicit exclusions,
  decision owner, review date, and dependencies.
- [ ] Material-change triggers and retirement responsibilities are recorded.
- [ ] Where in scope, the model-selection record, latency budget, and token-cost
  estimate are referenced in the customer's approved records system.

## 6. Change boundary

S4 creates no code, configuration, connection, access grant, publication, or
production lifecycle transition. Engineering, integration, change, rollback,
verification, and any production approval follow the customer's separate
approved processes.

## 7. Facilitator notes

- Keep the session evidence-first and report-only: the customer performs any
  record review and makes the decision; the facilitator records references,
  gaps, and decision wording.
- Treat classification as a governance decision based on intended authority,
  not a claim about a particular tool, model, or framework.
- Treat Microsoft product-path selection as a planning decision. A path
  recommendation creates backlog and ownership; it does not deploy or configure
  that product.
- Admission is not a production release. It only authorizes the next
  customer-controlled lifecycle activity stated in the record.
