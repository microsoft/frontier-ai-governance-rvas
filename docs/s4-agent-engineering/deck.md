# S4 · Agent Engineering & Admission Standards

**Facilitator deck**

Governance lead · Engineering owner · Service owner · 90-minute evidence-first review

Note:
Welcome and framing. This is an evidence-first, report-only admission review. It creates no code, configuration, connection, access grant, publication, or production approval. Roles in the room: facilitator, engineering owner, service owner, governance lead, evidence owner, and any risk, security, data, architecture, or operations specialists who own applicable requirements.

---

## One decision for one candidate

> **"Can this agent move to the next controlled stage, and on which Microsoft path?"**

The answer must name authority, owners, evidence, limits, and what remains out of scope.

Note:
Keep the scope tight: one bounded agent candidate. S4 is the admission and change-review decision point. It records what the agent must satisfy before it ships or materially changes, but execution stays with the customer's architecture, engineering, security, change, release, and production-approval processes.

---

## Why this matters

- A convincing description is not enough.
- A prototype is not enough.
- Reviewers need purpose, owners, authority boundary, and a Microsoft path.
- The result is a practical backlog and a lifecycle decision.

Note:
Set the stakes. The customer needs a reviewable decision, not a preference or demo. S4 says what the customer may do next, what remains out of scope, and what must come back for approval before a material change.

---

## Classification is about authority

![S4 decision tree: an agent candidate is classified by intended authority into advisory assistant, human-confirmed action, bounded delegated-action, or coordinating agent, each raising the minimum admission focus; if authority is unclear the candidate is unclassified and not admitted.](../assets/diagrams/s4-authority-admission-tree.svg)

Classify by what the candidate is meant to do — not by label or framework.

Note:
Walk the decision tree from intended authority to admission focus. The highest-impact action sets the standard. If the authority is unclear, classify the candidate as unclassified and do not admit it. An agent does not become advisory just because it also explains its work.

---

## Microsoft path selection is planning

- Compare Copilot Studio, Foundry Agent Service, custom Azure service, Microsoft 365 Copilot extensibility, workflow automation, or research/prototype.
- Record the recommendation, confidence, assumptions, and rejected alternatives.
- A path recommendation creates backlog and ownership.

Note:
The matrix is not a product wish list. It explains why one path fits the authority, users, data boundary, engineering ownership, and operating model better than the alternatives. It is not a deployment decision or production approval.

---

## Selected-path backlog

- For Foundry Agent Service, record project/model, agent type, tools, identity, runtime controls, telemetry, evaluation, red-team, catalog, and change process.
- Use the same structure for other paths.
- Deepen only the selected path.

Note:
S4 produces configuration backlog, not deployment instructions. Keep short notes for paths rejected or deferred so the decision is reviewable later. Route later work to S1, S5, S6, S7, S8, S9, platform owners, or the customer's change process as appropriate.

---

## Model, latency, and cost are governed

- Model choice affects capability, cost, latency, data residency, licensing, version ownership, and change review.
- Fine-tuning needs a bounded capability gap and approved training-data governance.
- Latency budgets and token-cost estimates need owners and limits.

Note:
Do not let engineering shorthand replace governance decisions. Record model path, assumptions, alternatives, and accountable owners. Fine-tuning requires base-versus-fine-tuned evaluation comparison and customer lifecycle ownership. A trace or price sheet helps the review; it does not make the decision alone.

---

## Admission evidence matches authority

- Every archetype needs purpose, classification, implementation path, owners, evidence location, lifecycle state, and decision package.
- Higher authority adds tool/action boundaries, safeguards, exception paths, tests, and operations.
- Claims, demos, and empty fields are not evidence.

Note:
Higher authority raises the bar; it never removes lower requirements. The record should distinguish planned, observed, passed, failed, and not applicable. Offline test evidence proves only the stated test, not live integration or production readiness.

---

## Material change and retirement are decisions

- Reapprove changes to purpose, users, authority, tools, access, model, owners, tests, or operating model.
- A version number alone does not decide materiality.
- Retirement must not leave an unowned authority boundary behind.

