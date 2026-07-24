# S12 LLMOps Lifecycle Runbook

Use this runbook to facilitate a customer decision and backlog handoff. The facilitator guides the questions; the customer inspects its Microsoft records and owns all decisions.

> **Boundary:** Use safe references only. Keep prompt text, model outputs, customer data, secrets, live configuration, telemetry exports, and personal data out of this repository.

## Entry condition

Bring a bounded workload or portfolio slice, the decision owner, implementation owner, evidence owner, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## 1. Inspect the Microsoft control path

Default Microsoft path: **Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**.

Customer action: inspect the data-curation record, experiment/candidate artifact, Foundry evaluation, validate/deploy release record, inference route, Azure Monitor/Application Insights signal, and governed feedback route. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

## 2. Complete the work records

- [ ] Copy `templates/incident-rollback-retirement-plan.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.
- [ ] Copy `templates/model-prompt-operations-register.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.
- [ ] Copy `templates/operating-model-material-change-decision.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.

Ask: **Which Microsoft record proves this decision is ready to hand off, and who operates it next?**

## 3. Decide

Record one result:

- **Approve** when the Microsoft control path is present, owned, evidenced, and accepted by the receiving owner.
- **Defer** when a record, owner, acceptance test, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope.
- **Route** when another Microsoft control owner must decide first.

## 4. Create implementation backlog

Create an LLMOps backlog item for each lifecycle stage missing an owner, gate, Microsoft record location, rollback route, feedback-to-curation control, or target date.

Each backlog item must include Microsoft control path, owner, evidence location, accepted when, exception if any, target date, and handoff. Use this row shape:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Exception | Target date | Handoff |
|---|---|---|---|---|---|---|---|
| | Microsoft Learn LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection | | | | | | data owner, experiment owner, evaluation owner, platform/change owner, service operations, and governance owner |

## 5. Hand off

Handoff to data owner, experiment owner, evaluation owner, platform/change owner, service operations, and governance owner. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.
