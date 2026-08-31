# Microsoft Agent 365 onboarding and access boundaries

## Session scope

### What we will do

Install one approved nonproduction agent from Agent Registry for a named Microsoft Entra test group.
The Microsoft 365 administrator reviews the requested permissions and grants consent for that
installation. Keep the deployment limited to synthetic setup and withhold meaningful user access
until Session 10 confirms that the DLP policy is enabled and propagated.

The installed agent, consent state, and deployment group remain in Microsoft 365. The repository
keeps the configuration contract that the administrator uses for the scoped deployment.

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

The Microsoft 365 administrator selects the approved agent from Agent Registry and deploys it to
one Microsoft Entra security group. During deployment, the administrator reviews and accepts its
approved permissions. Microsoft 365 makes the agent available through the selected host product to
members of that group.

Agent Registry records the agent and its availability. Microsoft Entra records group membership.
The Microsoft 365 deployment record holds the installed audience and consent. The agent's runtime
continues to live in its native service.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Deployment audience | One existing Microsoft Entra test group | Limits the pilot to an accountable population | Administrators manage membership outside this session | The delivery owner approves a larger pilot |
| Permission grant | Review and grant the agent's requested permissions during deployment | Connects consent to the exact pilot deployment | New permissions require another review | The agent's permission request changes |
| Agent scope | Install one available Agent Registry entry in one host product | Gives the team one observable availability boundary | It does not govern every way the runtime may be reached | The agent adds another supported host product |
| Restore | Uninstall the agent from the test group | Removes the group deployment without deleting the agent | Existing work in the native agent platform remains | The delivery owner retires the agent |

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
- The delivery owner has named one nonproduction Microsoft Entra security group, a group member,
  an excluded user, and one host product for the pilot.
- The Entra owner has reviewed the permissions that the deployment will request.
- The Microsoft 365 administrator can uninstall the agent if the group deployment has an
  unexpected effect.

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
requested permissions before the Microsoft 365 administrator grants consent. **Do not use an
organization-wide deployment** or add a host product during this session.

Stop if a requested permission is unapproved, the consent screen differs from the reviewed
permission set, or the agent asks for access outside the approved use case.

### Restore authority

The Microsoft 365 administrator must be able to uninstall the agent from the selected group.
Uninstall removes the deployment; it does not delete the agent or remove its native runtime.

Stop if the team cannot name the administrator who can uninstall the scoped deployment.

## Implement

### 1. Complete and check the deployment contract

Fill in `artifacts/agent-deployment.json`. Use aliases in the repository and keep tenant IDs,
user identities, and consent records in the approved customer system. Run either preflight command
before changing Microsoft 365 state.

### 2. Install the agent for the test group

The Microsoft 365 administrator opens Agents > All agents > Registry and selects the
Available agent listed in the deployment contract. Select Install, choose the named test group,
review the requested permissions, grant the approved admin consent, and finish the deployment.

Keep the deployment limited to the recorded group and host product. Stop if Microsoft 365 presents
a broader audience, a different agent, or an unapproved permission.

### 3. Confirm the intended-path setup boundary

Use only synthetic setup data. Do not ask the test group to use the agent for a meaningful business
case before Session 10 confirms that the DLP policy is enabled and propagated.

### 4. Confirm the blocked-path boundary

After Session 10 confirms the DLP policy, the named group member opens the recorded host product
and completes the approved use case. The named user outside the test group confirms that the agent
is unavailable. Do not add that user to the group to work around the result.

### 5. Delivery-owner checkpoint

The delivery owner observes the withheld-access boundary with the Microsoft 365 administrator.
**Keep the group deployment in place only when it remains limited to synthetic setup, user access
is withheld pending Session 10 DLP confirmation, and the consent matches the approved permission
set.**

## Confirm the result

Inspect the selected agent in Agent Registry and its Microsoft 365 deployment details.

Expected result: the agent remains installed for the named test group in one approved host product,
with synthetic setup permitted and meaningful user access withheld until Session 10 confirms DLP
coverage. The administrator can uninstall the same scoped deployment.

## After implementation

Microsoft 365 admin center keeps the installed audience and consent state. The Microsoft Entra
group owner maintains membership. The Agent 365 administrator monitors the registry record and
agent availability. The delivery owner approves any wider deployment through the customer change
process.

To restore the prior state, the Microsoft 365 administrator selects the agent in Agents >
All agents > Registry, selects Uninstall, and removes it from the recorded test group.
This session does not delete the agent or change its runtime configuration.
