# S5 · API and Tool Admission Workflow: Technical runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Azure API Center, Azure API Management, APIM AI Gateway policies, Entra/JWT, managed identity, delegated/OBO, connector governance, MCP publication, and tool schemas vary by tenant and product support.

## Microsoft default

Default to Azure API Center for catalog and lifecycle, Azure API Management for
the gateway route, Microsoft Entra/JWT or managed identity for caller/backend
auth, connector/MCP publication controls where applicable, operation allow-lists,
schema validation, quota/rate limits, diagnostics, and a withdrawal path.

![S5 tool/API admission package: trace one consumer through identity, catalog/API Center, gateway or alternative route, operation boundary, audit/correlation, and withdrawal path before admitting the tool.](../assets/diagrams/s5-tool-api-governance-record-model.svg)

S5 admits, blocks, or withdraws one operation for one consumer. It does not
change tenant configuration.

## 1. Preflight

| Check | Required detail | Blocker if missing |
|---|---|---|
| Consumer | Agent/app/workflow, environment, owner, lifecycle state. | Do not review anonymous consumers. |
| Operation | Method/tool/action, schema version, data class, side effect, allowed resources, blocked operations. | Do not approve broad API access. |
| Route | API Center/catalog, APIM/gateway, connector, MCP, allow-list, or owned direct exception. | Route missing owner or bypass. |
| Auth | Entra app, managed identity, delegated/OBO, app role, RBAC, APIM subscription, connector consent, MCP auth. | Block missing/unclear auth. |
| Observability | Request ID, tool-call ID, APIM/app/tool logs, workspace, retention owner. | Block non-observable calls. |
| Withdrawal | Disable/revoke/unpublish/remove/rotate/notify/verify owner. | Block if no withdrawal owner. |
| Safe test | One allowed synthetic operation and one denied out-of-scope synthetic operation or approved trace review. | Do not use customer data. |

## 2. API Center registration

Portal route:

1. **Azure portal** -> **API Center**.
2. Open API -> version -> definition, environments, deployments, lifecycle,
   contacts/owners, custom properties, and related APIM deployment.

CLI anchors:

```bash
az apic api show --service-name "$APIC" --resource-group "$RG" --api-id "$API_ID"
az apic api version list --service-name "$APIC" --resource-group "$RG" --api-id "$API_ID"
```

Accept when the API/tool/model route has a version, environment, owner,
lifecycle, deployment, and operation contract. If API Center is not used, inspect
the customer catalog with the same fields.

## 3. APIM import and gateway policy

Portal route:

1. **Azure portal** -> **API Management services** -> instance.
2. Open **APIs** -> selected API.
3. Inspect imported operations, **Design**, **Settings**, **Inbound processing**,
   **Backend**, **Outbound processing**, **Products**, **Subscriptions**,
   **Diagnostics**, **Logs**, **Policy fragments**, and **Named values**
   references.

CLI anchors:

```bash
az apim api show --resource-group "$RG" --service-name "$APIM" --api-id "$API_ID" \
  --query "{name:name,path:path,apiRevision:apiRevision,serviceUrl:serviceUrl}"
az apim api operation list --resource-group "$RG" --service-name "$APIM" --api-id "$API_ID" \
  --query "[].{id:name,method:method,urlTemplate:urlTemplate}"
az monitor diagnostic-settings list --resource "$APIM_RESOURCE_ID" \
  --query "[].{name:name,workspaceId:workspaceId,logs:logs[].category}"
```

Policy checks to record by owner/reference, not by pasting live policy:

| Policy area | What to inspect |
|---|---|
| Auth | `validate-jwt`, subscription/product requirement, managed identity, delegated/OBO, mTLS, or customer equivalent. |
| Backend | `set-backend-service`, managed identity/backend credential, credential manager, circuit breaker, retry, fallback. |
| Schema/input | `validate-content`, OpenAPI validation, JSON schema validation, required fields, max payload, parameter allow-list. |
| Rate/quota | `rate-limit`, `quota`, `llm-token-limit`, connector/MCP throttle, counter key, exception owner. |
| Safety where relevant | Content Safety, Prompt Shields, blocklists, output controls, runtime-safety handoff. |
| Logging | Diagnostics, correlation header, Application Insights/Log Analytics destination, retention owner. |
| Deny behavior | Status code and error surface for missing auth, schema mismatch, unapproved operation, and quota exceeded. |

