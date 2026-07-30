# S7 · Foundry Evaluation run record

Complete this in the customer's approved records system. Store only safe
references here; never paste customer evidence, prompts, outputs, telemetry
exports, endpoints, secrets, tenant identifiers, or live configuration.

## Scope

| Field | Value |
|---|---|
| Foundry project alias / endpoint reference |  |
| Candidate change |  |
| Environment | Dev / test / pre-release / other |
| Candidate owner |  |
| Evaluation owner |  |
| Threshold owner |  |
| Release/hold owner |  |
| Evidence location |  |
| Stop condition |  |

## Preflight

| Check | State | Owner / evidence reference | Notes |
|---|---|---|---|
| Foundry project and role verified | Accepted / blocked / review |  |  |
| Candidate version named | Accepted / blocked / review |  |  |
| Dataset/scenario version approved | Accepted / blocked / review |  |  |
| Evaluator/rubric support checked | Accepted / blocked / unsupported / review |  |  |
| Baseline available or routed | Available / missing / exception / blocked |  |  |
| Threshold file or threshold rule approved | Accepted / blocked / review |  |  |
| Runtime prerequisite accepted or diagnostic-only | Accepted / diagnostic-only / blocked |  |  |
| Safe evidence handling approved | Accepted / blocked / review |  |  |

## Foundry evaluation run

| Field | Value |
|---|---|
| Portal route | `ai.azure.com` -> project -> Build -> Evaluations |
| Evaluation ID |  |
| Run ID |  |
| Run status | Succeeded / failed / canceled / blocked |
| Dataset/scenario version |  |
| Evaluator/rubric name and version |  |
| Column mappings checked | Query / response / context / ground truth / custom / N/A |
| Baseline reference |  |
| Candidate reference |  |
| Baseline result |  |
| Candidate result |  |
| Failed slices / diagnostics |  |
| Safe result link/reference |  |

## Threshold review

| Field | Value |
|---|---|
| Threshold file/version or rule |  |
| Metrics checked | Groundedness / relevance / task adherence / tool use / safety / protected material / custom / performance / other |
| Threshold owner |  |
| Result | Passed / failed / not comparable / diagnostic-only / blocked |
| Baseline missing state | N/A / missing / exception approved / hold |
| Hold state | Continue / hold / defer / reject / route / block / diagnostic-only |
| Exception state | None / requested / approved / rejected / expired |
| Exception owner and expiry |  |

## CI/CD branch, if used

| Field | Value |
|---|---|
| Pipeline system and run ID |  |
| Pipeline identity / service connection |  |
| Task | `AIAgentEvaluation@2` / SDK script / other |
| Project endpoint input |  |
| Deployment-name input |  |
| Data-path input |  |
| Agent IDs / baseline agent ID |  |
| Threshold file/version |  |
| Failure behavior | Fail PR / fail release / warn / require human review / hold |
| Pipeline artifact storage |  |
| Manual override owner / expiry |  |

## Load/performance branch, if used

| Field | Value |
|---|---|
| Tool and run ID | Azure Load Testing / approved tool / telemetry-only |
| Request mix |  |
| Concurrency/ramp/duration |  |
| Quota/cost boundary |  |
| Telemetry correlation | Foundry traces / Application Insights / Azure Monitor / gateway / dependency / other |
| Latency result |  |
| Error/throttle/saturation result |  |
| Cost/budget result |  |
| Performance verdict | Pass / fail / diagnostic-only / blocked |

## Retest and release action

| Field | Value |
|---|---|
| Final action | Continue / hold / defer / reject / route / block / diagnostic-only / retest |
| Retest trigger |  |
| Fix or route owner |  |
| Acceptance check |  |
| Target date/event |  |

## Blockers and next technical action

| Blocker / gap | Owner | Acceptance check | Next action | Target date/event |
|---|---|---|---|---|
|  |  |  |  |  |
