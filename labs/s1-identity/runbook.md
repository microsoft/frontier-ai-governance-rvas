# S1 Runbook

> **Boundary:** this is an inventory-review and ownership-decision session. It
> does not use a heuristic discovery query, create a Conditional Access policy,
> validate a break-glass configuration, or retain customer evidence in Git.

## 1. Establish scope and source

- [ ] Identify the workload and customer identity administrator responsible for
  the review.
- [ ] Select the customer-authorized administrative source and record its
  workload coverage, limitations, and review date in the customer record.
- [ ] Do not treat a general service-principal listing, a tag/name match, or an
  unsupported API result as an Agent ID inventory.

## 2. Perform the one safe customer-operated action

The customer identity administrator reviews its authoritative inventory using
the schema in [README.md](README.md#identity-inventory-schema). For every
in-scope identity, the administrator confirms or records the identity
classification, accountable human sponsor, lifecycle state, purpose, source
reference, and unresolved ownership or access finding.

This review may use customer tooling and customer records, but no export,
identity data, object ID, or sponsor information is copied into this repository.

## 3. Decide and hand off

- [ ] Record the inventory review reference, source-coverage statement,
  accountable owner, and review date in
  `04-operate/evidence-register.json` in the generated delivery workspace.
- [ ] Record each ownership, lifecycle, residual-risk, or coverage decision
  with its owner, approver, and next review date in
  `04-operate/decision-register.json`.
- [ ] Hand any Conditional Access, break-glass, access-remediation, or
  unsupported-source question to the customer's approved identity-change
  process. That process owns design, implementation, rollback, verification,
  and evidence retention.
