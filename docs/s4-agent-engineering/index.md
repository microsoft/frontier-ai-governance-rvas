# S4 · Agent Engineering & Admission Standards

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Engineering owner</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & what the customer keeps

The customer answers one question:
**can this agent move to the next controlled stage, and on which Microsoft path?**

They leave with:

- A classification for one bounded agent candidate and the authority it may use.
- A recommended Microsoft implementation path, with confidence, assumptions,
  and alternatives the customer rejected or deferred.
- A configuration backlog for the selected path, including owners and the
  customer process that will handle each item.
- A review of governance services that may apply, such as Entra, Purview,
  Foundry, telemetry, Content Safety, gateway policy, and catalog records.
- Admission requirements and test expectations that match the agent's authority.
- A decision to admit the candidate to the next controlled stage, defer it,
  reject it, or return it for missing evidence.
- Material-change and retirement triggers.

The customer keeps the implementation decision package in its approved records
system. `labs/s4-agent-engineering/` provides blank offline templates and the
runbook. Keep customer code, data, credentials, integration settings,
deployment steps, or production approval.

### Plain decision

**Question:** **Do we approve, defer, reject, or route this Microsoft
implementation-path and DEV-PRE-PRO admission decision?** Default to the
Microsoft path that best fits the candidate. An exception must document the
capability, data, authority, support, and operating reason plus owner, evidence
reference, acceptance criterion, and target date. S4 selects and admits a path;
it does not change a system or approve production.

### What happens next

**Next customer action:** route the selected admission requirements and
implementation path to the customer's engineering, security, architecture, and
release owners.

In this session, the customer decides whether one bounded agent can move to its
next non-production stage. The decision records the agent's permitted authority,
the Microsoft implementation path, the evidence still needed, and the owner of
each follow-up item. For a Foundry path, the output is a Foundry Agent Service
backlog, not a live deployment. See [Microsoft Foundry Agent
Service](https://learn.microsoft.com/en-us/azure/foundry/agents/overview).

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
reviewable Microsoft path. S4 records the next work, exclusions, and
material-change reapproval triggers.

Read [S4 Concepts](concepts.md) for the authority model, Microsoft path choices,
Foundry Agent Service example, evidence rules, material changes, and retirement.

## 4. Change boundary

S4 creates no code, configuration, connection, access grant, publication, or
production lifecycle transition. Engineering, integration, change, rollback,
verification, and production approval follow the customer's approved processes.
