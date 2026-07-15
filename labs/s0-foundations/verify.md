# S0 Verify & Capture Evidence

## Verify

- [ ] All 21 questions in `assessment/scorecard.csv` have a score of 1–4 (the scorer warns on blanks).
- [ ] `score.py` prints per-domain maturity, an overall score, and a 7-item prioritized roadmap.
- [ ] `coe/operating-model.md` names a real CoE owner and executive sponsor.
- [ ] `coe/raci.csv` has a named holder for each persona.
- [ ] `evidence/tenant-readiness.json` was reviewed and unavailable prerequisites have owners.

## Capture evidence

Generate the dated governance baseline in `evidence/`, then transfer it to the
customer's approved governance records system:

```bash
python assessment/score.py assessment/scorecard.csv | tee evidence/roadmap.txt
cp assessment/scorecard.csv evidence/scorecard-baseline-$(date +%Y%m%d).csv
```

Store the signed-off `operating-model.md` with the same approved record. Do not
commit generated `evidence/` output to this kit; it is ignored by Git. These
become the customer's **baseline** — S6 re-runs the same scorecard to prove
measurable lift.
