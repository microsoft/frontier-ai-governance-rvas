# S10 In-Process Governance Work Package

This lab kit is a practical Microsoft-platform work package to decide whether in-process checks are needed after gateway and platform controls are exhausted. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Agent Governance Toolkit only when gateway controls cannot make the needed in-process decision.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the existing gateway/platform control, the runtime decision point, Agent Governance Toolkit applicability record, policy owner, and evidence route;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/applicability-review.template.md`](templates/applicability-review.template.md) | Capture the applicability review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to agent engineering owner, policy owner, runtime operations, and release manager. Create an in-process-governance backlog item only for decisions the gateway cannot enforce; include policy owner, runtime evidence, test, target date, and rollback route.

Example: Work item “add in-process policy for tool result summarization”; evidence location “Agent Governance Toolkit policy record”; accepted when gateway limits are documented and release owner approves rollback.
