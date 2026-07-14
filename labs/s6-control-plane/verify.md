# S6 Verify & Capture Evidence

## Verify

- [ ] Agent 365 registry export is present in `evidence/`.
- [ ] Reconciliation report exists and is valid JSON.
- [ ] Shadow agents, unmanaged/OBO agents, and missing sponsors were reviewed with owners.
- [ ] Exit scorecard was filled using the same S0 seven-domain, 1-4 maturity instrument.
- [ ] Residual gaps are assigned to the governance backlog.

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

Store `agent-registry.json`, `reconciliation-report.json`, `exit-scorecard.csv`, `exit-score-output.txt`, and the residual-gap backlog in `evidence/` or the customer's approved records system.
