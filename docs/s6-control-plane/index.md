# S6 · Control Plane & Operationalization

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Security / SOC</span>

## 1. Outcome & durable artifact

The customer leaves with an owned operating closeout:

- a read-only reconciliation of its normalized control-plane registry and the
  explicit S1 Entra Agent ID inventory;
- the S0 baseline-to-S6 exit maturity comparison; and
- a decision-ready residual-gap backlog with owners, due dates, and status.

Durable artifact: `labs/s6-control-plane/` - explicit input schemas,
read-only reconciliation tooling, and the closeout templates. Customer evidence
remains in the approved customer records system and is referenced, not
committed to this repository.

## 2. Prerequisites

- The S0 baseline scorecard and a customer-produced S1 normalized identity
  inventory using the S1 kit's explicit schema.
- A customer-normalized registry using
  `rvas.s6.control-plane-registry.v1`; `agent-registry.sample.json` is the
  safe, explicit example.
- Governance lead empowered to assign owners, decisions, and review dates.
- An approved customer records-system location for the closeout evidence.

## 3. Why this session

Governance becomes operational when known agents, identities, ownership,
lifecycle state, and unresolved gaps can be reconciled into one accountable
record. S6 uses explicit field mappings so a mismatch becomes a finding instead
of a guessed match.

Read the [S6 Concepts](concepts.md) for reconciliation, lifecycle ownership,
and the boundary between visibility and governance.

## 4. Co-delivery walkthrough

!!! warning "Read-only reconciliation"
    This kit does not export from a product API or write lifecycle, ownership,
    or access metadata. The customer uses its supported product process to
    obtain source data, then normalizes it before S6.

1. **Set the inputs** *(facilitator + <span class="rvas-badge rvas-persona">Governance lead</span>)* -
   confirm the S0 baseline, unmodified S1 inventory, evidence-reference
   location, and closeout approver.
2. **Normalize the registry** - prepare the customer registry with the explicit
   schema in `labs/s6-control-plane/data/agent-registry.sample.json`. Each
   record declares `entraObjectId`; S6 never matches on display name or aliases.
3. **Reconcile** - run:
   ```bash
   python labs/s6-control-plane/scripts/reconcile-registry.py \
     --registry labs/s6-control-plane/evidence/control-plane-registry.json \
     --inventory labs/s1-identity/evidence/agent-inventory.json \
     --out labs/s6-control-plane/evidence/reconciliation-report.json
   ```
4. **Triage gaps** - assign an owner and action for shadow, registry-only,
   unmanaged/OBO, sponsor, and lifecycle findings. Do not change the registry
   in this workshop.
5. **Re-run the S0 instrument** - follow
   `labs/s6-control-plane/assessment/exit-rescore.md` and retain the mandatory
   baseline-to-exit comparison.
6. **Close out** - complete
   `labs/s6-control-plane/assessment/closeout-backlog.md` in the customer's
   approved records system.

## 5. Verification & evidence capture

- [ ] Registry, S1 inventory, reconciliation report, baseline scorecard, exit
  scorecard, and maturity-lift output have customer records-system references.
- [ ] The report documents matches by Entra object ID only and preserves all
  unmatched records as findings.
- [ ] Every residual finding has a decision, owner, due date, and status.
- [ ] The governance lead has recorded a closeout decision, approver, and next
  governance review.

## 6. Change boundary

S6 makes no registry or tenant changes. Any customer registry update follows
the customer's supported product procedure and separate approved change,
rollback, and verification process.

## 7. Facilitator notes

- **Timing:** ~half day. Input validation + normalization ~45 min,
  reconciliation ~45 min, ownership review ~60 min, exit re-score + closeout
  ~60 min.
- **RACI:** Governance lead = R/A; Identity admin = C for S1 inventory;
  Security/SOC = C for unmanaged/OBO risk; AI developer/maker = C for
  provenance.
- **Common blockers:** a missing S1 inventory, incomplete normalized registry,
  or absent owner becomes a residual gap. Do not infer a match or improvise an
  API export.
- **Close the loop:** the S0 comparison and owned backlog provide the capstone
  decision package.
