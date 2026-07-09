# S1 · Identity & Access

!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · Concepts sourced from [Reference - Landscape](../reference/index.md). Entra Agent ID GA and Conditional Access for agents status in [Product Status](../reference/product-status.md).

<span class="rvas-badge rvas-persona">Identity admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with **agents governed as first-class identities** in their own tenant:

- An **inventory of agent identities** (Entra Agent ID) present in the tenant, exported to JSON.
- A **Conditional Access policy targeting agent identities**, created in **report-only** mode, exported as JSON and stored as code.
- A **human-sponsor accountability record** for each agent (who owns it, lifecycle state).

**Durable artifact:** `labs/s1-identity/` - the inventory export, the report-only Conditional Access policy JSON + creation/rollback scripts, and the sponsor register, committed to the customer's governance repo.

## 2. Prerequisites

=== "Tier A - Full production"
    - **Microsoft Entra ID P1** (Conditional Access) - **P2** recommended (ID Protection risk conditions). Targeting agent **service principals** additionally requires a **Microsoft Entra Workload ID Premium** license.
    - Roles held by the **customer's** admins (facilitator guides only): **Conditional Access Administrator** (or Security Administrator) to author policy; a **Privileged Role Administrator** on hand for exclusions.
    - At least one **Entra Agent ID** present - typically provisioned when the customer builds an agent in Copilot Studio or Microsoft Foundry (verify current provisioning behavior for your workloads).[^entra]
    - A **break-glass** account confirmed and **excluded** from the new policy.
    - Microsoft Graph PowerShell SDK (`Install-Module Microsoft.Graph`) on the operator workstation.

=== "Tier B - Baseline / simulation"
    - No P2 / no live agents required. Author the Conditional Access policy JSON **offline** and validate it statically; the inventory script runs read-only and returns an empty set (documented).
    - Policy is authored in **report-only** and left un-deployed, or deployed to a **sandbox tenant**. A "what changes at Tier A" note records the risk-based conditions you'd add with P2.

## 3. Concepts

