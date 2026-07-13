# S4 Rollback

S4 changes are evaluation and release-gate changes. The default mock run has no tenant or production impact.

## Disable a noisy gate

- Remove the copied GitHub Action workflow from the PR branch, or set it back to non-blocking/report-only.
- Restore the last approved `policies/thresholds.json` values.
- Re-run `python labs/s4-evaluation/pipelines/run_mock.py` to confirm the offline gate passes.

## Revert a regression

- Revert the prompt, model, tool, or routing change that caused the score drop.
- Keep the ignored `evidence/eval-results.json` in the customer's approved records system as audit evidence of the regression and fix.
- Add the failing case to the dataset if it represents a real expected behavior.

## Live-run cleanup

- Delete only temporary CI secrets or service connections created for the pilot.
- Do not delete Foundry project-level evaluation history unless the customer's retention policy requires it.
