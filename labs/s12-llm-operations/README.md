# S12 LLMOps Lifecycle Work Package

This lab kit is a practical Microsoft-platform work package to preserve the Microsoft LLMOps inner/outer loop with safe references, gates, and handoffs. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not enter prompt text, model outputs, customer data, secrets, live configuration, telemetry exports, or personal data in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the data-curation record, experiment/candidate artifact, Foundry evaluation, validate/deploy release record, inference route, Azure Monitor/Application Insights signal, and governed feedback route;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/incident-rollback-retirement-plan.template.md`](templates/incident-rollback-retirement-plan.template.md) | Capture the incident rollback retirement plan as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/model-prompt-operations-register.template.md`](templates/model-prompt-operations-register.template.md) | Capture the model prompt operations register as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/operating-model-material-change-decision.template.md`](templates/operating-model-material-change-decision.template.md) | Capture the operating model material change decision as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to data owner, experiment owner, evaluation owner, platform/change owner, service operations, and governance owner. Create an LLMOps backlog item for each lifecycle stage missing an owner, gate, Microsoft record location, rollback route, feedback-to-curation control, or target date.

Example: Work item “connect feedback to curated dataset review”; evidence location “feedback queue and S2 data-curation record”; accepted when no production observation mutates prompts or data without gate review.
