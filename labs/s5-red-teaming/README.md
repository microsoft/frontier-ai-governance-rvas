# S5 Takeaway Kit — Adversarial Testing

Runs an authorized, scoped red-team workflow and captures an Attack Success Rate
(ASR) scorecard. Customer delivery uses Microsoft Foundry AI Red Teaming Agent
against a customer-owned non-production test endpoint. The offline mock harness
is CI/static validation only.

!!! warning "Safety / authorization required"
    Do not run adversarial activity unless the SOC has been notified, written
    authorization and rules of engagement are approved, and the target is a
    customer-owned **NON-PRODUCTION** test agent/endpoint only.

## Contents

```
datasets/
  attack-prompts.jsonl       benign category-labeled adversarial test cases
policies/
  asr-thresholds.json        max acceptable ASR per category
pipelines/
  run_mock.py                offline no-network mock red-team harness -> evidence/asr-scorecard.json
scripts/
  redteam-airt.py            customer-operated async target-adapter contract for RedTeam
evidence/                   ignored customer-generated ASR scorecards and run notes
fixtures/
  asr-scorecard.example.json shipped example scorecard
runbook.md  rollback.md  verify.md
```

## Prerequisites

- Authorized customer test endpoint, Foundry project access,
  `azure-ai-evaluation[redteam]`, and a customer-owned async target adapter
  installed by the customer operator. The kit contains no endpoint client or
  credentials.

## Run order

1. Confirm SOC notification, written authorization, target scope, and rules of engagement.
2. Review `datasets/attack-prompts.jsonl` and `policies/asr-thresholds.json`.
3. In the customer's approved codebase, implement the
   `customer_redteam_adapter:target(prompt, endpoint)` async contract. Then the
   customer operator can run against the approved endpoint:
   ```bash
   python scripts/redteam-airt.py \
     --azure-ai-project "$AZURE_AI_PROJECT_ENDPOINT" \
     --target-endpoint "https://<customer-non-production-endpoint>" \
     --target-adapter customer_redteam_adapter:target
   ```
4. Capture `evidence/airt-asr-scorecard.json` and complete `verify.md`.
5. Follow `rollback.md` for cleanup and SOC de-brief.

<!-- Verified: static-only — Python compile/lint, JSON validation, and offline mock pipeline. Live execution is the customer's co-delivery step. -->
