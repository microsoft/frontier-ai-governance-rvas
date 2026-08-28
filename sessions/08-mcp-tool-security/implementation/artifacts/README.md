# Implementation artifacts

These files define the governed Session 08 MCP path: one deployable APIM MCP server, one
allowlisted read tool, identity and release decisions, a recurring security-evaluation runbook, and
the monitoring and restore paths.

| Path | Purpose |
|---|---|
| `apim/main.bicep` | MCP server, one tool reference, APIM named values, policy, and payload-free diagnostics |
| `apim/policies/mcp-policy.xml` | Inbound Entra validation, per-tool throttling, correlation, trace, and outbound managed identity |
| `environments/sandbox.json` | Approved nonproduction coordinates, identity decisions, owners, and limits |
| `governance/agent-mcp-binding.json` | Candidate binding, one-tool contract, prohibited action, and approval settings |
| `governance/security-evaluation.md` | Recurring candidate checks, maintained by the security owner before enablement |
| `governance/threat-model.md` | Trust boundaries and restore guidance, reviewed every 90 days by the security owner |
| `operations/mcp-traffic.kql` | Payload-free MCP traffic and correlation query |

Resolve every `__REQUIRED_*__` value before deployment. Runtime URLs, access tokens, subscription
IDs, prompts, responses, and telemetry must not be committed.
