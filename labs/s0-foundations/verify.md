# S0 Verify & Capture Evidence

## Verify

- [ ] All 21 questions in `assessment/scorecard.csv` have a score of 1–4 (the scorer warns on blanks).
- [ ] `score.py` prints per-domain maturity, an overall score, and a 7-item prioritized roadmap.
- [ ] `coe/operating-model.md` names a real CoE owner and executive sponsor.
- [ ] `coe/raci.csv` has a named holder for each persona.

## Capture evidence

Store the dated governance baseline in `evidence/`:

```bash
python assessment/score.py assessment/scorecard.csv | tee evidence/roadmap.txt
cp assessment/scorecard.csv evidence/scorecard-baseline-$(date +%Y%m%d).csv
```

Also commit the signed-off `operating-model.md`. These become the customer's **baseline** — S6 re-runs the same scorecard to prove measurable lift.
