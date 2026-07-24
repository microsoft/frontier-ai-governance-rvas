# S2 Data Compliance Work Package

This lab kit is a practical Microsoft-platform work package to route data use through Purview-backed classification, policy, audit, and retention controls. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, and eDiscovery.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the Purview DSPM finding, sensitivity-label policy, DLP policy, audit/eDiscovery retention setting, data source record, and data owner decision;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Additional kit materials

- `review-checklist.md`: customer checklist for Purview DSPM, DLP, labels, audit, eDiscovery, owner, and backlog readiness.

## Handoff

Default handoff goes to data owner, privacy/compliance team, and Purview administrator. Create a data-governance backlog item for each missing label, DLP rule, audit route, retention decision, or data-owner approval.

Example: Work item “label retrieval corpus”; evidence location “Purview sensitivity-label policy”; accepted when the data owner approves the label and DLP route before ingestion.
