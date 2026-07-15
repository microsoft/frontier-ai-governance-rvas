# S4 Takeaway Kit — Quality & Safety Evaluation

Runnable evaluation assets for a non-production AI-agent quality gate. Customer delivery uses Microsoft Foundry Evaluations; the no-network mock target is CI/static validation only.

## Contents

```
data/
  eval-dataset.jsonl                 bundled sample cases for the mock evaluator
policies/
  thresholds.json                    per-metric pass thresholds for the gate
pipelines/
  run_mock.py                        offline mock-target evaluator + CI gate demo
  azure-eval.py                      customer-operated target-adapter contract for azure-ai-evaluation
  github-action-example.yml          documented ai-agent-evals PR gate snippet
scripts/
  summarize.py                       render evidence/eval-results.json as a table
evidence/
  .gitkeep                           ignored customer-generated scorecards and CI logs
fixtures/
  eval-results.example.json          shipped example scorecard
runbook.md  rollback.md  verify.md
```

## Prerequisites

- Python 3.11+ for the offline path.
- No network, Azure subscription, or Azure SDK packages are required for `run_mock.py`.
- Live evaluation requires an Azure AI Foundry project, judge model deployment,
  `azure-ai-evaluation` in the runner, and a customer-owned non-production
  target adapter. The kit does not contain an endpoint client or credentials.

## Run order

1. Review `data/eval-dataset.jsonl` and replace samples with customer-owned non-sensitive test cases.
2. Review `policies/thresholds.json` and set report-only gate thresholds.
3. Run the offline gate:
   ```bash
   python labs/s4-evaluation/pipelines/run_mock.py
   ```
4. Summarize the evidence:
   ```bash
   python labs/s4-evaluation/scripts/summarize.py
   ```
5. In the customer's approved codebase, implement the
   `pipelines/azure-eval.py --target-adapter MODULE:CALLABLE` contract for the
   non-production target, configure its environment variables, and adapt
   `pipelines/github-action-example.yml` in a PR branch.
6. Capture outputs per `verify.md`.

<!-- Verified: static-only — ruff + py_compile + offline mock-target evaluation + JSON load. Live Foundry execution is the customer's co-delivery step. -->
