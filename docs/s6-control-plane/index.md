# S6 · Control Plane & Operationalization

!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · Concepts sourced from [Reference — Landscape](../reference/index.md). Agent 365 status and pricing must be re-verified in [Product Status](../reference/product-status.md) before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Security / SOC</span>

## 1. Outcome & durable artifact

The customer leaves with the capstone operating view for AI-agent governance:

- An **agent registry reconciliation** that compares Microsoft Agent 365's control-plane registry with the S1 Entra Agent ID inventory, including **shadow agents**, OBO agents, unmanaged agents, missing owners, and lifecycle state.
- The **S6 exit maturity re-score**: the same S0 assessment re-run after S1-S6, showing measurable lift versus the baseline and a residual-gap backlog.
- A named operational owner and lifecycle state for every known agent, so the registry becomes the single source of truth rather than another dashboard.

**Durable artifact:** `labs/s6-control-plane/` — registry export/reference script, offline reconciliation tooling, evidence templates, and the exit re-score runbook committed to the customer's governance repo.

## 2. Prerequisites

=== "Tier A — Full production"
    - Microsoft Agent 365 licensed and available in the tenant — **GA May 1, 2026**, approximately **$15/user/month** *(publicly announced — verify current before delivery)*.[^a365]
    - Customer admin/operator with permissions to export the Agent 365 registry and read Entra Agent ID inventory data.
    - Completed S1 inventory export or sponsor register available for reconciliation.
    - Governance lead empowered to assign lifecycle state and accountable owner for each finding.
    - A pre-agreed evidence location: `labs/s6-control-plane/evidence/`.

=== "Tier B — Baseline / simulation"
    - No Agent 365 license required. Reconcile the S1 Entra Agent ID inventory, maker/admin workshop inputs, and any known agent lists into a registry spreadsheet.
    - Use `labs/s6-control-plane/data/agent-registry.sample.json` and the offline reconciliation script to rehearse the method.
    - Document "what changes at Tier A": replace the spreadsheet with the Agent 365 registry export and repeat the same reconciliation/evidence steps.

## 3. Concepts

- **Agent 365 is the enterprise control plane.** At launch Microsoft described capability areas including **Registry, Access Control, Visualization, Interoperability, and Security**; Microsoft Learn also frames the work as **Observe / Govern / Secure**. Treat the exact pillar list as evolving and verify against current docs.[^a365]
- <span class="rvas-badge rvas-ga">GA</span> **Agent 365 GA:** May 1, 2026. Pricing has been publicly announced around **$15/user/month**; always verify current licensing before a customer delivery.[^a365]
- <span class="rvas-badge rvas-preview">Preview</span> Some Agent 365 expansion capabilities, such as AI teammate experiences and cross-cloud registry sync, may still be preview; do not make them delivery prerequisites.[^a365]
- **Five pillars, not six.** Microsoft Entra Agent ID is the identity technology under **Access Control** and **Security** — not a separate Agent 365 pillar.[^entra]
- <span class="rvas-badge rvas-ga">GA</span> **Entra Agent ID** provides first-class agent identities with human sponsors and lifecycle governance. The S6 registry must reconcile back to the S1 inventory.[^entra]
- **Monitoring ≠ control.** Agents executing **on-behalf-of a user (OBO)** without their own Entra Agent ID may be visible in telemetry but **not fully controllable**. The registry must flag them for remediation.[^a365]
- **Shadow agents** are agents not yet represented in the registry. Discovery and reconciliation are pillar 1's job: if the S1 inventory, maker list, or workshop identifies an agent absent from Agent 365, it becomes a shadow-agent finding.

## 4. Co-delivery walkthrough

!!! warning "Read-only reconciliation first"
    Start with export and reconciliation only. Do **not** write lifecycle metadata, ownership changes, or access controls until the customer reviews the findings, names an approver, and confirms rollback for any registry writes.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Governance lead</span>)* — confirm Agent 365 availability or Tier B spreadsheet path, evidence folder, approver, and the S0 baseline score location. Open `labs/s6-control-plane/rollback.md`.
