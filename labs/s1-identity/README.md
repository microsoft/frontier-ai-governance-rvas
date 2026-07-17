# S1 Takeaway Kit — Identity & Ownership Review

This kit supports one safe, customer-operated action: review an
administrator-sourced identity inventory, assign accountable ownership, and
hand off a decision. It does not discover identities, query a tenant, export
records, create Conditional Access, supply a break-glass design, or make any
tenant change.

Start with [runbook.md](runbook.md). Copy
[`templates/identity-inventory-review.template.md`](templates/identity-inventory-review.template.md)
to the customer's approved records system before entering any information, and
[`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md)
to record the chosen identity path and runtime-access option, rationale, and
adoption stage. Keep
inventory data, object identifiers, sponsor details, exports, and evidence only
in the customer's approved records system or generated delivery workspace.

## Supported-admin-source boundary

Use a current, customer-authorized administrative source for the workload in
scope: an available Microsoft Entra Agent ID/governance experience, the
workload's supported administration experience, or a customer-controlled
authoritative inventory. Record the source, workload coverage, review date, and
known exclusions with the customer record.

Do **not** infer an Agent ID inventory by listing service principals and matching
names or tags. A service-principal, managed-identity, OBO, or application
inventory can be useful corroborating context, but it is not proof that an
identity is an Entra Agent ID and does not establish complete workload coverage.

## Identity inventory schema

The inventory is a customer record, not an export in this repository. For each
reviewed entry, use this schema in the customer system:

| Field | Meaning |
|---|---|
| Record and source reference | Customer record ID plus the authoritative source and export/view reference |
| Source coverage | Workload, scope, known exclusions, and statement of what the source can support |
| Identity classification | `Agent ID`, service principal, managed identity, OBO, or another customer-defined type |
| Identity and workload reference | Customer-safe identifier or link, display name, and platform/workload |
| Accountable sponsor | Human owner responsible for business purpose, lifecycle, and access justification |
| Lifecycle and purpose | Proposed, active, suspended, retired, and the approved business purpose |
| Access context and risk references | Whether activity is user-delegated or agent-operated; links to customer permission, risk, exception, or change records |
| Authority boundary | Tool or action scope, accountable approver, and material changes that require reapproval |
| Review metadata | Reviewer, review date, finding, decision state, and next review date |

Conditional Access design, break-glass exclusions, and any enforcement decision
remain with the customer's approved identity-change process; this kit provides
no deployable policy or template for them.
