# S2 · Data & Compliance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Compliance / Data admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with a decision-ready review of AI data exposure in Microsoft Purview:

- References to reviewed DSPM for AI findings, including an empty-result,
  unavailable-capability, or licensing-gap outcome where applicable.
- A customer-owned decision on whether a scoped DLP change should remain
  designed, proceed to report-only change review, or be recorded as blocked or
  accepted risk.
- Evidence and decision references connecting Purview Audit/eDiscovery,
  classification, investigation ownership, and any proposed control change.

Durable artifact: `labs/s2-data-compliance/` - a facilitator review checklist
and data-governance handoff. Customer evidence remains in the approved customer
records system and is referenced, not copied, into the delivery workspace.

### Implementation pathway

S2 produces a data-governance implementation backlog for later customer-owned
work. The recommendation should state whether to continue without a DLP change,
prepare a report-only Purview DLP change review, remediate classification or
audit/eDiscovery gaps, route a gateway/data-boundary dependency to S3/S6, or
block dependent work because workload coverage, licensing, role, retention, or
investigation ownership is missing.

## 2. Prerequisites

- Microsoft Purview capabilities licensed for **DSPM for AI**, DLP, Audit, eDiscovery, IRM, and Communication Compliance.
- Roles held by the customer's admins (facilitator guides only): Compliance Administrator, Compliance Data Administrator, or equivalent Purview role groups for DLP and audit export.
- A named change approver if the review recommends a policy change. Break-glass
  is not directly in scope for DLP, but an escalation contact must be available.
- At least one AI workload in scope, such as Microsoft 365 Copilot, Microsoft Foundry agents, Copilot Studio, Security Copilot, or approved enterprise ChatGPT connectors.

## 3. Why this session

AI data risk cannot be managed by a single policy: the customer needs visibility into exposure, a safe way to test controls, and evidence that investigators can use later. S2 establishes that compliance-plane evidence before any DLP rule is promoted beyond simulation.

Read the [S2 Concepts](concepts.md) for DSPM, labels and DLP, investigation evidence, and the boundary between Purview and gateway masking.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    DLP policy creation in this session is **simulation/test only**. It must not block users or agents during the workshop. Promotion to enforcement is a separate, customer-owned change after findings review, legal/compliance approval, and communications.

**Timebox:** 90 minutes. **Roles:** facilitator (method and evidence boundary),
Compliance/Data administrator (customer activity owner), governance lead or
delegated risk authority (decision owner), evidence owner, pilot-agent owner,
and Audit/eDiscovery investigator or legal specialist. **Entry condition:** one
bounded, representative AI path; customer-approved evidence location; named
investigation route; and a decision owner. For a possible policy change, also
name the customer change approver. Do not start a policy configuration, export,
or enforcement activity in this session.

**Purposeful customer action:** the compliance administrator reviews live,
customer-authorized Purview evidence for the path, validates what coverage and
investigation route actually exist, and brings a decision—not a portal tour—to
the decision owner.

1. **Set the evidence and investigation question** *(10 min)* — facilitator
   asks: “For this path, what sensitive-data exposure are we trying to
   understand, where is the authoritative evidence, and who investigates an
   incident?” The customer records the pilot scope, safe posture, evidence
   references, owner, and stop condition in
   `labs/s2-data-compliance/review-checklist.md` in its approved system.
   **Meaningful result:** a bounded path and named investigation route.
   **Blocked:** no approved records location, compliance activity owner, or
   investigation owner—stop the dependent review and assign it. Do not use a
   demo, mock, or facilitator note as evidence.
2. **Customer maps the path and dependencies** *(15 min)* — the pilot owner
   traces inputs, retrieval sources, tools, outputs, applicable classifications,
   and data locations. Facilitator asks, “Where could sensitive data enter,
   persist, or leave?”, “Which label/classification is expected?”, and “Which
   upstream permission or runtime control changes the risk?” Record
   dependencies on labels/classification, DLP workload/location support, audit
   retention, eDiscovery permissions/hold process, IRM/Communication
   Compliance where applicable, and gateway protection as separate controls.
   A missing classification or unknown workload support is a finding, not an
   assumed match.
3. **Customer-led DSPM for AI review** *(20 min)* — the Compliance/Data
   administrator uses the current supported Purview experience to review
   relevant DSPM for AI posture, recommendations, or findings for the
   declared scope. Facilitator asks, “What does this finding actually cover?”,
   “Which path or data source does it not cover?”, and “What evidence lets a
   later reviewer reproduce this interpretation?” **Meaningful result:** a
   customer records-system reference plus scope, date, reviewer, and
   interpretation. **No-result:** no in-scope finding after the stated scope
   was reviewed; record that it is not proof of no exposure. **Unsupported:**
   the product/workload is not supported for the intended review; record the
   documented limitation. **Blocked:** licensing, role, or prerequisite
   prevents review; record the dependency, owner, and target date. Do not
   invent coverage from an empty dashboard.
