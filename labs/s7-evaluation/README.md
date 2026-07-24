# S7 Takeaway Kit: Evaluation & Assurance

S7 is an assurance handoff, not a live agent-evaluation gate. It contains a
customer-owned technical decision record, evaluation-plan review template,
quality-measurement-plan extension, outcome template, and contracts. It does not
run an evaluator, score a fixture, create local evidence, or block a pull
request.

**Decision:** approve, defer, reject, or route the bounded evaluation,
release-evidence, and performance-evidence plan. The default is Foundry
evaluations where current support fits, with accepted S6 evidence and a human
decision. An exception needs an owner, reason, compensating review, acceptance
criteria, target date, and S8/S11 handoff.

## Customer review

Follow [the runbook](runbook.md). Before S7 can exit, the customer must have an accepted S6 gateway proof: a
`pass` manifest conforming to
[`contracts/gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json)
whose correlation has been reviewed and accepted by named customer reviewers.
A `pass` in the manifest is test output, not reviewer acceptance.

## Workshop alignment

Use the [S7 practical activity](../../docs/s7-evaluation/practical.md)
to confirm the assurance owner, evidence reviewers, decision owner, 90-minute
timebox, and S6 entry condition. The customer creates and decides on the
assurance record; the facilitator does not operate an evaluator, certify a
score, or create a CI/CD gate.

## Handoff

Create the customer technical decision record from
`templates/technical-decision-record.template.md`, then create the
evaluation-plan review from `templates/evaluation-plan-review.template.md`.
Where quality dimensions or threshold governance are in scope, add
`templates/quality-measurement-plan.template.md` and validate the completed
quality threshold decision against
`contracts/quality-threshold-decision.schema.json`. Where synthetic performance
or load testing is in scope, add
`templates/performance-test-plan.template.md` to record the workload model,
first-token and end-to-end targets, and environment fidelity (see the
[agent performance-testing guide](../../docs/reference/performance-testing-guide.md)).
Then create the outcome
record from `templates/assurance-outcome.template.json` and validate its shape
against `contracts/assurance-handoff.schema.json`. Keep the completed records,
any evaluation outputs, and any future gate decision in the customer's approved
system. Do not commit them here. The completed outcome identifies the bounded
scope, evidence limit, decision, and next review; `continue` advances this
assurance handoff only. It does not approve a production release.
