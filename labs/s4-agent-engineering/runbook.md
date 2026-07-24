# S4 Runbook: Agent Engineering & Admission Standards

Use this runbook with the [agent-admission activity guide](../../docs/s4-agent-engineering/index.md).
The customer reviews its records and makes decisions; the facilitator preserves
the 90-minute, evidence-first, report-only boundary while producing a decision
package.

> **Boundary:** do not request or generate customer code, execute
> framework-specific implementation, connect to a live system, execute an
> integration, alter access or configuration, publish an agent, or approve
> production use.

## Activity card

**90 minutes:** scope and stop condition (10), classification (10),
Microsoft path matrix (20), selected-path backlog (20), cross-cutting
governance services (15), lifecycle decision and next actions (15).

**Roles:** engineering owner explains the candidate; service owner explains
operation and retirement ownership; governance lead makes or defers the
decision; evidence owner records references; relevant specialists interpret
their requirements. The facilitator manages time, questions, boundaries, and
decision wording.

**Entry condition:** a bounded candidate with stated purpose, intended
authority, engineering owner, service owner, governance decision owner, and
approved records location. Stop the affected decision if any item is absent.

## 1. Set the scope and classify

- [ ] State the candidate's purpose, intended users, expected outcome, excluded
  use, decision sought, and stop condition.
- [ ] Select advisory assistant, human-confirmed action agent, bounded
  delegated-action agent, coordinating agent, or unclassified.
- [ ] Record the highest-consequence intended action, action/tool boundary,
  human-control point, exception path, and known limitation.

Ask: “What authority is actually intended?” and “What must never happen without
another decision?” If authority cannot be stated, record `unclassified` and
stop admission.

## 2. Complete the Microsoft implementation-path matrix

1. Copy `templates/admission-record.template.md` into the approved records
   system as the implementation decision package.
2. Score each path as recommended, plausible, rejected, or out of scope:
   Copilot Studio / Power Platform agent; Microsoft Foundry Agent Service
   agent; custom Azure application or service agent using Foundry models/tools;
   Microsoft 365 Copilot extensibility / declarative agent; workflow automation
   with AI capability; research/prototype with no operational admission.
3. Record the recommended path, confidence, assumptions, and rejected
   alternatives. A recommendation is planning input, not deployment approval.
4. Name the purpose, engineering, service, governance decision, evidence, and
   applicable risk/control owners.
5. Reference the applicable architecture, risk, security, change, and
   operational records; do not copy their content into this kit.

Ask: “Which path best fits the authority, users, data boundary, engineering
ownership, and operating model?” and “Why are the other paths not the current
recommendation?”

## 3. Build the selected-path configuration backlog

Complete a lightweight row for every path that remains plausible, then deepen
the selected path. For Microsoft Foundry Agent Service, cover:

- [ ] Foundry project, subscription/resource boundary, environment, and owner.
- [ ] Agent type: prompt agent, hosted agent, or existing external agent using
  the Responses API.
- [ ] Model deployment or model-access path and model-operation owner.
- [ ] Instructions, prompt asset, hosted-agent code package, or package review.
- [ ] Tools, connected data, connectors, functions, APIs, and prohibited tools.
- [ ] Entra identity, RBAC, managed identity, service principal, OBO, or agent
  identity consideration where applicable.
- [ ] Content safety, prompt shield, gateway policy, human-control, or
  prohibited-action boundary.
- [ ] Tracing, logs, metrics, Application Insights/OpenTelemetry, or Foundry
  observability evidence.
- [ ] Evaluation target, dataset owner, threshold, scorecard, and customer evaluation process.
- [ ] Red-team authorization, scope, remediation route, and retest process.
- [ ] Agent/catalog/lifecycle record, review cadence, and
  retirement owner.
- [ ] Customer change process, rollback owner, production-approval boundary,
  and post-release verification route.

Ask: “What would the customer actually configure, validate, or approve next?”
Each backlog row needs an owner, evidence reference or gap, dependency, and
follow-up customer process.

### 3a. Record model, latency, and cost decisions

- [ ] Copy the model-selection, latency-budget, and token-cost-estimate
  templates when those questions apply.
