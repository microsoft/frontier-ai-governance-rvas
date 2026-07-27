# Practical workshop: scenario-driven data guardrail path

**Microsoft default:** Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, and eDiscovery.

**Customer decision:** Approve, defer, reject, or route the data-governance path for the pilot scenario.

## Work the decision

1. **Choose the scenario slice.** Select one bounded pilot, prompt flow, retrieval source, tool call, or backlog item. Name the business owner, data owner, compliance decision owner, and receiving owner before reviewing controls.
2. **Map the data path.** Record how data enters prompts, retrieval, tools, responses, logs, telemetry, gateway inspection, evidence notes, and investigation records. Defer any source, region, tenant boundary, owner, or minimization point that cannot be named.
3. **Inspect classification and DSPM posture.** Check customer-approved Purview sensitivity-label records, classifier/DSPM findings, source ACL review, or an approved alternate classifier record. Treat empty results as "scope reviewed" only when the workload, time range, source, role, license, and reviewer are recorded.
4. **Inspect DLP readiness without changing policy.** Record whether DLP is existing, report-only/simulation, enforced, unavailable, not applicable, or blocked for each scenario entry point. Do not claim DLP coverage for unsupported workloads, conditions, connectors, roles, regions, or licenses.
5. **Trace investigation, audit, eDiscovery, and retention.** Name the audit search route, eDiscovery or legal-hold owner, retention or records-management owner, and approved evidence location. Defer when source content, AI interaction logs, or workshop evidence do not have a retention expectation.
6. **Separate gateway and Purview dependencies.** Record what the gateway can observe or mask, what Purview governs, and what remains at the source or application boundary. A gateway-visible prompt is not proof that source-system classification, DLP, audit, or retention controls are established.
7. **Record the outcome and handoff.** Approve only when the data path, classification/DSPM finding, DLP posture, investigation route, retention expectation, gateway/Purview dependency, defer criteria, receiving owners, and acceptance checks are complete. Otherwise defer with owner and target date, reject unsafe use, or route to privacy, legal, data, platform, or security operations.

## Scenario examples

| Scenario | Route | Practical decision cue |
|---|---|---|
| Unknown or sensitive data path reaches prompts, retrieval, tools, responses, or logs | Data-path blocker | Defer until every source, data class, tenant/region boundary, owner, minimization point, and approved evidence location is named. Do not paste customer records into the repo. |
| Classification or DSPM coverage is unverified, unsupported, or empty without scope proof | Classification/DSPM gap | Route to the data owner when labels, scanner coverage, DSPM scope, source ACLs, reviewer, or time range cannot be verified. Empty findings are not safety proof unless scope is documented. |
| DLP exists, but is not mapped to agent behavior | DLP readiness gap | Record DLP as existing but not established for the scenario until prompt, retrieval, tool, response, connector, and workload conditions are mapped in report-only/simulation or another approved record. |
| Audit search or eDiscovery route is unknown | Investigation gap | Defer release decisions until audit availability, search owner, eDiscovery or legal-hold owner, and escalation path are recorded for the relevant workload. |
| Retention, records ownership, or sensitivity labeling is ambiguous | Records-management gap | Route to records management or compliance; record which source content, AI interaction logs, evidence notes, and investigation records lack an owner or policy reference. |
| Gateway can observe or mask prompts, but source-system controls are not proven | Gateway/Purview dependency | Treat gateway observation as a runtime dependency only. Route source classification, DLP, audit, and retention proof to Purview/source owners before claiming coverage. |
| Unsupported workload, connector, role, license, region, or tenant feature blocks validation | Capability blocker | Record the unsupported slice, residual risk, owner, target review date, and release impact. Do not substitute a product name for validated control coverage. |

## Decision record

Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, eDiscovery, and customer-approved source records | Data governance owner | Customer-approved record reference only | Data path, classification/DSPM finding, DLP posture, audit/eDiscovery owner, retention expectation, gateway/Purview dependency, defer criteria, receiving owners, acceptance checks, exception status, and handoff are complete | Customer date | Compliance operations |

Use this decision tree: if the Microsoft path fits and evidence references are complete, approve it; if records are missing or scope is unverified, defer with an acceptance test; if the path cannot meet the use case safely, reject or route to an exception owner.

For an exception, record: reason, affected data path, unsupported or unverified control, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, receiving owner, and review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Data path | every prompt, retrieval, tool, response, log, telemetry, gateway, evidence, and investigation path is named with source, tenant/region boundary, owner, and minimization point | Scenario owner |
| Classification/DSPM | each source has verified label/classifier/DSPM coverage or a named gap with owner, target date, and release impact | Data owner |
| DLP posture | DLP state is recorded as existing, report-only/simulation, enforced, unavailable, not applicable, or blocked for each scenario entry point; no policy change is made by the workshop | Compliance owner |
| Audit/eDiscovery | a named owner can explain how an investigation would find relevant records without exporting customer data, or the route is blocked with escalation | Legal/compliance |
| Retention | source content, AI interaction logs, evidence notes, and investigation records each have a retention expectation or documented blocker | Records-management owner |
| Gateway/Purview boundary | gateway observation or masking is not used as proof of source-system classification, DLP, audit, retention, or eDiscovery coverage | Platform and data owners |
| Defer criteria | unsupported workload, missing owner, empty result, unknown scope, ambiguous retention, or unverified coverage has a named owner, target date, and release/backlog impact | Receiving owner |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, changes no tenant policy, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Workshop facilitator |

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. This workshop changes no tenant policy, proves no runtime enforcement, and does not approve production.
