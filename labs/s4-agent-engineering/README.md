# S4 Agent Engineering Work Package

This lab kit is a practical Microsoft-platform work package to select the agent implementation path and define admission, model, rollout, latency, cost, change, and retirement controls. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Microsoft Foundry Agent Service, Copilot Studio, Microsoft 365 Copilot extensibility, or a custom Azure app path.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the Foundry agent, Copilot Studio agent, Microsoft 365 Copilot extension, or custom Azure app record plus model deployment, rollout, and release records;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/admission-record.template.md`](templates/admission-record.template.md) | Capture the admission record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/change-and-retirement.template.md`](templates/change-and-retirement.template.md) | Capture the change and retirement as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/latency-budget.template.md`](templates/latency-budget.template.md) | Capture the latency budget as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/model-selection-record.template.md`](templates/model-selection-record.template.md) | Capture the model selection record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/rollout-decision-record.template.md`](templates/rollout-decision-record.template.md) | Capture the rollout decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/token-cost-estimate.template.md`](templates/token-cost-estimate.template.md) | Capture the token cost estimate as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to agent engineering owner, product owner, platform owner, and release manager. Create an engineering backlog item for any missing admission criterion, model-selection record, token/cost guardrail, latency budget, rollout gate, or retirement trigger.

Example: Work item “select Foundry Agent Service for claims assistant”; evidence location “model-selection record”; accepted when rollout, cost, latency, and retirement gates have owners.
