# S2 · Data-Path Trace & Control Map: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Purview DSPM for AI, DLP, sensitivity labels, audit, eDiscovery, gateway masking, and Azure AI safety features vary by tenant, workload, region, and license. Verify official docs and tenant status before delivery.

## Microsoft default

Default to Microsoft Purview Data Security Posture Management, sensitivity labels, Data Loss Prevention, audit, and eDiscovery for data governance. Use gateway masking or Azure AI Content Safety only for the runtime slices they officially support.

S2 is a decision-recording gate, not a data movement or policy-authoring activity. It should prove that the reviewed AI scenario has a named data path, data owner, observation owner, and compliance route before the practical workshop asks participants to make release or backlog decisions.

## Workshop route: trace the data path

1. **Choose one bounded AI scenario.** Name the workload, environment, business
   owner, data owner, compliance decision owner, evidence owner, and approved
   records location.
2. **Draw the data path.** Record source system, prompt/input, retrieval context,
   tool request, tool response, final response, logs/telemetry, evaluation data,
   downstream sharing, and evidence reference.
3. **Classify each segment.** Record label/classifier/data class, source owner,
   exposure status, and whether the segment is labeled, unlabeled, overexposed,
   unknown, unsupported, not applicable, or outside scope.
4. **Interpret Purview/DSPM evidence.** Record result, validated no-result,
   unsupported, blocked, or not applicable. Do not treat empty findings as proof
   without scope, time range, workload support, reviewer, role/license, and
   source details.
5. **Assess DLP/report-only readiness.** For each entry point, record whether DLP
   is existing, report-only/simulation, enforced, designed, unavailable, not
   applicable, or blocked. S2 does not deploy or enforce policy.
6. **Trace investigation and retention.** Name audit, eDiscovery, legal hold,
   Insider Risk, Communication Compliance, privacy, service log, and
   records-management routes where applicable.
7. **Place minimization and identify bypasses.** Decide whether sensitive fields
   are reduced at source, retrieval, app, gateway, output, telemetry, or not at
   all. Record streaming, tool-response, direct-service, and logging bypasses.
8. **Close decision and backlog.** Approve only when every required segment has a
   control statement, owner, limitation, accepted-when condition, and handoff.

### Data-path trace card

Record references only. Do not copy prompts, outputs, documents, Purview
exports, audit records, tenant configuration, source names, policy artifacts, or
runtime evidence into this repository.

| Field | What to record |
|---|---|
| Scenario scope | Workload, environment, user group, business purpose, data owner, compliance owner, and customer record location. |
| Source data | Source system, data class, region/residency, permission model, label/classifier, retention owner, overexposure status. |
| Prompt/input | Input producer, sensitive classes allowed or denied, minimization point, DLP/workload support, logging behavior. |
| Retrieval context | Index/source, connector identity, query/filter scope, cache behavior, stale or overshared content risk. |
| Tool request | Tool/API, parameter classes, identity mode, gateway route, downstream system, data-processing owner. |
| Tool response | Response classes, truncation/redaction point, log/correlation route, failure behavior, bypass risk. |
| Final response | Display channel, copy/share/save route, output check, user notice, downstream recipient. |
| Logs and telemetry | Fields logged, sampling/masking, retention, access owner, investigation owner, SIEM or workspace route. |
| Evaluation reuse | Dataset source, de-identification owner, retention, reuse limit, approval route. |
| Evidence reference | Evidence system, evidence owner, review date, scope, limitations, expiry, hold/deletion owner. |
| Decision | Approve/defer/reject/route/blocked, accepted-when condition, target event, handoff, release/backlog impact. |

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Classification | Purview sensitivity labels, label policy, and scoped DLP readiness | existing enterprise classifier is authoritative and maps to Purview gaps |
| Exposure review | Purview DSPM for AI / data map findings for supported workloads | manual review is required for unsupported data stores or unknown tenant support |
| DLP readiness | report-only / simulation evidence before enforcement recommendations | unsupported condition, connector, license, or role means no DLP coverage claim |
| Audit/eDiscovery | Purview audit and eDiscovery route for supported workloads | regulated customer system is the legal record or workload is not supported |
| Retention | Purview retention / records-management owner and policy reference | source system retention is authoritative and mapped to the scenario |
| Residency/privacy | service residency documentation plus privacy/legal processing record | region, tenant, or contractual constraints require privacy/legal decision |
| PII/runtime handling | source minimization plus gateway masking where supported | app-specific redaction is the only supported point |

