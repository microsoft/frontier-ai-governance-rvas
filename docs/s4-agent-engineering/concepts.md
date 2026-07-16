# S4 · Agent Engineering & Admission Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

Use [S4 Prepare](index.md) for the 90-minute co-delivery method. This page
defines the standards that the session reviews and the Microsoft
implementation-path taxonomy it uses. S4 recommends a path and backlog; it does
not deploy, configure, publish, or approve production use.

## Classification is about authority

Classify a candidate by the authority it is intended to exercise, not by its
label or implementation style:

| Archetype | Intended authority | Minimum admission focus |
|---|---|---|
| Advisory assistant | Produces information or recommendations; a person takes any consequential action. | Purpose, audience, information boundaries, quality expectations, limitations, and accountable owner. |
| Human-confirmed action agent | Prepares or requests an action that requires a named human confirmation before execution. | Confirmation point, action scope, approver role, failure handling, action traceability, and test evidence. |
| Bounded delegated-action agent | Performs defined actions within a constrained authority without per-action confirmation. | Explicit authority and tool/action inventory, access boundary, safeguards, exception path, monitoring expectation, and negative testing. |
| Coordinating agent | Sequences, delegates, or selects among multiple actions or components. | All delegated-action requirements plus orchestration boundary, dependency map, escalation, recovery, and evidence for each consequential path. |

If the intended authority cannot be stated, classify the candidate as
**unclassified** and do not admit it. The most consequential intended action
sets the minimum standard; a candidate does not become advisory merely because
it also produces explanations.

## Microsoft implementation paths

S4 records a recommended Microsoft implementation path, confidence,
assumptions, and rejected alternatives. The recommendation is planning input
for the customer's architecture, engineering, and change processes; it is not a
deployment decision or production approval.

| Path | Use when | Minimum S4 backlog focus |
|---|---|---|
| Copilot Studio / Power Platform agent | The candidate fits a low-code agent, Power Platform environment strategy, governed connectors, and maker/admin ownership model. | Environment zone, maker/admin roles, DLP/data policies, connectors/actions, authentication, publication route, solutions/ALM, monitoring/audit, and retirement owner. |
| Microsoft Foundry Agent Service agent | The candidate needs a Foundry-managed prompt or hosted agent, Foundry model/tools, managed endpoint, identity, observability, and evaluation integration. | Foundry project, model deployment, agent type, instructions or code package, tools/data connections, identity/RBAC, runtime controls, tracing, evaluation, red-team readiness, catalog/lifecycle, and change process. |
| Custom Azure application or service agent using Foundry models/tools | The agent logic remains in a customer application or service while using Foundry models, Responses API, platform tools, gateway, telemetry, or evaluation capabilities. | Application architecture, model/tool endpoint, API/gateway exposure, workload identity, data boundary, observability, release assurance, rollback, service operation, and API/catalog records. |
| Microsoft 365 Copilot extensibility / declarative agent | The candidate should run inside the Microsoft 365 Copilot experience with declarative instructions, knowledge, actions/plugins, and tenant-admin distribution controls. | Agent definition, instructions, knowledge sources, capabilities/actions, consequential-action marking, app metadata, admin distribution, tenant governance, testing, and Agent Store or publication route. |
| Workflow automation with AI capability | The candidate is primarily a business workflow, trigger, or automation with AI-assisted decisions or content generation. | Workflow owner, trigger, action boundary, connector/data policy, human confirmation, exception route, audit trail, operational support, and change owner. |
| Research/prototype with no operational admission | The candidate is exploratory and should not enter an operational lifecycle yet. | Isolation boundary, excluded users/data/actions, expiry date, learning goals, evidence owner, and trigger for reclassification before any operational use. |

The path matrix should not be a product wish list. It should explain why one
path fits the authority, users, data boundary, engineering ownership, and
operating model better than the rejected alternatives.

## Foundry Agent Service worked example

For a candidate recommended for Microsoft Foundry Agent Service, S4 should
produce a configuration backlog rather than deployment instructions. The
backlog should cover:

