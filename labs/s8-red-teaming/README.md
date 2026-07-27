# S8 Red Teaming Work Package

This lab helps the customer make one bounded adversarial-testing, remediation, and retest decision. The facilitator guides the method; the customer inspects or operates its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, endpoint clients, credentials, attack datasets, native scorecards, incident payloads, or production approval claims in this repository. Do not run production tests or change tenant configuration during the lab.

## Entry condition

Bring a bounded non-production target, target owner, decision owner, red-team operator, SOC contact, legal/risk contact where required, evidence owner, category-threshold owner, severity owner, remediation owner model, retest owner, and approved customer records location. If any owner, authorization, stop condition, or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`runbook.md`](runbook.md) | Step-by-step adversarial-testing review flow, including authorization, method selection, unsupported-target route, threshold interpretation, remediation owner, stop condition, retest criterion, blockers, and handoff. |
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the decision, evidence references, acceptance tests, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Authorization:** rules of engagement, target, environment, version, timing, permitted operators, categories, data limits, prohibited activity, stop condition, SOC/legal contacts, and evidence handling.
- **Test method:** AI Red Teaming Agent support status or approved PyRIT/manual alternate path, with owner, support caveat, and limitations.
- **Finding interpretation:** native scorecard or run-record reference, ASR or qualitative result, category threshold, sample/context note, severity owner, and limitation.
- **Remediation route:** owner and acceptance criteria for Prompt Shields/Content Safety, gateway, app/tool permission, data path, SOC detection, evaluation, lifecycle/catalog, accepted risk, blocked, or release impact.
- **Retest plan:** retest method, closure criterion, evidence owner, target date, stop condition if risk remains active, and acceptance owner.
- **Blockers and backlog:** missing ROE, SOC/legal contact, stop condition, supported method, category threshold, severity owner, remediation owner, retest criterion, evidence location, or exception approval captured with owner, acceptance test, target date, and review trigger.
- **Handoff:** red-team lead, security owner, SOC, legal/risk owner, remediation owner, evaluation owner, product owner, and release/lifecycle owner accept the decision or backlog with clear acceptance criteria.

## Facilitation flow

1. Confirm the customer has approved written authorization, a customer-owned non-production target, owners, stop condition, SOC/legal contacts, and an approved records location. If not, stop the decision and create a blocker backlog item.
2. Follow [`runbook.md`](runbook.md), then copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Keep only safe references in this repository.
3. Select the Microsoft control path: **AI Red Teaming Agent where supported; PyRIT/manual approved alternate; Azure AI Content Safety/Prompt Shields; Defender/Sentinel; SOC remediation routes**.
4. Ask: **Which customer-owned record proves this authorized finding is ready to remediate, accept, reject, route, block, or retest, and who operates it next?**
5. Record one result in the customer system: approve, defer, reject, route, blocked, accepted risk, remediation required, or retest required.
6. Create a red-team remediation backlog item for each confirmed finding, missing safety control, unowned severity, missing threshold, unsupported target, SOC escalation route, retest requirement, or exception approval.
7. Handoff the completed decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the authorized test path, threshold interpretation, severity owner, remediation route, retest criterion, evidence reference, acceptance test, and handoff are complete for the tested scope.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the target, method, or category cannot be tested safely or cannot meet the bounded objective.
- **Route** when legal, SOC, business, risk, platform, app, data, evaluation, lifecycle, or exception owner must decide first.
- **Blocked** when authorization, non-production scope, SOC/legal contact, stop condition, evidence handling, threshold, severity owner, or retest path prevents a decision.

## Session-specific considerations

When completing the shared decision record, capture the authorization reference, AI Red Teaming Agent/PyRIT/manual method, unsupported-target rationale, threshold comparison, severity owner, remediation route, stop condition, and retest criterion.

## Handoff

Handoff to red-team lead, security owner, SOC, legal/risk owner, remediation owner, evaluation owner, product owner, release manager, and lifecycle/catalog owner. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.
