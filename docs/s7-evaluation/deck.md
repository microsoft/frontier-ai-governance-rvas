# S7 · Evaluation & Assurance

**Facilitator deck**

AI developer / maker · Governance lead · 90-minute assurance handoff

## The release question

> **"Can this pilot keep moving with accepted S6 proof and a referenced evaluation plan?"**

Record `continue` or `hold`, the decision owner, and next action.

Note:
This is an assurance handoff, not an evaluation run, CI/CD gate, deployment authorization, or runtime-control change.

---

## What supports the decision

![S6 proof and evaluation drive a continue-or-hold decision.](../assets/diagrams/s7-evaluation-release-handoff.svg)

- Accepted S6 gateway proof establishes the production-path control.
- A customer evaluation plan defines the behavior under review.
- Foundry evaluations and agent evaluators can inform the decision; they do not replace S6 proof.

Note:
A fixture score, local scorecard, or proposed CI gate is useful input, not gateway-enforcement proof.

---

## Plan and threshold discipline

- Name the scenario, version, population, evaluator or rubric, and coverage limit.
- Thresholds need an owner, baseline, regression response, and decision route.
- Record fine-tuned versions and policy comparisons separately.
- A synthetic load test is assurance input; production reconciliation goes to S11.

Note:
Keep evaluator results bounded to their dataset, rubric, and tool or policy scope.

---

## Entry and stop condition

- **Entry:** accepted S6 gateway-proof manifest with `result: "pass"`; reviewer acceptance; assurance and decision owners; evaluation-plan reference; approved records location.
- **Stop:** missing S6 acceptance, reviewer, plan, decision owner, valid handoff record, or evidence location.
- Record `hold` or blocked status with owner and review date.

---

## Step 1: Set the room · 20 min

> **"Which accepted S6 decision are we using, and what can this record support?"**

Confirm pilot scope, evidence boundary, decision owner, and the technical choice in scope: evaluation approach, release gate, or performance evidence.

---

## Step 2: Create the sign-off record · 30 min

- Customer assurance owner follows `labs/s7-evaluation/runbook.md`.
- Copy the applicable templates into the approved customer records system.
- Record safe references and validate the outcome against `contracts/assurance-handoff.schema.json`.

Note:
The facilitator can explain fields but does not create the record or substitute evaluator output.

---

## Step 3: Interpret references · 15 min

> **"Can a later reviewer find the S6 proof, status caveat, and evaluation plan?"**

- Confirm the S6 decision is accepted.
- Separate the plan from results, scores, and proposed gates.
- For each in-scope dimension: quality, groundedness, safety, tool use, regression, human review: record scope, limit, and owner.

---

## Step 4: Decide · 15 min

- `continue` requires a complete handoff contract, accepted S6 proof, and decision reference.
- Otherwise record `hold` or defer with an owner and review date.

---

## Step 5: Hand over · 10 min

Read back the S6-proof, technical-decision, and evaluation-plan references; outcome; owner; and review date. Keep the completed record in the customer system.

---

## Verification and handoff

- [ ] S6 proof conforms to the gateway-proof contract and is accepted.
- [ ] Technical decision, evaluation plan, outcome, and decision reference are recorded.
- [ ] Any quality-threshold decision is referenced.

Save only safe references in the generated delivery workspace. S7 changes no evaluator, agent, or CI/CD gate; customer-owned release processes own later implementation.
