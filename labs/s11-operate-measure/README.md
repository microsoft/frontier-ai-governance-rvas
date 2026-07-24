# S11 Operate & Measure Work Package

This lab kit is a practical Microsoft-platform work package to connect operational telemetry, quality, cost, latency, alerting, and remediation into customer operations. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the Foundry observability view, Azure Monitor metric/alert, Application Insights trace, Log Analytics query, Cost Management view, and FinOps review record;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/operating-review.template.md`](templates/operating-review.template.md) | Capture the operating review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/performance-telemetry-review.template.md`](templates/performance-telemetry-review.template.md) | Capture the performance telemetry review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/quality-cost-latency-review.template.md`](templates/quality-cost-latency-review.template.md) | Capture the quality cost latency review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/remediation-closure.template.md`](templates/remediation-closure.template.md) | Capture the remediation closure as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/telemetry-alert-operating-model.template.md`](templates/telemetry-alert-operating-model.template.md) | Capture the telemetry alert operating model as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to service operations, FinOps owner, platform monitoring, and product owner. Create an operations backlog item for missing telemetry, alert threshold, quality/cost/latency review, remediation owner, operating cadence, or FinOps action.

Example: Work item “add latency/cost alert for production agent”; evidence location “Azure Monitor alert and Cost Management view”; accepted when operations and FinOps owners accept the cadence.
