# S4 · Quality & Safety Evaluation

!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · Concepts sourced from [Reference - Landscape](../reference/index.md) and status in [Product Status](../reference/product-status.md).

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with a **repeatable evaluation suite and CI/CD gate** for a non-production AI agent:

- A local **mock-target evaluation pipeline** that runs without cloud access and produces a dated scorecard.
- A production path for **Microsoft Foundry Evaluations** using the `azure-ai-evaluation` Python SDK.
- A CI/CD gate pattern that can fail pull requests when quality or safety scores regress.

**Durable artifact:** `labs/s4-evaluation/` - dataset, thresholds, Foundry evaluation reference script, GitHub Actions gate snippet, and captured evidence. Local mock evaluation is CI/static validation only.

## 2. Prerequisites

- An Azure AI Foundry project and Azure OpenAI / judge-model deployment for evaluators that require a cloud judge.
- Python 3.11+ and permission to install `azure-ai-evaluation` (current stable line ~v1.17.x as of the last review - verify the latest on PyPI) on the operator workstation or CI runner.[^foundry]
- A **non-production / test agent** endpoint or callable target. Do not run first-time evaluation gates against production traffic.
- GitHub repository access to add a pull-request evaluation gate using `microsoft/ai-agent-evals`.[^aievals]
- OpenTelemetry gen-ai tracing enabled if the customer will connect evaluation results to production monitoring.[^foundry]

## 3. Concepts

- <span class="rvas-badge rvas-ga">GA</span> **Foundry Evaluations** are exposed through the `azure-ai-evaluation` Python SDK. Evaluator families include **quality** (relevance, coherence, fluency, groundedness, similarity, F1), **NLP** (BLEU, ROUGE, METEOR), **risk & safety** (violence, sexual, self-harm, hate/unfairness, protected material, indirect attack / XPIA), and **agent-specific** checks (intent resolution, tool-call accuracy, task adherence). Some individual evaluators remain <span class="rvas-badge rvas-preview">Preview</span>; verify status before production use.[^foundry]
- <span class="rvas-badge rvas-ga">GA</span> **Quality and NLP evaluators** can be run as repeatable batch tests over a fixed dataset. This makes quality measurable before a prompt, tool, or model change ships.[^foundry]
- <span class="rvas-badge rvas-preview">Preview</span> **Risk/safety and continuous evaluation** normally require an Azure AI project plus a judge model. Treat the first rollout as observe-only: collect failures, tune thresholds, and document exceptions before blocking releases.[^foundry]
- **CI/CD gates are governance controls.** The `microsoft/ai-agent-evals` GitHub Action runs evaluations on pull requests and can fail the build on score regression, turning the evaluation suite into a release gate.[^aievals]
- **Continuous evaluation closes the loop.** Production monitoring can combine the EvaluationRule API with OpenTelemetry gen-ai tracing so live agent behavior feeds dashboards, trend analysis, and future regression datasets.[^foundry]

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    Evaluate a **non-production / test agent** first. The initial gate is report-only unless the customer deliberately chooses to fail PRs after reviewing baseline scores, false positives, and rollback.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">AI developer / maker</span>)* - confirm target is non-production, open `labs/s4-evaluation/rollback.md`, agree thresholds and approver.
2. **Review the dataset** - inspect `labs/s4-evaluation/data/eval-dataset.jsonl`; replace sample rows with representative safe test cases before live use.
3. **Review thresholds** - tune `labs/s4-evaluation/policies/thresholds.json` for the customer's risk appetite. Start permissive enough to learn; tighten after observing baseline variance.
4. **Run the offline mock gate** - execute `python labs/s4-evaluation/pipelines/run_mock.py`. This creates `labs/s4-evaluation/evidence/eval-results.json` without network calls.
5. **Inspect the scorecard** - use `labs/s4-evaluation/scripts/summarize.py` to render the JSON evidence as a table and record any failing cases.
6. **Foundry path** - map the same dataset and target into `labs/s4-evaluation/pipelines/azure-eval.py` with Azure AI project environment variables.
7. **CI/CD gate design** - adapt `labs/s4-evaluation/pipelines/github-action-example.yml` in a pull-request branch. Keep it report-only first (do not block merges); enable enforcement - e.g. a `baseline-agent-id` regression comparison - only after governance approval.
8. **Continuous evaluation plan** - define which production traces become future evaluation examples, using OpenTelemetry gen-ai spans and EvaluationRule monitoring.

## 5. Verification & evidence capture

- [ ] `pipelines/run_mock.py` exits `0` with the shipped dataset and writes `evidence/eval-results.json`.
- [ ] The scorecard records per-case metrics, aggregate metrics, thresholds, and pass/fail status.
- [ ] Foundry environment variables and judge-model ownership are documented before any live run.
- [ ] Any CI gate starts in report-only or non-blocking mode until the customer approves enforcement.

**Evidence to capture** into `labs/s4-evaluation/evidence/`: `eval-results.json`, CI run URL or log excerpt, approved thresholds, and a short note describing dataset version and target agent version.

## 6. Rollback

Rollback is a release-control change, not a data-plane deletion:

- Disable or remove the PR gate snippet from the feature branch.
- Restore the previous `thresholds.json` values if a threshold change caused noise.
- Revert the target prompt/model/tool change that introduced a regression.
- Keep `evidence/eval-results.json` as an audit record; do not delete historical scorecards unless the customer's retention policy requires it.

Detailed steps are in `labs/s4-evaluation/rollback.md`.

## 7. Governance mapping

| Artifact | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|----------|-------------|---------------|-----------|
| Foundry evaluation suite + CI/CD gate | **Measure** | A.6 (verification & validation) | Art. 15 (accuracy), Art. 9 (risk mgmt) |
| Offline mock-target scorecard | **Measure** | A.6 (verification & validation) | Art. 15 (accuracy) |
| Continuous evaluation plan + trace lineage | **Measure**, **Manage** | A.10 (operations, monitoring) | Art. 72 (post-market monitoring), Art. 12 (logging) |

Consolidated in [Reference - Governance Mapping](../reference/governance-mapping.md).

## 8. Facilitator notes

- **Timing:** ~half day. Concepts + safety ~45 min, dataset/threshold review ~60 min, Foundry evaluation evidence ~45 min, CI design ~75 min, wrap-up ~30 min.
- **RACI:** AI developer / maker = **R**, Governance lead = **A**, Security / SOC = **C** (risk/safety thresholds), Compliance / Data admin = **C** (dataset handling), Identity admin = **I**.
- **Common blockers:**
    - *No Azure AI project or judge model* → stop S4 live delivery and route Foundry/evaluator provisioning to the prerequisite backlog.
    - *Dataset is not representative* → run only as simulation; do not enforce a gate until customer-owned cases are added.
    - *Safety evaluator availability differs by region/status* → mark affected evaluators Preview and verify current Foundry support.
    - *CI secrets unavailable* → keep the GitHub Action as a documented snippet and run the local mock gate in PR validation.
- **Hand-off:** S4 evidence feeds S5 adversarial testing and S6 operationalization; failed cases become regression rows for the next evaluation dataset.

[^foundry]: Microsoft Learn - [Foundry Observability](https://learn.microsoft.com/en-us/azure/ai-foundry/concepts/observability); Azure SDK for Python - [`azure-ai-evaluation` README](https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/evaluation/azure-ai-evaluation/README.md).
[^aievals]: GitHub Marketplace / repository - [`microsoft/ai-agent-evals`](https://github.com/microsoft/ai-agent-evals), a GitHub Action for running agent evaluations in CI/CD.
