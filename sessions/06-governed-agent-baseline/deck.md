---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 06</p>

# Governed Microsoft Foundry agent baseline

**240 minutes - One versioned agent, one read tool, no write path**

<!-- Notes: Establish the agent identity, version, tool, safety, and tracing controls before adding APIM and MCP. -->

---

## Control objective

> Create and pin one versioned prompt agent. Its Entra Agent Identity identifies the agent. The Foundry project managed identity authorizes one read-only OpenAPI tool. No write tools are added.

### Result check

- One prompt-agent version is created from implementation definitions.
- The stable endpoint is Entra-authorized and pinned to that version.
- The tool surface contains one GET operation and no write operation.
- One synthetic read returns only the approved fields through `get_policy`.

<!-- Notes: The enforceable boundary is the absent tool plus downstream authorization, not prompt wording alone. -->

---

## Implementation outcomes

1. Create one persistent prompt agent from approved instructions and configuration.
2. Use a unique Entra Agent Identity for the agent and endpoint boundary.
3. Use the project managed identity for one application-only, GET-only OpenAPI tool.
4. Apply the RAI policy from `agent.json` and server-side tracing.
5. Pin the stable Responses endpoint to the implemented version.

<!-- Notes: Session 07 fronts this endpoint with APIM; Session 09 introduces MCP controls. -->

---

## Why it matters

A pinned version gives the release owner one known agent configuration to operate.

The Entra Agent Identity identifies the agent and secures its endpoint.

The Foundry project managed identity does a separate job: it authorizes the direct OpenAPI read.

<!-- Notes: Do not collapse the agent identity and project identity into one control claim. -->

---

## Control boundaries

- One prompt agent in the approved nonproduction Foundry project
- One application-only read through the project managed identity
- No write tool and no delegated user authorization
- Live Foundry state is the source of truth; repository definitions own intended configuration
- APIM, MCP, distribution, and evaluations remain later review records

<!-- Notes: Instructions reinforce the boundary. Tool absence and downstream authorization enforce it. -->

---

<!-- _class: section-divider -->

# Version the full agent configuration

Instructions, tools, identity, safety, routing, and logs form one release unit.

<!-- Notes: A model plus a prompt is not the governed unit. -->

---

## Current Foundry agent model

The caller reaches one stable endpoint. Foundry routes that traffic to a pinned prompt-agent version,
which may call one read-only OpenAPI operation.

<div class="cards">
<div class="card">

### Prompt agent

One versioned release contains the model, instructions, OpenAPI tool, and RAI policy.

</div>
<div class="card">

### Stable endpoint

The endpoint exists with the new agent and points callers to the selected version. No separate
Agent Application is required.

</div>
<div class="card">

### Unique identity

The Entra Agent Identity identifies the agent and protects its endpoint. The project managed
identity handles the downstream tool call.

</div>
</div>

> "Publish the endpoint" now means select and pin the active version.

<!-- Notes: Publishing to M365 or Teams remains a separate distribution gesture and is out of scope. -->

---

## Implementation tradeoffs

| Runtime pattern | Why it does or does not fit |
|---|---|
| Prompt agent | Selected. It provides the managed runtime, immutable versions, and stable endpoint this baseline needs. |
| Hosted agent | It adds code and container control that this read-only scenario does not need. |
| Responses API only | The application would own an ephemeral definition, so Foundry would hold no persistent agent resource. |

The decision record explicitly names `persistent-prompt-agent`.

<!-- Notes: Choose the smallest runtime that still exposes identity, version, and endpoint controls. -->

---

<!-- _class: decision -->

## Decision 1 - Agent name and release

Resolve before creation:

1. Fixed agent name and accountable owner.
2. [Session 05](../05-model-governance-lifecycle/) consolidated approval record and matching live ARM model deployment.
3. Named RAI policy.
4. Responses protocol with Entra authorization.
5. Fixed-version routing, not "always latest."

Stop on an unmarked name collision or legacy agent with no unique identity.

<!-- Notes: A legacy shared-identity agent is recreated under a new governed name. -->

---

## The OpenAPI manifest exposes one GET operation

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

The downstream API authorization owner must approve the managed-identity read assignment before preflight.

Stop unless all are true:

- The operation is genuinely read-only despite using GET.
- The Entra audience matches the downstream resource.
- `tool-manifest.json` records the approved read role definition ID and downstream API resource scope.
- Preflight finds one matching assignment for the Foundry project managed identity.
- The API path, data classification, and owner are approved.
- The blocked write action has a human route listed in the release record.

