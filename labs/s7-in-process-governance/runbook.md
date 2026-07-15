# S7 Runbook — In-Process Agent Governance

## Pre-flight

- [ ] Confirm S7 is an optional adoption-decision workshop after the S0–S6 core.
- [ ] Confirm no customer source code, endpoint, tenant, or production policy will change.
- [ ] Review the pinned AGT Public Preview notice and known limitations.
- [ ] Identify the governance lead who owns the adoption decision.
- [ ] Review the illustrative deny-by-default policy in `policies/demo-policy.json`.

## Offline illustration

1. Run:
   ```bash
   python pipelines/run_mock.py
   ```
2. Confirm the output includes one `allow`, one `deny`, and one
   `approval_required` decision.
3. Verify hash-chain consistency in the generated evidence:
   ```bash
   python pipelines/run_mock.py --verify evidence/policy-decision-audit.json
   ```
4. Review the boundary: audit evidence records attempts and decisions, not
   whether an allowed downstream action succeeded.
5. Do not treat the local hash-chain result as tamper evidence. If tamper evidence
   is required, store a signed record in customer-managed immutable external
   storage under the customer's retention process.
6. Record application fit, AGT Preview risk, residual limitations, owner, and
   next review in the S6 follow-up backlog.

## Evidence and decision handoff

- [ ] The run and `--verify` command both exit `0`.
- [ ] Evidence has one allowed, one denied, and one approval-required attempt.
- [ ] Each record contains action, arguments, policy ID/version/hash, timestamp,
  previous hash, and entry hash; `hash_chain_consistency.status` is `pass`.
- [ ] The record remains labelled as an offline illustration, not AGT execution,
  downstream action success, production validation, or tamper evidence.
- [ ] The S6 follow-up backlog records the adoption decision, owner, residual
  risks, and next review. If tamper evidence is needed, it references the
  customer-managed signed/immutable external record.

## Stop conditions

Stop the workshop and record a follow-up rather than extending the demo if a
participant asks to install AGT, change customer code, use customer credentials,
or treat the simulator as production validation. Those requests require a
separate engineering and change-review path.
