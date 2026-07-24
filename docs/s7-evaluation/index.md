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

S7 produces an evaluation and release-sign-off backlog for the customer to work on later. The recommendation says whether to continue, hold, defer, or block release progress. It also names the next owner for the Foundry evaluation target, evaluator or scorecard, dataset, trace source, threshold, CI/CD or release process, rollback route, S8 red-team dependency, or S11 operating review, after current product and feature status are verified.

## 2. Prerequisites

- An S6 manifest conforming to [`gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json) with `result: "pass"`.
- Customer platform and security reviewers who accepted the S6 proof after telemetry correlation.
- A named assurance owner and an approved customer records system.
- A customer-owned evaluation-plan reference, usually for Microsoft Foundry evaluations or agent evaluators after current availability and scope are verified.

## 3. Why this session matters

A release sign-off needs two things: proof that the runtime path is controlled, and a clear evaluation plan for the behavior you care about. S7 ties those records together.

Foundry evaluations and agent evaluators can help the customer test quality, safety, groundedness, and tool use where current availability and scope are verified. They inform the decision. They do not replace the accepted S6 gateway proof.

Read the [S7 Concepts](concepts.md) for the boundary between evaluation results and the release decision.

## 4. Detailed facilitation reference

!!! warning "Report-only / audit-first"
    A fixture score or a direct component test is not a release sign-off. S7 requires an accepted S6 gateway proof.

Read [Technical decisions](technical.md) first. It covers evaluation approach,
release-gate, and performance-evidence options and selection criteria.

**Timebox:** 90 minutes. **Entry condition:** the customer's records system contains an S6 gateway-proof manifest with `result: "pass"`, and the named platform and security reviewers accepted its telemetry correlation. The room also has an assurance owner, a decision owner, an evaluation-plan reference, and an approved records location. If S6 acceptance is missing, stop at review.

| Role | Workshop responsibility |
|---|---|
| Facilitator | Runs the sign-off method and keeps the report-only boundary. Does not evaluate an agent, operate a gate, or choose the outcome. |
| Customer assurance owner | Retrieves the accepted S6 decision and creates the customer-owned assurance record. |
| Platform and security reviewers / evidence owner | Confirm the accepted S6 proof and point to the approved references. |
| Customer decision owner | Selects `continue` or `hold` and accepts the next action. |

1. **Set the room and orient** *(20 min)*: the facilitator asks: **"Which accepted S6 decision are we using, which S7 technical decision is in scope, and what release decision can this record support without treating evaluation output as proof?"** The customer confirms the pilot scope, evidence boundary, decision owner, and what stays in the separate evaluation process.
2. **Customer creates the sign-off record** *(30 min)*: the assurance owner follows `labs/s7-evaluation/runbook.md`. They copy `templates/technical-decision-record.template.md`, `templates/evaluation-plan-review.template.md`, `templates/quality-measurement-plan.template.md` when quality dimensions or thresholds are in scope, and `templates/assurance-outcome.template.json` into the approved customer records system. They supply safe references and validate the outcome against `contracts/assurance-handoff.schema.json`. The facilitator can read required fields aloud, but does not create the customer record or substitute evaluator output.
3. **Interpret the evidence together** *(15 min)*: reviewers confirm that the S6 decision is accepted. Then they separate the evaluation-plan reference from an evaluation result or CI/CD gate. Ask: **"Can a later reviewer find the accepted S6 proof, the verified-status caveat, and the Foundry evaluation plan from these references?"** and **"Are we treating a score, fixture, or proposed gate as more than it is?"** Record a result, no-result, or blocker as a safe reference only.

   Review the evaluation plan with these questions:

   | Question type | Practical question |
   |---|---|
   | Quality or task completion | Which scenario, version, evaluator, and coverage limit support the release decision? |
   | Groundedness or retrieval quality | Which data source and answer type were tested, and what evidence remains outside scope? |
   | Safety or policy behavior | Which safety result informs the decision, and which runtime control remains separate? |
   | Tool-use or action-boundary behavior | Which allowed, denied, or escalated action was reviewed? |
   | Regression or release comparison | What changed since the prior version, and who accepts the threshold or no-result? |
   | Human review or escalation | Which reviewer decision and remaining risk are recorded? |
   | Quality dimension and threshold | Which threshold is customer-owned and approved? Who owns a regression or missing evaluator? |

   If the customer later reviews trends, connect the sign-off decision to safe references for the workload, evaluation plan or version, decision outcome, runtime correlation where applicable, and reviewer. Do not treat a score, event field, or missing record as proof of coverage.
4. **Make the customer decision** *(15 min)*: `continue` is available only when the handoff contract is complete, the referenced S6 proof decision is `accepted`, and the decision owner records a decision reference. Otherwise choose `hold` or defer with an owner and review date. Foundry evaluation work with status verified may inform the decision, but it cannot replace the accepted S6 proof.
5. **Hand over** *(10 min)*: the assurance owner keeps the completed record in the customer system and reads back the S6-proof reference, technical-decision record reference, evaluation-plan reference, outcome, decision reference, next owner, and review date. The record informs the next delivery action. It does not authorize a deployment or change a control.

**Blockers:** no accepted S6 proof, unavailable reviewers, missing evaluation plan or decision owner, invalid handoff record, or no approved evidence location. Record `hold` or **blocked** with the missing dependency, owner, target date, and next review. Do not create local substitute evidence or turn a fixture result into a sign-off.

## 5. Verification & evidence capture

- [ ] The referenced S6 proof conforms to the gateway-proof contract and has `result: "pass"`.
- [ ] Customer platform and security reviewers accepted the proof.
- [ ] The customer records system references the technical decision record created from `templates/technical-decision-record.template.md`.
- [ ] The assurance record conforms to the S7 handoff contract.
- [ ] The customer records system contains the outcome and decision reference.
- [ ] Where in scope, the quality-measurement plan and quality-threshold decision are referenced alongside the evaluation-plan review.

Save only safe references in `04-operate/evidence-register.json` and the decision in `04-operate/decision-register.json`, in the generated delivery workspace. Do not put prompts, outputs, telemetry, scores, object IDs, credentials, or customer evidence in Git.

## 6. Rollback and handoff

S7 changes no evaluator, agent, or CI/CD gate. The customer can record `hold` or replace its sign-off decision through its own change and evidence process. The completed handoff remains customer owned.
