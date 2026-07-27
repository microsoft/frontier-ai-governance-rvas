# S9 Control Plane Runbook

Use this runbook to guide the required control-plane reconciliation path. The customer inspects its own Microsoft records, records safe references in its approved system, and decides whether the scoped agent or workload has an accepted control-plane record and steward.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, retirement artifacts, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry gate

Confirm the customer has a bounded workload or portfolio slice, decision owner, implementation owner, evidence owner, control-plane steward, receiving owner, and approved records location. If any are missing, stop the decision and create a blocker backlog item with the missing owner, record, or approval path.

## Required reconciliation flow

1. **Set the reconciliation question.** Record the scoped decision: for example, whether Agent 365 is authoritative, whether API Center is the dependency spine, whether Foundry is the best available record, or whether a federated register must reconcile multiple catalogs.
2. **Name the expected source of record.** Record field-level authority for agent/workload identity, owner, API/tool dependency, Foundry/project link, telemetry pointer, lifecycle state, exception status, and retirement route.
3. **Inspect Agent 365 when available.** Reference the agent record, owner, lifecycle, identity link, tool/API dependency, telemetry pointer, steward, and exception or retirement notes. If unavailable, record why another route is used.
4. **Inspect Entra Agent ID or workload identity.** Reference the identity record, lifecycle owner, disabled/retired state if applicable, and gap owner. Do not copy access assignments or live configuration.
5. **Inspect API Center and tool dependencies.** Reference APIs, tools, gateways, consumer agent/workload, dependency owner, lifecycle state, and material-change triggers.
6. **Inspect Foundry or platform record.** Reference the Foundry project/agent/model route or approved platform record, environment/scope, owner, telemetry/correlation pointer, and known limitations.
7. **Reconcile federated registers.** Where multiple catalogs exist, record dedupe key, winning source, field owner, conflict resolver, cadence, and stale-record rule.
8. **Resolve conflicts and stale records.** Classify each mismatch as `missing`, `duplicate`, `stale`, `conflicting`, `unsupported`, `no-steward`, or `blocked`. Assign owner, acceptance test, target date, evidence location, and review trigger.
9. **Confirm lifecycle and material-change trigger.** Record state as `proposed`, `pilot`, `active`, `exception`, `suspended`, `retiring`, or `retired`. Name triggers such as new tool/API, identity, model, data class, owner, environment, telemetry path, risk tier, exception, or retirement.
10. **Confirm retirement evidence route.** Name where disablement, owner approval, dependency cleanup, retained records, and exception closure would be referenced. Do not paste retirement artifacts into this repository.
11. **Set decision state.** Use one state:
    - `approve`: source of record, steward, conflict rule, lifecycle state, material-change trigger, retirement evidence route, evidence reference, acceptance test, and handoff are complete;
    - `defer`: a gap has a named owner and target date;
    - `reject`: the scoped control-plane path cannot meet the required reconciliation question;
    - `route`: another catalog, identity, API, Foundry/platform, portfolio, governance, or exception owner must decide first;
    - `blocked`: ownership, evidence location, source-of-record rule, steward, catalog access, lifecycle clarity, or scope clarity prevents a decision.
12. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, release or backlog impact, and next review trigger.
13. **Handoff.** Send the completed decision record and backlog references to the control-plane steward, identity owner, API platform owner, Foundry/platform owner, portfolio governance, and operations governance.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `steward-missing`, `record-location-missing`, `source-of-record-unclear`, `agent365-record-missing`, `identity-link-missing`, `api-center-link-missing`, `foundry-link-missing`, `telemetry-pointer-missing`, `federation-rule-missing`, `conflict-rule-missing`, `lifecycle-state-unclear`, `material-change-trigger-missing`, `retirement-evidence-route-missing`, `stale-record`, `unsupported-record-route`, `access-or-license`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes the source of record, steward, reconciliation status, identity/API/Foundry/telemetry references, conflict rule, lifecycle state, material-change trigger, retirement evidence route, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
