# Decision Record

Copy this template into the customer's approved records system. Use it to record the required customer decision for S8 Red Teaming.

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

Default path: **AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes**

Inspect: inspect the red-team plan/run record, PyRIT or AI Red Teaming Agent finding, Azure AI Content Safety result, Defender/Sentinel case, and remediation owner record. Confirm the record exists, has an accountable owner, names the environment/scope, and can be referenced from the customer record system.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes | | | | | |

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

- Technical Decision Record


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

Create a red-team remediation backlog item for each confirmed finding, missing safety control, unowned risk, retest requirement, or SOC escalation route.

Handoff to red team lead, safety owner, SOC, product owner, and release manager. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.

## Filled example

Work item “remediate jailbreak finding RT-014”; evidence location “red-team finding and retest record”; accepted when the safety owner confirms the control and SOC route.
