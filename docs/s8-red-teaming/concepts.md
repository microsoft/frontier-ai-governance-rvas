# S8 · Adversarial Testing Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the safety-testing model behind S8. [S8 Prepare](index.md) contains the authorization gates and customer-operated sequence.

## Red teaming tests a defined safety objective

AI red teaming is an authorized misuse test. The customer defines the target, attack categories, success criteria, limits, and response path before testing starts.

The goal is to find weaknesses while the customer can observe, contain, and fix them.

S8 is limited to an authorized, customer-owned, non-production endpoint with written rules of engagement and a notified SOC. The customer chooses and keeps the test data and success criteria.

## Attack Success Rate is a decision aid

![Authorized attacks produce an ASR compared with a threshold; outcomes route to remediation or tested-scope support.](../assets/diagrams/s8-red-teaming-asr-decision.svg)

Attack Success Rate (ASR) is the share of attempts that meet the agreed adversarial success condition. Lower is better, but the number only makes sense with its category, sample size, target version, and approved threshold.

A result above tolerance becomes a remediation item with an owner. A result below tolerance is accepted only for the tested scope.

For each category, ask four plain questions: what behavior did we test, what counted as success, why would that response be unacceptable, and what would prove the fix worked? This keeps the scorecard tied to the customer's rules of engagement.

## Findings become remediation backlog

S8 should recommend a remediation, accepted-risk, blocked, or re-test path with confidence and assumptions. Typical backlog rows include AI Red Teaming Agent or PyRIT adapter path, authorization and rules of engagement, SOC monitoring window, category threshold, above-threshold remediation owner, validation reference, re-test criteria, operating alert update, S6/S7/S11 handoff, and production-release blocker.

The backlog authorizes only the written test scope; production release needs the customer's release process.

## Native scorecard and threshold review are different records

The Foundry AI Red Teaming Agent produces the native scorecard for the run. S8 preserves that output unchanged.

If a customer reviews native ASR values against approved thresholds, the kit may write a comparison sidecar that references the native scorecard. The sidecar helps the decision owner. It is not an alternate scorecard and it does not transform Foundry evidence.

## Managed testing does not remove governance

AI Red Teaming Agent is Preview. If it is unavailable, S8 provides no mock
substitute. An authorized PyRIT path uses the same written scope, safe target,
SOC awareness, retained evidence, and owned remediation.[^airt][^pyrit]

[^airt]: Microsoft Learn - [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/foundry/concepts/ai-red-teaming-agent).
[^pyrit]: Microsoft - [PyRIT](https://github.com/microsoft/PyRIT).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Prompt Shields, Defender, and ASSERT context that can inform a customer-authorized testing and remediation path.
