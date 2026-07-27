# Decision Record

Copy this template into the customer's approved records system. Use it to record the required runtime-security handoff decision for S6 Security Runtime.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, gateway policy content, incident payloads, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Runtime question | |
| Decision owner | |
| Application owner | |
| Gateway / platform owner | |
| Security owner | |
| SOC owner | |
| Telemetry owner | |
| Retention / records owner | |
| Evidence owner | |
| Approved records location | |
| Target date | |

## Identity and route

| Field | Record |
|---|---|
| Caller identity / authority | |
| Application or workload identity | |
| Gateway route or app-only route | |
| Backend model / agent / service target | |
| Tool or API route | |
| Administrative or change owner | |
| Unsupported or unreviewed path | |

## Runtime policy decision

Default path: **Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Microsoft Sentinel, and Application Insights**

| Field | Record |
|---|---|
| Gateway policy decision point and owner | |
| App-only control and limitation if applicable | |
| Prompt Shields status (enabled / diagnostic-only / planned / unsupported / not-applicable / blocked) | |
| Prepared-test purpose and boundary | |
| Tool authorization or in-process policy owner | |
| Equivalent customer-owned control if Microsoft default is not used | |

## Detection, SOC route, and telemetry

| Field | Record |
|---|---|
| Defender for Cloud AI posture record or gap | |
| Defender XDR / Sentinel route | |
| SOC queue / playbook / monitoring window | |
| Severity owner | |
| Escalation contact | |
| Stop condition | |
| Telemetry destination | |
| Trace or correlation field | |
| Correlation propagation point | |
| Reviewer and review cadence | |
| Coverage limits and blind spots | |
| Retention / export / discovery / deletion / hold owner | |

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

Create a runtime-security backlog item for each missing identity owner, gateway route, app-only limitation, policy decision point, Prompt Shields status, posture owner, SOC route, severity owner, correlation field, telemetry destination, retention owner, unsupported capability, authorization gap, or exception approval.

Handoff to security engineering, SOC, platform/gateway owner, application owner, identity owner, observability owner, and records-management owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "confirm non-production agent gateway route"; evidence location "customer-approved gateway-route reference, Prompt Shields diagnostic note, Defender/Sentinel route reference, correlation-field note, and retention-owner decision"; accepted when the receiving SOC and security engineering owners accept the route, alert path, correlation, retention, and backlog criteria.
