# S6 Security Runtime Work Package

This lab helps the customer make one bounded runtime-security handoff decision. The facilitator guides the review method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, gateway policy content, incident payloads, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry condition

Bring a bounded workload or portfolio slice, decision owner, application owner, gateway owner, security owner, SOC owner, telemetry owner, retention owner, evidence owner, receiving owner, and approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the decision, evidence references, acceptance tests, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Runtime route:** safe references for caller, app, gateway or app-only path, backend/model, tool/API route, and route owner.
- **Control decision point:** whether gateway policy, Prompt Shields, app controls, tool authorization, or compensating review is existing, diagnostic, planned, unsupported, not applicable, or blocked.
- **Prompt Shields diagnostic path:** scope, support caveat, prepared-test purpose, owner, and gap handling without claiming production enforcement.
- **SOC route:** Defender for Cloud AI posture reference, Defender XDR/Sentinel route, SOC queue, severity owner, monitoring window, stop condition, and escalation contact.
- **Telemetry and correlation:** log destination, trace/correlation field, propagation point, reviewer, time window, coverage limits, and known blind spots.
- **Retention/evidence handling:** approved records location and retention/export/deletion/hold owner for runtime logs, alert records, diagnostic notes, and decision evidence.
- **Blockers and backlog:** missing identity owner, gateway route, policy decision, Prompt Shields support, SOC route, correlation, severity owner, retention owner, evidence location, or exception approval captured with owner, acceptance test, target date, and review trigger.
- **Handoff:** security engineering, SOC, platform/gateway, application, observability, identity, and records owners accept the decision or backlog with clear acceptance criteria.

## Facilitation flow

1. Confirm the customer has a bounded scope, owners, authorization to inspect records, and an approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Keep only safe references in this repository.
3. Map the Microsoft control path: **Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Microsoft Sentinel, and Application Insights**.
4. Ask: **Which customer-owned Microsoft record proves the scoped runtime route is ready to hand off, and who operates it next?**
5. Record one result in the customer system: approve, defer, reject, route, or blocked.
6. Create a runtime-security backlog item for each missing gateway route, app-only limitation, Prompt Shields gap, posture owner, SOC route, telemetry correlation field, severity owner, retention owner, or exception approval.
7. Handoff the completed decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when identity, route, policy decision, Prompt Shields status, SOC route, telemetry/correlation, retention owner, evidence reference, acceptance test, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped runtime path cannot meet the required security control expectation.
- **Route** when another Microsoft control owner, platform owner, app owner, identity owner, SOC owner, legal owner, or records owner must decide first.
- **Blocked** when authorization, access, evidence location, ownership, support status, retention, or scope clarity prevents a decision.

## Session-specific considerations

When completing the shared decision record, capture the runtime route review, Prompt Shields diagnostic status, gateway/app-only boundary, SOC route, telemetry correlation reference, retention owner, and exception/backlog path.

## Handoff

Handoff to security engineering, SOC, platform/gateway owner, application owner, identity owner, observability owner, and records-management owner. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.
