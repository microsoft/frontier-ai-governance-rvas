# S7 Evaluation Work Package

This lab helps the customer make one bounded evaluation-gate decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system. The decision record prepares evidence for the customer's release process; it is not automatic release approval.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry condition

Bring a bounded workload or portfolio slice, decision owner, evaluation owner, implementation owner, evidence owner, release/hold owner, and the approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the evaluation decision, safe evidence references, acceptance test, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Evaluation route:** Foundry evaluator, manual rubric, CI/CD gate, load-test route, diagnostic-only route, or mixed route.
- **Scenario set:** scenario-set reference, source, owner, reviewer, time window, environment assumption, data/tool boundary, and excluded or unsupported slices.
- **Evaluator and rubric version:** Foundry evaluator, agent evaluator, scorer, prompt/rubric version, reviewer role, limitation, and evidence reference.
- **Baseline and thresholds:** baseline run or score, candidate run, comparison rule, regression tolerance, threshold owner, exception owner, and release/hold owner.
- **Gate handoff:** pipeline or manual gate mode, release/hold process, diagnostic-only limits if runtime/platform prerequisites are missing, and Azure Load Testing evidence when performance affects the decision.
- **Blockers and backlog:** missing scenario set, evaluator version, threshold owner, baseline, evidence location, load-test record, runtime or platform prerequisite, release/hold owner, access, license, or scope clarity captured with owner, acceptance test, target date, evidence location, and review trigger.

## Facilitation flow

1. Confirm the customer has a bounded scope, owners, and an approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Complete only safe references in this repository.
3. Inspect the Microsoft control path: **Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable**.
4. Select the route: Foundry evaluator, manual rubric, CI/CD gate, load test, diagnostic-only because runtime or platform prerequisites are missing, or mixed route.
5. Ask: **Which scenario set, evaluator version, threshold owner, baseline, and release/hold owner make this gate ready for handoff?**
6. Record one result in the customer system: approve, defer, reject, route, or blocked.
7. Create an evaluation backlog item for each missing scenario, scorer/rubric version, baseline, threshold owner, load-test record, CI/CD gate, runtime/platform prerequisite, exception owner, or release/hold decision path.
8. Handoff the completed decision record and backlog references to the evaluation owner, model/agent owner, release owner, runtime/platform owner when needed, and governance owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the scenario set, evaluator/rubric version, baseline, threshold owner, gate mode, release/hold owner, evidence references, exception status, acceptance test, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped evaluation path cannot meet the required control path or acceptance expectation.
- **Route** when another Microsoft control owner, runtime/platform owner, release owner, security owner, product owner, or governance process must decide first.
- **Blocked** when access, licensing, evidence location, ownership, runtime/platform prerequisites, evaluator availability, baseline, or scope clarity prevents a decision.

## Session-specific considerations

When completing the decision record, capture evaluation plan review, scenario set, evaluator/scorer version, manual rubric if used, performance test plan, baseline, threshold owner, release/hold owner, diagnostic-only limits, exception owner, and quality measurement plan references.

## Handoff

Handoff to evaluation owner, QA/release owner, model or agent owner, runtime/platform owner when prerequisites are missing, and operations/governance owner. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, exception status, and release/hold ownership. Keep final records in the customer-approved system.
