# S0 · Technical Intake & Feasibility Triage worksheet

Complete this in the customer's approved records system. Store only safe
references here; never paste customer evidence, prompts, outputs, telemetry,
exports, endpoints, secrets, tenant identifiers, or live configuration.

## Candidate

| Field | Value |
|---|---|
| Candidate reference |  |
| Candidate type | Foundry agent / Copilot Studio agent / M365 extension / custom Azure app / workflow / prototype / other |
| Environment | Dev / test / pre-release / production read-only / prototype / discovery-only / unknown |
| Lifecycle state | Idea / prototype / pilot / pre-release / operating / unknown |
| Sponsor |  |
| Technical owner who can inspect the system |  |
| Approved records location |  |
| Stop condition |  |

## Source-system check

| Surface | Safe reference or portal area | Status | Owner | Note |
|---|---|---|---|---|
| Azure subscription/resource group |  | Ready / blocked / unsupported / N/A / review |  |  |
| Foundry project or model/agent resource |  | Ready / blocked / unsupported / N/A / review |  |  |
| Copilot Studio or Power Platform environment |  | Ready / blocked / unsupported / N/A / review |  |  |
| M365 extension or app record |  | Ready / blocked / unsupported / N/A / review |  |  |
| Entra identity/app/service principal/managed identity |  | Ready / blocked / unsupported / N/A / review |  |  |
| API gateway, API Center, connector, MCP, or tool registry |  | Ready / blocked / unsupported / N/A / review |  |  |
| Data source, retrieval, prompt/output/log path |  | Ready / blocked / unsupported / N/A / review |  |  |
| Telemetry/security/operating signal |  | Ready / blocked / unsupported / N/A / review |  |  |
| Customer backlog/change/portfolio record |  | Ready / blocked / unsupported / N/A / review |  |  |

## Path status

| Path | Current result | First blocker if any | Next session |
|---|---|---|---|
| Identity and permissions | Ready / blocked / unsupported / N/A / review |  | S1 |
| Data and compliance | Ready / blocked / unsupported / N/A / review |  | S2 |
| Platform route | Ready / blocked / unsupported / N/A / review |  | S3 |
| Agent build path | Ready / blocked / unsupported / N/A / review |  | S4 |
| Tool/API admission | Ready / blocked / unsupported / N/A / review |  | S5 |
| Runtime security evidence | Ready / blocked / unsupported / N/A / review |  | S6 |
| Evaluation | Ready / blocked / unsupported / N/A / review |  | S7 |
| Red-team target | Ready / blocked / unsupported / N/A / review |  | S8 |
| Control-plane reconciliation | Ready / blocked / unsupported / N/A / review |  | S9 |
| Operations/cost/telemetry | Ready / blocked / unsupported / N/A / review |  | S10 |
| LLMOps change lifecycle | Ready / blocked / unsupported / N/A / review |  | S11 |
| Portfolio rollup | Ready / blocked / unsupported / N/A / review |  | S12 |

## Result

| Field | Value |
|---|---|
| Result state | Ready for technical session / blocked by access / blocked by owner / blocked by evidence handling / unsupported or wrong route / discovery-only |
| First blocker |  |
| Route to |  |
| Receiving owner |  |
| Accepted-when condition |  |
| Recheck trigger |  |
| Notes that must stay in customer records |  |

## Hard-stop review

| Hard stop | Yes/No | Owner / action |
|---|---|---|
| No owner who can open the system |  |  |
| No approved records location |  |  |
| Candidate is only an idea or portfolio theme |  |  |
| Only production target exists and no read-only review is approved |  |  |
| Evidence would need to be copied into this repository |  |  |
| Requested outcome is legal/funding/procurement/production approval |  |  |
