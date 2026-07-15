# S1 · Identity & Ownership Review

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Identity admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with an identity-inventory review and ownership decision:

- A customer-owned inventory review from an authoritative administrator source,
  including its workload coverage and known limitations.
- A human sponsor and lifecycle decision for each reviewed in-scope identity.
- Evidence and decision references in the customer records system or generated
  delivery workspace.

`labs/s1-identity/` contains the review runbook only. It does not contain
identity discovery, exports, Conditional Access definitions, break-glass
templates, or customer records.

### Identity inventory schema

The customer inventory records a customer record/source reference, workload
coverage and exclusions, identity classification, identity/workload reference,
accountable sponsor, lifecycle and purpose, access context and authority
boundary, access/risk references, and review metadata (reviewer, date, finding,
decision, and next review date). The
customer records actual identifiers and personal data only in its approved
system.

## 2. Prerequisites

- A customer identity administrator who can use an authorized administrative
  source for the workload in scope.
- A customer-approved records-system location for inventory, evidence, and
  decisions.
- A named governance lead to accept source-coverage limitations and ownership
  findings.

This session does not require or validate Conditional Access licensing,
break-glass design, Graph PowerShell, or a particular Entra Agent ID
provisioning path.

## 3. Why this session

An agent cannot be governed reliably until the customer can identify its
authoritative source, name its human sponsor, and state the inventory's
coverage. S1 establishes that evidence and decision boundary without claiming
that a generic directory search is a complete Agent ID inventory.

Read the [S1 Concepts](concepts.md) for Agent ID, authoritative-source
boundaries, ownership, OBO, and gateway-boundary context.

## 4. Co-delivery walkthrough

!!! warning "Review-only boundary"
    This session creates no policy and makes no tenant change. Do not use a
    service-principal name/tag match as Agent ID discovery, and do not copy
    identity data or evidence into this repository.

**Timebox:** 90 minutes. **Roles:** facilitator, identity administrator
(customer activity owner), governance lead (decision owner), evidence owner,
and security reviewer. **Entry condition:** a bounded workload, a
customer-authorized source, a customer records location, and a governance lead
are present. Without a source or decision owner, stop the affected activity and
record the dependency; do not substitute a directory query.

**Purposeful customer action:** the identity administrator reviews a real
customer-held inventory boundary, then the governance lead decides how to
handle coverage and ownership gaps.

1. **Set the question and source boundary** *(15 min)* — facilitator asks:
   “What population can this source authoritatively describe?” and “What
   cannot it prove?” The customer identifies the workload, source, coverage,
   exclusions, evidence reference, and stop condition. A meaningful result is
   a source-coverage statement; a source with no applicable records is a
   no-result only when its checked scope and date are recorded. An unavailable
   supported source is unsupported/blocked, not permission to infer Agent ID
   status.
2. **Customer-led inventory review** *(35 min)* — the identity administrator
   reviews each in-scope record in the approved system using the schema above.
   The facilitator asks, “Who is accountable for purpose and lifecycle?”,
   “What evidence ties this identity to the workload?”, and “When is the next
   review?” **Meaningful result:** classification, sponsor, lifecycle, source
   reference, and finding are reviewable. **No-result:** no entry for the
   declared scope, recorded with source/date/reviewer. **Unsupported:** the
   source cannot expose a needed attribute, captured as a coverage limitation.
   **Blocked:** access, owner, or authorized source is absent; stop that
   population and assign the dependency.
3. **Interpret corroboration correctly** *(15 min)* — customer may compare
   service-principal, managed-identity, OBO, or application context, but the
   facilitator asks, “Does this prove Agent ID status or only corroborate?” and
   “Is the activity user-delegated or agent-operated?” Record corroboration,
   authority scope, and their limits. OBO visibility is not a distinct Agent ID
   inventory entry unless the supported source says so.
4. **Make the ownership decision** *(15 min)* — governance lead decides to
   remediate a missing sponsor/lifecycle, accept a bounded residual risk,
   defer, or mark the source coverage blocked. Criteria: authoritative source
   coverage, attributable sponsor, lifecycle clarity, access-risk context, and
   customer authority. Record the inventory/source reference, decision, owner,
   approver, and review date; never copy identifiers or exports here.
5. **Hand off without designing controls** *(10 min)* — facilitator reads back
   the control state (`observed`, `accepted_risk`, or `blocked`), evidence
   reference, next owner, and S6 reconciliation dependency. Conditional
   Access, break-glass, remediation, or enforcement requests go to the
   customer identity-change process. If no decision owner attended, mark the
   decision deferred with owner/date.

## 5. Verification & evidence capture

- [ ] The customer inventory identifies its authoritative source, workload
  coverage, known exclusions, and review date.
- [ ] Every reviewed in-scope identity has an identity classification, sponsor,
  lifecycle state, access context, authority boundary, and finding or decision.
- [ ] Ownership, residual-risk, and source-coverage decisions have an owner,
  approver, and next review date.
- [ ] Each no-result, unsupported capability, and blocker identifies the scope
  checked, evidence reference, owner, and review date.

Register only the customer inventory reference and its
retention/classification metadata in `04-operate/evidence-register.json` and
the related decision in `04-operate/decision-register.json` in the generated
delivery workspace. Do not add inventory data, object IDs, exports, or policy
evidence to Git.

## 6. Change boundary

This kit makes no tenant changes. The customer's identity-change process owns
any Conditional Access, break-glass, access-remediation, rollback, verification,
and evidence-retention activity.

## 7. Facilitator notes

- **Blocker path:** no authoritative source → record its coverage gap; no
  sponsor → create an ownership finding; OBO → classify as visibility unless
  the supported source states otherwise. Assign owner/date and resume only
  when the dependency is resolved.
- **Official context:** [manage agent identities](https://learn.microsoft.com/en-us/entra/agent-id/manage-agent-identities-admin)
  and [manage owners and sponsors](https://learn.microsoft.com/en-us/entra/agent-id/manage-owners-sponsors-agents)
  describe product capabilities. They support terminology and do not replace
  the customer’s source-coverage evidence.
- **Hand-off:** the customer-owned inventory reference and coverage statement
  inform S6 reconciliation; remediation decisions remain customer-owned.

[^entra]: Microsoft Learn - [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
