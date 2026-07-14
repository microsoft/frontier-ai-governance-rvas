# S5 · Adversarial Testing Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Validate AI Red Teaming Agent availability before use in [Product Status](../reference/product-status.md).

This page explains the safety-testing model behind S5. The [S5 Runbook](index.md) contains the authorization gates and operational sequence.

## Red teaming tests a defined safety objective

AI red teaming is a structured adversarial exercise: the team defines a permitted target, attack categories, success criteria, limits, and response path before testing begins. Its purpose is to find weaknesses while the customer can safely observe, contain, and remediate them—not to demonstrate that an attacker can cause harm.

The S5 boundary is strict: use an authorized, customer-owned, non-production endpoint with written rules of engagement and a notified SOC. The curriculum uses benign placeholders rather than harmful payloads.

## PyRIT makes attacks and scoring repeatable

PyRIT is Microsoft's open-source Python Risk Identification Toolkit. Its building blocks include datasets, attacks or orchestrators, converters, targets, scoring, and memory.[^pyrit] These components make a test repeatable: another operator can understand what was attempted, how the target responded, and why a result counted as a success.

An orchestrator can exercise multi-turn strategies such as Crescendo, where pressure is gradually increased rather than delivered in a single direct request. Repetition matters because a one-off prompt does not reveal whether an issue is systematic.

## Attack Success Rate is a decision aid

Attack Success Rate (ASR) is the proportion of attempts that meet the pre-agreed adversarial success condition. Lower is better, but an ASR number is meaningful only alongside its category, sample size, target version, and threshold.

**In the Runbook:** agree thresholds before the scan. A result above tolerance becomes a remediation item with an owner; a result below tolerance is evidence for the tested scope, not a proof that the system is secure.

## Indirect prompt injection crosses a trust boundary

Indirect prompt injection, sometimes called XPIA, occurs when untrusted content from a retrieved document, web page, email, ticket, or tool output contains instructions that conflict with the agent's intended policy. This is especially relevant for agents that retrieve information and call tools.

Testing it helps teams assess whether their application separates trusted instructions from untrusted data and whether controls such as tool scoping, retrieval filtering, and runtime safety layers respond as intended.

## Managed and open-source paths are complementary

Microsoft Foundry's AI Red Teaming Agent is a managed, preview capability that can produce ASR-oriented results across categories and strategies. PyRIT remains the underlying open-source toolkit and can be used through local and cloud-supported paths.[^airt]

**Common misconception:** a managed scan removes the need for governance. The customer still owns authorization, target scope, safe data, alert handling, evidence retention, and remediation decisions.

[^pyrit]: Azure/PyRIT - [Python Risk Identification Toolkit](https://github.com/Azure/PyRIT).
[^airt]: Microsoft Learn - [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/foundry/concepts/ai-red-teaming-agent).
