# Decision Record

Copy this template into the customer's approved records system. Use it to record the required control-plane reconciliation and lifecycle closeout decision for S9 Control Plane.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, tenant IDs, object IDs, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, retirement artifacts, or production approval claims in this repository. Do not change tenant configuration, access, catalog records, lifecycle state, or live policy during the lab.

## Registry population card

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Reconciliation question | |
| Population reference | |
| Included agents / workloads | |
| Included identities | |
| Included tools / APIs / actions | |
| Included models / deployments | |
| Included data sources | |
| Included telemetry pointers | |
| Included lifecycle / exception records | |
| Excluded records or field families | |
| Environment and lifecycle boundary | |
| Decision owner | |
| Control-plane steward | |
| Lifecycle owner | |
| Evidence owner | |
| Finding owners | |
| Receiving owner / process | |
| Approved records location | |
| Review cadence | |
| Closure owner | |
| Target date | |

## Canonical registry fields

| Field family | Record |
|---|---|
| Agent / workload | |
| Identity | |
| Tool / API / action | |
| Model / deployment | |
| Data source | |
| Telemetry | |
| Lifecycle / exception | |
| Closeout | |
| Missing fields opened as findings | |

## Source of record and join map

Default path: **Agent 365 where available, Microsoft Entra Agent ID, Azure API Center, API Management/gateway, Microsoft Foundry, federated registers, and Azure Monitor/Application Insights telemetry references**

| Field family | Source of record | Explicit join key | Owner | Coverage limit | Conflict rule |
|---|---|---|---|---|---|
| Agent / workload | | | | | |
| Identity | | | | | |
| Tool / API / action | | | | | |
| Model / deployment | | | | | |
| Data source | | | | | |
| Telemetry | | | | | |
| Lifecycle / exception | | | | | |
| Customer governance / closeout | | | | | |

## Reconciliation findings

| Field | Record |
|---|---|
| Reconciliation status (matched / missing / duplicate / stale / conflicting / unsupported / no-steward / blocked / close-with-owned-gaps) | |
| Finding type (missing owner / stale version / orphan identity / uncataloged tool / route mismatch / telemetry gap / lifecycle conflict / exception aging / unsupported coverage / other) | |
| Affected reference | |
| Source systems | |
| Explicit join key used | |
| Conflict rule / winning source | |
| Conflict resolver | |
| Lifecycle or closeout impact | |
| Owner | |
| Target date | |
| Validation reference | |
| Recurrence check | |
| Route / receiving process | |

## Lifecycle and material-change review

| Field | Record |
|---|---|
| Lifecycle state (proposed / active_review / publish_ready / published / hold / suspended / deprecated / retired / withdrawn) | |
| Prior state | |
| Proposed next state | |
| Transition owner | |
| Transition review reference | |
| Effective date | |
| Material-change triggers | |
| Exception status | None / proposed / accepted / expired / rejected |
| Exception owner and expiry | |
| Retirement / withdrawal / suspension evidence route | |
| Retained-record location | |
| Reopen trigger | |

## Closeout decision

| Decision field | Record |
|---|---|
| Result (close / close-with-owned-gaps / defer / reject / route / blocked) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Residual risk disposition | |
| Backlog item to create | |
| Handoff owner and customer process | |
| Release / portfolio / operations impact | |
| Next review trigger | |

## Closeout with owned gaps

Complete one row per remaining gap.

| Gap reference | Owner | Acceptance test | Evidence reference | Target date | Recurrence check | Exception route | Receiving process |
|---|---|---|---|---|---|---|---|
| | | | | | | | |

## Exception

Complete this section only when the Microsoft default is not used, a field family has unsupported coverage, or the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected field family or catalog route | |
| Unsupported or unverified control-plane check | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Downstream handoff impact | |
| Recurrence check | |
| Review trigger | |

## Backlog and handoff

Create a control-plane backlog item for each missing source-of-record rule, steward, catalog record, explicit join key, identity link, API/tool dependency, Foundry/API Center pointer, telemetry pointer, lifecycle state, material-change trigger, retirement evidence route, conflict rule, unsupported coverage, exception expiry, access/license blocker, or evidence location.

Handoff to the control-plane steward, identity owner, API/tool owner, Foundry/platform owner, telemetry/operations owner, lifecycle/catalog owner, portfolio governance, and release/change owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, recurrence checks, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "reconcile pilot agent registry population"; evidence location "customer-approved Agent 365 record reference, Entra identity reference, API Center dependency reference, Foundry project reference, and telemetry pointer; no customer evidence copied here"; accepted when the steward confirms source-of-record map, explicit join keys, conflict rule, lifecycle state, material-change trigger, closure route, recurrence checks, backlog owner, and handoff.
