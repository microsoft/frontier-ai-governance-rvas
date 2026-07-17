# S7 · Evaluation & Assurance

**Facilitator deck**

AI developer / maker · Governance lead · 90-minute report-only assurance handoff

Note:
Welcome and framing. This is a report-only assurance handoff. It does not evaluate an agent, operate a CI/CD gate, authorize deployment, or change runtime controls. The entry condition is accepted S6 gateway proof. Roles in the room: facilitator, customer assurance owner, platform and security reviewers or evidence owner, and customer decision owner.

---

## The release question

> **"Can this pilot keep moving — with accepted S6 proof and a referenced evaluation plan?"**

The answer is `continue` or `hold`, with an owner and next action.

Note:
Keep the question sharp. S7 ties together two records: accepted production-path gateway proof from S6, and a customer-owned evaluation plan whose current availability and scope are verified. The outcome is a sign-off record, not a new evaluator or gate.

---

## Why this matters

- A release sign-off needs proof that the runtime path is controlled.
- It also needs a clear evaluation plan for the behavior the customer cares about.
- Foundry evaluations and agent evaluators can inform the decision.
- They do **not** replace accepted S6 gateway proof.

Note:
Set the stakes early. A fixture score, local scorecard, or proposed CI gate can be useful input, but it is not proof that the runtime gateway is enforcing the production path. The customer's decision rests on accepted S6 proof plus referenced assurance planning.

---

## Evaluation is not release sign-off

![S7 handoff: the accepted S6 gateway proof is required first, then an evaluation plan (quality, groundedness, safety, tool use, regression, human review) goes to the assurance owner who selects continue or hold; Foundry evaluations inform but do not replace the decision.](../assets/diagrams/s7-evaluation-release-handoff.svg)

S7 requires accepted S6 gateway proof first.

Note:
Walk the diagram from S6 proof to evaluation plan to assurance-owner decision. Emphasize that Microsoft Foundry evaluations and agent evaluators can review quality, safety, groundedness, tool use, and task completion. They inform a release decision; they do not prove gateway enforcement.

---

## References keep ownership with the customer

- Record references to accepted S6 proof.
- Record the evaluation plan and assurance owner.
- Store the completed record in the customer's approved evidence system.
- Do not store raw prompts, outputs, telemetry, credentials, or evaluator evidence here.

Note:
Use this slide to protect evidence handling. The S7 template records safe references and decisions. The customer owns the evidence system, retention, and interpretation. This repository should not become a shadow evidence store.

---

## Agent evaluators answer specific questions

- Name the scenario, version, population, evaluator, and limit.
- Task completion asks whether the stated task was completed.
- Tool-call accuracy asks whether the right tool and parameters were used.
- Safety / policy behavior asks whether tested behavior met the policy.
- No evaluator gives one universal quality answer.

Note:
Help the room avoid over-generalizing an evaluator result. Each evaluator category answers a practical question for a defined scenario and population. Anything outside the dataset, rubric, tool boundary, or tested safety policy remains outside scope.

---

## Quality thresholds are customer decisions

- A threshold needs an owner.
- It needs a baseline and population limit.
- It needs a regression response and decision route.
- Foundry evaluators can inform it; they do not set or approve it.
- Fine-tuned versions and policy comparisons need their own recorded scope.

Note:
If the customer discusses thresholds, keep ownership clear. Manual annotation and customer scorers are valid options. For fine-tuned models, record base version, fine-tuned version, training-data governance reference, capability goal, pre/post comparison, and owner who accepts regressions. Policy-specific guidance such as ASSERT stays contextual and needs current status verification.

---

## Synthetic load testing is assurance input

- Performance is also an assurance question.
- Record workload model and first-token / end-to-end targets.
- Capture p50 / p95 / p99, throughput, and error or saturation targets.
- Record environment-fidelity limits.
- Production drift hands off to S11.

Note:
Keep this bounded. A customer-run synthetic load test can show whether an interaction holds expected latency and throughput at expected concurrency. The load engine is referenced, not operated by this kit. A benchmark is not a service-level objective.

---

## Evaluation review becomes release backlog

- Name the release-sign-off path.
- State confidence and assumptions.
- Capture evaluator, dataset, trace source, threshold, and renewal trigger.
- Assign CI/CD, rollback, S8, or S11 owners where needed.
- Do not create a live evaluator or production approval.

Note:
Separate recommendations from implementation. The backlog may include Foundry evaluation targets, scorecards, unsupported populations, evaluation-suite versions, trace-to-dataset owners, release-gate owners, rollback routes, S8 red-team dependencies, and S11 handoff.

