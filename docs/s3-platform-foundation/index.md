# S3 · Enterprise Platform & Trust Boundaries

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Verify current capability availability, platform assumptions, and customer evidence before delivery.

## 1. Outcome & what the customer keeps

The customer leaves with a concrete trace of one platform route: who calls it,
where it enters the platform, which gateway or direct path it uses, which model,
tool, or data dependency it reaches, which identities cross boundaries, where
telemetry and correlation land, and which platform owners must close blockers
before later assurance relies on the route.

They leave with:

- A customer-owned **platform-route trace card** that names the caller,
  application or orchestrator, hosting pattern, landing-zone boundary, gateway
  ingress, model/API/tool egress, data dependency, identity boundary, telemetry
  path, retention/export owner, registry/catalog entry, decision status, and
  blocker or defer route.
- A **segment route map** for caller, app/orchestrator, gateway, model endpoint,
  tool/API egress, data dependency, network/private route, identity,
  telemetry/logging, retention/export, and API Center/catalog record.
- A **trust-boundary decision** for the route later assurance owners are being
  asked to use: proceed with stated assumptions, defer until a prerequisite is
  closed, route to a customer platform process, or stop because ownership,
  evidence, support status, or route scope is missing.
- A **gateway/APIM boundary statement** covering ingress, backend/model route,
  tool/API egress, policy owner, log owner, bypasses, and change owner.
- A **private-route decision** covering public, private, managed VNet,
  bring-your-own VNet, hybrid, deferred, or unsupported route, with Private
  Link, DNS, VNet/subnet, firewall/NSG, route-table, and network-telemetry
  owners where applicable.
- A **telemetry/correlation plan** that says where trace or correlation IDs
  originate, propagate, land, and fail across gateway, app, model, tool, data,
  and log records.
- A **registry/control-plane handoff** for API, tool, model, gateway route,
  backend, lifecycle, owner, version, and exception records where applicable.
- Gateway, network, telemetry, and correlation assumptions written as review
  inputs, not as proof that controls are deployed, operating, or approved for
  production.
- A blocker/defer list that identifies the customer process and owner for each
  prerequisite, such as architecture review, network design, identity review,
  security approval, release management, or evidence retention.
- An explicit handoff to runtime-assurance, evaluation, and catalog/control-plane
  owners that states what they may assess later and what S3 did not prove.

`labs/s3-platform-foundation/` contains blank offline templates only. Keep workload data, credentials, network details, event records, and completed evidence in the customer's approved system.

### Plain decision

**Question:** **Can this pilot route be used as a named platform path for later
runtime, evaluation, and control-plane work without pretending it is deployed,
private, observable, or production-ready?** Default to the Azure/Microsoft
platform pattern: Azure landing zones, Microsoft Foundry where supported, Azure
API Management AI Gateway or a customer-approved gateway for the AI boundary,
private networking where risk requires it, Azure Monitor/Application Insights
for telemetry, and Azure API Center for registry where applicable. An alternative
requires architecture-owner rationale, platform record location, acceptance
criterion, target date, and downstream impact. It is not a system change,
runtime proof, or production approval.

### What happens next

**Next customer action:** route the selected platform prerequisites to the
customer's architecture, network, identity, security, or release process before
asking runtime assurance to rely on the path.

S3 produces a platform backlog: proceed to runtime assurance only with stated
assumptions, close landing-zone, hosting-pattern, AI gateway, API Center,
private-connectivity, identity, telemetry, correlation, retention/export,
network/DNS, egress/tool, SaaS-support, or ownership prerequisites, or pause for
missing evidence.

The AI gateway is a trust boundary for runtime access, not proof of enforcement.
In this curriculum, that usually means Azure API Management acting as the
gateway layer for AI APIs, model access, tool routes, and selected policy
controls. Platform changes still go through the customer's architecture,
network, identity, security, or release processes before runtime, evaluation, or
catalog decisions rely on the path.

## 2. Platform-route trace card

Use this list to make the platform-readiness decision inspectable. It captures
the route the review believes is intended, what is merely assumed, and where a
blocker must be routed. Do not paste customer evidence into the list; record
references to customer-approved systems only.

