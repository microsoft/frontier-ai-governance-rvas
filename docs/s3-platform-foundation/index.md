# S3 · Enterprise Platform & Trust Boundaries

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Verify current capability availability, platform assumptions, and customer evidence before delivery.

## 1. Outcome & what the customer keeps

The customer leaves with a platform-readiness record for the workload boundary:
what is assumed, who owns it, what is not yet evidenced, and which later session
may rely on the path.

They leave with:

- A customer-owned **platform profile** that names the hosting pattern,
  environment boundary, gateway or egress path, private-route assumption,
  identity boundary, telemetry and correlation expectations, retention/export
  owner, accountable platform owner, decision status, and blocker or defer route.
- A **trust-boundary decision** for the route runtime assurance is being asked
  to use: proceed with stated assumptions, defer until a prerequisite is closed,
  route to a customer platform process, or stop because ownership or evidence is
  missing.
- Gateway, network, telemetry, and correlation assumptions written as review
  inputs, not as proof that controls are deployed, operating, or approved for
  production.
- A blocker/defer list that identifies the customer process and owner for each
  prerequisite, such as architecture review, network design, identity review,
  security approval, release management, or evidence retention.
- An explicit handoff to S6 runtime assurance, S7 security review, and S9
  control-plane/evaluation work that states what those sessions may assess later
  and what S3 did not prove.

`labs/s3-platform-foundation/` contains blank offline templates only. Keep workload data, credentials, network details, event records, and completed evidence in the customer's approved system.

### Plain decision

**Question:** **Do we approve, defer, reject, or route this platform-readiness
decision?** Default to the Azure/Microsoft platform pattern: Microsoft Foundry,
a customer-adopted Citadel/AI Hub Gateway accelerator where applicable, and
Azure API Management for the AI gateway boundary. An alternative requires architecture-owner rationale,
platform record location, acceptance criterion, and target date. It is not a system
change or production approval.

### What happens next

**Next customer action:** route the selected platform prerequisites to the
customer's architecture, network, identity, security, or release process before
asking runtime assurance to rely on the path.

S3 produces a platform backlog: proceed to runtime assurance, close landing-zone,
AI gateway, API Center, private-connectivity, identity, telemetry, correlation,
retention/export, or ownership prerequisites, or pause for missing evidence.

The AI gateway is the trust boundary for runtime access. In this curriculum, that usually means Azure API Management acting as the gateway layer for AI APIs and model access. Platform changes still go through the customer's architecture, network, identity, security, or release processes before S6/S7/S9 rely on the path.

## 2. Platform profile list

Use this list to make the platform-readiness decision inspectable. It captures
what the review believes is true enough to hand off, what is merely assumed, and
where a blocker must be routed. Do not paste customer evidence into the list;
record references to customer-approved systems only.

| Field | What this list captures |
| --- | --- |
| Hosting pattern | The intended platform shape, such as Foundry-hosted, gateway-fronted API access, managed SaaS, private workload, hybrid dependency, or unsupported pattern requiring architecture-owner review. |
| Environment boundary | The customer-owned boundary for the review: tenant, subscription, landing zone, workspace, application environment, network segment, or externally managed service boundary by reference. |
| Gateway or egress path | The route callers or workloads are expected to use for AI service access, model access, tool calls, or outbound dependencies, including whether Azure API Management or another accountable gateway is in scope. |
| Private route | The private-connectivity assumption, where the path should terminate, who owns it, and what later evidence would be needed before runtime assurance relies on it. |
| Identity boundary | The caller, workload identity, delegated authority, privileged role, or managed identity boundary that changes authority across the route. |
| Telemetry and correlation | The expected event classes, correlation key or method, time window, known blind spots, and whether S6/S7/S9 need runtime records to connect a request, identity, gateway route, and backend action. |
| Retention/export owner | The owner and customer system responsible for retaining or exporting platform records; customer records stay in that system and are not copied into this repo. |
| Platform owner | The person or team accountable for the platform boundary, not just the workload team using it. |
| Decision status | Proceed with assumptions, defer, route to a customer process, or stop. State the acceptance criterion and target date when the decision is not proceed. |
| Blocker | The missing owner, route, record, review, or policy decision that prevents S6/S7/S9 from using the platform path as an assurance input. |

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
and logs. S3 makes each boundary, owner, and evidence expectation explicit
before runtime assurance relies on the path.

Workshop examples:

- **Proceed with assumptions:** the workload has a named platform owner, a
  customer-held gateway design, a known correlation method, and an S6 evidence
  request for runtime records. S3 records the assumption and hands off the
  evidence question; it does not claim the route operated.
- **Defer for network route:** the design depends on private connectivity, but
  the termination point, egress path, or network owner is unclear. Route the
  blocker to the customer's network or architecture process before S6 relies on
  the path.
- **Route to security or identity:** a managed identity, privileged role, or
  delegated authority crosses the platform boundary without a named lifecycle
  owner. S3 records the blocker and asks S7 or the customer identity process to
  assess the authority later.
- **Stop for unsupported SaaS boundary:** a managed or third-party service is
  material to the workload, but the customer cannot identify tenant boundary,
  record location, retention owner, or export path. Do not treat the service as
  assurance-ready until those conditions are resolved.

Read [S3 Concepts](concepts.md) for the vocabulary and reasoning behind the review.

## 5. Change boundary

This session authorizes no change. Network, identity, platform, telemetry, and runtime changes stay in the customer's approved change process, including safety review, rollback, verification, and evidence retention.
