# Practical activity: test one representative policy decision

## What you will do

Customer engineering owners use the local simulator to see how one
representative tool-call policy decision is allowed, denied, or sent for
approval.

## Before you start

- Confirm a meaningful tool-call boundary, governance lead, engineering owner,
  and approved records location.
- Use only the supplied illustration or sanitized representative details. Do
  not use customer source code, credentials, tenant data, or production policy.
- Stop and mark S10 not applicable if no meaningful in-process decision exists.

## Customer-operated activity

1. Review the applicability boundary in
   `labs/s10-in-process-governance/templates/applicability-review.template.md`.
2. Run the supplied illustration:
   ```bash
   python labs/s10-in-process-governance/pipelines/run_mock.py
   python labs/s10-in-process-governance/pipelines/run_mock.py --verify \
     labs/s10-in-process-governance/evidence/policy-decision-audit.json
   ```
3. Confirm the expected allow, deny, and approval-required decisions, then
   discuss which existing controls still apply.

## What good looks like

The simulator demonstrates the supplied local policy and an internally
consistent audit record. It does not prove AGT compatibility, downstream
execution, tamper evidence, or production suitability.

## If the environment is not ready

Use the same local illustration; this activity deliberately has no tenant
dependency.

## Keep and hand over

Keep the applicability decision and safe references in customer records. Hand
any future engineering assessment to the policy owner and customer SDLC process.
