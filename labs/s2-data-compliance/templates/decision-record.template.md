# Decision Record

Copy this template into the customer's approved records system. Use it to record the required customer decision for S2 Data Compliance.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, Purview exports, policy deployment artifacts, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Decision owner | |
| Data owner | |
| Compliance owner | |
| Implementation owner | |
| Evidence owner | |
| Approved records location | |
| Target date | |

## Data path

| Path segment | Safe reference / owner / notes |
|---|---|
| Prompt or input path | |
| Retrieval source or source data | |
| Tool output or downstream action | |
| Generated response | |
| Logs, telemetry, transcripts, or evidence notes | |
| Downstream sharing or storage | |
| Investigation or legal/compliance record | |
| Minimization point | |

## Classification and DSPM posture

| Field | Record |
|---|---|
| Sensitivity label / classifier / data class | |
| DSPM outcome (result / no-result / unsupported / blocked) | |
| Reviewed scope and time window | |
| Reviewer / observation owner | |
| Unsupported workload, role, license, location, or tenant condition | |
| Classification or exposure gap | |

## DLP, investigation, and retention

| Field | Record |
|---|---|
| DLP posture (covered / report-only-ready / designed / gap / not-applicable / blocked) | |
| DLP reviewer and false-positive owner | |
| Audit route | |
| eDiscovery / legal hold route | |
| Insider Risk / Communication Compliance / privacy route if applicable | |
| Retention or records-management owner | |
| Evidence storage / export / deletion / hold expectation | |

## Gateway / Purview boundary

| Field | Record |
|---|---|
| What Purview or source-system controls establish | |
| What gateway/runtime controls may observe or mask | |
| Path Purview cannot see | |
| Path gateway cannot see | |
| Dependency routed to platform or runtime owner | |

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
| Affected data path | |
| Unsupported or unverified control | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Backlog and handoff

Create a data-governance backlog item for each missing label, classifier, DSPM review, DLP readiness record, audit/eDiscovery route, retention decision, data-owner approval, gateway dependency, unsupported capability, or access/license blocker.

Handoff to the data owner, privacy/compliance team, Purview administrator, records-management owner, and any gateway/runtime owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "review retrieval corpus data path"; evidence location "customer-approved Purview label reference, DSPM scope note, report-only DLP review reference, and retention-owner decision"; accepted when the data owner and compliance owner confirm the source, classification, investigation route, retention expectation, gateway dependency, and backlog owner.