## Data-control matrix

Use this matrix to make the practical workshop scenario-driven. Each row asks for a decision artifact, evidence route, blocker condition, and safe handoff. Do not infer control coverage from product names alone; verify workload, location, role, license, region, and tenant support before recording a control as available.

| Control area | Decision to record | Evidence / control record | Scenario blocker | Safe route |
|---|---|---|---|---|
| Classification | Which data sources, fields, and prompt/retrieval slices are in scope, and whether each has a sensitivity label or named classification gap | Purview Information Protection label, label policy, scanner/classifier finding, or customer-approved classifier record | no label owner; source classification unknown; classifier cannot inspect the location | backlog classification gap with data owner and target event; do not claim label coverage |
| Exposure review | Whether the AI path increases access to overshared, stale, or privileged content | Purview DSPM for AI/data map finding, SharePoint/OneDrive permissions review, source ACL export reviewed in customer tenant | workload unsupported; source ACL unavailable; no source owner | route to source-system owner; limit scenario to reviewed sources only |
| DLP/report-only readiness | Whether a report-only or simulation state can observe the scenario before any enforcement decision | DLP policy in report-only/simulation mode, matched condition list, exception list, alert/report owner | missing license/role; unsupported workload, condition, or connector; policy would require production change | record DLP as not established; request compliance owner review before enforcement discussion |
| Audit/eDiscovery | How an investigation would find relevant user, prompt, retrieval, and document activity without exporting customer data | Purview audit search route, eDiscovery case/hold owner, workload audit availability record | audit disabled or unavailable; no eDiscovery case owner; route cannot cover the workload | route to compliance/legal; use synthetic workshop facts only |
| Retention | Which retention policy governs source content, AI interaction logs, evidence notes, and investigation records | retention label/policy reference, records-management owner, source-system retention record | retention owner missing; evidence storage not approved; logs have unclear retention | hold release recommendation; backlog retention mapping |
| Residency/privacy | Whether the data path, telemetry, model endpoint, gateway, and evidence location meet approved residency and privacy constraints | approved region/service residency documentation, privacy/legal processing record, tenant data-boundary note | region or tenant support unknown; legal basis unresolved; cross-border path unreviewed | route to privacy/legal; record no residency approval |
| Gateway/runtime minimization | Where sensitive fields are minimized before prompt assembly, retrieval, tool call, response, or logs | source filter, retrieval query, gateway masking rule, APIM route, app redaction owner, telemetry sampling/minimization record | gateway cannot see the field; streaming/tool output bypasses gateway; unsupported masking claim | move minimization to source/app boundary; do not claim gateway coverage |

## Outcome interpretation

Use this table to keep evidence language honest.

| Outcome | Use when | Required fields |
|---|---|---|
| Result | A supported Microsoft or customer-owned record shows a finding, label, match, alert, audit route, exposure, or classification. | Record source, reviewer, date, workload, segment, limitation, owner, and next action. |
| No result | A supported review found no matching signal in the agreed scope. | Query/scope, time range, workload support, role/license, reviewer, source, and why absence is meaningful. |
| Unsupported | The workload, connector, data location, role, license, region, tenant feature, or condition cannot support the expected control. | Unsupported slice, residual risk, owner, alternative review path, target event, release impact. |
| Blocked | The team cannot complete the review safely. | Missing dependency, owner, escalation path, accepted-when condition, target event, and what must stop. |
| Not applicable | The segment genuinely does not contain that data or route in the bounded scenario. | Scope statement, reviewer, date, and trigger for re-review if the path changes. |

## DLP/report-only readiness checklist

