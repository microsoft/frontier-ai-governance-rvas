# S7 · Evaluation Evidence & Release Readiness: Technical runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Foundry evaluators, cloud evaluations, agent evaluation tasks, Application Insights trace evaluation, and Azure Load Testing vary by region, project type, quota, pricing, SDK version, and preview status. Verify support before delivery.

## Microsoft default

Default to Microsoft Foundry cloud evaluation for the named non-production
candidate, Azure DevOps `AIAgentEvaluation@2` when the release pipeline can use
the result, and Azure Load Testing or an approved performance tool when
throughput, quota, latency, saturation, or cost can affect release readiness.

![S7 illustrative assurance pattern: runtime-path acceptance precedes scenario-set evaluation, evaluator or rubric selection, baseline comparison, threshold interpretation, finding action, and continue or hold handoff. Diagnostic-only evidence stays separate.](../assets/diagrams/s7-evaluation-release-handoff.svg)

## 1. Preflight

| Check | Required before run | Blocker if missing |
|---|---|---|
| Foundry project | Project endpoint from `ai.azure.com` -> project **Overview**; non-production or approved pre-release scope. | Do not run against an unapproved project. |
| Role | **Foundry User** or the customer-approved equivalent for the project; pipeline identity/service connection for CI/CD. | Cannot create/run evaluations or pipeline task. |
| Candidate | Model/deployment, agent ID/version, prompt, tool/API, retrieval source, policy, or release package is named. | No scoped evaluation. |
| Dataset/scenario | Dataset name/version, JSONL/CSV file reference, response/trace IDs, scenario simulation source, or approved manual scenario set. | Result cannot be interpreted. |
| Evaluator fit | Evaluator catalog entry, version, required inputs, mappings, region/project support, and preview status checked. | Use alternate evaluator/manual review or hold. |
| Baseline | Prior accepted run, baseline agent ID, pre-change run, gold scenario result, or accepted comparison rule. | Mark baseline missing; diagnostic-only unless threshold owner accepts an alternate rule. |
| Threshold owner | Customer owner for metric thresholds and threshold-file changes. | Do not fail/pass release automatically. |
| Evidence handling | Customer records system, pipeline artifact storage, retention owner, and raw prompt/output boundary. | Do not run if evidence cannot be handled safely. |
| Runtime prerequisite | Accepted runtime-path reference if the result will influence release. | Missing prerequisite means diagnostic-only. |

## 2. Foundry portal run

Use this path for an interactive customer run.

1. Open `ai.azure.com`.
2. Select the account, hub/project, and pre-release environment.
3. Open **Build** -> **Evaluations**.
4. Open **Evaluator catalog** and select evaluators that match the release
   question: quality/relevance, groundedness, retrieval/context, safety,
   task adherence, tool use, protected material, custom rubric, or regression.
5. Open **Datasets**. Upload a JSONL/CSV dataset or select an existing dataset
   version. If using traces or Foundry response IDs, confirm Application
   Insights/Foundry source support and sampling scope.
6. Create the evaluation. Configure:
   - data source type: JSONL, CSV, Foundry responses, traces, target
     completions, synthetic data, or scenario simulation when supported;
   - evaluator names and versions;
   - column mappings such as query, response, context, ground truth, and
     evaluator-specific fields;
   - target model deployment or agent ID/version;
   - baseline and candidate references when comparison is supported.
7. Run the evaluation.
8. Wait for status **Succeeded**, **Failed**, or **Canceled**.
9. Open the run result. Check metric summary, failed slices, evaluator
   diagnostics, baseline/candidate comparison, and confidence or statistical
   comparison where available.
10. Export or copy only safe references: project alias, evaluation ID, run ID,
    dataset/scenario version, evaluator/rubric version, baseline/candidate IDs,
    metric summary, threshold verdict, and result link.

Do not copy prompts, responses, full trace payloads, endpoint values, tenant IDs,
secrets, or raw telemetry into this repository.

## 3. Foundry SDK run

Use this path when the customer operates evaluations through code or a controlled
automation script.

Setup:

