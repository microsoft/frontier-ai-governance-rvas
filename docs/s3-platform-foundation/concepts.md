# S3 · Platform Route & Trust Boundaries Concepts

This page explains the vocabulary used by the [S3 session](index.md). It describes review questions, not a deployable design.

S3 is useful when the group can turn platform uncertainty into a decision:
proceed with named assumptions, defer until a prerequisite is closed, route a
blocker to the customer process that owns it, or stop because the boundary is
not reviewable.

## Platform route is the working record

A platform-route trace is the customer-owned record that runtime assurance,
evaluation, and control-plane owners are later being asked to trust. It should
name the caller, application or orchestrator, hosting pattern, environment
boundary, gateway ingress, model/tool/data egress, private-route assumption,
identity boundary, telemetry and correlation coverage, retention/export owner,
registry/catalog owner, platform owner, decision status, and blocker.

The route trace is not a deployment inventory. It is a readiness record that
says: "for this bounded workload, this is the platform route we believe is
intended; these are the owners; these are the assumptions; this is where later
evidence must come from." If any of those pieces are missing, the record should
say who must resolve the blocker before runtime, security, evaluation, or
control-plane assurance uses the route.

Example profile decisions:

- **Proceed with assumptions:** the gateway route, platform owner, correlation
  method, and record-retention owner are named, and the runtime owner has a
  bounded evidence question to assess later.
- **Defer:** private connectivity is expected, but the network termination point
  or egress path is not recorded in a customer-approved system.
- **Route:** the identity boundary depends on a privileged role or delegated
  authority that requires the customer identity or security process to decide.
- **Stop:** a managed SaaS dependency is material, but no one can identify the
  tenant boundary, record location, retention owner, or export path.

## Trust boundaries make authority visible

A trust boundary is where authority changes. A person becomes an application caller. A workload reaches a service. A request moves between networks. An administrator performs a privileged action.

The review makes those transitions explicit and names the evidence required for
each claim. A diagram shows intended design, not operating routes, identities,
or controls.

## Route-control map

Use this map when the discussion drifts into product names instead of route
segments.

| Route segment | Microsoft surface to inspect | What S3 records |
|---|---|---|
| Landing zone and environment | Azure subscription, resource group, Azure Policy, CAF/Well-Architected review, approved exception record | Boundary, platform owner, support caveat, policy assumption, release impact. |
| AI platform/orchestration | Microsoft Foundry project/workspace, model deployment, agent/tool record, app host | Hosting pattern, project/workspace owner, model/tool dependency, unsupported SKU/region/tenant caveat. |
| Gateway ingress | Azure API Management API/product/policy/backend/logs or approved customer gateway record | Caller route, auth/policy owner, backend mapping, bypass path, log owner, change route. |
| Tool/API egress | APIM backend route, firewall/proxy rule, connector/tool record, API owner | Allowed destinations, direct outbound exceptions, tool/API owner, egress blocker. |
| Private network | Private Link, private DNS, VNet/subnet, NSG, route table, firewall, managed VNet/BYO VNet record | Termination point, DNS owner, public-endpoint exception, route owner, validation owner. |
| Identity boundary | Entra identity, managed identity, app registration, OBO/delegated access, RBAC/API permissions | Human/workload/gateway/tool/resource identities, authority changes, missing lifecycle owner. |
| Telemetry and correlation | Azure Monitor, Application Insights, Log Analytics, diagnostic settings, gateway logs, trace headers | Correlation origin, propagation point, log destination, time window, blind spots, reviewer. |
| Retention and export | Log retention setting, approved export/storage route, records owner | Retention owner, evidence access route, deletion/hold expectation, export limitation. |
| Registry/catalog | Azure API Center, model/tool/API catalog, lifecycle record, version owner | API/tool/model entry, gateway/backend mapping, lifecycle status, exception/backlog owner. |

## The AI gateway is a platform trust boundary

![The gateway trust boundary controls caller access to AI services and tools, with platform ownership and S6 assurance.](../assets/diagrams/s3-gateway-trust-boundary.svg)

An AI gateway sits between callers and AI services, tools, or model backends. In Azure architectures, Azure API Management can provide that gateway boundary for APIs and AI workloads.[^apim]

