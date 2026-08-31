# Microsoft Agent 365 onboarding and access boundaries

## Session scope

### What we will do

Prepare one approved nonproduction Agent Registry deployment for a named Microsoft Entra test
group. Keep the agent uninstalled in this session. Session 10 confirms the DLP policy, then uses
this contract for installation and access checks.

The repository keeps the contract the administrator uses after DLP confirmation.

### Why it matters

Agent Registry is an inventory entry. Group installation decides who can use the agent. Keeping a
recorded test-group deployment uninstalled preserves that boundary until DLP coverage exists.

### Boundaries

This session covers one Agent Registry-listed agent, one nonproduction test group, and one host
product. It leaves the underlying agent, tenant-wide blocks, and Conditional Access unchanged.

Microsoft Agent 365 and Microsoft 365 admin center remain authoritative for inventory, installation,
consent, and user availability. Microsoft Entra remains authoritative for group membership and
agent identity. [Session 07](../../07-apim-ai-gateway/implementation/README.md) controls API
ingress for the Foundry route. [Session 10](../../10-purview-data-governance/implementation/README.md)
adds Purview data controls.

## Architecture

### Architecture at a glance

The Microsoft 365 administrator records the approved Agent Registry entry, Microsoft Entra
security group, host product, and consent decision. The agent remains uninstalled. Session 10
installs it after DLP coverage is enabled and propagated.

Agent Registry records the agent and its availability. Microsoft Entra records group membership.
Session 06 keeps the post-DLP deployment decision in the repository. The agent runtime stays in
its native service.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Deployment audience | One existing Microsoft Entra test group | Defines the post-DLP pilot population | Entra administrators manage membership, and the delivery owner approves a larger pilot | The delivery owner approves a larger pilot |
| Permission grant | Record the reviewed consent decision for the post-DLP deployment | Connects the decision to the exact pilot deployment | New permissions require another review | The agent's permission request changes |
| Agent scope | Prepare one Agent Registry entry for one host product and keep it uninstalled | Holds group access until DLP coverage exists | The installation controls the selected host-product route | The agent adds another supported host product |
| Restore | Remove a premature installation from the test group | Restores the uninstalled condition and leaves the agent intact | Existing work in the native agent platform remains | The delivery owner retires the agent |

### Architecture guidance

- [Governance and Lifecycle actions for agents available in Microsoft 365 admin center](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-actions) documents group installation, permission consent, and uninstall.
- [Agent Registry convergence with Microsoft Agent 365](https://learn.microsoft.com/en-us/entra/agent-id/agent-registry-convergence) explains the split between Agent 365 inventory and Microsoft Entra access management.
- [Connect existing agents to Microsoft Agent 365](https://learn.microsoft.com/en-us/microsoft-agent-365/connect-existing-agents) describes which Microsoft-built agents automatically appear in Agent 365 and the onboarding routes for external agents.

## Before you start

Confirm these prerequisites:

- Session 05 has created the governed nonproduction agent.
- The Agent 365 administrator can locate the selected agent in Microsoft 365 admin center >
  Agents > All agents > Registry, and the agent has **Available** status.
- The selected agent supports installation through Microsoft 365 admin center.
- The delivery owner has named one nonproduction Microsoft Entra security group and one host
  product for the post-DLP pilot.
- The Entra owner has reviewed the permissions that the deployment will request.
- The Microsoft 365 administrator can remove an accidental installation from the group.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/agent-deployment.json`](artifacts/agent-deployment.json) | The Microsoft 365 administrator and Session 06 preflight scripts |

Complete `artifacts/agent-deployment.json`, then run preflight:

```powershell
.\scripts\preflight.ps1
```

```bash
./scripts/preflight.sh
```

Microsoft 365 admin center does not provide a read-only preview for this group-install action.
Preflight checks the approved target scope and the deployment contract before the administrator
makes the change.

## Decisions and stop conditions

### Agent and audience

Use one Available Agent Registry entry. Record its registry ID, platform, alias, and one target
group in `artifacts/agent-deployment.json`. The target group must be a nonproduction test group
with a named sponsor.

Stop if the agent is not listed in Agent Registry, is not Available, has no supported group
installation path, or the proposed audience is broader than the approved test group.

### Permissions and host product

Record exactly one host product and the approved use case. The Entra owner reviews the agent's
requested permissions before the Microsoft 365 administrator grants consent in Session 10. **Do
not use an organization-wide deployment** or add a host product during this session.

Stop if a requested permission is unapproved, the consent screen differs from the reviewed
permission set, or the agent asks for access outside the approved use case.

### Restore authority

The Microsoft 365 administrator must be able to remove an accidental installation from the selected
group. Removal restores the uninstalled condition and leaves the agent and its native runtime intact.

Stop if the team cannot name the administrator who can remove an accidental installation.

## Implement

### 1. Complete and check the deployment contract

Fill in `artifacts/agent-deployment.json`. Use aliases in the repository and keep tenant IDs,
user identities, and consent records in the approved customer system. Run either preflight command
before changing Microsoft 365 state.

### 2. Confirm the installation is withheld

The Microsoft 365 administrator inspects the Available agent listed in the deployment contract.
Do not select Install or grant consent. Confirm that no deployment exists for the named test group.
Session 10 owns the installation after it confirms DLP policy enablement and propagation.

### 3. Confirm the intended-path setup boundary

The intended result is a complete deployment contract and no installation for the test group. The
group has no access because Session 06 leaves the agent uninstalled.

### 4. Confirm the blocked-path boundary

The blocked result is any installation, consent grant, or group availability before Session 10
confirms DLP coverage. Stop and remove the scoped installation through Microsoft 365 admin center
if one exists.

### 5. Delivery-owner checkpoint

The delivery owner observes the uninstalled boundary with the Microsoft 365 administrator.
**Keep the prepared contract when no installation exists for the group and the recorded consent
decision matches the approved permission set.**

## Confirm the result

Inspect the selected agent in Agent Registry and its Microsoft 365 deployment details.

Expected result: the contract names one approved agent, group, host product, and consent decision.
Microsoft 365 has no installation for that group.

## After implementation

Microsoft 365 admin center keeps the Agent Registry entry. The Microsoft Entra group owner
maintains membership. The Agent 365 administrator monitors the registry record. Session 10 owns
the DLP-gated installation and access checks.

If an installation occurs before DLP confirmation, the Microsoft 365 administrator selects the
agent in Agents > All agents > Registry and removes it from the recorded test group. Leave the
agent and its runtime configuration unchanged.
