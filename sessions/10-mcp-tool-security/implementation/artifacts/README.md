# Implementation artifacts

These files define the Session 10 MCP implementation. They configure an APIM MCP server with the
allowlisted read tool and record the identity, release, monitoring, and restore decisions.

| Path | Purpose |
|---|---|
| `apim/main.bicep` | Defines the MCP server, its one tool reference, named values, policy, and payload-free diagnostics |
| `apim/policies/mcp-policy.xml` | Validates inbound Entra tokens, throttles each tool, adds correlation and tracing, and uses outbound managed identity |
| `environments/sandbox.json` | Names the approved nonproduction resources and records identity decisions, owners, and limits |
| `governance/agent-mcp-binding.json` | Defines the candidate binding, approved-tool contract, prohibited action, and approval settings |
| `governance/security-evaluation.md` | Guides the security owner through recurring candidate checks before enablement |
| `governance/threat-model.md` | Records trust boundaries and restore guidance for the security owner's 90-day review |
| `operations/mcp-traffic.kql` | Queries payload-free MCP traffic and correlation |

Resolve every `__REQUIRED_*__` value before deployment. Keep runtime URLs, access tokens,
subscription IDs, prompts, responses, and telemetry out of the repository.
