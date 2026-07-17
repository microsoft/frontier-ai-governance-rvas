# S2 · Data & Compliance

**Facilitator deck**

Compliance / Data admin · Governance lead · 90-minute report-only review session

Note:
Welcome and framing. This is a **report-only / audit-first** session. DLP policy creation in this session is simulation/test only and must not block users or agents during the workshop. Timebox is 90 minutes. Roles in the room: facilitator, Compliance/Data administrator, governance lead or delegated risk authority, evidence owner, pilot-agent owner, and Audit/eDiscovery investigator or legal specialist.

---

## The outcome — findings become a work list

By the end, the customer has a **Microsoft Purview-based review** of AI data exposure and a decision on the next data-governance step.

- Customer-owned DLP decision
- Evidence links across labels, DLP, Audit/eDiscovery, classification, and investigation
- Backlog path: continue, report-only review, fix gaps, route dependency, or block

Note:
Keep the outcome focused on customer-owned records and decisions. Findings become a work list the customer owns, with assumptions and owners — not a policy rollout. The delivery workspace stores references, not copied evidence.

---

## Why this matters

- AI data risk is not solved by one policy.
- The customer needs to know what sensitive data is exposed.
- They need to know which Purview controls can cover it.
- Investigators need evidence they can use later.

Note:
S2 uses Microsoft Purview for data and compliance. The customer reviews classification and discovery signals, checks sensitivity-label and DLP coverage, and records the investigation route before any policy moves past simulation.

---

## Data raises its own governance question

![S2 compliance flow: DSPM for AI surfaces exposure, producing prioritised findings that drive sensitivity labels and DLP policies, which feed an evidence trail (Audit, eDiscovery, Insider Risk Management, Communication Compliance) routed to the customer compliance and change process; gateway masking complements but does not replace Purview.](../assets/diagrams/s2-compliance-flow.svg)

AI governance asks:

- Which data reaches the agent?
- Which sensitive data can appear in prompts or responses?
- Which evidence remains after an interaction?

Note:
Walk the diagram from DSPM through labels, DLP, and investigation evidence. Microsoft Purview brings data security and compliance to AI workloads and connected apps. S2 uses Purview for data classification, discovery, policy review, investigation, and evidence references. It does not build a new model gateway.

---

## DSPM for AI finds exposure before enforcement

- DSPM for AI helps surface oversharing and sensitive-data exposure.
- It can show risky access and likely ways data could leak.
- Its job is to **find** problems, not fix them.
- An empty result is still evidence — if you read it correctly.

Note:
An empty result can mean no discovered in-scope workload, no findings in the checked scope, or a prerequisite gap. Record which one the customer can support. Do not treat "nothing found" as proof of no exposure unless the scope and limits are clear.

---

## Labels and DLP turn classification into controls

- Sensitivity labels describe how data should be handled.
- DLP policies use labels or sensitive information types to govern inappropriate sharing or use.
- For AI, that can include prompts, responses, or connected workflows.
- Confirm supported workloads, locations, and conditions in the tenant.

Note:
The Co-deliver chapter uses simulation or test mode first. The customer observes matches and false positives before deciding whether enforcement is safe. Do not create or enforce a production policy in this session.

---

## Investigation needs an evidence trail

- Audit, eDiscovery, Insider Risk Management, and Communication Compliance serve different investigation needs.
- A DLP policy alone is **not** an evidence strategy.
- The customer must know logs, exports, review queues, retention rules, and owners.

Note:
Keep the investigation route explicit. The customer records route references, not content or exports. If the agreed search returns nothing, record scope, date, and reviewer. If a workload lacks the route, route the gap to the correct owner.

---

## Gateway masking complements compliance

- Purview governs data use and evidence in the tenant.
- A gateway can add a runtime pattern such as PII masking.
- Gateway masking does **not** replace classification, DLP review, or audit retention.
- A Purview policy does **not** implement a runtime gateway.

Note:
This is the cross-control guardrail. Purview and gateway controls can work together, but neither replaces the other. Gateway masking is a separate platform control and should be routed to S3 or S6 where needed.

---

## The activity — how we'll work

- **Timebox:** 90 minutes · **seven steps**
- **To start:** bounded AI path, evidence location, investigation route, decision owner.
- For a possible policy change, name the customer change approver.
- Do not start enforcement, export content, or configure a production policy.

Note:
Confirm the preconditions before continuing. The compliance administrator reviews authorized Purview evidence for the path, checks coverage, and brings a decision to the risk owner. Introduce the seven steps from evidence question through hand-off.

---

## Step 1 — Set the evidence and investigation question · 10 min

