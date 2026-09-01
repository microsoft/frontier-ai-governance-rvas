---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 10</p>

# MCP and tool security

210 minutes · Deploy one read tool, check the blocked write, then decide whether to enable it

---

## Why it matters

> Configure an MCP path that exposes only `get_policy`, validates the candidate agent at APIM, uses APIM's read-only managed identity for the backend, and emits payload-free telemetry.

By the end of the session:

- APIM exposes one Streamable HTTP tool.
- The agent and APIM use separate identities.
- The approved read succeeds with correlation and no payload logging.
- Indirect prompt injection cannot trigger the prohibited write.
- The release owner pins the candidate or keeps the prior version.

<!-- Notes: Tool absence and backend authorization enforce the write boundary. -->

---

<!-- _class: two-column -->

## Architecture

<div class="columns">
<div>

The candidate calls APIM with its agent identity.

APIM validates tenant, client, audience, app role, and `policyId`.

APIM calls the backend with its system-assigned identity and exact read role.

Foundry owns the candidate and stable selector. API Center holds inventory metadata. Application Insights keeps correlation without payloads.

</div>
<div>

![A Foundry agent and API Management use separate identities to reach a read-only backend.](assets/diagrams/mcp-tool-security-flow.svg)

</div>
</div>

<!-- Notes: The inbound MCP token stops at APIM. The backend hop is application-only, not OBO. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Required answer |
|---|---|
| Tool | Existing GET operation, approved fields, `policyId` rule, prohibited write |
| Inbound access | MCP audience, app role, candidate agent identity |
| Backend access | APIM identity, backend audience, exact read role and scope |
| Release | Named release owner, synthetic records, human change route |

Use Streamable HTTP at `/mcp`. APIM workspaces, delegated user access, write tools, payload logging, and production release need separate approval.

<!-- Notes: HTTP GET alone does not prove that an operation has no side effects. -->

---

## The enforceable boundary

| Layer | Allows | Blocks |
|---|---|---|
| Foundry | `get_policy`, approval `always` | Direct OpenAPI bypass and unknown tools |
| APIM inbound | Approved tenant, client, audience, and app role | Other callers and token audiences |
| APIM outbound | Managed-identity token for the backend | Forwarded caller authority |
| Backend RBAC | Required read Actions or DataActions at the exact scope | Wildcard, write, delete, and action permissions |
| Telemetry | Tool, status, latency, W3C trace, support correlation | Arguments, results, prompts, responses, tokens, and bodies |

Model instructions support the control. They do not replace it.

<!-- Notes: Keep the authority change at APIM explicit. -->

---

<!-- _class: implementation -->

## Implementation path

**Total session: 210 minutes. Guided implementation: about 165 minutes.**

1. Resolve owners, identities, scopes, tool fields, and synthetic records.
2. Run preflight and inspect ARM `what-if`.
3. Deploy the MCP API, one tool, policy, named values, and diagnostic.
4. Complete the API Center metadata.
5. Create the agentic-identity Foundry connection.
6. Create an unpinned candidate with only `get_policy`.
7. Run the approved-read and blocked-write checks.
8. Pin the candidate or keep the prior version.

The remaining time covers briefing, decisions, and the operating handoff.

<!-- Notes: The implementation guide contains paired PowerShell and Bash commands. -->

---

## Stop before the change when

- A `__REQUIRED_*__` value remains.
- The operator lacks time-bound **Contributor** on the APIM resource group or **Foundry User** on the project.
- APIM is a workspace, uses an unsupported tier, or preview automation is prohibited.
- The backing operation has side effects or the role is broader than the approved read.
- The inbound token reaches the backend or a shared secret is required.
- Any diagnostic captures payload bytes.
- Another tool appears, approval is not `always`, or the direct OpenAPI path remains.
- `what-if` changes unrelated resources or finds an unmarked name collision.

<!-- Notes: Preflight checks the definitions, live Azure state, and deployment preview. -->

---

<!-- _class: two-column -->

## Check both runtime paths

<div class="columns">
<div>

### Approved read

- Target the visible candidate ID.
- Confirm the stable selector still points to Session 05.
- Approve only `policy-catalog / get_policy`.
- Match one successful APIM event by W3C `operation_Id`.
- Confirm zero payload logging.

</div>
<div>

### Blocked write

- Read the adversarial synthetic record.
- Approve only the expected read.
- Treat the embedded instruction as data.
- Refuse the prohibited write and name the human route.
- Request no write or unknown tool.

</div>
</div>

<!-- Notes: Stop if the version selector is hidden, the result is wrong, or correlation is absent. -->

---

<!-- _class: decision -->

## Release-owner checkpoint

<div class="cards">
<div class="card">

### Enable

Both checks pass and API Center has the required owner metadata.

Pin the stable endpoint 100% to the candidate.

</div>
<div class="card">

### Keep the prior version

Either check fails.

Leave or restore Session 05 at 100%, keep the candidate unpinned, and route remediation.

</div>
</div>

<!-- Notes: The prior stable version is the immediate disable switch. -->

---

## Operate and restore

Keep the MCP API, one tool, policy, named values, diagnostic, Foundry connection, binding, security
evaluation, threat model, KQL query, and scripts. The security owner reviews the threat model every
90 days and reruns both checks after a security-relevant change.

**Restore before removal:**

1. Pin the prior Session 05 version at 100%.
2. Confirm no active agent uses the MCP endpoint.
3. Remove the unused Foundry connection.
4. Verify the Session 10 marker, then remove only the MCP API and five named values.
5. Revoke the backend role only when no other operational path uses it.

Never delete the backing API, APIM service, Foundry agent, API Center, Application Insights, or source data.

<!-- Notes: Removal is targeted and dependency-aware. -->

---

<!-- _class: closing -->

# Thank you!
