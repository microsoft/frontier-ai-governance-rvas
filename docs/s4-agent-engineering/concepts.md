# S4 · Agent Engineering & Admission Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

Use [S4 Prepare](index.md) for the 90-minute co-delivery method. This page
explains the admission decision for one agent: what it may do, what evidence is
needed, and who owns the next work. It recommends a Microsoft path and backlog,
not deployment or production use.

## Classification is about authority

![Authority classification routes candidates to an admission focus; unclear authority is not admitted.](../assets/diagrams/s4-authority-admission-tree.svg)

Classify a candidate by what it is meant to do, not by its label or framework.
The highest-impact action sets the standard.

| Archetype | Intended authority | Minimum admission focus |
|---|---|---|
| Advisory assistant | Produces information or recommendations; a person takes any consequential action. | Purpose, audience, information boundaries, quality expectations, limitations, and accountable owner. |
| Human-confirmed action agent | Prepares or requests an action that requires a named human confirmation before execution. | Confirmation point, action scope, approver role, failure handling, action traceability, and test evidence. |
| Bounded delegated-action agent | Performs defined actions within a constrained authority without per-action confirmation. | Explicit authority and tool/action inventory, access boundary, safeguards, exception path, monitoring expectation, and negative testing. |
| Coordinating agent | Sequences, delegates, or selects among multiple actions or components. | All delegated-action requirements plus orchestration boundary, dependency map, escalation, recovery, and evidence for each consequential path. |

If the intended authority is unclear, classify the candidate as
**unclassified** and do not admit it. An agent does not become advisory just
because it also explains its work.

## Microsoft implementation paths

S4 records a recommended Microsoft implementation path, confidence, assumptions,
and rejected alternatives. This is planning input for the customer's architecture,
engineering, and change processes. It is not a deployment decision or production
approval.

| Path | Use when | Minimum S4 backlog focus |
|---|---|---|
| Copilot Studio / Power Platform agent | The candidate fits a low-code agent, Power Platform environment strategy, governed connectors, and maker/admin ownership model. | Environment zone, maker/admin roles, DLP/data policies, connectors/actions, authentication, publication route, solutions/ALM, monitoring/audit, and retirement owner. |
| Microsoft Foundry Agent Service agent | The candidate needs a Foundry-managed prompt or hosted agent, Foundry model/tools, managed endpoint, identity, observability, and evaluation integration. | Foundry project, model deployment, agent type, instructions or code package, tools/data connections, identity/RBAC, runtime controls, tracing, evaluation, red-team readiness, catalog/lifecycle, and change process. |
| Custom Azure application or service agent using Foundry models/tools | The agent logic remains in a customer application or service while using Foundry models, Responses API, platform tools, gateway, telemetry, or evaluation capabilities. | Application architecture, model/tool endpoint, API/gateway exposure, workload identity, data boundary, observability, release review, rollback, service operation, and API/catalog records. |
| Microsoft 365 Copilot extensibility / declarative agent | The candidate should run inside the Microsoft 365 Copilot experience with declarative instructions, knowledge, actions/plugins, and tenant-admin distribution controls. | Agent definition, instructions, knowledge sources, capabilities/actions, consequential-action marking, app metadata, admin distribution, tenant governance, testing, and Agent Store or publication route. |
| Workflow automation with AI capability | The candidate is mainly a business workflow, trigger, or automation with AI-assisted decisions or content generation. | Workflow owner, trigger, action boundary, connector/data policy, human confirmation, exception route, audit trail, operational support, and change owner. |
| Research/prototype with no operational admission | The candidate is exploratory and should not enter an operational lifecycle yet. | Isolation boundary, excluded users/data/actions, expiry date, learning goals, evidence owner, and trigger for reclassification before any operational use. |

The matrix records why one path fits the authority, users, data boundary,
engineering ownership, and operating model better than the alternatives.

## Foundry Agent Service worked example

For a Microsoft Foundry Agent Service candidate, S4 produces a configuration
backlog, not deployment instructions. The customer uses the backlog to prepare
its admission decision and to reassess a material change.

| Backlog area | S4 decision question | Owner or customer process |
|---|---|---|
| Foundry project and resource boundary | Which project, subscription/resource boundary, environment, and owner would hold the agent record? | Platform or engineering process. |
| Agent type | Is this a prompt agent, hosted agent, or existing external agent using the Responses API? | Engineering owner; architecture/change process. |
| Model deployment | Which approved model deployment or model-access path is planned, and who owns model-operation risk? If fine-tuning is considered, which capability gap drives it, who owns training-data governance, what pre/post evaluation comparison is required, and which customer process owns its lifecycle? | Engineering or platform owner; evaluation review. |
| Instructions or code package | What prompt, instruction asset, hosted-agent code package, or package review is required? | Engineering owner; customer SDLC. |
| Tools, data, connectors, functions, or APIs | Which tools and data sources are allowed, prohibited, or pending governance review? | Tool/API, data, and runtime-control owners. |
| Identity and access | What Entra identity, RBAC, managed identity, service principal, OBO, or agent identity consideration applies? | Identity owner and customer identity process. |
| Runtime controls | Which content safety, prompt shield, gateway, human-control, or prohibited-action boundary is needed? | Security and change process. |
| Tracing and observability | What traces, logs, metrics, Application Insights/OpenTelemetry, or Foundry observability evidence is expected? | Platform operations and assurance owner. |
| Evaluation and release assurance | What evaluation target, dataset owner, threshold, scorecard, or release decision will be reviewed? | Evaluation and release-decision owner. |
| Red-team readiness | What authorization, scope, and remediation route are needed before adversarial testing? | Authorized testing owner. |
| Catalog and lifecycle | Where will the agent, tools, owner, status, exception, and retirement record be cataloged? | Service owner and lifecycle process. |
| Deployment and change process | Which customer change process owns rollout, rollback, production approval, and post-release verification? | Customer engineering/change authority. |

