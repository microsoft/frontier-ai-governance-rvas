# Model and prompt operations register

Copy this template into the customer's approved records system. It preserves the Microsoft Learn LLMOps lifecycle: inner loop (data curation, experimentation, evaluation) and outer loop (validate/deploy, inference, monitor, feedback/data collection).

> **Safety boundary:** Use safe references only. Do not enter prompt text, model outputs, customer data, secrets, live configuration, telemetry exports, or personal data in this repository.

## Scope and ownership

| Field | Record |
|---|---|
| LLM application/service, users, and environment | |
| Lifecycle decision under review | |
| LLMOps, data, experiment, evaluation, platform, service, governance, and evidence owners | |
| Approved records location | |
| Decision and next review date | |

## Microsoft control path

Default path: **Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**.

Inspect the data-curation record, experiment/candidate artifact, Foundry evaluation, validate/deploy release record, inference route, Azure Monitor/Application Insights signal, and governed feedback route.

| Stage | Microsoft control path | Owner | Evidence location | Accepted when | Exception | Target date | Handoff |
|---|---|---|---|---|---|---|---|
| Data curation | Purview/data governance record and approved source/provenance reference | | | source, use, transformation, retention, and S2 route are approved | | | S2 / experimentation |
| Experimentation | protected source/candidate artifact and experiment record | | | hypothesis, candidate reference, population, and decision limit are reproducible | | | evaluation owner |
| Evaluation | Microsoft Foundry evaluation or approved equivalent evaluation record | | | scenario, scorer/rubric, threshold, and release recommendation are accepted | | | S7 / validate-deploy |
| Validate and deploy | customer change record, release manifest, and deployment route | | | PRE/PRO promotion and rollback references are reconstructable | | | platform/change owner |
| Inference | inference route, deployment alias, and service operation record | | | active route has owner, limits, rollback, and support path | | | S11 / service support |
| Monitor | Azure Monitor, Application Insights, Foundry observability, or Log Analytics record | | | signals have threshold, interpretation owner, and escalation route | | | investigate / improve |
| Feedback and data collection | governed feedback queue and Purview/data-curation route | | | feedback cannot mutate data, prompts, retrieval, or model behavior without gate review | | | S2 / data curation |

## Candidate release manifest

| Control asset | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Service release/version | release/change record | | | service release is reconstructable | | service owner |
| Candidate code, prompt, retrieval, or configuration release | protected artifact reference | | | candidate is tied to experiment and evaluation references without raw prompt/output content | | experiment owner |
| Model/deployment alias and inference route | Foundry/Azure deployment or approved route record | | | active route and rollback target are known | | platform owner |
| Evaluation dataset/scenario and scorer/rubric version | Foundry evaluation record | | | thresholds and reviewer are recorded | | S7 owner |
| DEV/PRE/PRO promotion and customer change decision | customer change record | | | promotion authority accepts target environment and rollback plan | | change owner |
| Monitoring and feedback collection route | Azure Monitor/Application Insights and governed feedback record | | | monitoring and feedback have retention, privacy, and escalation owners | | S11/S2 owners |

## Exception

| Exception field | Record |
|---|---|
| Reason | |
| Equivalent control | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Implementation backlog

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Exception | Target date | Handoff |
|---|---|---|---|---|---|---|---|
| | Microsoft Learn LLMOps lifecycle | | | | | | |

Example: Work item “connect feedback to curated dataset review”; evidence location “feedback queue and S2 data-curation record”; accepted when no production observation mutates prompts or data without gate review.
