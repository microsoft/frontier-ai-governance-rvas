# S7 Takeaway Kit — In-Process Agent Governance

An offline, dependency-free illustration of tool-policy decisions and a
tamper-evident decision record. It models the governance pattern described by
AGT without installing, invoking, or validating AGT.

## Contents

```
policies/
  demo-policy.json                  illustrative deny-by-default policy
pipelines/
  run_mock.py                       offline decision and audit-chain simulator
evidence/
  .gitkeep                          generated customer evidence is ignored
runbook.md  rollback.md  verify.md
```

## Prerequisites

- Python 3.11+.
- No network, cloud service, Azure subscription, AGT package, customer source
  code, credentials, or endpoint is required.

## Run order

1. Review `policies/demo-policy.json`; it is illustrative and not a customer
   deployment policy.
2. Run the simulation:
   ```bash
   python labs/s7-in-process-governance/pipelines/run_mock.py
   ```
3. Verify the resulting audit-chain record:
   ```bash
   python labs/s7-in-process-governance/pipelines/run_mock.py \
     --verify labs/s7-in-process-governance/evidence/policy-decision-audit.json
   ```
4. Capture the adoption decision per `verify.md`.

The audit record shows governance attempts and decisions only. It does not
attest to downstream tool execution or action success.

<!-- Verified: static-only — ruff + py_compile + offline mock pipeline + audit integrity verification. -->
