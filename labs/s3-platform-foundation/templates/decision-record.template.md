# Decision Record

Copy this template into the customer's approved records system. Use it to record the required platform-boundary readiness decision for S3 Platform Foundation.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, sensitive diagrams, deployment details, network test results, access grants, or tenant changes in this repository.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio scope | |
| Platform question | |
| Decision owner | |
| Platform owner | |
| Security owner | |
| Evidence owner | |
| Receiving owner / process | |
| Approved records location | |
| Target date | |

## Platform-route trace

Default path: **Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking where risk requires it, Azure API Center, and Azure Monitor/Application Insights**

| Route field | Record |
|---|---|
| Caller / workload / environment | |
| Hosting pattern and environment boundary | |
| Foundry or equivalent AI platform record | |
| Application / orchestrator boundary | |
| Gateway ingress route and owner | |
| Model / backend route | |
| Tool / API egress route | |
| Data and external dependencies | |
| Registry / API Center / catalog record | |
| Platform maturity or support limits | |
| Evidence-reference location | |

## Trust boundary and route

| Field | Record |
|---|---|
| Caller / application authority change | |
| Gateway / egress route | |
| Gateway bypass or direct-route exception | |
| Model or service boundary | |
| Tool / API boundary | |
| Data-plane boundary | |
| Administrative or control-plane boundary | |
| Change owner | |
| Known unsupported or unreviewed path | |

## Network, identity, and observability

| Field | Record |
|---|---|
| Network route (public / private / managed VNet / BYO VNet / hybrid / deferred) | |
| Private Link / DNS / VNet / firewall owner if applicable | |
| Public endpoint exception owner if applicable | |
| NSG / route table / flow-log owner if applicable | |
| Identity boundary and lifecycle owner | |
| Human / workload / gateway / tool / resource identity split | |
| Telemetry destination | |
| Trace or correlation field | |
| Correlation propagation point | |
| Reviewer and review cadence | |
| Coverage limits and blind spots | |
| Retention / export / discovery owner | |

## Registry, catalog, and downstream evidence

| Field | Record |
|---|---|
| API Center / catalog entry | |
| API / tool / model route version | |
| Gateway/backend mapping | |
| Lifecycle state and owner | |
| Access contract reference | |
| Runtime evidence question | |
| Evaluation evidence question | |
| Control-plane reconciliation question | |

## Downstream prerequisites

| Handoff | Record |
|---|---|
| Runtime proof prerequisite | |
| Evaluation evidence prerequisite | |
| Control-plane / catalog handoff | |
| Stop condition before downstream reliance | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route / blocked) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Equivalent control or compensating review | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Downstream handoff impact | |
| Review trigger | |

## Backlog and handoff

Create a platform-foundation backlog item for each missing platform owner, trust-boundary record, gateway route, egress route, network/private route, identity boundary, policy assignment, telemetry coverage, correlation approach, retention/export record, runtime-proof prerequisite, evaluation prerequisite, catalog handoff, unsupported support condition, or exception approval.

Handoff to cloud platform team, network/security team, identity owner, observability owner, security runtime owner, evaluation owner, control-plane/catalog steward, and application delivery owner as applicable. The receiving owner accepts only backlog items with clear acceptance tests, target dates, and evidence locations. Keep final records in the customer-approved system.

## Filled example

Work item "confirm pre-production inference boundary"; evidence location "customer-approved gateway-route reference, private-route reference, telemetry-retention reference, and catalog handoff reference"; accepted when the receiving platform owner accepts the route and runtime-proof, evaluation-evidence, and catalog-handoff prerequisites are identified.
