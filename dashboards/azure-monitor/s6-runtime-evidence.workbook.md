# S6 runtime evidence workbook guidance

Use this guide to create a customer-owned Azure Monitor workbook for the S6
prompt-firewall package. The workbook should show aggregate state and safe
references only. Do not paste raw prompts, outputs, endpoint URLs, tenant IDs,
or telemetry exports into this repository.

## Workbook sections

| Section | Query source | Reviewer question |
|---|---|---|
| Scope and run reference | Manual parameters | Which non-production route, time window, and correlation value are being reviewed? |
| Runtime path trace | `requests`, `traces`, `dependencies`, `customEvents` | Can the request be traced through gateway, app, backend/model, and tool/API records? |
| Gateway policy decision | `AzureDiagnostics` and APIM diagnostics | Did the prompt-firewall policy produce allow, block, annotate, or diagnostic-only state? |
| Backend and dependency join | App telemetry and dependency tables | Did the backend or model/tool route receive the correlated request as expected? |
| SOC or security route | `SecurityAlert`, Sentinel incidents, Defender, or customer SIEM | Did actionable signal reach the queue, alert, incident, workbook, or manual review owner? |
| Signal-state decision | Manual reviewer field | Is the result signal present, no signal, partial, diagnostic-only, alert routed, unsupported, or blocked? |

## Suggested workbook parameters

| Parameter | Example | Notes |
|---|---|---|
| `correlationId` | Customer-supplied value | Store only in customer workbook or evidence record. |
| `timeRange` | Last 2 hours | Match the approved test window. |
| `routeReference` | APIM API/operation alias | Use safe alias, not exported configuration. |
| `expectedDecision` | allow / block / annotate / log / throttle / fallback | Set before running the query. |
| `reviewer` | Customer reviewer reference | Do not store personal data in this repo. |

## Workbook acceptance checks

- The workbook can filter by a single correlation value.
- The query owner can explain the tables, fields, and blind spots.
- The policy decision is visible or the absence is routed to an owner.
- The SOC/manual response route is visible or marked as a gap.
- The final signal state is recorded in the customer decision record.

## Evidence boundary

The workbook is customer-owned. Retain workbook links, query references,
aggregate states, reviewer decisions, and recheck triggers in customer systems.
Do not copy raw telemetry rows, screenshots, prompt text, model output, endpoint
URLs, or incident payloads into this repository.
