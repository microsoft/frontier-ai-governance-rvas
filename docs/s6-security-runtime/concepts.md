# S6 · Security Runtime Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Confirm runtime-control availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the evidence boundary behind S6. Use [S6 Prepare](index.md)
to begin the customer-owned validation steps.

## Gateway evidence is different from a component diagnostic

A direct call to a Content Safety endpoint can diagnose that component. It cannot
prove the agent request used the customer gateway, access contract, backend, or
policy. S6 labels direct component testing as a diagnostic. It never treats it as
gateway enforcement evidence.

The S6 artifact is a
[`gateway-proof`](../../contracts/gateway-proof.schema.json) manifest from the
gateway adapter. It holds safe references and a correlation identifier, not raw
payloads or endpoints.

## Correlation makes a request reviewable

![S6 flow: a gateway adapter request produces a gateway-proof manifest with safe references and a correlation_id; the transport result (pass/fail) and the correlation_id appearing in approved gateway telemetry both feed the platform and security owners' acceptance decision, yielding a reviewable runtime artifact; a direct component diagnostic is not gateway-path proof.](../assets/diagrams/s6-security-runtime-correlation-flow.svg)

A completed adapter request is not enough to prove a policy was enforced.
Customer platform and security owners use `correlation_id` to review gateway
telemetry. Then they make an acceptance decision in their approved records system.

This separates a transport result (`pass` or `fail`) from a security decision.

## Runtime safety remains layered

Prompt injection and harmful-content detection help, but they are only part of a
runtime boundary.[^contentsafety] Gateway policy, identity, scoped tools, data
controls, telemetry, and human review may also apply. The S6 adapter does not
configure any of them. It supplies evidence for customer review.

For delivery, keep five questions separate:

1. Did the request complete?
2. Does the correlation appear in approved gateway telemetry?
3. Does the route match the approved path?
4. Does the observed path support the expected policy behavior?
5. Who accepted the interpretation?

A Prompt Shields result or component diagnostic may add runtime-safety context.
It is not gateway-path proof by itself.[^appinsights]

Microsoft Defender for Cloud and AI security posture capabilities can help the
customer review the security posture, findings, and security-owner routing where enabled. They
support the runtime security picture. They do not replace the S6 gateway proof
and correlation decision.

## Runtime evidence becomes a work list

S6 should recommend the next runtime path with confidence and assumptions. Typical
work-list rows include gateway or Azure API Management route remediation, Content
Safety or Prompt Shields policy review, telemetry correlation, SOC alert or
debrief route, identity or data-control dependency, S7 evaluation prerequisite,
S9 catalog lifecycle update, and S11 operating evidence coverage.

The recommendation does not deploy a safety platform, change traffic, or prove
production control effectiveness. It routes work to customer platform, security,
SOC, identity, data, change, or operating processes.

[^contentsafety]: Microsoft Learn - [Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection).
[^appinsights]: Microsoft Learn - [Application Insights OpenTelemetry observability overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for the cross-cutting runtime-enforcement route and current Microsoft safety,
security, identity, gateway, and observability sources.
