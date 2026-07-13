# S5 Runbook

> **Safety:** adversarial testing is authorized-scope only. Notify the SOC before
> any run. Target only a customer-owned **NON-PRODUCTION** test agent/endpoint.

## Pre-flight

- [ ] SOC notified, with named contact and monitoring window.
- [ ] Written authorization approved and stored with the engagement record.
- [ ] Rules of engagement agreed: target, timing, categories, stop conditions, evidence handling.
- [ ] Target confirmed as customer-owned and non-production.
- [ ] `rollback.md` open and endpoint owner available.
- [ ] ASR thresholds reviewed in `policies/asr-thresholds.json`.

## Customer test deployment

1. Install dependencies in the customer's environment:
   ```bash
   python -m pip install "azure-ai-evaluation[redteam]" azure-ai-projects
   ```
2. Configure credentials and project details per the customer's Foundry standard.
3. Review the reference script:
   ```bash
   python scripts/redteam-airt.py --help
   ```
4. Run only against the authorized non-production test endpoint.
5. Export the ASR scorecard and run metadata to `evidence/`.

The local mock harness is CI/static validation only; do not use it as a customer delivery path.

## Stop conditions

Stop the run if the endpoint behaves unexpectedly, the SOC requests a pause, the
run drifts outside written scope, or any participant is unsure whether an action
is authorized.
