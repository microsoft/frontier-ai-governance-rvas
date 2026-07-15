# S3 Runbook — Gateway Proof

Run this only in a customer-approved non-production environment. The one S3
action is a request through the deployed gateway; a direct Content Safety call
is not S3 evidence.

1. Confirm the customer has approved the route, authentication handling, safe
   test input, and the record locations referenced below.
2. The customer operator runs the adapter, supplying real values only through
   their secure process:

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
   ./scripts/test_gateway_prompt_shield.sh ./evidence/gateway-proof.json
   ```

3. The platform and security owners validate the output against
   `contracts/gateway-proof.schema.json`, correlate `correlation_id` with
   customer telemetry, and record their decision in the approved evidence
   system. `pass` means only that the adapter request completed; it is not
   accepted gateway enforcement until that review is complete.
4. Hand off the accepted proof reference and decision reference to S4. If the
   request fails or review cannot be completed, record the outcome as failed or
   blocked in the customer system; do not create substitute local evidence.
