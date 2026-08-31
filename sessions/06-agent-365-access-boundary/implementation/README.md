# Microsoft Agent 365 onboarding and access boundaries

## Session scope

### What we will do

Prepare one approved nonproduction Agent Registry deployment for a named Microsoft Entra test
group. Do not install the agent or grant group availability in this session. Session 10 confirms
the DLP policy, then uses this contract for the installation and access checks.

The repository keeps the configuration contract that the administrator uses after DLP confirmation.

### Why it matters

An Agent Registry record is an inventory entry. It does not decide who can use an agent. Group
deployment creates a narrow availability boundary before a team exposes the agent to a wider
population.

### Boundaries

This session applies to one Agent Registry-listed agent, one nonproduction test group, and one host
product. It does not create, modify, stop, or delete the underlying agent. It does not publish the
agent to the organization, block it tenant-wide, or configure Conditional Access.

Microsoft Agent 365 and Microsoft 365 admin center remain authoritative for inventory, installation,
consent, and user availability. Microsoft Entra remains authoritative for group membership and
agent identity. [Session 07](../../07-apim-ai-gateway/implementation/README.md) controls API
ingress for the Foundry route. [Session 10](../../10-purview-data-governance/implementation/README.md)
adds Purview data controls.

## Architecture

### Architecture at a glance

The Microsoft 365 administrator records the approved Agent Registry entry, Microsoft Entra
security group, host product, and consent decision. The administrator does not deploy the agent in
this session. Session 10 installs it only after DLP coverage is enabled and propagated.

Agent Registry records the agent and its availability. Microsoft Entra records group membership.
Session 06 keeps the post-DLP deployment decision in the repository. The agent's runtime continues
to live in its native service.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Deployment audience | One existing Microsoft Entra test group | Defines the post-DLP pilot population | Administrators manage membership outside this session | The delivery owner approves a larger pilot |
| Permission grant | Record the reviewed consent decision for the post-DLP deployment | Connects the decision to the exact pilot deployment | New permissions require another review | The agent's permission request changes |
| Agent scope | Prepare one available Agent Registry entry for one host product | Keeps availability off until DLP coverage exists | It does not govern every way the runtime may be reached | The agent adds another supported host product |
| Restore | Remove any premature installation from the test group | Restores the no-availability state without deleting the agent | Existing work in the native agent platform remains | The delivery owner retires the agent |

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
group. Removal restores the no-availability state; it does not delete the agent or remove its native
runtime.

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

The intended result is a complete deployment contract with no group availability. The group cannot
use the agent because this session has not installed it.

### 4. Confirm the blocked-path boundary

The blocked result is any installation, consent grant, or group availability before Session 10
confirms DLP coverage. Stop and remove the scoped installation through Microsoft 365 admin center
if one exists.

### 5. Delivery-owner checkpoint

The delivery owner observes the withheld-access boundary with the Microsoft 365 administrator.
**Keep the prepared contract only when no installation exists, the group has no availability, and
the recorded consent decision matches the approved permission set.**

## Confirm the result

Inspect the selected agent in Agent Registry and its Microsoft 365 deployment details.

Expected result: the contract names one approved agent, group, host product, and consent decision,
while Microsoft 365 has no installation that makes the agent available to that group.

## After implementation

Microsoft 365 admin center keeps the Agent Registry entry. The Microsoft Entra group owner
maintains membership. The Agent 365 administrator monitors the registry record. Session 10 owns
the DLP-gated installation and access checks.

If an installation occurs before DLP confirmation, the Microsoft 365 administrator selects the
agent in Agents > All agents > Registry and removes it from the recorded test group. This session
does not delete the agent or change its runtime configuration.
