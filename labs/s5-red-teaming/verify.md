# S5 Verify & Capture Evidence

## Verify

- [ ] SOC notification and written authorization are recorded.
- [ ] Target was customer-owned and non-production.
- [ ] `evidence/asr-scorecard.json` exists.
- [ ] Scorecard includes attempts, successes, ASR, and max acceptable ASR per category.
- [ ] Any category above threshold has a remediation owner and due date.
- [ ] SOC de-brief completed and alerts/incidents annotated as authorized testing.

## Capture evidence

Tier B:

```bash
python pipelines/run_mock.py
```

Tier A:

- Export the AI Red Teaming Agent ASR scorecard.
- Save run metadata: authorized target name, time window, operator, categories,
  and thresholds.
- Store outputs under `evidence/` with the engagement record.
