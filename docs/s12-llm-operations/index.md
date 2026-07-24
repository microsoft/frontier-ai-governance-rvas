# S12 · LLM Operations

!!! info "Freshness"
    Last reviewed: 2026-07-24 - Reconfirm provider capabilities, model availability,
    quota, region, and customer change requirements before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Model operations owner</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & what the customer keeps

The customer answers one question:
**should this model-and-prompt operating model be approved, deferred, or rejected?**

They leave with:

- A customer-owned inventory of approved model/provider and prompt or
  system-instruction assets in the bounded scope.
- A versioning and ownership approach for those assets.
- Material-change classification and routing decisions, including managed-product
  or supplier applicability where the customer does not control the asset.
- Capacity, quota, region, incident, rollback, deprecation, and retirement
  dependencies with named owners.
- A customer-owned backlog for gaps, decisions, and handoffs.
- An approve, defer, or reject decision with evidence references and limitations.

`labs/s12-llm-operations/` holds blank offline templates and a runbook. It does
not contain customer prompts, model outputs, data, credentials, configuration,
or service settings.

### What happens next

**Next customer action:** route the approved operating-model backlog to the
customer's model, platform, engineering, change, supplier-management, and
service-management processes.

S12 defines the operating model for a model or system-instruction asset after
it is eligible for this review. It does not select a new model or approve a
production change. The customer retains the decision package in its approved
records system.

## 2. Prerequisites

- A bounded workload, service, product, or asset population and named owners.
- Evidence references for the current model/provider and prompt or
  system-instruction state, where available.
- A governance lead able to approve, defer, or reject the operating model.
- An approved records location for decisions and evidence references.
- Applicable customer change, incident, supplier-management, and retirement
  processes available by reference.

The session can proceed with gaps, but it must record them. It does not need a
live endpoint, tenant access, prompt text, raw telemetry, or production access.

## 3. Why this session matters

A model name or prompt file alone does not explain who can change it, whether a
change is material, which capacity or region dependency applies, or how the
customer routes an incident or retirement. S12 makes those operating decisions
reviewable and customer-owned.

Read [S12 Concepts](concepts.md) for applicability, asset boundaries, evidence,
ownership, material changes, and retirement. Read [Technical decisions](technical.md)
for provider-neutral operating-model choices and limitations.

## 4. Detailed facilitation reference

!!! warning "Evidence-first, report-only boundary"
    This 90-minute session reviews customer-held evidence references and records
    decisions only. Do not select or deploy models, approve production changes,
    alter prompts or system instructions, query live data, or configure services.

**Roles:** the facilitator maintains the method and boundary; the model
operations owner explains the asset operation; the service owner accepts
service dependencies; the governance lead owns the decision; the evidence owner
records approved references. Include platform, engineering, incident, change,
security, data, or supplier specialists only where applicable.

**Entry condition:** the customer can select, configure, version, or materially
change a model or system instruction for the bounded scope. If a managed product
or supplier controls the asset, classify the customer applicability and route
supplier dependencies instead. If neither is known, record the gap and defer the
affected decision.

| Activity | Time | Customer action | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set scope and applicability | 10 min | State the workload or asset population, customer control, owners, decision needed, and exclusions. | **"What can the customer actually select, configure, version, or materially change?"** If control is unknown, do not assume it. |
| Inventory assets and ownership | 15 min | Reference approved model/provider, deployment or access path, prompt/system-instruction asset, version, owner, and records. | **"Which asset is approved for use, and who owns its operation?"** Record references, not prompt text or live configuration. |
| Define versioning and material-change routes | 20 min | Decide asset identifiers, versioning evidence, change classes, approvers, and routes. | **"Which changes could invalidate the operating decision?"** A version label alone does not determine materiality. |
| Review dependencies and operating routes | 15 min | Record capacity, quota, region, supplier, incident, rollback, deprecation, and retirement dependencies. | **"What fails, changes, or ends outside this team's direct control?"** A dependency is not an assurance claim. |
| Decide managed-product or supplier applicability | 10 min | Mark customer-controlled, shared-control, supplier-managed, or unknown and assign the required route. | **"What evidence can the supplier provide, and what customer decision remains?"** Do not infer provider controls. |
| Decide and hand off | 20 min | Approve, defer, or reject the operating model and assign the backlog, review date, and handoffs. | **"What is approved as an operating model, and what is explicitly not approved?"** Approval does not authorize a production change. |

### Results, evidence, and handoff

Use `labs/s12-llm-operations/templates/model-prompt-operations-register.template.md`
to record the customer-owned asset and ownership view. Use
`operating-model-material-change-decision.template.md` for applicability and
material-change decisions, and `incident-rollback-retirement-plan.template.md`
for routes and dependencies. Reference only approved customer records.

This session does not duplicate these decisions:

- **S4:** initial admission and model/provider selection. S12 receives the
  approved selection or records that selection as a blocker.
- **S7:** evaluation and release assurance. S12 sends material changes requiring
  evaluation or release evidence to the customer's S7 route.
- **S11:** service monitoring and FinOps. S12 sends capacity, quota, incident,
  observability, cost, and operating-signal questions to the customer's S11
  route.

A blank template, a provider statement, a named version, or a planned rollback
does not prove implementation, availability, safety, operating effectiveness, or
production readiness.

### Blocker pathways

| If | Then |
|---|---|
| Customer control, owner, approved records location, or bounded scope is missing | Defer the affected decision. Record the gap, owner, target date, and consequence. |
| A request asks to choose or deploy a model, alter a prompt, configure a service, query live data, or approve production | Stop that request in this session and route it to the applicable customer process. |
| A proposed change needs new evaluation, assurance, or release evidence | Record the change classification and hand off to the customer's S7 route before deciding it is ready. |
| Capacity, quota, region, supplier, incident, rollback, or retirement evidence is incomplete | Record the limitation, owner, and dependency. Do not claim a route works. |

## 5. Verification & evidence capture

- [ ] Scope, applicability, customer control, owners, exclusions, and evidence
  location are recorded.
- [ ] Approved model/provider and prompt/system-instruction assets have
  customer-approved references, versioning information, and ownership or gaps.
- [ ] Material-change classes, decision routes, and re-review triggers are
  recorded.
- [ ] Capacity, quota, region, supplier, incident, rollback, deprecation, and
  retirement dependencies have owners, evidence or gaps, and handoffs.
- [ ] S4, S7, and S11 handoffs are identified without duplicating their work.
- [ ] The customer decision is approve, defer, or reject, with limitations,
  backlog owners, review date, and explicit exclusions.

## 6. Change boundary

S12 creates no model selection, deployment, prompt or system-instruction change,
service configuration, live-data query, production approval, incident action, or
retirement action. Customer engineering, platform, supplier, incident, change,
release, and retirement processes own execution.
