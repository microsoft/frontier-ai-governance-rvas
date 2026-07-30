# S5 · Tool/API Admission & Withdrawal

**Facilitator deck**

Microsoft default: **Azure API Center, Azure API Management, Entra/JWT,
managed identity or delegated OAuth, connector governance, allow-lists, and MCP
publication controls**.

Concrete decision: **Can this bounded consumer call this bounded operation
through an approved Microsoft control path, and can the customer withdraw it?**

---

## The tool call is the governance unit

- Do not approve "API access" in the abstract.
- Trace one consumer, one route, one identity contract, one operation, one data
  boundary, one audit path, and one withdrawal path.
- The outcome is a bounded admission decision, not publication or production approval.

Note:
The practical question is not whether an API exists. It is what the consumer can
cause and how the customer can stop it.

---

## Trace the call path

![S5 tool/API admission package: trace one consumer through identity, catalog/API Center, gateway or alternative route, operation boundary, audit/correlation, and withdrawal path before admitting the tool.](../assets/diagrams/s5-tool-api-governance-record-model.svg)

- Consumer agent/app/workflow.
- Caller identity and auth flow.
- Catalog/API Center record.
- APIM/gateway, connector, MCP, allow-list, or runtime-control route.
- Operation boundary, audit/correlation, consumer acceptance, withdrawal.

Note:
Use this as the room map. Every decision should land somewhere on this trace.

---

## Classify operation risk

| Operation | What changes |
|---|---|
| Read-only | Data class, audit, quota, and withdrawal still matter. |
| Write/update | Approval, rollback, idempotency, and over-scope handling matter. |
| Admin/destructive | Usually block, route to exception, or require high-authority review. |
| External side effect | Target boundary, notification, compensation, and incident route matter. |
| Bulk/export | Data owner, minimization, DLP/privacy, retention, and quota matter. |
| Dynamic tool chaining | Runtime or in-process control and stricter change triggers matter. |

Note:
If operation authority is unknown, do not proceed to product selection.

---

## Compare admission routes

| Route | Fits when |
|---|---|
| API Center/APIM | Shared or exposed API needs catalog, gateway, identity, quota, diagnostics, and lifecycle. |
| Allow-list | Narrow pilot tool with owner, version, consumer, expiry, and revocation. |
| Connector governance | Platform/SaaS connector needs permission, consent, DLP, environment, and withdrawal owner. |
| MCP publication | Server/tool schema, auth, version, rate/quota, audit, consumers, and unpublish path are reviewable. |
| Runtime-control referral | Per-call allow/deny/approval or runtime proof is needed before use. |
| Reject/block/withdraw | Authority is unsafe, owner is missing, audit is absent, or withdrawal is not executable. |

Note:
Record rejected alternatives. Otherwise the "route" is just a preference.

---

## Define the control path

Define:

- catalog/API Center entry and lifecycle state;
- APIM product/API/backend/policy route or exception;
- Entra app, managed identity, delegated/OBO path, JWT audience, scopes, consent,
  and credential owner;
- connector/MCP/allow-list record where applicable;
- rate/quota/cost/abuse controls;
- audit, diagnostics, correlation field, and retention/export expectation;
- consumer acceptance and material-change triggers;
- withdrawal path and closure owner.

Note:
No raw endpoints, live policy, secrets, payloads, telemetry exports, or customer
evidence go in this repository.

---

## APIM AI Gateway policy intent

Policy names are checklist anchors, not proof:

- `validate-jwt` for caller authentication.
- backend auth through managed identity, credential manager, or approved route.
- `rate-limit`, `quota`, and `llm-token-limit` for throttling and token budget.
- `llm-content-safety`, Prompt Shields, and blocklists for gateway safety intent.
- `llm-semantic-cache-lookup` only when data class and retention allow it.
- `llm-emit-token-metric`, diagnostics, and correlation for operating review.
- backend pool, retry, circuit breaker, overflow, and fallback for resilience.

Note:
S5 records policy intent and owner. Runtime assurance proves what actually ran.

---

## Consumer acceptance

The consuming owner accepts:

- allowed and blocked operations;
- input/output contract and over-scope handling;
- timeout, retry, idempotency, fallback, and manual route;
- audit/correlation fields;
- material-change triggers and review cadence.

Note:
The same API can be safe for one consumer and unsafe for another.

---

## Withdrawal-first design

Before admission, record how to:

- disable API/gateway route, connector, MCP tool, or allow-list entry;
- remove permission, consent, RBAC, scope, or credential;
- rotate secrets/certificates;
- notify consumers and release owners;
- preserve audit/investigation references;
- verify withdrawal and record closure or reconsideration.

Note:
If it cannot be withdrawn, it should not be admitted.

---

## Decide and hand over

Decision options:

- approve admission into the customer change process;
- defer with owner, accepted-when condition, and target event;
- reject unsafe tool;
- route to platform, identity, connector/MCP, runtime, evaluation, data/privacy,
  catalog, release, or exception owner;
- withdraw existing route;
- block until consumer, owner, scope, audit, or revocation becomes clear.

Note:
End with the decision, receiving owner, next admission or withdrawal action,
accepted-when condition, and customer-owned evidence reference. S5 changes no
tenant policy, grants no permission, configures no gateway, proves no runtime
control, and approves no production use.