```bash
pip install "azure-ai-projects>=2.2.0"
az login
```

Minimum run shape:

1. Set `AZURE_AI_PROJECT_ENDPOINT` to the project endpoint copied from Foundry
   project **Overview**.
2. Use `AIProjectClient(endpoint=..., credential=DefaultAzureCredential())`.
3. Upload or reference the dataset:
   `project_client.datasets.upload_file(name=..., version=..., file_path=...)`.
4. Define evaluator testing criteria with exact evaluator names and
   `data_mapping` for the dataset columns.
5. Create the evaluation with `openai_client.evals.create(...)`.
6. Start the run with `openai_client.evals.runs.create(...)`.
7. Poll run status, retrieve result summary, and store the run ID plus safe
   result link in the customer record.

Accepted when:

- run status is **Succeeded**;
- evaluator diagnostics do not show unsupported or missing mappings;
- dataset/scenario version matches the release candidate;
- baseline/candidate comparison is present or the missing baseline is explicitly
  routed;
- threshold verdict and owner are recorded.

## 4. Azure DevOps CI/CD branch

Use CI/CD only when the customer release process can consume automated
evaluation results.

Required pieces:

| Piece | Configuration to verify |
|---|---|
| Pipeline identity | Azure Resource Manager service connection, workload identity federation, or managed identity. Prefer secretless Entra ID. |
| Task | `AIAgentEvaluation@2` from the Microsoft Foundry AI Agent Evaluation extension. |
| Project endpoint | `azure-ai-project-endpoint` copied from Foundry project **Overview**. |
| Deployment | `deployment-name` copied from **Models + endpoints**. |
| Data | `data-path` to a versioned JSON file with `name`, `evaluators`, and `data` entries. |
| Agents | `agent-ids` in `agent-name:version` format; comma-separated for comparison. |
| Baseline | `baseline-agent-id` when a specific baseline should be used. |
| Thresholds | Versioned threshold file or evaluator parameters, with owner and change route. |
| Failure behavior | Fail PR, fail release stage, warn only, require human review, or hold deployment. |
| Storage | Pipeline summary/report, threshold file version, run ID, baseline/candidate IDs, and safe result link retained in customer systems. |

Example task shape:

```yaml
steps:
  - task: AIAgentEvaluation@2
    displayName: "Evaluate Foundry agent candidate"
    inputs:
      azure-ai-project-endpoint: "$(AzureAIProjectEndpoint)"
      deployment-name: "$(DeploymentName)"
      data-path: "$(System.DefaultWorkingDirectory)/evaluation/dataset.json"
      agent-ids: "$(CandidateAgentId)"
      baseline-agent-id: "$(BaselineAgentId)"
```

Add a customer-owned threshold check after the task if the task/report does not
directly fail on the required thresholds. The check must read the approved
threshold file, fail the job on required metric regression, and write a short
summary to the pipeline report. Manual override requires owner, expiry, reason,
ticket/change reference, and retest trigger.

## 5. Load and performance branch

Use Azure Load Testing or a customer-approved tool when release risk includes
latency, throughput, quota, saturation, reliability, or cost.

| Field | Required configuration |
|---|---|
| Tool | Azure Load Testing resource, k6/JMeter/approved runner, or telemetry-only exception. |
| Target | Non-production endpoint/agent/app route, auth path, deployment alias, and reset/rollback owner. |
| Request mix | User journeys, prompt class labels, retrieval/tool usage, streaming mode, cache state, error/timeout cases, and excluded routes. |
| Concurrency | Arrival rate, virtual users, ramp, duration, burst, retry behavior, and abort condition. |
| Quota/cost | TPM/RPM/PTU or model capacity, dependency quotas, test budget, budget owner, and throttling expectation. |
| Telemetry | Azure Load Testing run ID, Foundry traces, Application Insights, Azure Monitor metrics, gateway/dependency logs, and correlation keys. |
| Thresholds | p50/p95/p99 latency, timeout, error rate, throttling, saturation, dependency failure, token/cost budget, and fallback behavior. |

Portal route:

