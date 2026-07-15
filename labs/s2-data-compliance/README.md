# S2 Takeaway Kit — Data & Compliance Review

This kit helps a facilitator and customer compliance team make a decision about
data exposure for one representative AI-agent path. It intentionally does **not**
contain an export script, a deployable Purview policy, tenant IDs, or a fake
Purview configuration schema.

Microsoft Purview capabilities and supported workload coverage change. Use the
customer's current Purview experience and approved operating procedures to
review DSPM for AI, DLP, Audit, and eDiscovery. Store exports and investigation
records only in the customer's approved records system.

## What this kit contains

- [`runbook.md`](runbook.md) - entry point for the customer-operated review.
- [`review-checklist.md`](review-checklist.md) - facilitator-ready review,
  evidence-reference, decision, and handoff checklist.

## Prerequisites

- Compliance/Data administrator, governance lead, and the owner of the pilot
  agent path.
- Confirmed Purview licensing and workload coverage for the intended DSPM for
  AI, DLP, Audit, and eDiscovery capabilities.
- An approved customer records-system location for evidence references and a
  named change approver if a policy change is proposed.

## Run order

1. Use the checklist to scope the pilot agent, data flows, and investigation
   owner.
2. Review the supported Purview signals and findings in the customer tenant.
3. Record references to the customer-owned findings, policy definition, and
   audit/eDiscovery review in the generated delivery workspace's evidence
   register.
4. Decide whether to remain **designed**, proceed to a customer-owned
   **report-only** change, or record a **blocked** or **accepted-risk** outcome.

This session never deploys, reverses, or validates a Purview policy. Any
customer policy change follows the customer's standard change, rollback, and
verification process.
