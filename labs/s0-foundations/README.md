# S0 Takeaway Kit — Foundations & Operating Model

Durable artifacts for the customer's governance repository.

## Contents

```
assessment/
  scorecard.csv     21-question, 7-domain maturity assessment (fill the score column 1-4)
  score.py          auto-scorer: per-domain + overall maturity + prioritized roadmap
coe/
  operating-model.md  AI Center of Excellence operating model (fill owner/sponsor)
  raci.csv            RACI across the five personas
evidence/
  .gitkeep          drop the baseline scorecard, roadmap.txt, and signed operating model here
runbook.md          run order for the session
rollback.md         how to revert (S0 makes no tenant changes)
verify.md           how to confirm + capture evidence
```

## Run order

1. Fill `coe/operating-model.md` and `coe/raci.csv`.
2. Score `assessment/scorecard.csv` with the room (1–4 per question).
3. Run the scorer:
   ```bash
   python assessment/score.py assessment/scorecard.csv
   ```
4. Capture evidence per `verify.md`.

<!-- Verified: static-only — validated in CI (ruff + py_compile + CSV load). Live use is the customer's co-delivery step. -->