Use the same structure for other paths, but deepen only the selected path and
briefly record rejected or deferred alternatives.

## Model selection and fine-tuning are governance decisions

Model choice affects capability, cost, latency, data residency, licensing,
version ownership, and change review. The S4 decision package records the model
path, assumptions, alternatives, and accountable owners.

Fine-tuning may fit when the customer has a bounded capability gap and approved
training-data governance. It needs a base-versus-fine-tuned evaluation
comparison, model-version owner, SDLC route, and release route. S4 records those
dependencies. It does not train, evaluate, or deploy a model. See the
[quality, cost, latency, and rollout guide](../reference/quality-cost-latency-guide.md).

## Latency and cost are governed, not only measured

A latency budget records the user expectation, component limits, coverage limit,
regression owner, and operating-review route. A token-cost estimate records
assumptions, model-tier trade-offs, spending owner, allocation limits, and
FinOps handoff. A trace or price sheet helps the review. It does not make the
decision alone.

Foundry tracing may add context where the customer enables it. Application
Insights and OpenTelemetry are general telemetry routes. Record the evidence
source, coverage, retention, and limits. Assign trend and drift review to the
customer's operating owner; do not assume that telemetry proves a control works.

## Cross-cutting governance services are considered, not imposed

Every path states whether governance surfaces apply, do not apply, are unknown,
or need action outside this session. S4 requires an explicit decision, not every
service.

Mandatory consideration areas include:

- Entra identity, RBAC, workload identity, and Agent ID where applicable;
- Purview or other data-governance boundary where applicable;
- Azure Monitor, Application Insights, OpenTelemetry, or platform telemetry;
- Foundry evaluation and observability where applicable;
- Content Safety, prompt shields, gateway policy, or runtime controls where
  applicable;
- Power Platform Managed Environments, DLP, connectors, solutions, ALM, and
  monitoring for Copilot Studio paths;
- Microsoft 365 Copilot extensibility governance for declarative-agent paths;
- Agent 365, API Center, catalog, lifecycle, or registry surfaces where
  applicable; and
- customer architecture, security, risk, change, and production-release
  processes.

## Admission requirements match the authority

Every archetype needs a bounded purpose, classification, implementation path,
accountable owners, evidence location, lifecycle state, and implementation
decision package. Higher authority adds requirements. It never removes the lower
ones.

For candidates that can request or perform actions, the package also states:

- the allowed tools, actions, targets, and data categories at a level reviewers
  can understand;
- authority limits, human-control points, exception handling, and stop or
  escalation behavior;
- access and dependency boundaries, including what the candidate must not access
  or do;
- selected implementation path, configuration backlog, and governance-service
  applicability decisions;
- test expectations and acceptance criteria that fit the impact of a failure;
  and
- operational ownership, review cadence, incident or issue route, and known
  limitations.

Evidence is a reference to a customer-held record. A claim, demonstration, or
empty field is not evidence.

## Ownership separates accountability

One person may hold more than one role only when the record says so. The
implementation decision package names:

| Role | Accountability |
|---|---|
| Business or purpose owner | Intended outcome, permitted use, and continued need. |
| Engineering owner | Design integrity, implementation path, and technical remediation. |
| Service owner | Operability, support route, lifecycle coordination, and retirement execution. |
| Governance decision owner | Admission, deferral, exception, and reapproval decisions. |
| Evidence owner | References, retention location, and reviewability of the decision record. |
| Risk or control owner | Applicable risk acceptance and control obligations. |

An unnamed future owner is a gap, not a retirement or operating plan.

## Tests show bounded claims

Test expectations should match the archetype and intended authority. They may
include design checks, representative scenarios, boundary and negative cases,
denied dependency behavior, unavailable dependency behavior, human-confirmation
behavior, recovery behavior, escalation behavior, and access or action-limit
tests.

The record should distinguish **planned**, **observed**, **passed**, **failed**,
and **not applicable**. Offline test evidence proves only the stated test. It
does not prove live integration, operating effectiveness, or production readiness.

## Material changes require reapproval

Reapproval is required before a change that could invalidate the admission
decision, including a change to:

- purpose, intended users, or permitted use;
- classification or degree of delegated authority;
- action, tool, target, data category, access boundary, or human-control point;
- implementation path, product path, agent type, material component, dependency,
  or operating model;
- model deployment, prompt or instruction asset, hosted-agent package, connector,
  API, identity, telemetry, evaluation plan, catalog registration, or
  production-change route;
- accountable owner, exception decision, accepted risk, or acceptance criteria;
- test scope, failure handling, recovery behavior, or retirement obligation.

The organization may define more triggers. A version number alone does not decide
materiality. The decision owner records why the change does or does not affect
the admitted boundary.

## Lifecycle entry and retirement are decisions

Lifecycle entry happens when the decision owner admits the candidate to a stated
next stage with owners, evidence references, limits, and a review date. The
decision must say what remains out of scope. S4 does not approve production
release.

Retirement starts when the purpose ends, an owner cannot continue, risk is no
longer acceptable, a replacement supersedes the candidate, or a lifecycle
decision requires withdrawal. The customer retirement process assigns who stops
use, removes or disables approved access, retains records, communicates status,
and confirms closure. A retirement decision must not leave an unowned authority
boundary behind.

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for Foundry, Content Safety, and lifecycle sources that can inform an admission
or material-change assessment. See the
[quality, cost, latency, and rollout guide](../reference/quality-cost-latency-guide.md)
for cross-session decision-record guidance.
