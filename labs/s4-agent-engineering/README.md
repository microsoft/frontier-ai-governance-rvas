# S4 Agent Engineering Work Package

This lab helps the customer make one bounded agent-engineering decision and hand it to the right owner. It is not a deployment, runtime-proof, live-policy change, or production-approval exercise. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository.

## Entry condition

Bring a bounded workload or portfolio slice, the decision owner, product owner, engineering owner, model/cost owner, release owner, evidence owner, receiving downstream owners, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Required records

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the route decision, authority level, evidence references, DEV/PRE/PRO gates, acceptance test, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Agent route:** Copilot Studio, Foundry Agent, Microsoft 365 extension, custom app, workflow-not-agent, prototype-only, reject, or route.
- **Route rationale:** channel, orchestration, data/tool dependency, lifecycle, ownership, and support assumptions.
- **Authority level:** inform, draft, recommend, act-with-approval, autonomous, or blocked, plus human handoff and stop condition.
- **Admission and promotion:** DEV/PRE/PRO gate owners, evidence references, promotion blockers, and receiving process.
- **Model, latency, and cost ownership:** model selection, quota/cost budget, latency target, fallback behavior, and review cadence.
- **Downstream handoffs:** tool/API dependency, runtime-assurance prerequisite, evaluation prerequisite, control-plane/catalog handoff, and any blocker.
- **Blockers and backlog:** missing owner, record location, route rationale, authority, gate, model/cost/latency owner, downstream prerequisite, or scope clarity captured with owner, target date, evidence location, acceptance test, and review trigger.

## Technical capture fields

Capture these fields in the customer-owned decision record when they apply. Use
references and placeholders only; do not store prompts, outputs, endpoints, or
live configuration in this repository.

| Area | Fields to capture |
|---|---|
| Implementation path | Selected path, rejected alternatives, environment or project reference, package/version reference, owner, lifecycle state, support boundary. |
| Agent package | Instruction/workflow/package reference, model or deployment alias, tools/actions/API versions, data sources, identity mode, telemetry route, release manifest reference, rollback owner. |
| Authority and gates | Authority archetype, human-control point, tool/runtime/evaluation/testing/catalog/operations prerequisites, blocker rule, receiving owner. |
| Material changes | Prompt/workflow, model alias, tool schema, data source, identity/RBAC, gateway route, telemetry, owner, and publication-channel change triggers. |

## Facilitation flow

1. Confirm the customer has a bounded scope, owners, and an approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system.
3. Classify the route across **Copilot Studio, Foundry Agent, Microsoft 365 extension, custom app, workflow-not-agent, and prototype-only**.
4. Ask: **Which route gives this agent the right authority, lifecycle owner, gate path, model/cost/latency owner, and downstream handoff without implying production approval?**
5. Record one result: approve, defer, reject, route, blocked, or prototype-only.
6. Create an engineering backlog item for each missing route rationale, owner, admission criterion, model-selection record, token/cost guardrail, latency budget, DEV/PRE/PRO gate, tool/API dependency, runtime prerequisite, evaluation prerequisite, catalog handoff, or retirement trigger.
7. Handoff the completed decision record and backlog references to receiving owners. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the route rationale, authority level, owners, evidence reference, DEV/PRE/PRO gates, model/cost/latency ownership, acceptance checks, and downstream handoffs are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped use case should be a deterministic workflow or cannot meet bounded safety, ownership, or lifecycle needs.
- **Route** when another Microsoft control owner, platform owner, tool/API owner, M365 owner, runtime owner, evaluation owner, control-plane owner, or exception owner must decide first.
- **Blocked** when access, ownership, record location, route rationale, gate path, model/cost/latency ownership, or scope clarity prevents a decision.
- **Prototype-only** when exploration can continue but promotion is blocked until admission, gates, evidence, and handoffs are complete.

## Handoff

Handoff to agent engineering owner, product owner, release manager, model/cost owner, platform owner, tool/API owner, runtime-assurance owner, evaluation owner, and control-plane/catalog owner as applicable. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.
