# S6 · Runtime Path Evidence & Response worksheet

Complete this in the customer's approved records system. Store only safe
references here; never paste customer evidence, prompts, outputs, telemetry
rows, policies, exports, endpoints, secrets, tenant identifiers, or live
configuration.

## Scope

| Field | Value |
|---|---|
| Scenario / request |  |
| Environment |  |
| Request/run reference |  |
| Decision owner / reviewer |  |
| Evidence location |  |
| Stop condition |  |

## Runtime path

| Field | Value | Status | Owner / note |
|---|---|---|---|
| Caller identity |  | Accepted / blocked / unsupported / N/A / review |  |
| App/workload identity |  | Accepted / blocked / unsupported / N/A / review |  |
| Gateway or app-only route |  | Accepted / blocked / unsupported / N/A / review |  |
| Backend model/agent/service |  | Accepted / blocked / unsupported / N/A / review |  |
| Tool/API route |  | Accepted / blocked / unsupported / N/A / review |  |
| Response path |  | Accepted / blocked / unsupported / N/A / review |  |
| Policy decision point |  | Accepted / blocked / unsupported / N/A / review |  |

## Telemetry check

| Field | Value |
|---|---|
| Correlation field |  |
| Correlation value |  |
| Expected propagation points |  |
| Telemetry source/table/workbook |  |
| Query owner |  |
| Time window checked |  |
| Expected signal |  |
| Query/run reference |  |
| Actual signal state | Signal present / no signal / partial signal / diagnostic-only / alert routed / unsupported route / blocked evidence handling |
| Policy decision observed | Block / allow / annotate / log / throttle / fallback / no decision observed / N/A |
| Blind spot or limitation |  |

## SOC, retention, and response

| Field | Value | Status | Owner / note |
|---|---|---|---|
| Defender/Sentinel/SOC route |  | Accepted / blocked / unsupported / N/A / review |  |
| Alert, incident, queue, workbook, or manual review path |  | Accepted / blocked / unsupported / N/A / review |  |
| Severity owner |  | Accepted / blocked / unsupported / N/A / review |  |
| Retention/export/deletion owner |  | Accepted / blocked / unsupported / N/A / review |  |
| Recheck trigger |  | Accepted / blocked / unsupported / N/A / review |  |

## Decision

| Field | Value |
|---|---|
| Reviewer decision | Accept / defer / route / reject / block / diagnostic-only |
| Accepted claim, if any |  |
| Unsupported or missing claim |  |
| Gap owner |  |
| Next runtime-control action |  |
| Accepted-when condition |  |
