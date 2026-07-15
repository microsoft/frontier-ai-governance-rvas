# S4 · Agent Engineering & Admission Standards

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Engineering owner</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & durable artifact

The customer leaves with a decision-ready, evidence-first admission record for
one bounded agent candidate:

- a classification and intended authority boundary;
- an approved implementation path and named owners;
- proportionate admission requirements and test expectations;
- a lifecycle-entry decision, deferral, or rejection; and
- a material-change and retirement plan.

The durable artifact is the customer-owned admission record, referenced from
the approved records system. `labs/s4-agent-engineering/` provides blank,
offline templates and a runbook. It contains no customer code, data,
credentials, integration settings, or production approval.

## 2. Prerequisites

- One bounded candidate described in business and engineering terms.
- A governance lead who can make or defer the admission decision.
- A named engineering owner and service owner.
- An approved records location for evidence references and decisions.
- Existing risk, architecture, security, and change processes available by
  reference where they apply.

No source code, prescribed framework, live integration, endpoint access, or
production environment is required.

## 3. Why this session

An agent is not admitted because it has a persuasive description or a working
prototype. Admission starts with a clear classification, a bounded authority,
accountable ownership, and evidence that the proposed engineering path can be
reviewed. The result is a controlled lifecycle-entry decision—not permission
to deploy or operate in production.

Read [S4 Concepts](concepts.md) for the classification model, implementation
paths, admission evidence, material changes, and retirement.

## 4. Co-delivery walkthrough

!!! warning "Evidence-first, report-only boundary"
    This 90-minute session reviews customer-held evidence and records
    references and decisions only. Do not generate or change customer code,
    prescribe a framework, connect to live systems, run integrations, or grant
    production approval.

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
| Classify the candidate | 15 min | Select the closest archetype and describe the proposed authority, tool/action boundary, human involvement, and escalation path. | “Does it advise, request confirmation, act within a bounded authority, or coordinate actions?” Unclear authority is an unclassified finding, not an admission result. |
| Select the implementation path | 15 min | Identify the locally approved path: governed platform capability, application/service delivery, workflow automation, or research/prototype. | “Which existing engineering and change path governs this?” No path is selected for the customer; the session records the path the customer has approved. |
| Review admission evidence and ownership | 20 min | Complete the applicable sections of the admission template using references to customer records. | “Who is accountable for purpose, engineering, operation, risk decisions, and evidence?” Missing ownership, authority, or evidence is a gap with an owner and due date. |
| Review test expectations and material changes | 15 min | Identify proportionate planned test evidence, known limits, failure handling, and changes that require reapproval. | “What would demonstrate the claimed boundary?” “What change invalidates this decision?” A planned test is not a passed test. |
| Decide lifecycle entry and hand off | 15 min | Admit to the next controlled lifecycle stage, defer, reject, or return for evidence. Name the decision owner, review date, and retirement trigger. | “What is authorized now—and explicitly not authorized?” Admission enables only the recorded non-production lifecycle activity; production approval remains separate. |

### Results, evidence, and handoff

Use `labs/s4-agent-engineering/templates/admission-record.template.md` in the
approved records system. Reference only the candidate description, architecture
or design record, risk decisions, test evidence, change record, and lifecycle
decision. Record the scope, observed result or no-result, limitations,
decision, owner, next review, and dependencies.

A blank template, a facilitator note, a prototype description, or a planned
test does not prove implementation quality, control operation, integration
safety, or production readiness.

### Blocker pathways

| If | Then |
|---|---|
| Purpose, authority boundary, classification, implementation path, or required owner is missing | Stop the admission decision. Record the missing item, owner, target date, and the lifecycle activity that cannot proceed. |
| A participant requests code generation, framework selection, live connection, or production approval | Stop that request in this session. Create a separate customer-owned engineering or change item under the appropriate process. |
| Test evidence is incomplete, fails, or does not cover the claimed authority | Record the limitation and decision dependency. Do not reinterpret a planned, partial, or failed test as an admission pass. |
| A material change is already proposed or the candidate is no longer needed | Require reapproval before the change, or route to the retirement process. Do not carry forward an admission decision by assumption. |

## 5. Verification & evidence capture

- [ ] The candidate has a purpose, classification, intended authority boundary,
  approved implementation path, and named owners.
- [ ] Admission requirements match the selected archetype and are supported by
  approved evidence references or recorded gaps.
- [ ] Test expectations identify the boundary, negative or failure cases,
  human-control points where applicable, and known limitations.
- [ ] The decision states the permitted lifecycle stage, explicit exclusions,
  decision owner, review date, and dependencies.
- [ ] Material-change triggers and retirement responsibilities are recorded.

## 6. Change boundary

S4 creates no code, configuration, connection, access grant, or lifecycle
transition. Engineering, integration, change, rollback, verification, and any
production approval follow the customer's separate approved processes.

## 7. Facilitator notes

- Keep the session evidence-first and report-only: the customer performs any
  record review and makes the decision; the facilitator records references,
  gaps, and decision wording.
- Treat classification as a governance decision based on intended authority,
  not a claim about a particular tool, model, or framework.
- Admission is not a production release. It only authorizes the next
  customer-controlled lifecycle activity stated in the record.
