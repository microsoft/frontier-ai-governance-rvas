# S7 · Evaluation & Assurance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer can decide whether the pilot can keep moving, based on accepted S6 gateway proof and a referenced Foundry evaluation plan whose current availability and scope are verified.

They leave with:

- The accepted S6 gateway-proof reference, including the owner and reviewer decision.
- A reference to the customer's Microsoft Foundry evaluations or agent evaluator plan, with current availability and scope verified.
- A technical decision record reference for the selected evaluation approach, release-gate mechanism, and performance-evidence path.
- A release sign-off record that says `continue` or `hold`, names the decision owner, and records the next action.

`labs/s7-evaluation/` holds a technical-decision-record template, an evaluation-plan review template, an assurance-handoff contract, and a customer-owned outcome template. It does **not** hold live evaluators, prompt data, scores, CI/CD gates, telemetry, or customer records.

### What happens next

**Next customer action:** give the evaluation, threshold, release, or rollback
work to the named assurance and engineering owners before any release decision
progresses.

### Plain decision and default path

**Decision question:** *Approve, defer, reject, or route this bounded
evaluation, release-evidence, and performance-evidence plan?* Approval only
accepts the evidence plan and handoff; it does not approve a customer-system
change or production release.

The default is Microsoft Foundry evaluations or agent evaluators where their
current support, region, and scope fit, with an accepted S6 gateway proof and a
customer-owned human decision. Use manual scoring, policy scenarios, another
test service, or an explicit gap only when Foundry support, evaluation fit,
data handling, or coverage does not fit. Record the exception owner, reason,
compensating review, target date, and re-entry criteria. Verify current service
status before use.

S7 produces an evaluation and release-sign-off backlog. The recommendation says
whether to approve, defer, reject, or route release-progress work. It names the owner
for the Foundry evaluation target, evaluator or scorecard, dataset, trace source,
threshold, CI/CD or release process, rollback route, adversarial-testing work,
or operating review, after current product and feature status are verified.

## 2. Prerequisites

- An S6 manifest conforming to [`gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json) with `result: "pass"`.
- Customer platform and security reviewers who accepted the S6 proof after telemetry correlation.
- A named assurance owner and an approved customer records system.
- A customer-owned evaluation-plan reference, usually for Microsoft Foundry evaluations or agent evaluators after current availability and scope are verified.

## 3. Why this session matters

A release sign-off needs two things: proof that the runtime path is controlled, and a clear evaluation plan for the behavior you care about. S7 ties those records together.

Foundry evaluations and agent evaluators can help the customer test quality, safety, groundedness, and tool use where current availability and scope are verified. They inform the decision. They do not replace the accepted S6 gateway proof.

Read the [S7 Concepts](concepts.md) for the boundary between evaluation results and the release decision.

## 4. Rollback and handoff

S7 changes no evaluator, agent, or CI/CD gate. The customer can record a
deferral or replace its decision through its own change and evidence process.
Handoff to S8 names adversarial gaps and test scope; handoff to S11 names
approved evidence references, thresholds, owners, and review cadence. The
completed handoff remains customer owned.
