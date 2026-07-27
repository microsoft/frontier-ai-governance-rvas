# S6 Security Runtime Runbook

Use this runbook to guide the required lab path. The customer inspects its own Microsoft records, records safe references in its approved system, and decides whether the scoped runtime-security route is ready for handoff.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, gateway policy content, incident payloads, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry gate

Confirm the customer has a bounded workload or portfolio slice, decision owner, application owner, gateway owner, security owner, SOC owner, telemetry owner, retention owner, evidence owner, receiving owner, and approved records location. If any are missing, stop the decision and create a blocker backlog item with the missing owner, record, or approval path.

## Required review flow

1. **Set the runtime question.** Record the specific handoff decision: for example, whether a gateway route is ready for SOC monitoring, whether app-only controls need remediation, or whether a Prompt Shields diagnostic gap must be routed.
2. **Map identity and route.** Record safe references for caller identity, application identity, gateway or app-only route, backend/model target, tool/API route, administrator/change owner, and unreviewed paths.
3. **Inspect gateway proof path.** Name the APIM AI Gateway, equivalent customer gateway, or no-gateway route; route owner; backend; policy decision point; log destination; and correlation field. Do not run traffic or copy policy configuration.
4. **Record app-only control boundary.** If controls are implemented in code, prompt orchestration, SDK middleware, tool wrappers, or manual review, record the owner, limitation, and what remains unproven for gateway mediation, SOC routing, and runtime evidence.
5. **Review Prompt Shields diagnostic status.** Record one outcome:
   - `enabled`: the customer has an approved record for the scoped diagnostic path;
   - `diagnostic-only`: prepared tests or design checks document expected behavior but do not prove production operation;
   - `planned`: owner and target date exist, but no current record supports the scoped path;
   - `unsupported`: target, modality, connector, language, region, license, or service status is not supported;
   - `not-applicable`: the scoped path does not use Prompt Shields and has a named compensating route;
   - `blocked`: access, owner, records location, or scope prevents review.
6. **Trace Defender and SOC route.** Name the Defender for Cloud AI posture record or gap, Defender XDR/Sentinel route, SOC queue, severity owner, monitoring window, escalation contact, and stop condition. If no route exists, mark the decision as `defer` or `blocked`.
7. **Trace telemetry and correlation.** Record Application Insights or approved log destination, trace/correlation field, propagation point, query/review owner, time window, coverage limits, and blind spots. Planned telemetry or prepared events are not runtime proof.
8. **Confirm retention and evidence handling.** Reference the approved records location and retention/export/deletion/hold owner for runtime logs, alert records, diagnostic notes, decision records, and investigation records.
9. **Set decision state.** Use one state:
   - `approve`: control path, owner, evidence reference, acceptance test, and handoff are complete;
   - `defer`: a gap has a named owner and target date;
   - `reject`: the scoped runtime path cannot meet the required security expectation;
   - `route`: another owner or governance process must decide first;
   - `blocked`: authorization, access, evidence, ownership, support status, retention, or scope clarity prevents a decision.
10. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, release or backlog impact, and next review trigger.
11. **Handoff.** Send the completed decision record and backlog references to security engineering, SOC, platform/gateway owner, application owner, identity owner, observability owner, and records-management owner.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `record-location-missing`, `identity-boundary-unresolved`, `gateway-route-not-evidenced`, `app-only-control`, `policy-decision-missing`, `prompt-shields-unsupported`, `prompt-shields-diagnostic-only`, `defender-posture-unowned`, `soc-route-missing`, `severity-owner-missing`, `correlation-path-missing`, `telemetry-coverage-absent`, `retention-owner-missing`, `unsupported-workload`, `authorization-missing`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes identity, route, policy decision point, Prompt Shields status, SOC route, telemetry/correlation path, retention owner, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
