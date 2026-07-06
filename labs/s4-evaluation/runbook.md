# S4 Runbook

> **Safety:** report-only / audit-first. Evaluate only a non-production or test agent until baseline scores and false positives are understood.

## Pre-flight

- [ ] Target agent is non-production or a deterministic mock target.
- [ ] `rollback.md` is open.
- [ ] Threshold owner and approver are named.
- [ ] Dataset contains no secrets, regulated personal data, or production-only customer content.

## Steps

1. **Dataset review.** Inspect `data/eval-dataset.jsonl`; replace sample cases with customer-owned test prompts and ground truth.
2. **Threshold review.** Adjust `policies/thresholds.json` for report-only baseline collection.
3. **Run offline gate.**
   ```bash
   python labs/s4-evaluation/pipelines/run_mock.py
   ```
4. **Summarize evidence.**
   ```bash
   python labs/s4-evaluation/scripts/summarize.py
   ```
5. **Review failures.** Classify each failed case as target bug, dataset issue, threshold issue, or evaluator limitation.
6. **Tier A mapping.** If an Azure AI project and judge model are available, adapt `pipelines/azure-eval.py` and the GitHub Action snippet.
7. **Capture evidence** per `verify.md`.
8. **Decide promotion.** Blocking PR gates are a later, customer-owned enforcement decision.
