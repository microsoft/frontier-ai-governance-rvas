# Practical workshop: scenario-driven runtime security route

**Microsoft default:** Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Microsoft Sentinel, and Application Insights.

**Customer decision:** Approve, defer, reject, route, or block the runtime-security handoff for one bounded pilot. The decision records whether the control path is ready for the receiving owner; it is not a deployment, enforcement, runtime-proof, live-policy change, or production approval.

## Work the decision

1. **Choose the runtime slice.** Select one bounded pilot, endpoint, route, agent, prompt flow, or backlog item. Name the decision owner, application owner, gateway owner, security owner, SOC owner, telemetry owner, retention owner, and approved customer records location.
2. **Map the request path.** Record safe references for caller identity, application identity, gateway route, model or agent backend, tool/API route, policy decision point, response path, alert path, telemetry destination, correlation field, and evidence-retention owner.
3. **Inspect the gateway proof path without changing policy.** Confirm whether an existing APIM AI Gateway or equivalent customer gateway record names the route, policy owner, backend, identity boundary, log destination, and correlation field. Do not run live traffic or paste policy configuration into this repository.
4. **Inspect app-only controls separately.** If controls live only in application code, prompt orchestration, SDK middleware, or tool wrappers, record the owner and limitation. App-only validation can be useful, but it is not proof of gateway mediation, SOC routing, or platform enforcement.
5. **Inspect Prompt Shields as a diagnostic control.** Record whether Prompt Shields is enabled, unavailable, not applicable, simulated, or blocked for the scoped path. Treat prepared or synthetic prompts as diagnostic acceptance tests only; do not present them as proof of production control operation.
6. **Trace detection and response.** Name the Defender for Cloud AI posture record, Defender XDR or Sentinel incident route, SOC queue, severity owner, stop condition, and escalation contact. Defer when blocked prompts, suspicious tool calls, or model-risk alerts cannot be routed to a monitored queue.
7. **Trace telemetry, correlation, and retention.** Name the Application Insights or approved log destination, correlation propagation point, reviewer, time window, retention/export owner, and known blind spots. Planned telemetry, empty logs, or prepared events are not proof that runtime events exist.
8. **Record the decision and handoff.** Approve only when identity, route, policy decision, correlation, SOC route, retention owner, evidence reference, acceptance checks, and receiving owner are complete. Otherwise defer with owner and target date, reject unsafe or unsupported paths, route to another owner, or block when authorization/evidence location is missing.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Gateway route exists and is owned | Gateway proof path | Approve for handoff only when the route, backend, identity boundary, policy decision point, log destination, correlation field, reviewer, and retention owner are named in customer-approved records. |
| Controls are application-only | App-only control path | Route to app/security owner when filtering, authorization, prompt handling, or tool constraints happen inside code. Record that gateway/SOC/runtime proof remains unestablished until separately evidenced. |
| Prompt Shields coverage is diagnostic, planned, unsupported, or unavailable | Prompt Shields diagnostic path | Use prepared tests only to document expected behavior and acceptance criteria. Defer if the scoped target, language, modality, connector, region, or service status is unsupported or unreviewed. |
| SOC route or incident queue is missing | SOC route gap | Block or defer until Defender XDR/Sentinel routing, severity owner, monitoring window, stop condition, and escalation path are recorded. |
| Telemetry or correlation cannot join the request to the alert | Telemetry gap | Defer S6 acceptance until trace ID/correlation ID propagation, log destination, query owner, retention/export owner, and blind spots are named. |
| Identity, route, or policy decision owner is unclear | Runtime ownership gap | Route to platform, app, identity, gateway, or security owner before claiming runtime-security readiness. |
| Retention or evidence handling is unknown | Records gap | Defer until runtime logs, alert records, diagnostic notes, and evidence references have an approved records location and retention owner. |

## Decision record

Fill this row in the customer-approved records system. Store safe references only.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Runtime-security handoff | Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Microsoft Sentinel, and Application Insights | Security runtime owner | Customer-approved record reference only | Identity, route, policy decision, correlation field, SOC route, retention owner, exception status, backlog, target date, and receiving handoff are complete | Customer date | SOC / security engineering / app owner |

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Identity boundary | caller identity, workload identity, backend identity, admin/change owner, and unresolved permission gaps are named | Identity / app owner |
| Route boundary | ingress, gateway or app-only path, backend, egress/tool route, unsupported paths, and route owner are recorded | Gateway / platform owner |
| Policy decision | Prompt Shields, gateway policy, app control, tool authorization, or compensating review is recorded as existing, diagnostic, planned, unavailable, not applicable, or blocked | Security engineering |
| Correlation | trace/correlation field, propagation point, log destination, reviewer, time window, and blind spots are named | Observability owner |
| SOC route | Defender posture record, Defender XDR/Sentinel route, SOC queue, severity owner, escalation contact, monitoring window, and stop condition are named | SOC owner |
| Retention owner | runtime logs, alerts, diagnostic notes, and evidence references have retention/export/deletion/hold expectations or a blocker | Records owner |
| Defer criteria | missing route, unsupported Prompt Shields path, app-only control, absent SOC queue, missing correlation, unknown retention, or unowned severity has owner, target date, and acceptance test | Receiving owner |
| Workshop safety | the activity changes no tenant policy, exports no customer evidence, runs no production test, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Facilitator |

## Decision tree

- **Approve readiness** when the Microsoft path fits, all acceptance checks are complete, and the receiving owner accepts the handoff.
- **Defer** when a record, owner, support status, correlation path, SOC route, retention owner, or acceptance test is missing.
- **Reject** when the scoped runtime path cannot meet the customer security requirement safely.
- **Route** when platform, gateway, app, identity, SOC, telemetry, legal, or records owner must decide first.
- **Block** when authorization, evidence location, or safe evidence handling is missing.

For an exception, record: reason, affected route, unsupported or unverified control, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, downstream handoff impact, and review trigger.

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. S6 does not change live policy, deploy controls, prove production enforcement, or approve production use.
