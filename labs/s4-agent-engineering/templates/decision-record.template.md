# Decision Record

Copy this template into the customer's approved records system. Use it to record the required agent-engineering decision for S4 Agent Engineering.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Agent scenario | |
| Decision owner | |
| Product owner | |
| Engineering owner | |
| Model / latency / cost owner | |
| Release owner | |
| Evidence owner | |
| Receiving owner / process | |
| Approved records location | |
| Target date | |

## Route decision

Default paths: **Copilot Studio, Microsoft Foundry Agent Service, Microsoft 365 Copilot extensibility, custom Azure app path, workflow-not-agent, or prototype-only**

| Route field | Record |
|---|---|
| Result (approve / defer / reject / route / blocked / prototype-only) | |
| Selected route | Copilot Studio / Foundry Agent / M365 extension / custom app / workflow-not-agent / prototype-only / other route |
| Routes considered | |
| Path rationale | |
| Channel and user experience fit | |
| Orchestration requirement | |
| Data, tool, connector, or API dependency | |
| Lifecycle and support owner | |
| Unsupported or unreviewed assumption | |
| Evidence-reference location | |

## Agent candidate card

| Field | Record |
|---|---|
| Business purpose and users | |
| Channel / user experience | |
| Environment / lifecycle state | |
| Candidate owner and support boundary | |
| Stop condition | |
| Prototype isolation or promotion trigger if applicable | |

## Authority and handoff

| Field | Record |
|---|---|
| Authority level | Inform / draft / recommend / act-with-approval / autonomous / blocked |
| Allowed actions | |
| Blocked actions | |
| Tool / target / data category inventory | |
| Human approval point | |
| Exception path | |
| Fallback behavior | |
| Stop condition | |
| Rollback or fallback owner | |
| Business owner acceptance | |

## Admission and promotion flow

| Gate | Owner / evidence reference / accepted when / blocker |
|---|---|
| Admission criteria | |
| DEV gate | |
| PRE gate | |
| PRO gate | |
| Release or change process | |
| Retirement trigger | |

## Agent package record

| Field | Record |
|---|---|
| Instruction / workflow / hosted package reference | |
| Declarative manifest or solution reference if applicable | |
| Model or deployment alias | |
| Tool / API / connector list and versions | |
| Data-source references and owner | |
| Identity mode and authority owner | |
| Runtime-control or human-control route | |
| Evaluation scenario/rubric/threshold route | |
| Telemetry / correlation route | |
| Release manifest reference | |
| Rollback owner and target | |
| Material-change triggers | |

## Model, latency, and cost

| Field | Record |
|---|---|
| Model selection owner | |
| Model or service boundary | |
| Region / residency / version owner | |
| Latency target and owner | |
| Quota / cost budget owner | |
| Token/cost guardrail or review cadence | |
| Fallback behavior | |
| Fine-tuning rationale / training-data owner / base-vs-tuned comparison if applicable | |
| Known model, latency, quota, or cost gap | |

## DEV / PRE / PRO gates

| Gate field | Record |
|---|---|
| DEV purpose / accepted when / blocker | |
| PRE purpose / accepted when / blocker | |
| PRO customer-change process / out-of-scope note | |
| Gate receiving owner | |
| Rollback / decommissioning trigger | |

## Downstream prerequisites

| Handoff | Record |
|---|---|
| Platform-boundary prerequisite | |
| Identity prerequisite | |
| Data-boundary prerequisite | |
| Tool/API admission prerequisite | |
| Runtime-assurance prerequisite | |
| Evaluation evidence prerequisite | |
| Red-team readiness prerequisite | |
| Catalog/control-plane handoff | |
| Operations/support prerequisite | |
| Retirement prerequisite | |
| Stop condition before downstream reliance | |

## Customer decision

| Decision field | Record |
|---|---|
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Release or backlog impact | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default route is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Route not used | |
| Unsupported or unverified control | |
| Equivalent control or compensating review | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Downstream handoff impact | |
| Review trigger | |

## Backlog and handoff

Create an agent-engineering backlog item for each missing candidate-card field, route rationale, authority owner, action inventory, human handoff, package field, admission criterion, DEV/PRE/PRO gate, model owner, latency budget, cost owner, fine-tuning review, platform prerequisite, identity prerequisite, data prerequisite, tool/API prerequisite, runtime prerequisite, evaluation prerequisite, red-team readiness prerequisite, catalog handoff, operations owner, retirement trigger, or exception approval.

Handoff to agent engineering owner, product owner, release manager, model/cost owner, platform owner, tool/API owner, runtime-assurance owner, evaluation owner, and control-plane/catalog owner as applicable. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "choose build route for bounded service-desk assistant"; route "Foundry Agent with tool/API admission blocker"; evidence location "customer-approved route comparison, DEV/PRE gate reference, model/cost owner reference, and evaluation handoff reference"; accepted when the product, engineering, model/cost, release, tool/API, runtime, evaluation, and catalog owners accept the route and blockers without implying production approval.
