# S6 · Control Plane & Operationalization

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Security / SOC</span>

## 1. Outcome & durable artifact

The customer leaves with the capstone operating view for AI-agent governance:

- An **agent registry reconciliation** that compares Microsoft Agent 365's control-plane registry with the S1 Entra Agent ID inventory, including shadow agents, OBO agents, unmanaged agents, missing owners, and lifecycle state.
- The S6 exit maturity re-score: the same S0 assessment re-run after S1-S6 to compare the current state with the baseline and produce a residual-gap backlog.
- A named operational owner and lifecycle state for every known agent, maintained through a reviewed registry process rather than an unmanaged dashboard.

Durable artifact: `labs/s6-control-plane/` - registry export/reference script, offline reconciliation tooling, evidence templates, and the exit re-score runbook committed to the customer's governance repo.

## 2. Prerequisites

- Microsoft Agent 365 licensed and available in the tenant - GA May 1, 2026, approximately $15/user/month *(publicly announced - verify current before delivery)*.[^a365]
- Customer admin/operator with permissions to export the Agent 365 registry and read Entra Agent ID inventory data.
- Completed S1 inventory export or sponsor register available for reconciliation.
- Governance lead empowered to assign lifecycle state and accountable owner for each finding.
- A pre-agreed evidence location: `labs/s6-control-plane/evidence/`.

## 3. Why this session

Governance becomes operational only when the customer can reconcile its known agents, sponsors, lifecycle state, and unresolved gaps into one accountable record. S6 brings the registry and identity views together, re-runs the baseline, and turns residual gaps into an owned backlog.

Read the [S6 Concepts](concepts.md) for control-plane reconciliation, lifecycle ownership, shadow and OBO agents, and Citadel's adjacent registry view.

## 4. Co-delivery walkthrough

!!! warning "Read-only reconciliation first"
    Start with export and reconciliation only. Do **not** write lifecycle metadata, ownership changes, or access controls until the customer reviews the findings, names an approver, and confirms rollback for any registry writes.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Governance lead</span>)* - confirm Agent 365 availability, evidence folder, approver, and the S0 baseline score location. Open `labs/s6-control-plane/rollback.md`.
2. **Pull the registry** - the customer operator exports Agent 365 registry data:
   ```powershell
   ./scripts/Get-AgentRegistry.ps1 -OutFile ./evidence/agent-registry.json
   ```
3. **Add gateway registry evidence when present** - if the customer has a pre-provisioned AI Hub Gateway / Citadel Governance Hub, capture API Center / Access Contract evidence as an adjacent Layer 1 input. Do not deploy the hub during S6; record the export or customer-provided artifact alongside the Agent 365 registry.
4. **Reconcile S1 inventory** - compare the registry with the S1 Entra Agent ID inventory:
   ```bash
   python labs/s6-control-plane/scripts/reconcile-registry.py \
     --registry labs/s6-control-plane/evidence/agent-registry.json \
     --inventory labs/s1-identity/evidence/agent-inventory.json
   ```
5. **Identify gaps** - review shadow agents, unmanaged/OBO agents, missing sponsors, and registry-only records that need owner confirmation.
6. **Assign lifecycle state + owner** - mark each known agent as proposed, active, exception, suspended, retired, or decommissioned, and assign a human sponsor/accountable owner.
7. **Re-run the assessment** - copy the S0 scorecard, fill the S6 exit scores, and run:
   ```bash
   python labs/s0-foundations/assessment/score.py labs/s6-control-plane/evidence/exit-scorecard.csv
   ```
8. **Create the residual-gap backlog** - domains still below target maturity become the post-workshop backlog for the AI CoE / governance board.

## 5. Verification & evidence capture

- [ ] `evidence/agent-registry.json` is captured.
- [ ] `evidence/reconciliation-report.json` exists and lists shadow agents, unmanaged/OBO agents, missing sponsors, and lifecycle gaps.
- [ ] `evidence/exit-scorecard.csv` and the `score.py` terminal output are stored as the S6 exit score.
- [ ] Changes from the S0 baseline are documented per domain D0-D6, with residual gaps assigned to owners.

Evidence belongs in `labs/s6-control-plane/evidence/` so it can be reviewed without screenshots and committed or archived according to the customer's governance-record policy.

## 6. Rollback

S6 begins read-only. Registry exports, reconciliation reports, and maturity scorecards are documents - rollback is deleting or superseding the local evidence files.

If the customer later writes lifecycle state, owner, or access-control metadata back into Agent 365, those writes must be approved separately and are reversible by restoring the previous registry values from the captured export.

## 7. Facilitator notes

- **Timing:** ~half day. Session context + pre-flight ~30 min, registry export/reconciliation ~75 min, lifecycle ownership workshop ~60 min, exit re-score + backlog ~60 min, evidence hand-off ~15 min.
- **RACI:** Governance lead = R/A; Identity admin = C for Entra Agent ID inventory; Security/SOC = C for unmanaged/OBO risk; AI developer / maker = C for agent provenance; executive sponsor = I.
- **Common blockers:**
    - *No Agent 365 license* → stop S6 live delivery and route licensing / registry readiness to the prerequisite backlog.
    - *Citadel Governance Hub already deployed* → do not re-deploy it in S6. Capture API Center / Access Contract evidence as a Layer 1 input and reconcile it against Agent 365 / Entra Agent ID records.
    - *S1 inventory missing* → use maker/admin inputs for the workshop, but record this as a D1/D6 residual gap.
    - *OBO agents only* → mark them "visible but not fully controllable" and add migration to Entra Agent ID as the backlog action.
    - *No accountable owner* → do not mark the agent operationally complete; missing sponsor is a governance finding.
- **Close the loop:** S6 re-runs the same seven-domain, 1-4 maturity instrument, records the change from S0, and assigns the remaining gaps.

[^a365]: Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview); Microsoft 365 Blog - *Microsoft Agent 365: the control plane for AI agents* (2025-11-18); Microsoft Security Blog - *Agent 365 now generally available* (2026-05-01).
