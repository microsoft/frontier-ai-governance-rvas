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
- A customer-approved place to store evidence references and decisions.

## 3. Why this session matters

The review identifies sensitive-data exposure, available Purview coverage, and
the evidence an investigator can use. It checks classification, discovery,
sensitivity-label, and DLP coverage before any policy leaves simulation.

Read the [S2 Concepts](concepts.md) for DSPM, labels and DLP, investigation evidence, and the boundary between Purview and gateway masking.

## 4. Detailed facilitation reference

!!! warning "Report-only / audit-first"
    DLP policy creation in this session is **simulation/test only**. It must not block users or agents during the workshop. Promotion to enforcement is a separate, customer-owned change after findings review, legal/compliance approval, and communications.

**Timebox:** 90 minutes. **Roles:** facilitator, Compliance/Data administrator, governance lead or delegated risk authority, evidence owner, pilot-agent owner, and Audit/eDiscovery investigator or legal specialist. **To start:** you need one bounded AI path, an approved evidence location, a named investigation route, and a decision owner. For a possible policy change, you also need the customer change approver. Do not start enforcement, export content, or configure a production policy in this session.

**Customer action:** the compliance administrator reviews authorized Purview
evidence for the path, checks coverage, and brings a decision to the risk owner.

Read [Technical decisions](technical.md) first. It covers data-classification,
PII-handling, and compliance options and selection criteria.

1. **Set the evidence and investigation question** *(10 min)* - the facilitator asks: **"For this path, what sensitive-data exposure are we trying to understand, where is the evidence, and who investigates an incident?"** The customer records the pilot scope, safe starting state, evidence references, owner, and stop condition in `labs/s2-data-compliance/review-checklist.md` in its approved system. A useful result is a bounded path and named investigation route. If there is no records location, compliance owner, or investigation owner, stop that part and assign it.
2. **Map the path and dependencies** *(15 min)* - the pilot owner traces inputs, retrieval sources, tools, outputs, classifications, and data locations. The facilitator asks: **"Where could sensitive data enter, persist, or leave?"**, **"Which label or classification should apply?"**, and **"Which permission or runtime control changes the risk?"** Record dependencies on labels, classification, DLP workload/location support, audit retention, eDiscovery permissions and hold process, IRM/Communication Compliance where applicable, and gateway protection as separate controls. A missing classification or unknown workload support is a finding.
3. **Review DSPM for AI in Purview** *(20 min)* - the Compliance/Data administrator uses the current supported Purview experience to review relevant DSPM for AI posture, recommendations, or findings for the declared scope. The facilitator asks: **"What does this finding actually cover?"**, **"Which path or data source is outside it?"**, and **"What evidence lets a later reviewer understand this decision?"** A useful result is a customer records-system reference with scope, date, reviewer, and interpretation. If there is no in-scope finding, record what was checked and do not treat it as proof of no exposure. If licensing, role, or product support blocks the review, record the dependency, owner, and target date.
4. **Review Purview DLP coverage** *(15 min)* - the customer checks the applicable DLP workload, location, sensitive information type or sensitivity label condition, and tenant configuration. The facilitator asks: **"Can Purview DLP cover this workload and condition?"**, **"What false positive would be unacceptable?"**, and **"Who reviews the observations?"** A useful result is a coverage statement and one of: no DLP change, `designed`, or a customer-owned proposal for report-only review. Do not create a configuration here. DLP simulation mode supports observing likely impact without enforcement. Customer change control owns implementation, observation, rollback, communication, and verification.
5. **Review the Audit/eDiscovery investigation route** *(15 min)* - the investigator and administrator review which supported Audit records and eDiscovery scope can locate the relevant AI interactions or administrative activity. The facilitator asks: **"Which event or item answers the investigation question?"**, **"What retention, permission, or legal-hold limit applies?"**, and **"Who receives and assesses a concern?"** Record route references, not content or exports. If the agreed search returns nothing, record scope, date, and reviewer. If the workload lacks the route, retention is inadequate, or permission is missing, route it to the risk, retention, or licensing owner.
6. **Decide using the control tree** *(10 min)* - the decision owner uses this tree, in order:

   ```text
   Is the path, owner, and evidence location known?
     No → blocked: assign dependency; do not propose a policy.
     Yes → Does DSPM for AI/tenant review produce a scoped finding or documented empty result?
       No, unavailable/unsupported → accepted_risk or blocked; assign review/alternative control.
       Yes → Is DLP coverage supported for the workload, location, and condition?
         No → no DLP change; record gap and assess classification, access, retention, or gateway dependency.
         Yes → Are scope, approver, observation owner, safety/change plan, and investigation route ready?
           No → designed; close prerequisites.
           Yes → customer may submit a separate report-only change for approval.
   ```

   The decision picks the technical-decision options that fit: for classification and sensitivity handling, PII and retrieval governance, and compliance and residency mapping. Base it on the evidence scope, the coverage that is actually supported, classification and access dependencies, whether investigation is ready, who has the authority to decide, and whether the change is safe. Record only the selected control state: `designed`, `report_only_deployed`, `observed`, `approved_for_enforcement`, `enforced`, `accepted_risk`, or `blocked`. This session cannot advance any state to enforcement.
7. **Hand off evidence and blockers** *(5 min)* - the facilitator reads back the DSPM, DLP, and Audit/eDiscovery references; the interpretation; the decision; the owner; the review date; and dependencies for S3, S5, and S6. Store evidence in the customer's approved system. Capture the chosen options and rationale in `templates/technical-decision-record.template.md`. Register references and retention/classification metadata in the generated workspace. For blockers, stop the dependent action and create a customer-owned backlog, change, or risk item with owner and date.

## 5. Verification & evidence capture

- [ ] A customer records-system reference documents DSPM for AI findings, an empty result, or an unavailable-capability/licensing outcome.
- [ ] If the customer independently applies a DLP policy, its own change record documents report-only/test state and the observation period.
- [ ] Audit/eDiscovery search can locate AI interaction records where the tenant supports them.
- [ ] IRM and Communication Compliance reviewers know where AI interaction alerts appear where those products apply.
- [ ] The decision record separates a useful result from an empty result, unsupported capability, or blocked dependency.
- [ ] Each checked scope, evidence reference, owner, and review date is recorded.

Capture references to the DSPM for AI review, DLP policy/change record where applicable, policy match summary after observation, audit/eDiscovery review, and named approver/owner. Keep these in the approved customer records system. Register only references in the generated delivery workspace.

## 6. Change boundary

This kit makes no tenant changes. Any customer policy deployment, rollback, and verification stays in the customer's approved change process.