4. **Review DLP coverage; choose no change or report-only review** *(15 min)*
   — customer confirms applicable DLP workload, location, data type/sensitivity
   label condition, and the candidate path through current supported
   documentation and tenant configuration. Facilitator asks, “Can this policy
   cover this workload and condition?”, “What false positive would be
   unacceptable?”, and “Who evaluates observations?” A meaningful result is a
   coverage statement and one of: no DLP change, `designed`, or a
   customer-owned proposal for `report_only_deployed`. A configuration is
   **not** created here. No applicable workload or condition is a no-result
   only when documented; an unsupported workload or unavailable license is
   unsupported/blocked. DLP simulation mode supports observing potential
   impact without enforcement; customer change control owns any subsequent
   implementation, observation period, rollback, communication, and
   verification.
5. **Review the Audit/eDiscovery investigation route** *(15 min)* — the
   investigator and administrator review which supported Audit records and
   eDiscovery scope can locate the relevant AI interactions or administrative
   activity for this workload. Facilitator asks, “Which event or item answers
   the investigation question?”, “What retention, permissions, and legal-hold
   constraints apply?”, and “Who receives and assesses a concern?” Record
   references to the route, not content or exports. **Meaningful result:** a
   named route, responsible role, scope/retention limitation, and evidence
   reference. **No-result:** the agreed search was reviewed but returns no
   relevant item—record scope/date/reviewer, not a control pass. **Unsupported
   or blocked:** the workload lacks the route, retention is inadequate, or
   permission is missing—route to the risk, retention, or licensing owner.
6. **Decide using the control tree** *(10 min)* — decision owner uses this
   tree, in order:

   ```text
   Is the path, owner, and evidence location known?
     No → blocked: assign dependency; do not propose a policy.
     Yes → Does DSPM for AI/tenant review produce a scoped finding or documented no-result?
       No, unavailable/unsupported → accepted_risk or blocked; assign review/alternative control.
       Yes → Is DLP coverage supported for the workload, location, and condition?
         No → no DLP change; record gap and assess classification, access, retention, or gateway dependency.
         Yes → Are scope, approver, observation owner, safety/change plan, and investigation route ready?
           No → designed; close prerequisites.
           Yes → customer may submit a separate report-only change for approval.
   ```

   The decision criteria are evidence scope and quality, supported coverage,
   classification and access dependencies, investigation readiness, customer
   authority, and change safety. Record only the selected control state:
   `designed`, `report_only_deployed`, `observed`,
   `approved_for_enforcement`, `enforced`, `accepted_risk`, or `blocked`.
   This session cannot advance any state to enforcement.
7. **Evidence handoff and blocker path** *(5 min)* — facilitator reads back
   the DSPM, DLP, and Audit/eDiscovery evidence references; result/no-result/
   unsupported/blocked interpretation; decision; owner; review date; and
   dependencies for S3, S5, and S6. Store evidence in the customer’s approved
   system; register references and retention/classification metadata in the
   generated workspace. For blockers, stop the dependent action, create a
   customer-owned backlog/change/risk item with owner and date, and return only
   after it is resolved.

## 5. Verification & evidence capture

- [ ] A customer records-system reference documents DSPM for AI findings, an
  empty result, or an unavailable-capability/licensing outcome.
- [ ] If the customer independently applies a DLP policy, its own change record
  documents report-only/test state and the observation period.
- [ ] Audit/eDiscovery search can locate AI interaction records where the tenant supports them.
- [ ] IRM and Communication Compliance reviewers know where AI interaction alerts will appear.
- [ ] The decision record distinguishes a meaningful result from a no-result,
  unsupported capability, and blocked dependency, including the checked scope,
  evidence reference, owner, and review date.

Evidence references to capture: DSPM for AI findings review, DLP policy/change
record where applicable, policy match summary after observation, audit/eDiscovery
review, and named approver/owner. Keep these in the approved customer records
system; register references in the generated delivery workspace.

## 6. Change boundary

This kit makes no tenant changes. Any customer policy deployment, rollback, and
verification remain in the customer's approved change process.

## 7. Facilitator notes

- **Current official context:** validate support and terminology against
  [DSPM for AI](https://learn.microsoft.com/en-us/purview/dspm-for-ai),
  [Purview data protections for AI](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview),
  [DLP simulation mode](https://learn.microsoft.com/en-us/purview/dlp-simulation-mode-learn),
  [DLP for Microsoft 365 Copilot and Copilot Chat](https://learn.microsoft.com/en-us/purview/dlp-microsoft365-copilot-location-learn-about),
  [Audit for Copilot and AI applications](https://learn.microsoft.com/en-us/purview/audit-copilot), and
  [eDiscovery of AI data](https://learn.microsoft.com/en-us/purview/edisc-search-copilot-data).
  These sources establish available product capabilities; tenant evidence
  establishes the customer result.
- **Cross-control guardrail:** Purview DLP does not replace sensitivity-label
  governance, source permissions, audit retention, investigation process, or a
  runtime gateway. Gateway masking is a separate platform control and must not
  be claimed as Purview DLP coverage.
- **Blocker path:** unavailable DSPM for AI, unsupported DLP coverage, missing
  Audit/eDiscovery route, or inadequate retention → document source/scope,
  route to the named licensing, risk, retention, or platform owner, and keep
  the control `blocked` or `accepted_risk`. A request to enforce immediately
  stops at the separate customer change process.
- **Hand-off:** findings feed S3 security posture, S5 adversarial-testing
  evidence, and S6 control-plane reconciliation.