| Field | What this list captures |
| --- | --- |
| Pilot route | The caller, workload, environment, business purpose, and target platform path being reviewed. |
| Hosting pattern | The intended platform shape, such as Foundry-hosted, Azure app-hosted, gateway-fronted API access, managed SaaS, private workload, hybrid dependency, or unsupported pattern requiring architecture-owner review. |
| Environment boundary | The customer-owned boundary for the review: tenant, subscription, landing zone, workspace, application environment, network segment, or externally managed service boundary by reference. |
| Gateway ingress | The route callers are expected to use for AI service access, model access, tool calls, or outbound dependencies, including whether Azure API Management or another accountable gateway is in scope. |
| Model/tool/data egress | The backend, model endpoint, tool/API, connector, retrieval, data, or outbound service path and its owner. |
| Private route | The private-connectivity assumption, where the path should terminate, who owns it, and what later evidence would be needed before runtime assurance relies on it. |
| Identity boundary | The caller, workload identity, managed identity, app registration, delegated authority, privileged role, gateway identity, tool identity, or resource authorization boundary that changes authority across the route. |
| Telemetry and correlation | The expected event classes, correlation key or method, propagation point, time window, known blind spots, and whether downstream owners need runtime records to connect a request, identity, gateway route, model/tool action, and backend action. |
| Retention/export owner | The owner and customer system responsible for retaining or exporting platform records; customer records stay in that system and are not copied into this repo. |
| Registry/catalog record | The API Center, catalog, tool registry, model/endpoint record, version, lifecycle owner, and exception status where applicable. |
| Platform owner | The person or team accountable for the platform boundary, not just the workload team using it. |
| Decision status | Proceed with assumptions, defer, route to a customer process, or stop. State the acceptance criterion and target date when the decision is not proceed. |
| Blocker | The missing owner, route, record, review, or policy decision that prevents downstream assurance owners from using the platform path as an input. |

## 3. Prerequisites

- A bounded workload and review question.
- A platform owner, security owner, evidence owner, and decision owner.
- A customer-approved location for records and an agreed stop condition.
- Existing customer-held architecture, network, identity, gateway, or telemetry materials that can be cited by reference, if available.
- A clear statement of what this review can and cannot claim.

This session maps evidence expectations; it does not inspect, validate, or
change the environment.

- **Included:** trust boundaries; private-connectivity assumptions; ingress and egress paths; hybrid dependencies; identity boundaries; telemetry coverage; platform-security ownership; AI gateway boundary; and readiness for runtime assurance.
- **Excluded:** deployment, configuration, network testing, live integration, traffic capture, access changes, data transfer, and acceptance of a control as operating.
- **Evidence rule:** record references, coverage, dates, interpretation, and limits. Do not copy records, payloads, identifiers, diagrams with sensitive detail, or claims into the templates.

A reference architecture can guide the discussion. It is not evidence that the design is deployed or operating.

## 4. Why this session matters

AI requests cross users, apps, gateways, model services, tools, data sources,
identity systems, networks, logs, and catalogs. S3 makes each boundary, owner,
and evidence expectation explicit before runtime assurance relies on the path.

The route trace asks:

1. Which caller or workload starts the request?
2. Which app, orchestrator, or Foundry project owns execution?
3. Which gateway route mediates ingress and which path can bypass it?
4. Which model endpoint, tool/API, connector, or data dependency is reached?
5. Which private-network, DNS, firewall, or egress decision applies?
6. Which identities and authorities cross each boundary?
7. Which telemetry and correlation records should connect the route later?
8. Which API Center/catalog and retention/export owners must keep records?

Workshop examples:

- **Proceed with assumptions:** the workload has a named platform owner, a
  customer-held gateway design, a known correlation method, and a runtime-evidence
  request for runtime records. S3 records the assumption and hands off the
  evidence question; it does not claim the route operated.
- **Defer for network route:** the design depends on private connectivity, but
  the termination point, egress path, or network owner is unclear. Route the
  blocker to the customer's network or architecture process before runtime assurance relies on
  the path.
- **Route to security or identity:** a managed identity, privileged role, or
  delegated authority crosses the platform boundary without a named lifecycle
  owner. S3 records the blocker and asks the release or identity process to
  assess the authority later.
- **Stop for unsupported SaaS boundary:** a managed or third-party service is
  material to the workload, but the customer cannot identify tenant boundary,
  record location, retention owner, or export path. Do not treat the service as
  assurance-ready until those conditions are resolved.

Read [S3 Concepts](concepts.md) for the vocabulary and reasoning behind the review.

## 5. Change boundary

This session authorizes no change. Network, identity, platform, telemetry, and runtime changes stay in the customer's approved change process, including safety review, rollback, verification, and evidence retention.
