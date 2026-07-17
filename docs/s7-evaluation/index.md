# S7 · Evaluation & Assurance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with an assurance record that names the accepted S6 gateway
proof, the owner, an evaluation-plan reference, and a customer decision.

Durable artifact: `labs/s7-evaluation/` - an evaluation-plan review template,
an assurance-handoff contract, and a customer-owned outcome template. It is not
a live agent evaluator or CI/CD gate.

### Implementation pathway

S7 produces an evaluation and release-assurance backlog for later
customer-owned implementation. The recommendation should state whether to
continue, hold, defer, or block release progression, and which Foundry
evaluation target, evaluator/scorecard, dataset owner, trace source,
threshold, CI/CD or release process, rollback route, S8 red-team dependency, or
S11 operating review item must be owned next.

## 2. Prerequisites

- An S6 manifest conforming to
  [`gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json) with
  `result: "pass"`.
- Customer platform and security review accepting the S6 proof after telemetry
  correlation.
- A named assurance owner and approved customer records system.

## 3. Why this session

Assurance makes the customer decision and its prerequisites reviewable. S7
records references to customer-owned evaluation work but does not claim to run
or gate it.

Read the [S7 Concepts](concepts.md) for the boundary between evaluation results
and an assurance decision.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    A fixture score or a direct component test is not an assurance exit. S7
    requires an accepted S6 gateway proof.

**Timebox:** 90 minutes. **Entry condition:** the customer records system
contains an S6 gateway-proof manifest with `result: "pass"` and the named
platform and security reviewers have accepted its telemetry correlation. A named
assurance owner, decision owner, evaluation-plan reference, and approved record
location are available. S7 stops at review if the S6 acceptance is missing.

| Role | Workshop responsibility |
|---|---|
| Facilitator | Runs the assurance method and preserves the report-only boundary; does not evaluate an agent, operate a gate, or choose the outcome. |
| Customer assurance owner | Retrieves the accepted S6 decision and creates the customer-owned assurance record. |
| Platform and security reviewers / evidence owner | Confirm the accepted S6 proof and point to authoritative references. |
| Customer decision owner | Selects `continue` or `hold` and accepts the next action. |

1. **Set the room and orient — 20 min.** The facilitator states the question:
   *Given the accepted S6 gateway proof and the customer evaluation-plan
   reference, should the customer continue or hold this bounded pilot?* The
   customer confirms the evidence boundary and authority. Ask: *Which accepted
   S6 decision is canonical? What decision is this record allowed to make, and
   what remains in the customer's separate evaluation process?*
2. **Customer-owned assurance operation — 30 min.** The assurance owner follows
   `labs/s7-evaluation/runbook.md`: copies
   `templates/evaluation-plan-review.template.md` and
   `templates/quality-measurement-plan.template.md` where quality dimensions or
   thresholds are in scope, then
   `templates/assurance-outcome.template.json` into the approved customer
   records system, supplies safe references, and validates the outcome against
   `contracts/assurance-handoff.schema.json`. The facilitator may read the
   required fields aloud but does not create the customer record or substitute
   evaluator output.
3. **Interpret together — 15 min.** Customer reviewers confirm that the S6
   decision is accepted, then separate the evaluation-plan reference from an
   evaluation result or CI/CD gate. Ask: *Does every reference let a later
   reviewer locate the accepted S6 proof and the customer-owned plan? Does any
   claimed score, fixture, or proposed gate exceed this assurance boundary?*
   Record a result, no-result, or blocker as a safe reference only.

   Review the evaluation plan across these bounded questions:

   | Question type | Interpretation prompt |
   |---|---|
   | Quality or task completion | Which scenario, version, evaluator, and coverage limit support the release decision? |
   | Groundedness or retrieval quality | Which data source, answer type, and unavailable evidence remain out of scope? |
   | Safety or policy behavior | Which safety result informs the decision, and what runtime control remains separate? |
   | Tool-use or action-boundary behavior | Which allowed, denied, or escalated action was reviewed? |
   | Regression or release comparison | What changed since the prior version, and who accepts the threshold or no-result? |
   | Human review or escalation | Which reviewer decision and residual risk are recorded? |
   | Quality dimension and threshold | Which threshold is customer-owned and approved? Who owns a regression, and what universal fallback exists if an evaluator is unavailable? |

   If the customer later reviews assurance trends, connect the assurance
   decision to safe references for the bounded workload, evaluation-plan or
   version, decision outcome, applicable runtime correlation, and reviewer.
   Do not treat a score, event field, or absent record as proof of coverage.
4. **Customer decision — 15 min.** `continue` is available only when the
   handoff contract is complete, the referenced S6 proof decision is
   `accepted`, and the decision owner records a decision reference. Otherwise
   choose `hold` or defer with an owner and review date. S7 neither certifies an
   evaluator nor makes a CI/CD gate; customer-owned evaluation work may inform
   the decision but cannot replace the accepted S6 proof.
5. **Hand over — 10 min.** The assurance owner retains the completed record in
   the customer system and reads back the S6-proof reference, evaluation-plan
   reference, outcome, decision reference, next owner, and review date. The
   record informs the customer’s next delivery action without authorizing a
   deployment or changing a control.

**Blockers:** no accepted S6 proof, unavailable reviewers, missing evaluation
plan or decision owner, invalid handoff record, or no approved evidence
location. Record `hold` or **blocked** with the missing dependency, owner,
target date, and next review; do not create local substitute evidence or turn a
fixture result into an exit.

## 5. Verification & evidence capture

- [ ] The referenced S6 proof conforms to the gateway-proof contract and has
  `result: "pass"`.
- [ ] Customer platform and security reviewers accepted the proof.
- [ ] The assurance record conforms to the S7 handoff contract.
- [ ] The customer records system contains the outcome and decision reference.
- [ ] Where in scope, the quality-measurement plan and quality-threshold
  decision are referenced alongside the evaluation-plan review.

## 6. Customer-owned rollback and handoff

S7 changes no evaluator, agent, or CI/CD gate. The customer can record `hold`
or supersede its assurance decision through its own change and evidence
process. The completed handoff remains customer owned.

## 7. Facilitator notes

- **Timing:** 90-minute workshop; the customer prepares the accepted S6 proof
  and evidence location before entry.
- **Official context:** Foundry evaluation, cloud evaluation, agent evaluator,
  and observability documentation can support customer-owned evaluation plan
  design. When reviewing agent evaluators, state the bounded question (task
  completion, intent resolution, tool-call accuracy, response quality, or
  safety) and the excluded population. For a fine-tuned model, confirm whether
  a pre/post comparison row exists. These references do not replace the
  accepted gateway proof or customer decision.
- **RACI:** Assurance owner = R, Governance lead = A, Platform owner and
  Security/SOC = C.
- **Common blockers:**
    - *No accepted S6 proof* → do not exit S7; record `hold`.
    - *No evidence reviewers* → do not create local substitute evidence.
    - *No customer decision reference* → do not exit S7.
- **Hand-off:** the customer-owned assurance decision informs subsequent
  delivery; separate evaluation and gate implementations remain customer owned.
