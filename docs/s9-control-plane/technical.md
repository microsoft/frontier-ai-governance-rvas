# S9 · Control-Plane Reconciliation & Lifecycle: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-29 · Agent 365, Microsoft Entra Agent ID, Azure API Center, Foundry records, API Management, and platform telemetry vary by tenant, region, license, workload, and feature maturity. Verify official docs and customer coverage before delivery.

## Microsoft default

Default to Agent 365 where available for supported agent records, Microsoft Entra Agent ID or workload identity for identity records, Azure API Center and API Management/gateway for APIs/tools/routes, Foundry project records for Foundry agents/models/evaluations, and Azure Monitor/Application Insights for telemetry pointers. Use a customer register to join fields that no single product owns.

## Workshop decision route

1. **Choose a bounded population.** Select one pilot, agent group, API/tool dependency set, Foundry project, or portfolio slice.
2. **Build the registry population card.** Record scope, included/excluded records, steward, evidence owner, approved records location, cadence, and closure owner.
3. **Define canonical fields.** Capture agent/workload, identity, tool/API/action, model/deployment, data source, telemetry, lifecycle, exception, and closure fields.
4. **Declare source-of-record and join rules.** Assign field-level authority, explicit join keys, conflict rule, coverage limit, and owner.
5. **Reconcile records.** Compare explicit identifiers across identity, catalog, tool/API, model, data, telemetry, owner, exception, and lifecycle records.
6. **Classify findings.** Record missing owner, stale version, orphan identity, uncataloged tool/API, route mismatch, telemetry gap, lifecycle conflict, exception aging, missing cadence, unsupported coverage, or other.
7. **Apply lifecycle and material-change rules.** Confirm current state, permitted transition, review reference, material-change triggers, closure route, recurrence check, and reopen trigger.
8. **Decide closeout.** Close, close with owned gaps, defer, reject, route, or block.

## Registry population card

| Field | Required record |
|---|---|
| Population reference | Pilot, agent group, project, API/tool set, or portfolio slice under review. |
| Scope question | The reconciliation or closeout question being answered. |
| Included records | Agents/workloads, identities, tools/APIs/actions, models, data sources, telemetry pointers, lifecycle records. |
| Excluded records | Out-of-scope dependencies, unsupported field families, or records assigned to another steward. |
| Environment and lifecycle boundary | Non-production, pilot, production-like, active, suspended, retired, or mixed boundary. |
| Steward and evidence owner | Owner of registry quality and owner of evidence retention/reference handling. |
| Approved records location | Customer system that holds exports, object IDs, telemetry, change records, and closure evidence. |
| Review cadence | Recurrence rule, next review date, and trigger for earlier review. |

## Canonical registry field catalog

No single Microsoft product owns every field. Use a federated register when the estate spans Agent 365, Entra Agent ID, Foundry, API Center, gateway, telemetry, and customer lifecycle records.

| Entity | Minimum fields |
|---|---|
| Agent/workload | Registry ID, display name, purpose, implementation path, environment, lifecycle state, accountable owner, technical owner, support owner, risk tier, exception status, evidence reference. |
| Identity | Agent ID, workload identity, managed identity, service principal, or app registration reference; sponsor; authority mode; disabled/retired state; resource-authorization owner; identity review reference. |
| Tool/API/action | Tool ID, API Center/API Management/MCP/tool publication reference, schema version, parent/consumer agent, gateway route, owner, lifecycle state, tool/API review reference. |
| Model/deployment | Model family, deployment alias, region/residency, quota owner, evaluation baseline, fallback, evaluation/LLMOps review reference. |
| Data source | Source reference, classification, permission boundary, minimization point, data owner, data review reference. |
| Telemetry | Trace/correlation field, Application Insights/Monitor/gateway reference, alert owner, query owner, retention owner, operating review reference. |
| Lifecycle | Current state, prior state, transition owner, review reference, effective date, material-change trigger, exception expiry, retirement evidence route, next review date. |
| Closeout | Decision owner, residual-risk disposition, validation reference, recurrence check, retained-record location, receiving owner, reopen trigger. |

