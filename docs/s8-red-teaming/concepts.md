# S8 · Adversarial Testing Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the safety-testing model behind S8. [S8 Prepare](index.md)
contains the authorization gates and customer-operated sequence.

## Red teaming tests a defined safety objective

AI red teaming is a structured adversarial exercise: the team defines a
permitted target, attack categories, success criteria, limits, and response
path before testing begins. Its purpose is to find weaknesses while the customer
can safely observe, contain, and remediate them.

S8 is limited to an authorized, customer-owned, non-production endpoint with
written rules of engagement and a notified SOC. The customer chooses and
retains the applicable test data and success criteria.

## Attack Success Rate is a decision aid

Attack Success Rate (ASR) is the proportion of attempts that meet the
pre-agreed adversarial success condition. Lower is better, but an ASR number is
meaningful only with its category, sample size, target version, and approved
threshold.

A result above the agreed tolerance becomes a remediation item with an owner.
A result below tolerance is evidence for the tested scope, not proof that the
system is secure.

## Native scorecard and threshold review are different artifacts

The Foundry AI Red Teaming Agent produces the native scorecard for the run. S8
preserves that output unchanged. If a customer separately reviews native ASR
values against approved thresholds, the kit may write a comparison sidecar that
references the native scorecard. The sidecar is a decision aid, not an
alternative scorecard or a transformation of Foundry evidence.

## Managed testing does not remove governance

The managed AI Red Teaming Agent is a Preview capability. The customer still
owns authorization, target scope, safe test data, alert handling, evidence
retention, and remediation decisions. S8 does not provide a fallback mock or
an alternate testing path when the managed capability is unavailable.

[^airt]: Microsoft Learn - [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/foundry/concepts/ai-red-teaming-agent).
