# S9 · Control-Plane Reconciliation & Lifecycle

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Validate Agent 365, Entra Agent ID, API Center, API Management, Foundry, Monitor, Defender/Sentinel, and customer catalog coverage before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Catalog steward</span> <span class="rvas-badge rvas-persona">Service owner</span>

!!! abstract "What is at stake"
    Governance breaks down when agent, identity, tool, and lifecycle records
    disagree or no owner is responsible for reconciling them.

## 1. Reconcile the control plane

Reconcile one bounded agent/tool population. Establish which records exist, which
source owns each field, which explicit identifiers join them, which lifecycle
state applies, which gaps remain, and who closes them.

Work through these checks:

- Open the customer registry or CMDB record and capture the workload reference,
  owner, lifecycle state, support contact, expected API/model route, evidence
  owner, and next review.
- Open Agent 365 or the Microsoft 365 agent inventory where available:
  `admin.microsoft.com` -> **Copilot** -> **Agents & connectors** -> **All
  agents**. Check agent owner, channel, lifecycle state, and linked identity. If
  the source is unavailable, record the coverage limit instead of inventing a
  registry value.
- Open Microsoft Entra admin center. Inspect the Agent ID, managed identity,
  service principal, app registration, sponsor, enabled state, credential or
  federation review, and resource assignments.
- Open Azure API Center and API Management. Check API/version/operation,
  schema, product/backend/route, owner, policy boundary, and lifecycle state.
- Open Microsoft Foundry. Check project, app/agent, model deployment alias,
  evaluation/run reference, and telemetry link.
- Open Azure Monitor/Application Insights/Log Analytics. Check correlation key,
  query owner, alert owner, retention, and workbook/dashboard route.
- Open Defender for Cloud and Sentinel/SOC handoff where used. Check posture,
  alert/incident route, SOC owner, and accepted no-result scope.
- Compare explicit IDs for one workload across all sources. Route mismatches as
  matching owner, orphaned identity, uncataloged API, unmonitored deployment,
  stale lifecycle state, missing telemetry, duplicate record, unsupported
  source, or validated no-gap.

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

## 3. Make the records agree

Agent governance breaks when the catalog, identity, tool/API, model, data, telemetry, and lifecycle records disagree. S9 makes those gaps visible without guessing.

Names, dashboards, screenshots, and exports can support the record, but they do not become truth by themselves. Join keys are evidence; names are hints. A telemetry pointer records observability coverage; it does not prove runtime control effectiveness. A retired or suspended label is not enough without closure evidence and a retained record.

Use [Technical decisions](technical.md) for registry accountability, field-level source-of-record ownership, explicit join keys, reconciliation findings, lifecycle states, and closeout with owned gaps.

## 4. Expected signals from the reconciliation

| Signal | What to verify | Action if present |
|---|---|---|
| Matching owner | Registry, Entra, API/tool, Foundry, operations, and portfolio owners match or have an accepted split. | Close that field or record the accepted split. |
| Orphaned identity | Entra identity exists without cataloged workload, sponsor, or lifecycle owner. | Route to identity owner and lifecycle steward. |
| Uncataloged API | API Center/API Management shows a callable route not in the workload record. | Route to API/tool owner. |
| Unmonitored deployment | Foundry/runtime route lacks telemetry pointer, query owner, alert owner, or retention owner. | Route to telemetry/operations owner. |
| Stale lifecycle state | Sources disagree on active, hold, suspended, deprecated, retired, or withdrawn. | Route to lifecycle and portfolio/change owner. |
| Missing telemetry | No approved correlation key, workspace, query, workbook, alert, or retention path. | Do not claim runtime evidence; create operating gap. |
| Duplicate record | Same workload appears in multiple portfolio, agent, API, or change records. | Route to catalog/portfolio steward. |

## 5. Change boundary

S9 makes no live-data query and no catalog, lifecycle, identity, policy, access, retirement, enforcement, runtime, or production change. Any correction follows the customer's separate approved implementation, rollback, verification, retention, and change process.

Operational handoff includes reconciliation findings, evidence references, owners, exceptions, cadence, and recurrence checks. Portfolio handoff includes the closeout decision, residual risk, lifecycle status, target events, and unresolved blockers.
