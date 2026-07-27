# Decision Record

Copy this template into the customer's approved records system. Use it to record the required customer decision for S13 Portfolio Governance.

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

Default path: **Agent 365 and control-plane records, Azure Cost Management, operating evidence, and the S0 re-baseline**

Inspect: inspect Agent 365/control-plane inventory, exception register, Azure Cost Management view, operating evidence from S11, roadmap, and S0 baseline record. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | Agent 365 and control-plane records, Azure Cost Management, operating evidence, and the S0 re-baseline | | | | | |

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

- Exception Register
- Governance Roadmap
- Portfolio Review


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

Create a portfolio-governance backlog item for each unowned exception, stale control-plane record, unfunded roadmap item, missing operating evidence, or re-baseline trigger.

Handoff to portfolio governance board, finance/FinOps owner, control-plane steward, and session owners. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.

## Filled example

Work item “close expired exception EX-007”; evidence location “exception register and roadmap item”; accepted when owner, funding decision, target date, and re-baseline impact are recorded.
