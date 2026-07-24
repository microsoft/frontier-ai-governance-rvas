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
5. **If no steward can reconcile drift**, hold lifecycle closure and route to S13.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Authoritative record | Agent 365/Entra Agent ID + Azure API Center + Foundry + customer register | existing GRC/CMDB is authoritative and maps required fields |
| Reconciliation | evidence-driven review using platform exports/reports and telemetry references | automated sync is already governed and validated |
| Lifecycle | material-change, version, deprecation, retirement, and dependency rules | customer lifecycle policy is stricter and traceable |

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
