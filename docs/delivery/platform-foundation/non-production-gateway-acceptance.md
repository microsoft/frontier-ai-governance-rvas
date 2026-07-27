# Non-production gateway acceptance

This gate establishes that an approved non-production request used the customer gateway path. It neither certifies production readiness nor proves every workload, route, policy, or backend is covered.

## Entry conditions

- The intake identifies a non-production gateway URL, an approved test caller,
  route, backend contract, and authentication method.
- The smoke-test command explicitly identifies the customer-approved
  non-production environment; the adapter rejects empty, `prod`, and
  `production` environment labels.
- The test request and data are customer-owned and non-production.
- The platform team has approved the test window and named the owners who can
  inspect gateway and telemetry records.
- A proof identifier is agreed so the request can be correlated without
  recording tokens or sensitive request content.

## Acceptance criteria

All applicable criteria must be evidenced in the manifest:

1. The caller reached the configured non-production gateway URL, not a direct backend endpoint. Keep the URL in the customer platform record, not the normalized manifest.
2. The gateway accepted or intentionally rejected the caller according to the
   documented access contract; the expected result is recorded.
3. The configured route selected the approved backend and applicable runtime
   policy. The policy/configuration version or change record is recorded.
4. A platform owner can locate a gateway trace or telemetry record with the proof identifier and timestamp, subject to customer retention and access controls. The manifest records a safe telemetry reference, not raw trace or query output.
5. The platform owner confirms that the result did not create a production
   change and that the documented rollback/support path applies.
6. Any unavailable control, missing telemetry, unexpected route, or direct
   component-only result is a blocked/deferred item with an owner and date.

If the customer uses its own Prompt Shields-compatible smoke-test adapter, it must run only where an approved gateway route exposes the required request contract. The output should be a versioned references-only manifest with no raw response bodies, prompts, documents, endpoint values, or credentials. The adapter is smoke-test evidence collection, not gateway deployment or policy configuration.
