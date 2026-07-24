# S4 · Agent Engineering & Admission Standards

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Engineering owner</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & what the customer keeps

The customer answers one question:
**can this agent move to the next controlled stage, and on which Microsoft path?**

They leave with:

- A classification for one bounded agent candidate and the authority it may use.
- A recommended Microsoft implementation path, with confidence, assumptions,
  and alternatives the customer rejected or deferred.
- A configuration backlog for the selected path, including owners and the
  customer process that will handle each item.
- A review of governance services that may apply, such as Entra, Purview,
  Foundry, telemetry, Content Safety, gateway policy, and catalog records.
- Admission requirements and test expectations that match the agent's authority.
- A decision to admit the candidate to the next controlled stage, defer it,
  reject it, or return it for missing evidence.
- Material-change and retirement triggers.

The customer keeps the implementation decision package in its approved records
system. `labs/s4-agent-engineering/` provides blank offline templates and the
runbook. It does not hold customer code, data, credentials, integration settings,
deployment steps, or production approval.

### Plain decision

**Question:** **Do we approve, defer, reject, or route this Microsoft
implementation-path and DEV-PRE-PRO admission decision?** Default to the
Microsoft path that best fits the candidate. An exception must document the
capability, data, authority, support, and operating reason plus owner, evidence
reference, acceptance criterion, and target date. S4 selects and admits a path;
it does not change a system or approve production.

### What happens next

**Next customer action:** route the selected admission requirements and
implementation path to the customer's engineering, security, architecture, and
release owners.

