---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Delegated API access with OAuth on-behalf-of
description: Optional implementation module for preserving signed-in user authority across a trusted middle tier.
---

<!-- _class: cover -->

# Delegated API access with OAuth on-behalf-of

## Optional implementation module

Preserve signed-in user authority across a trusted middle tier.

<!-- Notes: This module is selected by architecture need. It is not Session 16. -->

---

## Control objective

A trusted Python middle tier exchanges the signed-in user's assertion for a new delegated token addressed to the protected downstream API.

The visible result is one allowed call and one denial caused by missing downstream user authority.

![Microsoft Entra ID](assets/icons/microsoft/microsoft-entra-id.svg)

<!-- Notes: The exchange preserves user authority. The downstream API still owns the resource decision. -->

---

## Why it matters

A workload identity carries the same application authority for every request.

That breaks down when the downstream API must make a decision for the signed-in user.

OBO carries that user context across the middle tier without forwarding the original bearer token.

<!-- Notes: Use this module only for a real per-user authorization requirement. -->

---

## Control boundary

**In scope:** delegated permissions and consent, inbound token checks, the OBO exchange, protected certificate use, and payload-free checks.

**Outside the module:** replacement applications, downstream authorization redesign, new user grants, and application-only retry after a downstream denial.

<!-- Notes: The existing client, middle tier, and downstream API are approved inputs. -->

---

## Architecture and authority

![The OBO sequence validates the inbound token, uses certificate authentication for token exchange, and ends in allowed-user success or missing-authority denial](assets/diagrams/obo-trust-chain.svg)

In the OAuth on-behalf-of (OBO) flow, the inbound token stops at the middle tier. Microsoft Entra
ID issues a new delegated token for the downstream API, preserving the user's identity so the API
can allow one user and deny another.

<!-- Notes: The client gets a token for the middle tier. The middle tier validates it, then uses the user assertion and its certificate to request a downstream token from Microsoft Entra ID. Entra owns token issuance. The downstream API owns resource access for each user. -->

---

<!-- _class: decision -->

## Tradeoffs behind this design

| Engineering choice | Route used here | What the team accepts |
| --- | --- | --- |
| Authority at the API | OBO delegated token | Consent and separate token audiences |
| Middle-tier identity | Protected certificate PFX | Rotation; nonexportable HSM keys need another design |
| Existing registrations | Merge exact entries | Preflight compares live state because Graph has no what-if |
| Boundary check | Permitted and denied users | Two users with different downstream access |

<!-- Notes: OBO fits only when the API must decide for the signed-in user. Use workload identity for shared or background work. -->

---

<!-- _class: decision -->

## Decision gate 1 - Is user authority required?

Choose OBO only when:

- the downstream resource is user-owned or user-scoped;
- the downstream API evaluates the signed-in user; and
- application-only authority would be too broad or incorrect.

Otherwise, stop here and use a workload identity.

<!-- Notes: Do not add delegated consent to a shared background operation. -->

---

## The inbound token stops at the middle tier

The Python component validates:

1. issuer and tenant;
2. middle-tier audience;
3. approved calling client;
4. lifetime and signature;
5. signed-in user claim; and
6. delegated `access_as_user` scope.

The original bearer token never reaches the downstream API.

<!-- Notes: Token forwarding is not OBO. -->

---

## OBO creates a new delegated token

![Azure Key Vault](assets/icons/microsoft/azure-key-vault.svg)

The middle tier uses MSAL with the protected PFX and sends:

- the validated user assertion;
- its own client identity; and
- certificate-based client authentication.

Microsoft Entra ID issues a token for the approved downstream delegated scope.

<!-- Notes: The certificate proves the middle tier. The assertion carries the user. -->

---

<!-- _class: decision -->

## Decision gate 2 - Consent and scope

The identity owner approves:

- client to middle tier: `access_as_user`;
- middle tier to downstream API: `Policy.Read`; and
- the approved consent type.

Stop if an existing grant is ambiguous or the requested scope is broader than the read operation.

<!-- Notes: The configure scripts merge the module entries and preserve unrelated permissions. -->

---

## Downstream authorization still decides

A successful exchange proves that Microsoft Entra ID accepted the trust chain.

It does not prove that the user may read the protected resource.

The downstream API checks both the delegated scope and that user's resource assignment.

<!-- Notes: This is why the module needs a denied-user check. -->

---

## Intended path and failure path

| Check | Expected result |
| --- | --- |
| Allowed user | 2xx plus `downstream-authorized` |
| User without downstream access | 401/403 plus `downstream-denied` |

No application-only retry. No token or payload logging.

<!-- Notes: The two users must differ at the downstream resource boundary. -->

---

<!-- _class: implementation -->

## Implement the operational control

1. Complete the identity and claim contracts.
2. Bind the exportable Key Vault certificate as a protected PFX.
3. Preview and apply the delegated permissions listed in the module record.
4. Deploy the Python middle tier through the normal pipeline.
5. Run the allowed and denied checks.

<!-- Notes: Do not create a temporary API to make the check pass. -->

---

## Stop conditions

- Inbound token reaches the downstream API
- Application-only token enters the OBO path
- Permission or consent is broader than the approved scope
- Certificate leaves the approved runtime
- Assertion, token, or payload enters diagnostics
- Downstream denial is replaced with a workload-authorized retry

<!-- Notes: Any one of these changes the authority boundary. -->

---

## What remains

| Owner | Operational responsibility |
| --- | --- |
| Identity | Delegated scopes, consent, certificate registration |
| Application | Inbound validation, OBO exchange, error handling |
| Downstream API | User-specific resource authorization |
| Operations | Payload-free logs and certificate expiry |

<!-- Notes: Restore removes exact module-owned permissions and grants, not the applications. -->

---

## Related numbered sessions

- **Session 03** selects human, workload, agent, or delegated authority.
- **Session 06** keeps the direct OpenAPI baseline application-only.
- **Session 09** replaces inbound authority with APIM managed identity.

This module is used when those application-only paths do not satisfy a real per-user requirement.

<!-- Notes: It complements the series without changing its sequence. -->

---

<!-- _class: closing -->

# Thank you!
