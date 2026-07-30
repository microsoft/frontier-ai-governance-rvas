# S9 · Control-Plane Reconciliation & Lifecycle record

Complete this in the customer's approved records system. Store only safe
references here; never paste customer evidence, prompts, outputs, telemetry,
exports, endpoints, secrets, tenant identifiers, object IDs, or live
configuration.

## Scope

| Field | Value |
|---|---|
| Workload / agent / route under review |  |
| Environment and lifecycle boundary |  |
| Registry or portfolio safe reference |  |
| Decision owner |  |
| Evidence location |  |
| Stop condition |  |

## Source-system inspection

| Source | Route / item inspected | Expected fields | State | Safe evidence reference / note |
|---|---|---|---|---|
| Agent 365 / agent inventory | `admin.microsoft.com` -> Copilot -> Agents & connectors -> All agents, where available | Agent reference, owner, lifecycle, channel, identity reference | Matched / gap / unavailable / blocked |  |
| Entra identity | Microsoft Entra admin center -> identity/app/managed identity/service principal | Object/app/agent identity reference, sponsor, enabled state, credential/federation review | Matched / orphaned / disabled / stale / blocked |  |
| API Center | Azure portal -> API Center -> APIs/versions/environments | API reference, owner, schema/operation, lifecycle | Cataloged / uncataloged / stale / blocked |  |
| API Management / gateway | Azure portal -> API Management -> APIs/products/backends/policies | Route/backend/product, operation, owner, policy boundary | Matched / route mismatch / missing / blocked |  |
| Foundry | `ai.azure.com` -> project -> agents/apps/deployments/evaluations | Project, agent/app, deployment alias, evaluation/run, telemetry link | Matched / unmonitored / stale / blocked |  |
| Monitor / App Insights | Azure portal -> Application Insights / Log Analytics / Azure Monitor | Correlation key, query owner, retention, alert owner | Present / missing telemetry / sampled / blocked |  |
| Defender / Sentinel | Defender for Cloud posture and Sentinel incidents/watchlists/playbooks where used | Security finding/alert route, SOC owner, handoff rule | Present / missing route / unsupported / blocked |  |
| Portfolio / CMDB / change | Customer record system | Owner, lifecycle, exception, roadmap/change link | Matched / duplicate / stale / missing owner / blocked |  |

## One-workload ID reconciliation

| Join field | Registry value / safe reference | Source value / safe reference | Match state | Owner / next check |
|---|---|---|---|---|
| Registry or portfolio ID |  |  | Match / mismatch / missing |  |
| Agent 365 / agent inventory reference |  |  | Match / mismatch / unavailable |  |
| Entra object/application/agent identity reference |  |  | Match / orphaned / stale / missing |  |
| API Center API or operation reference |  |  | Match / uncataloged / stale / missing |  |
| API Management route/backend/product reference |  |  | Match / route mismatch / missing |  |
| Foundry project / deployment alias |  |  | Match / mismatch / missing |  |
| Telemetry correlation key or workspace reference |  |  | Match / missing telemetry / sampled |  |
| Security handoff reference |  |  | Match / missing route / unsupported |  |

## Expected signal classification

| Signal | Observed? | Owner | Fix / route |
|---|---|---|---|
| Matching owner across registry, identity, API/tool, Foundry, and operations | Yes / No / partial |  |  |
| Orphaned identity | Yes / No / review |  |  |
| Uncataloged API or tool | Yes / No / review |  |  |
| Unmonitored deployment or missing telemetry pointer | Yes / No / review |  |  |
| Stale lifecycle state | Yes / No / review |  |  |
| Missing telemetry query/alert/retention owner | Yes / No / review |  |  |
| Duplicate record | Yes / No / review |  |  |
| Unsupported or unavailable source-system coverage | Yes / No / review |  |  |

## Gap actions

| Gap | Source owner | Acceptance check | Next action | Target event | Recheck condition |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## Go/no-go decision

| Decision | Select one | Rationale |
|---|---|---|
| Close reconciliation |  |  |
| Close with owned gaps |  |  |
| Defer |  |  |
| Route to source owner |  |  |
| Block |  |  |
