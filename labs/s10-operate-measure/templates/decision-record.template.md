# S10 · Operating Evidence & FinOps record

Complete this in the customer's approved records system. Store only safe
references here; never paste customer evidence, prompts, outputs, telemetry,
exports, endpoints, secrets, tenant identifiers, object IDs, or live
configuration.

## Scope

| Field | Value |
|---|---|
| Workload / route under review |  |
| Environment |  |
| Review period and time zone |  |
| Included population |  |
| Excluded paths |  |
| Decision owner |  |
| Evidence location |  |
| Stop condition |  |

## Source-system inspection

| Source | Route / item inspected | Expected check | State | Safe evidence reference / note |
|---|---|---|---|---|
| Application Insights | Azure portal -> Application Insights -> transaction search / failures / performance | Requests, dependencies, failures, sampling, `operation_Id` | Present / sampled / missing / blocked |  |
| Log Analytics | Azure portal -> Log Analytics workspace -> Logs | KQL query references for latency, errors, routes, tokens/cost proxy, dependencies, safety/security | Present / missing / unsupported / blocked |  |
| Azure Monitor alerts | Azure Monitor -> Alerts -> Alert rules / Action groups | Rule state, severity, owner, action group, suppression, validation | Ready / needs tuning / missing owner / blocked |  |
| Azure Monitor workbooks | Azure Monitor -> Workbooks or customer workbook | Population, filters, time window, owner, interpretation limits | Ready / stale / missing / blocked |  |
| Cost Management exports | Azure portal -> Cost Management -> Exports / Cost analysis / Budgets | Export schedule, tags/dimensions, allocation owner, budget/anomaly route | Ready / allocation gap / missing / blocked |  |
| Quota / capacity | Azure OpenAI/Foundry/service quota and deployment capacity views | Quota owner, PTU/commitment, saturation, throttling, fallback | Normal / pressure / throttled / blocked |  |
| Defender / Sentinel | Defender for Cloud and Microsoft Sentinel incidents/playbooks where used | Security signal, SOC owner, incident or no-result scope | Ready / missing route / unsupported / blocked |  |
| Operating review | Customer operating forum or ticket/change record | Action owner, decision, recurrence, validation reference | Adopted / routed / deferred / blocked |  |

## KQL/query placeholders used

| Query | Customer query reference | Aggregate state | Owner / limitation |
|---|---|---|---|
| Latency p50/p95/p99 |  | Normal / investigate / missing |  |
| Errors and failures |  | Normal / investigate / missing |  |
| Model/tool route |  | Expected / unexpected route / missing |  |
| Token or cost proxy |  | Normal / anomaly / unavailable |  |
| Dependency failures |  | Normal / investigate / missing |  |
| Safety/security signals |  | No alert / alert / unsupported |  |

## Correlation and expected states

| Field | Value |
|---|---|
| Join method | operation_Id / traceparent / gateway request ID / run ID / tool call ID / time-window join |
| Propagation points |  |
| Break points |  |
| Retention and sampling limits |  |
| Expected operating state | Normal / investigate / missing telemetry / sampled / delayed / unsupported / blocked |
| Expected FinOps state | Allocated / shared-cost review / anomaly / missing export / blocked |
| Expected security handoff | Ready / route missing / alert active / unsupported / blocked |

## Actions

| Gap or action | Owner | Acceptance check | Next action | Target event | Recurrence / recheck |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## Go/no-go decision

| Decision | Select one | Rationale |
|---|---|---|
| Adopt operating review |  |  |
| Adopt with owned gaps |  |  |
| Defer |  |  |
| Route to owner |  |  |
| Block |  |  |
