# Implementation artifacts

This module keeps these files after delivery.

- `model-approval-register.json` records why each model is approved: its publisher, asset ID, source
  category, hosting route, approved deployment types, processing location, use-case boundary,
  approvers, and review date. Azure Policy stores the allowed values but not the reasoning behind
  them, so this file is the only place that reasoning lives.
- `policy/model-governance.bicep` assigns the two built-in Foundry model-deployment policies at the
  approved resource group.
- `policy/model-governance.bicepparam` reads the allowed publishers, asset IDs, effect, and
  eligibility toggles straight from the register, so the assignment cannot drift from the approval
  decision.

Resolve the `__REQUIRED_*__` values in the approved private configuration path. Do not add tenant
IDs, subscription IDs, or credentials to these files. The two policy definition IDs come from
environment variables at deployment time.
