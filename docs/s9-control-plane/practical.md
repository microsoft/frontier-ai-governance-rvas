# Practical workshop: control-plane registry reconciliation

**Microsoft default:** Agent 365 where available, Microsoft Entra Agent ID or workload identity, Azure API Center, API Management/gateway, Microsoft Foundry, federated customer registers, and Azure Monitor/Application Insights telemetry references.

**Customer decision:** Close, close with owned gaps, defer, reject, route, or block the reconciliation package for one bounded population. This is a registry and handoff decision, not a tenant change, runtime proof, deployment, enforcement, access change, lifecycle change, or production approval.

## Work the decision

1. **Choose the population and scope question.** Select one pilot, agent group, API/tool dependency set, Foundry project, or portfolio slice. Name the steward, decision owner, evidence owner, lifecycle owner, finding owners, and approved records location.
2. **Build the registry population card.** Record included/excluded agents, tools/APIs, identities, models, data sources, telemetry pointers, lifecycle records, environment boundary, cadence, and closure owner.
3. **List canonical fields.** Capture the expected agent/workload, identity, tool/API/action, model/deployment, data source, telemetry, lifecycle, exception, and closeout fields. Unknown fields stay unknown and become findings.
4. **Declare source-of-record per field family.** Use Agent 365 where available, Entra identity records, API Center/API Management/gateway, Foundry, telemetry, or customer register according to field ownership. Record coverage limits and conflict rules.
5. **Compare explicit join keys.** Use registry ID, platform object ID, agent identity ID, application ID, API ID, route ID, tool schema ID, Foundry reference, deployment alias, telemetry correlation key, or customer record reference. Do not match by name or inferred similarity.
6. **Classify reconciliation findings.** Record missing owner, stale version, orphan identity, uncataloged tool/API, route mismatch, telemetry gap, lifecycle conflict, exception aging, unsupported coverage, or other.
7. **Check lifecycle and material-change state.** Confirm state, permitted transition, transition owner, review reference, material-change triggers, retirement/withdrawal evidence route, retained-record location, and reopen trigger.
8. **Record the outcome and handoff.** Close only when source-of-record ownership, join keys, steward, conflict rule, lifecycle state, material-change trigger, closure route, evidence references, recurrence check, and receiving owners are complete. Otherwise close with owned gaps, defer, reject, route, or block.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Agent 365 contains the authoritative agent record | Agent 365 authoritative path | Close only when the record links owner, identity, API/tool dependencies, telemetry pointer, lifecycle state, exception status, steward, and review cadence. |
| Identity exists without registry owner | Orphan identity route | Route to identity owner and lifecycle steward with sponsor, disable/retire decision, validation reference, and target date. |
| API dependencies drive the control question | API Center/API Management spine | Defer until API/tool owner, route, schema version, consuming agent/workload, lifecycle state, and review trigger are recorded. |
| Gateway route and API catalog disagree | Route mismatch | Preserve both references, record conflict rule, assign resolver, and set validation reference. Do not choose by display name. |
| Foundry project is the best available spine | Foundry spine | Close or route only when Foundry record references owner, environment, model/agent boundary, telemetry pointer, lifecycle state, and receiving steward. |
| Foundry project has no lifecycle owner | Lifecycle owner gap | Defer or block until owner, state, material-change trigger, and closeout route are accepted. |
| Portfolio uses multiple catalogs | Federated register | Record field-level authority, dedupe key, conflict owner, coverage limit, cadence, and exception route. Missing reconciliation rules block closeout. |
| Telemetry pointer is missing or unowned | Telemetry gap | Route to telemetry/operations owner with correlation key, query owner, retention owner, alert owner, and review cadence. |
| Model/tool version is stale | Stale version route | Open material-change review with owner, affected record, target date, validation reference, and recurrence check. |
| Exception is expired | Exception-aging route | Route to exception owner or accepted-risk authority with expiry, compensating action, and next review. |
| Retired state lacks closure evidence | Retirement closure route | Defer until closure owner, retained-record location, validation reference, dependency cleanup, and recurrence check are recorded. |
| No steward can accept the record | No-steward blocker | Block until a named steward can accept conflicts, lifecycle updates, closure evidence, and material-change review. |

## Decision record

Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Control-plane reconciliation package | Agent 365 where available, Entra Agent ID/workload identity, API Center, API Management/gateway, Foundry, customer register, and telemetry references as applicable | Control-plane steward | Customer-approved record reference only | Population card, canonical fields, source-of-record map, explicit join keys, findings, lifecycle/material-change rules, closeout decision, backlog, and handoff are complete | Customer date | Steward, identity, API/tool, platform, telemetry, lifecycle, and portfolio owners |

Use this decision tree: if source-of-record ownership, explicit join keys, lifecycle state, findings, and closeout checks are complete, close the package; if gaps are owned and measurable, close with owned gaps; if records or owners are missing, defer with an acceptance test; if the route cannot satisfy the scoped question, reject or route to an exception owner; if no steward, record location, join key, or hard-gate source exists, block.

For an exception, record: reason, affected field family or catalog route, unsupported or unverified control-plane check, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, downstream handoff impact, recurrence check, and review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Registry population | bounded population, included/excluded records, steward, evidence owner, approved records location, closure owner, and cadence are recorded | Control-plane steward |
| Canonical fields | agent/workload, identity, tool/API, model, data source, telemetry, lifecycle, exception, and closeout fields are recorded or opened as findings | Registry steward |
| Source of record | authoritative system for each field family is named, or field-level authority and coverage limit are documented | Control-plane steward |
| Join keys | explicit identifiers are recorded for joins; no name-based matching is used | Record-quality owner |
| Conflict rule | duplicate, stale, missing, inconsistent, or unsupported records have a winning source, resolver, target date, validation reference, and review trigger | Catalog owner |
| Lifecycle state | state, transition owner, review reference, material-change trigger, closure route, and reopen trigger are recorded | Lifecycle owner |
| Retirement evidence | disablement, owner approval, dependency cleanup, retained records, or exception path has a safe reference location | Operations governance |
| Closeout with gaps | every remaining gap has owner, acceptance test, evidence reference, target date, recurrence check, and next review trigger | Receiving owner |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, queries no live tenant data, changes no policy/access/catalog/lifecycle state, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Facilitator |

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. This workshop changes no tenant policy, proves no runtime enforcement, and does not approve production.
