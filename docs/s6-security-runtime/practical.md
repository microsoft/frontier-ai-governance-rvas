# Do this

**Customer owner:** Platform or security operator

1. Set the approved non-production variables in `labs/s6-security-runtime/runbook.md`.
2. Run `bash labs/s6-security-runtime/scripts/test_gateway_prompt_shield.sh`.
3. Correlate the emitted ID with gateway telemetry and record the review decision.

**Stop:** Use only the approved non-production route with named reviewers and safe authentication handling.

**If unavailable:** Validate the manifest shape and assign the missing route, policy, authentication, or telemetry prerequisite.
