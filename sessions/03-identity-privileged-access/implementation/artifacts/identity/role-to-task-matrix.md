# Role-to-task matrix

Preflight resolves the stable IDs from `role-definitions.json` before deployment because Foundry
display names can lag across tools.

| Functional group | Allowed tasks | Role | Exact scope | Assignment |
|---|---|---|---|---|
| Platform administrators | Create accounts, projects, and model deployments during an approved change | Foundry Account Owner | Foundry resource | PIM eligible; activation required |
| Project managers | Manage and publish project work; assign Foundry User where allowed | Foundry Project Manager | Foundry resource | Group assignment |
| Developers and users | Build and operate inside one project | Foundry User | Foundry project | Group assignment |
| Auditors | Inspect resource configuration and role assignments without data-plane use | Reader | Foundry resource | Group assignment |
| Implementation workload | Invoke an approved model and read approved blobs | Cognitive Services User plus Storage Blob Data Reader | Nonproduction Foundry resource and storage account recorded for this session | Dedicated managed identity |

The matrix omits `Foundry Owner`. The narrower Account Owner and Project Manager roles split
account/model administration from project development. Reader does not grant model or blob data
access. If an auditor needs those data actions, record that as a separate decision.

## Identity-flow decision model

| Situation | Identity flow | Why |
|---|---|---|
| A person works directly in Foundry, the Azure portal, the CLI, or an approved operator path | Direct human | The resource should authorize that signed-in person or group. Use PIM when the task is elevated. |
| A workflow or application should do the same thing regardless of who started it | Workload or application-only | The authority belongs to the workload. Keep one dedicated managed identity and narrow roles. |
| A Foundry agent needs its own runtime actor for tool calls | Agent identity | Foundry Agent Service keeps the agent separate from human and workload identities. See [Session 06](../../../../06-governed-agent-baseline/implementation/README.md). |
| A middle tier calls a downstream API and the downstream decision must change by signed-in user | Delegated OBO | Carry the user's delegated authority across the hop. Use OBO only in this case, through a separately approved implementation. |

OBO is not a stronger managed identity. If the downstream API should return the same authorization
result for every caller, stay with application-only access.
