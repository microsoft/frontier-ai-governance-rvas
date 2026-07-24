# S5 Tool & API Governance Runbook

Use this runbook to facilitate a customer decision and backlog handoff. The facilitator guides the questions; the customer inspects its Microsoft records and owns all decisions.

> **Boundary:** Use safe references only. Keep customer identifiers, secrets, prompt text, model outputs, telemetry exports, and live configuration out of this repository.

## Entry condition

Bring a bounded workload or portfolio slice, the decision owner, implementation owner, evidence owner, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## 1. Inspect the Microsoft control path

Default Microsoft path: **Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls**.

Customer action: inspect the API Center entry, APIM product/API policy, Entra app/JWT validation, access contract, connector approval, and MCP publication record. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

## 2. Complete the work records

- [ ] Copy `templates/catalog-record.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.
- [ ] Copy `templates/review-decision.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.
- [ ] Copy `templates/technical-decision-record.template.md` and complete the Microsoft control path, owner, evidence location, acceptance, exception, target date, and handoff fields.

Ask: **Which Microsoft record proves this decision is ready to hand off, and who operates it next?**

## 3. Decide

Record one result:

- **Approve** when the Microsoft control path is present, owned, evidenced, and accepted by the receiving owner.
- **Defer** when a record, owner, acceptance test, or target date is missing.
- **Reject** when the proposed path cannot meet the bounded scope.
- **Route** when another Microsoft control owner must decide first.

## 4. Create implementation backlog

Create a tool/API backlog item for missing catalog metadata, owner, auth contract, APIM policy, connector approval, MCP publication guardrail, or consumer review.

Each backlog item must include Microsoft control path, owner, evidence location, accepted when, exception if any, target date, and handoff. Use this row shape:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Exception | Target date | Handoff |
|---|---|---|---|---|---|---|---|
| | Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls | | | | | | API platform owner, tool owner, identity owner, and consuming-agent owner |

## 5. Hand off

Handoff to API platform owner, tool owner, identity owner, and consuming-agent owner. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.