1. Azure portal -> **Azure Load Testing** -> selected test resource.
2. Create or select the test.
3. Upload the approved script/package or configure the approved URL test.
4. Set secrets/environment variables inside the test resource.
5. Run the bounded test.
6. Correlate the Azure Load Testing run with Foundry, Application Insights,
   Azure Monitor, gateway, dependency, quota, and cost telemetry.
7. Hold release when any required threshold fails or quota/cost boundary is
   exceeded.

## 6. Result interpretation

| Result | Meaning | Required next action |
|---|---|---|
| Run succeeded | Evaluation completed and result summary is available. | Check thresholds, failed slices, baseline/candidate comparison, and support notes. |
| Evaluator unavailable | Evaluator missing, unsupported in region/project, preview-only for required gate, or mapped fields unavailable. | Select supported alternate, manual rubric, or hold. |
| Threshold failed | Required metric, high-risk slice, comparison, load, quota, or cost threshold failed. | Hold release or route exception to threshold owner. |
| Result diagnostic-only | Missing runtime prerequisite, baseline, threshold owner, scenario owner, support fit, or evidence handling. | Do not use for release reliance; create fix/retest action. |
| Baseline missing | No accepted prior run or comparison rule exists. | Establish baseline or obtain time-limited exception. |
| Override required | Release continues despite failed/missing signal. | Record owner, expiry, compensating check, change/ticket reference, and retest trigger. |
| Hold release | Any blocker remains. | Stop promotion until fixed, retested, or accepted by customer authority. |

## 7. Finding routes

| Signal | Open/inspect/fix route |
|---|---|
| Low groundedness | Inspect retrieval scope, source freshness, prompt assembly, context window, citations, and unsupported user request handling. |
| Task or quality failure | Inspect prompt/instruction change, model version, conversation state, input normalization, and scenario fit. |
| Tool-call failure | Inspect tool schema, parameter mapping, auth/identity, allow-list, side-effect approval, and trace. |
| Safety or policy failure | Inspect safety evaluator result, Content Safety/Prompt Shields/runtime-control references, and S8 retest route if adversarial. |
| Regression | Compare baseline and candidate versions, rollback path, changed dependency, and threshold owner exception. |
| Performance miss | Inspect load-test run, traces, latency percentiles, token use, dependency timing, throttling, quota, retry, cache, and budget. |
| Evidence gap | Fix missing owner, records location, runtime prerequisite, dataset version, support check, or threshold file before release reliance. |

## 8. Acceptance checks

| Work item | Accepted when... | Handoff |
|---|---|---|
| Candidate | Candidate change, environment, deployment/agent ID, owner, and release question are named. | Evaluation owner |
| Dataset/scenario | Source, version, mappings, included/excluded slices, and retest trigger are recorded. | Scenario owner |
| Foundry run | Evaluation ID, run ID, status, evaluator/rubric version, dataset/scenario version, and result link are recorded. | Foundry project owner |
| Baseline/candidate | Baseline and candidate IDs/results are compared, or baseline missing is routed. | Threshold owner |
| Thresholds | Metrics, threshold file/version, owner, failure behavior, and override route are recorded. | Release owner |
| CI/CD | Pipeline identity, task inputs, failure behavior, artifact storage, override, and manual hold path are verified. | Engineering/release |
| Load/performance | Tool, request mix, concurrency, quota/cost boundary, telemetry correlation, and threshold verdict are recorded. | Operations owner |
| Release action | Continue, hold, defer, reject, route, block, diagnostic-only, or retest is selected with owner and next check. | Release/change owner |

## Boundary note

S7 runs or wires up evaluation evidence for one bounded candidate. It does not
approve production, set thresholds for the customer, copy customer data into this
repository, or claim runtime enforcement from an evaluator result.

## Related references

- [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation)
- [How to run an evaluation in Azure DevOps](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluation-azure-devops)
- [Runtime security decisions](../s6-security-runtime/technical.md)
- [Operating and measurement decisions](../s10-operate-measure/technical.md)
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md)
- [Performance-testing guide](../reference/performance-testing-guide.md)
