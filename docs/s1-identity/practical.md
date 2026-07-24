# Practical activity: confirm one agent owner

## What you will do

Use a customer-approved identity or agent source to review one in-scope agent
and confirm its human sponsor, lifecycle state, and coverage limits.

## Before you start

- Confirm an identity administrator, governance lead, approved source, and
  approved records location.
- Select one bounded agent population. Do not export credentials, personal data,
  or raw tenant records to this repository.
- Stop if the source cannot support the claimed agent-to-owner relationship.

## Customer-operated activity

1. The identity administrator opens the customer-approved source, such as the
   relevant Entra or workload administration experience.
2. The customer records a reference to the source, what it covers and excludes,
   the human sponsor, and the lifecycle decision in
   `labs/s1-identity/templates/identity-inventory-review.template.md`.
3. Resolve or assign one missing-owner, source-coverage, or lifecycle gap.

## What good looks like

One agent has a named accountable person and an honest statement of the source
coverage. A source that cannot make that link is a gap, not an inventory.

## If the environment is not ready

Complete the review from an approved source reference and mark the exact access
or coverage prerequisite that prevents confirmation.

## Keep and hand over

Keep the customer-held inventory reference and decision. Hand access, RBAC,
OBO, Conditional Access, or lifecycle work to the customer identity process.
