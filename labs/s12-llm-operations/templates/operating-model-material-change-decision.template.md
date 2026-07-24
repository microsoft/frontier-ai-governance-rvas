# Operating model material-change decision

Copy this template into the customer's approved records system. Use it to decide whether an LLMOps lifecycle change is safe to approve, defer, reject, or route.

> **Safety boundary:** Use safe references only. Do not enter prompt text, model outputs, customer data, secrets, live configuration, telemetry exports, or personal data in this repository.

## Microsoft control path

Default path: **Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**.

Inspect the affected lifecycle-stage record, Foundry evaluation or equivalent evaluation gate, customer change record, inference route, monitoring signal, and feedback/data-curation route.

| Change type | Microsoft control path | Owner | Evidence location | Accepted when | Exception | Target date | Handoff |
|---|---|---|---|---|---|---|---|
| Data/feedback change | Purview/data-curation and feedback route | | | data owner approves purpose, retention, transformation, and reuse gate | | | S2 / data curation |
| Candidate behavior change | experiment artifact plus Foundry evaluation/release decision | | | evaluation owner accepts scenario, threshold, and promotion recommendation | | | S7 / release owner |
| Retrieval or prompt configuration change | protected artifact reference and customer change record | | | rollback target and reviewer can reconstruct the release without raw prompt/output content | | | platform/change owner |
| Production-operation change | inference route, Azure Monitor/Application Insights, and operations record | | | operations owner accepts signal, alert, rollback, and support route | | | S11 / service owner |

## Decision

| Field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Decision rationale | |
| Backlog item to create | Create an LLMOps backlog item for the missing owner, gate, Microsoft record location, rollback route, feedback-to-curation control, or target date. |
| Next review trigger | production promotion, material model/prompt/data change, incident, audit, or product availability change |

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
