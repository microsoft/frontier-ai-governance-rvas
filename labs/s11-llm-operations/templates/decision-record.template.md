# LLMOps Change Control Decision Record

Copy this template into the customer's approved records system. Use it to record
the required lifecycle decision for S11 LLMOps.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, datasets, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, traffic movement, alias changes, automation enablement, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## LLMOps change card

| Field | Record |
|---|---|
| Workload / capability | |
| Change type | Prompt / retrieval / tool schema / model / fine-tuning / dataset / evaluation rubric / deployment alias / fallback / feedback / retirement / automation / other |
| Lifecycle question | |
| Target customer process | |
| Environment | DEV / PRE / limited preview / expanded preview / production-change readiness / other |
| Affected artifact references | |
| Intended lifecycle stage | |
| Decision owner | |
| Data/privacy owner | |
| Experiment owner | |
| Engineering owner | |
| Evaluation baseline owner | |
| Platform/change owner | |
| Operations owner | |
| LLMOps owner | |
| Governance owner | |
| Evidence owner | |
| Approved records location | |
| Evidence limits | |
| Stop condition | |
| Review date / trigger | |

## Seven-stage lifecycle package

| Stage | Input reference | Output reference | Owner | Accepted when | Blocker | Material-change trigger | Receiving handoff |
|---|---|---|---|---|---|---|---|
| Data curation | | | | | | | |
| Experimentation | | | | | | | |
| Evaluation | | | | | | | |
| Validate/deploy | | | | | | | |
| Inference | | | | | | | |
| Monitor | | | | | | | |
| Feedback/data collection | | | | | | | |

## Release manifest

| Manifest field | Record |
|---|---|
| Release reference | |
| Workload reference | |
| Environment | |
| Change type | |
| Prompt/instruction reference | |
| Retrieval/index/query-config reference | |
| Tool/API schema references | |
| Baseline model/deployment alias | |
| Candidate model/deployment alias | |
| Fallback model/deployment alias | |
| Evaluation reference | |
| Runtime-control reference | |
| Telemetry/operating reference | |
| Rollout stage | |
| Stop condition reference | |
| Rollback target | |
| Customer change authority / approver reference | |
| Evidence limit reference | |

## Artifact version contracts

| Artifact | Safe reference | Owner | Version/provenance | Intended use | Reapproval trigger | Retirement route |
|---|---|---|---|---|---|---|
| Prompt/instruction | | | | | | |
| Model/deployment | | | | | | |
| Dataset/scenario | | | | | | |
| Evaluation rubric/scorer | | | | | | |
| Retrieval config | | | | | | |
| Tool/API schema | | | | | | |
| Deployment alias | | | | | | |
| Feedback queue | | | | | | |
| Rollout plan | | | | | | |

## Model/deployment lifecycle state

| State field | Record |
|---|---|
| Approved baseline | |
| Candidate version | |
| Fallback route | |
| Deprecated version | |
| Retired version | |
| Blocked state / reason | |
| Support owner | |
| Capacity / quota owner | |
| Cost owner | |
| Authority to approve testing | |
| Authority to approve canary or phased rollout | |
| Authority to move traffic or switch alias | |
| Authority to activate fallback | |
| Authority to roll back | |
| Authority to retire or remove a version | |
| Authority to enable automation | |

## Rollout, fallback, rollback, and retirement

| Field | Record |
|---|---|
| Stage plan | |
| Entry condition references | |
| Traffic population | |
| Excluded users / workloads | |
| Switch authority | |
| Monitoring signal | |
| Stop condition | |
| Fallback trigger | |
| Fallback target | |
| Rollback trigger | |
| Rollback target | |
| Rollback owner | |
| Retirement trigger | |
| Removal owner | |
| Dependency check | |
| Review date | |

## Feedback-to-curation gate

| Field | Record |
|---|---|
| Signal or feedback source | |
| Hypothesis | |
| Population / time window | |
| Data/privacy route | |
| Retention / consent / legal-hold note | |
| Curation rule | |
| Curation owner | |
| Candidate dataset/scenario/artifact reference | |
| Evaluation route | |
| Mutation gate | |
| Decision | Reuse / discard / investigate / block |

## Automation readiness

| Automation area | Trigger | Prerequisite evidence | Owner | Stop condition | Validation reference | Manual override | Exception path |
|---|---|---|---|---|---|---|---|
| Regression test or scenario comparison | | | | | | | |
| Canary or phased rollout | | | | | | | |
| Alias switching | | | | | | | |
| Fallback routing | | | | | | | |
| Feedback-to-curation | | | | | | | |
| Retirement/removal | | | | | | | |

## Customer decision

| Decision field | Record |
|---|---|
| Result | Ready for next process / defer / reject / route / blocked |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Receiving owner and customer process | |
| Release or backlog impact | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used or when the
customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected lifecycle stage | |
| Unsupported or unverified control | |
| Equivalent customer-owned control if one exists | |
| Owner | |
| Evidence reference | |
| Expiry / review date | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Backlog and handoff

Create an LLMOps backlog item for each missing artifact owner, lifecycle stage
owner, stage gate, release manifest field, baseline/candidate/fallback state,
switch authority, fallback trigger, rollback target, retirement owner,
monitoring owner, feedback gate, automation prerequisite, unsupported
capability, exception, access/license blocker, or approved records location.

Handoff to the receiving owner named in the customer record. The receiving owner
accepts only backlog items with clear acceptance tests, target dates, evidence
locations, exception status, affected artifact references, switch authority,
rollback/fallback trigger, retirement owner, and review trigger. Keep final
records in the customer-approved system.

## Safe filled example

Work item: "prepare candidate model rollout handoff"; evidence location:
"customer-approved curated-data reference, experiment lineage reference,
evaluation package reference, release manifest, alias record, operating signal,
fallback route, and rollback target references"; accepted when: "baseline,
candidate, fallback, switch authority, stop condition, rollback trigger,
retirement owner, automation prerequisites, exception status, and handoff are
recorded."
