# S4 · Agent Build Path & Admission

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Engineering owner</span> <span class="rvas-badge rvas-persona">Service owner</span>

!!! abstract "What is at stake"
    Teams need a shared bar for admitting an agent or material change before it
    reaches customers, data, tools, or production processes.

## 1. Choose and test the engineering path

Compare the Microsoft build paths for one bounded agent candidate, then inspect
the selected route deeply enough to know whether engineering can actually build
and govern it. S4 should leave the customer with a selected path, rejected
alternatives, a safe boundary test, and the backlog needed before the next
controlled stage.

Work through these checks:

- An **agent candidate card** for one bounded scenario: purpose, users,
  authority, action boundary, human-control point, data/tool dependencies,
  channel, environment, lifecycle state, and stop condition.
- An **authority/action inventory**: inform, draft, recommend,
  act-with-approval, autonomous, coordinating, or blocked; allowed actions,
  prohibited actions, approval point, exception path, fallback, rollback owner,
  and material-change triggers.
- A **build-path comparison** across Copilot Studio, Microsoft Foundry Agent
  Service, Microsoft 365 Copilot extensibility, custom Azure app, workflow
  automation, and prototype-only.
- A selected Microsoft implementation path, with confidence, assumptions, and
  alternatives the customer rejected or deferred.
- A route-specific inspection for the selected path:
  - **Foundry Agent Service:** Foundry project, agent, instructions/hosted-code
    reference, model deployment, tool, connected data, identity/RBAC, trace,
    evaluation, safety settings, lifecycle owner.
  - **Copilot Studio:** environment, solution, agent/topic/action, connector,
    DLP policy, authentication, publication channel, audit/monitoring, maker and
    admin owner.
  - **Microsoft 365 extensibility:** app/agent metadata, declarative
    instructions, knowledge source, action/plugin, Graph permission, admin
    review, distribution route.
  - **Custom Azure app:** repository/release reference, model/API backend,
    gateway route, managed identity/federation, telemetry, IaC/release path,
    rollback and support owner.
  - **Workflow automation:** trigger, deterministic steps, connector policy,
    approval point, run history, exception route, retirement owner.
- A safe boundary check for the selected route: verify one non-production
  tool/data call boundary or inspect an existing trace without changing product
  configuration.
- A configuration backlog for the selected path, including owners and the
  customer process that will handle each item.
- A review of governance services that may apply, such as Entra, Purview,
  Foundry, telemetry, Content Safety, gateway policy, and catalog records.
- Admission requirements, DEV/PRE/PRO gate criteria, and test expectations that
  match the agent's authority.
- Model, latency, cost, quota, fallback, and fine-tuning ownership where
  applicable.
- A decision to admit the candidate to the next controlled stage, defer it,
  reject it as non-agent or unsafe, route it, block it, or mark it
  prototype-only.
- Material-change and retirement triggers.

The customer keeps the agreed implementation details in its approved records
system. `labs/s4-agent-engineering/` provides blank offline templates and the
runbook. Keep customer code, data, credentials, integration settings,
deployment steps, or production approval.

### Plain decision

**Question:** **Can this candidate enter the next controlled engineering stage
on a named Microsoft build path with inspectable instructions, model route,
tool/data boundary, identity path, telemetry hook, evaluation hook, and
rollback owner?** Default to the Microsoft path that best fits the candidate.
An exception must document the capability, data, authority, support, and
operating reason plus owner, evidence reference, acceptance criterion, and
target event. S4 selects and admits a path; it does not create code, configure a
product, change a system, run production behavior, or approve production.

### What happens next

**Next customer action:** route the selected admission requirements and
implementation path to the customer's engineering, security, architecture, and
release owners.

In this session, the customer decides whether one bounded agent can move to its
next non-production stage. The decision defines the agent's permitted authority,
the selected Microsoft implementation path, the implementation details engineering
must own, the safe boundary check to run or inspect, the evidence still needed,
and the owner of each follow-up item. For a Foundry path, the output is a
Foundry Agent Service implementation backlog, not a live deployment. See
[Microsoft Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/agents/overview).

Before the agent is released or changed in a way that affects this decision, the
customer must review the recorded requirements again. Architecture, engineering,
security, change, release, and production approval remain customer processes.

## 2. Prerequisites

- One bounded candidate described in business and engineering terms.
- A governance lead who can decide, defer, or reject admission.
- A named engineering owner and service owner.
- An approved place to store evidence references and decisions.
- Existing risk, architecture, security, and change processes available by
  reference when they apply.

You do not need source code, a live integration, endpoint access, tenant changes,
or a production environment. You may use product documentation to decide the path
and backlog. Deployment steps stay in the customer's delivery process.

## 3. Set the bar before an agent changes

Admission needs a named owner, clear purpose and authority boundary, and a
reviewable Microsoft path. The practical question is not "which product do we
like?" It is:

1. What can the agent do?
2. Which actions are allowed, denied, or require human approval?
3. Which Microsoft path fits the channel, orchestration, data, tool, lifecycle,
   and operating model?
4. What must engineering own and verify for that path?
5. Which model, latency, cost, quota, evaluation, runtime, catalog, and release
   owners must accept the next step?

S4 selects the build route, exclusions, implementation backlog, gate plan, and
material-change reapproval triggers.

### Expected result states

| Result | Use when | Next action |
|---|---|---|
| Buildable route | Selected product path has owner, environment/project, identity, model, tool/data boundary, telemetry, evaluation, and rollback route. | Move to the next customer engineering stage. |
| Buildable with backlog | Path fits, but one or more required controls are missing. | Assign the backlog item and recheck before PRE/PRO. |
| Wrong path | A different Microsoft path better fits the authority, channel, data, or lifecycle need. | Route to the alternate product owner. |
| Unsupported route | Required tenant, region, SKU, feature, identity, connector, or control is unavailable. | Defer or redesign before engineering starts. |
| Unsafe authority | Action boundary, approval point, or rollback path cannot be made reviewable. | Block until authority is redesigned. |
| Prototype-only | Learning can continue only in an isolated sandbox. | Add expiry, excluded data/actions/users, and promotion stop. |

Use [Technical decisions](technical.md) for the authority model, Microsoft path
choices, selected-path package fields, material changes, and retirement.

## 4. Change boundary

S4 creates no code, configuration, connection, access grant, publication, or
production lifecycle transition. Engineering, integration, change, rollback,
verification, and production approval follow the customer's approved processes.
