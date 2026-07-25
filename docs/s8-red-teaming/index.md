# S8 · Adversarial Testing

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer has an authorized misuse-test result for one non-production agent or endpoint, plus an owner for each finding.

They leave with:

- The native Microsoft Foundry AI Red Teaming Agent scorecard, or the approved PyRIT run evidence for the authorized path.
- A customer-approved threshold-comparison sidecar when the customer performs a threshold review.
- A remediation, accepted-risk, blocked, or re-test decision with an owner and date.

`labs/s8-red-teaming/` holds the customer-operated Foundry adapter contract and runbook. Native scorecards and comparison sidecars stay as customer evidence in the approved records system. This kit does not hold endpoint clients, credentials, attack datasets, or customer evidence.

### What happens next

**Next customer action:** route the selected remediation, accepted-risk, or
re-test work through the customer security and non-production change process.

### Plain decision and default path

**Decision question:** *Approve, defer, reject, or route each authorized
adversarial-test finding to a control owner?* Approval accepts a remediation
plan or bounded risk decision; it is not production approval and does not
change a customer system.

The default is an authorized, customer-operated non-production Microsoft
Foundry AI Red Teaming Agent path where currently supported, with the native
scorecard retained by the customer. Use PyRIT, manual testing, or a third-party
engagement only when support, target type, scope, authorization, or test
coverage makes the default unsuitable. Record the exception owner, reason,
compensating authorization or review, target date, and retest criteria. Verify
current service availability and scope before use.

S8 produces a remediation backlog. The recommendation says whether to remediate,
approve, defer, reject, or route the finding. It names the owner for the AI Red Teaming Agent
or PyRIT adapter path, SOC authorization, category threshold, remediation,
runtime assurance, evaluation, operating review, or non-production change
process.

!!! warning "Safety / authorization required"
    Run adversarial activity only after SOC notification, approved written authorization and rules of engagement, and confirmation that the target is a customer-owned **NON-PRODUCTION** test agent/endpoint.

## 2. Prerequisites

- Written authorization, rules of engagement, and a named SOC contact and monitoring window.
- A customer-owned non-production endpoint and an available endpoint owner.
- Foundry project access, the AI Red Teaming Agent <span class="rvas-badge rvas-preview">Preview</span>, and a customer-owned async target adapter. The kit contains no endpoint client or credentials.
- Customer-approved test categories, thresholds, evidence location, and decision owner. This kit deliberately does not ship a test dataset or threshold policy.

### Materials to prepare

- Authorization record and rules of engagement: target, timing, categories, permitted operators, stop conditions, monitoring contact, and evidence handling.
- Target context: non-production endpoint label, version, owner, rollback or reset path, and dependencies that could create alerts or instability.
- Decision aids: approved ASR thresholds, category notes, remediation owner model, accepted-risk route, blocked path, and re-test criteria.
- Reference sources to validate before delivery: the AI Red Teaming Agent concept page, Foundry red-teaming run guidance, PyRIT documentation, and customer safety/evaluation standards.

## 3. Why this session matters

Red teaming is useful only when the customer agrees on the target, success criteria, safety limits, and response path before the first probe. S8 evidence is accepted only for that exact scope.

Read the [S8 Concepts](concepts.md) for authorization, Attack Success Rate as a decision aid, and the native-scorecard boundary.

## 4. Change boundary

S8 does not deploy a production control. The customer alone pauses, resets, or
changes its non-production endpoint and follows its own cleanup, incident, and
change processes. Handoff to S6 names runtime-control findings, to S7 names
evaluation or retest evidence, and to S9 names lifecycle, ownership, and
catalog effects.
