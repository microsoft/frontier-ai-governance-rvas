# S11 · LLMOps Change Control record

Complete this in the customer's approved records system. Store only safe
references here; never paste customer evidence, prompts, outputs, datasets,
telemetry, exports, endpoints, secrets, tenant identifiers, object IDs, or live
configuration.

## Scope

| Field | Value |
|---|---|
| Workload / Foundry project under review |  |
| Baseline release reference |  |
| Candidate release reference |  |
| Environment |  |
| Target customer process | Separate change review / release review / backlog / experiment queue / evaluation queue |
| Decision owner |  |
| Evidence location |  |
| Stop condition | No production traffic movement during this lab. |

## Foundry inspection

| Item | Route / item inspected | Baseline reference | Candidate reference | State | Owner / note |
|---|---|---|---|---|---|
| Project asset | `ai.azure.com` -> project -> assets/apps/agents |  |  | Matched / missing / blocked |  |
| Prompt / instruction version | Foundry prompt flow / agent instruction / source repo reference |  |  | Matched / changed / unversioned / blocked |  |
| Model deployment / alias | Foundry deployments / Azure OpenAI deployments |  |  | Matched / alias mismatch / missing |  |
| Dataset / scenario | Foundry data/evaluation asset or customer scenario store |  |  | Matched / missing / unsupported |  |
| Evaluation run | Foundry evaluations / pipeline evaluation output |  |  | Passed / failed / missing / diagnostic-only |  |
| Monitoring signal | Foundry observability / App Insights / Log Analytics reference |  |  | Ready / missing / sampled / blocked |  |

## Pipeline and release inspection

| Item | Expected check | State | Safe evidence reference / note |
|---|---|---|---|
| Release manifest | Prompt/instruction, retrieval, tool schema, model alias, dataset/scenario, evaluation, runtime control, monitoring, rollout, rollback, fallback, approver | Complete / incomplete / stale / blocked |  |
| Pipeline run | Build/test/evaluation gates, environment, skipped/failed steps, manual approvals, generated manifest | Passed / failed / skipped / blocked |  |
| Rollout stage | DEV / PRE / limited preview / expanded preview / production-change readiness | Ready / hold / unsupported / blocked |  |
| Stop condition | Quality/safety/error/latency/cost/capacity/owner trigger | Ready / missing / blocked |  |
| Rollback target | Prior release, alias, route, prompt/retrieval bundle, tool schema, model deployment, or manual hold | Ready / missing / stale / blocked |  |
| Fallback route | Target alias/route, trigger, compatibility, capacity owner, recovery owner | Ready / missing / unsupported / blocked |  |
| Feedback source | Approved source, privacy/retention route, curation owner, mutation gate | Approved / not approved / blocked |  |
| Automation readiness | Regression, canary, alias switching, fallback routing, feedback curation, retirement | Ready / manual only / not ready / blocked |  |

## Baseline versus candidate comparison

| Check | Result | Owner | Fix / route |
|---|---|---|---|
| Manifest complete | Yes / No / review |  |  |
| Evaluation missing or diagnostic-only | Yes / No / review |  |  |
| Alias mismatch | Yes / No / review |  |  |
| Rollback target missing | Yes / No / review |  |  |
| Fallback route missing or untested | Yes / No / review |  |  |
| Feedback source not approved | Yes / No / review |  |  |
| Automation not ready | Yes / No / review |  |  |
| Monitoring signal cannot inform stop/fallback/rollback | Yes / No / review |  |  |
| Ready for separate change review | Yes / No / with conditions |  |  |

## Gap actions

| Gap | Owner | Acceptance check | Next action | Target event | Recheck condition |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## Go/no-go decision

| Decision | Select one | Rationale |
|---|---|---|
| Ready for separate change review |  |  |
| Ready with owned gaps |  |  |
| Defer |  |  |
| Route to owner |  |  |
| Reject |  |  |
| Block |  |  |