> **"For this path, what sensitive-data exposure are we trying to understand, where is the evidence, and who investigates an incident?"**

Record pilot scope, safe starting state, evidence references, owner, and stop condition.

Note:
A useful result is a bounded path and named investigation route. If there is no records location, compliance owner, or investigation owner, stop that part and assign it. Use the customer's approved system for the review checklist.

---

## Step 2 — Map the path and dependencies · 15 min

Trace inputs, retrieval sources, tools, outputs, classifications, and data locations.

> **"Where could sensitive data enter, persist, or leave?"**
> **"Which label or classification should apply?"**
> **"Which permission or runtime control changes the risk?"**

Note:
Record dependencies on labels, classification, DLP workload/location support, audit retention, eDiscovery permissions and hold process, IRM/Communication Compliance where applicable, and gateway protection as separate controls. Missing classification or unknown workload support is a finding.

---

## Step 3 — Review DSPM for AI in Purview · 20 min

The administrator reviews relevant DSPM for AI posture, recommendations, or findings for the declared scope.

> **"What does this finding actually cover?"**
> **"Which path or data source is outside it?"**
> **"What evidence lets a later reviewer understand this decision?"**

Note:
A useful result is a customer records-system reference with scope, date, reviewer, and interpretation. If there is no in-scope finding, record what was checked and do not treat it as proof of no exposure. If licensing, role, or product support blocks the review, record the dependency, owner, and target date.

---

## Step 4 — Review Purview DLP coverage · 15 min

Check the applicable DLP workload, location, condition, and tenant configuration.

> **"Can Purview DLP cover this workload and condition?"**
> **"What false positive would be unacceptable?"**
> **"Who reviews the observations?"**

Note:
A useful result is a coverage statement and one of: no DLP change, `designed`, or a customer-owned proposal for report-only review. Do not create a configuration here. Customer change control owns implementation, observation, rollback, communication, and verification.

---

## Step 5 — Review the Audit/eDiscovery investigation route · 15 min

Review which supported records and scope can locate relevant AI interactions or administrative activity.

> **"Which event or item answers the investigation question?"**
> **"What retention, permission, or legal-hold limit applies?"**
> **"Who receives and assesses a concern?"**

Note:
Record route references, not content or exports. If the agreed search returns nothing, record scope, date, and reviewer. If the workload lacks the route, retention is inadequate, or permission is missing, route it to the risk, retention, or licensing owner.

---

## Step 6 — Decide using the control tree · 10 min

Decision states:

- `designed`
- `report_only_deployed`
- `observed`
- `approved_for_enforcement`
- `enforced`
- `accepted_risk` or `blocked`

Note:
Use the control tree in order: path/owner/evidence known; DSPM or tenant review result available; DLP coverage supported; scope, approver, observation owner, safety/change plan, and investigation route ready. This session cannot advance any state to enforcement. Record only the selected control state and rationale.

---

## Step 7 — Hand off evidence and blockers · 5 min

Read back:

- DSPM, DLP, and Audit/eDiscovery references
- Interpretation and decision
- Owner and review date
- Dependencies for S3, S5, and S6

Note:
Store evidence in the customer's approved system. Capture chosen options and rationale in `templates/technical-decision-record.template.md`. Register references and retention/classification metadata in the generated workspace. For blockers, stop the dependent action and create a customer-owned backlog, change, or risk item with owner and date.

---

## Verification & evidence

- [ ] DSPM for AI finding, empty result, or unavailable capability is documented by reference.
- [ ] Any customer-applied DLP policy has a report-only/test change record.
- [ ] Audit/eDiscovery can locate AI interaction records where supported.
- [ ] IRM and Communication Compliance reviewers know where applicable alerts appear.
- [ ] The decision separates useful, empty, unsupported, and blocked results.
- [ ] Each checked scope, evidence reference, owner, and review date is recorded.

Note:
Capture references to the DSPM for AI review, DLP policy/change record where applicable, policy match summary after observation, audit/eDiscovery review, and named approver/owner. Keep these in the approved customer records system. Register only references in the generated delivery workspace.

---

## Change boundary & hand-off

- This kit makes **no tenant changes**.
- Policy deployment, rollback, and verification stay in the customer's approved change process.
- Findings feed **S3** security posture, **S5** adversarial-testing evidence, and **S6** reconciliation.

Note:
Close with the guardrails. When stuck: unavailable DSPM for AI, unsupported DLP coverage, missing Audit/eDiscovery route, or inadequate retention → document source and scope, route to the named owner, and keep the control `blocked` or `accepted_risk`.
