# S7 Runbook — Assurance Handoff

S7 does not operate a live evaluation or gate. Its one action is a
customer-operated assurance review and decision handoff.

## Facilitated activity alignment

Run this sequence during the [S7 90-minute co-delivery workshop](../../docs/s7-evaluation/index.md#4-co-delivery-walkthrough).
Before step 1, the facilitator confirms a customer assurance owner, platform
and security reviewers/evidence owner, decision owner, approved record
location, and accepted S3 entry evidence. The customer performs the review and
chooses the outcome; the facilitator keeps the assurance boundary and records
the handoff.

1. Confirm the customer evidence system contains an S3 gateway-proof manifest
   conforming to `contracts/gateway-proof.schema.json`, with `result: "pass"`.
2. Confirm named customer platform and security reviewers have accepted that
   proof after correlating its `correlation_id` with gateway telemetry. A passed
   request without this acceptance is not an S7 entry condition.
3. The customer assurance owner copies
   `templates/assurance-outcome.template.json` into their approved records
   system, records only references (not raw evidence), and selects `continue`
   or `hold`.
4. Validate the completed record against
   `contracts/assurance-handoff.schema.json`. The assurance exit is complete
   only when the S3 decision is `accepted` and the customer has recorded the
   outcome and decision reference.

Customer teams may run Foundry Evaluations or introduce a CI gate separately in
their own approved delivery process. Those results do not replace the accepted
S3 gateway proof and are not produced by this kit.

**Interpret and decide:** retain only safe references to the accepted S3 proof,
evaluation plan, assurance owner, and decision. Choose `continue` only when the
handoff contract is complete and the S3 decision is `accepted`; otherwise
choose `hold`, defer, or record **blocked** with the dependency, owner, target
date, and review date. A fixture score, evaluator result, or proposed gate is
context for a customer-owned process, not an S7 exit.

For a later operating review, retain customer-held references to the bounded
workload, evaluation-plan/version, applicable runtime correlation, decision
outcome, and reviewer. Do not copy evaluation cases, scores, prompts, or
outputs into this kit.
