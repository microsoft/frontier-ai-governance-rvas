# Decision Record

Copy this template into the customer's approved records system. Use it to record
the required tool-call admission decision for S5 Tool & API Governance.

> **Safety boundary:** Use safe references only. Do not place customer
> identifiers, secrets, prompt text, model outputs, telemetry exports, live
> configuration, tenant-change details, runtime proof, enforcement evidence, or
> production approval claims in this repository. Do not change tenant
> configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Tool / API / connector / MCP publication scope | |
| Consuming agent / app / workflow | |
| Operation or operation group | |
| Decision owner | |
| Tool owner | |
| API platform owner | |
| Identity owner | |
| Connector / MCP owner if applicable | |
| Consuming-agent owner | |
| Security / compliance owner | |
| Evidence owner | |
| Approved records location | |
| Target date | |

## Tool-call trace card

| Field | Record |
|---|---|
| Consumer and environment | |
| Caller identity path | |
| Route under review | API Center/APIM / allow-list / connector / MCP publication / runtime-control referral / other |
| Tool/API/MCP operation | |
| Version / schema / package reference | |
| Lifecycle state | Proposed / admitted / published / suspended / withdrawn / blocked |
| Data classes touched | |
| Side effects | |
| Blocked operations | |
| Approved records location | |

## Admission route comparison

Default paths: **API Center/APIM, allow-list, connector, MCP publication,
runtime-control referral, reject unsafe tool, withdraw, or block**

| Route field | Record |
|---|---|
| Result (approve / defer / reject / route / withdraw / blocked) | |
| Selected route | API Center/APIM / allow-list / connector / MCP publication / runtime-control referral / reject unsafe tool / withdraw |
| Routes considered and rejected | |
| Route rationale | |
| API Center record or catalog state | |
| APIM product/API/backend/policy route or exception | |
| Connector approval route | |
| MCP publication record | |
| Allow-list scope and expiry | |
| Runtime/security referral | |
| Evidence-reference location | |

## Operation risk

| Field | Record |
|---|---|
| Operation class | Read-only / write-update / approval-gated / admin-destructive / external side effect / bulk-export / sensitive-data / dynamic tool-chaining |
| Resource or data boundary | |
| Human approval requirement | |
| Over-scope request handling | |
| Failure / retry / fallback behavior | |
| Hard stop or blocker | |
| Business owner acceptance | |

## Control-path package

| Field | Record |
|---|---|
| Catalog / API Center metadata reference | |
| APIM product / API / backend reference | |
| APIM policy-intent families | Caller auth / backend auth / rate-quota / token-limit / content-safety / prompt-shield / blocklist / semantic-cache / token-metric / diagnostics / resilience |
| Connector governance reference if applicable | |
| MCP server/tool schema and publication state if applicable | |
| Allow-list source, version, expiry, and revocation owner if applicable | |
| Material-change triggers | |

## Auth, scopes, rate, and quotas

| Field | Record |
|---|---|
| Entra app / managed identity / OBO path | |
| JWT issuer / audience | |
| Scopes or roles | |
| Consent owner | |
| Credential or secret owner | |
| Least-privilege gap | |
| Rate limit | |
| Token or request quota | |
| Throttling behavior | |
| Cost owner | |
| Abuse or exception owner | |

## Audit, diagnostics, and correlation

| Field | Record |
|---|---|
| Audit route | |
| Correlation field(s) | |
| Diagnostic settings or log reference | |
| Log / evidence owner | |
| Investigation path | |
| Retention / export expectation | |
| Known blind spots | |

## Consumer acceptance

| Field | Record |
|---|---|
| Consuming-agent review result | |
| Accepted operations | |
| Blocked or over-scope operations | |
| Input/output contract assumptions | |
| Timeout / retry / fallback expectations | |
| Next consumer review trigger | |
| Consumer impact if withdrawn | |

## Withdrawal execution plan

| Field | Record |
|---|---|
| Disable API/gateway route | |
| Permission or scope removal path | |
| Connector consent withdrawal path | |
| MCP unpublish path | |
| Allow-list removal path | |
| Credential rotation path | |
| Consumer notification owner | |
| Rollback or closure owner | |
| Verification reference | |
| Investigation reference to preserve | |

## Downstream prerequisites

| Handoff | Record |
|---|---|
| Platform-route prerequisite | |
| Identity prerequisite | |
| Connector / MCP prerequisite | |
| Data / privacy prerequisite | |
| Runtime-assurance prerequisite | |
| Tool behavior / evaluation evidence prerequisite | |
| Catalog/control-plane lifecycle handoff | |
| Operations/support prerequisite | |
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

Complete this section only when the Microsoft default route is not used or when
the customer accepts residual risk.

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

Create a tool/API backlog item for each missing trace field, route rationale,
owner, version, API Center entry, APIM route, connector approval, MCP publication
record, allow-list boundary, auth scope, least-privilege review, rate/quota,
cost owner, audit route, correlation field, consumer acceptance,
material-change trigger, revocation path, withdrawal path, runtime-control
referral, catalog handoff, unsafe operation boundary, or exception approval.

Handoff to API platform owner, tool owner, identity owner, connector owner, MCP
publication owner, consuming-agent owner, security/compliance owner, runtime or
in-process governance owner, evaluation owner, data/privacy owner, and
control-plane/catalog owner as applicable. The receiving owner accepts only
backlog items with clear acceptance tests, target dates, evidence locations, and
review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "admit bounded lookup operation for service assistant"; route "API
Center/APIM with consumer acceptance and withdrawal backlog"; evidence location
"customer-approved API Center record, auth-scope reference, rate/quota
reference, audit-route reference, withdrawal checklist, and consumer review
reference"; accepted when tool, API platform, identity, consumer, security,
evaluation, catalog, and runtime owners accept admission and withdrawal checks
without implying production approval.
