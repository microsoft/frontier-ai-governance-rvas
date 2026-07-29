# Practical workshop: trace one non-production runtime request

**Microsoft default:** Azure API Management AI Gateway, Azure AI Content Safety
Prompt Shields, Defender for Cloud AI posture, Defender XDR, Microsoft Sentinel,
Application Insights, and Azure Monitor.

**Customer decision:** Accept, defer, reject, route, block, or mark
diagnostic-only for one bounded runtime-control claim. The decision records
whether the reviewed runtime path is ready for the receiving owner; it is not a
deployment, enforcement proof, live-policy change, runtime test, or production
approval.

## Facilitation flow

1. **Choose the runtime slice.** Select one bounded non-production request,
   endpoint, route, agent, prompt flow, tool call, or backlog item. Name the
   decision owner, application owner, gateway owner, security owner, SOC owner,
   telemetry owner, retention owner, evidence owner, reviewer, and approved
   customer records location.
2. **Map the request path.** Record safe references for caller identity,
   application identity, gateway or app-only route, backend model/agent, tool/API
   route, policy decision point, response path, alert path, telemetry
   destination, correlation field, and evidence-retention owner.
3. **Classify runtime risks.** Identify direct/indirect prompt injection,
   harmful content, data leakage, unsupported answers, protected material, tool
   abuse, unauthorized access, cost/availability abuse, or route bypass.
4. **Place controls and actions.** For each risk, record inspection point,
   candidate Microsoft control, action, owner, telemetry, limitation, and hard
   stop.
5. **Inspect gateway-proof manifest fields.** Confirm whether the customer-held
   references identify gateway, access contract, backend, policy reference,
   correlation ID, request evidence, telemetry evidence, expected behavior, and
   transport result.
6. **Build the telemetry/correlation contract.** Name correlation creation,
   propagation point, log destination, query owner, time window, expected signal,
   reviewer, retention/export owner, and blind spots.
7. **Route SOC and retention.** Name the Defender posture record or gap, Defender
   XDR/Sentinel route, SOC queue, playbook, severity owner, monitoring window,
   escalation path, stop condition, and records owner.
8. **Record the decision and handoff.** Accept only when route, policy decision,
   correlation, SOC route, retention owner, evidence reference, accepted-when
   checks, and receiving owner are complete. Otherwise defer, reject, route,
   block, or mark diagnostic-only.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Gateway route exists and is owned | Runtime-path acceptance | Accept only when route, backend, identity boundary, policy decision point, log destination, correlation field, reviewer, SOC route, and retention owner are named in customer-approved records. |
| Controls are application-only | App-only control path | Route to app/security owner and record limitation. App-only evidence can be valid but is not gateway-path proof. |
| Prompt Shields coverage is diagnostic, planned, unsupported, or unavailable | Diagnostic-only path | Use prepared tests only to document expected behavior and acceptance criteria. Defer if scoped target, language, modality, connector, region, or service status is unsupported or unreviewed. |
| SOC route or incident queue is missing | SOC route gap | Block or defer until Defender XDR/Sentinel routing, severity owner, monitoring window, stop condition, and escalation path are recorded. |
| Telemetry or correlation cannot join request to decision | Telemetry gap | Defer acceptance until correlation propagation, log destination, query owner, retention/export owner, and blind spots are named. |
| Tool-response context is invisible to gateway | Tool-context gap | Route to app, tool/API, or in-process owner; gateway evidence may still be useful but does not cover local context. |
| Identity, route, or policy owner is unclear | Runtime ownership gap | Route to platform, app, identity, gateway, or security owner before claiming readiness. |
| Retention or evidence handling is unknown | Records gap | Defer until runtime logs, alert records, diagnostic notes, and evidence references have an approved records location and retention owner. |

## Workshop artifact

