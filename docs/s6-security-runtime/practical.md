# Practical activity: produce one gateway proof

## What you will do

The customer operator runs the existing gateway-proof script against an approved
non-production route, then security reviewers correlate its ID with customer
telemetry.

## Before you start

- Confirm the non-production route, endpoint owner, approved authentication
  handling, platform and security reviewers, and records location.
- Follow the non-production hard exit gate. Stop if any authorization, safe
  target, or rollback condition is missing.
- Never record credentials, raw payloads, or telemetry in this repository.

## Customer-operated activity

1. Set the approved non-production variables described in
   `labs/s6-security-runtime/runbook.md`.
2. Run:
   ```bash
   bash labs/s6-security-runtime/scripts/test_gateway_prompt_shield.sh
   ```
3. The customer security and platform reviewers use the emitted correlation ID
   to locate the corresponding gateway telemetry and accept, defer, or reject
   the proof.

## What good looks like

The manifest has a `pass` result and its correlation ID is accepted against
customer telemetry. A request failure, missing telemetry, or uncertain scope
is a gap, not a pass.

## If the environment is not ready

Validate the manifest shape and identify the route, policy, authentication, or
telemetry prerequisite that prevents a customer-operated proof.

## Keep and hand over

Keep only the safe proof and telemetry references in customer records. Hand
route, policy, or telemetry remediation to the platform or security owner.
