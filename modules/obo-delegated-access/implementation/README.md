# Implementation - Delegated API access with OAuth on-behalf-of

## Module scope

### What we will do

Configure an existing trusted Python middle tier to exchange a signed-in user's token for a
delegated token for an existing protected API. Record the approved client, middle tier, downstream
audience, delegated scope, and consent boundary. Add only the approved delegated permissions,
validate the inbound assertion, and use a protected Azure Key Vault certificate for the OAuth 2.0
on-behalf-of (OBO) exchange.

Then confirm that a permitted user succeeds and that a user without downstream resource authority
is denied.

The working delegated flow preserves signed-in user authority in the **middle tier**. The
**downstream API** still makes the resource-authorization decision for that user.

### Why it matters

A workload identity gives the middle tier the same application authority for every request. It
does not fit a downstream resource whose access must change with the signed-in user. OBO carries
that user context across the middle tier without forwarding the original bearer token.

The permitted-user check confirms that Microsoft Entra ID accepts the delegated trust chain. The
denied-user check confirms that the downstream API still enforces its user-specific resource rules.

### Boundaries

Use this module only when an existing client, confidential middle tier, and protected downstream API
already require per-user authorization. If the operation should run with one workload identity
regardless of who started it, use managed identity instead.

The module changes **exact delegated permissions and consent**, the middle-tier OBO implementation,
and its payload-free diagnostics. It does not create replacement applications, redesign the
downstream authorization model, or grant missing resource authority to the denied user. The
original bearer token stops at the middle tier. No application-only retry may bypass a downstream
denial.

The certificate remains in Azure Key Vault and reaches the approved runtime only through its
protected certificate integration. This repository stores references, never private keys, bearer
tokens, tenant values, endpoints, or user data.

This optional module sits outside the 15-session sequence. It complements the identity decision in
[Session 02](../../../sessions/02-identity-privileged-access/), the application-only agent baseline
in [Session 05](../../../sessions/05-governed-agent-baseline/), and the application-only MCP path
in [Session 09](../../../sessions/09-mcp-tool-security/).

## Architecture

### Architecture at a glance

![The OBO sequence validates a middle-tier token, exchanges the user assertion with certificate authentication, and produces permitted or denied downstream authorization](../assets/diagrams/obo-trust-chain.svg)

This design preserves the signed-in user's authority across a trusted middle tier. The downstream
API can make its decision for that user instead of treating every request as the same application.

The client first gets a token for the Python middle tier. The middle tier validates it, then sends
the user's assertion and its certificate to Microsoft Entra ID. Entra issues a second token for the
protected downstream API. That token carries the user's delegated identity. The API checks the
delegated scope and the user's access to the requested resource. One user can succeed while
another receives a denial through the same middle tier. A workload identity would give every
request the same application authority.

Microsoft Entra ID holds the application registrations, permission grants, and token issuance.
Azure Key Vault and the approved host control the certificate and how the runtime receives it. The
downstream API decides which resources each user may access. The repository defines the configuration and claim checks, along with the threat model, runtime
code, and operational scripts.

The trust chain ends at the downstream authorization response. The inbound bearer token never
crosses the middle-tier boundary. A denial stays a denial. The middle tier cannot retry with
application-only authority or change the resource's access model.

### Design choices and tradeoffs

| Choice engineers need to make | Route used here | Why this route fits | What the team accepts | Change course when |
|---|---|---|---|---|
| Which authority reaches the API? | OAuth 2.0 OBO with delegated permissions | The API can decide for the signed-in user | Consent, user-capable clients, and separate token audiences | The operation becomes shared or background work |
| How does the middle tier prove its identity? | An exportable Key Vault certificate provided as a protected PFX file containing the certificate and private key | The shipped MSAL component can use it without a client secret | The team must rotate the certificate; nonexportable HSM keys need another design | The host supports an approved key-bound client authentication path |
| How are existing registrations changed? | Merge the module's exact entries and preserve everything else | The module touches only the permissions it owns | Microsoft Graph has no what-if operation for this change, so preflight compares live state | The registrations move to an approved declarative lifecycle |
| How do we test the authorization boundary? | Call once as a permitted user and once as a user the downstream resource denies | The pair separates a successful token exchange from the API's resource decision | Two test users need deliberately different access to the downstream resource | The API can run an automated policy test that proves the same distinction |

