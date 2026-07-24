# Incident, rollback, and retirement plan

Copy this template into the customer's approved records system. Use it to connect the Microsoft LLMOps outer loop to monitoring, incident response, rollback, feedback, deprecation, and retirement.

> **Safety boundary:** Use safe references only. Do not enter prompt text, model outputs, customer data, secrets, live configuration, telemetry exports, or personal data in this repository.

## Microsoft control path

Default path: **Microsoft Learn LLMOps lifecycle: validate/deploy, inference, monitor, and feedback/data collection, linked back to data curation and experimentation through governed review**.

Inspect the release manifest, inference route, Azure Monitor/Application Insights or Foundry observability signal, incident route, rollback target, retirement decision, and feedback-to-curation record.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Exception | Target date | Handoff |
|---|---|---|---|---|---|---|---|
| Monitoring signal and alert | Azure Monitor, Application Insights, Foundry observability, or Log Analytics | | | threshold, interpretation owner, escalation route, and retention limit are accepted | | | S11 / operations |
| Incident response route | Defender/Sentinel/customer incident process plus service owner record | | | triage owner can correlate release, inference route, and observed signal | | | SOC / service owner |
| Rollback target | customer change record and release manifest | | | rollback target is approved and reconstructable without raw prompts or outputs | | | platform/change owner |
| Feedback-to-curation route | governed feedback queue and Purview/data-curation record | | | feedback cannot change prompts, retrieval, data, or model behavior without gate review | | | S2 / data owner |
| Deprecation or retirement | portfolio roadmap, service catalog, and customer change record | | | users, dependencies, rollback, archive, and communications owners accept the plan | | | portfolio / service owner |

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

## Filled example

Example: Work item “retire legacy prompt route”; evidence location “release manifest and customer change record”; accepted when the service owner verifies no active inference traffic and the rollback/archive decision is recorded.
