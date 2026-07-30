# S1 · Identity Path Trace: Technical runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Microsoft Entra Agent ID, Agent 365, workload identities, Conditional Access for workload identities, managed identity, workload identity federation, and OBO support vary by tenant and workload. Verify current support before delivery.

## Microsoft default

Default to Microsoft Entra Agent ID / Agent 365 where the workload exposes it,
backed by Entra app registrations, enterprise applications, managed identities,
workload identity federation, Conditional Access, Azure RBAC, APIM/gateway JWT
checks, and resource API authorization. When Agent ID is not supported, use a
custom app/service-principal path with an explicit owner and recheck condition.

![S1 illustrative identity pattern: a human sponsor governs agent identity and lifecycle; host workload identity, agent identity, delegated OBO, gateway access, and resource authorization remain separate decisions.](../assets/diagrams/s1-agent-identity-model.svg)

S1 is read-only. It proves whether the path can be inspected and routed for a
fix; it does not change permissions.

## 1. Preflight

| Check | Required before inspection | Blocker if missing |
|---|---|---|
| One request | One synthetic or non-production user request, app/agent alias, target tool/API, and time window are named. | Do not inspect a broad portfolio. |
| Roles | Reader access to app registration, enterprise app, sign-in logs, audit logs, managed identity/RBAC, gateway or API record, and CA sign-in details where relevant. | Route to identity/platform owner. |
| Evidence handling | Customer-approved location exists for token claim notes, sign-in references, and portal links. | Do not decode or copy claims into this repo. |
| Safe content | No customer prompt, response, token, endpoint, tenant ID, secret, or screenshot is stored in repo files. | Stop the lab. |
| Fix owners | Identity, app, gateway, API/resource, CA, and security owners are known or discoverable. | Result is blocked or routed. |

## 2. Portal sequence

Follow this order so the result mirrors the technical path.

### 2.1 App registration

Portal route: **Microsoft Entra admin center** -> **Identity** ->
**Applications** -> **App registrations** -> selected app.

Open:

- **Overview**: display name, application/client ID, supported account types,
  object owner reference.
- **Owners**: human or group owner for lifecycle and consent routing.
- **Authentication**: redirect URI, public client setting, implicit/hybrid
  settings, logout/front-channel assumptions where relevant.
- **Certificates & secrets**: secret/certificate presence, expiry, owner, and
  Key Vault or rotation route. Do not reveal values.
- **Federated credentials**: issuer, subject, audiences, branch/environment
  constraints, and revocation owner.
- **API permissions**: delegated scopes and application permissions requested.
- **Expose an API**: application ID URI, scopes, authorized client apps.
- **App roles**: role values assigned to applications/users.
- **Manifest**: only when the UI does not expose required resource access,
  app roles, optional claims, or known client apps.

### 2.2 Enterprise application / service principal

Portal route: **Microsoft Entra admin center** -> **Identity** ->
**Applications** -> **Enterprise applications** -> selected service principal.

Open:

- **Overview** and **Owners**: account enabled state and owner.
- **Permissions**: admin consent, delegated grants, application role grants.
- **Users and groups**: user assignment requirement and assigned subjects where
  applicable.
- **Sign-in logs**: result, token issuer, conditional access status, service
  principal sign-in, managed identity sign-in, and correlation ID.
- **Audit logs**: credential, owner, permission, and consent changes.
- **Conditional Access**: policies applied or not applied to the app/user path.

### 2.3 Managed identity and workload federation

Portal routes:

- **Azure portal** -> hosting resource -> **Identity** for system-assigned
  managed identity.
- **Azure portal** -> **Managed identities** -> user-assigned identity ->
  **Overview** and **Azure role assignments**.
- **App registrations** -> app -> **Federated credentials** for external
  workload identity federation.

Check principal ID/client ID, target scopes, issuer/subject/audience constraints,
public or wildcard subjects, and the owner who can remove the trust.

### 2.4 Delegated/OBO path

Open the client app and downstream API app:

- Client app **API permissions**: delegated scopes requested.
- Enterprise app **Permissions**: consent actually granted.
- Downstream API **Expose an API**: scopes and authorized client apps.
- Sign-in log details: user, client app, resource, scopes, CA result, and
  correlation ID.
