# Microsoft Agent 365 onboarding and access boundaries

## Session scope

### What we will do

Prepare one approved nonproduction Agent Registry deployment for a Microsoft Entra test group.
**Keep the agent uninstalled.** Session 10 uses the contract after DLP propagation.

### Why it matters

Agent Registry shows that an agent exists. Group installation gives people access. Hold access
closed until the data control is ready.

### Boundaries

The scope is one Available entry, test group, host product, and consent decision. Agent 365 holds
inventory and installation. Microsoft Entra holds identity and membership. The repository holds
the contract. Runtime, membership, Conditional Access, and tenant-wide blocks do not change.
[Session 07](../../07-apim-ai-gateway/implementation/README.md) controls Foundry API ingress.
[Session 10](../../10-purview-data-governance/implementation/README.md) owns installation and access
checks after DLP confirmation.

## Architecture

### Architecture at a glance

The administrator records the agent, group, host, use case, consent, and validation aliases in
`agent-deployment.json`. Preflight checks it. The administrator confirms no installation. Session
10 confirms DLP, installs the agent, and checks access. The runtime stays in its native service.

### Design choices and tradeoffs

| Decision | Choice | Limitation |
|---|---|---|
| Audience | One nonproduction Entra group | Wider access needs approval |
| Consent | One approved permission set and host product | Changes need review |
| Access | No installation before Session 10 | No group access yet |
| Restore | Remove the group installation | The agent remains |

### Architecture guidance

- [Governance and Lifecycle actions for agents available in Microsoft 365 admin center](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/agent-actions)
- [Agent Registry convergence with Microsoft Agent 365](https://learn.microsoft.com/en-us/entra/agent-id/agent-registry-convergence)
- [Connect existing agents to Microsoft Agent 365](https://learn.microsoft.com/en-us/microsoft-agent-365/connect-existing-agents)

## Before you start

Session 05 must have created the agent. The Agent 365 administrator finds it under **Agents > All
agents > Registry** with **Available** status and group installation. The delivery owner approves
the scope and post-DLP route. The Entra owner approves permissions. A Microsoft 365 administrator
owns inspection and removal.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/agent-deployment.json`](artifacts/agent-deployment.json) | The Microsoft 365 administrator and Session 06 preflight scripts |

Complete every `__REQUIRED_*__` value. Keep tenant IDs, identities, and consent records in customer
systems.

```powershell
.\scripts\preflight.ps1
```

```bash
./scripts/preflight.sh
```

The admin center has no read-only preview. Preflight checks the fixed scope, marker, status, host,
consent, synthetic-data boundary, and `PrepareOnly` action.

## Decisions and stop conditions

| Gate | Continue | Stop |
|---|---|---|
| Agent | Exact registry ID is Available with group installation | Missing, unavailable, or another path |
| Audience | One sponsored nonproduction group | Wider audience |
| Consent | One host, use case, and approved permission set | Changed, unapproved, or excessive permission |
| Access | No installation or consent | Access exists before DLP |
| Restore | Named administrator owns removal | No removal owner |

Do not select **Install**, grant consent, add a host product, or use an organization-wide deployment.

## Implement

1. Complete `agent-deployment.json` and run preflight.
2. Open **Agents > All agents > Registry** and select the recorded agent.
3. Confirm that the group has no installation. Do not install or grant consent.
4. Compare the saved host and consent with the approval.

### Intended-path check

The contract matches the approved scope, including both validation aliases. Microsoft 365 shows no
installation.

### Blocked-path check

Any early installation, consent, or availability fails the boundary. Stop and remove the scoped
installation.

### Delivery-owner checkpoint

The delivery owner observes both checks. Keep the contract only when the group remains uninstalled
and consent still matches.

## Confirm the result

Inspect the registry entry once. The contract must match, and **Microsoft 365 must show no group
installation.**

## After implementation

The Agent 365 administrator owns the entry. The Entra owner maintains membership. The Microsoft
365 administrator keeps the contract. Session 10 owns installation and access checks.

To restore the boundary, remove the group installation under **Agents > All agents > Registry**.
Leave the agent, runtime, and membership unchanged.
