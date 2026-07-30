# S5 · API and Tool Admission Workflow template

Complete this in the customer's approved records system. Store only safe
references here; never paste customer payloads, tokens, endpoints, resource IDs,
raw logs, policy exports, screenshots, secrets, tenant identifiers, or live
configuration.

## Scope

| Field | Value |
|---|---|
| Consumer agent/app/workflow alias |  |
| Environment |  |
| API/tool/connector/MCP alias |  |
| Operation ID / tool name |  |
| Version / schema version |  |
| Route ID |  |
| Decision owner |  |
| Evidence location |  |
| Stop condition |  |

## API Center / catalog

| Field | Value | State | Owner / safe reference |
|---|---|---|---|
| API Center or catalog entry |  | Present / stale / missing / N/A |  |
| API/tool version |  | Verified / mismatch / missing |  |
| Definition / schema source |  | Verified / mismatch / missing |  |
| Environment / deployment |  | Verified / missing / N/A |  |
| Lifecycle state | Draft / preview / active / deprecated / retired / unknown |  |  |
| Owner/contact |  | Verified / missing |  |
| Related APIM deployment |  | Linked / not linked / N/A |  |

## APIM / gateway

| Field | Value | State | Owner / safe reference |
|---|---|---|---|
| APIM/gateway alias |  | Verified / N/A / blocked |  |
| API ID |  | Verified / missing / N/A |  |
| Operation ID |  | Verified / mismatch / N/A |  |
| Product / subscription |  | Verified / missing / N/A |  |
| Backend ID / route |  | Matched / mismatch / missing / N/A |  |
| Auth policy family | JWT / subscription / managed identity / OBO / mTLS / other | Enforced / not observed / N/A |  |
| Schema/content validation | OpenAPI / JSON schema / tool schema / none | Enforced / missing / N/A |  |
| Rate/quota/token policy | Rate / quota / token / connector / MCP / none | Enforced / missing / N/A |  |
| Diagnostics/correlation |  | Verified / missing / partial |  |
| Direct-route bypass | None / found / exception-owned / unknown |  |  |

## Connector / MCP / tool contract

| Field | Value | State | Owner / safe reference |
|---|---|---|---|
| Route type | Connector / MCP / direct SDK / runtime-control / N/A |  |  |
| Contract/schema version |  | Verified / mismatch / missing / N/A |  |
| Auth scopes / permission model |  | Least privilege / broad / missing / N/A |  |
| Publication state | Published / local / draft / unknown / N/A |  |  |
| Consumer scope |  | Verified / broad / unknown / N/A |  |
| Logging route |  | Verified / missing / partial / N/A |  |
| Unpublish/disable route |  | Verified / missing / N/A |  |

## Operation allow-list

| Field | Value |
|---|---|
| Allowed operation(s) |  |
| Denied operation(s) |  |
| Required fields |  |
| Denied fields / parameters |  |
| Allowed resource aliases |  |
| Data class | Public / internal / confidential / sensitive / unknown |
| Side effect | Read-only / write / admin / destructive / external / bulk-export / none |
| Approval requirement |  |
| Over-scope behavior | Deny / require approval / route / unknown |

## Auth, schema, quota, and logging

| Area | Expected | Observed state | Owner / fix route |
|---|---|---|---|
| Token audience / issuer |  | Matched / mismatch / N/A |  |
| Scope / role / RBAC / consent |  | Least privilege / overbroad / missing / N/A |  |
| Backend auth |  | Verified / missing / unknown / N/A |  |
| Valid schema accepted |  | Pass / fail / not tested |  |
| Schema mismatch blocked |  | Pass / fail / not tested |  |
| Rate/quota/cost counter |  | Pass / fail / N/A |  |
| Logging/correlation fields |  | Pass / fail / partial |  |
| Retention owner |  | Verified / missing / N/A |  |

## Safe tests

### Allowed synthetic operation

| Field | Value |
|---|---|
| Test time window |  |
| Request/correlation/tool-call ID |  |
| Operation and schema version |  |
| Expected auth and policy |  |
| Expected backend |  |
| Result | Success / failed / not approved / trace review |
| Auth enforced | Yes / no / not observed |
| Schema accepted | Yes / no / not observed |
| Policy hit | Yes / no / not observed |
| Telemetry event | Found / delayed / missing |
| Backend side effect | Expected none / expected harmless / unexpected / unknown |

### Denied out-of-scope operation

| Field | Value |
|---|---|
| Denial type | Missing scope / blocked method / forbidden parameter / oversized payload / admin action / unapproved resource / other |
| Test time window |  |
| Request/correlation/tool-call ID |  |
| Expected response | 401 / 403 / 404 / 405 / 429 / schema failure / other |
| Result | Blocked / succeeded unexpectedly / not approved / trace review |
| No backend side effect confirmed | Yes / no / unknown |
| Policy or contract denied | Yes / no / not observed |
| Telemetry event | Found / delayed / missing |
| False-positive fix owner |  |

## Withdrawal path

| Step | Route | Owner | Verified? | Recheck condition |
|---|---|---|---|---|
| Disable APIM/API/backend/product or route |  |  | Yes / no / N/A |  |
| Remove allow-list entry |  |  | Yes / no / N/A |  |
| Revoke consent/scope/RBAC/connector permission |  |  | Yes / no / N/A |  |
| Unpublish MCP tool / suspend connector |  |  | Yes / no / N/A |  |
| Rotate credential |  |  | Yes / no / N/A |  |
| Notify consumers/release owner |  |  | Yes / no / N/A |  |
| Preserve logs/investigation references |  |  | Yes / no / N/A |  |
| Verify closed |  |  | Yes / no / N/A |  |

## Expected signals

| Signal | State | Owner / fix route | Accepted when / recheck |
|---|---|---|---|
| Registered API | Pass / fail / N/A |  |  |
| Approved operation list | Pass / fail |  |  |
| Auth enforced | Pass / fail |  |  |
| Schema mismatch blocked | Pass / fail / N/A |  |  |
| Policy hit | Pass / fail / N/A |  |  |
| Telemetry event for allowed and denied tests | Pass / fail / delayed |  |  |
| Blocked operation failed closed | Pass / fail / not tested |  |  |
| Withdrawal owner named | Pass / fail |  |  |

## Support limits

| Limit | Applies? | Owner | Route / next action |
|---|---|---|---|
| Unmanaged direct tool bypasses catalog/gateway/logging | Yes / No / review |  |  |
| Local MCP server or developer credential | Yes / No / review |  |  |
| Broad connector permission or tenant-wide consent | Yes / No / review |  |  |
| Missing API/tool/consumer/withdrawal owner | Yes / No / review |  |  |
| Non-observable call path | Yes / No / review |  |  |
| Schema drift between catalog/APIM/tool/backend | Yes / No / review |  |  |
| Dynamic tool chaining expands authority | Yes / No / review |  |  |

## Result

| Result | Select one | Rationale |
|---|---|---|
| Admit into customer change process |  |  |
| Defer |  |  |
| Reject |  |  |
| Withdraw existing route |  |  |
| Block |  |  |
| Unsupported |  |  |

## Blockers and next technical action

| Blocker / gap | Owner | Acceptance check | Next action | Target date/event |
|---|---|---|---|---|
|  |  |  |  |  |
