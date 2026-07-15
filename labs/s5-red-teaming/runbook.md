# S5 Runbook — Authorized customer-operated red teaming

> **Safety:** adversarial testing is authorized-scope only. Notify the SOC before
> any run. Target only a customer-owned **NON-PRODUCTION** test agent/endpoint.

## Pre-flight

- [ ] SOC notified, with named contact and monitoring window.
- [ ] Written authorization approved and stored with the engagement record.
- [ ] Rules of engagement agreed: target, timing, categories, stop conditions,
  and evidence handling.
- [ ] Target confirmed as customer-owned and non-production.
- [ ] Endpoint owner is available to pause or reset the non-production target.
- [ ] Customer-approved test categories and ASR thresholds are recorded in the
  engagement record; this kit does not provide them.

## Customer-operated path

1. Confirm the authorization, written scope, SOC monitoring window, target,
   stop conditions, test categories, and ASR thresholds before connecting a scan.
2. Install dependencies in the customer's environment:
   ```bash
   python -m pip install "azure-ai-evaluation[redteam]" azure-identity
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
   The script leaves the Foundry-generated scorecard at
   `evidence/airt-native-scorecard.json`; it does not rewrite that output.
5. If the customer has completed an approved review that transcribes category
   ASRs from the native scorecard, create an ignored comparison sidecar only:
   ```bash
   python scripts/redteam-airt.py \
     --azure-ai-project "$AZURE_AI_PROJECT_ENDPOINT" \
     --target-endpoint "https://<customer-non-production-endpoint>" \
     --target-adapter customer_redteam_adapter:target \
     --threshold-review evidence/customer-approved-asr-review.json
   ```
   The review is a customer-owned JSON object with a `categories` array. Each
   item has `category`, `observed_asr`, and `max_acceptable_asr` values from
   `0` through `1`. The resulting
   `evidence/airt-threshold-comparison.json` is a decision aid, not a native
   Foundry scorecard.

## Evidence and decision handoff

- [ ] The native Foundry scorecard and run metadata are referenced in the
  customer's approved records system.
- [ ] If thresholds were reviewed, the ignored comparison sidecar is retained
  beside the native scorecard and every above-threshold category has a
  remediation owner and due date.
- [ ] SOC de-brief records authorized alerts/incidents and the endpoint owner
  records any required cleanup.
- [ ] Governance lead records the remediation, accepted-risk, blocked, or
  re-test decision in the approved decision register.

## Stop conditions

Stop the run if the endpoint behaves unexpectedly, the SOC requests a pause, the
run drifts outside written scope, or any participant is unsure whether an action
is authorized.
