# S7 Evaluation Evidence Work Package

This lab helps the customer build one bounded evaluation evidence package and
hand it to the right owner. The facilitator guides the method; the customer
inspects its own Microsoft records, chooses the decision, and keeps completed
evidence in its approved records system. The decision record prepares evidence
for the customer's release process; it is not automatic release approval.

> **Safety boundary:** Use safe references only. Do not place customer
> identifiers, secrets, prompt text, model outputs, datasets, evaluator exports,
> telemetry exports, live configuration, access grants, tenant changes, runtime
> proof, enforcement evidence, or production approval claims in this repository.
> Do not change tenant configuration, evaluator configuration, CI/CD gates, or
> live policy during the lab.

## Entry condition

Bring one bounded candidate change, decision owner, scenario owner, evaluation
owner, model/agent owner, threshold owner, evidence owner, release/hold owner,
rollback/remediation owner, and the approved customer records location. If any
owner or location is missing, create a blocker backlog item instead of
completing the decision.

If accepted runtime-path evidence is missing, the lab can still produce
diagnostic findings and backlog, but the record must say `diagnostic-only` and
must not be used as release reliance.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the evaluation candidate card, scenario-set package, evaluator/rubric package, baseline/threshold package, gate behavior, performance/cost evidence, findings, safe evidence references, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that
summarizes:

- **Evaluation candidate card:** workload, capability, change type, release
  question, environment, lifecycle state, owners, approved records location, and
  material-change triggers.
- **Runtime prerequisite:** accepted runtime-path evidence reference, or
  diagnostic-only boundary when the prerequisite is missing.
- **Scenario-set package:** scenario-set reference, source, owner, population,
  sampling method, reviewer, time window, environment assumption, data/tool
  boundary, included slices, excluded or unsupported slices, and re-entry
  triggers.
- **Evaluator and rubric package:** Foundry evaluator, agent evaluator, manual
  rubric/scorer, CI/CD cloud evaluation, load/performance route, diagnostic-only
  route, evaluator/rubric version, scorer configuration reference, limitation,
  interpretation owner, and fallback.
- **Baseline, thresholds, and exceptions:** baseline run or score, candidate
  run, comparison rule, selected metrics, regression tolerance, threshold owner,
  exception owner, expiry, compensating review, and re-evaluation criterion.
- **Gate behavior:** manual review, blocking CI/CD, warning CI/CD, mixed,
  diagnostic-only, or not applicable; pipeline identity, evidence storage, raw
  prompt/output handling boundary, failure behavior, override route, rollback
  owner, and release/hold owner.
- **Performance and cost package:** workload model, concurrency, latency,
  throughput, error/saturation, quota/capacity, token cost, cache/fallback, run
  reference, limitation, and operating reconciliation owner.
- **Finding-to-action map:** release blocker, accepted exception,
  diagnostic-only observation, operating hypothesis, data/retrieval backlog,
  agent/tool backlog, safety review, rollback/remediation, or repeat
  evaluation.
- **Blockers and backlog:** missing scenario set, evaluator version, threshold
  owner, baseline, evidence location, load-test record, runtime prerequisite,
  release/hold owner, rollback route, access, license, or scope clarity captured
  with owner, acceptance test, target date, evidence location, and review
  trigger.

## Facilitation flow

1. Confirm the customer has a bounded candidate change, owners, and an approved
   records location. If not, stop the decision and create a blocker backlog
   item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md)
   into the customer-owned records system. Complete only safe references in this
   repository.
3. Confirm the runtime prerequisite. If accepted runtime-path evidence is
   missing, mark the package diagnostic-only.
4. Define the scenario set: source, owner, population, sampling method,
   included/excluded slices, data/tool boundary, reviewer, time window, and
   re-entry triggers.
5. Select the evaluation route: Foundry evaluator, agent evaluator, manual
   rubric, CI/CD gate, load/performance route, diagnostic-only because
   prerequisites are missing, or mixed route.
6. Capture baseline, candidate, comparison rule, metrics, thresholds, threshold
   owner, exception owner, rollback/remediation owner, and re-evaluation
   criterion.
7. Record gate behavior and performance/cost evidence when they affect the
   release question.
8. Map each finding to action, owner, closure evidence, target date, and review
   trigger.
9. Record one result in the customer system: continue, hold, defer, reject,
   route, blocked, or diagnostic-only.
10. Handoff the completed decision record and backlog references to the
   evaluation owner, model/agent owner, release owner, runtime/platform owner
   when needed, performance owner when needed, and governance owner. Keep final
   evidence only in the customer-approved records system.

## Decision criteria

- **Continue** when the runtime prerequisite is accepted, scenario set,
  evaluator/rubric version, baseline, threshold owner, gate mode,
  release/hold owner, evidence references, exception status, rollback route,
  acceptance test, and handoff are complete.
- **Hold** when the package shows a release blocker, unacceptable regression,
  unsafe finding, threshold failure, missing rollback route, or unresolved
  high-risk slice.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence
  location, and next review trigger.
- **Reject** when the scoped evaluation path cannot meet the required control
  path or acceptance expectation.
- **Route** when another Microsoft control owner, runtime/platform owner,
  release owner, security owner, product owner, performance owner, legal owner,
  or governance process must decide first.
- **Blocked** when access, licensing, evidence location, ownership, runtime
  prerequisite, evaluator availability, baseline, rollback route, or scope
  clarity prevents a decision.
- **Diagnostic-only** when the evaluation can inform backlog but cannot support
  release reliance.

## Session-specific considerations

When completing the decision record, capture evaluation candidate card,
runtime-prerequisite status, scenario set, evaluator/scorer version, manual
rubric if used, performance test plan, baseline, threshold owner, exception
owner, release/hold owner, rollback/remediation owner, diagnostic-only limits,
finding-to-action map, and quality measurement plan references.

## Handoff

Handoff to evaluation owner, QA/release owner, model or agent owner,
runtime/platform owner when prerequisites are missing, performance owner when
latency/cost/capacity matters, rollback/remediation owner, and
operations/governance owner. The receiving owner accepts only decisions or
backlog items with clear acceptance tests, target dates, evidence locations,
exception status, diagnostic-only limits, and release/hold ownership. Keep final
records in the customer-approved system.
