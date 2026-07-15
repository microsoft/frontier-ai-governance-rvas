# S2 · Data & Compliance

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

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

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Compliance / Data admin</span>)* - confirm the pilot agent, Purview roles, evidence-reference location, and change approver if a policy change may be proposed.
2. **Scope the data path** - use `labs/s2-data-compliance/review-checklist.md` to record the pilot agent's inputs, retrieval sources, tools, outputs, classifications, and accountable owner.
3. **Review tenant evidence** - use the supported Purview experience to review DSPM for AI, DLP workload coverage, Audit, and eDiscovery. Record customer records-system references, including empty-result, unavailable-capability, or licensing-gap outcomes.
4. **Make the control decision** - determine whether a candidate control remains designed, is ready for customer report-only change review, is blocked, or is accepted risk. Do not create a policy from this kit.
5. **Hand off** - record the decision, owners, review date, and evidence references in the generated delivery workspace. A customer-owned policy change follows the customer's separate change, rollback, and verification process.

## 5. Verification & evidence capture

- [ ] A customer records-system reference documents DSPM for AI findings, an
  empty result, or an unavailable-capability/licensing outcome.
- [ ] If the customer independently applies a DLP policy, its own change record
  documents report-only/test state and the observation period.
- [ ] Audit/eDiscovery search can locate AI interaction records where the tenant supports them.
- [ ] IRM and Communication Compliance reviewers know where AI interaction alerts will appear.

Evidence references to capture: DSPM for AI findings review, DLP policy/change
record where applicable, policy match summary after observation, audit/eDiscovery
review, and named approver/owner. Keep these in the approved customer records
system; register references in the generated delivery workspace.

## 6. Change boundary

This kit makes no tenant changes. Any customer policy deployment, rollback, and
verification remain in the customer's approved change process.

## 7. Facilitator notes

- **Timing:** ~half day. Pre-flight + data-path scoping ~45 min, Purview review ~60 min, control decision ~60 min, evidence and backlog handoff ~30 min.
- **RACI:** Compliance/Data admin = R, Governance lead = A, Security/SOC = C (IRM/Communication Compliance), AI developer = I.
- **Common blockers:**
    - *DSPM for AI not licensed* → record the gap and route licensing to the prerequisite backlog. *No findings* → record the empty-result reference.
    - *Policy owner asks to enforce immediately* → **stop**; a policy change must follow the customer's report-only observation and approval process.
    - *Customer asks about PII masking before the LLM call* → keep the S2 DLP simulation in scope, then point the platform team to the Citadel Governance Hub [PII masking guide](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/pii-masking-apim.md) for gateway-layer anonymization/deanonymization.
    - *Audit retention insufficient* → document the gap and route to the governance backlog.
- **Hand-off:** findings feed S3 security posture, S5 adversarial testing evidence, and S6 control-plane reconciliation.
