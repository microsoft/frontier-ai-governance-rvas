# S8 Red Teaming Work Package

This lab kit is a practical Microsoft-platform work package to route adversarial findings into Microsoft-supported safety controls and remediation. It starts with the Microsoft default control path, records the customer decision, and creates implementation backlog items that a named owner can accept.

**Microsoft default:** AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes.

Start with [runbook.md](runbook.md). Copy only blank templates into the customer's approved records system, then store completed evidence there.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, or live configuration in this repository.

## Work package outcome

By the end of the kit, the customer has:

- inspected the red-team plan/run record, PyRIT or AI Red Teaming Agent finding, Azure AI Content Safety result, Defender/Sentinel case, and remediation owner record;
- recorded approve, defer, reject, or route with owner and target date;
- created backlog for gaps using acceptance tests and a receiving handoff;
- documented any exception with reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

## Included records

| Record | Use |
|---|---|
| [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) | Capture the technical decision record as a Microsoft-platform work record with owner, acceptance, exception, target date, and handoff. |

## Handoff

Default handoff goes to red team lead, safety owner, SOC, product owner, and release manager. Create a red-team remediation backlog item for each confirmed finding, missing safety control, unowned risk, retest requirement, or SOC escalation route.

Example: Work item “remediate jailbreak finding RT-014”; evidence location “red-team finding and retest record”; accepted when the safety owner confirms the control and SOC route.
