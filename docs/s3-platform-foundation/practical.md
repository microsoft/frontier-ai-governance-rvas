# Practical workshop: trace one platform route

**Microsoft default:** Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking where risk requires it, Azure API Center, and Azure Monitor/Application Insights.

**Customer decision:** Can this pilot route be used as a named platform path for
later runtime, evaluation, and control-plane work without pretending it is
deployed, private, observable, or production-ready?

## Facilitation flow

1. **Choose the pilot platform question.** Select one bounded pilot or backlog item. Name the customer decision owner, platform owner, security owner, network owner if relevant, telemetry owner, and evidence record location.
2. **Draw the platform route.** Record caller, app/orchestrator, hosting pattern,
   landing-zone boundary, gateway ingress, model/API/tool egress, data
   dependency, identity boundary, network/private route, telemetry/logging,
   retention/export, and API Center/catalog record.
3. **Classify the hosting pattern.** Record whether the pilot is Foundry-hosted,
   Azure app-hosted, managed SaaS, hybrid, non-Azure, unsupported, or exception
   routed. Record tenant, region, SKU, license, workload, and support caveats.
4. **Inspect the gateway and egress route.** Record where caller authority
   changes, where APIM/gateway is expected to mediate access, which backend/model
   route it reaches, which tool/API egress paths are covered, which routes bypass
   it, and which owner can approve changes.
5. **Inspect private-network and dependency assumptions.** If the pilot relies on
   private routing, hybrid systems, data stores, tools, or managed service
   boundaries, record Private Link, VNet/subnet, private DNS, firewall/NSG, route
   table, public-endpoint exception, flow-log route, and owner. If the route is
   public by design, record the policy approval owner and compensating
   gateway/telemetry expectations.
6. **Map identity boundaries.** Separate human caller, workload identity, managed
   identity/app registration, OBO/delegated authority, gateway identity, tool/API
   identity, and resource authorization. Route shared, broad, unowned, or
   unsupported identity boundaries to the accountable owner.
7. **Inspect telemetry, correlation, and retention.** Name the expected trace
   field, propagation point, log destinations, reviewer, known blind spots,
   retention/export owner, and approved evidence route. Record absent coverage
   plainly; planned telemetry is not proof that events exist.
8. **Assign registry/catalog and downstream evidence owners.** Record API Center
   or catalog status for APIs, tools, model endpoints, gateway routes, backends,
   versions, lifecycle states, owners, and exceptions. Name runtime, evaluation,
   and catalog/control-plane evidence questions.
9. **Record the outcome and handoff.** Approve only when the route record is
   complete enough for the next owner to act. Otherwise defer with named
   acceptance checks, reject unsafe or unsupported assumptions, or route to the
   accountable platform, network, security, telemetry, architecture, product
   support, identity, or catalog owner.

## Workshop artifact

| Artifact field | Capture prompt |
|---|---|
| Pilot route | Which caller, workload, environment, business purpose, and platform path are in scope? |
| Route map | What is the caller -> app/orchestrator -> gateway -> model/tool/data -> telemetry/catalog path? |
| Hosting pattern | Is it Foundry-hosted, Azure app-hosted, managed SaaS, hybrid, non-Azure, unsupported, or exception-routed? |
| Gateway boundary | Which ingress, backend/model route, tool/API egress, policy owner, log owner, and bypasses apply? |
| Private route | Which public/private/managed VNet/BYO VNet/hybrid/deferred path applies, and who owns Private Link, DNS, VNet, firewall, and flow logs? |
| Identity boundary | Which human, workload, gateway, OBO, tool/API, and resource identities cross authority boundaries? |
| Telemetry/correlation | Which trace key or time-window method connects gateway, app, model, tool, data, and log records? |
| Retention/export | Who owns log retention, approved export, evidence access, deletion/hold, and records management? |
| Registry/catalog | Which API Center/catalog/model/tool route entry, version, lifecycle state, owner, and exception status apply? |
| Decision | Proceed with assumptions, defer, route, reject, or blocked with owner, target date, release impact, and review trigger. |

## Scenario examples

