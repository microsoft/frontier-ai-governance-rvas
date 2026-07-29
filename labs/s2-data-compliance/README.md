# S2 Data Compliance Work Package

This lab helps the customer trace one bounded AI data path and make a compliance
decision for each relevant segment. It is not a policy-authoring, deployment,
enforcement, evidence-export, or production-approval exercise. The facilitator
guides the review method; the customer inspects its own Microsoft records,
chooses the decision, and keeps completed evidence in its approved records
system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, Purview exports, policy deployment artifacts, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry condition

Bring a bounded workload or portfolio slice, decision owner, implementation owner, evidence owner, and approved customer records location. If any owner or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the decision, evidence references, acceptance test, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Data-path trace card:** safe references for source, prompt/input, retrieval
  context, tool request, tool response, final response, logs/telemetry,
  evaluation data, downstream sharing, evidence reference, and handoff owner.
- **Segment control map:** classification, DSPM/exposure, DLP/report-only,
  audit/eDiscovery, retention, residency/privacy, minimization, and
  gateway/runtime posture for each segment.
- **Classification and DSPM outcome:** sensitivity label, sensitive-information
  type, data-source classification, or named classification gap; plus a Microsoft
  Purview Data Security Posture Management result, validated no-result,
  unsupported state, not-applicable state, or blocker.
- **DLP posture:** covered, report-only-ready, designed, enforced, unavailable,
  gap, not-applicable, or blocked by entry point, with no live policy deployment
  or tenant change performed in the lab.
- **Audit and eDiscovery route:** the Audit, eDiscovery, Insider Risk,
  Communication Compliance, service log, records-management, or privacy process
  that would receive a future observation.
- **Retention or hold expectation:** retention label, retention policy,
  eDiscovery hold route, deletion/export owner, or legal/privacy owner decision
  needed before approval.
- **Minimization and bypasses:** source filter, retrieval filter, app redaction,
  gateway masking, output check, telemetry minimization, evaluation-data
  de-identification, and known direct/streaming/tool/cache/log bypasses.
- **Gateway and Purview dependency:** whether runtime gateway masking, filtering,
  or policy enforcement depends on Purview classification, DLP, audit/eDiscovery,
  or retention evidence. Gateway controls do not replace those records.
- **Blockers and backlog:** missing owner, record location, classification, DSPM access, DLP readiness, investigation route, retention/hold decision, gateway dependency, license/access, or scope clarity captured with owner, acceptance test, target date, evidence location, and review trigger.
- **Handoff:** receiving data owner, privacy/compliance team, Purview administrator, and any gateway/runtime owner accept the decision or backlog with clear acceptance criteria.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Data-path trace card | Source, prompt/input, retrieval, tool request, tool response, final response, logs/telemetry, evaluation data, downstream sharing, investigation route, and evidence reference. |
| Segment control map | Classification, DSPM/exposure, DLP/report-only, audit/eDiscovery, retention/legal hold, residency/privacy, minimization, gateway/runtime, and unsupported workload notes for each segment. |
| Minimization | Source filter, retrieval filter, app redaction, gateway masking, model/output check, telemetry minimization, evaluation-data de-identification, and known bypass paths. |
| Handoff | Data owner, compliance owner, records owner, gateway/runtime owner, acceptance test, target date, blocker, and release impact. |

## Facilitation flow

1. Confirm the customer has a bounded scope, owners, and an approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Complete only safe references in this repository.
3. Map the data path and inspect the Microsoft control path: **Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, eDiscovery, retention/hold route, residency/privacy route, and any gateway dependency**.
4. Ask: **Which customer-owned Microsoft record proves this segment is ready to hand off, and who operates it next?**
5. Record one result in the customer system: approve, defer, reject, route, or blocked.
6. Create a data-governance backlog item for each missing label, DLP rule, DSPM review, audit/eDiscovery route, retention decision, minimization point, bypass review, gateway dependency, evaluation-data approval, or data-owner approval.
7. Handoff the completed decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when the bounded data path, classification/DSPM outcome, DLP posture, audit/eDiscovery route, retention/hold answer, owner, evidence reference, acceptance test, and handoff are complete.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence location, and next review trigger.
- **Reject** when the scoped data path cannot meet the required Microsoft control path or compliance expectation.
- **Route** when another Microsoft control owner, legal/privacy owner, data owner, or governance process must decide first.
- **Blocked** when access, licensing, evidence location, ownership, classification, policy readiness, or scope clarity prevents a decision.

## Session-specific considerations

When completing the shared decision record, capture the technical decision record reference for DSPM, DLP, sensitivity-label, audit/eDiscovery, data-source, retention/hold, gateway dependency, and data-owner coverage.

## Handoff

Handoff to the data owner, privacy/compliance team, Purview administrator, and any gateway/runtime owner. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, and review triggers. Keep final records in the customer-approved system.