| Check | Question |
|---|---|
| Entry point | Is the policy mapped to prompt/input, retrieval, tool request, tool response, final response, sharing, or storage? |
| Workload support | Does the relevant workload, connector, condition, role, license, region, and tenant support the intended observation? |
| Mode | Is the policy existing, report-only/simulation, enforced, designed, unavailable, not applicable, or blocked for this segment? |
| Match handling | Who reviews matches, false positives, exceptions, and tuning? |
| Enforcement boundary | What would enforcement affect, and which customer change process owns it? |
| Evidence safety | Where is the report reference stored without exporting sensitive content into delivery materials? |
| Failure route | What happens when DLP cannot observe the segment: source restriction, app redaction, gateway control, or blocker? |

## Investigation and retention checklist

| Review area | Required question |
|---|---|
| Audit | Which audit route can find user, app, agent, prompt, retrieval, tool, response, or sharing activity for the workload? |
| eDiscovery/legal hold | Who can place or review a hold, and which content/log locations are in or out of scope? |
| Insider Risk / Communication Compliance | Is the path relevant to those processes, and who owns triage if a signal appears? |
| Service/application logs | Which service logs, app traces, or telemetry workspaces preserve correlation without retaining unnecessary content? |
| Retention | Which policy governs source content, AI interaction logs, transcripts, evidence notes, and investigation records? |
| Deletion/export | Who owns deletion, export, hold, and approved evidence storage decisions? |
| Privacy/residency | Which region, tenant boundary, legal basis, or processing record must be confirmed before continuation? |

## Data-path reference map

Record every segment as a reference to customer-held evidence. S2 does not
copy data, prompts, outputs, exports, or tenant configuration.

| Segment | Minimum fields | Common control question |
|---|---|---|
| Source system | Workload, source owner, data class, region/residency, permission model, retention owner, last review date. | Is the source approved for this scenario and least-privilege access path? |
| Prompt/input | Input producer, allowed sensitive classes, prohibited fields, minimization point, logging behavior. | Can sensitive input enter the model path, and where is it reduced? |
| Retrieval context | Index/source, query scope, filter, ranking owner, connector identity, cache/storage behavior. | Can retrieval surface overshared or stale content? |
| Tool request | Tool/API, parameter classes, identity mode, gateway route, policy owner, downstream system. | Does a tool call send regulated data to another boundary? |
| Tool response | Response classes, truncation/redaction point, log/correlation path, failure behavior. | Can returned data bypass source controls or gateway masking? |
| Final response | Display channel, sharing target, storage/copy route, output-safety dependency, user notice if any. | Could generated content expose or transform sensitive data? |
| Logs/telemetry | Fields logged, sampling, masking, retention, access owner, investigation owner. | Are logs minimized and usable for investigation without becoming a new data store risk? |
| Evaluation data | Dataset source, de-identification owner, retention, rubric owner, reuse limits. | Is evaluation using approved non-production or properly governed records? |
| Evidence reference | Record system, evidence owner, review date, scope, limitations, expiry. | Can reviewers find the decision evidence without exporting customer data? |

## Purview, DLP, audit, and eDiscovery review shapes

Use these shapes when turning technical evidence into a decision artifact.

| Review | Fields to capture | Blocker examples | Fallback route |
|---|---|---|---|
| Purview classification | Workload, label or sensitive-information type, classifier source, coverage scope, reviewer, unsupported locations. | Label owner missing; source not scanned; classifier does not cover the data type. | Manual data-owner attestation plus classification backlog. |
| DSPM/exposure | Finding ID/reference, affected source, exposure type, access group, remediation owner, residual risk. | Workload unsupported; ACL export unavailable; oversharing owner unknown. | Source-permission review before broad agent access. |
| DLP/report-only | Policy/report reference, condition, workload, mode, match count, false-positive owner, exception owner. | Missing license/role; unsupported connector/condition; enforcement would require live change. | Record observation gap and route to compliance/change owner. |
| Audit/eDiscovery | Query route, workload coverage, time range, retention/hold owner, reviewer, investigation handoff. | Audit disabled; no case owner; route excludes the workload. | Legal/compliance backlog with manual review route. |
| Retention/legal hold | Source retention, log retention, evidence retention, hold process, deletion owner, expiry/review date. | Evidence store unapproved; hold route missing; residency/legal basis unresolved. | Defer release recommendation pending records/privacy decision. |

## Runtime minimization placement

