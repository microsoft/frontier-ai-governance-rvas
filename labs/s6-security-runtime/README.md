# S6 Runtime Path Evidence & Response Work Package

This lab helps the customer make one bounded runtime-path acceptance decision
for one non-production request. The facilitator guides the review method; the
customer inspects its own Microsoft records, chooses the decision, and keeps
completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer
> identifiers, secrets, prompt text, model outputs, telemetry exports, live
> configuration, gateway policy content, incident payloads, tenant-change
> details, runtime proof, enforcement evidence, or production approval claims in
> this repository. Do not change tenant configuration or live policy during the
> lab.

## Entry condition

Bring one bounded non-production runtime path, decision owner, application owner,
gateway/platform owner, identity owner, security owner, SOC owner, telemetry
owner, retention owner, evidence owner, reviewer, receiving owner, and approved
customer records location.

If any route owner, telemetry destination, correlation field, SOC route,
retention owner, reviewer, or records location is missing, create a blocker
backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for runtime-path trace, gateway-proof references, control placement, threat/control map, telemetry/correlation contract, SOC route, retention/evidence handling, decision, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that
summarizes:

- **Runtime-path trace:** caller, app/workload, gateway or app-only route,
  backend model/agent, tool/API route, response path, policy decision point,
  telemetry destination, correlation field, SOC route, and retention owner.
- **Gateway-proof acceptance record:** safe manifest references, transport
  result, telemetry correlation, customer reviewer, accepted-when criteria, and
  limitation.
- **Control-placement map:** identity/network, gateway, model/agent,
  app/in-process, tool/API, SOC/posture, operations, and records controls.
- **Threat/control map:** prompt injection, harmful content, data leakage,
  unsupported answer, protected material, tool abuse, unauthorized access,
  cost/availability abuse, and route bypass.
- **Telemetry and correlation contract:** propagation point, log destination,
  query owner, time window, expected signal, reviewer, coverage limits, blind
  spots, and retention/export owner.
- **SOC and response route:** Defender posture reference or gap, Defender XDR or
  Sentinel route, SOC queue, severity owner, monitoring window, stop condition,
  playbook, and escalation contact.
- **Blockers and backlog:** missing route owner, app-only limitation, diagnostic
  boundary, unsupported Prompt Shields scope, SOC route, correlation, severity
  owner, retention owner, evidence location, reviewer, or exception approval.

## Facilitation flow

1. Confirm the customer has a bounded non-production request path, owners,
   authorization to inspect records, reviewer, and approved records location. If
   not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md)
   into the customer-owned records system. Keep only safe references in this
   repository.
3. Build the runtime-path trace card before discussing product fit.
4. Map control placement across **Azure API Management AI Gateway, Azure AI
   Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR,
   Microsoft Sentinel, Application Insights, Azure Monitor, app controls, and
   tool/API controls**.
5. Ask: **Which customer-owned Microsoft record proves the scoped request used
   the expected path, emitted the expected telemetry, reached the response route,
   and has an accepted retention boundary?**
6. Record one result in the customer system: accept, defer, reject, route,
   blocked, or diagnostic-only.
7. Create a runtime-security backlog item for each missing gateway route,
   app-only limitation, diagnostic-only boundary, Prompt Shields gap, posture
   owner, SOC route, telemetry correlation field, query owner, severity owner,
   retention owner, reviewer, or exception approval.
8. Handoff the completed decision record and backlog references to receiving
   owners. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Accept** when identity, route, policy decision, telemetry/correlation, SOC
  route, retention owner, evidence reference, customer reviewer, acceptance
  test, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence
  location, and next review trigger.
- **Reject** when the scoped runtime path cannot meet the required security
  control expectation.
- **Route** when another Microsoft control owner, platform owner, app owner,
  identity owner, SOC owner, observability owner, legal owner, or records owner
  must decide first.
- **Blocked** when authorization, access, evidence location, ownership, support
  status, retention, reviewer, or scope clarity prevents a decision.
- **Diagnostic-only** when the evidence is useful for component behavior but is
  not runtime-path acceptance evidence.

## Handoff

Handoff to security engineering, SOC, platform/gateway owner, application owner,
identity owner, observability owner, data/privacy owner, runtime assurance owner,
evaluation owner, operations owner, and records-management owner as applicable.
The receiving owner accepts only decisions or backlog items with clear
acceptance tests, target dates, evidence locations, limitations, and review
triggers. Keep final records in the customer-approved system.
