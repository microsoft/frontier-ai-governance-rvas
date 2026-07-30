# S1 · Identity Path Trace

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Use this as a read-only trace for one agent or app. Verify tenant features, roles, licenses, and product support before delivery.

<span class="rvas-badge rvas-persona">Identity admin</span> <span class="rvas-badge rvas-persona">App owner</span> <span class="rvas-badge rvas-persona">Security reviewer</span>

!!! abstract "What this workshop does"
    S1 traces one user request from user identity to app or agent identity to the tool/API permission that allows or denies the action. It inspects Entra records, token claims, permissions, Conditional Access dependencies, and disable routes without creating identities or changing grants.

## 1. Pick one request and follow the identity path

Use one bounded pilot agent, app, or agent-like workload. The customer should be
able to open the actual Entra and Azure records and answer:

**Which user or process starts the request, which app/agent identity receives or
exchanges a token, which API or resource permission is used, and what blocks or
disables the path when it is wrong?**

Trace this route:

1. **User or trigger**: signed-in user, scheduler, event, pipeline, or service.
2. **Client/app registration**: app registration, enterprise app service
   principal, redirect/API permissions, owners, credentials, and consent.
3. **Host workload identity**: managed identity, service principal, federated
   credential, workload identity federation, or stored credential exception.
4. **Agent identity branch**: Entra Agent ID / Agent 365 where supported; custom
   app or customer register fallback when unsupported.
5. **Authority mode**: app-only, delegated OAuth, on-behalf-of (OBO), or separate
   app-only and OBO paths.
6. **Tool/API permission**: Graph/API delegated scope, application role, Azure
   RBAC assignment, connector permission, APIM product/subscription, or resource
   data permission.
7. **Conditional Access and logs**: workload identity CA where relevant, sign-in
   logs, audit logs, APIM/app/resource telemetry, and SIEM handoff.
8. **Fix route**: exact owner and route to narrow permission, grant missing
   consent, remove a secret, adjust CA, block unsupported OBO/tool use, or disable
   the app/agent path.

Keep tokens, claims payloads, object IDs, endpoints, sign-in records, and
screenshots in the customer's approved system. In this repo, store only blank
templates and safe field names.

## 2. Open the records in the right order

### Entra portal inspection

Use these routes during the trace:

- **Microsoft Entra admin center** -> **Identity** -> **Applications** -> **App
  registrations** -> app -> **Overview**, **Owners**, **Authentication**,
  **Certificates & secrets**, **Federated credentials**, **API permissions**,
  **Expose an API**, **App roles**, **Manifest**.
- **Microsoft Entra admin center** -> **Identity** -> **Applications** ->
  **Enterprise applications** -> service principal -> **Overview**, **Owners**,
  **Permissions**, **Users and groups**, **Sign-in logs**, **Audit logs**,
  **Conditional Access**.
- **Azure portal** -> resource -> **Identity** for system-assigned or
  user-assigned managed identity; then open **Azure role assignments** on the
  target scope.
- **Microsoft Entra admin center** -> **Protection** -> **Conditional Access** ->
  **Policies** and **Sign-in logs** when a policy may block the app, workload
  identity, or delegated user path.
- **Microsoft Entra admin center** -> **Identity** -> **Applications** -> **Agent
  identities / Agent ID** or **Agent 365** where available. If the tenant or
  workload does not expose an agent identity record, use the custom app/service
  principal plus customer owner register fallback and record the unsupported
  branch.

### Graph and CLI read-only checks

Use customer-approved read permissions only. Replace placeholders in the
customer's shell; do not paste output into this repo.

```powershell
# Microsoft Graph PowerShell: app registration and service principal
Get-MgApplication -ApplicationId $ClientId |
  Select-Object Id, AppId, DisplayName, SignInAudience, RequiredResourceAccess
Get-MgServicePrincipal -Filter "appId eq '$ClientId'" |
  Select-Object Id, AppId, DisplayName, AccountEnabled, ServicePrincipalType

# Owners, credentials, federated credentials, and app roles
Get-MgApplicationOwner -ApplicationId $AppObjectId
Get-MgApplicationPasswordCredential -ApplicationId $AppObjectId
Get-MgApplicationFederatedIdentityCredential -ApplicationId $AppObjectId
Get-MgApplicationAppRole -ApplicationId $AppObjectId

# Granted app roles and delegated OAuth grants
Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $SpObjectId
Get-MgOauth2PermissionGrant -Filter "clientId eq '$SpObjectId'"

# Sign-in and audit checks by app or service principal
Get-MgAuditLogSignIn -Filter "appId eq '$ClientId' and createdDateTime ge $Start"
Get-MgAuditLogDirectoryAudit -Filter "targetResources/any(t:t/id eq '$AppObjectId')"
```

