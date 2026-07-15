# S7 · In-Process Agent Governance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · This page describes AGT from pinned primary sources at [commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676). AGT is Public Preview.

S7 is an optional extension. Use the [S7 Prepare](index.md) chapter for the
offline workshop; use this page to explain why an in-process policy decision is
not the same as a gateway, data, identity, or outcome control.

## A different enforcement point

Citadel's Governance Hub can apply shared controls at the network and API
gateway boundary. An in-process governance library can evaluate the requested
tool action inside the agent application before the action is invoked. These
controls can be layered, but neither proves that the other is configured or
effective.

AGT's documented `govern()` pattern wraps a tool call with policy evaluation and
audit logging. That makes a policy decision at the tool-call boundary
observable. The offline S7 simulator deliberately models only this idea; it
does not import, test, or certify AGT.[^agt-readme]

## Decision evidence is not outcome evidence

A policy-and-audit record can show which policy version evaluated an attempted
action and whether it was allowed, denied, or sent for approval. A hash chain
can make later alteration of those records detectable.

That evidence has a clear boundary: AGT documents that its audit log records
attempts and governance decisions, not whether a downstream action actually
succeeded.[^agt-limitations] For example, allowing a notification tool does not
prove an email was delivered. S7 keeps this boundary explicit so audit records
are not overstated.

## A policy is a governance artifact

An allow list, deny default, and approval requirement encode decisions about
delegated authority. The policy owner must decide which tools/actions are
permitted, what requires approval, how policies change, and how records are
retained. The sample policy is intentionally generic and must not be copied
into a customer application without a separate engineering, security, and
change-review process.

The AGT limitations also note that an evaluator with no policies loaded can
allow actions by default; strict deny-by-default configuration is a production
consideration. S7 models a deny default but does not validate an AGT
configuration.[^agt-limitations]

## What S7 does not cover

S7 complements but does not replace:

- **S1 identity:** AGT's in-process identity patterns are distinct from Entra
  Agent ID and platform identity governance.
- **S2 data:** AGT does not govern retrieved knowledge provenance, freshness, or
  authorization; Purview and the S2 controls remain necessary.
- **S3 runtime security:** Citadel gateway protections, Content Safety, and
  Defender posture evidence remain the runtime-security baseline.
- **S4 evaluation and S5 adversarial testing:** policy decisions need separate
  quality/safety evaluation and authorised misuse testing.
- **S6 control plane:** an in-process audit record does not replace Agent 365,
  Entra, or API Center reconciliation.

## Preview and adoption discipline

At the pinned source revision, AGT is Public Preview and may have breaking
changes before GA. Its own documented limitations include no built-in SBOM,
knowledge-provenance governance, or turnkey UI-level human approval. These
limitations, the customer's language/runtime fit, and any relationship to
existing platform controls are decision inputs, not claims of compliance or
certification.[^agt-readme][^agt-limitations]

[^agt-readme]: [AGT README at `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/README.md), Public Preview notice, `govern()` example, and audit architecture.
[^agt-limitations]: [AGT known limitations at `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md), especially audit outcomes, knowledge governance, policy initialization, and feature boundaries.
