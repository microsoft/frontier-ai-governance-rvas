# Decision Record

Copy this template into the customer's approved records system. Use it to record the required customer decision for S5 Tool & API Governance.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Decision owner | |
| Implementation owner | |
| Evidence owner | |
| Approved records location | |
| Target date | |

## Microsoft control path

Default path: **Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls**

Inspect: inspect the API Center entry, APIM product/API policy, Entra app/JWT validation, access contract, connector approval, and MCP publication record. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls | | | | | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Next review trigger | |

## Required considerations

Use the prompts below only to make the single decision complete. Do not create separate customer records unless the receiving owner asks for them.

- Catalog Record
- Review Decision


## Session-specific prompts

Use this table to preserve the lesson-specific questions or prompt references that shaped the decision. Keep the entries short and references-only; do not paste sensitive prompts, outputs, or customer data.

| Prompt or question | Customer answer / reference | Decision impact |
|---|---|---|
| | | |

## Exception

Complete this section only when the Microsoft default is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Equivalent control | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |

## Backlog and handoff

Create a tool/API backlog item for missing catalog metadata, owner, auth contract, APIM policy, connector approval, MCP publication guardrail, or consumer review.

Handoff to API platform owner, tool owner, identity owner, and consuming-agent owner. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.

## Filled example

Work item “publish claims lookup API”; evidence location “API Center entry and APIM product”; accepted when Entra/JWT, schema, throttling, and consumer contract are approved.