This is an application-only boundary. The downstream API sees the project managed identity, not a signed-in human token.

If the API must authorize each signed-in user, use the separately approved delegated-access implementation.

System instructions reinforce this boundary; they do not create it.

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

Refusal instructions and untrusted-tool-output rule.

</div>
<div class="card">

### Authorization

No write tool. One approved read role at the downstream API resource scope.

</div>
</div>

<!-- Notes: Keep the layers separate so no single control is overstated. -->

---

## Tracing without accidental disclosure

- Connect the existing Application Insights resource to the project.
- Use Foundry server-side tracing; no client instrumentation is required here.
- Restrict readers and assign retention/cost ownership.
- Use only the synthetic check prompt during this session.
- Never retain prompts, responses, tool payloads, tokens, or trace exports.

Tracing can capture content, tool use, tokens, latency, retries, and cost.

<!-- Notes: Observability creates a data boundary that requires explicit ownership. -->

---

## Architecture overview

![A fixed prompt-agent version sits between its version-controlled definition and a pinned endpoint protected by a unique Entra Agent Identity. A separate Foundry project managed identity makes the only OpenAPI GET call to the approved API. The write path is absent, while the configured RAI policy and Application Insights tracing remain attached to the version.](assets/diagrams/governed-agent-flow.svg)

The caller enters through the stable endpoint. Foundry uses the agent identity at that boundary,
routes the request to the pinned version, then uses the project managed identity for the single
OpenAPI GET call.

Foundry owns live identity, versions, and routing. Git holds the intended configuration and release
record. The control ends at the direct read API; Session 07 receives the pinned endpoint.

<!-- Notes: The endpoint identity and project identity do different jobs. The control ends at the direct read API. -->

---

## Operational control tree

```text
agents/policy-assistant/
  agent.json
  instructions.md
  tool-manifest.json
  prohibited-actions.json
operations/release-operations.json
scripts/
  preflight.ps1
  deploy.ps1
  manual removal guidance
```

Runtime endpoints, IDs, prompts, responses, and traces stay out of source control.

---

<!-- _class: implementation -->

## Create and pin the governed agent

**Timebox: 240 minutes**

1. Resolve the agent, RAI, tool, prohibition, and tracing decisions.
2. Run preflight and inspect the read-only mutation summary.
3. Create one fixed agent version.
4. Pin the stable Responses endpoint and confirm unique identity.
5. Read one synthetic policy through `get_policy`.

<!-- Notes: Stop before creation if any authority or logs boundary is unresolved. -->

---

## Preflight inventory and safety checks

**Implementation definitions:** recorded owners, approved model and RAI policy, one `get_policy` GET operation, no write operation, and no live endpoint in source.

**Live Foundry resources:** approved subscription and project, `AIServices` resource, Foundry User role ID, model deployment, Application Insights connection, downstream assignment, existing-agent marker, and unique Entra Agent Identity.

Foundry has no data-plane agent `what-if`; preflight uses read-only lookup plus an specific change summary.

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

Expected state: one new fixed version, unique identity, Responses + Entra endpoint, 100% pinned traffic.

<!-- Notes: The deployment updates the current version and source-hash fields in `release-operations.json` only. -->

---

## Confirm the result

Use the stable endpoint once with synthetic policy `POL-001`.

Ask `get_policy` to return only approved fields. Confirm the project managed identity is authorized and no other tool runs.

The Entra Agent Identity identifies the agent.

The project managed identity authenticates this direct application-only OpenAPI read. No signed-in human token is forwarded.

Do not retain the response or export the trace.

<!-- Notes: One visible standard-mode check is enough. -->

---

## Live state and ownership

| Live state | Owner |
|---|---|
| Agent behavior and pinned release | AI product owner |
| Endpoint access and identity authority | Platform/identity owner |
| RAI policy | Safety owner |
| Tool contract and human change route | API/policy owner |
| Trace access, retention, and cost | Operations owner |

Removal deletes only the marked Session 06 agent and its versions.

<!-- Notes: The model, API, project, RAI policy, and logs resource remain. -->

---

## Recap

- Create one persistent prompt agent with a unique Entra Agent Identity.
- Pin its stable endpoint to the implemented version.
- Register one GET-only tool and keep the blocked write action absent.
- Apply the RAI policy from `agent.json` and assign trace ownership.

Next: place the governed endpoint behind the [Session 07 APIM AI gateway](../07-apim-ai-gateway/).

<!-- Notes: The customer now owns the baseline that later sessions extend. -->

---

<!-- _class: closing -->

# Thank you!