| Scenario | Route | Practical decision cue |
|---|---|---|
| Foundry-hosted pilot with named project and model route | Foundry platform path | Proceed with assumptions only when project/workspace, model deployment, network mode, tool configuration, observability route, owner, and support caveats are recorded. |
| Azure app route fronted by APIM | APIM gateway path | Proceed when API/product/policy/backend, auth owner, model/backend mapping, tool/API egress, gateway logs, correlation field, and bypass owner are recorded. |
| Direct route without gateway | Gateway backlog path | Defer gateway proof; record app-only controls, direct-route owner, proposed gateway owner, release impact, and runtime evidence limitation. |
| Private network dependency | Private Link/VNet/DNS path | Defer until Private Endpoint, private DNS, VNet/subnet, firewall/NSG, route table, public endpoint exception, and network telemetry owners are named. |
| Hybrid or externally managed dependency | Hybrid boundary path | Route until boundary owner, route owner, support owner, log/export path, retention owner, and incident escalation route are recorded. |
| Managed SaaS with limited telemetry | SaaS visibility path | Defer or route unless available audit/export fields, unavailable fields, retention expectation, support boundary, and compensating review route are explicit. |
| Missing correlation ID path | Telemetry/correlation backlog path | Defer runtime or evaluation reliance until trace/correlation source, propagation expectation, log destination, reviewer, and blind spots are recorded. |
| API/tool/model route missing from registry | API Center/catalog backlog path | Route to catalog/control-plane owner until route, backend, version, lifecycle state, owner, and exception status are recorded. |
| Unsupported region, SKU, license, tenant, or workload | Capability blocker | Record unsupported slice, official/support check needed, alternate route if any, owner, target date, and release impact. |

## Existing profile cues

Evidence-reference example: landing-zone subscription, resource group, Foundry
project/workspace, API Center entry, gateway record, network boundary, and
monitoring workspace are named in customer-approved systems.

Defer blocker example: the pilot cannot name the hosting boundary, authoritative
platform owner, gateway route, telemetry destination, correlation field, registry
record, or records system.

## Decision record

Fill this record in the customer-approved records system. Store only template output and references here; completed evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Pilot platform-route readiness decision |
| Platform-route trace | Caller, app/orchestrator, gateway, model/tool/data route, telemetry/catalog path |
| Hosting pattern | Foundry-hosted, Azure app-hosted, managed SaaS, hybrid, non-Azure, unsupported, or exception route |
| Trust boundary | Caller, app, gateway, model/service, tool, data, administrator, and identity authority changes |
| Gateway/egress route | Expected ingress, egress, API Management AI Gateway or customer-approved route, backend, identity boundary, bypasses, and change owner |
| Private-network decision | Public, private, managed VNet, bring-your-own VNet, hybrid, deferred, or unsupported route; required Private Link/DNS/VNet/firewall/flow-log owners |
| Identity boundary | Human, workload, managed identity/app registration, delegated/OBO, gateway, tool/API, and resource authorization boundaries |
| Telemetry/correlation path | Expected log destinations, trace or correlation field, propagation point, reviewer, coverage limits, blind spots, and empty-result interpretation |
| Retention/export expectation | Retention period or policy reference, export/discovery owner, evidence-reference location, and deletion/hold expectation |
| Platform owner | Accountable platform owner plus network, security, telemetry, support, and architecture owners where different |
| Runtime handoff | Gateway route, correlation source, retention owner, reviewer, stop condition, and runtime-assurance prerequisites |
| Evaluation handoff | Evaluation environment assumptions, data/tool boundary notes, evidence expectations, and unresolved platform constraints |
| Control-plane handoff | API Center/control-plane/catalog owner, route registry status, version/lifecycle owner, gateway/backend mapping, and exception/backlog references |
| Defer criteria | Missing owner, unsupported route, unvalidated support status, absent correlation, unknown retention/export owner, incomplete private-network decision, or incomplete runtime/evaluation/control-plane prerequisite |
| Acceptance checks | Decision owner, platform profile, trust boundary, route, telemetry/correlation, retention/export, owner handoff, exception status, target date, and downstream prerequisites are complete |

## Decision tree

- **Approve readiness** when the Microsoft path fits, owners are named, evidence references are in customer-approved systems, and runtime, evaluation, and control-plane owners can act on the handoff without assuming deployment or runtime proof.
- **Defer** when records, owners, support status, route details, correlation, retention/export, or private-network decisions are missing. Include acceptance checks, owner, target date, and review trigger.
- **Reject** when the proposed path cannot meet the platform-boundary question safely or relies on unsupported, unowned, or unreviewable assumptions.
- **Route** when an accountable platform, network, security, telemetry, architecture, product-support, or exception owner must decide before the pilot proceeds.

For an exception, record: reason, equivalent control or compensating review, owner, evidence location, acceptance check, target date, downstream handoff impact, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval. S3 records readiness decisions and handoffs only; it does not deploy resources, alter tenant policy, validate live traffic, prove enforcement, or approve production use.
