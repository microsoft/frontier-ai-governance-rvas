# S3 Takeaway Kit — Security Posture & Runtime

Builds an audit-first security baseline for AI workloads: Defender for Cloud AI-SPM exports, AI Threat Protection status capture, and Azure AI Content Safety Prompt Shields testing.

## Contents

```
infra/
  main.bicep                  subscription-scope deployment wrapper
  main.parameters.json        azd/ARM-style parameter example
  modules/content-safety.bicep Azure AI Content Safety account module
scripts/
  test_prompt_shield.sh       calls Content Safety Prompt Shields with a test string
  export_defender_ai_recommendations.sh read-only Defender AI recommendation export
policies/
  content-safety-runtime-baseline.json   runtime safety baseline placeholders
  defender-ai-assessment-export-template.json Defender evidence schema/template
pipelines/
  run_mock.py                 static safety/config validation, no network
evidence/                     captured deployment output, exports, Prompt Shield results
runbook.md  rollback.md  verify.md
```

## Prerequisites

- Azure CLI logged in to the customer subscription.
- Deployment rights for the target resource group; Security/SOC permissions for Defender for Cloud exports.
- Bicep CLI locally or in CI for `infra/main.bicep`.
- A customer-owned non-production test endpoint/string for runtime checks.

## Run order

1. Review `infra/main.parameters.json`; replace `REPLACE-WITH-...` values.
2. Deploy or preview the Content Safety account:
   ```bash
   az deployment sub what-if --location westeurope \
     --template-file infra/main.bicep \
     --parameters @infra/main.parameters.json
   ```
3. Export Defender AI recommendations:
   ```bash
   ./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
   ```
4. Test Prompt Shields against the approved test string:
   ```bash
   CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
     ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
   ```
5. Capture evidence per `verify.md`; rollback per `rollback.md` if needed.

<!-- Verified: static-only — ruff + py_compile + JSON/config invariants + optional Bicep build. Live execution is the customer's co-delivery step. -->
