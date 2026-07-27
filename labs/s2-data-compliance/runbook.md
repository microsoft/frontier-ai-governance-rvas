# S2 Data Compliance Runbook

Use this runbook to guide the required lab path. The customer inspects its own Microsoft records, records safe references in its approved system, and decides whether the scoped data path is ready to proceed.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, Purview exports, policy deployment artifacts, tenant-change details, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry gate

Confirm the customer has a bounded workload or portfolio slice, a decision owner, an implementation owner, an evidence owner, a data owner, a compliance owner, and an approved records location. If any are missing, stop the decision and create a blocker backlog item with the missing owner, record, or approval path.

## Required review flow

1. **Map the data path.** Record safe references for each source, store, retrieval index, processing step, prompt/input path, tool output, generated response, log or telemetry destination, downstream sharing path, investigation record, and handoff owner.
2. **Confirm classification.** Reference the sensitivity label, sensitive-information type, data-source classification, or named classification gap. If the class is unknown, mark the decision state as `blocked` and assign an observation owner.
3. **Review DSPM posture.** Record one outcome:
   - `result`: a relevant Microsoft Purview Data Security Posture Management finding exists and is assigned;
   - `no-result`: the customer reviewed the scoped path and found no relevant finding, with scope and reviewer recorded;
   - `unsupported`: the source, workload, role, license, location, or tenant capability does not support the expected view;
   - `blocked`: licensing, role access, inventory, owner, or evidence location prevents review.
4. **Check DLP readiness.** Record whether the DLP path is `covered`, `report-only-ready`, `designed`, `gap`, `not-applicable`, or `blocked`. Do not deploy or change policy during the lab.
5. **Choose the investigation route.** Identify the Audit, eDiscovery, Insider Risk, Communication Compliance, service log, legal hold, retention, or privacy process that would receive a future observation. If no route exists, record a blocker and receiving owner.
6. **Confirm retention or hold.** Reference the retention label, policy, eDiscovery hold route, records-management owner, or legal/privacy decision. If retention, residency, evidence storage, export, deletion, or hold requirements are unresolved, route before approval.
7. **Record gateway dependency.** Note whether runtime gateway masking, filtering, routing, logging, or tool-call control is needed outside Purview. Gateway controls do not replace classification, DLP, audit, eDiscovery, or retention evidence.
8. **Set decision state.** Use one state:
   - `approve`: control path, owner, evidence reference, acceptance test, and handoff are complete;
   - `defer`: a gap has a named owner and target date;
   - `reject`: the scoped data path cannot meet the required control path;
   - `route`: another owner or governance process must decide first;
   - `blocked`: access, licensing, evidence, ownership, policy readiness, investigation route, retention, or scope clarity prevents a decision.
9. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, release or backlog impact, and next review trigger.
10. **Handoff.** Send the completed decision record and backlog references to the data owner, privacy/compliance team, Purview administrator, records-management owner, and any gateway/runtime owner.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `record-location-missing`, `classification-gap`, `dspm-unavailable`, `dlp-not-ready`, `investigation-route-missing`, `retention-or-hold-unresolved`, `gateway-dependency`, `access-or-license`, `unsupported-workload`, `empty-result-not-scoped`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes the data path, classification/DSPM outcome, DLP posture, investigation route, retention/hold answer, gateway/Purview boundary, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
