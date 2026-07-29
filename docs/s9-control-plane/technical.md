# S9 · Control Plane, Catalog & Lifecycle: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, Foundry records, and platform telemetry vary by tenant, region, license, workload, and feature maturity. Verify official docs and customer coverage before delivery.

## Microsoft default

Default to Agent 365 and Entra Agent ID for supported agent identity/lifecycle records, Azure API Center for APIs/tools, Foundry project records for Foundry agents/models/evaluations, and platform telemetry for reconciliation. Use a customer register to join fields that no single product owns.

## Decision tree

1. **If one Microsoft platform is authoritative for the bounded population**, use it and record excluded fields.
2. **If APIs/tools are central**, anchor on Azure API Center and join agent/model/identity fields from Agent 365, Entra, or Foundry.
3. **If Foundry owns engineering records**, use Foundry for agents/models/evaluations and reconcile tool/API lifecycle with Azure API Center.
4. **If the estate is mixed**, use a federated view with field-level source ownership and conflict rules.
5. **If no steward can reconcile drift**, hold lifecycle closure and route to portfolio governance.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Authoritative record | Agent 365/Entra Agent ID + Azure API Center + Foundry + customer register | existing GRC/CMDB is authoritative and maps required fields |
| Reconciliation | evidence-driven review using platform exports/reports and telemetry references | automated sync is already governed and validated |
| Lifecycle | material-change, version, deprecation, retirement, and dependency rules | customer lifecycle policy is stricter and traceable |

## Canonical registry field catalog

No single Microsoft product owns every field. Use a federated register when the
estate spans Agent 365, Entra Agent ID, Foundry, API Center, gateway, telemetry,
and customer lifecycle records.

| Entity | Minimum fields |
|---|---|
| Agent/workload | Registry ID, display name, purpose, implementation path, environment, lifecycle state, accountable owner, technical owner, support owner, risk tier, exception status, evidence reference. |
| Identity | Agent ID or workload identity reference, sponsor, authority mode, disabled/retired state, resource-authorization owner, identity review reference. |
| Tool/API/action | Tool ID, API Center/API Management/MCP reference, schema version, parent/consumer agent, gateway route, owner, lifecycle state, tool/API review reference. |
| Model/deployment | Model family, deployment alias, region/residency, quota owner, evaluation baseline, fallback, evaluation/LLMOps review reference. |
| Data source | Source reference, classification, permission boundary, minimization point, data owner, data review reference. |
| Telemetry | Trace/correlation field, Application Insights/Monitor reference, alert owner, retention owner, operating review reference. |
| Lifecycle | Current state, prior state, transition owner, material-change trigger, exception expiry, retirement evidence route, next review date. |

## Source-of-record join matrix

| Field family | Preferred source | Join key | Conflict rule |
|---|---|---|---|
| Agent lifecycle | Agent 365 where available, otherwise customer register or Foundry record | Explicit registry ID or platform object ID | Preserve disagreement; route unresolved state to steward. |
| Identity | Entra Agent ID, managed identity, service principal, or workload identity record | Object ID/application ID/agent identity ID | Identity record wins for lifecycle and disable state; catalog wins only for ownership intent. |
| Tools/APIs | Azure API Center, API Management, MCP/tool publication record | API ID, product/route ID, tool schema ID | Tool/API catalog wins for schema and lifecycle; agent catalog records consumer relationship. |
| Foundry assets | Foundry project/agent/model/evaluation references | Project/agent/model deployment reference | Foundry wins for engineering state; S9 records only safe references and limits. |
| Telemetry | Azure Monitor, Application Insights, gateway logs, approved operations view | Trace/operation ID or configured correlation key | Telemetry proves observation route only; it does not set lifecycle state. |
| Customer governance | Approved GRC/CMDB/register/change record | Customer record reference | Governing forum owns residual risk, exception, and closeout decision. |

## Lifecycle state machine

Use these states consistently so portfolio and operations teams can reason about
drift and closure.

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

## Reconciliation rules

| Finding | Rule | Route |
|---|---|---|
| Missing owner/steward | Lifecycle cannot close without a named owner. | Steward backlog; portfolio governance if portfolio-level ownership is unclear. |
| Stale version | Version, model alias, tool schema, or data-source reference is older than the recorded review. | Material-change review and LLMOps, tool/API, or data owner as applicable. |
| Orphan identity | Entra/workload identity exists without cataloged agent or owner. | Identity owner and lifecycle steward; consider suspension/retirement route. |
| Uncataloged API/tool | Gateway/API Center shows callable capability missing from agent registry. | Publication route and relationship update. |
| Route mismatch | Agent record, gateway route, API catalog, or telemetry route disagree. | Preserve conflict and assign resolver; do not pick by name similarity. |
| Telemetry gap | Cataloged production item has no trace/correlation or alert owner. | Operating backlog; do not claim runtime proof. |
| Lifecycle conflict | One source says active while another says suspended/retired. | Decision owner resolves with evidence reference and effective date. |
| Exception aging | Exception is expired or lacks next review. | Exception owner or portfolio governance escalation. |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Agent identity/lifecycle | Agent 365 record, Entra Agent ID, sponsor and lifecycle owner |
| API/tool catalog | Azure API Center entry, API Management product/backend, MCP/tool publication record |
| Foundry engineering state | Foundry project, agent, model deployment, evaluation, trace references |
| Reconciliation evidence | approved export/report, Azure Monitor/Application Insights telemetry, drift review ticket |
| Lifecycle closure | material-change record, version/deprecation notice, retirement validation, retained record location |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Catalog authority | each required field has one source of record, steward, coverage limit, and conflict rule | Catalog steward |
| Reconciliation | cadence, evidence source, reviewer, drift threshold, exception path, and next review date are recorded | Control-plane owner |
| Material change | triggers cover authority, tools, data, model, owner, operating scope, and evaluation changes | Lifecycle owner |
| Retirement | suspended/retired entries have closure owner, validation reference, retained record, and recurrence check | Portfolio/catalog owner |

## Boundary note

S9 records and reconciles lifecycle state; customer stewards implement catalog or platform changes.

## Related references

- [S9 Concepts](concepts.md): catalog stewardship, lifecycle trail, reconciliation, and closeout accountability.
- [S1 technical decisions](../s1-identity/technical.md), [S5 technical decisions](../s5-tool-api-governance/technical.md), and [S11 technical decisions](../s11-operate-measure/technical.md).
- [Governance capability guide](../reference/governance-capability-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
