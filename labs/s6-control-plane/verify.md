# S6 Verify & Capture Evidence

## Verify

- [ ] Agent 365 registry export is present in `evidence/`.
- [ ] Reconciliation report exists and is valid JSON.
- [ ] Shadow agents, unmanaged/OBO agents, and missing sponsors were reviewed with owners.
- [ ] Exit scorecard was filled using the same S0 seven-domain, 1-4 maturity instrument.
- [ ] `evidence/maturity-lift.txt` documents the mandatory baseline-to-exit comparison.
- [ ] A completed `assessment/closeout-backlog.md` record contains the closeout
  decision, approver, and an owner, due date, and status for every residual gap.

## Capture evidence

```bash
python scripts/reconcile-registry.py \
  --registry evidence/agent-registry.json \
  --inventory ../s1-identity/evidence/agent-inventory.json \
  --out evidence/reconciliation-report.json

python ../../labs/s0-foundations/assessment/score.py evidence/exit-scorecard.csv | tee evidence/exit-score-output.txt

python ../../labs/s0-foundations/assessment/compare.py \
  ../../labs/s0-foundations/evidence/scorecard-baseline-*.csv \
  evidence/exit-scorecard.csv --target 3.0 | tee evidence/maturity-lift.txt
```

Transfer `agent-registry.json`, `reconciliation-report.json`,
`exit-scorecard.csv`, `exit-score-output.txt`, `maturity-lift.txt`, and the
completed closeout/backlog record to the customer's approved records system.
The local `evidence/` folder is ignored by Git and is only a staging location.