The gateway boundary states where authentication, authorization, routing,
throttling, logging, or policy checks are expected. S3 records what it should
mediate and who owns it; later authorized evidence must show actual use.

Treat the gateway as an accountable route, not magic enforcement. The review
should ask which callers must use it, which backend paths are out of scope, who
owns policy changes, where gateway records live, and how a later reviewer would
correlate a request through the route. A gateway design does not prove that
traffic cannot bypass it, that a policy is effective, or that every backend is
covered.

Concrete gateway failure modes:

- APIM exists, but model/tool egress uses a direct route the gateway cannot see.
- The gateway covers interactive callers, but background jobs or administrators
  reach the backend another way.
- A policy is described, but no owner can say who can change it, where changes
  are reviewed, or which logs show the decision.
- Gateway logs exist, but no correlation key connects them to application,
  model, tool, or data records.

Workshop blockers include:

- The workload team says "all AI traffic goes through the gateway," but cannot
  name the gateway owner, route record, bypass exception process, or correlation
  field.
- The gateway covers application callers, but a background job, tool connector,
  or administrator path reaches the model service another way.
- A policy is planned for the gateway, but no customer record identifies who can
  change it, how changes are reviewed, or what runtime/evaluation owners should
  inspect later.

## Private connectivity is an assumption until evidenced

Private connectivity limits exposure by keeping an expected path off public routing or by restricting where a path may terminate. The review records the assumed route, boundary, owner, and evidence needed to support that assumption.

S3 does not test reachability, inspect configuration, or declare a route private.

Ingress is traffic entering a protected workload boundary. Egress is traffic leaving it for a service, dependency, or destination. Both need explicit scope. A protected ingress path says nothing about where the workload can send data.

Private-route assumptions need enough detail to route the next decision: source
boundary, destination boundary, termination point, egress path, network owner,
expected evidence source, and known exceptions. If the group cannot say where
the path starts or ends, S3 should defer the handoff rather than let runtime
assurance treat the route as ready.

Scenario: a Foundry-hosted workload is described as private, but the workshop
cannot identify whether the intended pattern is public access with restrictions,
managed network isolation, bring-your-own VNet, or a hybrid path. Record the
hosting pattern as undecided and route it to architecture or network ownership.

For Azure platform routes, "private" usually has several separate records:
private endpoint placement, private DNS resolution, VNet or managed network
integration, subnet segmentation, NSG or firewall policy, route propagation, and
monitoring. S3 should record which of those records exists, who owns each one,
and which later assurance or operating review can rely on it. A single
architecture diagram, endpoint URL, or resource name is not enough to accept the
private-route assumption.

Concrete private-route failure modes:

- The team says "private endpoint," but cannot identify DNS zone linkage or
  fallback-to-public behavior.
- The route is private for ingress, but egress to tools, data, or monitoring is
  broad or unowned.
- Managed VNet, BYO VNet, and hybrid routing are mentioned interchangeably
  without a selected pattern.
- NSG or firewall telemetry exists, but no reviewer owns denied traffic,
  unexpected public endpoint use, or flow-log retention.

## Hybrid dependencies widen the review boundary

A hybrid dependency spans more than one operational environment or connects to an externally managed service. It can add separate identity, routing, logging, retention, and incident-response obligations.

The review identifies accountability changes and the evidence that would bridge
them. Accept health or security only from each side's own records.

Managed SaaS and unsupported patterns need explicit conditions. S3 can record
that the service is part of the platform path only if the customer can identify
the accountable owner, tenant or environment boundary, support boundary, record
location, retention/export owner, and escalation path. If those are unavailable,
the correct decision is usually to route or stop, not to invent evidence.

## Identity boundaries are authority boundaries

Identity review asks which actor or workload is expected to start an action, which authority is delegated, which actions are privileged, and who owns the identity lifecycle.

An identity appearing in a record is accepted only as an identifier match. Permission fitness and session use require authorized runtime-assurance work.

