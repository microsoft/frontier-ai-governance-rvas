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

**180 minutes - A versioned agent, a read tool, no write path**

<!-- Notes: Establish the agent identity, version, tool, safety, and tracing controls before adding APIM and MCP. -->

---

## Control objective

> Create and pin a versioned prompt agent. Its Entra Agent Identity identifies the agent. The Foundry project managed identity authorizes the approved read-only OpenAPI tool. No write tools are added.

### Result check

- One prompt-agent version is created from `agent.json`, `instructions.md`, and `tool-manifest.json`.
- The stable endpoint is Entra-authorized and pinned to that version.
- The agent definition exposes the GET operation and no write operation.
- One synthetic read returns only the approved fields through `get_policy`.

<!-- Notes: The enforceable boundary is the absent tool plus downstream authorization, not prompt wording alone. -->

---

## Implementation outcomes

1. Create a persistent prompt agent from approved instructions and configuration.
2. Use a unique Entra Agent Identity to identify the agent and secure its endpoint.
3. Use the project managed identity for the approved application-only, GET-only OpenAPI tool.
4. Apply the RAI policy from `agent.json` and server-side tracing.
5. Pin the stable Responses endpoint to the implemented version.

<!-- Notes: Session 06 fronts this endpoint with APIM; Session 08 introduces MCP controls. -->

---

## Why it matters

A pinned version gives the release owner a known agent configuration to operate.

The Entra Agent Identity identifies the agent and secures its endpoint.

The Foundry project managed identity does a separate job: it authorizes the direct OpenAPI read.

<!-- Notes: Do not collapse the agent identity and project identity into one control claim. -->

---

## Control boundaries

- One prompt agent in the approved nonproduction Foundry project
- One application-only read through the project managed identity
- No write tool and no delegated user authorization
- Inspect Foundry for the live state; repository definitions specify the configuration to deploy
- APIM, MCP, distribution, and evaluations remain later-session work

<!-- Notes: Instructions reinforce the boundary. Tool absence and downstream authorization enforce it. -->

---

<!-- _class: section-divider -->

# Version the full agent configuration

Instructions, tools, identity, safety, routing, and logs form a versioned release.

<!-- Notes: A model plus a prompt is not the governed unit. -->

---

## Current Foundry agent model

The caller reaches the stable endpoint. Foundry routes that traffic to a pinned prompt-agent version,
which may call the approved read-only OpenAPI operation.

<div class="cards">
<div class="card">

### Prompt agent

Each agent version includes the model, instructions, OpenAPI tool, and RAI policy.

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
| Direct OpenAPI attachment | Selected. The agent version includes the OpenAPI definition, and the deployment files record the downstream role and assignment scope. |
| Foundry Toolbox | Defer to an optional module when several agents need a curated, reusable tool endpoint. Session 08 is the handoff when APIM and MCP controls are also required. |
| Hosted agent | It adds code and container control that this read-only scenario does not need. |
| Responses API only | The application would send the definition for each request, and Foundry would store no persistent agent resource. |

The decision record explicitly names `persistent-prompt-agent`.

<!-- Notes: Choose the smallest runtime that still exposes identity, version, and endpoint controls. -->

---

<!-- _class: decision -->

## Decision 1 - Agent name and release

Resolve before creation:

1. Fixed agent name and accountable owner.
2. [Session 04](../04-model-governance-lifecycle/) consolidated approval record and matching live ARM model deployment.
3. Named RAI policy.
4. Responses protocol with Entra authorization.
5. Fixed-version routing, not "always latest."

Stop on an unmarked name collision or legacy agent with no unique identity.

The older Agent Application model used a shared identity during development and created a distinct
identity at publication. This current agent receives its unique identity when it is created.

<!-- Notes: Do not apply the older publish-time identity rule to the current agent object model. -->

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

The downstream API authorization owner must approve the managed-identity read assignment before preflight.

Stop unless all are true:

- The operation is genuinely read-only despite using GET.
- The Entra audience matches the downstream resource.
- `tool-manifest.json` records the approved read role definition ID and downstream API resource scope.
- Preflight finds one matching assignment for the Foundry project managed identity.
- The API path, data classification, and owner are approved.
- The release record lists how a person can request and approve the blocked write action.

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

No write tool. Use the approved read role at the downstream API resource scope.

</div>
</div>

<!-- Notes: Keep the layers separate so no single control is overstated. -->

---

## Tracing without accidental disclosure

- Connect the existing Application Insights resource to the project.
- Use Foundry server-side tracing; no client instrumentation is required here.
- Restrict trace readers and name who sets trace retention and monitors cost.
- Use only the synthetic check prompt during this session.
- Never retain prompts, responses, tool payloads, tokens, or trace exports.

Tracing can capture content, tool use, tokens, latency, retries, and cost.

<!-- Notes: Observability creates a data boundary that requires explicit ownership. -->

---

## Architecture overview

<!-- _class: diagram -->

![A fixed prompt-agent version sits between its version-controlled definition and a pinned endpoint protected by a unique Entra Agent Identity. A separate Foundry project managed identity makes the only OpenAPI GET call to the approved API. The write path is absent, while the configured RAI policy and Application Insights tracing remain attached to the version.](assets/diagrams/governed-agent-flow.svg)

<!-- Notes: The endpoint identity and project identity do different jobs. The control ends at the direct read API. -->

---

## What this means

The caller enters through the stable endpoint. Foundry uses the agent identity at that boundary,
routes the request to the pinned version, then uses the project managed identity for the single
OpenAPI GET call.

Inspect Foundry for the live identity, versions, routing, and RAI policy. Store the intended
configuration in Git. This implementation covers calls through the direct read API; Session 06
uses the pinned endpoint.

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

Runtime endpoints, IDs, prompts, responses, and traces stay out of source control.

---

<!-- _class: implementation -->

## Create and pin the governed agent

**Timebox: 180 minutes**

1. Ask the responsible implementation or platform owner to resolve each agent, RAI, tool, prohibited-action, and tracing decision.
2. Run preflight and inspect its planned-change summary, which is based on read-only lookups.
3. Create a fixed agent version.
4. Pin the stable Responses endpoint and confirm unique identity.
5. Read a synthetic policy through `get_policy`.

<!-- Notes: Stop before creation if any authority or logs boundary is unresolved. -->

---

## Preflight inventory and safety checks

**Implementation definitions:** recorded owners, approved model and RAI policy, the `get_policy` GET operation, no write operation, and no live endpoint in source.

**Live Foundry resources:** approved subscription and project, `AIServices` resource, Foundry User role ID, model deployment, Application Insights connection, downstream assignment, existing-agent marker, and unique Entra Agent Identity.

Foundry has no data-plane agent `what-if`; preflight uses read-only lookup plus a specific change summary.

The portal can pin a version, but protocol, authorization, and agent-card settings still require the
REST API or SDK. Use the scripts and API response to check those settings.

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

Expected state: a new fixed version, unique identity, Responses + Entra endpoint, and 100% pinned traffic.

<!-- Notes: Foundry retains the active version and endpoint selector. The deployment does not write a release record. -->

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
- Register the GET-only tool and keep the blocked write action absent.
- Apply the RAI policy from `agent.json`; the operations owner manages trace access, retention, and cost.

Next: place the governed endpoint behind the [Session 06 APIM AI gateway](../06-apim-ai-gateway/).

<!-- Notes: The customer now owns the baseline that later sessions extend. -->

---

<!-- _class: closing -->

# Thank you!