## Source-of-record join package

| Field family | Preferred source | Join key | Conflict rule |
|---|---|---|---|
| Agent lifecycle | Agent 365 where available, otherwise customer register or Foundry record | Explicit registry ID or platform object ID | Preserve disagreement; route unresolved state to steward. |
| Identity | Entra Agent ID, managed identity, service principal, app registration, or workload identity record | Object ID, application ID, agent identity ID, or workload identity ID | Identity source wins for lifecycle and disable state; catalog wins only for ownership intent. |
| Tools/APIs | Azure API Center, API Management, MCP/tool publication record | API ID, product/route ID, tool schema ID, operation ID | Tool/API catalog wins for schema and lifecycle; agent catalog records consumer relationship. |
| Foundry assets | Foundry project/agent/model/evaluation references | Project, agent, model deployment, evaluation, or trace reference | Foundry wins for engineering state; registry records safe references and limits. |
| Data sources | Data catalog, retrieval configuration, source-owner record | Source ID, index ID, collection ID, or customer record reference | Data owner wins for classification and permission boundary. |
| Telemetry | Azure Monitor, Application Insights, gateway logs, approved operations view | Trace/operation ID, gateway request ID, configured correlation key | Telemetry proves observation route only; it does not set lifecycle state. |
| Customer governance | Approved GRC/CMDB/register/change record | Customer record reference | Governing forum owns residual risk, exception, and closeout decision. |

## Lifecycle state machine

Use these states consistently so portfolio and operations teams can reason about drift and closure.

| State | Meaning | Allowed next states |
|---|---|---|
| `proposed` | Candidate is recorded but not admitted. | `active_review`, `withdrawn` |
| `active_review` | Review is underway and blockers are owned. | `publish_ready`, `hold`, `withdrawn` |
| `publish_ready` | Required handoffs are complete for the scoped release decision. | `published`, `hold` |
| `published` | Intended use is accepted by the customer process. | `suspended`, `deprecated`, `active_review` |
| `hold` | Decision is paused pending owner, evidence, or risk resolution. | `active_review`, `withdrawn` |
| `suspended` | Use should stop while review or remediation occurs. | `active_review`, `deprecated`, `retired` |
| `deprecated` | Replacement/removal is planned; limited use may continue under owner. | `retired`, `active_review` |
| `retired` | Intended use ended; record remains for accountability. | none except correction by steward |
| `withdrawn` | Candidate will not proceed. | none except resubmission as new proposal |

## Material-change triggers

| Trigger | Why it reopens review |
|---|---|
| Owner or steward change | Accountability, support, and exception authority may change. |
| Identity or authority change | Permissions, disabled state, sponsorship, or authorization boundary may change. |
| Tool/API schema or route change | Callable capability, side effect, gateway path, or consumer relationship may change. |
| Model deployment or alias change | Behavior, quota, residency, fallback, and evaluation baseline may change. |
| Data source or classification change | Permission boundary, minimization, data owner, or retrieval exposure may change. |
| Telemetry pointer change | Observability coverage, query owner, retention, or alert route may change. |
| Risk tier or exception status change | Review depth, expiry, and portfolio reporting may change. |
| Lifecycle state change | Transition evidence, closure route, and recurrence check must be updated. |
| Operating scope change | Population, environment, user group, or production-impact boundary may change. |

## Reconciliation finding record

Use this shape for customer-owned decision notes that reference source systems. Do not store exports, tenant IDs, object IDs, telemetry payloads, or live configuration in this repository.

```json
{
  "findingType": "route_mismatch",
  "affectedRef": "registry-or-safe-reference-placeholder",
  "sourceSystems": ["catalog-reference", "gateway-reference"],
  "joinKey": "explicit-join-key-reference",
  "conflictRule": "customer-recorded-rule-placeholder",
  "lifecycleImpact": "hold-until-resolved",
  "owner": "steward-placeholder",
  "targetDate": "customer-date",
  "validationReference": "customer-approved-reference",
  "recurrenceCheck": "next-review-trigger-placeholder",
  "route": "api-tool-owner"
}
```

