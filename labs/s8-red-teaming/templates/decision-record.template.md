# Decision Record

Copy this template into the customer's approved records system. Use it to record the required adversarial-testing, remediation, and retest decision for S8 Red Teaming.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, endpoint clients, credentials, attack datasets, native scorecards, incident payloads, or production approval claims in this repository. Do not run production tests or change tenant configuration during the lab.

## Scope and authorization

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Adversarial-testing question | |
| Target and version | |
| Environment (must be non-production) | |
| Decision owner | |
| Target owner | |
| Red-team operator / facilitator | |
| SOC contact and monitoring window | |
| Legal / risk contact if required | |
| Evidence owner | |
| Category-threshold owner | |
| Severity owner | |
| Remediation owner | |
| Retest owner | |
| Approved records location | |
| Target date | |

## Rules of engagement

| Field | Record |
|---|---|
| Authorization reference | |
| Permitted categories | |
| Allowed methods and tools | |
| Data limits | |
| Prohibited activity | |
| Timing / duration | |
| Stop condition | |
| Reset or rollback path | |
| Evidence handling and retention owner | |
| Production-impact exclusion | |

## Test method and evidence boundary

Default path: **AI Red Teaming Agent where supported; PyRIT/manual approved alternate; Azure AI Content Safety/Prompt Shields; Defender/Sentinel; SOC remediation routes**

| Field | Record |
|---|---|
| Method (AI Red Teaming Agent / PyRIT / manual / third-party / unsupported / blocked) | |
| Support-status caveat | |
| Foundry project or approved run-record reference | |
| Native scorecard or run-record reference | |
| Threshold comparison sidecar reference if used | |
| Prompt/output/dataset storage location (customer-approved reference only) | |
| Limitations and assumptions | |

## Finding interpretation and remediation

| Field | Record |
|---|---|
| Category | |
| ASR or qualitative result | |
| Sample/context note | |
| Threshold or tolerance | |
| Above / at / below / disputed / not-comparable threshold | |
| Severity and rationale | |
| Control owner (Prompt Shields / Content Safety / gateway / app / tool / data / SOC / evaluation / lifecycle / accepted risk) | |
| Remediation or accepted-risk decision | |
| Release or backlog impact | |
| Stop condition if risk remains active | |
| Retest criterion and method | |
| Retest evidence owner | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route / blocked / accepted-risk / retest-required) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used, the target/category is unsupported, production testing was requested, or the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected target/category | |
| Unsupported or unverified method/control | |
| Equivalent customer-owned assurance route if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Release impact | |
| Retest criterion | |
| Review trigger | |

## Backlog and handoff

Create a red-team remediation backlog item for each missing authorization field, ROE gap, SOC/legal contact, stop condition, evidence location, unsupported method, unsupported target, threshold gap, severity owner, remediation owner, accepted-risk authority, retest criterion, production-test request, or exception approval.

Handoff to red-team lead, security owner, SOC, legal/risk owner, remediation owner, evaluation owner, product owner, release manager, and lifecycle/catalog owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "review non-production agent jailbreak category"; evidence location "customer-approved ROE reference, native scorecard/run-record reference, threshold sidecar reference, severity-owner decision, remediation backlog item, and retest criterion"; accepted when the severity owner and remediation owner accept the finding route and retest closure criteria.
