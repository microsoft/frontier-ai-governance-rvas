# S1 · Identity Path Trace lab kit

Use this lab to inspect one non-production app/agent identity path without
changing permissions. Complete the template in the customer's approved records
system. This repository keeps only blank templates and safe field shapes.

## Inputs

- One synthetic or non-production user request, app/agent alias, tool/API
  operation, and time window.
- Reader access to Entra app registrations, enterprise applications, sign-in
  logs, audit logs, managed identity/RBAC, gateway/API route, and Conditional
  Access details where relevant.
- Safe correlation handle: request ID, APIM request ID, trace ID, or sign-in
  correlation ID.
- Named identity, app, platform, gateway/API, CA, and security owners.
- Customer-approved location for token claim notes and portal references.

## Steps

1. Select one request and confirm no customer data, raw token, endpoint, tenant
   ID, secret, or screenshot will be stored in this repo.
2. Open **Entra admin center** -> **Identity** -> **Applications** -> **App
   registrations** -> app. Inspect Overview, Owners, Authentication,
   Certificates & secrets, Federated credentials, API permissions, Expose an
   API, App roles, and Manifest when needed.
3. Open **Enterprise applications** -> service principal. Inspect Permissions,
   Users and groups, Sign-in logs, Audit logs, and Conditional Access result.
4. Open the managed identity or workload federation path in Azure/Entra. Check
   principal, issuer, subject, audience, RBAC scope, and revocation owner.
5. Open Entra Agent ID / Agent 365 where supported. If unsupported, record the
   custom app/service-principal fallback and product recheck condition.
6. Decode only safe claim checks in the customer environment: `aud`,
   `scp`/`roles`, actor, user context present/absent, client app, managed
   identity indicator, and CA result.
7. Open the target permission record: Graph/API permission, Azure RBAC, APIM
   product/subscription, connector grant, or backend ACL.
8. Mark the permission result: verified, missing consent, overbroad, unmanaged
   secret, blocked by CA, unsupported OBO/tool path, Agent ID unavailable, or
   unobservable.
9. Record owner, fix route, and recheck condition.

## Required technical fields

- Request and correlation handle
- App registration and service principal
- Managed identity / federated credential
- Agent ID branch or custom-app fallback
- Runtime mode: app-only, delegated/OBO, or mixed
- Token/claim checks: `aud`, `scp`, `roles`, actor, user context, client app
- API permission / RBAC / gateway / connector result
- Conditional Access and sign-in result
- Owner, fix route, and recheck condition

## Files

- `templates/identity-review.addendum.md`
- `../templates/decision-record.template.md` for the shared short wrapper when
  the delivery workspace needs one.

## Output

A customer-owned identity-path trace that shows what was opened, checked,
allowed, denied, missing, blocked, or unsupported. The lab does not create
identities, grant consent, assign RBAC, edit Conditional Access, rotate
credentials, export logs, or approve release.
