# S6 · Runtime Path Evidence & Response

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the
    [Governance capability guide](../reference/governance-capability-guide.md).
    Verify tenant support, region, licensing, telemetry access, and customer
    policy before delivery.

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">Governance lead</span>

!!! abstract "What is at stake"
    A runtime control is only useful when the customer can see the request path,
    the decision it made, the evidence it produced, and the owner who responds.

## 1. Test one runtime path

Trace one bounded non-production request through its runtime path, then decide
whether the customer can rely on the evidence it produces.

Answer this:

> Can this request be traced through the expected runtime path, policy decision
> points, telemetry, SOC route, and retention process well enough for named
> customer reviewers to accept or reject the runtime-control claim?

Check the following:

- A runtime-path trace card naming caller identity, application/workload
  identity, gateway or app-only route, backend model/agent, tool/API route,
  response path, correlation field, telemetry destination, SOC route, retention
  owner, and approved records location.
- Gateway proof and telemetry correlation using safe references and
  the [`gateway-proof`](../../contracts/gateway-proof.schema.json) manifest
  shape.
- A control-placement map that separates identity/network, gateway, model/agent,
  app/in-process, tool, SOC, operating, and records controls.
- A threat-to-control map for prompt injection, harmful content, data leakage,
  unsupported answers, tool abuse, unauthorized access, cost/availability abuse,
  and route bypass.
- A customer reviewer decision: accept, defer, reject, route, block, or mark
  diagnostic-only.

The adapter does not deploy a safety platform, configure APIM, change live
policy, or prove a direct Content Safety call. A completed request is transport
evidence, not a security decision. The customer platform and security owners
must match the `correlation_id` to customer-owned telemetry before accepting it
as runtime-path evidence.

### What happens next

**Next customer action:** assign any route, policy, telemetry, correlation, SOC,
retention, or reviewer gap to the customer platform/gateway, application,
identity, security, SOC, observability, data/privacy, runtime assurance,
evaluation, catalog/control-plane, operations, or records owner.

### Plain decision and default path

**Decision question:** *Accept, defer, reject, route, block, or mark
diagnostic-only for this bounded runtime-control claim?* Acceptance is a
customer decision for the reviewed path; it is not deployment,
enforcement proof, live-policy change, production-control approval, or
production approval.

The default is layered Azure/Microsoft enforcement:

1. Microsoft Entra identity and network controls for route access.
2. Azure API Management AI Gateway or an approved customer gateway where shared
   runtime controls fit.
3. Azure AI Content Safety, Prompt Shields, Foundry model/agent controls, or
   app/in-process controls where the inspection point requires them.
4. Tool/API controls for tool calls, tool parameters, tool responses, and local
   action boundaries.
5. Defender for Cloud AI posture, Defender XDR, Sentinel, SOC playbooks, and
   Application Insights/Azure Monitor for detection, response, correlation, and
   retention where enabled.

Use application-only enforcement or another customer control only when route
coverage, context visibility, latency, capability status, and evidence ownership
make the default unsuitable. Name the exception owner, reason, compensating
control, target event, recheck condition, and exact claim that remains unsupported.

## 2. Prerequisites

- One bounded non-production request path and one customer-approved test scope.
- Customer-owned request, telemetry, SOC, and records locations.
- Named application, gateway/platform, identity, security, SOC, telemetry,
  retention, evidence, and reviewer owners.
- Authorization to inspect customer records without exporting raw evidence into
  this repository.
- Known correlation field or a backlog owner for creating one.

If the route owner, correlation propagation, telemetry destination, SOC queue,
retention owner, or customer reviewer is missing, the safe result is defer,
route, block, or diagnostic-only.

## 3. Make the runtime path reviewable

Runtime security is reviewable only when the path is reviewable. "Content Safety
is enabled" or "APIM is in front" is not enough. The customer needs to know where
the control runs, what it inspects, what action it takes, what telemetry it
emits, how the event joins to the request, who reviews the interpretation, and
what happens when the control fails or is bypassed.

S6 establishes the runtime-path review. It does not publish a route, configure a
gateway, grant access, run production traffic, export logs, prove production
enforcement, or approve production.

## 4. Change boundary and handoff

S6 changes no gateway configuration, app code, model setting, SOC rule, live
policy, tenant setting, alert route, retention policy, or lifecycle state. Any
deployment, configuration, permission grant, runtime test, incident workflow, or
production release follows the customer's approved change and evidence process.

Release-assurance handoff includes accepted runtime-path evidence and its
limits. Catalog/control-plane handoff includes the route, owner, version,
runtime-control exception, material-change triggers, and open blockers.
