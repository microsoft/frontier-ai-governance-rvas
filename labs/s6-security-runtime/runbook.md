# S6 Runbook: Gateway Proof

Run this only in a customer-approved non-production environment. The one S6
action is a request through the deployed gateway; a direct Content Safety call
is not S6 evidence.

## Facilitated activity alignment

Run this sequence during the [gateway-proof activity guide](../../docs/s6-security-runtime/practical.md).
Before step 1, the facilitator confirms the customer platform operator,
security reviewer/evidence owner, and decision owner; an approved
non-production route; safe authentication handling; an evidence location; and
a stop condition. The customer performs every operation below. The facilitator
does not receive credentials, run the request, or accept the proof.

1. Confirm the customer has approved the route, authentication handling, safe
   test input, and the record locations referenced below.
2. The customer operator runs the adapter, supplying real values only through
   their secure process:

   From the repository root, run:

   ```bash
   PILOT_AGENT_SLUG="customer-agent-np" \
   GATEWAY_ENDPOINT="https://<customer-gateway-host>" \
   GATEWAY_PATH="/<approved-route>" \
   GATEWAY_ENVIRONMENT="<customer-nonproduction-environment>" \
   GATEWAY_AUTH_HEADER_VALUE="<customer-operated-credential>" \
   GATEWAY_REFERENCE="platform-record:gateway-np" \
   ACCESS_CONTRACT_REFERENCE="contract-record:approved-route" \
   BACKEND_REFERENCE="backend-record:runtime-safety-np" \
   POLICY_REFERENCE="policy-record:gateway-policy-v1" \
   REQUEST_EVIDENCE_REFERENCE="change-record:request-window" \
   TELEMETRY_EVIDENCE_REFERENCE="telemetry-record:gateway-query" \
   EXPECTED_POLICY_BEHAVIOR="Approved gateway policy records the non-production request" \
   bash labs/s6-security-runtime/scripts/test_gateway_prompt_shield.sh \
     labs/s6-security-runtime/evidence/gateway-proof.json
   ```

3. The adapter writes `pass` only when the request completes and `fail` when it
   does not. `blocked` is a customer review decision, not an adapter result.
   The platform and security owners validate the output against
   `contracts/gateway-proof.schema.json`, correlate `correlation_id` with
   customer telemetry, and record their decision in the approved evidence
   system. `pass` means only that the adapter request completed; it is not
   accepted gateway enforcement until that review is complete.
   Copy `templates/gateway-correlation-review.template.md` into the approved
   records system to capture the manifest reference, correlation decision,
   interpretation owner, and accepted/rejected/deferred/blocked outcome. Copy
   `templates/technical-decision-record.template.md` when the customer records
   the runtime-safety, threat-response, or gateway-correlation option selected.
4. Record the runtime-control implementation backlog in the correlation review:
   gateway/APIM route or policy remediation, Content Safety or Prompt Shields
   review, telemetry correlation and retention, SOC/reviewer route, identity or
   data dependency, evaluation route, catalog/operating-record update,
   recommendation, confidence, assumptions, evidence reference or gap, owner,
   and customer process.
5. When the customer needs a defence-in-depth operating design, copy
   `templates/runtime-control-matrix.template.md` to the approved records
   system. Define risk, inspection point, selected layer, expected response,
   control/response owners, correlation expectation, and capability limit.
   The matrix is a design and follow-up record; it is not evidence of enforced
   behavior.
6. Cite the accepted proof and decision references in the customer’s
   agent-admission record when that decision needs runtime evidence. If the
   request fails or review cannot be completed, record the outcome as failed or
   blocked in the customer system; do not create substitute local evidence.

**Interpret and decide:** record safe references to the manifest, request and
telemetry records, correlation identifier, reviewer interpretation, and
decision. Accept only a conforming `pass` manifest whose telemetry correlation
is accepted by both customer platform and security reviewers. Missing
correlation, production-only availability, missing reviewers, or an unsafe
route is a safe stop: record the blocker, owner, date, and impact on the
related admission decision instead of
substituting a direct component test.

For a later operating review, the customer may reference the bounded workload
and initiating context, correlation, tool/model version, policy decision,
outcome category, and reviewer decision. Do not add raw event data, payloads,
identifiers, or credentials to this kit.

Validate official product context before delivery: Prompt Shields can inform a
runtime-safety control discussion, while Application Insights/OpenTelemetry or
other customer telemetry can support correlation. Neither source replaces the
customer's accepted gateway proof decision.
