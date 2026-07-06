# S0 Runbook

No tenant changes. This is a facilitated discovery + planning session.

1. **Operating model (~60 min).** With the governance lead + sponsor, complete `coe/operating-model.md` (ownership, cadence, use-case intake stub) and `coe/raci.csv`.
2. **Baseline assessment (~90 min).** Open `assessment/scorecard.csv`. For each of the 21 questions, agree a maturity score of 1–4 with the room. The discussion is the value — capture disagreements as notes.
3. **Generate roadmap (~15 min).**
   ```bash
   python assessment/score.py assessment/scorecard.csv | tee evidence/roadmap.txt
   ```
4. **Agree sequence (~15 min).** The CoE confirms the actual session order in `operating-model.md`.
5. **Capture evidence.** Follow `verify.md`.
