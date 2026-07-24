# S3 Platform Foundation Work Package

This lab kit is a practical Microsoft-platform work package to confirm the Azure landing-zone, Foundry, gateway, network, and monitoring boundary before build work proceeds. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, and Azure Monitor.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the landing-zone subscription/resource group, Foundry project, API gateway configuration, private networking route, Azure Policy assignment, and Azure Monitor workspace;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/platform-boundary-review.template.md`](templates/platform-boundary-review.template.md) | Capture the platform boundary review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/platform-control-profile.template.md`](templates/platform-control-profile.template.md) | Capture the platform control profile as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/runtime-assurance-handoff.template.md`](templates/runtime-assurance-handoff.template.md) | Capture the runtime assurance handoff as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to cloud platform team, network/security team, and application delivery owner. Create a platform-foundation backlog item for each missing boundary control, environment separation, network route, policy assignment, monitor, or runtime handoff.

Example: Work item “route PRE inference through APIM AI Gateway”; evidence location “APIM policy record”; accepted when PRE traffic has private network, policy, and monitor references.
