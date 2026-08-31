---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 05</p>

# Governed Microsoft Foundry agent baseline

180 minutes · A versioned agent with one read tool and no write path

<!-- Notes: Establish the agent identity, version, tool, safety, and tracing controls before adding APIM and MCP. -->

---

## Control objective

> Create and pin a versioned prompt agent. Its Entra Agent Identity identifies the agent. The Foundry project managed identity authorizes the approved read-only OpenAPI tool. Keep write tools absent.

### Result check

- Create one prompt-agent version from `agent.json`, `instructions.md`, and `tool-manifest.json`.
- Pin the Entra-authorized stable endpoint to that version.
- Expose the GET operation and omit write operations.
- Return approved fields through `get_policy` in one synthetic read.

<!-- Notes: The enforceable boundary is the absent tool plus downstream authorization, not prompt wording alone. -->

---

## Implementation outcomes

1. Create a persistent prompt agent from approved instructions and deployment files.
2. Use a unique Entra Agent Identity to identify the agent and secure its endpoint.
3. Use the project managed identity for the approved application-only GET OpenAPI tool.
4. Apply the RAI policy in `agent.json` and enable server-side tracing.
5. Pin the stable Responses endpoint to the implemented version.

<!-- Notes: Session 07 fronts this endpoint with APIM; Session 09 introduces MCP controls. -->

---

## Why it matters

A pinned version gives the release owner a known configuration to operate.

The Entra Agent Identity identifies the agent and secures its endpoint.

The Foundry project managed identity authorizes the direct OpenAPI read.

<!-- Notes: Present the agent identity and project identity as separate controls. -->

---

## Control boundaries

- One prompt agent in the approved nonproduction Foundry project
- One application-only read through the project managed identity
- No write tool or delegated user authorization
- Foundry holds the live agent and endpoint; repository definitions define the version to deploy
- APIM, MCP, distribution, and evaluations belong to later sessions

<!-- Notes: Instructions reinforce the boundary. Tool absence and downstream authorization enforce it. -->

---

<!-- _class: section-divider -->

# Version the full agent definition

The versioned release includes instructions, a tool, the RAI policy, identity settings, routing,
and tracing.

<!-- Notes: A model plus a prompt is not the governed unit. -->

---

## Current Foundry agent model

A caller reaches the stable endpoint. Foundry routes the request to a pinned prompt-agent version.
That version can call the approved read-only OpenAPI operation.

<div class="cards">
<div class="card">

### Prompt agent

Each agent version includes the model, instructions, OpenAPI tool, and RAI policy.

</div>
<div class="card">

### Stable endpoint

The endpoint is created with the agent and routes callers to the selected version. The current
agent model carries its own endpoint and identity.

</div>
<div class="card">

### Unique identity

The Entra Agent Identity identifies the agent and protects its endpoint. The project managed
identity makes the downstream tool call.

</div>
</div>

> In this model, publishing the endpoint means selecting and pinning the active version.

<!-- Notes: Publishing to M365 or Teams remains a separate distribution gesture and is out of scope. -->

---

## Implementation tradeoffs

| Runtime pattern | Decision |
|---|---|
| Prompt agent | Selected. It provides the managed runtime, immutable versions, and stable endpoint this baseline needs. |
| Direct OpenAPI attachment | Selected. The agent version includes the OpenAPI definition, and the deployment files record the downstream role and assignment scope. |
| Foundry Toolbox | Use a future optional module when several agents need a curated reusable tool endpoint. Session 09 is the handoff when APIM and MCP controls are also required. |
| Hosted agent | Use a hosted agent when the workload needs code or container control. |
| Responses API only | The application would send the definition with each request. Foundry would not store a persistent agent resource. |

The decision record names `persistent-prompt-agent`.

<!-- Notes: Choose the smallest runtime that still exposes identity, version, and endpoint controls. -->

---

<!-- _class: decision -->

## Decision 1 - Agent name and release

Resolve before creation:

1. Fixed agent name and accountable owner.
2. [Session 04](../04-model-governance-lifecycle/) consolidated approval record and matching live ARM model deployment.
3. Named RAI policy.
4. Responses protocol with Entra authorization.
5. **Fixed-version routing, not "always latest."**

Stop if the name collides with an unmarked agent or a legacy agent has no unique identity.

The older Agent Application model used a shared development identity and created a distinct
identity at publication. The current agent receives its unique identity when it is created.

<!-- Notes: The current agent object receives its identity when created. -->

---

## The OpenAPI manifest exposes the approved GET operation

```text
policy_lookup
  OpenAPI 3.0.1
  GET <approved read path>
  operationId: get_policy
  auth: project managed_identity
  audience: approved downstream resource
```

No `POST`, `PUT`, `PATCH`, or `DELETE` operation is registered.

<!-- Notes: The API base URL is supplied at runtime and never committed. -->

---

<!-- _class: decision -->

## Decision 2 - Tool authority

The downstream API authorization owner approves the managed-identity read assignment before preflight.

**Stop** unless all are true:

- The operation is genuinely read-only despite using GET.
- The Entra audience matches the downstream resource.
- `tool-manifest.json` records the approved read role definition ID and downstream API resource scope.
- Preflight finds one matching assignment for the Foundry project managed identity.
- The API path, data classification, and owner are approved.
- The release record lists how a person can request and approve the blocked write action.

