# S6 Takeaway Kit: Security Runtime

S6 produces one runtime proof: a redacted record that a
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
decision. Use
[`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md)
to record the runtime-safety, threat-response, and gateway-correlation option
selected, the rationale, and the adoption stage.

Use `templates/runtime-control-matrix.template.md` to assign each relevant risk
to a selected identity/network, gateway, model/agent, or tool boundary; record
the expected action, control/response owner, evidence expectation, and
capability limit. It complements rather than replaces the gateway-proof review.

## Workshop alignment

Use the [S6 practical activity](../../docs/s6-security-runtime/practical.md)
to establish roles, the 90-minute timebox, entry condition, interpretation, and
decision before following this runbook. The customer platform operator performs
the request; customer platform and security reviewers, not the facilitator,
correlate it and decide whether the canonical gateway proof is accepted.

## Using the proof record

The customer platform and security owners correlate the manifest's
`correlation_id` with their gateway telemetry and record an accept, reject, or
blocked decision in their approved evidence system. Only an accepted, `pass`
gateway proof may be cited in an agent-admission decision. Keep the technical
decision record with the customer's approved evidence. Do not commit the
manifest or customer records to this repository.
