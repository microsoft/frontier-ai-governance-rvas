# S1 · Identity Path Trace

**Facilitator deck**

Microsoft default: **Entra Agent ID / Agent 365 where supported, Entra app
registrations, enterprise applications, managed identity, workload identity
federation, Conditional Access, Azure RBAC, APIM/gateway JWT checks, and
resource API permissions**.

Concrete decision: **Can we trace one user request from user identity to
app/agent identity to the tool/API permission that allows or denies the action?**

---

## Pick one request

- Use one non-production user request or synthetic trigger.
- Name the app/agent alias, target tool/API operation, time window, and
  correlation handle.
- Do not change consent, RBAC, CA, credentials, or gateway policy.

Note:
If the team cannot name the request, the target API, and the actor, S1 blocks
until the app owner narrows the scope.

---

## Open Entra app records

Portal route:

**Entra admin center** -> **Identity** -> **Applications** -> **App
registrations** -> app.

Inspect:

- Overview, Owners, Authentication.
- Certificates & secrets.
- Federated credentials.
- API permissions.
- Expose an API.
- App roles.
- Manifest only when needed.

Note:
Requested permissions are not granted permissions. Keep that distinction visible.

---

## Open the enterprise app

Portal route:

**Entra admin center** -> **Identity** -> **Applications** -> **Enterprise
applications** -> service principal.

Inspect:

- Permissions and admin consent.
- Users and groups if assignment is required.
- Sign-in logs and audit logs.
- Conditional Access result.

Note:
This is where missing consent, CA blocks, disabled service principal, and recent
permission changes usually become visible.

---

## Check host identity and federation

Open:

- **Azure portal** -> host resource -> **Identity**.
- **Azure portal** -> **Managed identities** -> identity -> **Azure role
  assignments**.
- **App registrations** -> app -> **Federated credentials**.

Check principal ID, client ID, issuer, subject, audience, wildcard subjects,
target RBAC scope, and revocation owner.

Note:
Managed identity and federation avoid stored secrets, but they still need owner,
scope, and disable route.

---

## Branch to Agent ID where supported

Open:

- **Entra admin center** -> **Identity** -> **Applications** -> **Agent
  identities / Agent ID** where available.
- **Agent 365** record where the workload uses it.

If unavailable:

- Use the custom app/service-principal fallback.
- Record owner register, support recheck, and migration condition.

Note:
Do not pretend a service principal alone is an Agent ID. Name the fallback.

---

## Inspect delegated and OBO path

For user-context operation, check:

- client app delegated scopes;
- enterprise app consent;
- downstream API **Expose an API** scopes;
- sign-in logs with user, app, resource, scopes, CA result;
- app/API trace that shows token exchange and downstream action.

Note:
If the tool uses app-only auth, say app-only. Do not call it OBO because a user
clicked first.

---

## Decode only safe claim checks

In the customer environment, check:

- `aud` for target API or gateway;
- `scp` for delegated scopes;
- `roles` for app roles/application permission;
- `oid`/`sub`, `appid`/`azp`, and user claim presence/absence;
- `xms_mirid` for managed identity where present;
- sign-in correlation ID and CA result.

Note:
Never paste raw tokens or claim payloads into this repo.

---

## Expected signals

| Signal | Meaning |
|---|---|
| Correct `aud` | Token is for the intended API/gateway. |
| `scp` + user claims | Delegated/OBO user context is present. |
| `roles` without user | App-only permission path. |
| Broad scope/RBAC | Narrow or exception-route before reliance. |
| Missing consent | Route to consent owner. |
| Unmanaged secret | Route to managed identity/federation or credential owner. |
| CA block | Route with sign-in reference. |
| Unsupported OBO/tool | Block user-context claim and fix the route. |

Note:
The output is the permission result, owner, fix route, and recheck condition.

---

## Decide and hand over

Confirm:

- request trace and correlation handle;
- app registration and enterprise app result;
- managed identity/federated credential result;
- Agent ID branch or custom-app fallback;
- token audience and user-context result;
- permission result and owner;
- CA/logging result;
- fix route and recheck condition.

Note:
S1 changes nothing in the tenant. Production use waits for customer change,
access, and release processes.
