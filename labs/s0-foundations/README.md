# S0 Foundations & Operating Model Work Package

This lab kit is a practical Microsoft-platform work package to baseline the AI governance operating model and route the first owned backlog. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the customer governance charter, AI CoE/RACI record, control-framework baseline, and approved decision register location;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Additional kit materials

- `coe/operating-model.md`: operating-model canvas for the AI CoE/RACI handoff.

## Handoff

Default handoff goes to AI governance lead, executive sponsor, and the next session owner. Create a foundation backlog item with selected operating model, baseline framework, accountable owner, acceptance test, target date, and receiving governance process.

Example: Work item “approve hub-and-spoke AI governance model”; evidence location “customer decision register FG-001”; accepted when the sponsor signs the RACI and S1/S2 owners accept their backlog.
