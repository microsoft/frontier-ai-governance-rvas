# S5 Runbook

> **Safety:** adversarial testing is authorized-scope only. Notify the SOC before
> any run. Target only a customer-owned **NON-PRODUCTION** test agent/endpoint.

## Pre-flight

- [ ] SOC notified, with named contact and monitoring window.
- [ ] Written authorization approved and stored with the engagement record.
- [ ] Rules of engagement agreed: target, timing, categories, stop conditions, evidence handling.
- [ ] Target confirmed as customer-owned and non-production.
- [ ] `rollback.md` open and endpoint owner available.
- [ ] `datasets/attack-prompts.jsonl` and `policies/asr-thresholds.json` are
  reviewed for the authorized scope.

## Customer test deployment

The managed AI Red Teaming Agent covers content-harm categories. The offline mock
harness covers jailbreak and injection scenarios. Review both scopes for a complete
adversarial assessment; they are complementary measurements.

1. Confirm the authorization, written scope, SOC monitoring window, target, stop
   conditions, dataset, and ASR thresholds before connecting any scan.
2. Install dependencies in the customer's environment:
   ```bash
   python -m pip install "azure-ai-evaluation[redteam]" azure-ai-projects
   ```
3. Configure credentials and project details per the customer's Foundry standard.
   In the customer's approved codebase, implement the async
   `customer_redteam_adapter:target(prompt, endpoint)` contract. The adapter
   owns endpoint authentication and returns the target response; this kit does
   not contain an endpoint client.
4. Run the customer-operated adapter only against the authorized
   non-production endpoint:
   ```bash
   python scripts/redteam-airt.py \
     --azure-ai-project "$AZURE_AI_PROJECT_ENDPOINT" \
     --target-endpoint "https://<customer-non-production-endpoint>" \
     --target-adapter customer_redteam_adapter:target
   ```
5. Transfer the ASR scorecard and run metadata to the customer's approved
   records system. The local `evidence/` folder is ignored by Git.

The local mock harness is CI/static validation only; do not use it as a customer delivery path.

## Stop conditions

Stop the run if the endpoint behaves unexpectedly, the SOC requests a pause, the
run drifts outside written scope, or any participant is unsure whether an action
is authorized.
