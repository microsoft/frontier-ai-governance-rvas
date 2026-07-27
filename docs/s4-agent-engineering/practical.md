# Practical workshop: scenario-driven agent engineering path

**Microsoft default:** Copilot Studio, Microsoft Foundry Agent Service, Microsoft 365 Copilot extensibility, or a custom Azure app path.

**Customer decision:** Approve, defer, reject, route, or mark prototype-only for the scoped agent engineering path. This is a design, admission, and handoff decision only; it is not a deployment, runtime-proof, live-policy change, or production approval.

## Work the decision

1. **Choose the agent scenario.** Select one bounded pilot, backlog item, or capability slice. Name the product owner, engineering owner, model/cost owner, release owner, evidence owner, and customer-approved records location.
2. **Define authority and autonomy.** Record whether the agent informs, drafts, recommends, acts with human approval, or acts autonomously. Defer any scenario that cannot name the human handoff, approval point, rollback path, or owner for agent action.
3. **Classify the build route before discussing tooling.** Use the route table below to choose the smallest Microsoft-aligned engineering path that fits the channel, orchestration, data, tool, lifecycle, and governance needs.

| Scenario | Route | Practical decision cue |
|---|---|---|
| Business-user authored assistant, constrained process, low-code lifecycle | Copilot Studio | Approve only when environment, maker/admin ownership, connector use, handoff, and ALM/promotion path are recorded. |
| Multi-step agent requiring model/tool orchestration, evaluation hooks, or engineering lifecycle | Foundry Agent | Approve only when model choice, evaluation handoff, tool boundary, telemetry expectation, and DEV/PRE/PRO gate owner are named. |
| Assistant embedded in Microsoft 365 work patterns | M365 extension | Route through the M365 extensibility owner when channel, identity, data boundary, app permission, review process, and consumer experience are recorded. |
| Custom UX, custom backend, bespoke orchestration, or nonstandard integration | Custom app | Defer until platform boundary, API/tool governance, identity, gateway, telemetry, and release owners are named. Route S3/S5/S6/S7/S9 prerequisites explicitly. |
| Deterministic workflow or automation without agentic reasoning | Workflow-not-agent | Reject the agent route and route to workflow, app, or automation owner when fixed rules, approvals, or RPA are sufficient. |
| Exploration without owners, gates, or evidence location | Prototype-only | Mark prototype-only; block promotion until admission, authority, model/cost, latency, evaluation, runtime, and control-plane handoffs are complete. |

4. **Inspect the engineering path.** Record safe references for the build path, channel, data/tool dependencies, model or service boundary, human handoff, prompt/behavior ownership, lifecycle owner, and known unsupported assumptions.
   - Evidence-reference example: the customer records name the Foundry project or Copilot Studio environment, M365 app/extension route, custom app repository, owner, target environment, model/cost owner, and release gate owner.
   - Defer blocker example: the team chose a build path before confirming required tools, authority level, human handoff, model ownership, latency budget, or DEV/PRE/PRO promotion route.
5. **Run the admission and promotion flow.** Confirm the proposed path has a named owner for DEV, PRE, and PRO gates. S4 may define readiness criteria and handoff blockers, but must not claim deployment, enforcement, runtime proof, or production approval.
6. **Confirm model, latency, and cost ownership.** Record the owner of model selection, quota, latency target, cost budget, fallback behavior, and review cadence. Defer if any are unknown.
7. **Set downstream handoffs.** Record what S6 runtime assurance, S7 evaluation, and S9 control-plane/catalog owners must receive before they can act. Route S5 when tools/APIs are required and S3 when platform boundary assumptions are unresolved.
8. **Record the outcome.** Approve only when the route rationale, authority level, owners, gates, model/latency/cost ownership, accepted-when checks, defer criteria, and handoffs are complete. Otherwise defer, reject, route, block, or mark prototype-only.

## Decision record

Fill this record in the customer-approved records system. Store only safe references here; completed evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Pilot agent engineering decision |
| Route decision | Copilot Studio, Foundry Agent, M365 extension, custom app, workflow-not-agent, prototype-only, reject, or route |
| Path rationale | Why this path fits the channel, orchestration, tool, data, lifecycle, and ownership needs |
| Authority level | Inform, draft, recommend, act-with-approval, autonomous, or blocked |
| Human handoff | Approval point, exception path, receiving owner, and stop condition |
| DEV/PRE/PRO gate | Gate owner, gate purpose, evidence reference, and promotion blocker for each stage |
| Model/latency/cost owner | Model choice owner, quota/cost owner, latency target, fallback behavior, and review cadence |
| Tool/API dependency | Required S5 tool/API admission, connector, allow-list, or rejection decision |
| S6 handoff | Runtime-assurance owner, expected telemetry/correlation, action audit route, and stop condition |
| S7 handoff | Evaluation owner, scenario set, quality/safety acceptance, and unresolved evidence gap |
| S9 handoff | Catalog/control-plane owner, lifecycle state, exception/backlog reference, and retirement trigger |
| Defer criteria | Missing owner, unresolved authority, unsupported route, incomplete handoff, missing gate, model/cost/latency gap, or missing S5/S6/S7/S9 prerequisite |
| Acceptance checks | Route rationale, authority, owners, gates, model/cost/latency, handoff, exception status, target date, and backlog are complete |

## Decision tree

- **Approve engineering path** when the Microsoft path fits, customer owners and evidence references are named, DEV/PRE/PRO gates are defined, and downstream owners can act without assuming production readiness.
- **Defer** when route rationale, authority, owner, model/cost/latency, gate, evidence reference, acceptance test, or downstream prerequisite is missing. Include owner, target date, evidence location, and review trigger.
- **Reject** when the use case is better served by deterministic workflow, cannot meet bounded safety/ownership needs, or requires unsupported assumptions.
- **Route** when platform, tool/API, identity, data, runtime, evaluation, M365, release, or exception owners must decide first.
- **Prototype-only** when exploration can continue safely but cannot be promoted until admission, evidence, gates, and handoffs are complete.

For an exception, record: reason, route not used, equivalent control or compensating review, owner, evidence location, acceptance check, target date, downstream handoff impact, and review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Path rationale | the chosen route is justified against Copilot Studio, Foundry Agent, M365 extension, custom app, workflow-not-agent, and prototype-only alternatives | Product owner |
| Authority level | allowed actions, human approval point, exception path, and stop condition are explicit | Business owner |
| DEV/PRE/PRO gate | each gate has an owner, purpose, evidence reference, blocker rule, and receiving process | Release owner |
| Model/latency/cost | model selection, latency target, quota/cost owner, fallback, and review cadence are named | Model/cost owner |
| Tool/API dependency | every tool, connector, API, action, or allow-list need is routed to S5 or rejected as unsafe | Tool/API owner |
| S6 runtime handoff | expected telemetry, correlation, action audit route, reviewer, and stop condition are recorded without claiming runtime proof | Runtime assurance owner |
| S7 evaluation handoff | scenario set, evaluation owner, acceptance criteria, and evidence gap are recorded without claiming evaluation completion | Evaluation owner |
| S9 control-plane handoff | catalog/control-plane lifecycle owner, state, exception, retirement trigger, and consumer review need are recorded | Control-plane owner |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, changes no tenant policy, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Workshop facilitator |

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. This workshop changes no tenant policy, proves no runtime enforcement, and does not approve production.
