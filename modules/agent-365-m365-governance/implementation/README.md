# Implementation - Microsoft Agent 365 and Microsoft 365 agent governance

## Module scope

### What we will do

Create the owner review packet for one approved nonproduction Agent 365 or Microsoft 365 agent
path. The module records the Agent Registry and Agent Map entries, Entra Agent ID decisions,
publishing approval checks, Copilot Studio environment controls, connector policy, SharePoint
oversharing review, and Defender XDR Security for AI hunting templates.

The result is an owner-reviewed packet that tells the team whether the pilot agent is ready for a
controlled publishing decision. No production-wide access change is made by this module.

### Why it matters

Foundry sessions govern the Azure implementation path. Microsoft 365 agents add another control
plane: publishing, app availability, user access, connector policy, SharePoint grounding, and
Defender XDR posture. If those controls are not reviewed together, an agent can look clean in
Foundry and still be risky once it reaches Microsoft 365 users.

### Boundaries

This optional module sits outside the 15-session sequence. It complements Session 10 for Purview
data controls, Session 12 for Defender, and Session 15 for fleet visibility. It does not replace
those sessions.

Use it for one nonproduction pilot agent or agent family. Microsoft 365 Admin Center, Microsoft
Entra, Power Platform, SharePoint, Microsoft Purview, and Defender XDR remain authoritative for
live state. The repository keeps templates, owner decisions, aliases, and payload-free query text.

Production publishing, tenant-wide connector blocking, Conditional Access enforcement, SharePoint
permission changes, Purview eDiscovery, Insider Risk, Communication Compliance, Copilot capacity
governance, and preview-only implementation paths are excluded from this wave.

## Architecture

### Architecture at a glance

![Live Microsoft 365 control planes feed owner decisions into one pilot review packet without changing tenant state](../assets/diagrams/agent-365-control-plane-review.svg)

No single Microsoft 365 admin surface can answer every governance question about an agent. This
module gives the existing service owners one review path for a single nonproduction agent or agent
family. It adds no new control plane. Each owner still inspects the part of the pilot that their
service governs.

The review follows the agent across the service boundaries. Agent 365 shows its registry entry and
Agent Map. Microsoft 365 Admin Center shows publishing and availability, while Microsoft Entra
holds the Agent ID and Conditional Access state. Copilot Studio and Power Platform report the
environment route and connector policy. SharePoint controls access to grounding sources. Defender
XDR supplies the security posture and hunting results.

The live services remain the source for current state. The repository packet connects their
aliases and owner decisions, including who acts next, and stores payload-free hunting queries.
Preflight can check whether that packet is complete. It cannot read the tenant or prove that an
owner's portal review is still current.

The publishing approver uses the packet to decide whether work should move to a separate, approved
change path. This module stops before that change. It cannot publish the agent, enforce Conditional
Access, alter SharePoint permissions, or block a connector.

### Design choices and tradeoffs

| Choice engineers need to make | Route used here | Why this route fits | What the team accepts | Change course when |
|---|---|---|---|---|
| How should owners inspect the pilot? | Review the live admin surfaces they own | Each decision comes from the service that holds the state, without brittle portal automation | Owners need access and must review current state; preflight cannot detect tenant drift | Supported APIs expose the required state with stable semantics |
| What belongs in the repository? | An alias-based review packet with no tenant or user data | The packet assigns decisions and next actions without copying live records | It cannot reconstruct tenant state or replace service records | An approved private system can retain governed identifiers |
| When should Conditional Access block access? | Record the Agent ID policy decision in report-only mode | The identity owner can inspect the expected effect first | This module does not block access | The identity owner approves a separate enforcement change |
| How narrowly should connector access be set? | Default-deny at action level where Advanced Connector Policies support it | The owner can restrict specific actions instead of classifying only the whole connector | Coverage depends on the tenant and connector | The platform provides a stronger approved policy route |

### Architecture guidance

