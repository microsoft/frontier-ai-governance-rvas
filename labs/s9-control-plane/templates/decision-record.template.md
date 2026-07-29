# Decision Record

Copy this template into the customer's approved records system. Use it to record the required control-plane reconciliation decision for S9 Control Plane.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, retirement artifacts, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Reconciliation question | |
| Decision owner | |
| Control-plane steward | |
| Implementation owner | |
| Evidence owner | |
| Receiving owner / process | |
| Approved records location | |
| Target date | |

## Control-plane route

Default path: **Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, Microsoft Foundry, federated registers, and platform telemetry references**

| Route field | Record |
|---|---|
| Agent 365 record or reason unavailable | |
| Entra Agent ID / workload identity reference | |
| API Center / tool dependency reference | |
| Foundry / platform record reference | |
| Federated register or alternate catalog reference | |
| Telemetry / correlation pointer | |
| Evidence-reference location | |

## Source of record and stewardship

| Field | Record |
|---|---|
| Authoritative source for agent/workload record | |
| Authoritative source for owner/steward | |
| Authoritative source for identity | |
| Authoritative source for API/tool dependencies | |
| Authoritative source for telemetry pointer | |
| Authoritative source for lifecycle state | |
| Field-level authority or federation rule | |
| Steward and review cadence | |
| Record-quality owner | |

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
| Source-of-record join key | |

## Reconciliation checks

| Check | Record |
|---|---|
| Reconciliation status (matched / missing / duplicate / stale / conflicting / unsupported / no-steward / blocked) | |
| Conflict rule / winning source | |
| Conflict resolver | |
| Stale-record rule | |
| Lifecycle state (proposed / active-review / publish-ready / published / hold / suspended / deprecated / retired / withdrawn) | |
| Material-change trigger | |
| Retirement evidence route | |
| Drift rule (missing owner / stale version / orphan identity / uncataloged tool / route mismatch / telemetry gap / lifecycle conflict / exception aging) | |
| Known unsupported or unreviewed path | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route / blocked) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Release or backlog impact | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected catalog route | |
| Unsupported or unverified control-plane check | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Downstream handoff impact | |
| Review trigger | |

## Backlog and handoff

Create a control-plane backlog item for each missing source-of-record rule, steward, catalog record, identity link, API/tool dependency, Foundry/API Center pointer, telemetry pointer, lifecycle state, material-change trigger, retirement evidence route, conflict rule, unsupported route, access/license blocker, or evidence location.

Handoff to the control-plane steward, identity owner, API platform owner, Foundry/platform owner, portfolio governance, and operations governance. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "reconcile pilot agent catalog entry"; evidence location "customer-approved Agent 365 record reference, API Center dependency reference, Foundry project reference, and telemetry pointer; no customer evidence copied here"; accepted when the steward confirms source of record, conflict rule, lifecycle state, material-change trigger, retirement evidence route, backlog owner, and handoff.
