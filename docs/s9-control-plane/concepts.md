# S9 · Control Plane, Catalog & Lifecycle Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-29 · Validate current Microsoft service names, availability, and customer coverage before delivery.

S9 is a read-only view of agent, tool, identity, telemetry, and lifecycle records. It does not query live data or change a catalog, identity, access setting, lifecycle state, or production system.

## A registry entry is the unit of accountability

An agent or tool catalog is useful only when each entry names its purpose, accountable owner, technical steward, lifecycle state, and review references. A control-plane registry is the customer-owned record that brings those fields together for a bounded population.

Unknown fields stay unknown and become owned findings. Do not fill gaps by guessing from names, dashboards, team labels, or nearby metadata.

Agent and tool stewardship are related but different. An agent entry names the accountable service. A tool entry names the callable capability, steward, parent agent or approved shared-use relationship, version, route, and lifecycle decision. This matters because an approved agent can gain new reach through an unreviewed tool.

## Source of record is field-level

No single product owns every field. A useful registry says which source owns which field and what happens when sources disagree.

| Field family | Typical source of record | Why field-level ownership matters |
|---|---|---|
| Agent/workload | Agent 365 where available, Foundry, customer register | Agent registry may know purpose and lifecycle better than identity records. |
| Identity | Entra Agent ID, managed identity, app registration, workload identity | Identity source wins for object ID, disable state, sponsor, and authorization boundary. |
| Tool/API/action | API Center, API Management/gateway, MCP/tool publication record | Tool/API catalog wins for schema, route, dependency, and lifecycle state. |
| Model/deployment | Foundry project/model deployment, customer LLMOps record | Engineering record wins for model route, deployment alias, quota, fallback, and evaluation baseline. |
| Data source | Data catalog, retrieval configuration, source-owner record | Data owner and permission boundary decide whether access is acceptable. |
| Telemetry | Azure Monitor, Application Insights, gateway logs, approved operations view | Telemetry source proves observation route only; it does not set lifecycle state. |
| Lifecycle/exception | Customer register, change record, portfolio/governance process | Governing process owns residual risk, exception expiry, transition, and closeout. |

## Join keys are evidence; names are hints

S9 compares explicit identifiers only: registry ID, platform object ID, agent identity ID, application ID, API ID, product or route ID, tool schema ID, Foundry project/agent/model reference, deployment alias, telemetry correlation key, or customer record reference.

Accept matches only when the join key is explicit and the source-of-record rule is recorded. Do not infer a match from display name, owner guess, alias, URL similarity, file name, or "looks like the same thing."

## Lifecycle is a decision trail, not a label

Proposed, active review, publish ready, published, hold, suspended, deprecated, retired, and withdrawn states show intended operating state. A transition needs an accountable decision, review reference, effective date, and permitted destination.

Material changes to authority, tool use, data handling, model behavior, operating scope, telemetry route, risk tier, exception status, or ownership need recorded review before the customer treats them as accepted.

Suspension stops use while review happens. Retirement ends intended use but keeps the record for accountability. Withdrawal ends a candidate path. S9 records these distinctions. It never performs them.

## Reconciliation keeps gaps visible

![Control-plane reconciliation uses source-of-record joins to expose findings, route lifecycle decisions, and create owned backlog.](../assets/diagrams/s9-reconciliation-gap-flow.svg)

S9 compares explicit identity, catalog, tool/API, model, data, telemetry, and lifecycle identifiers in the registry. Unmatched identities, catalog-only entries, missing owners, invalid lifecycle states, unreviewed material changes, telemetry gaps, stale versions, and incomplete closure records become findings for accountable owners.

Records may come from Agent 365 where available, Entra Agent ID or workload identity, API Center or gateway, Foundry, telemetry, and lifecycle or change-review systems. S9 preserves disagreement; it does not choose the customer's system of record unless the customer has already recorded the conflict rule.

## Telemetry pointer is not runtime proof

A telemetry pointer says where an operating reviewer should look and which correlation key is expected. It does not prove that runtime controls are working, that every call is covered, or that production behavior is accepted. If the pointer has no query owner, retention owner, alert owner, or review cadence, it is a reconciliation finding.

## Reconciliation becomes lifecycle backlog

The S9 recommendation should say whether the bounded population can close, close with owned gaps, defer, reject, route, or block. Typical backlog rows include source-of-record rule, steward assignment, parent-tool relationship, lifecycle-state fix, material-change review, suspension, withdrawal, retirement, recurrence check, exception escalation, telemetry owner, identity owner, API/tool owner, platform/Foundry owner, and portfolio risk.

Where evaluation or red-team readiness depends on versioned datasets, evaluator definitions, adversarial categories, or scorecard references, S9 should name a steward, version record, lifecycle decision, and review trigger. An unowned assurance asset is a dependency. It is not proof that future decisions remain valid.

S9 does not execute catalog, identity, access, policy, telemetry, or retirement changes. It routes them to the customer-owned steward or change process.

## Closeout accepts accountability, not absence of findings

Closeout can happen with owned gaps only when the decision owner records residual-risk disposition, accountable owner, due date, validation reference, recurrence check, exception route, and next review.

Closeout should not occur when the population has no steward, no approved records location, no field-level source-of-record rule, no explicit join key, no lifecycle state, no material-change trigger, or no closure route for retired/suspended entries.

## Fleet governance and workflow controls have different jobs

A fleet control plane can show agents, ownership, dependencies, lifecycle state, and reconciliation gaps across systems. An in-process control can make a decision inside an agent workflow before a specific tool action. S9 reconciles fleet-level records and dependencies. Runtime behavior, workflow-control installation, and enforcement claims must come from their own operating records.

## Failure modes to prevent

- Matching records by display name instead of explicit identifier.
- Treating an orphan identity as harmless because no owner complained.
- Cataloging a tool/API without a parent or consumer relationship.
- Keeping an API Center record with no gateway route or lifecycle owner.
- Keeping a Foundry project without accountable lifecycle owner.
- Recording telemetry pointer with no query owner, retention owner, or cadence.
- Marking a record retired without closure evidence and retained-record location.
- Letting an exception expire without escalation or next review.
- Treating stale model/tool versions as accepted because the catalog entry exists.
- Treating an unowned evaluation or red-team asset as future release evidence.

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Agent 365, Purview, identity, audit, API, telemetry, and lifecycle sources that can inform customer-owned control-plane stewardship.
