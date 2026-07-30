# S3 · Platform Route & Trust Boundaries

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Verify current capability availability, platform assumptions, and customer-owned evidence before delivery.

## 1. Trace one platform route

Trace one platform route end to end: caller, app or orchestrator, gateway or
direct path, model/tool/data dependency, identity boundary, private-network
assumption, telemetry path, registry record, and blocker owner.

Map the following:

- caller, workload, environment, and stop condition;
- hosting pattern: Foundry-hosted, Azure app-hosted, managed SaaS, hybrid,
  non-Azure, prototype, or unsupported;
- gateway ingress and model/tool/API egress route;
- private route, DNS, VNet/subnet, firewall/NSG, route-table, and public-endpoint
  exception status where relevant;
- human, workload, managed, delegated, gateway, tool/API, and resource identities;
- telemetry destination, correlation method, retention/export owner, and blind
  spots;
- API Center/catalog/model/tool route record, lifecycle owner, and exception;
- decision: proceed with assumptions, defer, route, reject, or block.

`labs/s3-platform-foundation/` contains blank offline templates only. Keep
workload data, credentials, network details, event records, architecture
exports, and completed evidence in the customer's approved system.

### Plain decision

**Can this pilot route be named as the platform path for later runtime,
evaluation, and control-plane work without pretending it is deployed, private,
observable, or production-ready?**

Default to Azure landing zones, Microsoft Foundry where supported, Azure API
Management AI Gateway or a customer-approved gateway for the AI boundary,
private networking where risk requires it, Azure Monitor/Application Insights
for telemetry, and Azure API Center for registry where applicable. Any
alternative needs an architecture-owner rationale and a concrete acceptance
criterion.

## 2. Workshop flow

1. **Pick one route.** Name the caller, workload, environment, business purpose,
   platform owner, security owner, telemetry owner, and evidence owner.
2. **Draw the execution path.** Identify caller -> app/orchestrator -> gateway
   or direct route -> model/tool/API/data dependency -> response/log path.
3. **Classify the hosting pattern.** Identify whether the route is Foundry-hosted,
   Azure app-hosted, managed SaaS, hybrid, non-Azure, prototype-only, or
   unsupported.
4. **Check the gateway boundary.** Identify the APIM/customer gateway API, backend,
   auth, policy owner, log owner, bypasses, and direct-route exceptions.
5. **Check private-network claims.** Do not accept "private" without route
   owner, termination point, Private Endpoint/DNS owner, egress path, firewall
   or NSG owner, and later validation reference.
6. **Separate identities.** Identify the human caller, workload identity, managed
   identity/app registration, delegated/OBO path, gateway identity, tool/API
   identity, and resource authorization separately.
7. **Define telemetry and correlation.** State where the trace/correlation key
   starts, where it propagates, where it breaks, who can query it, and how long
   records are retained.
8. **Assign catalog and lifecycle ownership.** Name the API Center/catalog/tool/
   model route record, version, lifecycle owner, and exception owner.
9. **Decide.** Proceed only for the stated route and assumptions. Otherwise
   defer, route, reject, or block with the technical gap and owner.

## 3. Hard stops

- No named platform owner for the route.
- Product label exists but tenant, region, SKU, network mode, or support status
  is unknown.
- Gateway route is planned but direct ingress or tool/API egress can bypass it.
- Private route is claimed without DNS, termination, egress, and owner details.
- Shared or broad identity crosses a platform boundary without lifecycle owner.
- Telemetry exists but no correlation key, query owner, time window, or retention
  owner is recorded.
- Managed SaaS or hybrid dependency cannot expose boundary, log, retention, or
  export information.
- API/tool/model route has no registry/catalog owner or lifecycle state.

## 4. Change boundary

S3 authorizes no platform change. It does not deploy resources, configure APIM,
test networking, change tenant policy, export telemetry, prove runtime control
operation, or approve production. Network, identity, platform, telemetry, and
runtime changes stay in the customer's approved change process.

Use [Technical decisions](technical.md) for gateway, private-network, identity,
telemetry, and catalog checks.
