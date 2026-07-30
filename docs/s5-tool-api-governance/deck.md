# S5 · API and Tool Admission Workflow

**Facilitator deck**

Microsoft default: **Azure API Center, Azure API Management, Entra/JWT or
managed identity, delegated/OBO where needed, connector governance, MCP
publication controls, operation allow-lists, schema validation, rate/quota
policy, diagnostics, and withdrawal route**.

Concrete decision: **Can this consumer call one allowed operation through the
approved route, and does one denied out-of-scope operation fail closed with
telemetry?**

---

## Start with one consumer and one operation

- Consumer agent/app/workflow.
- Tool/API/connector/MCP server and version.
- Operation ID or tool name.
- Data class and side effects.
- Allowed and blocked operations.
- Route ID, auth mode, logs, and withdrawal owner.

Note:
"API access" is too broad. The operation is the unit of admission.

---

## Register or inspect API Center

Route:

**Azure portal** -> **API Center** -> API -> version.

Check:

- definition, environment, deployment;
- lifecycle state;
- owner/contact and custom properties;
- link to APIM or approved route;
- exception/deprecation owner.

Note:
If API Center is not used, the customer catalog must show the same fields.

---

## Inspect APIM import and policy route

Route:

**Azure portal** -> **API Management services** -> instance -> **APIs** -> API
-> operation.

Check:

- imported operations match contract;
- product/subscription maps to consumer;
- backend route is approved;
- JWT/subscription/backend auth policy;
- schema/content validation;
- rate/quota/token policy;
- diagnostics and correlation;
- direct endpoint bypasses.

Note:
Do not paste live APIM policy. Record policy family, owner, and expected signal.

---

## Review connector, MCP, or tool contract

Inspect:

- connector permission model, admin consent, environment/DLP boundary, allowed
  actions, logging, disable route;
- MCP server owner, publication state, tool schema, auth scopes, consumer list,
  rate/quota, audit, unpublish path;
- direct SDK/tool owner, version, credentials, network route, logs, replacement
  or exception owner.

Note:
Local MCP tools and developer credentials are blockers unless the customer owns
and observes the route.

---

## Build the operation allow-list

Name:

- operation ID/tool name/method;
- schema version;
- required fields and allowed resources;
- denied fields, methods, targets, and side effects;
- read/write/admin/export/external side-effect class;
- approval requirement;
- over-scope failure behavior.

Note:
If the allow-list cannot be written, the operation is not ready for admission.

---

## Verify auth, schema, and quota

Check:

- token audience, issuer, `scp`/`roles`;
- managed identity, OBO, RBAC, connector consent, or MCP auth;
- APIM subscription/product where used;
- schema validation for valid and invalid payloads;
- `rate-limit`, `quota`, `llm-token-limit`, connector/MCP throttles;
- cost/token/capacity owner.

Note:
Auth success alone is not enough; it must authorize the bounded operation.

---

## Run two safe tests

Allowed synthetic operation:

- non-customer payload;
- approved route;
- expected schema, auth, policy, backend, telemetry.

Denied out-of-scope operation:

- blocked method/tool/parameter/scope/admin action;
- expected 401/403/404/405/429 or schema failure;
- no backend side effect;
- telemetry event.

Note:
If live testing is not approved, use an existing non-production denial trace or
customer-approved mock/sandbox.

---

## Expected signals

| Signal | Good result |
|---|---|
| Registered API | API Center/catalog has version, route, owner, lifecycle. |
| Approved operation list | Allowed and denied operations are explicit. |
| Auth enforced | Gateway/app/tool log shows expected auth result. |
| Schema mismatch | Invalid request fails before side effect. |
| Policy hit | Rate/quota/schema/auth/deny policy logs event. |
| Telemetry event | Allowed and denied calls are joinable. |
| Blocked operation | Out-of-scope call fails closed. |
| Withdrawal owner | Disable/revoke/unpublish route is named. |

Note:
If the denied operation succeeds, admission blocks.

---

## Withdraw first

Before admission, know how to:

- disable APIM product/API/operation/backend;
- remove allow-list entry;
- revoke consent, scope, app role, RBAC, or connector permission;
- unpublish MCP tool;
- rotate credential;
- notify consumers;
- preserve logs;
- verify closed with a denied synthetic request or approved trace.

Note:
If nobody can withdraw it, nobody should admit it.

---

## Decide and hand over

Options:

- admit into customer change process;
- defer with owner and recheck;
- reject unsafe operation;
- withdraw existing route;
- block missing owner/auth/logging/withdrawal;
- route unsupported product fit.

Note:
S5 changes no tenant policy, configures no gateway, grants no permission, and
approves no production release.
