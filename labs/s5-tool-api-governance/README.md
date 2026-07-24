# S5 Tool & API Governance Work Package

This lab kit is a practical Microsoft-platform work package to publish and approve agent tools through catalog, gateway, identity, contract, and connector controls. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the API Center entry, APIM product/API policy, Entra app/JWT validation, access contract, connector approval, and MCP publication record;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/catalog-record.template.md`](templates/catalog-record.template.md) | Capture the catalog record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/review-decision.template.md`](templates/review-decision.template.md) | Capture the review decision as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to API platform owner, tool owner, identity owner, and consuming-agent owner. Create a tool/API backlog item for missing catalog metadata, owner, auth contract, APIM policy, connector approval, MCP publication guardrail, or consumer review.

Example: Work item “publish claims lookup API”; evidence location “API Center entry and APIM product”; accepted when Entra/JWT, schema, throttling, and consumer contract are approved.
