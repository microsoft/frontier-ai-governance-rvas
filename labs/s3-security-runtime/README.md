# S3 Takeaway Kit — Security Posture & Runtime

Builds an audit-first security baseline for AI workloads: Defender for Cloud AI-SPM exports, AI Threat Protection status capture, and Prompt Shields testing through AI Hub Gateway / Citadel Governance Hub.

This kit does not deploy runtime safety infrastructure. Content Safety / Prompt Shields are owned by Citadel Governance Hub; RVAS verifies and captures evidence from that path.

The live export and non-production test scripts are customer-operated evidence
capture. Their output is ignored by Git and must remain in the customer's
approved records system.

## Contents

```
scripts/
  test_prompt_shield.sh       calls Content Safety Prompt Shields with a test string
  export_defender_ai_recommendations.sh read-only Defender AI recommendation export
policies/
  content-safety-runtime-baseline.json   runtime safety baseline placeholders
  defender-ai-assessment-export-template.json Defender evidence schema/template
pipelines/
  run_mock.py                 static safety/config validation, no network
evidence/                     ignored customer-captured output, exports, Prompt Shield results
runbook.md  rollback.md  verify.md
```

## Prerequisites

- Azure CLI logged in to the customer subscription.
- Security/SOC permissions for Defender for Cloud exports.
- AI Hub Gateway / Citadel Governance Hub deployed, with gateway endpoint and Prompt Shields / Content Safety configuration available.
- A customer-owned non-production test endpoint/string for runtime checks.

## Run order

1. Capture the Citadel Governance Hub gateway endpoint and Content Safety / Prompt Shields configuration.
2. Export Defender AI recommendations:
   ```bash
   ./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
   ```
3. Test Prompt Shields against the approved test string through the Citadel gateway / configured Content Safety endpoint:
   ```bash
   CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
     ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
   ```
4. Capture evidence per `verify.md`; rollback per `rollback.md` if needed.

<!-- Verified: static-only — ruff + py_compile + JSON/config invariants. Live execution is the customer's co-delivery step. -->
