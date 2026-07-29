# S8 Red Teaming Work Package

This lab helps the customer make one bounded adversarial-testing, remediation, and retest decision. The facilitator guides the method; the customer inspects or operates its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, endpoint clients, credentials, attack datasets, native scorecards, run records, incident payloads, or production approval claims in this repository. Do not run production tests or change tenant configuration during the lab.

## Entry condition

Bring one bounded non-production target, target version, target owner, decision owner, red-team operator, SOC contact, legal/risk contact where required, evidence owner, category-threshold owner, severity owner, remediation owner model, retest owner, approved records location, and written rules of engagement. If any hard-gate owner, authorization, stop condition, or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the authorized target card, rules of engagement, method route, threshold/severity interpretation, finding record, remediation map, retest closure, safe evidence references, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned red-team remediation package that summarizes:

- **Authorized target card:** target, target type, version, non-production environment, owner, scope, dependencies, monitoring window, reset/rollback path, production-impact exclusion, evidence owner, and approved records location.
- **Rules of engagement:** authorization reference, operators, methods/tools, permitted categories, excluded categories, data limits, prohibited activity, stop conditions, SOC/legal contacts, evidence handling, visibility limits, and retention owner.
- **Method route:** AI Red Teaming Agent support status or approved PyRIT/manual/third-party alternate path, with operator, support caveat, category coverage, cost/coverage limits, and safe evidence reference.
- **Threshold and severity interpretation:** ASR or qualitative result, category threshold, sample/context note, not-comparable/disputed handling, threshold owner, severity rationale, and accepted-risk authority.
- **Finding record:** category, technique, affected route, target version, evidence reference, impact, exploitability, exposure, detectability, severity, limitation, release/backlog impact, owner, and retest criterion.
- **Remediation map:** owner and acceptance criteria for Prompt Shields/Content Safety, gateway, app/prompt design, tool/API permission, data/retrieval path, identity, in-process policy, SOC detection, evaluation, lifecycle/catalog, accepted risk, release hold, or blocked route.
- **Retest closure:** retest method, changed target version, comparison rule, evidence owner, closure owner, remaining risk, target date, and reopen trigger.
- **Blockers and backlog:** missing ROE, SOC/legal contact, stop condition, supported method, category threshold, severity owner, remediation owner, retest criterion, evidence location, exception approval, or production-test request captured with owner, acceptance test, target date, and review trigger.
- **Handoff:** red-team lead, target owner, security owner, SOC, legal/risk owner, remediation owner, retest owner, product owner, and release/lifecycle owner accept the decision or backlog with clear acceptance criteria.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Authorized target | Target, type, version, environment, owner, scope, excluded dependencies, reset/rollback, monitoring, production-impact exclusion, approved records location. |
| Rules of engagement | Authorization, operators, methods/tools, categories, excluded categories, data limits, prohibited activity, stop conditions, contacts, evidence handling, retest criteria. |
| Method route | AI Red Teaming Agent, PyRIT, manual, third-party, unsupported route, production-test request, or blocked route; support status; operator; category coverage; limitation. |
| Attack category | Direct/indirect prompt injection, sensitive-data disclosure, tool abuse, hallucination, harmful content, protected material, cost/availability, unauthorized access, or customer-approved custom category. |
| Threshold/severity | ASR or qualitative result, sample/context note, threshold/tolerance, disputed/not-comparable status, impact, exploitability, exposure, detectability, response burden, release impact. |
| Finding | Category, technique, severity, exploitability, exposure, affected route, evidence reference, owner, remediation route, release impact, stop condition, retest criterion. |
| Remediation | Control owner, remediation hypothesis, acceptance test, target date, blocker or accepted-risk status, remaining risk, handoff process. |
| Retest | Method, target version, category, criterion, comparison rule, owner, evidence reference, acceptance owner, limitation, remaining risk, reopen trigger. |

## Facilitation flow

1. Confirm the customer has approved written authorization, a customer-owned non-production target, owners, stop condition, SOC/legal contacts where required, and an approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Keep only safe references in this repository.
3. Build the authorized target card and rules-of-engagement package before discussing method or scores.
4. Select the Microsoft control path: **AI Red Teaming Agent where supported; PyRIT/manual approved alternate; Azure AI Content Safety/Prompt Shields; Defender/Sentinel; SOC remediation routes**.
5. Ask: **Which customer-owned record proves this authorized finding is ready to remediate, accept, reject, route, block, or retest, and who operates it next?**
6. Interpret ASR or qualitative findings only against approved category thresholds, sample/context notes, and severity model.
7. Create a red-team remediation backlog item for each confirmed finding, missing safety control, unowned severity, missing threshold, unsupported target, SOC escalation route, retest requirement, production-test request, or exception approval.
8. Handoff the completed decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the authorized target, method route, threshold interpretation, severity owner, remediation route, retest criterion, evidence reference, acceptance test, and handoff are complete for the tested scope.
- **Remediation required** when a finding exceeds tolerance or severity requires a fix before continued release/change activity.
- **Retest required** when a fix, target change, threshold dispute, or not-comparable result must be verified.
- **Accepted risk** when the customer-authorized risk owner accepts residual risk with expiry, review trigger, evidence reference, and compensating action where required.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the target, method, or category cannot be tested safely or cannot meet the bounded objective.
- **Route** when legal, SOC, business, risk, platform, app, data, evaluation, lifecycle, release, or exception owner must decide first.
- **Blocked** when authorization, non-production scope, SOC/legal contact, stop condition, evidence handling, threshold, severity owner, or retest path prevents a decision.

## Session-specific considerations

When completing the shared decision record, capture the authorization reference, target card, ROE package, AI Red Teaming Agent/PyRIT/manual/third-party method, unsupported-target rationale, threshold comparison, severity owner, remediation route, stop condition, retest criterion, accepted-risk authority, and release/backlog impact.

## Handoff

Handoff to red-team lead, target owner, security owner, SOC, legal/risk owner, remediation owner, retest owner, product owner, release manager, and lifecycle/catalog owner. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.