Use the [Microsoft Agent 365
overview](https://learn.microsoft.com/en-us/microsoft-agent-365/overview) to establish what Agent
Registry and Agent Map can tell the Agent 365 administrator about this pilot. The inventory record
then captures the alias, owner, sponsor, and lifecycle decision. It points back to Agent 365 rather
than copying the live registry.

The publishing checklist connects that inventory to the availability decision. The approver checks
current state and the restore path in [Microsoft 365 Admin Center agent
management](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/manage-copilot-agents-integrated-apps).
Connector and MCP action decisions go into the connector matrix. Apply [Advanced Connector
Policies](https://learn.microsoft.com/en-us/power-platform/admin/advanced-connector-policies) only
when the tenant supports the action-level rule the owner needs. These policies allow the owner to
control individual connector or MCP actions rather than treating the whole connector as one unit.

Preflight comes last. It finds missing files and unresolved owner decisions in the packet. It does
not query any of the live control planes.

The numbered sessions still own their parts of the wider system. Session 03 supplies the identity
ownership model. Sessions 08 and 09 set the inventory and tool boundaries. Sessions 10 and 12
remain the data and Defender handoffs. Session 15 brings the reviewed pilot record into fleet
operations.

## Before you start

Confirm these prerequisites:

- The tenant owner has approved one nonproduction agent or agent family for review.
- The Agent 365 administrator can view Agent Registry and Agent Map for the approved scope.
- The Entra identity owner can review Agent ID, sponsor, expiry, and Conditional Access decisions.
- The publishing approver can review Microsoft 365 Admin Center Integrated Apps and Agent Store state.
- The Copilot Studio environment owner can review the agent's environment, ALM path, and security scan.
- The Power Platform DLP owner can review connector grouping and Advanced Connector Policies.
- The SharePoint owner can review oversharing and Data Access Governance findings for grounding sources.
- The Defender owner can review Security for AI posture and run hunting queries without exporting payloads.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/governance/agent-inventory-template.csv`](artifacts/governance/agent-inventory-template.csv) | The Agent 365 administrator and agent owner |
| Record | [`artifacts/governance/agent-publishing-approval-checklist.md`](artifacts/governance/agent-publishing-approval-checklist.md) | The publishing approver and Agent 365 administrator |
| Record | [`artifacts/identity/entra-agent-id-policy-template.json`](artifacts/identity/entra-agent-id-policy-template.json) | The Entra identity owner |
| Record | [`artifacts/connectors/connector-governance-matrix.csv`](artifacts/connectors/connector-governance-matrix.csv) | The Power Platform DLP owner and Copilot Studio environment owner |
| Record | [`artifacts/data/sharepoint-oversharing-assessment.md`](artifacts/data/sharepoint-oversharing-assessment.md) | The SharePoint owner and data owner |
| Runtime | [`artifacts/defender/agent-security-hunting-queries.kql`](artifacts/defender/agent-security-hunting-queries.kql) | The Defender owner and SOC analyst |

Run preflight after filling the module artifacts:

```powershell
.\scripts\preflight.ps1
```

```bash
./scripts/preflight.sh
```

Preflight checks that the module artifacts exist and that no required owner decision remains.
A read-only deployment preview is unsupported because this module records portal-led owner
decisions and makes no tenant state change.

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value before owner review. Use aliases rather than tenant IDs, user
names, source URLs, prompt text, response text, connector secrets, or audit exports.

### Agent inventory and lifecycle

Record the agent in
[`artifacts/governance/agent-inventory-template.csv`](artifacts/governance/agent-inventory-template.csv).
The Agent 365 administrator confirms that the registry entry and Agent Map node match the approved
pilot scope.

Stop if the agent has no owner, no sponsor, no lifecycle state, no retirement review date, or a
publishing state broader than the approved nonproduction scope.

### Identity and access

Record the Entra Agent ID decisions in
[`artifacts/identity/entra-agent-id-policy-template.json`](artifacts/identity/entra-agent-id-policy-template.json).
Start Conditional Access in `ReportOnly` mode for this module. Enforcement requires a separate
tenant change.

Stop if the agent lacks a sponsor, has no expiry or access review path, or the access scope is a
production population.

### Publishing and Copilot Studio

Use
[`artifacts/governance/agent-publishing-approval-checklist.md`](artifacts/governance/agent-publishing-approval-checklist.md)
to review Integrated Apps, Agent Store readiness, environment routing, ALM, and Copilot Studio
security scan results.

Stop if the agent is reachable by a broader user population than approved, if a high-severity
security scan finding remains open, or if the admin cannot block or remove the agent.

### Connector and MCP actions

Classify every connector, MCP endpoint, and tool action in
[`artifacts/connectors/connector-governance-matrix.csv`](artifacts/connectors/connector-governance-matrix.csv).
Use default-deny for action-level controls where Advanced Connector Policies are available.

Stop if a connector is unclassified, uses an unclear authentication mode, allows write actions
without owner approval, or crosses the Business and Non-business boundary.

### SharePoint oversharing

Record the grounding-source review in
[`artifacts/data/sharepoint-oversharing-assessment.md`](artifacts/data/sharepoint-oversharing-assessment.md).
Use aliases for sites and libraries. Keep SharePoint and Purview reports as the source of truth.

Stop if broad sharing remains unresolved for an in-scope grounding source or if the agent can read
outside the approved access scope.

### Defender XDR Security for AI

Use
[`artifacts/defender/agent-security-hunting-queries.kql`](artifacts/defender/agent-security-hunting-queries.kql)
as payload-free hunting templates. The Defender owner reviews agent inventory, runtime protection
status, prompt-injection signals, and tool-misuse signals.

Stop if the agent is not visible in the expected Defender surface, if runtime protection status is
unknown, or if the SOC route cannot handle agent-related alerts.

## Implement

### 1. Complete the module artifacts

Fill in the inventory, publishing checklist, Entra Agent ID policy template, connector matrix,
SharePoint assessment, and Defender query aliases. Keep customer-specific copies in the approved
private repository or configuration store if they contain tenant details.

### 2. Review live control planes

Review live state with the owners of these admin surfaces:

| Surface | Owner | Review |
|---|---|---|
| Agent 365 | Agent 365 administrator | Agent Registry, Agent Map, owner, sponsor, lifecycle |
| Microsoft 365 Admin Center | Publishing approver | Integrated Apps, app availability, Agent Store readiness |
| Microsoft Entra | Identity owner | Agent ID, sponsor, expiry, Conditional Access report-only policy |
| Copilot Studio | Environment owner | Environment routing, ALM state, security scan |
| Power Platform | DLP owner | Connector grouping and Advanced Connector Policies |
| SharePoint | SharePoint owner | Oversharing and Data Access Governance findings |
| Defender XDR | Defender owner | Security for AI posture, runtime protection, and hunting results |

Do not change production tenant state during this module. Record the owner decision and the next
approved change path.

### 3. Run preflight

```powershell
.\scripts\preflight.ps1
```

```bash
./scripts/preflight.sh
```

Preflight should pass only after every module artifact has a resolved owner decision.

## Confirm the result

The delivery owner reviews the six module artifacts with the owners listed above.

Expected result: each artifact has no unresolved `__REQUIRED_*__` value, uses aliases instead of
tenant or user data, and names the owner responsible for the next action. The publishing checklist
must show that the agent is not production-published, connector actions are classified, SharePoint
oversharing has an owner decision, and Defender XDR review has a payload-free query path.

## After implementation

Keep the module artifacts with the pilot agent record. The Agent 365 administrator owns inventory
and lifecycle. The publishing approver owns user availability. The identity owner owns Agent ID,
sponsors, expiry, and Conditional Access. The Power Platform owner owns connector policy. The
SharePoint and data owners own grounding-source access. The Defender owner owns Security for AI
posture and hunting.

Restore is manual. Block or remove the agent in Microsoft 365 Admin Center, return Conditional
Access policy to report-only or disabled, restore connector policy to the approved baseline, remove
the agent from the pilot access group, and close the Defender review as not production-enabled.