## 4. Connector, MCP, and tool contract review

Open the route that the consumer will actually use:

| Route | Inspect |
|---|---|
| Connector | Connector owner, environment, admin consent, delegated/app permission model, DLP/data boundary, solution/package version, allowed actions, throttles, logging, disable/withdrawal route. |
| MCP server/tool | Server owner, publication state, tool name, schema version, auth scopes, consumer list, rate/quota, audit log, source trust, local/developer credential use, unpublish route. |
| Direct SDK/tool | Package/source owner, version pin, credentials, allowed methods, network route, logging, replacement plan or exception owner. |
| Runtime-control referral | Per-call allow/deny/approval owner, policy input fields, telemetry, failure mode, and stop condition. |

Do not admit local MCP tools, broad connectors, or direct SDK calls unless the
customer names the owner, auth, observable route, and withdrawal path.

## 5. Operation allow-list and schema validation

The allow-list must name:

- operation ID/tool name/method;
- schema version and definition source;
- required and optional fields;
- allowed resource patterns or IDs by safe alias;
- denied methods, fields, targets, and side effects;
- read/write/admin/export/external side-effect class;
- approval requirement and over-scope behavior.

Schema validation checks:

- OpenAPI or JSON schema matches APIM operation and backend.
- MCP tool schema matches published tool and runtime implementation.
- Connector action parameters match allowed data classes.
- Invalid field, missing required field, oversized payload, wrong enum, or
  unauthorized resource is rejected before backend side effect where possible.

## 6. Auth, scope, and quota

| Area | Check |
|---|---|
| Caller auth | Token audience, issuer, `scp`/`roles`, APIM subscription, product, connector consent, MCP auth. |
| Backend auth | Managed identity, app registration, credential manager, Key Vault-backed credential, OBO exchange, or connector backend identity. |
| Scope | Delegated scope, application role, RBAC, connector permission, data permission, or allow-list resource boundary. |
| Quota | Counter key: subscription, app, team, user/session, agent identity, tool name, or custom header. |
| Cost | Token/call budget owner, APIM product quota owner, model quota/capacity owner, exception owner. |

## 7. Logging and telemetry

Required join fields:

- consumer/app/agent alias;
- operation ID or tool name;
- request ID / correlation ID / APIM request ID;
- user/session ID where applicable;
- auth result and policy result;
- backend result and side-effect result;
- denied-operation result;
- workspace/table/query owner and retention owner.

Kusto examples to adapt:

```kusto
AzureDiagnostics
| where TimeGenerated between (datetime({start}) .. datetime({end}))
| where ResourceProvider has "MICROSOFT.APIMANAGEMENT"
| where requestId_s == "{request-id}" or CorrelationId_g == "{correlation-id}"
| project TimeGenerated, apiId_s, operationId_s, responseCode_d, backendUrl_s
```

```kusto
AppTraces
| where TimeGenerated between (datetime({start}) .. datetime({end}))
| where Message has "{tool-call-id}" or OperationId == "{trace-id}"
| project TimeGenerated, OperationId, SeverityLevel, Message
```

## 8. Safe allowed and denied tests

### Allowed synthetic operation

1. Use a non-customer payload and an operation on the approved allow-list.
2. Send through the approved route.
3. Record route ID, operation ID/tool name, schema version, auth mode, time
   window, request ID, expected policy, backend alias, and expected telemetry.
4. Verify success response, auth enforcement, schema acceptance, policy hit,
   backend route, quota/log event, and no unexpected side effect.

### Denied out-of-scope operation

1. Use a synthetic request that violates one boundary: missing scope, blocked
   method, unapproved tool name, forbidden parameter, oversize payload, admin
   action, or unapproved resource alias.
