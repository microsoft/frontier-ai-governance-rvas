# Practical workshop: scenario-driven platform boundary readiness

**Microsoft default:** Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking where risk requires it, Azure API Center, and Azure Monitor/Application Insights.

**Customer decision:** Approve, defer, reject, or route the platform foundation path for the pilot. The decision is a readiness and handoff decision, not a deployment, live-policy change, runtime proof, or production approval.

## Work the decision

1. **Choose the pilot platform question.** Select one bounded pilot or backlog item. Name the customer decision owner, platform owner, security owner, network owner if relevant, telemetry owner, and evidence record location.
2. **Build the platform profile.** Record the expected hosting pattern, environment boundary, data/tool dependencies, model or agent service boundary, gateway assumption, registry assumption, and known platform maturity limits.
   - Evidence-reference example: landing-zone subscription, resource group, Foundry project/workspace, API Center entry, gateway record, network boundary, and monitoring workspace are named in customer-approved systems.
   - Defer blocker example: the pilot cannot name the hosting boundary, authoritative platform owner, gateway route, telemetry destination, or record system.
3. **Classify the scenario route.** Decide which practical scenario best fits the pilot before discussing acceptance:

| Scenario | Route | Practical decision cue |
|---|---|---|
| Managed SaaS agent with limited customer telemetry | SaaS/platform-owner path | Defer or route unless the customer can name the platform owner, available audit/export fields, retention expectation, support boundary, and compensating review route for telemetry blind spots. |
| Custom app or API gateway route | Azure API Management AI Gateway or Citadel-aligned gateway path | Approve only as ready-for-handoff when ingress, egress, identity boundary, backend route, correlation field, logging expectation, and gateway owner are recorded. |
| Private network dependency | Private Link/VNet/DNS/network-owner path | Defer until required private endpoints, DNS, routing, firewall or egress controls, and network validation owner are named. S3 does not test reachability. |
| Missing correlation ID path | Telemetry/correlation backlog path | Defer S6 handoff until a trace/correlation source, propagation expectation, log destination, reviewer, and known blind spots are recorded. |
| Retention or export owner unknown | Records and observability ownership path | Defer until log retention, export, discovery, evidence reference, and deletion/hold expectations have named owners. |
| Platform support not yet production-validated | Architecture/support readiness path | Route to architecture, product support, or platform engineering with support status, assumption owner, target date, and stop condition. Do not claim production readiness. |
| S6/S7/S9 prerequisites incomplete | Runtime/evaluation/control-plane handoff path | Defer the downstream handoff until gateway route, telemetry/correlation, evaluation evidence expectation, registry/control-plane owner, and review criteria are complete. |

4. **Inspect trust boundary and route.** Record where caller authority changes, where the AI gateway is expected to mediate access, what leaves the boundary, and which owner can approve changes to that path.
   - Acceptance-test cue: the handoff can point S6 to the expected gateway route and correlation source, S7 to evaluation/environment assumptions, and S9 to the registry/control-plane owner without copying customer evidence into this repo.
5. **Inspect private-network and dependency assumptions.** If the pilot relies on private routing, hybrid systems, data stores, tools, or managed service boundaries, record the route owner and what must be evidenced later. If the route is public by design, record the policy approval owner and compensating gateway/telemetry expectations.
6. **Inspect telemetry, correlation, and retention.** Name the expected trace field, log destinations, correlation propagation point, retention/export owner, and known gaps. Record absent coverage plainly; planned telemetry is not proof that events exist.
7. **Record the outcome and handoff.** Approve only when the readiness record is complete enough for the next owner to act. Otherwise defer with named acceptance checks, reject unsafe or unsupported assumptions, or route to the accountable platform, network, security, telemetry, architecture, or product-support owner.

## Decision record

Fill this record in the customer-approved records system. Store only template output and references here; completed evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Pilot platform-boundary readiness decision |
| Platform profile | Hosting pattern, environment boundary, platform/service maturity, data/tool dependencies, registry assumption, and known limits |
| Trust boundary | Caller, app, gateway, model/service, tool, data, and administrator authority changes |
| Gateway/egress route | Expected ingress, egress, API Management AI Gateway or Citadel-aligned route, backend, identity boundary, and change owner |
| Private-network decision | Public, private, managed VNet, bring-your-own VNet, hybrid, or deferred route; required Private Link/DNS/VNet/firewall owners |
| Telemetry/correlation path | Expected log destinations, trace or correlation field, propagation point, reviewer, coverage limits, and blind spots |
| Retention/export expectation | Retention period or policy reference, export/discovery owner, evidence-reference location, and deletion/hold expectation |
| Platform owner | Accountable platform owner plus network, security, telemetry, support, and architecture owners where different |
| S6 handoff | Gateway route, correlation source, retention owner, reviewer, stop condition, and runtime-assurance prerequisites |
| S7 handoff | Evaluation environment assumptions, data/tool boundary notes, evidence expectations, and unresolved platform constraints |
| S9 handoff | API Center/control-plane/catalog owner, route registry status, lifecycle owner, and exception/backlog references |
| Defer criteria | Missing owner, unsupported route, unvalidated support status, absent correlation, unknown retention/export owner, incomplete private-network decision, or incomplete S6/S7/S9 prerequisite |
| Acceptance checks | Decision owner, platform profile, trust boundary, route, telemetry/correlation, retention/export, owner handoff, exception status, target date, and downstream prerequisites are complete |

## Decision tree

- **Approve readiness** when the Microsoft path fits, owners are named, evidence references are in customer-approved systems, and S6/S7/S9 can act on the handoff without assuming deployment or runtime proof.
- **Defer** when records, owners, support status, route details, correlation, retention/export, or private-network decisions are missing. Include acceptance checks, owner, target date, and review trigger.
- **Reject** when the proposed path cannot meet the platform-boundary question safely or relies on unsupported, unowned, or unreviewable assumptions.
- **Route** when an accountable platform, network, security, telemetry, architecture, product-support, or exception owner must decide before the pilot proceeds.

For an exception, record: reason, equivalent control or compensating review, owner, evidence location, acceptance check, target date, downstream handoff impact, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval. S3 records readiness decisions and handoffs only; it does not deploy resources, alter tenant policy, validate live traffic, prove enforcement, or approve production use.
