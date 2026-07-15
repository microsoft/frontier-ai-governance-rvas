# S7 Takeaway Kit — In-Process Agent Governance

An offline, dependency-free illustration of tool-policy decisions and
hash-chain consistency. It models the governance pattern described by AGT
without installing, invoking, or validating AGT.

## Contents

```
policies/
  demo-policy.json                  illustrative deny-by-default policy
pipelines/
  run_mock.py                       offline decision and hash-chain simulator
evidence/
  .gitkeep                          generated customer evidence is ignored
runbook.md                           run, verification, and decision handoff
```

## Prerequisites

- Python 3.11+.
- No network, cloud service, Azure subscription, AGT package, customer source
  code, credentials, or endpoint is required.

## Run order

1. Review `policies/demo-policy.json`; it is illustrative and not a customer
   deployment policy.
2. Follow [`runbook.md`](runbook.md) to run the illustration, verify
   hash-chain consistency, and record the adoption decision.

The audit record shows governance attempts and decisions only. It does not
attest to downstream tool execution, action success, or tamper evidence. Tamper
evidence requires customer-managed signed and immutable external storage.