- [ ] Record the model capability, cost, latency, data-governance, and
  fine-tuning assumptions as references and owned gaps.
- [ ] Name the cost owner, latency-regression owner, training-data review owner,
  and the customer process for evaluation, finance, or operations review.

Ask: “Which model tier is the cost owner accountable for?” “What is the
consequence of a latency regression?” and “Is fine-tuning justified, and who
owns the training-data review?” These records do not calculate cost, collect
telemetry, or fine-tune a model.

## 4. Review related governance services and test expectations

1. Mark each related governance area as applies, does not apply,
   unknown, or follow-up item: Entra/Agent ID, Purview/data governance,
   Azure Monitor/Application Insights/OpenTelemetry, Foundry
   evaluation/observability, Content Safety/runtime policy, Power Platform DLP
   and ALM, Microsoft 365 Copilot governance, Agent 365/API Center/catalog, and
   customer architecture/security/risk/change processes.
2. Complete only the applicable admission requirement rows for the selected
   archetype and path.
3. Reference proportionate planned or completed evidence for scenarios,
   boundary/negative behavior, unavailable dependencies, human confirmation,
   recovery or escalation, and action/access limits.
4. Mark each expectation as planned, observed, passed, failed, not applicable,
   or blocked. A no-result records the checked scope and expected signal; it is
   not automatically a pass.

Do not create a test, connection, code change, tenant configuration, or
deployment step in this session. An offline result establishes only the stated
offline result.

## 5. Assess material change and retirement

- [ ] Copy `templates/change-and-retirement.template.md` when a change or
  withdrawal is proposed.
- [ ] Treat purpose, authority, action/tool/data/access scope, human control,
  implementation path, product path, agent type, model deployment, prompt or
  instruction asset, hosted-agent package, connector/API, identity, telemetry,
  evaluation plan, catalog/lifecycle registration, material dependency,
  ownership, risk decision, test scope, failure handling, and retirement
  obligations as reapproval triggers.
- [ ] For retirement, assign the customer process owners for stopping use,
  changing or removing access, retaining required records, communication, and
  closure confirmation.

The session records whether reapproval is required; it does not perform the
change, disable an integration, or retire a service.

## 6. Decide lifecycle entry and next actions

The governance lead chooses one:

- **admit to stated next lifecycle stage;**
- **defer pending owned evidence or decision;**
- **reject for the proposed path;** or
- **return for reclassification, reapproval, or retirement.**

Record the decision, permitted next stage, explicit exclusions, rationale,
owner, approver, review date, dependencies, and evidence references. Admission
in this runbook is never production approval.

### 6a. Assemble a rollout decision when later evidence is available

Copy `templates/rollout-decision-record.template.md` only when the customer is
ready to assemble its own admission, runtime-proof, assurance, security-review,
and catalog references. If its approved records system creates a JSON rollout
record, validate that JSON against `../../contracts/rollout-decision.schema.json`.
Confirm the current stage, gateway-proof and assurance references, rollback
owner, environment label, and customer change authority. Map the customer's
DEV, PRE, and PRO labels explicitly: DEV is an isolated non-production activity;
PRE is the certification/integration stage that records intended
production-equivalence and assurance evidence; PRO is always a separate
customer production-change decision. Production promotion remains a separate
customer decision.

## Blocker pathways

| If | Then |
|---|---|
| Candidate, authority boundary, owner, recommended Microsoft path, or evidence reference is missing | Stop that decision. Record the gap, owner, target date, and effect on lifecycle entry. |
| Evidence is planned, partial, failed, or outside the claimed boundary | Record the limitation and defer or narrow the decision; do not represent it as a pass. |
| A request involves code, live integration, access, tenant configuration, deployment execution, publication, or production approval | Route it to the customer's separate engineering or change process. Do not act in this session. |
| A change affects an admitted boundary or the candidate is no longer needed | Record the trigger and require reapproval or retirement through the relevant customer process. |
| Model, latency, cost, or rollout record lacks an accountable owner or authoritative reference | Record the gap and route it to the applicable engineering, FinOps, evaluation, or change process. |