| Artifact field | Capture prompt |
|---|---|
| Runtime-path trace | Which caller, app, gateway/app route, backend, tool/API, response path, telemetry destination, correlation field, SOC route, and records owner are in scope? |
| Control-placement map | Which risk is inspected at identity/network, gateway, model/agent, app, tool, SOC, operations, or records layer? |
| Gateway-proof package | Which safe manifest references identify route, access contract, backend, policy, correlation, request evidence, telemetry evidence, expected behavior, and result? |
| Correlation contract | Where is correlation created, propagated, queried, retained, and reviewed? What blind spots remain? |
| SOC response route | Which queue, playbook, severity owner, monitoring window, escalation path, and stop condition apply? |
| Evidence handling | Which logs, alerts, diagnostic notes, decision references, retention/export/deletion/hold expectations, and owners apply? |
| Decision | Accept, defer, reject, route, block, or diagnostic-only with owner, accepted-when condition, target date, review trigger, and limitation. |

## Decision record

Fill this row in the customer-approved records system. Store safe references
only.

| Field | Record |
|---|---|
| Work item | Runtime-path acceptance for bounded non-production request |
| Runtime path | Caller, app/workload, gateway or app-only route, backend model/agent, tool/API route, response path |
| Control placement | Identity/network, gateway, model/agent, app/in-process, tool/API, SOC/posture, operations, or records |
| Gateway-proof references | Gateway, access contract, backend, policy, correlation ID, request evidence, telemetry evidence, expected behavior, transport result |
| Correlation | Trace/correlation field, propagation point, log destination, query owner, time window, reviewer, blind spots |
| SOC route | Defender posture record or gap, Defender XDR/Sentinel route, SOC queue, severity owner, escalation contact, monitoring window, stop condition |
| Retention owner | Runtime logs, alerts, diagnostic notes, decision references, export/deletion/hold expectations |
| Decision | Accept, defer, reject, route, blocked, or diagnostic-only |
| Defer criteria | Missing route, unsupported feature, app-only limitation, absent SOC queue, missing correlation, unknown retention, unowned severity, or missing reviewer |
| Handoff | Security engineering, SOC, platform/gateway, app, identity, observability, data/privacy, runtime assurance, evaluation, records, or operations owner |

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Identity boundary | caller identity, workload identity, backend identity, admin/change owner, and unresolved permission gaps are named | Identity / app owner |
| Route boundary | ingress, gateway or app-only path, backend, egress/tool route, unsupported paths, and route owner are recorded | Gateway / platform owner |
| Policy decision | Prompt Shields, gateway policy, app control, tool authorization, model/agent control, or compensating review is recorded as existing, diagnostic, planned, unavailable, not applicable, or blocked | Security engineering |
| Correlation | trace/correlation field, propagation point, log destination, query owner, reviewer, time window, expected signal, and blind spots are named | Observability owner |
| SOC route | Defender posture record or gap, Defender XDR/Sentinel route, SOC queue, severity owner, escalation contact, monitoring window, and stop condition are named | SOC owner |
| Retention owner | runtime logs, alerts, diagnostic notes, and evidence references have retention/export/deletion/hold expectations or a blocker | Records owner |
| Defer criteria | missing route, unsupported control path, app-only limitation, absent SOC queue, missing correlation, unknown retention, or unowned severity has owner, target date, and acceptance test | Receiving owner |
| Workshop safety | the activity changes no tenant policy, exports no customer evidence, runs no production test, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Facilitator |

## Decision tree

- **Accept runtime-path evidence** when the reviewed path fits, all acceptance
  checks are complete, and the customer reviewer records the interpretation.
- **Defer** when a record, owner, support status, correlation path, SOC route,
  retention owner, reviewer, or acceptance test is missing.
- **Reject** when the scoped runtime path cannot meet the customer security
  requirement safely.
- **Route** when platform, gateway, app, identity, SOC, observability, data,
  legal, or records owner must decide first.
- **Block** when authorization, evidence location, safe evidence handling, or
  ownership is missing.
- **Diagnostic-only** when evidence helps troubleshoot a component but does not
  prove the runtime path.

For an exception, record: reason, affected route, unsupported or unverified
control, equivalent customer-owned control if one exists, owner, evidence
location reference, acceptance test, target date, downstream handoff impact, and
review trigger.

**Boundary:** Keep customer data and evidence in customer-approved systems; store
references only. S6 does not change live policy, deploy controls, prove
production enforcement, or approve production use.