- App or API telemetry: request ID showing the user token was exchanged and
  downstream action used delegated authority.

### 2.5 Tool/API and resource permission

Open the permission that actually authorizes the operation:

- **Graph/API permission**: delegated scope or app role grant on the service
  principal.
- **Azure RBAC**: Azure portal -> target scope -> **Access control (IAM)** ->
  **Role assignments**, filtered by principal ID.
- **APIM/gateway**: API/product/subscription/JWT policy, backend auth, and logs.
- **Connector**: consent, connector policy, environment, and data boundary.
- **Resource ACL/data permission**: storage, search, database, or SaaS record.

### 2.6 Agent ID branch

When available, open the agent identity record:

- **Microsoft Entra admin center** -> **Identity** -> **Applications** -> **Agent
  identities / Agent ID** or the current Agent ID surface.
- **Agent 365** agent record where the workload is onboarded there.

Check sponsor, purpose, authority mode, host trust, lifecycle state, disable
route, and linked app/service principal. If unavailable, record
**custom-app fallback**: app registration/service principal, customer owner
register, product-support recheck owner, and migration condition.

## 3. Read-only Graph and CLI checks

Use these commands only in the customer's approved environment with the minimum
read scopes. Store sanitized results in the customer system.

```powershell
# App registration details
Get-MgApplication -ApplicationId $ClientId |
  Select Id, AppId, DisplayName, SignInAudience, RequiredResourceAccess

# Service principal / enterprise app
Get-MgServicePrincipal -Filter "appId eq '$ClientId'" |
  Select Id, AppId, DisplayName, AccountEnabled, ServicePrincipalType

# Owners
Get-MgApplicationOwner -ApplicationId $AppObjectId
Get-MgServicePrincipalOwner -ServicePrincipalId $SpObjectId

# Credentials and federation
Get-MgApplicationPasswordCredential -ApplicationId $AppObjectId
Get-MgApplicationFederatedIdentityCredential -ApplicationId $AppObjectId

# App roles and OAuth delegated grants
Get-MgApplicationAppRole -ApplicationId $ApiAppObjectId
Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ClientSpObjectId
Get-MgOauth2PermissionGrant -Filter "clientId eq '$ClientSpObjectId'"

# Sign-ins and audit
Get-MgAuditLogSignIn -Filter "appId eq '$ClientId' and createdDateTime ge $Start"
Get-MgAuditLogDirectoryAudit -Filter "targetResources/any(t:t/id eq '$AppObjectId')"
```

```bash
# App and service principal
az ad app show --id "$APP_ID" --query "{appId:appId, displayName:displayName, signInAudience:signInAudience}"
az ad sp show --id "$APP_ID" --query "{id:id, appId:appId, displayName:displayName, accountEnabled:accountEnabled}"

# Credentials and federated credentials
az ad app credential list --id "$APP_ID" --query "[].{displayName:displayName,endDateTime:endDateTime,hint:hint}"
az ad app federated-credential list --id "$APP_ID" --query "[].{name:name,issuer:issuer,subject:subject,audiences:audiences}"

# Managed identity and RBAC
az identity show --ids "$IDENTITY_RESOURCE_ID" --query "{name:name,principalId:principalId,clientId:clientId}"
az role assignment list --assignee "$PRINCIPAL_ID" --all --query "[].{role:roleDefinitionName,scope:scope}"
```

## 4. Token and claim checks

Decode only in the customer environment. Do not store raw tokens.

| Claim/check | Delegated/OBO expectation | App-only expectation | Problem signal |
|---|---|---|---|
| `aud` | Target API or gateway audience. | Target API or Azure resource audience. | Wrong backend, bypass, or token reuse. |
| `scp` | Present with delegated scopes. | Absent. | Missing consent or app-only path mistaken for OBO. |
| `roles` | Usually absent unless app roles are used by resource. | Present for application permissions/app roles. | Broad app role or wrong resource. |
| `oid` / `sub` | User and app correlation must be explainable in logs. | Service principal or managed identity actor. | Actor cannot be tied to app/agent. |
| `appid` / `azp` | Client app that initiated OBO. | App/service principal that requested token. | Unexpected client. |
| `upn` / user claims | Present when policy requires user-context inspection. | Absent. | User context missing from delegated claim. |
| `xms_mirid` | Usually absent. | Present for managed identity tokens where applicable. | Host identity mismatch. |
| CA result | User and app policy outcome visible in sign-in logs. | Workload identity CA outcome where configured. | Blocked or uninspected policy path. |

