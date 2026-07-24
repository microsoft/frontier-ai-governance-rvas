# S2 Takeaway Kit: Data & Compliance Review

This kit helps a facilitator and customer compliance team make a decision about
data exposure for one representative AI-agent path. It intentionally does **not**
contain an export script, a deployable Purview policy, tenant IDs, or a fake
Purview configuration schema.

Microsoft Purview capabilities and supported workload coverage change. Use the
customer's current Purview experience and approved operating procedures to
review DSPM for AI, DLP, Audit, and eDiscovery. Store exports and investigation
records only in the customer's approved records system.

## What this kit contains

- **Start with [`review-checklist.md`](review-checklist.md).** It is the
  customer-operated runbook, including the facilitated review, evidence
  references, decision, and handoff checklist.
- [`runbook.md`](runbook.md) is retained only for existing links and points to
  the checklist.
- [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md) - records the chosen option, alternatives, rationale, owner, and adoption stage.

## Prerequisites

- Compliance/Data administrator, governance lead, and the owner of the pilot
  agent path.
- Confirmed Purview licensing and workload coverage for the intended DSPM for
  AI, DLP, Audit, and eDiscovery capabilities.
- An approved customer records-system location for evidence references and a
  named change approver if a policy change is proposed.

## Run order

1. Set the bounded path, approved evidence location, and investigation owner.
2. Map input, retrieval, tool, output, classification, and control
   dependencies.
3. Customer reviews scoped DSPM for AI evidence and records a result,
   documented no-result, unsupported capability, or blocker.
4. Customer confirms DLP coverage and decides no change, **designed**, or a
   customer-owned **report-only** change review.
5. Customer reviews the Audit/eDiscovery investigation route, scope, retention,
   and owner.
6. Decision owner uses the checklist decision tree, records the technical
   decision in `templates/technical-decision-record.template.md`, then hands
   evidence references, state, owner, date, and any platform, tool/API, or
   runtime-assurance dependencies to their owners.

This session never deploys, reverses, or validates a Purview policy. Any
customer policy change follows the customer's standard change, rollback, and
verification process.
