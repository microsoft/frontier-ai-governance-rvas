# S3 · Enterprise Platform & Trust Boundaries Concepts

This page explains the vocabulary used by the [S3 session](index.md). It describes review questions, not a deployable design.

## Trust boundaries make authority visible

A trust boundary is where authority changes. A person becomes an application caller. A workload reaches a service. A request moves between networks. An administrator performs a privileged action.

The review makes those transitions explicit and names the evidence required for
each claim. A diagram shows intended design, not operating routes, identities,
or controls.

## The AI gateway is a platform trust boundary

![The gateway trust boundary controls caller access to AI services and tools, with platform ownership and S6 assurance.](../assets/diagrams/s3-gateway-trust-boundary.svg)

An AI gateway sits between callers and AI services, tools, or model backends. In Azure architectures, Azure API Management can provide that gateway boundary for APIs and AI workloads.[^apim]

The gateway boundary states where authentication, authorization, routing,
throttling, logging, or policy checks are expected. S3 records what it should
mediate and who owns it; later authorized evidence must show actual use.

## Private connectivity is an assumption until evidenced

Private connectivity limits exposure by keeping an expected path off public routing or by restricting where a path may terminate. The review records the assumed route, boundary, owner, and evidence needed to support that assumption.

S3 does not test reachability, inspect configuration, or declare a route private.

Ingress is traffic entering a protected workload boundary. Egress is traffic leaving it for a service, dependency, or destination. Both need explicit scope. A protected ingress path says nothing about where the workload can send data.

## Hybrid dependencies widen the review boundary

A hybrid dependency spans more than one operational environment or connects to an externally managed service. It can add separate identity, routing, logging, retention, and incident-response obligations.

The review identifies accountability changes and the evidence that would bridge
them. Accept health or security only from each side's own records.

## Identity boundaries are authority boundaries

Identity review asks which actor or workload is expected to start an action, which authority is delegated, which actions are privileged, and who owns the identity lifecycle.

An identity appearing in a record is accepted only as an identifier match. Permission fitness and session use require authorized runtime-assurance work.

## Telemetry coverage is not telemetry proof

Telemetry evidence has two parts:

- **Coverage:** event classes, boundaries, time window, correlation method, retention decision, and known blind spots that records are expected to represent.
- **Interpretation:** whether an authorized reviewer can connect a bounded event to the review question and explain the limits.

A planned log, dashboard, or retention setting is not proof of emitted events or effective detection. Record absent coverage and missing correlation plainly.

## Platform security needs clear ownership

Platform security ownership separates responsibility for the platform boundary, the workload's use of that boundary, and the decision to accept remaining risk.

One role may hold several responsibilities. Each responsibility still needs to be recorded. A template or technical description does not transfer ownership.

## Runtime assurance completes a different task

S3 provides a bounded evidence question and handoff. Runtime assurance uses
authorized observation to assess stated behavior for a stated scope and time;
it can reject the handoff or identify a coverage gap.

## Platform review becomes a work list

S3 should recommend a platform foundation path with confidence and assumptions. Typical work-list rows include landing-zone readiness, private connectivity, Azure API Management or AI gateway route, API Center/access-contract record, identity boundary, telemetry coverage, platform-security owner, S6 runtime-proof prerequisite, and customer architecture/security/change-process route.

For Foundry-hosted workloads, the review may also need a network-isolation question: public, managed VNet, bring-your-own VNet, or hybrid path, with an accountable platform owner.

These rows do not deploy an accelerator, configure a gateway, test networking, or prove telemetry operation. They identify which platform owner and customer process must execute and evidence that work later.

[^apim]: Microsoft Learn - [Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/api-management-key-concepts); [Azure API Management for AI Gateway](https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Azure Policy and API Management AI Gateway sources that inform a customer-owned platform boundary backlog.