- **Agents are identities, not app registrations.** Microsoft Entra **Agent ID** models each agent with four object types - **blueprint**, **blueprint principal**, **agent identity**, and the **agent's user account** - and requires a **human sponsor** accountable for its lifecycle.[^entra]
- **Provisioning.** Agent identities are typically created when agents are built in surfaces such as **Copilot Studio and Microsoft Foundry** - so they can appear in the tenant without a deliberate governance step. Confirm the current behavior for each surface you use; inventory is therefore the first control.[^entra]
- **Existing controls extend to agents - via the workload-identity path.** Because agents are **service principals**, Conditional Access governs them through **Workload Identity Conditional Access** (targeting service principals under `clientApplications`), not the user/group conditions used for people. Agents are non-interactive, so policy design differs (no MFA prompt; gate on network, risk, and app instead), and workload-identity CA requires a **Microsoft Entra Workload ID Premium** license. Verify the current agent-CA experience, which is still evolving.[^entra]
- **Report-only is the safe default.** A report-only Conditional Access policy logs what *would* happen without blocking anything - essential when the target is a non-interactive identity that could break automation if wrongly scoped.
- **Monitoring ≠ control.** Agents executing **on-behalf-of a user (OBO)** without their own Agent ID may be visible but not fully governable - flag these in the inventory.[^a365]

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    The Conditional Access policy created here is **report-only**. It changes **nothing** for users or agents until the customer deliberately switches it to *On* after reviewing report-only sign-in impact. Confirm the **break-glass exclusion** before creating any policy.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Identity admin</span>)* - confirm the break-glass account, change window, and approver (see [How to Deliver](../how-to-deliver.md#safety-protocol-applies-to-every-session)). Open `labs/s1-identity/rollback.md`.
2. **Connect read-only and inventory agents** - the customer runs:
   ```powershell
   ./scripts/Get-AgentIdentities.ps1 -OutFile ./evidence/agent-inventory.json
   ```
   This connects Microsoft Graph with least-privilege read scopes and exports every agent identity + its sponsor.
3. **Build the sponsor register** - for each agent in the inventory without a clear owner, record a human sponsor in `policies/sponsor-register.csv`. Agents with no sponsor are the first governance finding.
4. **Author the Conditional Access policy** - review `policies/ca-agent-baseline.json` (a Workload Identity CA policy that targets the agent **service principals** under `clientApplications`, excludes a break-glass service principal, report-only). Set `includeServicePrincipals` to the agent SP object ID(s) and `excludeServicePrincipals` to the customer's break-glass service principal.
5. **Create it report-only** - the customer runs:
   ```powershell
   ./scripts/New-AgentConditionalAccess.ps1 -PolicyFile ./policies/ca-agent-baseline.json
   ```
   The script refuses to proceed unless `state` is `enabledForReportingButNotEnforced`.
6. **Let it bake** - leave the policy in report-only. Impact is reviewed over the following days via sign-in logs before any enforcement decision (a separate, customer-owned step).

## 5. Verification & evidence capture

- [ ] `agent-inventory.json` exists and lists agent identities (or is documented empty at Tier B).
- [ ] Every inventoried agent has a sponsor in `sponsor-register.csv`.
- [ ] The Conditional Access policy exists in the tenant with state **report-only** and the break-glass **service principal excluded**.

**Evidence to capture** (into `labs/s1-identity/evidence/`): the inventory JSON, the created policy re-exported from the tenant, and a screenshot-free record (policy JSON + object IDs) of the report-only state.

```powershell
./scripts/Export-AgentConditionalAccess.ps1 -OutFile ./evidence/ca-agent-baseline.deployed.json
```

## 6. Rollback

Every change is reversible. `labs/s1-identity/rollback.md` deletes the report-only policy by display name and confirms removal:

```powershell
./scripts/Remove-AgentConditionalAccess.ps1 -DisplayName "RVAS S1 - Agent baseline (report-only)"
```

Because the policy is report-only, deleting it has **no user impact**. The inventory and sponsor register are read-only artifacts - nothing to revert.

## 7. Governance mapping

| Artifact | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|----------|-------------|---------------|-----------|
| Agent identity inventory + sponsor register | **Govern** (accountability), **Map** (inventory) | A.6 (AI system lifecycle), A.9 (access control) | Art. 14 (human oversight) |
| Conditional Access policy (report-only) | **Manage** (access risk) | A.9 (access control) | Art. 15 (access security) |
| Sign-in / report-only logs captured | **Measure** | A.10 (operations, logging) | Art. 12 (record-keeping / logging) |

Consolidated in [Reference - Governance Mapping](../reference/governance-mapping.md).

## 8. Facilitator notes

- **Timing:** ~half day. Pre-flight + concepts ~45 min, inventory + sponsor register ~60 min, policy authoring + report-only creation ~60 min, verification/evidence ~30 min.
- **RACI:** Identity admin = **R**, Governance lead = **A**, Security/SOC = **C** (sign-in risk), AI developer = **I**.
- **Common blockers:**
    - *No agents in the tenant yet* → Tier B path; author the policy offline and stage it for when agents arrive.
    - *No Entra P2* → skip risk-based conditions; document them as the Tier-A upgrade.
    - *Break-glass not identified* → **stop**; do not create any Conditional Access policy until a break-glass account is confirmed and excluded.
    - *Agents running OBO* → they won't appear as distinct identities; note them as "visible but not fully controllable" and revisit in S6.
- **Hand-off:** the inventory feeds S6 (Agent 365 registry reconciliation); the report-only policy is the customer's to promote to enforce after impact review.

[^entra]: Microsoft Learn - [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
[^a365]: Microsoft 365 Blog - *Microsoft Agent 365: the control plane for AI agents* (2025-11-18); Microsoft Learn - [Agent 365 Overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview).
