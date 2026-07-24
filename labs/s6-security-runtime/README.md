# S6 Security Runtime Work Package

This lab kit is a practical Microsoft-platform work package to connect prompt, gateway, posture, detection, telemetry, and incident controls for runtime operation. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, and Application Insights.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the APIM AI Gateway policy, Prompt Shields configuration, Defender for Cloud AI posture finding, Defender XDR/Sentinel incident route, and Application Insights correlation fields;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/gateway-correlation-review.template.md`](templates/gateway-correlation-review.template.md) | Capture the gateway correlation review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/runtime-control-matrix.template.md`](templates/runtime-control-matrix.template.md) | Capture the runtime control matrix as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to security engineering, SOC, platform operations, and application owner. Create a runtime-security backlog item for each missing gateway policy, prompt shield, posture finding owner, detection rule, incident route, or telemetry correlation field.

Example: Work item “correlate prompt shield event to Sentinel case”; evidence location “Application Insights operation id and Sentinel incident”; accepted when SOC can trace and triage the event.