2. Send through sandbox/non-production, mock, or inspect an approved denial trace.
3. Verify 401/403/404/405/429 or schema validation failure, no backend side
   effect, telemetry event, and owner for false-positive fix.

Do not test with customer data or destructive actions.

## 9. Withdrawal path

Before admission, confirm who can perform and verify each action:

| Withdrawal step | Route to inspect |
|---|---|
| Disable route | APIM product/API/operation/backend, connector, MCP tool, allow-list, catalog lifecycle state. |
| Remove permission | Entra consent, delegated scope, app role assignment, RBAC assignment, connector permission. |
| Revoke credential | Managed identity assignment, service principal secret/cert, Key Vault credential, MCP secret, connector credential. |
| Notify consumers | Consumer owner, release owner, service desk/status page, backlog/change route. |
| Preserve logs | APIM/app/tool/audit logs, retention, incident reference, investigation owner. |
| Verify closed | Denied synthetic request, absence of backend side effect, catalog lifecycle update, owner signoff. |

## 10. Expected result states

| State | Meaning | Next action |
|---|---|---|
| Admitted for change process | Registered, routed, allow-listed, auth enforced, schema checked, quota/logging visible, allowed and denied tests pass, withdrawal owner named. | Enter customer change/release process. |
| Defer | One fixable route, schema, policy, telemetry, or owner gap has accepted-when criteria. | Assign owner and recheck. |
| Reject | Operation authority, data class, side effect, or consumer fit is unsafe for the pilot. | Do not admit. |
| Withdraw | Existing route should be disabled/revoked/unpublished and verified. | Execute customer withdrawal process. |
| Block | Missing owner, auth, observable route, operation boundary, or withdrawal path. | Stop until fixed. |
| Unsupported | Product route cannot provide required control for the operation. | Route to architecture/platform owner. |

## 11. Support limits

| Limit | Why it matters |
|---|---|
| Unmanaged direct tools | They bypass catalog, gateway policy, auth, logging, quota, and withdrawal. |
| Local MCP servers | Developer-local tools may use personal credentials and lack central publication or telemetry. |
| Broad connector permissions | Admin consent or environment-wide connector grants can exceed one operation. |
| Missing owner | Admission and withdrawal need API/tool, consumer, identity, platform, telemetry, and release owners. |
| Non-observable calls | No request/tool-call ID, logs, retention, or query owner means denied and allowed behavior cannot be checked. |
| Schema drift | API Center, APIM, connector/MCP schema, and backend can diverge after admission. |
| Dynamic tool chaining | Tool selection can expand authority at runtime and may need per-call control. |

## 12. Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| API Center/catalog | API/tool has version, definition, environment, deployment, lifecycle, owner, and deployment link or gap route. | Catalog owner |
| APIM/gateway | API/operation/product/backend/policy/diagnostics/bypass owner are inspected. | Gateway owner |
| Connector/MCP/tool | Contract, auth scopes, publication state, consumer scope, logging, and unpublish path are inspected. | Tool/connector owner |
| Allow-list | Allowed and denied operations, parameters, data class, side effects, and over-scope behavior are explicit. | API/tool owner |
| Auth | Audience/scope/role/subscription/identity/consent matches the operation. | Identity owner |
| Schema validation | Valid payload succeeds and invalid payload fails closed or the gap is routed. | API/tool owner |
| Quota/logging | Rate/quota/cost policy and telemetry events are visible or routed. | Platform/FinOps/telemetry owner |
| Allowed/denied tests | One allowed synthetic operation and one denied out-of-scope operation are verified or approved trace review is recorded. | Security reviewer |
| Withdrawal | Disable, revoke, unpublish, rotate, notify, preserve logs, and verify-closed route have owners. | Operations/release owner |

## Boundary note

S5 performs admission inspection and safe testing. It publishes nothing, imports
no APIs, grants no consent, creates no identities, configures no gateway,
registers no MCP server, changes no connector, uses no customer data, and
approves no production release.
