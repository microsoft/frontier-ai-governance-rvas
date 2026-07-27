# S4 Agent Engineering Runbook

Use this runbook to guide the required lab path. The customer inspects its own Microsoft records, records safe references in its approved system, and decides whether the scoped agent engineering path is ready for owner handoff.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry gate

Confirm the customer has a bounded workload or portfolio slice, a decision owner, a product owner, an engineering owner, a model/cost owner, a release owner, an evidence owner, downstream receiving owners, and an approved records location. If any are missing, stop the decision and create a blocker backlog item.

## Required review flow

1. **Define the scenario and desired outcome.** Record the capability, channel, user group, data/tool dependency, expected action, and receiving owner.
2. **Set authority level.** Choose `inform`, `draft`, `recommend`, `act-with-approval`, `autonomous`, or `blocked`. Record the human approval point, exception path, fallback, and stop condition.
3. **Classify the route.** Choose the smallest accurate route:
   - `copilot-studio`: low-code/business-owned assistant with environment, maker/admin, connector, handoff, and ALM owners;
   - `foundry-agent`: engineered orchestration, model/tool lifecycle, evaluation hooks, telemetry, and DEV/PRE/PRO gates;
   - `m365-extension`: Microsoft 365 channel, app permission, identity, data boundary, app review, and consumer experience owner;
   - `custom-app`: custom UX/backend/orchestration needing S3 platform, S5 tool/API, S6 runtime, S7 evaluation, and S9 catalog handoffs;
   - `workflow-not-agent`: deterministic workflow or automation is sufficient;
   - `prototype-only`: exploration can continue, but promotion is blocked.
4. **Record route rationale.** Compare channel fit, orchestration need, data/tool boundary, lifecycle owner, model ownership, expected latency/cost, observability, and support assumptions. If rationale is not clear, defer.
5. **Check admission criteria.** Confirm owner, approved records location, route, authority, required tools, required data, human handoff, exception path, model owner, cost owner, latency owner, and downstream owners.
6. **Check DEV/PRE/PRO promotion flow.** For DEV, PRE, and PRO separately, record gate owner, gate purpose, evidence reference, blocker rule, and receiving process. S4 records criteria only; it does not deploy or approve production.
7. **Confirm model, latency, and cost ownership.** Record model-selection owner, quota/cost budget owner, latency target, fallback behavior, review cadence, and unresolved constraints.
8. **Route tool/API dependencies.** If the agent uses a tool, API, connector, action, or allow-list, route to S5 and record the S5 owner, admission state, and blocker.
9. **Set downstream prerequisites.** Record S6 runtime-assurance prerequisite, S7 evaluation evidence prerequisite, and S9 control-plane/catalog handoff. If any are missing, create a blocker rather than implying readiness.
10. **Set decision state.** Use one state:
    - `approve`: route rationale, authority, owners, evidence reference, gates, model/cost/latency ownership, acceptance test, and handoff are complete;
    - `defer`: a gap has a named owner and target date;
    - `reject`: the scoped path cannot meet the decision safely or should be workflow-not-agent;
    - `route`: another owner must decide first;
    - `blocked`: access, ownership, record location, route rationale, gate path, model/cost/latency ownership, or scope clarity prevents a decision;
    - `prototype-only`: exploration may continue but promotion is blocked.
11. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, release/backlog impact, and next review trigger.
12. **Handoff.** Send the completed decision record and backlog references to agent engineering, product, release, model/cost, platform, tool/API, runtime, evaluation, and control-plane/catalog owners as applicable.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `record-location-missing`, `route-rationale-incomplete`, `authority-level-unclear`, `human-handoff-missing`, `dev-gate-missing`, `pre-gate-missing`, `pro-gate-missing`, `model-owner-missing`, `latency-budget-missing`, `cost-owner-missing`, `tool-api-s5-missing`, `platform-s3-missing`, `runtime-s6-missing`, `evaluation-s7-missing`, `catalog-s9-missing`, `unsupported-channel-or-route`, `workflow-not-agent`, `prototype-only`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes the route rationale, authority level, human handoff, DEV/PRE/PRO gates, model/latency/cost ownership, S5/S6/S7/S9 handoffs, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