## 5. Safe inspection activity

1. Run one synthetic non-customer request through the named app/agent.
2. Capture safe correlation: request ID, trace ID, APIM request ID, sign-in
   correlation ID, and time window.
3. Decode token claims in the customer environment and write down only the claim
   check result state: matched, missing, overbroad, blocked, unsupported.
4. Open portal records in the sequence above.
5. Compare requested permission to granted permission and backend result.
6. Record the owner, fix route, and recheck condition.

## 6. Expected result states

| State | Meaning | Next action |
|---|---|---|
| Verified | Token audience, actor, authority mode, permission, CA outcome, and logs match the intended route. | Continue dependent S3/S5 work with this route reference. |
| Missing consent | Permission is requested but not granted on the enterprise app or downstream API. | Route to consent owner. |
| Overbroad | Permission or RBAC scope exceeds the operation. | Route to permission/resource owner for narrowing. |
| Unmanaged credential | Secret/certificate exists without owner, rotation, or retirement plan. | Route to managed identity/federation or credential owner. |
| Blocked by CA | Sign-in shows CA failure, interruption, or policy mismatch. | Route to CA owner with sign-in reference. |
| Unsupported OBO/tool path | User-context assumption cannot be supported by the backend, connector, or tool. | Block OBO claim; route to app/tool owner. |
| Agent ID unavailable | No supported Agent ID/Agent 365 record for the workload. | Use custom-app fallback and recheck product support. |
| Unobservable | Logs cannot distinguish user, app, agent, gateway, and backend. | Route to app/platform telemetry owner before production reliance. |

## 7. Support limits

| Area | Supported claim | Limit |
|---|---|---|
| App registration | Requested scopes, credentials, federation, owners, and exposed scopes can be inspected. | Requested permission is not the same as granted consent. |
| Enterprise app | Granted consent, assignments, sign-ins, and CA result can be inspected. | Some logs delay or require roles/licensing. |
| Managed identity | Principal and Azure RBAC can be inspected. | It may not represent the agent or user by itself. |
| Federated credential | Issuer/subject/audience can be inspected. | Wildcards or external issuers need owner review; S1 does not fix them. |
| Agent ID / Agent 365 | Use where tenant/workload supports it. | Fall back to custom app + owner register when unsupported. |
| OBO | Delegated scopes and sign-in correlation can be checked. | Backend/tool support must be verified; app-only fallback is not OBO. |
| Conditional Access | Sign-in details can identify applied policies and blocks. | S1 does not change policies or bypass CA. |

## 8. Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Identity path | User/trigger, app registration, service principal, host identity, agent branch, authority mode, and target permission are all named. | Identity owner / app owner |
| Portal inspection | App registration, enterprise app, credential/federation, permissions, sign-in logs, and CA dependency are opened or the blocker is routed. | Identity admin |
| Token checks | `aud`, `scp`/`roles`, actor, user-context presence/absence, client app, and managed identity indicator are checked. | App/security owner |
| Permission result | Granted scope/app role/RBAC/gateway/connector permission matches the operation or the overbroad/missing grant is routed. | Resource/API owner |
| Credential result | No unmanaged secret remains unowned; managed identity or federation route is named. | Platform owner |
| Agent branch | Agent ID/Agent 365 record is inspected where supported or custom-app fallback and recheck condition are recorded. | Identity platform owner |
| Fix route | Missing consent, overbroad permission, CA block, unsupported OBO/tool path, and observability gap each have owner and recheck condition. | Governance lead |

## Boundary note

S1 performs read-only inspection and routes fixes. It grants no access, changes
no Conditional Access policy, creates no identity, rotates no credential, and
approves no production release.