```bash
# Azure CLI: managed identity, role assignments, and federated credential
az identity show --ids "$USER_ASSIGNED_IDENTITY_RESOURCE_ID" \
  --query "{name:name, principalId:principalId, clientId:clientId, tenantId:tenantId}"
az role assignment list --assignee "$PRINCIPAL_ID" --all \
  --query "[].{role:roleDefinitionName, scope:scope, principalType:principalType}"
az ad app federated-credential list --id "$APP_ID" \
  --query "[].{name:name, issuer:issuer, subject:subject, audiences:audiences}"
az ad app credential list --id "$APP_ID" \
  --query "[].{displayName:displayName, endDateTime:endDateTime, hint:hint}"
```

## 3. Run the safe inspection activity

No permissions change is needed.

1. Select one non-production user request or replay a synthetic request that uses
   non-customer data.
2. Capture a safe correlation handle: time window, app alias, request ID/header
   name, APIM request ID, trace ID, or sign-in correlation ID.
3. Decode only the headers and claims needed in the customer system. Check:
   `aud`, `azp`/`appid`, `scp` or `roles`, `oid`/`sub`, `tid`, `upn` or absence
   of user claim, `xms_mirid` for managed identity where present, and OBO claim
   indicators where used.
4. Open the app registration and enterprise app. Verify owners, consent, app
   roles, delegated scopes, secrets/certificates, federated credentials, and
   sign-in result.
5. Open the managed identity or federated credential if the host exchanges a
   token. Check issuer, subject, audience, and revocation owner.
6. Open the API/resource authorization: Graph/API permission, Azure RBAC
   assignment, APIM product/subscription, connector grant, or backend ACL.
7. Check Conditional Access sign-in details when a user, workload identity, or
   enterprise app policy may allow or block the path.
8. Record the result state and route the fix. Do not add consent, create secrets,
   change CA, or update RBAC during S1.

## 4. Expected signals

| Signal | What to check | Result route |
|---|---|---|
| Token audience | `aud` matches the intended API or gateway, not a management endpoint or unrelated resource. | Wrong audience routes to app/gateway owner. |
| User context present | Delegated/OBO path has `scp` and user claims that correlate to sign-in logs. | Missing user context routes to app owner; do not treat as OBO. |
| User context absent | App-only path has `roles`/app role or RBAC and no user claim. | Confirm sponsor and app-only purpose. |
| Overbroad permission | `Directory.ReadWrite.All`, `Sites.FullControl.All`, Owner/Contributor at broad scope, wildcard app role, or broad connector permission. | Route to permission owner for narrowing or exception review. |
| Missing consent | Required delegated scope/app role exists in app registration but no enterprise app grant or admin consent. | Route to consent owner; do not test by granting. |
| Unmanaged secret | Client secret/certificate exists without owner, rotation, Key Vault, or retirement trigger. | Route to managed identity/federation or time-bound credential fix. |
| Blocked Conditional Access | Sign-in shows interrupted/failure due to CA, device, location, risk, workload identity policy, or terms. | Route to CA owner with sign-in reference. |
| Unsupported OBO/tool path | Tool or connector uses app-only token where user-scoped action was assumed, or OBO is unsupported by backend. | Route to app/tool owner; block user-context claim until fixed. |
| Agent ID unsupported | Agent ID / Agent 365 record is unavailable for tenant/workload. | Use custom app fallback and record product recheck condition. |

## 5. Support limits

S1 supports read-only identity-path inspection. It does not grant consent,
create app registrations, provision Agent IDs, assign RBAC, edit Conditional
Access, rotate secrets, update gateway policy, or approve production.

Record these limits when they apply:

- Agent ID / Agent 365 availability varies by tenant, workload, license, and
  product surface; unsupported workloads need a custom app/service-principal
  fallback and recheck condition.
- A service principal proves an app can sign in; it does not by itself prove the
  accountable agent, sponsor, or resource permission.
- Delegated permission proves a user-context token can be requested; it does not
  prove the backend honors user entitlements unless OBO and resource checks are
  observed.
- Conditional Access may block a valid token path. Treat CA failure as a routing
  signal, not as a reason to bypass policy.
- APIM or gateway JWT validation is one boundary. Backend API permission and
  resource authorization still need inspection.

## 6. Lab output

`labs/s1-identity/` contains the read-only inspection lab and template. The
completed customer record should include token/claim checks, permission result,
owner, fix route, and recheck condition without storing secrets, raw tokens,
personal data, tenant IDs, or live configuration in this repository.

## Related references

- [Technical decisions](technical.md)
- [Governance capability guide](../reference/governance-capability-guide.md)
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md)
