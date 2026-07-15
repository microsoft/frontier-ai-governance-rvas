# S10 · In-Process Agent Governance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · This page describes AGT from pinned primary sources at [commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676). AGT is Public Preview.

S10 is an applicability-based curriculum session. Use the [S10 Prepare](index.md) chapter for the
offline workshop; use this page to explain why an in-process policy decision is
not the same as a gateway, data, identity, or outcome control.

## A different enforcement point

Citadel's Governance Hub can apply shared controls at the network and API
gateway boundary. An in-process governance library can evaluate the requested
tool action inside the agent application before the action is invoked. These
controls can be layered, but neither proves that the other is configured or
effective.

AGT's documented `govern()` pattern wraps a tool call with policy evaluation and
audit logging. The offline S10 simulator models only that policy-and-audit idea;
it does not import, test, or certify AGT.[^agt-readme]

## Hash-chain consistency is not tamper evidence

The local simulator links each record to the prior record and verifies that the
supplied record's hashes are internally consistent. A person who can replace
the record can recalculate a local hash chain, so this result alone does not
prove integrity, immutability, provenance, or later tampering.

If the customer needs tamper evidence, it must retain a signed record in
customer-managed immutable external storage under its own retention and access
controls. S10 does not configure, validate, or certify that storage.

## Decision evidence is not outcome evidence

A policy-and-audit record can show which policy version evaluated an attempted
action and whether it was allowed, denied, or sent for approval. It does not
show whether an allowed downstream action succeeded. For example, allowing a
notification tool does not prove an email was delivered.[^agt-limitations]

## A policy is a governance artifact

An allow list, deny default, and approval requirement encode decisions about
delegated authority. The policy owner must decide which tools/actions are
permitted, what requires approval, how policies change, and how records are
retained. The sample policy is intentionally generic and must not be copied
into a customer application without separate engineering, security, and
change-review.

The AGT limitations note that an evaluator with no policies loaded can allow
actions by default; strict deny-by-default configuration is a production
consideration. S10 models a deny default but does not validate an AGT
configuration.[^agt-limitations]

## Preview and offline boundary

At the pinned source revision, AGT is Public Preview and may have breaking
changes before GA. Its documented limitations, the customer's language/runtime
fit, and the relationship to existing platform controls are decision inputs, not
claims of compliance or certification.

S10 complements but does not replace S1 identity, S2 data controls, S6 runtime
security, S4 evaluation, S5 adversarial testing, or S6 reconciliation.

[^agt-readme]: [AGT README at `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/README.md), Public Preview notice, `govern()` example, and audit architecture.
[^agt-limitations]: [AGT known limitations at `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md), especially audit outcomes, knowledge governance, policy initialization, and feature boundaries.
