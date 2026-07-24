# S7 Evaluation Work Package

This lab kit is a practical Microsoft-platform work package to turn quality, risk, and performance criteria into Foundry evaluation and release gates. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the Foundry evaluation run, evaluator/scorer configuration, dataset/scenario reference, CI/CD gate, release decision, and Azure Load Testing record when applicable;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/evaluation-plan-review.template.md`](templates/evaluation-plan-review.template.md) | Capture the evaluation plan review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/performance-test-plan.template.md`](templates/performance-test-plan.template.md) | Capture the performance test plan as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/quality-measurement-plan.template.md`](templates/quality-measurement-plan.template.md) | Capture the quality measurement plan as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to evaluation owner, QA/release owner, model or agent owner, and operations owner. Create an evaluation backlog item for missing scenarios, scoring thresholds, owner review, CI/CD gate, load-test coverage, or release decision evidence.

Example: Work item “gate release on safety and groundedness eval”; evidence location “Foundry evaluation run”; accepted when thresholds, owner signoff, and CI gate are recorded.
