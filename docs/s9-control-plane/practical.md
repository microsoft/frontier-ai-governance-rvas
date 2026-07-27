# Practical workshop: control-plane reconciliation path

**Microsoft default:** Microsoft Agent 365 as the authoritative agent record where available, Microsoft Entra Agent ID, Azure API Center, Microsoft Foundry project or agent record, federated register entries, and platform telemetry references.

**Customer decision:** Approve, defer, reject, route, or block the control-plane record for one bounded workload. This is a reconciliation and handoff decision, not a tenant change, runtime proof, deployment, enforcement, or production approval.

## Work the decision

1. **Choose the reconciliation slice.** Select one pilot, agent, API/tool dependency, Foundry project, or portfolio slice. Name the decision owner, steward, evidence owner, implementation owner, and approved records location before reviewing controls.
2. **Declare the expected source of record.** Start with Microsoft Agent 365 when it is available and appropriate. If the workload is represented through API Center, Foundry, a federated register, or another customer catalog, record why that route is being used and who stewards it.
3. **Reconcile the control-plane route.** Compare safe references for the agent/catalog record, workload identity, API/tool dependencies, Foundry project, telemetry/correlation pointer, owner, lifecycle state, and retirement or exception notes. Do not copy customer evidence into this repository.
4. **Resolve record conflicts.** If two systems disagree, record the conflict rule: which record wins, which owner resolves the mismatch, the target date, and the next review trigger. Absence of a named steward is a blocker.
5. **Check lifecycle and material change.** Record whether the agent or workload is proposed, pilot, active, exception, suspended, retiring, or retired; what change triggers re-review; and where retirement evidence would be referenced.
6. **Record the outcome and handoff.** Approve only when the source of record, steward, conflict rule, lifecycle state, material-change trigger, retirement evidence route, acceptance checks, and receiving owner are complete. Otherwise defer with owner and target date, reject the path, route to the accountable owner, or block the decision.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Agent 365 contains the authoritative agent record | Agent 365 authoritative path | Approve only when the Agent 365 record links owner, identity, API/tool dependencies, telemetry pointer, lifecycle state, exception status, and steward. |
| API dependencies drive the control question | API Center spine | Defer until API Center names the API/tool owner, dependency, lifecycle state, consuming agent/workload, and review trigger. |
| Foundry project is the best available spine | Foundry spine | Route or approve only when the Foundry record references owner, environment, model/agent boundary, telemetry pointer, lifecycle state, and receiving steward. |
| Portfolio uses multiple catalogs | Federated register | Record the federation rule, authoritative field owner, dedupe key, conflict owner, and cadence. Missing reconciliation rules block approval. |
| No steward can accept the record | No-steward blocker | Block or route until a named steward can accept conflicts, lifecycle updates, retirement evidence, and material-change review. |
| Agent appears in code, demo, or backlog but not inventory | Inventory gap | Defer with acceptance test: record is created or linked in the customer-approved control-plane system and handed to a steward. |
| Record is stale or inconsistent | Reconciliation conflict | Defer with source-of-record rule, resolving owner, target date, customer evidence reference, and next review trigger. |

## Decision record

Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot control-plane reconciliation | Agent 365, Entra Agent ID, API Center, Foundry, federated register, and platform telemetry references as applicable | Control-plane steward | Customer-approved record reference only | Source of record, steward, conflict rule, lifecycle state, material-change trigger, retirement evidence route, exception status, backlog, and handoff are complete | Customer date | Control-plane steward and operations governance |

Use this decision tree: if the Microsoft path fits and reconciliation checks are complete, approve the handoff; if records or owners are missing, defer with an acceptance test; if the route cannot satisfy the scoped control question, reject or route to an exception owner; if no steward or record location exists, block.

For an exception, record: reason, affected catalog route, unsupported or unverified control, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, downstream handoff impact, and review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Source of record | the authoritative system for agent/workload, identity, API/tool dependency, telemetry pointer, and lifecycle state is named, or field-level authority is documented | Control-plane steward |
| Steward | a named steward accepts record quality, conflict resolution, cadence, backlog, and retirement evidence routing | Governance owner |
| Conflict rule | duplicate, stale, missing, or inconsistent records have a winning source, resolver, target date, and review trigger | Catalog owner |
| Lifecycle state | proposed, pilot, active, exception, suspended, retiring, or retired state is recorded with owner and safe evidence reference | Portfolio owner |
| Material-change trigger | new tool/API, identity, model, data class, owner, environment, telemetry path, risk tier, exception, or retirement event triggers re-review | Receiving owner |
| Retirement evidence | disablement, owner approval, dependency cleanup, retained records, or exception path has a safe reference location | Operations governance |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, changes no tenant policy, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Workshop facilitator |

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. This workshop changes no tenant policy, proves no runtime enforcement, and does not approve production.
