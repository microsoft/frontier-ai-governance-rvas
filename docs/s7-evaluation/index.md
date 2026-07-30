# S7 · Foundry Evaluation Runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · This runbook uses Microsoft Foundry evaluations, Azure DevOps `AIAgentEvaluation@2`, and Azure Load Testing patterns. Confirm region, evaluator, role, quota, pricing, and SDK/task versions before delivery.

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Release owner</span> <span class="rvas-badge rvas-persona">Evaluation owner</span>

!!! abstract "What this workshop does"
    S7 runs or wires up one concrete evaluation path for a bounded Foundry change: select the project, attach the dataset or scenario set, choose evaluators, run the baseline and candidate, check thresholds, export safe result references, and decide whether the release must continue, hold, retest, or stay diagnostic-only.

## 1. Start with one candidate and one Foundry project

Use a non-production Foundry project or a customer-approved pre-release project.
Before opening the evaluator, name:

- Candidate change: model/deployment, prompt or instruction, agent version,
  retrieval source, tool/API schema, policy/control, or release package.
- Baseline reference: previous accepted run, previous agent version, gold
  scenario result, or manual score. If no baseline exists, record **baseline
  missing** and use the result only as diagnostic evidence until the customer
  accepts another comparison rule.
- Dataset or scenario version: Foundry dataset name/version, JSONL/CSV source
  reference, trace/response IDs, scenario-simulation reference, or approved
  customer record.
- Threshold owner: the person or role allowed to set or change pass/fail
  thresholds.
- Evidence location: customer-owned records system. Do not paste prompts,
  outputs, telemetry exports, endpoints, secrets, tenant identifiers, or live
  configuration into this repository.

## 2. Run the Foundry evaluation flow

Portal route:

1. Open `ai.azure.com`.
2. Select the account, hub/project, and environment used for pre-release work.
3. Open **Build** -> **Evaluations**.
4. Check **Evaluator catalog** for the selected evaluator names, versions,
   required inputs, and support notes.
5. Open **Datasets** and upload or select the versioned JSONL/CSV dataset, or
   choose a supported Foundry response/trace/scenario source.
6. Create an evaluation run. Select the dataset/scenario source, model or agent
   target, evaluator set, column mappings, and baseline/candidate agent IDs or
   versions where comparison is supported.
7. Run the evaluation and wait for status **Succeeded**, **Failed**, or
   **Canceled**.
8. Open the run result, compare baseline and candidate metrics, inspect failed
   slices, and copy only safe run IDs and result references into the customer
   record.

SDK route when the portal is not the operating path:

- Use `azure-ai-projects>=2.2.0` with `DefaultAzureCredential`.
- Upload the dataset with `project_client.datasets.upload_file(...)` or
  reference existing response/trace IDs.
- Create the evaluation with `openai_client.evals.create(...)`.
- Start the run with `openai_client.evals.runs.create(...)`.
- Poll until completion, then store the run ID, status, metric summary, and
  result URL/reference in the approved customer location.

## 3. Add the CI/CD branch only when the release process can consume it

For Azure DevOps, use the Microsoft Foundry AI Agent Evaluation extension:

- Authentication: Azure Resource Manager service connection or federated
  pipeline identity. Prefer secretless Entra ID; if a secret is unavoidable,
  record the exception owner and expiry outside this repository.
- Task: `AIAgentEvaluation@2`.
- Required inputs: `azure-ai-project-endpoint`, `deployment-name`, `data-path`,
  and `agent-ids`.
- Baseline: `baseline-agent-id` when comparing candidate to an accepted agent
  version.
- Threshold file: versioned JSON/checked policy file owned by the customer, such
  as `evaluation-thresholds.json`, referenced by the pipeline check or post-step
  that fails the run when required metrics regress.
- Failure behavior: fail pull request, fail release stage, warn only, require
  human review, or hold deployment. Warning-only and manual override must name
  the override owner, expiry, retest trigger, and ticket/change reference.
- Pipeline artifact storage: store report, run summary, threshold file version,
  baseline/candidate IDs, and safe result link in the pipeline system and the
  customer records system. Do not store raw prompts or outputs here.

Expected Azure DevOps signal: the pipeline summary shows evaluator scores,
confidence intervals where available, and comparison results for the listed
agents. If the task cannot authenticate, the project endpoint is wrong, an
evaluator is unavailable, or thresholds fail, route to the owner before the
release continues.

## 4. Add load and performance when latency, quota, saturation, or cost matters

Use Azure Load Testing or another customer-approved tool against a
non-production endpoint.

Preflight:

- Test endpoint and auth path are approved for synthetic traffic.
- Request mix is explicit: user journeys, model/agent routes, retrieval/tool
  calls, cache state, streaming/non-streaming behavior, and invalid/timeout
  cases.
- Concurrency and ramp plan are bounded: users, arrival rate, duration, burst,
  retry policy, timeout, and stop conditions.
- Quota and cost boundary is approved: model TPM/RPM or PTU capacity,
  dependency quotas, budget cap, rate-limit owner, and test abort threshold.
- Telemetry correlation is ready: Foundry traces, Application Insights, Azure
  Monitor, gateway logs, dependency telemetry, and load-test run ID.

Run and check:

1. Open Azure portal -> **Azure Load Testing** -> selected test resource.
2. Create or select the test, upload the approved JMeter/k6/script package or
   configure the approved URL-based test.
3. Set environment variables/secrets in the tool, not in this repository.
4. Run against the pre-release deployment.
5. Correlate load-test run ID with Foundry traces, Application Insights, Azure
   Monitor, dependency failures, throttling, retries, and token/cost records.
6. Hold release when p95/p99 latency, error rate, saturation, quota, budget, or
   dependency failure crosses the customer threshold.

## 5. Expected signals

| Signal | What to check | Release action |
|---|---|---|
| Run succeeded | Foundry evaluation run status is **Succeeded** and result summary is available. | Review thresholds and failed slices before continue. |
| Evaluator unavailable | Evaluator missing from catalog, unsupported in region/project, preview-only for the needed gate, or required mapping unavailable. | Use approved alternate evaluator/manual review or hold. |
| Threshold failed | Required metric, slice, confidence interval, ASR-derived safety result, latency, error, or cost threshold fails. | Hold release or route exception to threshold owner. |
| Result diagnostic-only | Runtime prerequisite, baseline, scenario owner, threshold owner, or support fit is missing. | Do not use as release reliance. Open fix/retest action. |
| Baseline missing | No prior accepted run or accepted comparison rule exists. | Create baseline or obtain threshold-owner exception before release reliance. |
| Override required | Pipeline or manual gate needs exception despite failed/missing signal. | Name override owner, expiry, compensating check, and retest trigger. |
| Hold release | Any blocker remains: failed threshold, unsupported evaluator, quota/cost breach, missing owner, or unsafe evidence handling. | Stop promotion until fixed or accepted through customer process. |

## 6. Lab output

`labs/s7-evaluation/` contains the runbook lab kit and template. Store the
completed run details in the customer's approved records system. This repository
keeps only blank templates and safe field shapes.

## Related references

- [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation)
- [How to run an evaluation in Azure DevOps](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluation-azure-devops)
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md)
- [Performance-testing guide](../reference/performance-testing-guide.md)
