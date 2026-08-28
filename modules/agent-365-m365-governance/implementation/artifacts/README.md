# Agent 365 and Microsoft 365 governance artifacts

Use these files to review an agent before publishing it. They do not change tenant state.

| Path | Operational purpose |
|---|---|
| `governance/agent-inventory-template.csv` | Agent Registry, Agent Map, owner, sponsor, lifecycle, and publishing inventory |
| `governance/agent-publishing-approval-checklist.md` | Pre-publishing checks for metadata, access, identity, connector, data, security, and restore |
| `identity/entra-agent-id-policy-template.json` | Entra Agent ID sponsorship, Conditional Access, expiry, and access-review decisions |
| `connectors/connector-governance-matrix.csv` | Connector, MCP, action, authentication, data movement, and approval classification |
| `data/sharepoint-oversharing-assessment.md` | SharePoint broad-sharing findings and grounding-source remediation decisions |
| `defender/agent-security-hunting-queries.kql` | Payload-free Defender XDR hunting templates for agent posture and runtime protection |

Resolve every `__REQUIRED_*__` value before owner review. Keep tenant IDs, user names, source URLs,
prompts, responses, connector secrets, and audit exports outside this tree.
