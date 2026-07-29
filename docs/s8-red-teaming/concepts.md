# S8 · Adversarial Testing Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md) and current Microsoft Learn pages before delivery.

This page explains the safety-testing model behind S8. [S8 Prepare](index.md), [technical decisions](technical.md), and the lab runbook contain the operational gates and customer-operated sequence.

## Red teaming tests a defined safety objective

AI red teaming is an authorized defensive misuse test. The customer defines the target, categories, success criteria, limits, contacts, stop conditions, evidence handling, and response path before testing starts.

The goal is to find weaknesses while the customer can observe, contain, fix, and retest them. The workshop does not provide attack datasets, live endpoint clients, credentials, production tests, or bypass instructions.

S8 is limited to an authorized, customer-owned, non-production endpoint with written rules of engagement and a notified SOC. The customer chooses and keeps the test data, prompts, outputs, scorecards, thresholds, and success criteria.

## Authorization is the control, not paperwork

Authorization prevents a useful safety test from becoming unbounded activity. A complete rules-of-engagement record names:

- target, version, environment, owner, and reset or rollback path;
- permitted operators, tools, categories, timing, and monitoring window;
- prohibited activity, data boundaries, stop condition, and escalation contact;
- SOC contact and legal/risk contact where required;
- evidence location, retention owner, and who may see prompts, outputs, and findings;
- severity owner, remediation owner, accepted-risk authority, and retest criterion.

If any item is missing, S8 records `defer`, `route`, or `blocked` instead of starting or accepting the test.

## Attack Success Rate is a decision aid

![Authorized attacks produce an ASR compared with a threshold; outcomes route to remediation or tested-scope support.](../assets/diagrams/s8-red-teaming-asr-decision.svg)

Attack Success Rate (ASR) is the share of attempts that meet the agreed adversarial success condition. Lower is better, but the number only makes sense with its category, sample size, target version, prompt set, method, and approved threshold.

A result above tolerance becomes a remediation item with severity owner and re-test criterion. A result below tolerance supports only the tested scope and does not approve production release. Empty or synthetic results are not safety proof unless the scope, sample, method, reviewer, and limitations are recorded.

For each category, ask five plain questions: what behavior did we test, what counted as success, why would that response be unacceptable, who owns the severity/remediation decision, and what would prove the fix worked?

## Findings become remediation backlog

S8 should recommend a remediation, accepted-risk, blocked, rejected, routed, or re-test path with confidence and assumptions. Typical backlog rows include AI Red Teaming Agent, PyRIT, or manual path; authorization and rules of engagement; SOC/legal contact; category threshold; severity owner; control owner; validation reference; re-test criteria; operating alert update; runtime, evaluation, catalog, and portfolio handoff; and release blocker.

A backlog item is useful only when a receiving owner can act on it. Each item should name the affected category, tested scope, severity, proposed control owner, evidence reference, acceptance test, target date, stop condition if risk remains active, and next review trigger.

The backlog authorizes only the written test scope; production release needs the customer's release process.

## Native scorecard and threshold review are different records

The Foundry AI Red Teaming Agent produces the native scorecard for the run. S8 preserves that output unchanged in the customer's approved records system.

If a customer reviews native ASR values against approved thresholds, the kit may write a comparison sidecar that references the native scorecard. The sidecar helps the decision owner. It is not an alternate scorecard and it does not transform Foundry evidence.

PyRIT or manual paths should keep the same boundary: preserve the customer-owned run record, then create a separate decision note that maps findings to threshold, severity owner, remediation route, and retest criterion.

## Managed testing does not remove governance

AI Red Teaming Agent is subject to target, region, license, preview, and service-status constraints. If it is unavailable or unsupported, S8 provides no mock substitute. An authorized PyRIT or manual path uses the same written scope, safe target, SOC awareness, retained evidence, severity owner, and owned remediation.[^airt][^pyrit]

Unsupported targets should be routed, not forced into a prepared demonstration. Production-test requests should be deferred to the customer's legal, SOC, business, and change process.

[^airt]: Microsoft Learn - [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/foundry/concepts/ai-red-teaming-agent).
[^pyrit]: Microsoft - [PyRIT](https://github.com/microsoft/PyRIT).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Prompt Shields, Defender, and ASSERT context that can inform a customer-authorized testing and remediation path.
