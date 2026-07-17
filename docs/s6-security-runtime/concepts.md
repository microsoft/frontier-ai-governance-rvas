# S6 · Security Runtime Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Confirm runtime-control availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the evidence boundary behind S6. Use [S6 Prepare](index.md)
to begin the customer-owned validation steps.

## Gateway evidence is different from a component diagnostic

A direct call to a Content Safety endpoint can diagnose that component. It cannot
prove the agent request used the customer gateway, access contract, backend, or
policy. S6 therefore treats direct component testing as a separately labelled
diagnostic, never as gateway enforcement evidence.

The canonical S6 artifact is a
[`gateway-proof`](../../contracts/gateway-proof.schema.json) manifest from the
gateway adapter. It holds safe references and a correlation identifier, not
raw payloads or endpoints.

## Correlation makes a request reviewable

A completed adapter request is not by itself evidence that a control enforced a
policy. Customer platform and security owners must use `correlation_id` to
review gateway telemetry, then make an acceptance decision in their approved
records system. This separates a transport result (`pass` or `fail`) from an
assurance decision.

## Runtime safety remains layered

Prompt injection and harmful-content detection are useful controls, but they
are only part of a runtime boundary. Gateway policy, identity, scoped tools,
data controls, telemetry, and human review remain necessary. The S6 adapter
does not configure any of them; it supplies evidence for customer review.

For delivery, separate five evidence questions: whether the request completed,
whether the correlation appears in approved gateway telemetry, whether the
observed route matches the approved path, whether the expected policy behavior
is supported, and who accepted the interpretation. A Prompt Shields result or
component diagnostic may inform runtime-safety context, but it is not the
gateway-path proof by itself.[^appinsights]

## Runtime evidence becomes implementation backlog

S6 should recommend the next runtime path with confidence and assumptions.
Typical backlog rows include gateway/APIM route remediation, Content Safety or
Prompt Shields policy review, telemetry correlation, SOC alert/de-brief route,
identity or data-control dependency, S7 evaluation prerequisite, S9 catalog
lifecycle update, and S11 operating evidence coverage.

The recommendation does not deploy a safety platform, change traffic, or prove
production control effectiveness. It routes work to customer platform,
security, SOC, identity, data, change, or operating processes.

[^contentsafety]: Microsoft Learn - [Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection).
[^appinsights]: Microsoft Learn - [Application Insights OpenTelemetry observability overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for the cross-cutting runtime-enforcement route and current Microsoft safety,
security, identity, gateway, and observability sources.
