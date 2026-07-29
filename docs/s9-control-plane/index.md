# S9 · Control Plane, Catalog & Lifecycle

!!! info "Freshness"
    Last reviewed: 2026-07-29 · Validate Agent 365, Entra Agent ID, API Center, Foundry, Monitor, and customer catalog coverage before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Catalog steward</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer has a **control-plane reconciliation package** for one bounded agent/tool population. The package shows which records exist, which source owns each field, which explicit identifiers join records, which lifecycle state applies, which gaps remain, and who closes them.

They leave with:

- A **registry population card** for the bounded population: scope question, included/excluded agents, tools/APIs, identities, models, data sources, telemetry pointers, lifecycle records, steward, evidence owner, approved records location, and review cadence.
- A **canonical registry package** covering agent/workload, identity, tool/API/action, model/deployment, data source, telemetry, lifecycle, exception, and closure fields.
- A **source-of-record join map** for Agent 365 where available, Entra Agent ID or workload identity, Foundry, API Center, API Management/gateway, Azure Monitor/Application Insights, customer register, and lifecycle/change records.
- A **reconciliation findings package** for missing owner, stale version, orphan identity, uncataloged tool/API, route mismatch, telemetry gap, lifecycle conflict, exception aging, missing review cadence, unsupported field coverage, or other gaps.
- A **lifecycle and material-change package** with state, transition owner, review reference, material-change triggers, closure route, retained-record location, recurrence check, and reopen trigger.
- A **closeout and backlog decision**: close, close with owned gaps, defer, reject, route, or block, with every open item assigned to a receiving owner.

`labs/s9-control-plane/` provides the facilitator runbook and decision-record template. Customer exports, tenant identifiers, object IDs, raw telemetry, live configuration, secrets, endpoint details, retirement evidence, and production records stay in approved customer systems. This repository stores safe references and field shapes only.

### What happens next

**Next customer action:** assign every open catalog, identity, tool/API, telemetry, lifecycle, exception, or closeout gap to its steward and set the next review before closing the population.

### Plain decision and default path

**Decision question:** *Can this bounded agent/tool population be represented in a customer-owned control-plane registry with explicit source-of-record ownership, stable join keys, lifecycle state, material-change rules, reconciliation findings, owners, and closure criteria?*

The default is an authoritative Azure/Microsoft-backed control-plane view: Agent 365 where available for agent records, Microsoft Entra Agent ID or workload identity for identity references, Azure API Center and API Management/gateway for APIs/tools/routes, Microsoft Foundry for supported agent/model/evaluation engineering records, and Azure Monitor/Application Insights for telemetry pointers. Use an existing customer register, GRC, or CMDB only when field ownership, coverage, identifiers, lifecycle rules, conflict handling, and reconciliation cadence are explicit.

S9 produces a registry reconciliation backlog for customer-owned work. It does not approve a lifecycle change, production change, access change, or runtime-control claim. The recommendation says whether to close, close with owned gaps, defer, reject, route, or block. Receiving owners can include identity, API/tool, platform/Foundry, telemetry/operations, lifecycle/catalog, portfolio, release/change, legal/risk, or accepted-risk authority.

## 2. Prerequisites

- A bounded population: one pilot, agent group, API/tool dependency set, Foundry project, or portfolio slice.
- A customer-normalized agent/tool registry using `rvas.s9.control-plane-registry.v1` or an equivalent customer-owned shape.
- Explicit identifiers for the records to reconcile: registry IDs, object IDs, application IDs, agent identity IDs, API IDs, route IDs, tool schema IDs, Foundry references, deployment aliases, telemetry correlation keys, or customer record references.
- A governance lead, control-plane steward, evidence owner, finding owners, lifecycle owner, and approved records location.
- Current customer policy for lifecycle states, material changes, exceptions, retirement, recurrence checks, and closeout with gaps.

## 3. Why this session matters

Agent governance breaks when the catalog, identity, tool/API, model, data, telemetry, and lifecycle records disagree. S9 makes those gaps visible without guessing.

Names, dashboards, screenshots, and exports can support the record, but they do not become truth by themselves. Join keys are evidence; names are hints. A telemetry pointer records observability coverage; it does not prove runtime control effectiveness. A retired or suspended label is not enough without closure evidence and a retained record.

Read the [S9 Concepts](concepts.md) for registry accountability, field-level source-of-record ownership, explicit join keys, reconciliation findings, lifecycle states, and closeout with owned gaps.

## 4. Change boundary

S9 makes no live-data query and no catalog, lifecycle, identity, policy, access, retirement, enforcement, runtime, or production change. Any correction follows the customer's separate approved implementation, rollback, verification, retention, and change process.

Operational handoff includes reconciliation findings, evidence references, owners, exceptions, cadence, and recurrence checks. Portfolio handoff includes the closeout decision, residual risk, lifecycle status, target dates, and unresolved blockers.
