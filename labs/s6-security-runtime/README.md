# S6 Takeaway Kit — Security Runtime

S6 produces one runtime evidence artifact: a redacted proof that a
customer-operated non-production request reached the approved gateway path.
It does not deploy, configure, or directly call Content Safety.

## Customer action

Follow [the runbook](runbook.md) to run
`scripts/test_gateway_prompt_shield.sh` through the approved gateway. The
adapter writes only the manifest defined by
[`contracts/gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json);
it never writes prompts, documents, endpoint values, credentials, telemetry, or
gateway responses.

Use
[`templates/gateway-correlation-review.template.md`](templates/gateway-correlation-review.template.md)
in the approved customer records system to record platform and security
reviewer interpretation of the manifest, telemetry correlation, and acceptance
decision.

## Workshop alignment

Use the [S6 co-delivery workshop](../../docs/s6-security-runtime/index.md#4-co-delivery-walkthrough)
to establish roles, the 90-minute timebox, entry condition, interpretation, and
decision before following this runbook. The customer platform operator performs
the request; customer platform and security reviewers, not the facilitator,
correlate it and decide whether the canonical gateway proof is accepted.

## Handoff

The customer platform and security owners correlate the manifest's
`correlation_id` with their gateway telemetry and record an accept, reject, or
blocked decision in their approved evidence system. Only an accepted, `pass`
gateway proof may be handed to S4. Do not commit the manifest or customer
records to this repository.
