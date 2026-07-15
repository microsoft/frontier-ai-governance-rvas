# S3 Takeaway Kit — Security Runtime

S3 produces one runtime evidence artifact: a redacted proof that a
customer-operated non-production request reached the approved gateway path.
It does not deploy, configure, or directly call Content Safety.

## Customer action

Follow [the runbook](runbook.md) to run
`scripts/test_gateway_prompt_shield.sh` through the approved gateway. The
adapter writes only the manifest defined by
[`contracts/gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json);
it never writes prompts, documents, endpoint values, credentials, telemetry, or
gateway responses.

## Handoff

The customer platform and security owners correlate the manifest's
`correlation_id` with their gateway telemetry and record an accept, reject, or
blocked decision in their approved evidence system. Only an accepted, `pass`
gateway proof may be handed to S4. Do not commit the manifest or customer
records to this repository.
