# S1 Identity & Access Work Package

This lab kit is a practical Microsoft-platform work package to decide how agent, workload, and human identities will be represented and governed. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the Entra application or managed identity record, Agent ID/Agent 365 record when available, Conditional Access assignment, Azure RBAC scope, and identity owner record;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/identity-inventory-review.template.md`](templates/identity-inventory-review.template.md) | Capture the identity inventory review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to identity platform owner, application owner, and security operations. Create an identity backlog item for each missing agent/workload identity record, least-privilege role assignment, Conditional Access control, or owner review.

Example: Work item “register support-agent workload identity”; evidence location “Entra app record and RBAC assignment”; accepted when the app owner and identity owner verify least privilege and review date.
