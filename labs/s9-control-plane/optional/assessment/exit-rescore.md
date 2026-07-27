# S9 Exit Re-score

Use this optional comparison only when the customer has an approved S0 baseline
and elects to compare it. It is not an S9 entry or closeout requirement. Do not
create or infer a baseline to produce a score.

## Steps

1. Confirm the baseline reference, scorecard version, and comparison owner in
   approved records. If any is unavailable, record the coverage limitation in
   `closeout-backlog.md` and skip this comparison.
2. Copy the approved baseline scorecard structure into a customer-controlled,
   gitignored S9 evidence location:
   ```bash
   cp ../s0-foundations/optional/assessment/scorecard.csv ../s9-control-plane/optional/evidence/exit-scorecard.csv
   ```
3. Fill the `score` column with the customer using the same 1-4 scale:
   - 1 = Ad-hoc
   - 2 = Repeatable
   - 3 = Defined
   - 4 = Optimized
4. Run the scorer from the S9 kit directory:
   ```bash
   python ../s0-foundations/optional/assessment/score.py optional/evidence/exit-scorecard.csv
   ```
5. Auto-compute the **lift versus the approved S0 baseline** and the
   residual-gap backlog:
   ```bash
   python ../s0-foundations/optional/assessment/compare.py \
     ../s0-foundations/optional/evidence/scorecard-baseline-*.csv \
     optional/evidence/exit-scorecard.csv --target 3.0 \
     | tee optional/evidence/maturity-lift.txt
   ```
   `compare.py` prints per-domain baseline→exit deltas, overall lift, and the domains still below the target maturity (the residual-gap backlog). Capture
   `optional/evidence/maturity-lift.txt` as the comparison record. The comparison is
   optional decision input; it is not evidence that a control operates and is
   not required for S9 closeout.

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

Domains below target maturity become the residual-gap backlog for the
governance decision group. Complete `closeout-backlog.md` in the customer's
approved records system to formally record accountable owners, dates,
validation, recurrence, and the closeout decision.
