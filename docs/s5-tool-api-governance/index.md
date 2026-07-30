# S5 · API and Tool Admission Workflow

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Use this as an end-to-end admission and withdrawal workflow for one API, connector, MCP tool, or tool operation. Verify service support, tenant policy, and customer-owned change routes before delivery.

<span class="rvas-badge rvas-persona">API platform owner</span> <span class="rvas-badge rvas-persona">Tool owner</span> <span class="rvas-badge rvas-persona">Security reviewer</span> <span class="rvas-badge rvas-persona">Agent/app owner</span>

!!! abstract "What this workshop does"
    S5 admits or blocks one bounded operation for one bounded consumer. It checks API Center registration, APIM import and gateway policy, connector/MCP/tool contract, operation allow-list, auth mode, schema validation, rate/quota policy, logging, safe allowed/denied tests, and withdrawal owner.

## 1. Admit one operation, not broad API access

Use one consumer and one operation:

- consumer agent/app/workflow and environment;
- tool/API/connector/MCP server and version;
- operation name, method, schema, data class, side effects, and blocked
  operations;
- auth mode and token audience/scope/role;
- gateway or direct-route exception;
- telemetry and correlation;
- withdrawal owner and verification step.

The question is:

**Can this consumer call this allowed operation through an approved route, and
does the route block one out-of-scope operation without losing telemetry?**

## 2. Default admission sequence

Follow this order. Skip a step only when the customer has an owned equivalent
route.

1. **API Center registration**: open **Azure portal** -> **API Center** -> API.
   Verify API name, version, definition, environment, deployment, lifecycle
   state, owner/contact, data classification/custom properties, and related APIM
   deployment. If API Center is not used, open the customer catalog with the same
   fields.
2. **APIM import and route**: open **Azure portal** -> **API Management
   services** -> APIM -> **APIs**. Verify the API was imported or represented,
   operations match the contract, product/subscription maps to the consumer,
   backend is the approved target, and direct endpoints are exception-owned.
3. **Gateway policy**: inspect inbound/backend/outbound policy references for
   JWT validation, managed identity or credential manager backend auth,
   schema/content validation where used, rate/quota/token limits, diagnostics,
   and blocked operation behavior. Do not paste live policy.
4. **Connector/MCP/tool contract**: inspect connector permission model, admin
   consent, environment/DLP boundary, MCP server/tool schema, version, auth
   scopes, publication state, source owner, and unpublish path.
5. **Operation allow-list**: list allowed operations, denied operations,
   parameter boundaries, data classes, write/admin limits, and approval
   requirements.
6. **Auth mode**: verify Entra app, managed identity, delegated/OBO, app role,
   RBAC, APIM subscription, connector consent, or MCP auth is the intended mode.
7. **Schema validation**: check OpenAPI/JSON schema/tool schema version, required
   fields, enum/resource limits, max payload, and failure response for mismatch.
8. **Rate/quota/cost policy**: check APIM `rate-limit`, `quota`,
   `llm-token-limit`, connector throttles, MCP rate controls, or customer
   equivalent, plus owner for exception and cost allocation.
9. **Logging**: check APIM diagnostics, app/tool logs, Application Insights, Log
   Analytics, request ID, tool-call ID, consumer ID, user/session ID where
   appropriate, and retention owner.
10. **Withdrawal path**: verify who can disable the APIM product/API/backend,
    remove allow-list entry, revoke consent/scope/RBAC, unpublish MCP tool,
    suspend connector, rotate credentials, notify consumers, and confirm the
    route is closed.

## 3. Safe admission test

Use synthetic non-customer payloads only.

### Allowed operation

Run one safe read-only or harmless operation that is already in the allow-list.
Record:

- consumer alias and route ID;
- operation ID/tool name and schema version;
- auth mode and expected audience/scope/role;
- request/time window/correlation ID;
- expected policy hit and backend;
- expected telemetry tables or portal views.

Expected result: 2xx or documented harmless success, schema accepted, auth
enforced, quota/log policy hit, telemetry emitted, and backend route matched.

### Denied out-of-scope operation

Run or dry-run one denied operation using a synthetic request, such as a blocked
method, unapproved tool name, forbidden parameter, oversized payload, missing
scope, or admin/write action outside the allow-list.

Expected result: 401/403/404/405/429 or schema validation failure as designed,
policy or tool contract denies the call, no backend side effect occurs, telemetry
records the denial, and the owner knows how to fix false positives.

If live denial testing is not approved, inspect an existing non-production
denial trace or run the request in a customer-approved mock/sandbox.

## 4. Expected signals

| Signal | How to verify | Result route |
|---|---|---|
| Registered API | API Center/catalog has API/tool, version, environment, lifecycle, owner, and deployment link. | Missing/stale record routes to catalog owner. |
| Approved operation list | Allow-list names operation, method/tool, parameters, data class, side effects, and denied operations. | Missing boundary routes to tool/API owner. |
| Auth enforced | APIM/app/tool log shows JWT/subscription/managed identity/OBO/connector/MCP auth result. | Failure routes to identity/gateway owner. |
| Schema mismatch | Invalid payload is blocked before backend side effect or by the tool contract. | Failure routes to API/tool owner. |
| Policy hit | APIM/gateway/connector/MCP policy logs rate/quota/schema/auth/deny decision. | Missing policy route goes to platform owner. |
| Telemetry event | Application Insights/Log Analytics/tool logs show allowed and denied test events with correlation. | Empty logs route to telemetry owner. |
| Blocked operation | Out-of-scope operation fails closed and leaves no backend side effect. | If it succeeds, block admission. |
| Withdrawal owner | Owner and exact disable/revoke/unpublish route are named. | Missing owner blocks admission. |

## 5. Support limits

Record these as blockers or routed gaps:

- Unmanaged direct tools that bypass catalog, gateway, auth, logging, or owner.
- Local MCP servers not centrally published, not observable, or using developer
  credentials.
- Broad connector permissions, tenant-wide consent, or environment DLP boundary
  not understood by the owner.
- Missing API/tool owner, missing consumer owner, or missing withdrawal owner.
- Non-observable calls: no request ID, no tool-call ID, no gateway/app/tool log,
  sampled-away telemetry, or no retention owner.
- Dynamic tool chaining that expands operation authority without re-review.
- Schema or operation drift between OpenAPI/tool schema, APIM operations,
  connector action, and actual backend.

S5 does not publish APIs, import APIM routes, grant consent, create identities,
configure policies, approve connectors, register MCP servers, test customer data,
or approve production. It records what must be opened, tested, blocked, fixed, or
withdrawn by the customer's change process.

## 6. Lab output

`labs/s5-tool-api-governance/` contains the admission test lab and template. The
completed customer record should include API Center/catalog route, APIM policy
route, connector/MCP/tool contract, operation allow-list, auth mode, schema
validation result, rate/quota/logging result, allowed/denied test IDs,
withdrawal owner, fix route, and recheck condition.

## Related references

- [Technical decisions](technical.md)
- [Platform technical guide](../reference/platform-technical-guide.md)
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md)
