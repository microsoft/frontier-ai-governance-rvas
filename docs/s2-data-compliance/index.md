# S2 · Data & Compliance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Compliance / Data admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

The customer leaves with a Microsoft Purview-based data-exposure review and a
decision on the next data-governance step.

They leave with:

- References to reviewed DSPM for AI findings, including empty results, unavailable capabilities, or licensing gaps.
- A customer-owned decision on whether a scoped Purview DLP change stays `designed`, moves to report-only change review, or is recorded as `blocked` or `accepted_risk`.
- Evidence and decision references that connect Purview sensitivity labels, DLP, Audit/eDiscovery, classification, and investigation ownership.

`labs/s2-data-compliance/` contains a facilitator review checklist and data-governance handoff. Customer evidence stays in the approved customer records system. The delivery workspace stores references, not copied evidence.

### Plain decision

**Question:** **Do we approve, defer, reject, or route the proposed data-use
enforcement decision?** Default to supported Microsoft Purview controls and the
customer change-review process. If a workload, role, licensing, retention, or
feature does not support the proposed control, record that exception with its
owner, Purview record location, acceptance criterion, and target date; do not claim
equivalent coverage. This session does not deploy enforcement or approve production.

### What happens next

**Next customer action:** assign the selected data, classification, investigation,
or report-only change work to its customer owner before dependent platform work
continues.

S2 produces a data-governance backlog: continue without a DLP change, prepare a
report-only review, fix classification or investigation gaps, route a
gateway/data dependency to S3/S6, or block dependent work.

Blockers can include missing workload coverage, licensing, role assignment, retention, or investigation ownership.

## 2. Prerequisites

- Microsoft Purview capabilities licensed for **DSPM for AI**, sensitivity labels, DLP, Audit, eDiscovery, IRM, and Communication Compliance where needed.
- Customer admins with the right Purview roles, such as Compliance Administrator, Compliance Data Administrator, or equivalent role groups for DLP and audit export.
- A named change approver if the review recommends a policy change.
- An escalation contact for compliance decisions.
- At least one AI workload in scope, such as Microsoft 365 Copilot, Microsoft Foundry agents, Copilot Studio, Security Copilot, or approved enterprise ChatGPT connectors.
- A customer-approved place to store Purview findings, Audit/eDiscovery routes, DLP configuration records, and decisions.

## 3. Why this session matters

The review identifies sensitive-data exposure, available Purview coverage, and
the evidence an investigator can use. It checks classification, discovery,
sensitivity-label, and DLP coverage before any policy leaves simulation.

Read the [S2 Concepts](concepts.md) for DSPM, labels and DLP, investigation evidence, and the boundary between Purview and gateway masking.

## 4. Change boundary

This kit makes no tenant changes. Any customer policy deployment, rollback, and verification stays in the customer's approved change process.
