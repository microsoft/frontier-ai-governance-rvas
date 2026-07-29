# Decision Record

Copy this template into the customer's approved records system. Use it to record
the required runtime-path acceptance decision for S6 Security Runtime.

> **Safety boundary:** Use safe references only. Do not place customer
> identifiers, secrets, prompt text, model outputs, telemetry exports, live
> configuration, gateway policy content, incident payloads, tenant-change
> details, runtime proof, enforcement evidence, or production approval claims in
> this repository. Do not change tenant configuration or live policy during the
> lab.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Runtime question | |
| Non-production request path | |
| Decision owner | |
| Application owner | |
| Gateway / platform owner | |
| Identity owner | |
| Security owner | |
| SOC owner | |
| Telemetry / observability owner | |
| Retention / records owner | |
| Evidence owner | |
| Customer reviewer | |
| Approved records location | |
| Target date | |

## Runtime-path trace

| Field | Record |
|---|---|
| Caller identity / authority | |
| Application or workload identity | |
| Gateway route or app-only route | |
| Backend model / agent / service target | |
| Tool or API route | |
| Response path | |
| Policy decision point(s) | |
| Alert or SOC path | |
| Telemetry destination | |
| Trace or correlation field | |
| Administrative or change owner | |
| Unsupported or unreviewed path | |

## Gateway-proof acceptance package

Use safe references that align to `rvas.delivery.gateway-proof.v1`.

| Manifest / acceptance field | Record |
|---|---|
| Environment label | |
| Gateway reference | |
| Access contract reference | |
| Backend reference | |
| Policy reference | |
| Correlation ID | |
| Request evidence reference | |
| Telemetry evidence reference | |
| Expected policy behavior | Block / deny / annotate / log / throttle / alert / route / fallback / other |
| Transport result | Pass / fail / blocked |
| Customer reviewer decision | Accept / defer / reject / route / blocked / diagnostic-only |
| Acceptance limitation | |

## Control placement and threat map

| Field | Record |
|---|---|
| Identity/network control | |
| Gateway/APIM control | |
| Model/agent control | |
| Application or in-process control | |
| Tool/API control | |
| SOC/posture control | |
| Operations or records control | |
| Direct prompt-injection handling | |
| Indirect prompt-injection handling | |
| Harmful-content handling | |
| PII / sensitive-data leakage handling | |
| Unsupported-answer handling | |
| Tool-abuse handling | |
| Unauthorized-access handling | |
| Cost/availability-abuse handling | |
| Route-bypass handling | |

## Diagnostic versus acceptance boundary

| Field | Record |
|---|---|
| Gateway-path evidence | |
| App-only evidence and limitation | |
| Model/agent evidence and limitation | |
| Direct Content Safety or Prompt Shields diagnostic | |
| Prepared-test purpose and boundary | |
| Unsupported / planned / not-applicable capability | |
| Claim that must not be made | |

## Detection, SOC route, and telemetry

| Field | Record |
|---|---|
| Defender for Cloud AI posture record or gap | |
| Defender XDR / Sentinel route | |
| Customer SIEM or manual review route if applicable | |
| SOC queue / playbook / monitoring window | |
| Severity owner | |
| Escalation contact | |
| Stop condition | |
| Telemetry destination | |
| Correlation creation point | |
| Correlation propagation point(s) | |
| Query owner and query reference | |
| Time window reviewed | |
| Expected signal | |
| Reviewer and review cadence | |
| Coverage limits and blind spots | |
| Retention / export / discovery / deletion / hold owner | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (accept / defer / reject / route / blocked / diagnostic-only) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Release or backlog impact | |
| Material-change trigger | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used or when the
customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected runtime route | |
| Unsupported or unverified control | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Downstream handoff impact | |
| Review trigger | |

## Backlog and handoff

Create a runtime-security backlog item for each missing runtime-path trace
field, identity owner, gateway route, app-only limitation, policy decision point,
Prompt Shields status, diagnostic-only boundary, posture owner, SOC route,
severity owner, correlation field, query owner, telemetry destination, retention
owner, unsupported capability, reviewer, authorization gap, hard stop, or
exception approval.

Handoff to security engineering, SOC, platform/gateway owner, application owner,
identity owner, observability owner, data/privacy owner, runtime assurance owner,
evaluation owner, operations owner, and records-management owner as applicable.
The receiving owner accepts only backlog items with clear acceptance tests,
target dates, evidence locations, limitations, and review triggers. Keep final
records in the customer-approved system.

## Filled example

Work item "confirm bounded non-production agent gateway route"; evidence
location "customer-approved gateway-route reference, gateway-proof manifest
reference, diagnostic note, Defender/Sentinel route reference, correlation-query
reference, reviewer decision, and retention-owner decision"; accepted when the
receiving SOC and security engineering owners accept the route, policy decision,
alert path, correlation, retention, limitations, and backlog criteria.
