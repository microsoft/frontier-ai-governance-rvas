# S5 Takeaway Kit — Adversarial Testing

Runs an authorized, scoped red-team workflow and captures an Attack Success Rate
(ASR) scorecard. Tier A uses Microsoft Foundry AI Red Teaming Agent against a
customer-owned non-production test endpoint. Tier B uses the offline mock harness
included here.

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
  redteam-airt.py            Tier A reference script for azure-ai-evaluation RedTeam
evidence/                   generated ASR scorecards and run notes
runbook.md  rollback.md  verify.md
```

## Prerequisites

- Tier A: authorized customer test endpoint, Foundry project access, and
  `azure-ai-evaluation[redteam]` installed by the customer operator.
- Tier B: Python 3.11+ only. No network, Azure packages, or live model needed.

## Run order

1. Confirm SOC notification, written authorization, target scope, and rules of engagement.
2. Review `datasets/attack-prompts.jsonl` and `policies/asr-thresholds.json`.
3. Tier B baseline:
   ```bash
   python pipelines/run_mock.py
   ```
4. Tier A reference path, run only by the customer operator against the approved test endpoint:
   ```bash
   python scripts/redteam-airt.py --help
   ```
5. Capture `evidence/asr-scorecard.json` and complete `verify.md`.
6. Follow `rollback.md` for cleanup and SOC de-brief.

<!-- Verified: static-only — Python compile/lint, JSON validation, and offline mock pipeline. Live execution is the customer's co-delivery step. -->