---

## A decision is explicit

- The assurance owner selects `continue` or `hold`.
- `continue` requires the S6 acceptance condition.
- Future evaluation or CI gates may add input.
- The customer owns how results run, store evidence, and enforce outcomes.
- Score changes do not prove release readiness or runtime enforcement.

Note:
Do not let the group drift into vague approval language. The decision is explicit, recorded, owned, and supported by references. A measured policy comparison can support a safety review, but it remains contextual. If the handoff contract is incomplete or S6 proof is not accepted, the safe answer is `hold` or defer with owner and review date.

---

## The activity — how we'll work

- **Timebox:** 90 minutes · **five steps**
- **Entry:** S6 gateway-proof manifest with `result: "pass"` and accepted reviewer decision.
- **Room:** assurance owner, decision owner, reviewers, evidence owner.
- Missing S6 acceptance? **Stop at review** and record `hold`.

Note:
Confirm preconditions before starting. The customer needs an approved records location and an evaluation-plan reference. Review the technical-decision menus for evaluation approach, release gate, and performance evidence before deciding between options.

---

## Step 1 — Set the room and orient · 20 min

> **"Which accepted S6 decision are we using?"**
> **"What release decision can this record support without treating evaluation output as proof?"**

Confirm pilot scope, evidence boundary, decision owner, and what stays separate.

Note:
This step prevents false sign-off. Name the S6 decision, the S7 technical decision in scope, the decision owner, and the separate evaluation process. If the room cannot identify these, do not proceed as if assurance is complete.

---

## Step 2 — Customer creates the sign-off record · 30 min

- Assurance owner follows `labs/s7-evaluation/runbook.md`.
- Copy the required templates into the customer records system.
- Supply safe references.
- Validate the outcome against `contracts/assurance-handoff.schema.json`.

Note:
The facilitator may read required fields aloud, but does not create the customer record or substitute evaluator output. Templates can include the technical decision record, evaluation-plan review, quality-measurement plan when in scope, and assurance outcome.

---

## Step 3 — Interpret the evidence together · 15 min

> **"Can a later reviewer find the accepted S6 proof, verified-status caveat, and Foundry evaluation plan?"**
> **"Are we treating a score, fixture, or proposed gate as more than it is?"**

Record result, no-result, or blocker as a safe reference only.

Note:
Reviewers first confirm that the S6 decision is accepted. Then separate evaluation-plan references from evaluation results or CI/CD gates. Use the plan questions for quality, groundedness, safety, tool use, regression, human review, and customer-owned thresholds.

---

## Step 4 — Make the customer decision · 15 min

- `continue` requires a complete handoff contract.
- Referenced S6 proof decision must be `accepted`.
- Decision owner records a decision reference.
- Otherwise choose `hold` or defer with owner and review date.

Note:
Foundry evaluation work with status verified may inform the decision, but it cannot replace the accepted S6 proof. If any required condition is missing, keep the outcome conservative and assign the next action.

---

## Step 5 — Hand over · 10 min

- Read back S6-proof reference.
- Read back technical-decision and evaluation-plan references.
- Name outcome, decision reference, next owner, and review date.
- Keep the completed record in the customer system.

Note:
Close cleanly. The record informs the next delivery action. It does not authorize a deployment, change a control, operate an evaluator, or create a release gate.

---

## Verification & evidence

- [ ] Referenced S6 proof conforms to the gateway-proof contract and has `result: "pass"`.
- [ ] Customer platform and security reviewers accepted the proof.
- [ ] Customer records reference the technical decision record.
- [ ] Assurance record conforms to the S7 handoff contract.
- [ ] Outcome, decision reference, and any quality-threshold decision are recorded.

Note:
Save only safe references in `04-operate/evidence-register.json` and the decision in `04-operate/decision-register.json`, in the generated delivery workspace. Do not put prompts, outputs, telemetry, scores, object IDs, credentials, or customer evidence in Git.

---

## Change boundary & hand-off

- S7 changes no evaluator, agent, or CI/CD gate.
- The customer can record `hold` or replace its sign-off decision through its own process.
- Evaluation suites, thresholds, and gates stay with the customer's release process.
- Customer-owned sign-off informs later delivery.

Note:
When stuck: no accepted S6 proof means record `hold`; no evidence reviewers means do not create local evidence; no decision reference means do not exit S7. RACI: Assurance owner is responsible, Governance lead is accountable, Platform owner and Security/SOC are consulted.
