# MCP threat model

## Scope

The [Session 06](../../../../06-governed-agent-baseline/implementation/README.md) policy assistant calls one Session 09 MCP endpoint in the
[Session 07](../../../../07-apim-ai-gateway/implementation/README.md) API Management instance. APIM maps `get_policy` to one existing GET operation. The
source API, Foundry project, model, network, and API Center service remain existing dependencies.

## Trust boundaries

1. **User to Foundry agent:** user input is untrusted; the agent endpoint keeps its existing Entra
   boundary.
2. **Foundry agent to APIM MCP:** the candidate agent identity receives a token for the exact MCP
   audience. APIM validates tenant, client application, audience, and app role.
3. **APIM to backing API:** APIM discards the inbound MCP token for backend access and obtains its
   own managed-identity token for the exact backend audience. This hop is application-only, not
   OBO. The backing scope grants only the approved read role.
4. **Tool output to model:** every returned field is untrusted data. Content cannot expand the tool
   allowlist, change approval policy, or grant backend authority.
5. **Telemetry:** APIM records operation, tool, client, duration, status, and correlation metadata.
   Arguments and results remain disabled.

## Abuse cases and controls

| Abuse case | Primary control | Stop condition |
|---|---|---|
| Unknown tool appears | One deployed `tools` child resource and Foundry `allowedTools` | More than `get_policy` is returned by `tools/list` |
| Caller reuses a token | Audience, tenant, client, and app-role validation | Token is not bound to the MCP audience |
| Gateway forwards or reuses caller authority | APIM discards inbound backend authority and obtains a new managed-identity token | Inbound bearer token or any caller-derived authorization claim reaches the backend |
| Read tool mutates state | GET-only operation, backend validation, read-only role | Operation or role permits write |
| Argument injection or traversal | Backend validates `policyId` against the authoritative schema | Backend accepts values outside the pattern or length |
| Indirect prompt injection | Untrusted-output instruction, one-tool allowlist, approval, no write authority | Tool output changes instructions or requests an unknown tool |
| Payload leaks through diagnostics | Request and response body logging remain zero | Any global or MCP diagnostic captures payload bytes |
| Runaway calls | Per-client and per-tool short-window throttle | Limit is absent or keyed only by shared IP |
| Stream breaks | Policy never reads `context.Response.Body` | A policy or diagnostic buffers MCP response content |

## Residual risks

- A read API can still disclose data if its own row-level authorization is too broad.
- A changed tool description, input schema, or output field can alter model behavior without
  changing the tool name.
- APIM throttling is distributed and is not an exact accounting mechanism.
- The preview MCP management API can change before a stable version is available.
- If the API must authorize each signed-in user, this session's application-only hop is the wrong
  pattern. Use a separately approved delegated-access implementation instead of forwarding the MCP
  token.
- Model behavior is not a security boundary; identity, tool absence, and backend authorization remain
  the enforceable controls.

The security owner reruns both synthetic checks whenever the server operator, tool description,
input schema, returned fields, backing operation, identity mapping, agent instructions, model, or
approval policy changes. The release owner keeps the stable endpoint on the prior version until
that review passes.

## Authorization

| Hop | Caller | Resource and audience | Required authority | Excluded |
|---|---|---|---|---|
| User to agent | Approved nonproduction user group | Session 06 agent endpoint | Existing agent consumer access | Project administration |
| Agent to MCP | Candidate agent identity | `__REQUIRED_MCP_AUDIENCE__` | App role `__REQUIRED_MCP_CALLER_APP_ROLE__` | APIM management |
| APIM to backing API | APIM system-assigned identity | `__REQUIRED_BACKEND_AUDIENCE__` at `__REQUIRED_BACKEND_AUTHORIZATION_SCOPE__` | Read role `__REQUIRED_BACKEND_ROLE_DEFINITION_ID__` | Forwarded caller token and writes |
| Release | `__REQUIRED_RELEASE_OWNER__` | Candidate agent version | Observe both checks, then pin or disable | Scope changes during the checkpoint |

APIM obtains a new token for the backing audience. It never forwards the inbound MCP token. Use a
separately approved delegated-access implementation if the API must authorize each signed-in user.

## Disable and restore

Keep the Session 06 version pinned while testing. If either check fails, leave the stable endpoint
unchanged. If the candidate is already active, restore the previous Session 06 version at 100%
before changing infrastructure.

Then remove the Foundry project connection only when no other governed tool uses it. Preview and
use the approved APIM change path to delete the marked Session 09 MCP resources. Revoke the APIM
backend role only when the identity owner confirms that no other path depends on it. Never delete
the backing API, APIM service, Foundry agent, API Center, Application Insights resource, or source
data during this restore.