## Reconciliation rules

| Finding | Rule | Route |
|---|---|---|
| Missing owner/steward | Lifecycle cannot close without a named owner. | Steward backlog; portfolio governance if portfolio-level ownership is unclear. |
| Stale version | Version, model alias, tool schema, data-source reference, or telemetry pointer is older than the recorded review. | Material-change review and model, tool/API, data, or telemetry owner as applicable. |
| Orphan identity | Entra/workload identity exists without cataloged agent, sponsor, or owner. | Identity owner and lifecycle steward; consider suspension/retirement route. |
| Uncataloged API/tool | Gateway/API Center shows callable capability missing from agent registry. | Publication route and relationship update. |
| Route mismatch | Agent record, gateway route, API catalog, or telemetry route disagree. | Preserve conflict and assign resolver; do not pick by name similarity. |
| Telemetry gap | Cataloged item has no trace/correlation, query owner, alert owner, retention owner, or review cadence. | Operating backlog; do not claim runtime proof. |
| Lifecycle conflict | One source says active while another says suspended, deprecated, retired, or withdrawn. | Decision owner resolves with evidence reference and effective date. |
| Exception aging | Exception is expired or lacks next review. | Exception owner or portfolio governance escalation. |
| Unsupported coverage | A required field family has no approved source for the bounded population. | Document coverage limit, owner, alternate route, and review trigger. |

## Closeout with owned gaps

| Field | Required for closeout with gaps |
|---|---|
| Gap reference | Finding type, affected record, source systems, and safe evidence reference. |
| Owner | Named accountable owner, not a team alias. |
| Acceptance test | What proves the gap is closed or accepted. |
| Target date | Date or milestone accepted by the receiving owner. |
| Validation reference | Customer-owned reference that will verify closure. |
| Recurrence check | When the gap is rechecked or reopened. |
| Exception route | Residual risk owner, expiry, compensating control, and review trigger if accepted. |
| Portfolio/reporting impact | Whether the gap affects portfolio, release/change, operations, legal/risk, or backlog reporting. |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Agent identity/lifecycle | Agent 365 record where available, Entra Agent ID, sponsor, lifecycle owner. |
| API/tool catalog | Azure API Center entry, API Management product/backend/route, MCP/tool publication record. |
| Foundry engineering state | Foundry project, agent, model deployment, evaluation, trace references. |
| Reconciliation evidence | Approved export/report reference, Azure Monitor/Application Insights telemetry pointer, drift review ticket. |
| Lifecycle closure | Material-change record, version/deprecation notice, retirement validation, retained-record location. |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Registry population | bounded population, included/excluded records, steward, evidence owner, approved records location, and cadence are recorded. | Control-plane steward |
| Catalog authority | each required field has one source of record, join key, steward, coverage limit, and conflict rule. | Catalog steward |
| Reconciliation | findings, cadence, evidence source, reviewer, conflict rule, exception path, and next review date are recorded. | Control-plane owner |
| Material change | triggers cover authority, tools, data, model, telemetry, owner, operating scope, risk tier, and evaluation/red-team asset changes. | Lifecycle owner |
| Retirement | suspended/retired entries have closure owner, validation reference, retained record, recurrence check, and reopen trigger. | Portfolio/catalog owner |
| Closeout with gaps | every gap has owner, acceptance test, evidence reference, target date, recurrence check, and next review trigger. | Receiving owner |

## Boundary note

S9 records and reconciles control-plane state. Customer stewards implement catalog, identity, access, telemetry, lifecycle, or platform changes in their own approved processes.

## Related references

- [S9 Concepts](concepts.md): registry accountability, join keys, lifecycle trail, reconciliation, and closeout accountability.
- [Identity technical decisions](../s1-identity/technical.md), [tool/API governance technical decisions](../s5-tool-api-governance/technical.md), and [operate/measure technical decisions](../s11-operate-measure/technical.md).
- [Governance capability guide](../reference/governance-capability-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