Runtime minimization belongs at the earliest technically reliable point. Record
coverage limits explicitly, especially when streaming, tool responses, or
direct service calls bypass a gateway.

| Placement | Example record | Limitation to record |
|---|---|---|
| Source filter | Source query scope, ACL group, label filter, row/field projection owner. | Does not protect user-entered prompt text or downstream tool responses. |
| Retrieval query | Index filter, semantic ranker scope, connector identity, cache behavior. | Ranking can surface sensitive snippets if source access is too broad. |
| Application redaction | Field allow-list, redaction library/policy version, test owner, fallback behavior. | App must see the field before it can redact it. |
| Gateway masking | APIM/gateway route, masking policy reference, observed field classes, bypass routes. | Only covers traffic routed through that gateway and supported content forms. |
| Model/output check | Safety/output check reference, action on match, reviewer route. | Output checks do not prove source permission or legal basis. |
| Telemetry minimization | Logged fields, sampling/masking rule, retention/access owner. | Logs may still retain correlation metadata requiring privacy review. |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Classification status | Purview Information Protection labels, label policy, DLP policy, policy simulation/report |
| Exposure and oversharing | Purview DSPM for AI/data map finding, SharePoint/OneDrive permissions, data-source ACLs |
| Audit/eDiscovery | Purview audit log, eDiscovery case/hold, retention policy, records-management owner |
| Runtime data path | gateway masking rule, Azure API Management route, Azure AI Content Safety setting if used |
| Residency/privacy | approved Azure region, service residency docs, privacy/legal processing record |

## Decision and blocker routes

| Case | Decision route | Record before continuing |
|---|---|---|
| Unsupported workload | Treat the control as not established for that source or scenario slice | affected workload, unsupported control, source owner, target review date, release impact |
| Missing license or role | Do not ask participants to prove product behavior they cannot access | required license/role, tenant admin or compliance owner, alternate manual evidence route |
| Missing data owner | Block data-path acceptance for that source | source name, unresolved owner, interim custodian if any, escalation owner |
| Missing investigation owner | Block audit/eDiscovery acceptance | expected incident/eDiscovery route, missing owner, legal/compliance escalation |
| Unsupported DLP condition | Record DLP as observation gap rather than coverage | unsupported condition/connector, residual risk, report-only alternative if available |
| No result or empty result | Do not treat an empty search, report, or scan as proof of safety until scope is validated | query/scope, time range, workload coverage, reviewer, next validation step |
| Runtime minimization unsupported | Keep the control at source or application boundary | field/data type, unsupported gateway/runtime claim, implementing owner |
| Residency or privacy unresolved | Defer release recommendation | unresolved region/legal basis/processing record, privacy owner, decision due date |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Data path | every source-to-prompt, retrieval, tool, response, log, and evidence path is named with workload, region, tenant boundary, owner, and minimization point | Scenario owner |
| Classification | each in-scope source has verified label/classifier coverage or a named classification gap with owner, target event, and release impact | Data/compliance owner |
| Policy state | DLP, label, and retention references state whether they are existing, report-only/simulation, enforced, not available, or not applicable; no policy change is made by S2 | Compliance owner |
| Observation owner | every DLP report, DSPM finding, audit search, telemetry view, or manual review has a named reviewer and review cadence | Observation owner |
| Audit/eDiscovery route | a reviewer can explain how an investigation would find relevant records without exporting customer data, or the route is blocked with owner and escalation | Legal/compliance |
| Retention | source content, AI interaction logs, workshop evidence, and investigation records each have a retention owner or documented blocker | Records-management owner |
| Investigation route | unsupported workload, missing owner, empty result, or suspected oversharing has a named investigation route and release/backlog impact | Investigation owner |
| Change safety | the scenario records decisions only, exports no customer data, changes no compliance policy, approves no production, and uses synthetic or pre-approved evidence references | Workshop facilitator |

## Boundary note

S2 records data decisions and routes remediation; it exports no customer data and changes no compliance policy.

## Related references

- [S6 technical decisions](../s6-security-runtime/technical.md): runtime safety placement.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): Purview, DLP, audit, eDiscovery, residency, and compliance sources.
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
