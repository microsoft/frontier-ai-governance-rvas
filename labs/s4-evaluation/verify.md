# S4 Verify & Capture Evidence

## Verify

- [ ] `python labs/s4-evaluation/pipelines/run_mock.py` exits `0` with the shipped dataset.
- [ ] `evidence/eval-results.json` exists and includes aggregate scores, thresholds, and pass/fail status.
- [ ] `python labs/s4-evaluation/scripts/summarize.py` prints a readable scorecard.
- [ ] Live runs target a non-production/test agent first.

## Capture evidence

Transfer the following to the customer's approved records system; generated
`evidence/` output is ignored by Git and must not be committed to this kit:

- `evidence/eval-results.json`
- The approved `policies/thresholds.json`
- CI run URL/log excerpt if the GitHub Action is piloted
- Dataset version and target agent version used for the run

These artifacts form the customer's S4 quality and safety evaluation record and feed S6 operationalization.
