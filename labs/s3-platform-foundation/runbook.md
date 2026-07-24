# S3 Platform Foundation Runbook

Use this runbook to facilitate a customer decision and backlog handoff. The facilitator guides the questions; the customer inspects its Microsoft records and owns all decisions.

> **Boundary:** Use safe references only. Keep customer identifiers, secrets, prompt text, model outputs, telemetry exports, and live configuration out of this repository.

## Entry condition

Bring a bounded workload or portfolio slice, the decision owner, implementation owner, evidence owner, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## 1. Inspect the Microsoft control path

Default Microsoft path: **Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, and Azure Monitor**.

Customer action: inspect the landing-zone subscription/resource group, Foundry project, API gateway configuration, private networking route, Azure Policy assignment, and Azure Monitor workspace. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

## 2. Complete the work records

- [ ] Copy `templates/platform-boundary-review.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.
- [ ] Copy `templates/platform-control-profile.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.
- [ ] Copy `templates/runtime-assurance-handoff.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.
- [ ] Copy `templates/technical-decision-record.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.

Ask: **Which Microsoft record proves this decision is ready to hand off, and who operates it next?**

## 3. Decide

Record one result:

- **Approve** when the Microsoft control path is present, owned, evidenced, and accepted by the receiving owner.
- **Defer** when a record, owner, acceptance test, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope.
- **Route** when another Microsoft control owner must decide first.

## 4. Create implementation backlog

Create a platform-foundation backlog item for each missing boundary control, environment separation, network route, policy assignment, monitor, or runtime handoff.

Each backlog item must include Microsoft control path, owner, evidence location, accepted when, exception if any, target date, and handoff. Use this row shape:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Exception | Target date | Handoff |
|---|---|---|---|---|---|---|---|
| | Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, and Azure Monitor | | | | | | cloud platform team, network/security team, and application delivery owner |

## 5. Hand off

Handoff to cloud platform team, network/security team, and application delivery owner. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.
