# S6 Exit Re-score

S6 closes the loop opened in S0 by re-running the same maturity instrument.

## Steps

1. Copy the baseline scorecard structure into S6 evidence:
   ```bash
   cp ../s0-foundations/assessment/scorecard.csv ../s6-control-plane/evidence/exit-scorecard.csv
   ```
2. Fill the `score` column with the customer using the same 1-4 scale:
   - 1 = Ad-hoc
   - 2 = Repeatable
   - 3 = Defined
   - 4 = Optimized
3. Run the scorer from the S6 kit directory:
   ```bash
   python ../s0-foundations/assessment/score.py evidence/exit-scorecard.csv
   ```
4. Auto-compute the **lift vs the S0 baseline** and the residual-gap backlog:
   ```bash
   python ../s0-foundations/assessment/compare.py \
     ../s0-foundations/evidence/scorecard-baseline-*.csv \
     evidence/exit-scorecard.csv --target 3.0 \
     | tee evidence/maturity-lift.txt
   ```
   `compare.py` prints per-domain baseline→exit deltas, overall lift, and the domains still below the target maturity (the residual-gap backlog). Capture
   `evidence/maturity-lift.txt` as the engagement's proof of measurable
   improvement. The comparison is mandatory for S6 closeout.

The table below is auto-produced by `compare.py`; fill the backlog-owner column by hand:

| Domain | Baseline | Exit | Lift | Residual backlog owner |
|--------|----------|------|------|------------------------|
| D0 | | | | |
| D1 | | | | |
| D2 | | | | |
| D3 | | | | |
| D4 | | | | |
| D5 | | | | |
| D6 | | | | |

Domains below target maturity become the residual-gap backlog for the AI CoE /
governance board. Complete `closeout-backlog.md` in the customer's approved
records system to formally record its owners, dates, and closeout decision.
