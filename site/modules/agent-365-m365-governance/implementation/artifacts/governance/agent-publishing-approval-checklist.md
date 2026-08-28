# Agent publishing approval checklist

Use this checklist before making the approved pilot agent available in Microsoft 365 Copilot or the
Agent Store. Microsoft 365 Admin Center remains authoritative for live publishing state.

| Field | Decision |
|---|---|
| Agent alias | `__REQUIRED_AGENT_ALIAS__` |
| Agent Registry ID | `__REQUIRED_AGENT_REGISTRY_ID__` |
| Publishing approver | `__REQUIRED_PUBLISHING_APPROVER_ROLE__` |
| Agent owner | `__REQUIRED_AGENT_OWNER_ROLE__` |
| Review date | `__REQUIRED_REVIEW_DATE__` |
| Publishing state | NotPublished |

## Checks

| Check | Required state |
|---|---|
| Registry entry | Agent appears in Agent Registry with an owner and sponsor |
| Agent Map | Dependencies and connected tools are visible or recorded as unavailable |
| User access | Access scope matches the approved nonproduction group |
| Entra Agent ID | Sponsorship, expiry, and Conditional Access decisions are recorded |
| Connector policy | Every connector and MCP action is classified in the connector matrix |
| SharePoint grounding | Broad-sharing findings are remediated or accepted by the data owner |
| Copilot Studio security scan | No high-severity finding remains open |
| Defender XDR | Security for AI posture has been reviewed for this agent |
| Restore | The admin can block, disable, or remove the agent from user access |

Stop if the agent is production-facing, ownerless, missing a sponsor, connected to an unclassified
tool, or published to a broader user population than the approved access scope.
