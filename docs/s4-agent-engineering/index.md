# S4 · Agent Build Path & Admission

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Engineering owner</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & what the customer keeps

The customer answers one question:
**which Microsoft build path fits this bounded agent candidate, and what package
must engineering own before it moves to the next controlled stage?**

They leave with:

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
- A concrete **agent package record** for the selected path: instruction or
  workflow reference, model route, tool/API/connector list, data sources,
  identity mode, runtime controls, evaluation plan, telemetry route, release and
  rollback owner, lifecycle state, and support boundary.
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

The customer keeps the implementation decision package in its approved records
system. `labs/s4-agent-engineering/` provides blank offline templates and the
runbook. Keep customer code, data, credentials, integration settings,
deployment steps, or production approval.

### Plain decision

**Question:** **Can this candidate enter the next controlled engineering stage
on a named Microsoft build path with a complete agent package?** Default to the
Microsoft path that best fits the candidate. An exception must document the
capability, data, authority, support, and operating reason plus owner, evidence
reference, acceptance criterion, and target event. S4 selects and admits a path;
it does not create code, configure a product, change a system, test runtime
behavior, or approve production.

### What happens next

**Next customer action:** route the selected admission requirements and
implementation path to the customer's engineering, security, architecture, and
release owners.

In this session, the customer decides whether one bounded agent can move to its
next non-production stage. The decision artifacts the agent's permitted authority,
the selected Microsoft implementation path, the package fields engineering must
own, the evidence still needed, and the owner of each follow-up item. For a
Foundry path, the output is a Foundry Agent Service package backlog, not a live
deployment. See [Microsoft Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/agents/overview).

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

## 3. Why this session matters

Admission needs a named owner, clear purpose and authority boundary, and a
reviewable Microsoft path. The practical question is not "which product do we
like?" It is:

1. What can the agent do?
2. Which actions are allowed, denied, or require human approval?
3. Which Microsoft path fits the channel, orchestration, data, tool, lifecycle,
   and operating model?
4. What package does engineering need to own for that path?
5. Which model, latency, cost, quota, evaluation, runtime, catalog, and release
   owners must accept the next step?

S4 records the build route, exclusions, package backlog, gate plan, and
material-change reapproval triggers.

Use [Technical decisions](technical.md) for the authority model, Microsoft path
choices, selected-path package fields, material changes, and retirement.

## 4. Change boundary

S4 creates no code, configuration, connection, access grant, publication, or
production lifecycle transition. Engineering, integration, change, rollback,
verification, and production approval follow the customer's approved processes.
