# S9 Control Plane Work Package

This lab kit helps the customer make one bounded Microsoft-platform governance decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own records, chooses the decision, and keeps completed evidence in its approved records system.

**Microsoft default:** Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, and platform telemetry

Start with [runbook.md](runbook.md). Copy only the required blank decision record into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the Agent 365 or agent catalog record, Entra Agent ID/workload identity, API Center entry, ownership metadata, telemetry reference, and stewardship cadence;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Required record

| Record | Use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the session decision, evidence reference, acceptance test, exception status, backlog, target date, and handoff. |

## Optional materials

These materials support facilitation, offline illustration, automation, or deeper implementation. They are not required to complete the lab decision.

| Material | Use |
|---|---|
| `optional/assessment/` | Optional supporting materials (2 files). |
| [`optional/assessment/closeout-backlog.md`](optional/assessment/closeout-backlog.md) | Optional closeout backlog structure for stale or missing control-plane records. |
| [`optional/assessment/exit-rescore.md`](optional/assessment/exit-rescore.md) | Optional S0-to-exit comparison aid when the customer chooses to re-score maturity. |
| `optional/data/` | Optional supporting materials (2 files). |
| `optional/policies/` | Optional supporting materials (1 file). |
| `optional/scripts/` | Optional supporting materials (1 file). |

## Handoff

Handoff to control-plane steward, identity owner, API platform owner, and portfolio governance. The receiving owner accepts only the backlog items with clear acceptance tests, target dates, and evidence locations. Keep the final records in the customer-approved system.