Identity blockers are often ownership blockers. If no one owns the lifecycle for
a managed identity, service principal, delegated permission, privileged role, or
break-glass path, S3 should not hand the route to runtime assurance as ready.
Record the owner needed and whether the evaluation owner, customer identity
team, or security review must decide before the route is relied on.

## Telemetry coverage is not telemetry proof

Telemetry evidence has two parts:

- **Coverage:** event classes, boundaries, time window, correlation method, retention decision, and known blind spots that records are expected to represent.
- **Interpretation:** whether an authorized reviewer can connect a bounded event to the review question and explain the limits.

A planned log, dashboard, or retention setting is not proof of emitted events or effective detection. Record absent coverage and missing correlation plainly.

Correlation is the bridge between platform readiness and later evidence. The
profile should state how a later reviewer expects to connect user or workload
identity, gateway request, backend service call, tool action, and relevant time
window. If correlation depends on a request ID, trace ID, session ID, application
log field, gateway log, or export job, record the assumption and owner.

Scenario: gateway logs exist, application logs exist, and model-service records
exist, but no shared identifier or documented time-window method connects them.
S3 should record a correlation blocker and route it before runtime or
control-plane owners treat the path as evaluable.

Useful telemetry failure modes:

- Empty logs are treated as proof without query scope, time window, route
  coverage, diagnostic status, sampling, and reviewer.
- Gateway logs and app traces exist, but no trace ID, request ID, session ID, or
  documented time-window method connects them.
- Managed SaaS offers only partial audit/export fields, but the route is still
  treated as fully observable.
- Retention is known for operational dashboards but not for authorized evidence
  review or export.

## Platform security needs clear ownership

Platform security ownership separates responsibility for the platform boundary, the workload's use of that boundary, and the decision to accept remaining risk.

One role may hold several responsibilities. Each responsibility still needs to be recorded. A template or technical description does not transfer ownership.

Ownership should cover the platform boundary, workload use of the boundary,
evidence retention/export, exception handling, and the decision to accept or
defer remaining risk. A named owner is not evidence that a control works, but
without an owner the assurance handoff usually has no accountable path.

## Runtime assurance completes a different task

S3 provides a bounded evidence question and handoff. Runtime assurance uses
authorized observation to assess stated behavior for a stated scope and time;
it can reject the handoff or identify a coverage gap.

Readiness is not operating proof. S3 can say a profile is coherent enough for a
later owner to ask for evidence. It cannot say traffic flowed through the
gateway, private connectivity was enforced, identities were least-privileged,
logs were emitted, or controls passed. Runtime owners assess runtime behavior,
evaluation owners assess release and safety questions, and control-plane owners
reconcile evidence using authorized customer records.

## Platform review becomes a work list

S3 should recommend a platform foundation path with confidence and assumptions. Typical work-list rows include landing-zone readiness, private connectivity, Azure API Management or AI gateway route, API Center/access-contract record, identity boundary, telemetry coverage, platform-security owner, runtime-proof prerequisite, and customer architecture/security/change-process route.

For Foundry-hosted workloads, the review may also need a network-isolation question: public, managed VNet, bring-your-own VNet, or hybrid path, with an accountable platform owner.

These rows do not deploy an accelerator, configure a gateway, test networking, or prove telemetry operation. They identify which platform owner and customer process must execute and evidence that work later.

Useful blocker rows in a workshop:

- **Gateway route unknown:** "AI calls should use APIM" is stated, but the route,
  owner, exception process, and record location are not named.
- **Private path undecided:** the workload requires private connectivity, but
  architecture has not selected the hosting or network isolation pattern.
- **Correlation gap:** logs are expected in several systems, but no shared
  identifier or time-window method is defined.
- **Retention/export gap:** telemetry is available only in an operational tool,
  and no owner can say how long records are retained or how authorized reviewers
  will access them.
- **Managed SaaS boundary:** a vendor-managed component is in the request path,
  but support boundary, tenant boundary, and evidence export conditions are not
  recorded.
- **Owner missing:** the workload team can describe the platform route, but no
  platform owner can accept the prerequisite or route it to change control.

[^apim]: Microsoft Learn - [Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts); [Azure API Management for AI Gateway](https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Azure Policy and API Management AI Gateway sources that inform a customer-owned platform boundary backlog.
