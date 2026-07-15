# S4 Takeaway Kit — Evaluation & Assurance

S4 is an assurance handoff, not a live agent-evaluation gate. It contains only
the customer-owned outcome template and its contract. It does not run an
evaluator, score a fixture, create local evidence, or block a pull request.

## Customer review

Follow [the runbook](runbook.md). Before S4 can exit, the customer must have an
accepted S3 gateway proof: a `pass` manifest conforming to
[`contracts/gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json)
whose correlation was accepted by the named customer reviewers.

## Handoff

Create the customer record from
`templates/assurance-outcome.template.json` and validate its shape against
`contracts/assurance-handoff.schema.json`. Keep the completed record, any
evaluation outputs, and any future gate decision in the customer's approved
system. Do not commit them here.
