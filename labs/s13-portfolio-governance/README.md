# S13 Portfolio Governance Work Package

This lab kit is a practical Microsoft-platform work package to roll session evidence into portfolio review, exception management, roadmap, cost, and re-baseline decisions. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** Agent 365 and control-plane records, Azure Cost Management, operating evidence, and the S0 re-baseline.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected Agent 365/control-plane inventory, exception register, Azure Cost Management view, operating evidence from S11, roadmap, and S0 baseline record;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/exception-register.template.md`](templates/exception-register.template.md) | Capture the exception register as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/governance-roadmap.template.md`](templates/governance-roadmap.template.md) | Capture the governance roadmap as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/portfolio-review.template.md`](templates/portfolio-review.template.md) | Capture the portfolio review as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to portfolio governance board, finance/FinOps owner, control-plane steward, and session owners. Create a portfolio-governance backlog item for each unowned exception, stale control-plane record, unfunded roadmap item, missing operating evidence, or re-baseline trigger.

Example: Work item “close expired exception EX-007”; evidence location “exception register and roadmap item”; accepted when owner, funding decision, target date, and re-baseline impact are recorded.
