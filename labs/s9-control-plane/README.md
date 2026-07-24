# S9 Control Plane Work Package

This lab kit is a practical Microsoft-platform work package to make agent, identity, API, ownership, and telemetry records discoverable and stewarded. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, and platform telemetry.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the Agent 365 or agent catalog record, Entra Agent ID/workload identity, API Center entry, ownership metadata, telemetry reference, and stewardship cadence;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/catalog-stewardship.template.md`](templates/catalog-stewardship.template.md) | Capture the catalog stewardship as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Additional kit materials

- `assessment/closeout-backlog.md`: closeout backlog structure for stale or missing control-plane records.
- `assessment/exit-rescore.md`: exit rescore checklist for control-plane maturity.

## Handoff

Default handoff goes to control-plane steward, identity owner, API platform owner, and portfolio governance. Create a control-plane backlog item for each missing catalog record, owner, identity link, API dependency, telemetry pointer, stale record, or review cadence.

Example: Work item “link agent record to API dependency”; evidence location “Agent 365 record and API Center entry”; accepted when steward review shows owner, identity, and telemetry links.
