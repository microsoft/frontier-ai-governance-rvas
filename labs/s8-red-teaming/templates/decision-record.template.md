# Decision Record

Copy this template into the customer's approved records system. Use it to record the required adversarial-testing, remediation, and retest decision for S8 Red Teaming.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, endpoint clients, credentials, attack datasets, native scorecards, run records, incident payloads, or production approval claims in this repository. Do not run production tests or change tenant configuration during the lab.

## Authorized target card

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Adversarial-testing question | |
| Target and target type | |
| Target version | |
| Environment (must be non-production) | |
| In-scope interfaces or routes | |
| Excluded dependencies or categories | |
| Target owner | |
| Decision owner | |
| Red-team operator / facilitator | |
| SOC contact and monitoring window | |
| Legal / risk contact if required | |
| Evidence owner | |
| Category-threshold owner | |
| Severity owner | |
| Remediation owner model | |
| Retest owner | |
| Approved records location | |
| Reset or rollback path | |
| Production-impact exclusion | |
| Target date | |

## Rules of engagement

| Field | Record |
|---|---|
| Authorization reference | |
| Permitted operators | |
| Permitted categories | |
| Excluded categories | |
| Allowed methods and tools | |
| Data limits | |
| Prohibited activity | |
| Timing / duration | |
| Cost or rate limits | |
| Stop condition | |
| Escalation route | |
| SOC notification / monitoring | |
| Legal / risk handling if required | |
| Evidence handling and visibility limits | |
| Retention / export / deletion owner | |
| Retest criteria | |

## Category and method package

Default path: **AI Red Teaming Agent where supported; PyRIT/manual approved alternate; Azure AI Content Safety/Prompt Shields; Defender/Sentinel; SOC remediation routes**

| Field | Record |
|---|---|
| Method (AI Red Teaming Agent / PyRIT / manual / third-party / unsupported / production-request / blocked) | |
| Category tested | |
| Success condition for the category | |
| Support-status caveat | |
| Foundry project or approved run-record reference | |
| Native scorecard or run-record reference | |
| Threshold comparison sidecar reference if used | |
| Prompt/output/dataset storage location (customer-approved reference only) | |
| Cost / coverage / service-status limitation | |
| Alternate methods rejected and why | |

## Threshold and severity interpretation

| Field | Record |
|---|---|
| ASR or qualitative result | |
| Sample/context note | |
| Category threshold or tolerance | |
| Above / at / below / disputed / not-comparable threshold | |
| Threshold owner interpretation | |
| Impact | |
| Exploitability | |
| Exposure | |
| Detectability | |
| Response burden | |
| Severity and rationale | |
| Accepted-risk authority | |
| Limitation | |

## Finding record

| Field | Record |
|---|---|
| Finding reference | |
| Category | |
| Technique or behavior class | |
| Affected target version | |
| Affected route | |
| Evidence reference | |
| Severity | |
| Control owner | |
| Remediation route (Prompt Shields / Content Safety / gateway / app or prompt design / tool or API / data or retrieval / identity / in-process policy / SOC / evaluation / lifecycle / accepted risk / release hold / blocked) | |
| Remediation hypothesis | |
| Release or backlog impact | |
| Stop condition if risk remains active | |
| Retest criterion | |
| Target date | |

## Finding-to-control remediation map

| Finding signal | Receiving owner | Acceptance test | Evidence reference | Target date |
|---|---|---|---|---|
| Direct prompt injection | | | | |
| Indirect prompt injection | | | | |
| Sensitive-data disclosure | | | | |
| Tool abuse or unsafe action | | | | |
| Hallucination or grounding failure | | | | |
| Harmful or policy-violating content | | | | |
| Protected-material concern | | | | |
| Cost or availability abuse | | | | |
| Unauthorized access | | | | |
| Other customer-approved category | | | | |

## Retest and closure

| Field | Record |
|---|---|
| Retest required? | Yes / No |
| Retest method | |
| Same category and success condition? | Yes / No / alternate justified |
| Changed target version | |
| Comparison rule | |
| Retest evidence reference | |
| Closure owner | |
| Closure decision | |
| Remaining risk | |
| Reopen trigger | |
| Closure date | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route / blocked / remediation-required / retest-required / accepted-risk) | |
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

Handoff to red-team lead, target owner, security owner, SOC, legal/risk owner, remediation owner, retest owner, product owner, release manager, and lifecycle/catalog owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.

## Filled example

Work item "review non-production agent indirect-prompt-injection category"; evidence location "customer-approved ROE reference, native scorecard/run-record reference, threshold sidecar reference, severity-owner decision, remediation backlog item, and retest criterion"; accepted when the severity owner and remediation owner accept the finding route and retest closure criteria.