| Backlog area | S4 decision question | Likely later owner or session |
|---|---|---|
| Foundry project and resource boundary | Which project, subscription/resource boundary, environment, and owner would hold the agent record? | Platform or engineering process; S3 if platform foundation evidence is needed. |
| Agent type | Is this a prompt agent, hosted agent, or existing external agent using the Responses API? | Engineering owner; architecture/change process. |
| Model deployment | Which approved model deployment or model-access path is planned, and who owns model-operation risk? | Engineering/platform owner; S7 for evaluation-plan review. |
| Instructions or code package | What prompt, instruction asset, hosted-agent code package, or package review is required? | Engineering owner; customer SDLC. |
| Tools, data, connectors, functions, or APIs | Which tools and data sources are allowed, prohibited, or pending governance review? | S5 for tool/API publication; S2 for data boundary; S6 for runtime controls. |
| Identity and access | What Entra identity, RBAC, managed identity, service principal, OBO, or agent identity consideration applies? | S1 and customer identity process. |
| Runtime controls | Which content safety, prompt shield, gateway, human-control, or prohibited-action boundary is needed? | S6 and security/change process. |
| Tracing and observability | What traces, logs, metrics, Application Insights/OpenTelemetry, or Foundry observability evidence is expected? | S7/S11 and platform operations. |
| Evaluation and release assurance | What evaluation target, dataset owner, threshold, scorecard, or release decision will be reviewed? | S7. |
| Red-team readiness | What authorization, scope, and remediation route are needed before adversarial testing? | S8. |
| Catalog and lifecycle | Where will the agent, tools, owner, status, exception, and retirement record be cataloged? | S9 and service owner. |
| Deployment and change process | Which customer change process owns rollout, rollback, production approval, and post-release verification? | Customer engineering/change authority. |

The same structure can be used for other paths, but S4 only deepens the rows
for the selected path. Non-selected paths still need enough backlog notes to
explain why they were deferred or rejected.

## Cross-cutting governance services are considered, not imposed

Every implementation path must record whether key governance surfaces apply,
do not apply, are unknown, or need a later session. S4 does not require every
service to be deployed. It requires the applicability decision to be explicit.

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

## Admission requirements are proportional

Every archetype needs a bounded purpose, classification, implementation path,
accountable owners, evidence location, lifecycle state, and an implementation
decision package. Higher authority adds requirements; it never removes the
lower ones.

For candidates that can request or perform actions, the implementation decision
package also states:

- the allowed tools, actions, targets, and data categories at a level suitable
  for governance review;
- authority limits, human-control points, exception handling, and stop or
  escalation behavior;
- access and dependency boundaries, including what the candidate must not
  access or do;
- selected implementation path, configuration backlog, and cross-cutting
  governance-service applicability decisions;
- test expectations and acceptance criteria appropriate to the consequence of
  a failure; and
- operational ownership, review cadence, incident or issue route, and known
  limitations.

Evidence is a reference to a customer-held record. A claim, a demonstration,
or an empty field is not evidence.

## Ownership separates accountability

One person may hold more than one role only when that is explicitly recorded.
The implementation decision package names:

| Role | Accountability |
|---|---|
| Business or purpose owner | Intended outcome, permitted use, and continued need. |
| Engineering owner | Design integrity, implementation path, and technical remediation. |
| Service owner | Operability, support route, lifecycle coordination, and retirement execution. |
| Governance decision owner | Admission, deferral, exception, and reapproval decisions. |
| Evidence owner | References, retention location, and reviewability of the decision record. |
| Risk or control owner | Applicable risk acceptance and control obligations. |

Ownership must survive handoffs. An unnamed future owner is a gap, not a
retirement or operating plan.

## Tests show bounded claims

Test expectations should match the archetype and intended authority. They may
include reviewed design checks, representative scenario tests, boundary and
negative cases, denied or unavailable dependency behavior, human-confirmation
behavior, recovery or escalation behavior, and access or action-limit tests.

The record should distinguish **planned**, **observed**, **passed**, **failed**,
and **not applicable**. Evidence of an offline test is limited to the stated
test; it does not demonstrate a live integration, operating effectiveness, or
production readiness.

## Material changes require reapproval

Reapproval is required before a change that could invalidate the admission
decision, including a change to:

- purpose, intended users, or permitted use;
- classification or degree of delegated authority;
- action, tool, target, data category, access boundary, or human-control point;
- implementation path, product path, agent type, material component,
  dependency, or operating model;
- model deployment, prompt or instruction asset, hosted-agent package,
  connector, API, identity, telemetry, evaluation plan, catalog registration,
  or production-change route;
- accountable owner, exception decision, risk posture, or acceptance criteria;
- test scope, failure handling, recovery behavior, or retirement obligation.

The organization may define additional triggers. A version number change alone
does not decide materiality; the decision owner records why the change does or
does not affect the admitted boundary.

## Lifecycle entry and retirement are decisions

Lifecycle entry occurs when the decision owner admits the candidate to a stated
next stage with owners, evidence references, limitations, and a review date.
The decision must say what remains out of scope. S4 does not approve a
production release.

Retirement begins when the purpose ends, an owner cannot be sustained, risk is
no longer acceptable, a replacement supersedes the candidate, or a lifecycle
decision requires withdrawal. The customer retirement process should assign
responsibility for stopping use, removing or disabling approved access through
the applicable change process, retaining required records, communicating the
status, and confirming closure. A retirement decision must not leave an
unowned authority boundary behind.
