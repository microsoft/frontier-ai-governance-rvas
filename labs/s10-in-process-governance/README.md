# S10 Takeaway Kit — In-Process Agent Governance

An offline, dependency-free facilitator-led activity for deciding whether to
investigate in-process agent governance further. It illustrates tool-policy
decisions and hash-chain consistency, modelling a governance pattern described
by AGT without installing, invoking, or validating AGT.

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
2. Follow [`runbook.md`](runbook.md) for applicability, policy review, the
   illustration, limitation interpretation, blocker pathways, and the
   reference-only adoption-decision handoff.

Use
[`templates/applicability-review.template.md`](templates/applicability-review.template.md)
in the approved customer records system to record whether an in-process
tool-call decision point is meaningful and what evidence a future engineering
assessment would need.

The audit record shows governance attempts and decisions only. It does not
attest to downstream tool execution, action success, or tamper evidence. Tamper
evidence requires customer-managed signed and immutable external storage.
