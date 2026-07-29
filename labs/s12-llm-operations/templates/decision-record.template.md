# LLMOps Lifecycle Decision Record

Copy this template into the customer's approved records system. Use it to record the required lifecycle decision for S12 LLM Operations.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Lifecycle question | |
| Decision owner | |
| Data owner | |
| Experiment owner | |
| Evaluation owner | |
| Platform / change owner | |
| Service operations owner | |
| Evidence owner | |
| Governance owner | |
| Approved records location | |
| Target date | |

## Seven-stage lifecycle review

Default path: **Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**

| Stage | Evidence reference / owner / accepted when / blocker |
|---|---|
| Data curation | |
| Experiment | |
| Evaluation dependency | |
| Validate / deploy | |
| Inference | |
| Monitor | |
| Feedback / data collection | |

## Model rollout and lifecycle state

| Field | Record |
|---|---|
| Approved baseline model / deployment alias | |
| Candidate model or prompt versions | |
| Fallback model / route | |
| Deprecated versions | |
| Retired versions | |
| Release manifest or alias reference | |
| Canary / phased rollout criteria | |
| Traffic switch authority | |
| Fallback activation criteria | |
| Rollback trigger and target | |
| Rollback owner | |
| Retirement trigger and removal owner | |
| Monitoring signal used for rollback/fallback | |

## Automation readiness

| Automation area | Evidence required before enablement |
|---|---|
| Test automation | |
| Canary rollout | |
| Alias or traffic switching | |
| Fallback routing | |
| Feedback-to-curation | |
| Retirement or removal | |

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
| Affected lifecycle stage | |
| Unsupported or unverified control | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Backlog and handoff

Create an LLMOps backlog item for each missing data-curation owner, experiment lineage, evaluation record, validate/deploy record, inference route, monitoring signal, feedback gate, baseline/candidate/fallback state, switch authority, rollback trigger, retirement owner, automation prerequisite, unsupported capability, or access/license blocker.

Handoff to the data owner, experiment owner, evaluation owner, platform/change owner, service operations owner, and governance owner. The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, exception status, model version or deployment alias where relevant, switch authority, rollback trigger, and retirement owner. Keep final records in the customer-approved system.

## Filled example

Work item "prepare candidate model rollout handoff"; evidence location "customer-approved curated-data reference, experiment lineage reference, evaluation record, release manifest, alias record, monitor signal, and fallback route reference"; accepted when baseline, candidate, fallback, switch authority, rollback trigger, retirement owner, automation prerequisites, exception status, and handoff are recorded.
