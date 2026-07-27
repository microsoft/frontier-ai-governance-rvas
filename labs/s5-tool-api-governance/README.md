# S5 Tool & API Governance Work Package

This lab kit helps the customer make one bounded Microsoft-platform governance decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own records, chooses the decision, and keeps completed evidence in its approved records system.

**Microsoft default:** Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls

Start with [runbook.md](runbook.md). Copy only the required blank decision record into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the API Center entry, APIM product/API policy, Entra app/JWT validation, access contract, connector approval, and MCP publication record;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Required record

| Record | Use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the session decision, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |

## Handoff

Handoff to API platform owner, tool owner, identity owner, and consuming-agent owner. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.