### Architecture guidance

Start with Microsoft’s [OBO flow
guidance](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-on-behalf-of-flow).
It explains the different roles of the inbound audience, user assertion, and downstream scope.
Session 02 supplies the identity decision: choose this module only if an application-only path
would erase a real per-user authorization decision. Sessions 05 and 08 retain their
application-only routes.

Once that boundary is agreed, `app-registrations.json` records the applications and exact delegated
permissions. `token-claim-contract.json` lists the issuer, audience, client, scope, and user claims
that the middle tier accepts. Preflight compares those definitions with live Microsoft Entra state
and prints the proposed change because Microsoft Graph has no what-if operation for
application-registration updates. Follow the [Microsoft Graph application update
semantics](https://learn.microsoft.com/en-us/graph/api/application-update) so the update preserves
collection values owned by other work.

The runtime authenticates with the protected PFX described by the certificate binding. This route
works only with an exportable certificate. Check the [Key Vault certificate export
boundary](https://learn.microsoft.com/en-us/azure/key-vault/certificates/how-to-export-certificate)
before the team approves it; a nonexportable HSM key needs a different client-authentication
design.

## Before you start

Confirm these prerequisites:

- The client, middle tier, and downstream API already exist in an approved nonproduction tenant.
- The client can sign in users and request a token for the middle-tier audience.
- The downstream API exposes one narrow delegated read scope and enforces resource authorization
  for each user.
- The middle-tier host can expose the exportable Key Vault certificate in the certificate binding
  as a protected PFX path through its approved certificate integration.
- The identity owner can approve the exact delegated permission and consent boundary.
- One permitted user and one user without downstream resource authority are available for the
  delivery checks.
- Diagnostics can retain correlation, operation, status, error, and duration fields while
  excluding authorization headers, assertions, tokens, and payloads.

Complete every `__REQUIRED_*__` value under
[`artifacts/`](artifacts/README.md). Keep organization-specific copies in the approved private
repository or configuration store.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/control-definition.json`](artifacts/control-definition.json) | The preflight and configuration scripts |
| Deployment | [`artifacts/identity/app-registrations.json`](artifacts/identity/app-registrations.json) | The preflight and configuration scripts |
| Deployment | [`artifacts/identity/key-vault-certificate-binding.json`](artifacts/identity/key-vault-certificate-binding.json) | The preflight scripts and Python middle tier |
| Record | [`artifacts/governance/authorization-matrix.md`](artifacts/governance/authorization-matrix.md) | The identity owner and delivery owner |
| Runtime | [`artifacts/governance/token-claim-contract.json`](artifacts/governance/token-claim-contract.json) | The Python middle tier and verification scripts |
| Record | [`artifacts/governance/threat-model.md`](artifacts/governance/threat-model.md) | The application security owner and delivery owner |
| Runtime | [`artifacts/runtime/settings.json`](artifacts/runtime/settings.json) | The Python middle tier |
| Runtime | [`artifacts/runtime/obo_proxy.py`](artifacts/runtime/obo_proxy.py) | The approved middle-tier runtime |
| Runtime | [`artifacts/runtime/requirements.txt`](artifacts/runtime/requirements.txt) | The middle-tier build process |

Run preflight before any Microsoft Graph change:

```powershell
.\scripts\preflight.ps1 -ArtifactRoot (Resolve-Path .\artifacts)
```

```bash
./scripts/preflight.sh --artifact-root "$(realpath ./artifacts)"
```

Preflight reads the current application and service-principal configuration, compares it with the
implementation files, and prints the exact change plan. Microsoft Graph does not provide a what-if
operation for these application-registration changes, so this read-only plan is the required
preview.

## Decisions and stop conditions

### Choose OBO for the right reason

Use OBO only when the downstream API must evaluate the signed-in user. Typical signals include
user-owned records, per-user entitlements, or a downstream policy that names the user.

Use application-only authorization when the workload reads shared data, runs in the background, or
needs the same authority for every caller. OBO carries a different authority from managed identity.

### Keep token audiences separate

The inbound token audience is the middle tier. The exchanged token audience is the downstream API.
They must differ.

The claim examples and Conditional Access claims-challenge boundary contain no token values.

Stop if any design forwards the inbound bearer token to the downstream API. Also stop when:

- the client requests a token directly for the downstream API and sends it through the middle tier;
- the middle tier accepts tokens issued for another audience;
- the downstream scope is broader than the implemented read operation;
- an application-only token can enter the OBO path;
- the middle-tier API uses a custom signing key that the downstream trust chain cannot validate;
- the middle tier falls back to an application permission after delegated exchange fails; or
- the downstream API trusts exchange success without checking user access to the resource.

### Assign consent ownership

The identity owner approves the client-to-middle-tier and middle-tier-to-downstream delegated
permissions. Record the exact scope IDs and consent type in
[`identity/app-registrations.json`](artifacts/identity/app-registrations.json).

Stop when the consent owner is unnamed, a requested scope is unresolved, or an existing
tenant-wide grant would be broadened without an explicit decision. The configure scripts preserve
unrelated permissions. They must not replace a complete permission collection with the module's
entries. Obtain downstream delegated consent before runtime; the middle tier has no interactive
surface where it can ask the user.

### Protect the confidential client

The middle tier authenticates with the certificate described in
[`identity/key-vault-certificate-binding.json`](artifacts/identity/key-vault-certificate-binding.json).
MSAL reads the protected PFX path. Only the middle-tier workload may read the private key.

Stop if the certificate is committed, passed as a command argument, printed, copied into a build
artifact, or mounted where another workload can read it. Stop if the registered thumbprint differs
from the certificate exposed to the middle tier. This path requires an exportable Key Vault
certificate. An HSM-backed, nonexportable key cannot be mounted as a PFX and needs a different
client-authentication design.

### Validate before exchange

The middle tier validates the issuer, middle-tier audience, tenant, calling client, delegated
scope, token lifetime, and signed-in user claims before using the token as a user assertion. The
authoritative configuration file is
[`governance/token-claim-contract.json`](artifacts/governance/token-claim-contract.json).

An OBO exchange does not remove Conditional Access. Return a supported claims challenge or
authorization failure to the approved client flow. Never turn it into an anonymous retry or an
application-only call.

### Keep telemetry payload-free

Use the allowlist in the token-claim contract. Do not log the inbound authorization header, user
assertion, exchanged token, request body, downstream body, or certificate material. The threat
model in [`governance/threat-model.md`](artifacts/governance/threat-model.md) treats any such capture
as a stop condition.

## Implement

### 1. Record the approved applications, permissions, and claim checks

Review these files with the identity, application, downstream API, and delivery owners:

- [`artifacts/control-definition.json`](artifacts/control-definition.json)
- [`artifacts/identity/app-registrations.json`](artifacts/identity/app-registrations.json)
- [`artifacts/governance/authorization-matrix.md`](artifacts/governance/authorization-matrix.md)
- [`artifacts/governance/token-claim-contract.json`](artifacts/governance/token-claim-contract.json)
- [`artifacts/governance/threat-model.md`](artifacts/governance/threat-model.md)

The client receives only the middle-tier delegated scope. The middle tier receives only the
downstream delegated read scope. The downstream API decides whether the preserved user can read the
requested resource.

### 2. Bind the Key Vault certificate

Register the public certificate on the middle-tier application through the approved identity
lifecycle. Configure the hosting platform's Key Vault integration to expose the exportable private
certificate as a protected PFX at the approved runtime path.

Do not use the configure scripts to upload private key material. Preflight checks the approved
thumbprint against the middle-tier registration and confirms that the configured path exists on
the execution host.

### 3. Preview and apply the delegated permissions

Run preflight again after the certificate binding is active. The read-only plan must show only:

- the client application's exact middle-tier delegated scope;
- the middle tier's exact downstream delegated scope; and
- the approved delegated consent grant.

Apply the plan:

```powershell
.\scripts\configure.ps1 -ArtifactRoot (Resolve-Path .\artifacts) -Confirm
```

```bash
./scripts/configure.sh --artifact-root "$(realpath ./artifacts)" --confirm
```

Pause if either script finds an existing conflicting scope ID, audience, consent grant, or
certificate thumbprint. Resolve the registration through the identity owner listed in the control definition rather than
overwriting it.

### 4. Deploy the Python middle tier

Use the implementation component under
[`artifacts/runtime/`](artifacts/runtime/README.md). Copy `settings.json` into the approved
deployment configuration, resolve its required values there, and set `OBO_SETTINGS_PATH` to that
protected copy.

Deploy through the organization's normal application pipeline. The component:

- validates the inbound delegated token against the issuer, audience, client, scope, and claim
  rules in `token-claim-contract.json`;
- creates an MSAL confidential client from the mounted PFX;
- requests only the approved downstream scope;
- calls one fixed HTTPS endpoint; and
- returns correlation and authorization status without returning the downstream payload.

Do not run it as a public sample service. Apply the host's normal network, TLS, scaling, patching,
and telemetry controls.

### 5. Prepare the delivery checks

Use the approved client to obtain two short-lived middle-tier access tokens interactively:

- one for the permitted user; and
- one for a user who lacks access to the downstream protected resource.

Write each token to a separate protected temporary file outside the repository. Restrict file
permissions to the operator. The verification scripts read the files without printing their
contents and remove no user-owned file automatically.

### 6. Delivery-owner checkpoint

Before the checks, the delivery owner reviews:

- the read-only preflight plan;
- the exact consent grant;
- the certificate thumbprint and protected runtime path;
- payload-free diagnostic settings; and
- the downstream rule that distinguishes the permitted and denied users.

Do not continue if the two users differ only in the client or middle-tier permission. The
failure-path check must exercise downstream user authorization.

## Confirm the result

Run both checks:

```powershell
.\scripts\verify.ps1 `
  -MiddleTierEndpoint "https://__APPROVED_HOST__/delegated-resource" `
  -PermittedTokenFile $permittedTokenFile `
  -DeniedTokenFile $deniedTokenFile
```

```bash
./scripts/verify.sh \
  --middle-tier-endpoint "https://__APPROVED_HOST__/delegated-resource" \
  --permitted-token-file "$permitted_token_file" \
  --denied-token-file "$denied_token_file"
```

For the **intended-path check**, the permitted user's call returns 2xx, a correlation ID, and the
`downstream-authorized` decision header. The downstream API authorizes the preserved user and the
middle tier logs metadata only.

For the **failure-path check**, the denied user's call returns 401 or 403 with the
`downstream-denied` decision header. This prevents an inbound-token or exchange failure from
passing as a downstream authorization test. No protected resource is returned, no application-only
retry occurs, and the failure remains correlated without recording either token or payload.

At the **delivery-owner checkpoint**, the owner observes both status codes and confirms that the
downstream API made the user-specific decision. The client prompt and middle-tier instructions do
not make that decision.

## After implementation

Keep:

- the approved app-registration and consent definitions;
- the authorization matrix and token claim rules;
- the certificate reference and thumbprint;
- the Python middle-tier component and pinned dependencies;
- the threat model; and
- the paired operational scripts.

The identity owner owns delegated permissions and consent. The application owner owns inbound
validation and certificate use. The downstream API owner owns resource authorization. Operations
owns payload-free diagnostics and certificate-expiry alerting.

To remove the module-owned permission and consent entries, the identity owner checks the
`optional-module-obo-delegated-access` marker and approved scope IDs, then removes only the
module-owned delegated grants through the approved Entra change path. Do not delete application
registrations, service principals, the Key Vault certificate, the downstream API, or unrelated
permissions. Retire the certificate through the normal identity lifecycle only after no other
approved workload uses it.
