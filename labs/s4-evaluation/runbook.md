# S4 Runbook — Assurance Handoff

S4 does not operate a live evaluation or gate. Its one action is a
customer-operated assurance review and decision handoff.

1. Confirm the customer evidence system contains an S3 gateway-proof manifest
   conforming to `contracts/gateway-proof.schema.json`, with `result: "pass"`.
2. Confirm named customer platform and security reviewers have accepted that
   proof after correlating its `correlation_id` with gateway telemetry. A passed
   request without this acceptance is not an S4 entry condition.
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
