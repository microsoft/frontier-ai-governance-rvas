# S3 · Platform Plumbing Verification template

Complete this in the customer's approved records system. Store only safe
references here; never paste endpoints, resource IDs, raw telemetry, screenshots,
secrets, tenant identifiers, customer prompts, outputs, or live configuration.

## Scope

| Field | Value |
|---|---|
| Route name / alias |  |
| Environment |  |
| Caller / app / orchestrator alias |  |
| Model / tool / API backend alias |  |
| Route ID |  |
| Safe portal references |  |
| Trace/request ID |  |
| Time window |  |
| Decision owner |  |
| Evidence location |  |
| Stop condition |  |

## Foundry and model deployment

| Field | Value | State | Owner / safe reference |
|---|---|---|---|
| Foundry project / Azure AI resource alias |  | Verified / blocked / N/A / review |  |
| Region and support status |  | Supported / unsupported / review |  |
| Model deployment alias |  | Verified / missing / N/A |  |
| Model/version or deployment family |  | Verified / unknown / N/A |  |
| Network mode | Public / private / managed VNet / BYO VNet / unknown |  |  |
| Identity setting | Managed identity / app registration / key / unknown / N/A |  |  |
| Diagnostic settings | Enabled / missing / partial / blocked |  |  |
| Quota/capacity owner |  | Verified / missing / review |  |

## APIM / gateway route

| Field | Value | State | Owner / safe reference |
|---|---|---|---|
| Gateway / APIM instance alias |  | Verified / N/A / blocked |  |
| API ID |  | Verified / missing / N/A |  |
| Operation ID |  | Verified / missing / N/A |  |
| Product / subscription |  | Verified / missing / N/A |  |
| Backend ID / route alias |  | Matched / mismatch / missing / N/A |  |
| Expected policy family | Auth / rate-quota / token / diagnostics / safety / retry / other | Applied / not observed / N/A |  |
| Correlation field |  | Verified / missing / review |  |
| Direct-route bypass | None / found / exception-owned / unknown |  |  |

## Private endpoint and DNS

| Field | Value | State | Owner / safe reference |
|---|---|---|---|
| Private route required? | Yes / No / review |  |  |
| Public-network access setting | Disabled / enabled / exception / unknown |  |  |
| Private endpoint |  | Verified / missing / N/A |  |
| Private DNS zone |  | Verified / missing / N/A |  |
| VNet link / resolver path |  | Verified / missing / N/A |  |
| NSG/firewall/route table |  | Verified / missing / N/A |  |
| Flow/DNS/resource log evidence |  | Private / public / no telemetry / N/A |  |

## API Center / catalog

| Field | Value |
|---|---|
| API Center or catalog route |  |
| API/tool/model entry |  |
| Version |  |
| Deployment/environment |  |
| Lifecycle state | Draft / preview / active / deprecated / retired / unknown |
| Owner/contact |  |
| Exception or deprecation route |  |
| Catalog result | Present / stale / missing / N/A |

## Telemetry query

| Field | Value |
|---|---|
| Application Insights alias |  |
| Log Analytics workspace alias |  |
| Query owner |  |
| Query reference |  |
| Tables checked | AppRequests / AppDependencies / AppTraces / AzureDiagnostics / resource-specific / other |
| Trace/request/correlation ID |  |
| Gateway event | Found / delayed / missing / N/A |
| App request event | Found / delayed / missing / N/A |
| Backend/model/tool event | Found / delayed / missing / N/A |
| Sampling or ingestion limitation |  |
| Retention owner |  |

## Defender, Sentinel, and cost/quota

| Area | Route checked | Result | Owner | Recheck condition |
|---|---|---|---|---|
| Defender for Cloud | Recommendations / alerts | Covered / unsupported / not used / review |  |  |
| Sentinel | Logs / Analytics / Incidents | Handoff verified / unsupported / not used / review |  |  |
| Model quota / PTU / capacity | Quota blade / deployment capacity | Owner found / missing / review |  |  |
| APIM product quota | Product/subscription/policy | Owner found / missing / N/A |  |  |
| Cost allocation | Cost Management tags/budget | Owner found / missing / review |  |  |

## Expected signals

| Signal | State | Owner / fix route | Accepted when / recheck |
|---|---|---|---|
| Gateway policy applied | Pass / fail / N/A |  |  |
| Backend route matched | Pass / fail / review |  |  |
| Identity propagated | Pass / fail / review |  |  |
| Private route used when required | Pass / fail / N/A |  |  |
| Public route exception owned | Pass / fail / N/A |  |  |
| Telemetry emitted | Pass / fail / delayed |  |  |
| Catalog present and current | Pass / fail / N/A |  |  |
| Unsupported bypass found | Found / not found / review |  |  |

## Result

| Result | Select one | Rationale |
|---|---|---|
| Verified for this route |  |  |
| Partial; recheck needed |  |  |
| Bypass found |  |  |
| Public path found |  |  |
| No telemetry |  |  |
| Catalog gap |  |  |
| Unsupported |  |  |
| Block |  |  |

## Blockers and next technical action

| Blocker / gap | Owner | Acceptance check | Next action | Target date/event |
|---|---|---|---|---|
|  |  |  |  |  |
