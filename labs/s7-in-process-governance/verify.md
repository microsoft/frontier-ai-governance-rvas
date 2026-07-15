# S7 Verify & Capture Evidence

## Verify

- [ ] `python pipelines/run_mock.py` exits `0`.
- [ ] `python pipelines/run_mock.py --verify evidence/policy-decision-audit.json` exits `0`.
- [ ] Evidence has one allowed, one denied, and one approval-required attempt.
- [ ] Each record contains action, arguments, policy ID/version/hash, timestamp,
  previous hash, and entry hash.
- [ ] `integrity_verification.status` is `pass`.
- [ ] The record's `outcome_attestation` remains `not_available`.
- [ ] The S6 follow-up backlog records the adoption decision, owner, and next review.

## Capture evidence

Archive:

- `evidence/policy-decision-audit.json`;
- the approved or reviewed policy version;
- the adoption decision and residual-risk notes; and
- the pinned AGT source revision and status confirmation used for the workshop.

Do not describe the generated evidence as AGT execution, downstream action
success, certification, or an official AGT–Citadel integration.
