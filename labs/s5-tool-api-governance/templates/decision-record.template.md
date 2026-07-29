# Decision Record

Copy this template into the customer's approved records system. Use it to record the required tool/API admission decision for S5 Tool & API Governance.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Tool / API / connector / MCP publication scope | |
| Consuming agent / app / workflow | |
| Decision owner | |
| Tool owner | |
| API platform owner | |
| Identity owner | |
| Consuming-agent owner | |
| Security / compliance owner | |
| Evidence owner | |
| Approved records location | |
| Target date | |

## Admission route

Default paths: **API Center/APIM, allow-list, connector, MCP publication, runtime-control referral, or reject unsafe tool**

| Route field | Record |
|---|---|
| Result (approve / defer / reject / route / withdraw / blocked) | |
| Selected route | API Center/APIM / allow-list / connector / MCP publication / runtime-control referral / reject unsafe tool / withdraw |
| Route rationale | |
| API Center record or catalog state | |
| APIM product/API policy route or exception | |
| Connector approval route | |
| MCP publication record | |
| Allow-list scope and expiry | |
| Runtime/security referral | |
| Evidence-reference location | |

## Tool/API profile

| Field | Record |
|---|---|
| Business purpose | |
| Environment or scope | |
| Version | |
| Lifecycle state | Proposed / admitted / deprecated / withdrawn / blocked |
| Change owner | |
| Review cadence | |
| Expiry or next review date | |
| Deprecation or withdrawal trigger | |

## Operation boundary

| Field | Record |
|---|---|
| Read operations allowed | |
| Write operations allowed | |
| Admin or destructive operations allowed | |
| Blocked operations | |
| Data classes or sensitivity boundary | |
| Side effects | |
| Human approval requirement | |
| Over-scope request handling | |

## Auth, scopes, rate, and quotas

| Field | Record |
|---|---|
| Entra app / JWT audience | |
| Scopes or roles | |
| Consent owner | |
| Credential or secret owner | |
| Least-privilege gap | |
| Rate limit | |
| Quota | |
| Throttling behavior | |
| Abuse or exception owner | |

## Audit, revocation, withdrawal, and consumer review

| Field | Record |
|---|---|
| Audit route | |
| Correlation field | |
| Log / evidence owner | |
| Investigation path | |
| Retention / export expectation | |
| Disable or revoke path | |
| Permission removal path | |
| Connector consent withdrawal path | |
| MCP unpublish path | |
| Allow-list removal path | |
| Credential rotation path | |
| Consumer notification owner | |
| Rollback owner | |
| Consuming-agent review result | |
| Next consumer review trigger | |

## Downstream prerequisites

| Handoff | Record |
|---|---|
| Platform-route prerequisite | |
| Runtime-assurance prerequisite | |
| Tool behavior / evaluation evidence prerequisite | |
| Catalog/control-plane lifecycle handoff | |
| Runtime/enforcement referral | |
| Stop condition before downstream reliance | |

## Customer decision

| Decision field | Record |
|---|---|
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Consumer or release impact | |
| Handoff owner and customer process | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default route is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected operation | |
| Unsupported or unverified control | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Consumer impact | |
| Review trigger | |

## Backlog and handoff

Create a tool/API backlog item for each missing owner, version, API Center entry, APIM route, allow-list boundary, connector approval, MCP publication record, auth scope, least-privilege review, rate/quota, audit route, correlation field, revocation path, withdrawal path, consumer review, runtime-control referral, catalog handoff, unsafe operation boundary, or exception approval.

Handoff to API platform owner, tool owner, identity owner, connector owner, consuming-agent owner, security/compliance owner, runtime or in-process governance owner, evaluation owner, and control-plane/catalog owner as applicable. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "admit customer-lookup tool for bounded support pilot"; route "API Center/APIM with allow-list and catalog handoff"; evidence location "customer-approved API Center record, auth-scope reference, rate/quota reference, audit-route reference, revocation checklist, and consumer review reference"; accepted when tool, API platform, identity, consumer, security, evaluation, catalog, and runtime/in-process governance owners accept admission and withdrawal checks without implying production approval.
