# S7 Runbook — In-Process Agent Governance

## Pre-flight

- [ ] Confirm S7 is an optional adoption-decision workshop after the S0–S6 core.
- [ ] Confirm no customer source code, endpoint, tenant, or production policy will change.
- [ ] Review the pinned AGT Public Preview notice and known limitations.
- [ ] Open `rollback.md` and identify the governance lead who owns the adoption decision.
- [ ] Review the illustrative deny-by-default policy in `policies/demo-policy.json`.

## Offline illustration

1. Run:
   ```bash
   python pipelines/run_mock.py
   ```
2. Confirm the output includes one `allow`, one `deny`, and one
   `approval_required` decision.
3. Verify the generated evidence:
   ```bash
   python pipelines/run_mock.py --verify evidence/policy-decision-audit.json
   ```
4. Review the boundary: audit evidence records attempts and decisions, not
   whether an allowed downstream action succeeded.
5. Record application fit, AGT Preview risk, residual limitations, owner, and
   next review in the S6 follow-up backlog.

## Stop conditions

Stop the workshop and record a follow-up rather than extending the demo if a
participant asks to install AGT, change customer code, use customer credentials,
or treat the simulator as production validation. Those requests require a
separate engineering and change-review path.