In this session, the customer decides whether one bounded agent can move to its
next non-production stage. The decision records the agent's permitted authority,
the Microsoft implementation path, the evidence still needed, and the owner of
each follow-up item. For a Foundry path, the output is a Foundry Agent Service
backlog, not a live deployment. See [Microsoft Foundry Agent
Service](https://learn.microsoft.com/en-us/azure/foundry/agents/overview).

Before the agent is released or changed in a way that affects this decision, the
customer must review the recorded requirements again. Architecture, engineering,
security, change, release, and production approval remain customer processes.

## 2. Prerequisites

- One bounded candidate described in business and engineering terms.
- A governance lead who can decide, defer, or reject admission.
- A named engineering owner and service owner.
- An approved place to store evidence references and decisions.
- Existing risk, architecture, security, and change processes available by
  reference when they apply.

You do not need source code, a live integration, endpoint access, tenant changes,
or a production environment. You may use product documentation to decide the path
and backlog. Do not run deployment steps in this session.

## 3. Why this session matters

Admission needs a named owner, clear purpose and authority boundary, and a
reviewable Microsoft path. S4 records the next work, exclusions, and
material-change reapproval triggers.

Read [S4 Concepts](concepts.md) for the authority model, Microsoft path choices,
Foundry Agent Service example, evidence rules, material changes, and retirement.

## 4. Detailed facilitation reference

!!! warning "Evidence-first, report-only boundary"
    This 90-minute session reviews customer-held evidence and records references
    and decisions only. Do not generate or change customer code, configure
    Microsoft services, connect to live systems, run integrations, publish an
    agent, or grant production approval.

**Roles:** the facilitator keeps the method and boundary; the engineering owner
explains the candidate; the service owner accepts operational ownership; the
governance lead owns the admission decision; the evidence owner records approved
references. Include risk, security, data, architecture, or operations specialists
when their requirements apply.

**Entry condition:** the candidate has a purpose, intended users, proposed
authority boundary, owners, and an approved records location. If one is missing,
record the dependency and stop that decision. Do not infer it.

**What the customer actually does:** the customer reviews one agent candidate,
chooses the right Microsoft implementation path, and decides whether it can enter
the next controlled lifecycle stage.

| Activity | Time | Customer action | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set the scope and stop condition | 10 min | State the candidate's purpose, users, intended outcome, excluded use, and decision needed. | **"What exactly are we reviewing, and what would make us stop?"** A vague candidate is blocked. Do not broaden the session to make it fit. |
| Classify the candidate | 10 min | Choose the closest authority archetype and describe the tool/action boundary, human involvement, and escalation path. | **"Does it advise, ask a person to confirm, act inside a fixed boundary, or coordinate other actions?"** If the authority is unclear, record an unclassified finding. Do not admit it. |
| Compare Microsoft implementation paths | 20 min | Complete the six-path matrix: Copilot Studio, Foundry Agent Service, custom Azure service, Microsoft 365 Copilot extensibility, workflow automation, or research/prototype. | **"Which path fits the users, authority, data boundary, engineering owner, and operating model?"** Use the [Technical decisions](technical.md) path matrix for selection criteria and trade-offs. Record the recommendation, confidence, assumptions, and rejected alternatives. |
| Build the selected-path backlog | 20 min | For the recommended path, record configuration rows, owners, dependencies, evidence references, and the customer process that will handle each item. | **"What must the customer configure, validate, or approve next?"** For Foundry Agent Service, cover project/model, agent type, tools, identity, runtime controls, telemetry, evaluation, red-team, catalog, and change process. Where in scope, use the model-selection, latency-budget, and token-cost-estimate records to name the owner and limitation. |
| Review cross-cutting governance services | 15 min | Mark each relevant governance surface as applies, does not apply, unknown, or needs action outside this session. | **"Which product control or customer process must review this path?"** Consider Entra/Agent ID, Purview, telemetry, Foundry observability, Content Safety, Power Platform DLP, M365 Copilot governance, Agent 365, API Center, and customer change records. Consideration is required; deployment is not. |
| Decide lifecycle entry and hand off | 15 min | Admit to the next controlled lifecycle stage, defer, reject, or return for missing evidence. Name the decision owner, review date, material-change triggers, and retirement trigger. | **"What is allowed now, and what is still not allowed?"** Admission allows only the recorded non-production lifecycle activity. Production approval remains separate. |

### Results, evidence, and handoff

Use `labs/s4-agent-engineering/templates/admission-record.template.md` as the
implementation decision package in the customer's approved records system.
Reference only the candidate description, architecture or design record, risk
decisions, test evidence, product-path decision, backlog item, change record, and
lifecycle decision.

Record the scope, recommended path, assumptions, rejected alternatives, observed
result or no result, limitations, decision, owner, next review, follow-up
owner, and dependencies.

Where applicable, the engineering owner also records model and fine-tuning
governance in `model-selection-record.template.md`, component expectations in
`latency-budget.template.md`, and token assumptions in
`token-cost-estimate.template.md`. Record the chosen path, alternatives, and
rationale in `technical-decision-record.template.md`. When the customer has runtime and
evaluation evidence, it may assemble `rollout-decision-record.template.md` for
its own staged change decision.

A blank template, facilitator note, prototype description, or planned test does
not prove implementation quality, control operation, integration safety, or
production readiness.

### Blocker pathways

| If | Then |
|---|---|
| Purpose, authority boundary, classification, recommended implementation path, or required owner is missing | Stop the admission decision. Record the missing item, owner, target date, and lifecycle activity that cannot proceed. |
| A participant requests code generation, tenant configuration, live connection, deployment execution, or production approval | Stop that request in this session. Create a separate customer-owned engineering or change item under the right process. |
| Test evidence is incomplete, fails, or does not cover the claimed authority | Record the limitation and decision dependency. Do not treat a planned, partial, or failed test as an admission pass. |
| A material change is already proposed or the candidate is no longer needed | Require reapproval before the change, or route to the retirement process. Do not carry forward admission by assumption. |

## 5. Verification & evidence capture

- [ ] The candidate has a purpose, classification, intended authority boundary,
  recommended Microsoft implementation path, and named owners.
- [ ] The path matrix records confidence, assumptions, and rejected alternatives.
- [ ] The selected-path backlog records configuration decisions, owners, evidence
  references, follow-up owners, and customer change-process dependencies.
- [ ] Cross-cutting governance-service rows are marked applies, does not apply,
  unknown, or needs action outside this session.
- [ ] Admission requirements match the selected archetype and are backed by
  approved evidence references or recorded gaps.
- [ ] Test expectations identify the boundary, failure cases, human-control
  points where applicable, and known limitations.
- [ ] The decision states the permitted lifecycle stage, explicit exclusions,
  decision owner, review date, and dependencies.
- [ ] Material-change triggers and retirement responsibilities are recorded.
- [ ] Where in scope, the model-selection record, latency budget, and token-cost
  estimate are referenced in the customer's approved records system.

## 6. Change boundary

S4 creates no code, configuration, connection, access grant, publication, or
production lifecycle transition. Engineering, integration, change, rollback,
verification, and production approval follow the customer's approved processes.