2. **Pull the registry** — Tier A customer operator exports Agent 365 registry data:
   ```powershell
   ./scripts/Get-AgentRegistry.ps1 -OutFile ./evidence/agent-registry.json
   ```
   Tier B uses the workshop registry spreadsheet converted to JSON/CSV and records the source.
3. **Reconcile S1 inventory** — compare the registry with the S1 Entra Agent ID inventory:
   ```bash
   python labs/s6-control-plane/scripts/reconcile-registry.py \
     --registry labs/s6-control-plane/evidence/agent-registry.json \
     --inventory labs/s1-identity/evidence/agent-inventory.json
   ```
4. **Identify gaps** — review shadow agents, unmanaged/OBO agents, missing sponsors, and registry-only records that need owner confirmation.
5. **Assign lifecycle state + owner** — mark each known agent as proposed, active, exception, suspended, retired, or decommissioned, and assign a human sponsor/accountable owner.
6. **Re-run the assessment** — copy the S0 scorecard, fill the S6 exit scores, and run:
   ```bash
   python labs/s0-foundations/assessment/score.py labs/s6-control-plane/evidence/exit-scorecard.csv
   ```
7. **Create the residual-gap backlog** — domains still below target maturity become the post-workshop backlog for the AI CoE / governance board.

## 5. Verification & evidence capture

- [ ] `evidence/agent-registry.json` or the Tier B registry spreadsheet/export is captured.
- [ ] `evidence/reconciliation-report.json` exists and lists shadow agents, unmanaged/OBO agents, missing sponsors, and lifecycle gaps.
- [ ] `evidence/exit-scorecard.csv` and the `score.py` terminal output are stored as the S6 exit score.
- [ ] Lift versus the S0 baseline is documented per domain D0-D6, with residual gaps assigned to owners.

Evidence belongs in `labs/s6-control-plane/evidence/` so it can be reviewed without screenshots and committed or archived according to the customer's governance-record policy.

## 6. Rollback

S6 begins read-only. Registry exports, reconciliation reports, and maturity scorecards are documents — rollback is deleting or superseding the local evidence files.

If the customer later writes lifecycle state, owner, or access-control metadata back into Agent 365, those writes must be approved separately and are reversible by restoring the previous registry values from the captured export.

## 7. Governance mapping

| Artifact | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|----------|-------------|---------------|-----------|
| Agent 365 registry + capstone re-score | **Govern**, **Manage** | A.2, A.3, A.10 | Art. 72 (post-market monitoring) |
| Shadow/OBO residual-gap backlog | **Map**, **Manage** | A.6, A.10 | Art. 72 (post-market monitoring) |

Consolidated in [Reference — Governance Mapping](../reference/governance-mapping.md).

## 8. Facilitator notes

- **Timing:** ~half day. Concepts + pre-flight ~30 min, registry export/reconciliation ~75 min, lifecycle ownership workshop ~60 min, exit re-score + backlog ~60 min, evidence hand-off ~15 min.
- **RACI:** Governance lead = **R/A**; Identity admin = **C** for Entra Agent ID inventory; Security/SOC = **C** for unmanaged/OBO risk; AI developer / maker = **C** for agent provenance; executive sponsor = **I**.
- **Common blockers:**
    - *No Agent 365 license* → Tier B path: reconcile S1 inventory + workshop inputs in the registry spreadsheet.
    - *S1 inventory missing* → use maker/admin inputs for the workshop, but record this as a D1/D6 residual gap.
    - *OBO agents only* → mark them "visible but not fully controllable" and add migration to Entra Agent ID as the backlog action.
    - *No accountable owner* → do not mark the agent operationally complete; missing sponsor is a governance finding.
- **Close the loop:** S6 proves the lift opened in S0 by re-running the exact same seven-domain, 1-4 maturity instrument and turning remaining gaps into an owned backlog.

[^a365]: Microsoft Learn — [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview); Microsoft 365 Blog — *Microsoft Agent 365: the control plane for AI agents* (2025-11-18); Microsoft Security Blog — *Agent 365 now generally available* (2026-05-01).
[^entra]: Microsoft Learn — [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
