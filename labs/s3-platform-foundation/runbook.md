# S3 Platform Boundary Readiness Runbook

Use this runbook to guide the required lab path. The customer inspects its own platform records, records safe references in its approved system, and decides whether the scoped workload is ready for downstream runtime, evaluation, and control-plane handoffs.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, sensitive diagrams, deployment details, network test results, access grants, or tenant changes in this repository.

## Entry gate

Confirm the customer has a bounded workload or portfolio slice, a platform question, a decision owner, a platform owner, a security owner, an evidence owner, receiving owners, and an approved records location. If any are missing, stop the decision and create a blocker backlog item with the missing owner, record, or approval path.

## Required review flow

1. **Set the platform question.** Record the specific readiness decision: for example, whether a pilot can proceed to runtime assurance, whether a platform route must be deferred, or whether another owner must decide first.
2. **Build the platform profile.** Record safe references for the hosting pattern, environment boundary, Foundry or equivalent AI platform record, gateway assumption, registry assumption, data/tool dependencies, platform maturity limits, and owner.
3. **Map trust boundaries.** Identify where authority changes across caller, application, gateway, model or hosted service, tools, data sources, administrative plane, operations, and security monitoring. Record expected owners and evidence references only.
4. **Inspect gateway and egress route.** Name the expected Azure API Management AI Gateway, Citadel-aligned gateway, existing gateway, or no-gateway route. Record ingress, egress, backend, identity boundary, change owner, and known unsupported paths. Do not run traffic or copy policy configuration.
5. **Review network and private-route assumptions.** Record whether the path is public, private, managed VNet, bring-your-own VNet, hybrid, or deferred. Name required Private Link, DNS, firewall, route-table, or network-validation owners. S3 does not test reachability.
6. **Record identity and administrative boundaries.** Name the workload identity, caller authority, administrator authority, and lifecycle owner expected to support the platform path. Route unresolved permission fitness to identity/runtime assurance rather than approving it in S3.
7. **Inspect telemetry and correlation readiness.** Name expected log destinations, trace or correlation field, propagation point, reviewer, time window, coverage limits, and blind spots. Planned telemetry or empty logs are not proof that events exist.
8. **Confirm retention and export expectations.** Record the retention policy or owner for platform logs, gateway records, evidence notes, exports, and investigation records. Defer when retention, export, discovery, deletion, or hold expectations are unknown.
9. **Check downstream prerequisites.** Confirm the handoff can tell S6 where runtime proof should look, S7 which environment and evidence assumptions matter, and S9 which registry/control-plane owner receives the route. If any prerequisite is missing, create a blocker instead of implying readiness.
10. **Set decision state.** Use one state:
    - `approve`: readiness record, owner, evidence reference, acceptance test, and handoff are complete;
    - `defer`: a gap has a named owner and target date;
    - `reject`: the scoped platform path cannot meet the readiness question safely;
    - `route`: another platform, security, network, telemetry, architecture, product-support, or exception owner must decide first;
    - `blocked`: access, ownership, record location, support status, correlation, retention, or downstream prerequisite prevents a decision.
11. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, and next review trigger.
12. **Handoff.** Send the completed decision record and backlog references to the cloud platform team, network/security team, identity owner, observability owner, security runtime owner, evaluation owner, control-plane/catalog steward, and application delivery owner as applicable.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `record-location-missing`, `platform-profile-incomplete`, `trust-boundary-unclear`, `gateway-route-not-evidenced`, `egress-route-unknown`, `network-private-route-unresolved`, `identity-boundary-unresolved`, `telemetry-coverage-absent`, `correlation-path-missing`, `retention-or-export-unresolved`, `unsupported-region-sku-tenant`, `s6-prerequisite-missing`, `s7-prerequisite-missing`, `s9-handoff-missing`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes the platform profile, trust-boundary map, gateway and egress route, network/private-route decision, identity boundary, telemetry and correlation path, retention/export expectation, S6/S7/S9 prerequisites, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
