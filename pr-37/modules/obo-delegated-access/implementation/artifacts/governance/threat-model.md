# OBO threat model

| Abuse case | Primary control | Stop condition |
| --- | --- | --- |
| Inbound token is reused against the downstream API | Separate audiences and an OBO exchange | The original bearer token leaves the middle tier |
| Middle tier acts without a user | Require `scp`, `oid`, and `azp`; reject app-only tokens | Inbound token has roles but no delegated scope |
| Confused deputy calls for an unknown client | Allowlisted client application ID and exact middle-tier audience | `azp` or audience differs from the authoritative configuration file |
| Unsupported middle-tier signing trust | Microsoft Entra-issued token signed with the standard platform key | Middle-tier API relies on a custom signing key for the inbound token |
| Assertion is replayed | TLS, short token lifetime, library-managed exchange, no assertion storage | Assertion appears in a file, queue, trace, or retry log |
| Consent is broader than the operation | Downstream delegated scope and consent owner recorded in the control definition | Requested or granted scope exceeds `Policy.Read` |
| Certificate escapes the approved runtime | Key Vault-backed PFX mount and repository exclusions | Private key is copied from the protected host path into source, arguments, or logs |
| Authorized token reaches unauthorized data | Downstream resource authorization for the preserved user | Denied test user receives the protected resource |
| Claims challenge is hidden | Return the downstream authorization failure and approved challenge metadata | Middle tier converts a claims challenge into success |
| Middle-tier token is relayed back to the client | Return status and correlation metadata only | Client receives either the inbound token or the exchanged downstream token |
| Token leaks through diagnostics | Structured metadata allowlist | Any token, assertion, authorization header, or payload is logged |