This is an application-only boundary. The downstream API sees the project managed identity. It
does not receive a signed-in human token.

If the API must authorize each signed-in user, use a separately approved delegated-access implementation.

System instructions reinforce the boundary. They do not create it.

<!-- Notes: The agent keeps a unique identity; Microsoft OpenAPI guidance assigns managed-identity tool calls to the project identity. -->

---

## RAI policy, refusal instructions, and authorization

<div class="cards">
<div class="card">

### Platform

The safety owner compares the policy's input and output severity settings with the approved minimum filters in `agent.json`.

</div>
<div class="card">

### Agent

Defines refusal behavior and the untrusted-tool-output rule.

</div>
<div class="card">

### Authorization

The agent has no write tool. Use the approved read role at the downstream API resource scope.

</div>
</div>

<!-- Notes: Keep the layers separate so no single control is overstated. -->

---

## Tracing without accidental disclosure

- Connect the existing Application Insights resource to the project.
- Use Foundry server-side tracing. This session needs no client instrumentation.
- Restrict trace readers. Name who sets retention and monitors cost.
- Use the synthetic check prompt during this session.
- Keep prompts, responses, tool payloads, tokens, and trace exports out of the repository.

Tracing can capture content, tool use, tokens, latency, retries, and cost.

<!-- Notes: Observability creates a data boundary that requires explicit ownership. -->

---

## Architecture overview

<!-- _class: diagram -->

![A fixed prompt-agent version sits between its version-controlled definition and a pinned endpoint protected by a unique Entra Agent Identity. A separate Foundry project managed identity makes the only OpenAPI GET call to the approved API. The write path is absent, while the configured RAI policy and Application Insights tracing remain attached to the version.](assets/diagrams/governed-agent-flow.svg)

<!-- Notes: The endpoint identity and project identity do different jobs. The control ends at the direct read API. -->

---

## What this means

A caller enters through the stable endpoint. Foundry uses the agent identity at that boundary,
routes the request to the pinned version, and uses the project managed identity for the one
OpenAPI GET call.

Foundry holds the live identity, versions, routing, and RAI policy. Git holds the version
definition. This baseline covers calls through the direct read API. Session 07 uses the pinned
endpoint.

---

## Operational controls

```text
agents/policy-assistant/
  agent.json
  instructions.md
  tool-manifest.json
scripts/
  preflight.ps1
  deploy.ps1
  manual removal guidance
```

Keep runtime endpoints, IDs, prompts, responses, and traces out of source control.

---

<!-- _class: implementation -->

## Create and pin the governed agent

Timebox: 180 minutes

1. Resolve the agent, RAI, tool, prohibited-action, and tracing decisions with the responsible owner.
2. Run preflight and inspect its read-only planned-change summary.
3. Create a fixed agent version.
4. Pin the stable Responses endpoint and confirm the unique identity.
5. Read a synthetic policy through `get_policy`.

<!-- Notes: Stop before creation if any authority or logs boundary is unresolved. -->

---

## Preflight inventory and safety checks

Implementation definitions: recorded owners, approved model and RAI policy, the `get_policy`
GET operation, no write operation, and no live endpoint in source.

Live Foundry resources: approved subscription and project, `AIServices` resource, Foundry User role ID, model deployment, Application Insights connection, downstream assignment, existing-agent marker, and unique Entra Agent Identity.

Foundry has no data-plane agent `what-if`. Preflight uses a read-only lookup and a specific change summary.

The portal can pin a version. Protocol, authorization, and agent-card settings require the REST API
or SDK. Use the scripts and API response to check them.

<!-- Notes: This is an explicit platform limitation, not a reason to skip preview. -->

---

## Create and pin

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -ProjectName $projectName `
  -ReadApiBaseUrl $readApiBaseUrl
```

**Expected configuration:** a new fixed version, unique identity, a Responses endpoint with Entra
authorization, and 100% traffic pinned to that version.

<!-- Notes: Foundry retains the active version and endpoint selector. -->

---

## Confirm the result

Use the stable endpoint once with synthetic policy `POL-001`.

Ask `get_policy` to return approved fields. Confirm that the project managed identity is authorized
and no other tool runs.

The Entra Agent Identity identifies the agent.

The project managed identity authenticates this direct application-only OpenAPI read. No signed-in
human token is forwarded.

Do not retain the response or export the trace.

<!-- Notes: One visible standard-mode check is enough. -->

---

## Live agent and ownership

| Resource or setting | Owner |
|---|---|
| Agent behavior and pinned release | AI product owner |
| Endpoint access, Entra Agent Identity, and downstream authorization | Platform/identity owner |
| RAI policy | Safety owner |
| OpenAPI definition and procedure for human-approved writes | API/policy owner |
| Trace access, retention, and cost | Operations owner |

Removal deletes only the marked Session 05 agent and its versions.

<!-- Notes: The model, API, project, RAI policy, and logs resource remain. -->

---

## Recap

- Create a persistent prompt agent with a unique Entra Agent Identity.
- Pin its stable endpoint to the implemented version.
- Register the GET-only tool and keep the write action absent.
- Apply the RAI policy in `agent.json`. The operations owner manages trace access, retention, and cost.

Next, place the governed endpoint behind the [Session 07 APIM AI gateway](../07-apim-ai-gateway/).

<!-- Notes: The customer now owns the baseline that later sessions extend. -->

---

<!-- _class: closing -->

# Thank you!
