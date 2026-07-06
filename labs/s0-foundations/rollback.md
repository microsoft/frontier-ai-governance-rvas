# S0 Rollback

S0 produces **documents only** and makes **no changes to any tenant, subscription, or directory**. There is nothing to revert in a live system.

To discard the session's working output before it is committed:

```bash
git checkout -- labs/s0-foundations/
# or, if on a working branch:
git switch - && git branch -D s0-baseline
```

If the operating model or scorecard was already committed and the customer wants to restart the baseline, simply overwrite `assessment/scorecard.csv` with a fresh copy and re-run the scorer; keep the prior file in `evidence/` for history.
