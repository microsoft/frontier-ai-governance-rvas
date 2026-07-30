# S2 · Foundry Purview Compliance decision record

Complete this in the customer's approved records system. Store only safe
references here; never paste customer evidence, prompts, outputs, telemetry,
policy exports, screenshots, endpoints, secrets, tenant identifiers, or live
configuration.

## Scope

| Field | Value |
|---|---|
| Scenario / pilot path |  |
| Non-production subscription alias |  |
| Foundry resource/app alias |  |
| Model / deployment alias |  |
| API path |  |
| Auth flow / user-context mode |  |
| Agent path, if any |  |
| Decision owner |  |
| Evidence location |  |
| Stop condition |  |

## Preflight

| Field | State | Owner / evidence reference | Notes |
|---|---|---|---|
| Dedicated non-production subscription approved | Accepted / blocked / review |  |  |
| Microsoft Purview exists in tenant | Accepted / blocked / review |  |  |
| Purview license and PAYG/billing confirmed | Accepted / blocked / review |  |  |
| Foundry Account Owner / Azure AI Account Owner assigned | Accepted / blocked / review |  |  |
| Purview Compliance Admin / Compliance Administrator assigned | Accepted / blocked / review |  |  |
| Security Reader or AI Viewer assigned for read-only review | Accepted / blocked / review |  |  |
| Content viewing role intentionally not used or approved | Accepted / blocked / review |  |  |
| Information Protection Admin available for DLP simulation | Accepted / blocked / review |  |  |
| Synthetic non-customer test approved | Accepted / blocked / review |  | Do not paste prompt or response. |

## Portal runbook evidence

| Area | Portal route / expected state | Result | Safe evidence reference / note |
|---|---|---|---|
| Foundry Purview enablement | `ai.azure.com` -> Operate -> Compliance -> Data security and governance -> subscription -> Powered by Microsoft Purview | Enabled / blocked / deferred |  |
| Alternative Azure route, if used | Defender for Cloud -> Environment settings -> subscription -> AI services -> Settings -> data security for AI interactions | Used / not used / blocked |  |
| Audit activation | Purview -> Audit | Active / blocked / review |  |
| DSPM collection | Purview -> Data Security Posture Management | Active / blocked / review |  |
| Recommendation | Secure data in Azure AI apps and agents | Enabled / deferred / blocked |  |
| Enterprise app interaction policy | Secure interactions from enterprise apps / DSPM for AI - Capture interactions for enterprise AI apps | Enabled / deferred / blocked |  |
| Custom app / KYD collection, if applicable | Custom app integration path | Approved / not applicable / blocked | Use only if customer accepts prompt/response storage. |

## Synthetic validation

| Field | Value |
|---|---|
| Test user or user alias |  |
| Test time window |  |
| Synthetic prompt reference |  |
| Expected classifier / SIT |  |
| App/resource alias |  |
| API/auth path confirmed |  |
| Prompt/response content viewed? | No / approved exception |

## Activity Explorer

| Field | Value |
|---|---|
| Portal route | Purview -> DSPM -> Activity explorer |
| Filters | AI app category = Enterprise AI apps; App = Azure AI; test user/time window |
| Event status | Found / delayed / validated no-result / unsupported / blocked |
| Event reference |  |
| Observed metadata categories | User / timestamp / app-access context / SIT metadata / file-reference metadata / other |
| Recheck owner and time, if delayed |  |
| Limitation |  |

## Audit search

| Field | Value |
|---|---|
| Portal route | Purview -> Audit |
| Search scope | Test user, time window, ConnectedAIAppInteraction / ConnectedAIApp |
| Expected identity | ConnectedAIApp.AzureAI.&lt;resource&gt; |
| Result | Found / validated no-result / delayed / blocked |
| Event reference |  |
| Retention note | Audit Standard generally retains 180 days unless tenant policy differs. |
| Limitation |  |

## DSPM reports

| Field | Value |
|---|---|
| Portal route | Purview -> Reports -> Enterprise AI apps |
| Report status | Shows interactions / 24-hour recheck / unsupported / blocked |
| Total interactions observed |  |
| Sensitive interactions observed |  |
| Recheck owner and time |  |

## Retention and eDiscovery

| Area | Route | State | Owner / evidence reference | Notes |
|---|---|---|---|---|
| Retention | Purview -> Data Lifecycle Management -> Policies -> Retention policies -> Enterprise AI apps | Verified / gap / blocked |  | Approved period:  |
| Content capture dependency | Non-Copilot generative apps require collection for prompts/responses | Accepted / N/A / gap |  |  |
| eDiscovery | Purview -> eDiscovery -> Cases -> Create case -> relevant mailbox search | Verified / gap / blocked |  |  |
| Foundry item class | `IPM.SkypeTeams.Message.ConnectedAIApp.AzureAI.<AzureResourceName>` | Verified / N/A / gap |  | Do not use deletion as validation. |

## DLP simulation boundary

| Field | Value |
|---|---|
| Portal route | Purview -> Data Loss Prevention -> Policies -> Simulate / Run policy in simulation mode |
| Simulation status | In simulation / not configured / blocked / N/A |
| Matching items or alerts observed |  |
| Activity Explorer policy mode | TestWithNotifyUser / TestWithoutNotifyUser / not observed / N/A |
| Boundary statement accepted | DLP simulation is policy tuning/observation only; it is not end-to-end Foundry prompt blocking evidence. |
| Tuning owner |  |

## Unsupported coverage and limits

| Limit | Applies? | Owner | Decision / route |
|---|---|---|---|
| Data-security policy enforcement limited to managed-inference `/chat/completions` with Entra user-context token or explicit user context | Yes / No / review |  |  |
| Other auth flows observable but not policy-enforced | Yes / No / review |  |  |
| Network isolation not supported by this Purview integration | Yes / No / review |  |  |
| Agent coverage must be verified for exact model/API/agent path | Yes / No / review |  |  |
| Custom/Entra app KYD collection stores prompts/responses only with deliberate customer approval | Yes / No / N/A |  |  |
| DLP simulation workload locations do not establish Enterprise AI apps / Foundry prompt blocking | Yes / No / review |  |  |

## Go/no-go decision

| Decision | Select one | Rationale |
|---|---|---|
| Proceed for non-production observation |  |  |
| Proceed with conditions |  |  |
| Defer |  |  |
| Route to owner |  |  |
| Reject |  |  |
| Block |  |  |

## Blockers and next technical action

| Blocker / gap | Owner | Acceptance check | Next action | Target date/event |
|---|---|---|---|---|
|  |  |  |  |  |
