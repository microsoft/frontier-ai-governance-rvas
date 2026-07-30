# S1 · Identity Path Trace template

Complete this in the customer's approved records system. Store only safe
references here; never paste raw tokens, decoded claim payloads, tenant IDs,
object IDs, endpoints, secrets, screenshots, customer data, or live
configuration.

## Scope

| Field | Value |
|---|---|
| App / agent alias |  |
| Synthetic or non-production request |  |
| Tool/API operation |  |
| Environment |  |
| Time window |  |
| Safe correlation handle |  |
| Decision owner |  |
| Evidence location |  |
| Stop condition |  |

## Portal and CLI inspection

| Area | Route / command family | Result | Owner / safe reference | Notes |
|---|---|---|---|---|
| App registration | Entra -> Identity -> Applications -> App registrations -> app | Opened / blocked / N/A |  | Overview, Owners, Authentication |
| Credentials | App registrations -> Certificates & secrets | No secret / managed / unmanaged / blocked |  | Do not paste values. |
| Federated credential | App registrations -> Federated credentials / `az ad app federated-credential list` | Verified / broad / missing / N/A |  | Issuer, subject, audience checked. |
| API permissions requested | App registrations -> API permissions / Graph app read | Least privilege / overbroad / missing / review |  | Requested permissions only. |
| Exposed API/app roles | App registrations -> Expose an API / App roles | Verified / missing / N/A |  | Scope or role names only. |
| Enterprise app | Entra -> Enterprise applications -> service principal | Opened / blocked / N/A |  | Account enabled and owners. |
| Granted consent | Enterprise app -> Permissions / Graph grants | Granted / missing / overbroad / N/A |  | Delegated grant or app role assignment. |
| Managed identity | Azure resource -> Identity or Managed identities / `az identity show` | Verified / mismatch / N/A |  | Principal/client checked. |
| Azure RBAC | Target scope -> IAM -> Role assignments / `az role assignment list` | Least privilege / overbroad / missing / N/A |  | Scope and role only. |
| Agent ID / Agent 365 | Entra Agent ID / Agent 365 surface where supported | Verified / unsupported / N/A |  | If unsupported, fill fallback. |
| Conditional Access | Entra -> Protection -> Conditional Access and Sign-in logs | Allowed / blocked / not applied / review |  | Sign-in reference only. |

## Runtime mode

| Field | Value |
|---|---|
| Mode | App-only / delegated / OBO / mixed / unknown |
| User or trigger |  |
| Host workload identity |  |
| Agent identity or fallback |  |
| Downstream API/resource |  |
| Disable first object/route |  |

## Token and claim checks

| Check | Expected | Observed state | Owner / fix route |
|---|---|---|---|
| Token audience `aud` | Target API/gateway | Match / mismatch / not checked |  |
| Delegated scope `scp` | Required for delegated/OBO | Present / absent / N/A |  |
| App role `roles` | Required for app-only/app role | Present / absent / N/A |  |
| Actor `oid` / `sub` | User or service principal explainable in logs | Matched / ambiguous / missing |  |
| Client `appid` / `azp` | Expected client app | Matched / unexpected / missing |  |
| User context | Present for OBO, absent for app-only | Present / absent / ambiguous |  |
| Managed identity indicator | Matches host when used | Matched / mismatch / N/A |  |
| Sign-in correlation | Joinable to request time window | Found / delayed / missing / blocked |  |

## Permission result

| Permission surface | Expected boundary | Result | Owner | Recheck condition |
|---|---|---|---|---|
| Graph/API delegated scope |  | Verified / missing consent / overbroad / N/A |  |  |
| Graph/API application role |  | Verified / missing consent / overbroad / N/A |  |  |
| Azure RBAC |  | Verified / missing / overbroad / N/A |  |  |
| APIM/gateway product or JWT policy |  | Verified / bypass / missing / N/A |  |  |
| Connector or tool permission |  | Verified / unsupported / overbroad / N/A |  |  |
| Backend ACL/data permission |  | Verified / missing / overbroad / N/A |  |  |

## Expected signals and fixes

| Signal | State | Fix route | Owner | Accepted when / recheck |
|---|---|---|---|---|
| Correct token audience | Pass / fail / N/A |  |  |  |
| User context present for OBO | Pass / fail / N/A |  |  |  |
| User context absent for app-only | Pass / fail / N/A |  |  |  |
| Overbroad permission | Found / not found / review |  |  |  |
| Missing consent | Found / not found / review |  |  |  |
| Unmanaged secret | Found / not found / review |  |  |  |
| Blocked Conditional Access path | Found / not found / review |  |  |  |
| Unsupported OBO/tool path | Found / not found / review |  |  |  |
| Agent ID unsupported; custom-app fallback used | Yes / no / N/A |  |  |  |
| Logs cannot distinguish user/app/agent/backend | Found / not found / review |  |  |  |

## Go/no-go result

| Result | Select one | Rationale |
|---|---|---|
| Verified for this non-production route |  |  |
| Proceed with fixes tracked |  |  |
| Defer |  |  |
| Route to owner |  |  |
| Reject for production reliance |  |  |
| Block |  |  |

## Blockers and next technical action

| Blocker / gap | Owner | Acceptance check | Next action | Target date/event |
|---|---|---|---|---|
|  |  |  |  |  |
