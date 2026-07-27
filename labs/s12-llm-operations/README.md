# S12 LLMOps Lifecycle Work Package

This lab kit helps the customer make one bounded Microsoft-platform governance decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own records, chooses the decision, and keeps completed evidence in its approved records system.

**Microsoft default:** Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection

Start with [runbook.md](runbook.md). Copy only the required blank decision record into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the data-curation record, experiment/candidate artifact, Foundry evaluation, validate/deploy release record, inference route, Azure Monitor/Application Insights signal, and governed feedback route;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Required record

| Record | Use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the session decision, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |

## Handoff

Handoff to data owner, experiment owner, evaluation owner, platform/change owner, service operations, and governance owner. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.
