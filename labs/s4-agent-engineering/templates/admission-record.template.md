# Agent Implementation Decision Package

## Scope and decision request

| Field | Record |
|---|---|
| Candidate reference | |
| Purpose and intended users | |
| Expected outcome and excluded use | |
| Classification | |
| Highest-consequence intended action | |
| Requested lifecycle-entry decision | |
| Explicitly excluded lifecycle activity | |
| Review date | |

## Authority boundary

| Field | Record |
|---|---|
| Allowed actions, tools, targets, and data categories | |
| Authority limits and prohibited actions | |
| Human-control point and exception route | |
| Material dependencies and operating boundary | |
| Known limitations | |

## Microsoft implementation-path matrix

| Path | Fit: recommended / plausible / rejected / out of scope | Rationale, assumptions, and rejected-alternative note | Owner / next action |
|---|---|---|---|
| Copilot Studio / Power Platform agent | | Environment, DLP/data policies, connectors/actions, authentication, publication, solutions/ALM, monitoring/audit, and retirement considerations. | |
| Microsoft Foundry Agent Service agent | | Foundry project, model, agent type, instructions/code, tools, identity, runtime controls, observability, evaluation, red-team, catalog/lifecycle, and change considerations. | |
| Custom Azure application or service agent using Foundry models/tools | | Application architecture, model/tool endpoint, API/gateway exposure, workload identity, data boundary, observability, release assurance, rollback, service operation, and API/catalog considerations. | |
| Microsoft 365 Copilot extensibility / declarative agent | | Agent definition, instructions, knowledge sources, capabilities/actions, consequential-action marking, app metadata, admin distribution, testing, and publication considerations. | |
| Workflow automation with AI capability | | Workflow owner, trigger, action boundary, connector/data policy, human confirmation, exception route, audit trail, support, and change-owner considerations. | |
| Research/prototype with no operational admission | | Isolation boundary, excluded users/data/actions, expiry date, learning goals, evidence owner, and reclassification trigger. | |

## Recommended path

| Field | Record |
|---|---|
| Recommended Microsoft implementation path | |
| Confidence: high / medium / low | |
| Key assumptions | |
| Rejected alternatives and why | |
| Customer decision owner | |
| Non-production lifecycle activity authorized now | |
| Production approval boundary | |

## Selected-path configuration backlog

Complete a lightweight row for every plausible path and deepen the rows for the
selected path. For Microsoft Foundry Agent Service, use the example rows below.

| Backlog area | Applies / N/A / unknown | Decision or required configuration | Evidence reference or gap | Owner | Follow-up customer process |
|---|---|---|---|---|---|
| Foundry project, subscription/resource boundary, environment, and owner | | | | | |
| Agent type: prompt agent, hosted agent, or external agent using the Responses API | | | | | |
| Model deployment or model-access path and model-operation owner | | | | | Customer model-governance process |
| Instructions, prompt asset, hosted-agent code package, or package review | | | | | Customer SDLC |
| Tools, connected data, connectors, functions, APIs, and prohibited tools | | | | | Customer data, tool, and runtime-control processes |
| Entra identity, RBAC, managed identity, service principal, OBO, or agent identity consideration | | | | | Customer identity process |
| Content safety, prompt shield, gateway policy, human-control, or prohibited-action boundary | | | | | Customer security process |
| Tracing, logs, metrics, Application Insights/OpenTelemetry, or Foundry observability evidence | | | | | Customer platform-operations process |
| Evaluation target, dataset owner, threshold, scorecard, and release-assurance route | | | | | Customer evaluation process |
| Red-team authorization, scope, remediation route, and retest expectation | | | | | Customer security-testing process |
| Agent/catalog/lifecycle record, review cadence, and retirement owner | | | | | Customer service-management process |
| Customer change process, rollback owner, production-approval boundary, and post-release verification | | | | | Customer change authority |

## Cross-cutting governance-service applicability

Mandatory consideration does not mean mandatory deployment. Record why each
surface applies, does not apply, is unknown, or needs a follow-up customer action.

| Governance surface | Applies / does not apply / unknown / follow-up | Decision, rationale, and owner | Evidence reference or next step |
|---|---|---|---|
| Entra identity, RBAC, workload identity, and Agent ID | | | |
| Purview or other data-governance boundary | | | |
| Azure Monitor, Application Insights, OpenTelemetry, or platform telemetry | | | |
| Foundry evaluation and observability | | | |
| Content Safety, prompt shields, gateway policy, or runtime controls | | | |
| Power Platform Managed Environments, DLP, connectors, solutions, ALM, and monitoring | | | |
| Microsoft 365 Copilot extensibility governance | | | |
| Agent 365, API Center, catalog, lifecycle, or registry surfaces | | | |
| Customer architecture, security, risk, change, and production-release processes | | | |

## Ownership and evidence references

| Accountability | Named owner | Approved record reference |
|---|---|---|
| Purpose | | |
| Engineering | | |
| Service operation and retirement | | |
| Governance decision | | |
| Evidence and retention | | |
| Risk or control obligation | | |
| Product-path recommendation | | |
| Selected-path backlog | | |

## Admission and test expectations

| Requirement or test | Status: planned / observed / passed / failed / N/A / blocked | Evidence reference, limit, and owner |
|---|---|---|
| Purpose and classification reviewed | | |
| Authority boundary and exclusions reviewed | | |
| Microsoft implementation path and rejected alternatives reviewed | | |
| Selected-path backlog owner and routing confirmed | | |
| Cross-cutting governance-service applicability reviewed | | |
| Representative scenario evidence | | |
| Boundary, negative, or denied-action evidence | | |
| Dependency failure, escalation, or recovery evidence | | |
| Human-control evidence, if applicable | | |
| Access or action-limit evidence, if applicable | | |

## Decision and next actions

| Field | Record |
|---|---|
| Decision: admit / defer / reject / return | |
| Permitted next lifecycle stage | |
| Conditions, gaps, and dependencies | |
| Decision owner and approver | |
| Next review | |
| Material-change triggers | |
| Follow-up owner and customer process | |
| Retirement trigger and accountable owner | |
