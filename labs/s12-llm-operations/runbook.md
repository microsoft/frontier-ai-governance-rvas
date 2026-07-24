# S12 Runbook: LLM Operations operating-model review

Use this runbook with the [LLM Operations activity guide](../../docs/s12-llm-operations/index.md).
The customer reviews approved records and makes decisions; the facilitator
preserves the 90-minute, evidence-first, report-only boundary.

> **Boundary:** do not select or deploy a model, approve a production change,
> alter a prompt or system instruction, query live data, configure a service,
> execute an incident action, or retire an asset in this session.

## Activity card

**90 minutes:** scope and applicability (10), asset inventory and ownership
(15), versioning and material-change routes (20), dependencies and lifecycle
routes (15), supplier applicability (10), decision and handoff (20).

**Roles:** model operations owner explains the asset path; prompt or instruction
owner explains approved asset references; service owner explains service and
lifecycle dependencies; governance lead makes or defers the decision; evidence
owner records approved references. Include platform, engineering, supplier,
incident, change, security, data, or operations specialists only when applicable.

**Entry condition:** a bounded workload, service, product, or asset population;
customer control or a managed-product/supplier applicability question; named
owners; and an approved records location. Stop the affected decision if any is
unknown.

## 1. Set scope and applicability

- [ ] State the bounded workload, service, product configuration, or asset
  population; intended decision; exclusions; and approved records location.
- [ ] Mark customer-controlled, shared-control, supplier-managed, or unknown.
- [ ] State what the customer can select, configure, version, or materially
  change, and what is controlled elsewhere.
- [ ] Name the model operations, instruction, service, governance decision,
  evidence, and supplier owners where applicable.

Ask: "What can the customer actually change?" and "What would make us defer
this decision?" Do not infer a supplier, provider, or platform control.

## 2. Record assets, versioning, and ownership

1. Copy `templates/model-prompt-operations-register.template.md` into the
   approved records system.
2. Reference approved records for the model/provider, access path, prompt or
   system-instruction asset, version identifier, status, owner, and evidence
   gap. Do not copy prompt text, outputs, credentials, identifiers, or live
   configuration.
3. Record the versioning method: approved asset register, source or release
   reference, deployment/access-path alias, supplier version/notice route, or
   an evidence gap.
4. Record whether capacity, quota, region, licensing, supplier, or service
   dependencies apply. A known dependency is not evidence that it is available
   or effective.

Ask: "Which asset is approved for this scope, how is it identified, and who
owns it?" A model name or prompt file without an owner and evidence reference
is a gap.

## 3. Classify material changes

1. Copy `templates/operating-model-material-change-decision.template.md` into
   approved records.
2. Assess proposed or anticipated changes to model/provider, model version,
   deployment/access path, prompt/system instruction, ownership, region, quota,
   capacity, licensing, supplier route, service boundary, incident/rollback
   route, deprecation, or retirement obligation.
3. Record whether the change is material, non-material, unknown, or requires
   further assessment. Record rationale, evidence reference or gap, decision
   owner, and customer route.
4. If the change needs new evaluation, regression, assurance, or release
   evidence, record a handoff to the customer's S7 route. Do not perform the
   evaluation or approve release in this session.

A version number alone does not decide materiality. A change can be material when
it changes the operating decision, dependency, ownership, or required evidence.

## 4. Record incident, rollback, deprecation, and retirement routes

- [ ] Copy `templates/incident-rollback-retirement-plan.template.md` when
  lifecycle or disruption routes are in scope.
- [ ] Reference the customer incident route, rollback/change route, supplier
  support or notice route, deprecation review route, retirement owner, records
  retention route, communications route, and closure route.
- [ ] Record capacity, quota, region, observability, cost, and operating-signal
  dependencies with their limitations and owners.
- [ ] Hand off service monitoring, incident operation, capacity/quota
  observation, and FinOps questions to the customer's S11 route. Do not monitor
  or query live data here.

A route does not prove recovery, rollback, availability, supplier notice, or
retirement completion. Record evidence and gaps separately.

## 5. Keep S4, S7, and S11 boundaries distinct

- **S4** owns initial admission and model/provider selection. If no approved
  selection exists, record the blocker and route it to the customer S4 process.
- **S7** owns evaluation and release assurance. Route material changes requiring
  that evidence to S7.
- **S11** owns service monitoring and FinOps. Route operating signals, capacity,
  quota, incident, telemetry, and cost questions to S11.

S12 records the operating model and handoff only. It does not duplicate the
selection, assurance, monitoring, or FinOps decision.

## 6. Decide and hand over

The governance lead chooses one:

- **approve the bounded operating model;**
- **defer pending owned evidence, route, or decision;** or
- **reject the operating model for the stated scope.**

Record the decision, rationale, limitations, explicit exclusions, owner, review
date, asset-register reference, material-change route, backlog owners, and
customer-process handoffs. Approval is never model deployment or production
change approval.

## Blocker pathways

| If | Then |
|---|---|
| Scope, customer control, owner, evidence location, or approved selection is missing | Defer the affected decision. Record the gap, owner, target date, and S4 or other customer route. |
| A request asks for selection/deployment, prompt alteration, live query, service configuration, or production approval | Stop the request and route it through the applicable customer process. |
| A material change needs evaluation or release evidence | Record the classification and route to S7; do not claim assurance in S12. |
| Capacity, quota, region, incident, rollback, supplier, or retirement route is unknown | Record the limitation, owner, and S11, supplier, platform, change, or service-management handoff. |