Note:
Lifecycle entry happens only when the decision owner admits the candidate to a stated next stage with owners, evidence references, limits, and a review date. Retirement starts when purpose ends, ownership fails, risk is unacceptable, a replacement supersedes it, or a lifecycle decision requires withdrawal.

---

## The activity — how we'll work

- **Timebox:** 90 minutes · **six steps**
- **Entry condition:** purpose, users, proposed authority boundary, owners, and approved records location.
- Missing item? **Record the dependency and stop that decision.**

Note:
Preview the six steps: set scope, classify, compare paths, build backlog, review governance services, decide lifecycle entry. The customer reviews one agent candidate, chooses the right Microsoft implementation path, and decides whether it can enter the next controlled lifecycle stage.

---

## Step 1 — Set the scope and stop condition · 10 min

> **"What exactly are we reviewing, and what would make us stop?"**

State purpose, users, intended outcome, excluded use, and decision needed.

Note:
A vague candidate is blocked. Do not broaden the session to make it fit. Record only the bounded scope and the stop condition the customer accepts.

---

## Step 2 — Classify the candidate · 10 min

> **"Does it advise, ask a person to confirm, act inside a fixed boundary, or coordinate other actions?"**

Choose the closest authority archetype and describe boundary, human involvement, and escalation.

Note:
If the authority is unclear, record an unclassified finding and do not admit it. Keep the conversation focused on intended authority, not tool name, model name, or framework.

---

## Step 3 — Compare Microsoft implementation paths · 20 min

> **"Which path fits the users, authority, data boundary, engineering owner, and operating model?"**

Record the recommendation, confidence, assumptions, and rejected alternatives.

Note:
Use the technical decisions path matrix for selection criteria and trade-offs. The rejected alternatives are part of the decision, not noise. This is planning input for customer architecture, engineering, and change processes.

---

## Step 4 — Build the selected-path backlog · 20 min

> **"What must the customer configure, validate, or approve next?"**

Record configuration rows, owners, dependencies, evidence references, and later-session routing.

Note:
For Foundry Agent Service, cover project/model, agent type, tools, identity, runtime controls, telemetry, evaluation, red-team, catalog, and change process. Where in scope, name owners for model selection, latency budget, and token-cost estimate limitations.

---

## Step 5 — Review governance services · 15 min

> **"Which product control or customer process must review this path?"**

Mark each surface as applies, does not apply, unknown, or later-session item.

Note:
Consider Entra/Agent ID, Purview, telemetry, Foundry observability, Content Safety, Power Platform DLP, Microsoft 365 Copilot governance, Agent 365, API Center, and customer change records. Consideration is required; deployment is not.

---

## Step 6 — Decide lifecycle entry and hand off · 15 min

> **"What is allowed now, and what is still not allowed?"**

Admit, defer, reject, or return for missing evidence.

Note:
Name the decision owner, review date, material-change triggers, and retirement trigger. Admission allows only the recorded non-production lifecycle activity. Production approval remains separate.

---

## Verification & evidence

- [ ] Purpose, classification, authority boundary, Microsoft path, and owners are recorded.
- [ ] Path matrix includes confidence, assumptions, and rejected alternatives.
- [ ] Selected-path backlog has owners, evidence references, routing, and dependencies.
- [ ] Governance-service rows and admission requirements have evidence or gaps.
- [ ] Decision states lifecycle stage, exclusions, owner, review date, material-change triggers, and retirement responsibilities.

Note:
Use the admission record in the customer's approved records system. Reference only approved records: candidate description, design record, risk decisions, test evidence, path decision, backlog item, change record, and lifecycle decision. Do not copy customer code, data, credentials, integration settings, or deployment steps.

---

## Change boundary & hand-off

- S4 creates no code, configuration, connection, access grant, publication, or production transition.
- Engineering and production approval follow customer processes.
- Missing purpose, path, owner, or evidence stops admission.

Note:
Close by restating the boundary. If participants request code generation, tenant configuration, live connection, deployment, or production approval, stop that request in this session and create a customer-owned engineering or change item under the right process.
