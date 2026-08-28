# Implementation artifacts

These files define the governed Session 08 MCP path: one deployable APIM MCP server, one
allowlisted read tool, identity and release decisions, an active security evaluation, and the
monitoring and restore paths.

| Path | Purpose |
|---|---|
| `apim/main.bicep` | MCP server, one tool reference, APIM named values, policy, and payload-free diagnostics |
| `apim/policies/mcp-policy.xml` | Inbound Entra validation, per-tool throttling, correlation, trace, and outbound managed identity |
| `environments/sandbox.json` | Approved nonproduction coordinates, identity decisions, owners, and limits |
| `governance/agent-mcp-binding.json` | Candidate binding, one-tool contract, prohibited action, and approval settings |
| `governance/security-evaluation.md` | Approved-read and indirect-prompt-injection evaluation record |
| `governance/threat-model.md` | Trust boundaries, authorization, controls, residual risks, and restore |
| `operations/mcp-traffic.kql` | Payload-free MCP traffic and correlation query |

Resolve every `__REQUIRED_*__` value before deployment. Runtime URLs, access tokens, subscription
IDs, prompts, responses, and telemetry must not be committed.
