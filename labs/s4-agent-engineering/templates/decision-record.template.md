# S4 · Agent Build Path & Admission worksheet

Complete this in the customer's approved records system. Store only safe
references here; never paste customer code, prompts, outputs, telemetry,
exports, endpoints, secrets, tenant identifiers, or live configuration.

## Candidate

| Field | Value |
|---|---|
| Candidate reference |  |
| Environment | Dev / test / pre-release / prototype / production-readiness review / unknown |
| Lifecycle state | Idea / prototype / DEV / PRE / PRO-readiness / operating / retired / unknown |
| Product owner |  |
| Engineering owner |  |
| Service/support owner |  |
| Release/change owner |  |
| Approved records location |  |
| Stop condition |  |

## Authority and action boundary

| Field | Value |
|---|---|
| Authority class | Inform / draft / recommend / act-with-approval / autonomous / coordinating / blocked |
| Allowed actions |  |
| Prohibited actions |  |
| Human-control point |  |
| Exception route |  |
| Fallback behavior |  |
| Rollback owner |  |

## Build-path comparison

| Path | Fit | Rejected/deferred reason | Owner |
|---|---|---|---|
| Foundry Agent Service | Fits / rejected / deferred / unsupported |  |  |
| Copilot Studio | Fits / rejected / deferred / unsupported |  |  |
| Microsoft 365 Copilot extensibility | Fits / rejected / deferred / unsupported |  |  |
| Custom Azure app | Fits / rejected / deferred / unsupported |  |  |
| Workflow automation | Fits / rejected / deferred / unsupported |  |  |
| Prototype-only | Fits / rejected / deferred / unsupported |  |  |

## Selected route inspection

| Field | Safe reference / value | Status | Owner / note |
|---|---|---|---|
| Selected path |  | Accepted / blocked / unsupported / N/A / review |  |
| Product surface inspected |  | Accepted / blocked / unsupported / N/A / review |  |
| Instruction, workflow, hosted code, or manifest reference |  | Accepted / blocked / unsupported / N/A / review |  |
| Model deployment or backend route |  | Accepted / blocked / unsupported / N/A / review |  |
| Tool/API/action/connector list |  | Accepted / blocked / unsupported / N/A / review |  |
| Data, retrieval, or knowledge source boundary |  | Accepted / blocked / unsupported / N/A / review |  |
| Identity and authorization mode |  | Accepted / blocked / unsupported / N/A / review |  |
| Runtime controls and denial behavior |  | Accepted / blocked / unsupported / N/A / review |  |
| Telemetry or trace hook |  | Accepted / blocked / unsupported / N/A / review |  |
| Evaluation hook |  | Accepted / blocked / unsupported / N/A / review |  |
| Release/rollback route |  | Accepted / blocked / unsupported / N/A / review |  |

## Safe boundary check

| Field | Value |
|---|---|
| Check type | Synthetic prompt/action / connector inspection / trace review / run-history review / not possible |
| Tool/data/action boundary checked |  |
| Result | Boundary verified / diagnostic-only / blocked / unsupported / not run |
| Expected signal |  |
| Actual signal reference |  |
| Gap owner |  |
| Recheck trigger |  |

## Gate and result

| Field | Value |
|---|---|
| DEV accepted-when condition |  |
| PRE accepted-when condition |  |
| PRO handoff condition |  |
| Material-change trigger |  |
| Result state | Buildable route / buildable with backlog / wrong path / unsupported route / unsafe authority / prototype-only / blocked |
| Backlog item or blocker |  |
| Receiving owner |  |
| Next action |  |
