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
accountable sponsor, lifecycle and purpose, access/risk references, and review
metadata (reviewer, date, finding, decision, and next review date). The
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

1. **Define the source boundary** *(facilitator + <span class="rvas-badge rvas-persona">Identity admin</span>)* - select a customer-authorized Entra Agent ID/governance experience, supported workload administration experience, or customer authoritative inventory. Record what workloads it covers and what it cannot confirm.
2. **Perform the safe inventory review** - the identity administrator reviews customer-held records for each in-scope entry: source reference, identity classification, workload, accountable sponsor, lifecycle, purpose, access/risk references, reviewer, and next review date.
3. **Treat corroborating sources correctly** - a service-principal, managed-identity, OBO, or application inventory is not by itself an Entra Agent ID inventory. Record it only as corroborating context and retain the coverage limitation.
4. **Make the ownership decision** - record missing sponsors, uncertain lifecycle, unsupported sources, and residual access risk with an accountable owner and approver.
5. **Hand off change work** - Conditional Access, break-glass, access remediation, or enforcement questions go to the customer's approved identity-change process. This kit supplies no policy or template.

## 5. Verification & evidence capture

- [ ] The customer inventory identifies its authoritative source, workload
  coverage, known exclusions, and review date.
- [ ] Every reviewed in-scope identity has an identity classification, sponsor,
  lifecycle state, and finding or decision.
- [ ] Ownership, residual-risk, and source-coverage decisions have an owner,
  approver, and next review date.

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

- **Timing:** ~half day. Source boundary + session context ~45 min, inventory
  review + sponsor assignment ~60 min, ownership decisions ~60 min, evidence
  reference + handoff ~30 min.
- **RACI:** Identity admin = R, Governance lead = A, Security/SOC = C (sign-in risk), AI developer = I.
- **Common blockers:**
    - *No authoritative source for the workload* → record the coverage gap; do
      not infer an Agent ID inventory from tags or names.
    - *No sponsor* → record an ownership finding and assign a decision owner.
    - *Agents running OBO* → classify them as OBO visibility, not as distinct
      Agent ID inventory entries, unless the supported source says otherwise.
    - *Customer asks for Conditional Access or break-glass design* → hand it to
      the customer's identity-change process; S1 supplies no policy template.
- **Hand-off:** the customer-owned inventory reference and coverage statement
  inform S6 reconciliation; remediation decisions remain customer-owned.

[^entra]: Microsoft Learn - [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
