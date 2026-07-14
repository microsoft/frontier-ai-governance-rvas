# S1 · Identity & Access

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Concepts sourced from [Reference - Landscape](../reference/index.md). Entra Agent ID GA and Conditional Access for agents status in [Product Status](../reference/product-status.md).

<span class="rvas-badge rvas-persona">Identity admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with agents governed as first-class identities in their own tenant:

- An **inventory of agent identities** (Entra Agent ID) present in the tenant, exported to JSON.
- A Conditional Access policy definition targeting agent identities in report-only mode, ready for the customer's approved change process.
- A human-sponsor accountability record for each agent (who owns it, lifecycle state).

Durable artifact: `labs/s1-identity/` - the inventory export, report-only Conditional Access policy definition, and sponsor register. Customer evidence remains local and is not committed to this repository.

## 2. Prerequisites

- **Microsoft Entra ID P1** (Conditional Access) - P2 recommended (ID Protection risk conditions). Targeting agent service principals additionally requires a Microsoft Entra Workload ID Premium license.
- Roles held by the customer's admins (facilitator guides only): Conditional Access Administrator (or Security Administrator) to author policy; a Privileged Role Administrator on hand for exclusions.
- At least one **Entra Agent ID** present - typically provisioned when the customer builds an agent in Copilot Studio or Microsoft Foundry (verify current provisioning behavior for your workloads).[^entra]
- A **break-glass** account confirmed and excluded from the new policy.
- Microsoft Graph PowerShell SDK (`Install-Module Microsoft.Graph`) on the operator workstation.

## 3. Why this session

An agent cannot be governed reliably until the customer can identify it, name its human sponsor, and observe how a proposed access policy would affect it. S1 creates that evidence first and keeps Conditional Access in report-only mode while the customer learns its impact.

Read the [S1 Concepts](concepts.md) for Agent ID, workload-identity Conditional Access, report-only policy, OBO, and gateway-boundary context.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    The Conditional Access policy created here is **report-only**. It changes nothing for users or agents until the customer deliberately switches it to *On* after reviewing report-only sign-in impact. Confirm the break-glass exclusion before creating any policy.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Identity admin</span>)* - confirm the break-glass account, change window, and approver (see [How to Deliver](../how-to-deliver.md#safety-protocol-applies-to-every-session)). Open `labs/s1-identity/rollback.md`.
2. **Connect read-only and inventory agents** - the customer runs:
   ```powershell
   ./scripts/Get-AgentIdentities.ps1 -OutFile ./evidence/agent-inventory.json
   ```
   This connects Microsoft Graph with least-privilege read scopes and exports every agent identity + its sponsor.
3. **Build the sponsor register** - for each agent in the inventory without a clear owner, record a human sponsor in `policies/sponsor-register.csv`. Agents with no sponsor are the first governance finding.
4. **Author the Conditional Access policy** - review `policies/ca-agent-baseline.json` (a Workload Identity CA policy that targets the agent service principals under `clientApplications`, excludes a break-glass service principal, report-only). Set `includeServicePrincipals` to the agent SP object ID(s) and `excludeServicePrincipals` to the customer's break-glass service principal.
5. **Hand it off for customer-owned change** - this kit intentionally does not create or remove tenant policy. The customer may apply the reviewed definition through its approved change process, retaining `enabledForReportingButNotEnforced` and the break-glass exclusion.
6. **Let it bake** - if the customer applies the policy, leave it in report-only. Impact is reviewed over the following days via sign-in logs before any enforcement decision.

## 5. Verification & evidence capture

- [ ] `agent-inventory.json` exists and lists agent identities.
- [ ] Every inventoried agent has a sponsor in `sponsor-register.csv`.
- [ ] If independently applied by the customer, the Conditional Access policy is **report-only** and excludes the break-glass service principal.

Evidence to capture (into `labs/s1-identity/evidence/`): the inventory JSON, the created policy re-exported from the tenant, and a screenshot-free record (policy JSON + object IDs) of the report-only state.

```powershell
./scripts/Export-AgentConditionalAccess.ps1 -OutFile ./evidence/ca-agent-baseline.deployed.json
```

## 6. Customer-owned rollback

This kit makes no tenant changes. If the customer independently applies a report-only policy, its approved change process owns reversal and confirmation. The inventory and sponsor register are read-only artifacts - nothing to revert in the tenant.

## 7. Facilitator notes

- **Timing:** ~half day. Pre-flight + session context ~45 min, inventory + sponsor register ~60 min, policy authoring + report-only creation ~60 min, verification/evidence ~30 min.
- **RACI:** Identity admin = R, Governance lead = A, Security/SOC = C (sign-in risk), AI developer = I.
- **Common blockers:**
    - *No agents in the tenant yet* → stop S1 live delivery and route agent onboarding / Citadel deployment readiness to the prerequisite backlog.
    - *No Entra P2* → skip risk-based conditions; document them as the Tier-A upgrade.
    - *Break-glass not identified* → **stop**; do not create any Conditional Access policy until a break-glass account is confirmed and excluded.
    - *Agents running OBO* → they won't appear as distinct identities; note them as "visible but not fully controllable" and revisit in S6.
    - *Customer asks how Entra governs access through an APIM AI gateway* → keep S1 focused on Agent ID inventory and report-only CA, then point the platform team to the Citadel Governance Hub [Entra ID auth validation](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/entraid-auth-validation.md) and [JWT client identity & permissions](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/jwt-client-identity-permissions.md) guides.
- **Hand-off:** the inventory feeds S6 (Agent 365 registry reconciliation); the report-only policy is the customer's to promote to enforce after impact review.

[^entra]: Microsoft Learn - [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
