# S2 · Data & Compliance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Compliance / Data admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

The customer leaves with a concrete review of how data moves through one
in-scope AI scenario and whether that path is ready for classification,
report-only DLP review, and investigation. The review uses Microsoft Purview
where the tenant, workload, location, role, and license support it; unsupported
areas are recorded as gaps, not assumed coverage.

They leave with:

- A references-only data-path map for prompts, retrieval sources, tool outputs,
  generated responses, storage, and downstream sharing.
- References to reviewed DSPM for AI or related Purview findings, including
  result, no-result, unsupported, and blocked outcomes.
- A classification and exposure position for each data-path segment: labeled,
  unlabeled, overexposed, unknown, unsupported, or outside the reviewed scope.
- A customer-owned decision on whether a scoped Purview DLP change stays
  `designed`, moves to report-only change review, or is recorded as `blocked` or
  `accepted_risk`.
- Investigation-readiness references that name the route, owner, retention or
  hold dependency, and legal/compliance decision point for Audit, eDiscovery,
  Insider Risk Management, Communication Compliance, or another customer-owned
  process where applicable.
- A gateway/runtime dependency note when masking, routing, logging, or tool-call
  controls are needed outside Purview.

`labs/s2-data-compliance/` contains a facilitator review checklist and data-governance handoff. Customer evidence stays in the approved customer records system. The delivery workspace stores references, not copied evidence.

### Plain decision

**Question:** **Do we approve, defer, reject, or route the proposed data-use
decision for this data path?** Separate the decisions for data path,
classification/exposure, report-only DLP readiness, investigation route,
gateway/runtime dependency, and final decision state. Default to supported
Microsoft Purview controls and the customer change-review process. If a workload,
role, licensing, location, retention rule, or feature does not support the
proposed control, record that exception with its owner, Purview record location,
acceptance criterion, and target date; do not claim equivalent coverage. This
session does not deploy enforcement or approve production.

### What happens next

**Next customer action:** assign the selected data, classification, investigation,
or report-only change work to its customer owner before dependent platform work
continues.

S2 produces a data-governance backlog: continue without a DLP change, prepare a
report-only review, fix classification or investigation gaps, route a
gateway/data dependency to S3/S6, or block dependent work. Each backlog item
should preserve the review posture:

- **Result:** the customer can point to a supported Purview finding, label, DLP
  match, audit route, retention rule, or approved evidence record.
- **No result:** the customer reviewed the agreed scope and found no matching
  signal; record the scope and why that absence is meaningful.
- **Unsupported:** the workload, data location, role, license, or tenant
  capability does not support the expected Purview or investigation coverage.
- **Blocked:** a missing owner, approval, retention/hold path, data-path detail,
  or gateway/runtime dependency prevents a safe decision.

Blockers can include missing workload coverage, licensing, role assignment, retention, or investigation ownership.

## 2. Prerequisites

- Microsoft Purview capabilities licensed for **DSPM for AI**, sensitivity labels, DLP, Audit, eDiscovery, IRM, and Communication Compliance where needed.
- Customer admins with the right Purview roles, such as Compliance Administrator, Compliance Data Administrator, or equivalent role groups for DLP and audit export.
- A named change approver if the review recommends a policy change.
- An escalation contact for compliance decisions.
- At least one AI workload in scope, such as Microsoft 365 Copilot, Microsoft Foundry agents, Copilot Studio, Security Copilot, or approved enterprise ChatGPT connectors.
- A customer-approved place to store Purview findings, Audit/eDiscovery routes, DLP configuration records, and decisions.

## 3. Why this session matters

AI data risk is often hidden in the handoff between systems: a user prompt, a
retrieval source, a tool response, generated text, a saved transcript, or a file
shared downstream. S2 traces that path before discussing enforcement. It asks
what data is present, who owns it, how it is classified, where Purview can see
it, where a gateway or runtime control would be required, and how an
investigator would reconstruct the event without copying customer data into this
repository.

The review identifies sensitive-data exposure, available Purview coverage, and
the evidence an investigator can use. It checks classification, discovery,
sensitivity-label, DLP, audit, retention, and legal/compliance ownership before
any policy leaves simulation or report-only review.

Read the [S2 Concepts](concepts.md) for DSPM, labels and DLP, investigation evidence, and the boundary between Purview and gateway masking.

## 4. Change boundary

This kit makes no tenant changes. Any customer policy deployment, rollback, and verification stays in the customer's approved change process.
