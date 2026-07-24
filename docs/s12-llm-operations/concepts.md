# S12 · LLM Operations Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-24 - Verify current provider, model, region, quota,
    and managed-product conditions before relying on a record.

Use [S12 Prepare](index.md) for the 90-minute co-delivery method. This page
explains the operating-model decision for approved model and prompt assets. It
does not select a model, change an instruction, or operate a service.

## Applicability is about customer control

S12 applies when the customer can select, configure, version, or materially
change a model or system instruction. The customer may use a direct provider,
a platform-managed deployment, an application-owned instruction asset, or a
managed product. The operational question is not the product label. It is who
can change which asset and who owns the resulting decision.

| Applicability | Customer position | S12 focus |
|---|---|---|
| Customer-controlled | The customer selects or configures the model or instruction asset. | Record inventory, versioning, material-change route, dependencies, and owners. |
| Shared control | Customer and platform or supplier each control part of the asset path. | Separate responsibility, evidence, and escalation routes. |
| Supplier-managed product | The supplier controls the model or system instruction while the customer can set limited product options. | Record applicability, supplier evidence route, customer limitations, and customer-owned operating decisions. |
| Unknown | Control or ownership cannot be confirmed. | Record the gap and defer the affected operating-model decision. |

A supplier capability statement is not evidence that it applies to a particular
customer configuration, region, version, contract, or workload.

## The operating asset is a decision boundary

An operating asset can include an approved model/provider, model deployment or
access path, prompt or system-instruction asset, version identifier, region or
capacity dependency, and owning service. The record must say what it covers and
what it excludes. It should reference approved records rather than copy prompt
text, responses, credentials, or configuration.

The aim is not a universal inventory. It is a bounded, reviewable answer to:

- Which model/provider and instruction assets are approved for this scope?
- How is each asset identified and versioned?
- Who can propose, assess, approve, and operate a material change?
- Which capacity, quota, region, supplier, incident, rollback, deprecation, and
  retirement routes could affect use?

## Versioning makes a change reviewable

Versioning can use customer-approved identifiers, source-control references,
release records, vendor version labels, deployment aliases, configuration
records, or a combination. The method must identify the asset, accountable
owner, evidence reference, effective status, and review trigger.

A version identifier makes comparison possible. It does not prove that a change
is safe, tested, approved, or deployed correctly.

## Materiality depends on the decision boundary

A material change is a change that could invalidate the approved operating
model, ownership, dependency assumptions, or required evidence. The customer
sets its classes and routes. Typical triggers include changes to:

- model/provider, model family, model version, deployment or access path;
- system instruction, prompt asset, tool-use instruction, or instruction
  ownership;
- data, region, residency, capacity, quota, licensing, or supplier terms;
- workload purpose, intended users, authority boundary, or supported service;
- incident, rollback, observability, evaluation, release, or retirement route;
  and
- accountable owner, exception, or accepted limitation.

A minor text edit can be material if it changes authority or expected behavior.
A provider version update can be material if it changes the approved model path
or dependency. Conversely, a version number alone does not decide materiality.
The decision owner records the rationale and route.

## Ownership keeps the operating model actionable

One person may hold multiple roles when the record states it. Each role still
needs a named accountable owner.

| Role | Accountability |
|---|---|
| Model operations owner | Asset inventory, versioning, provider/deployment dependencies, and change assessment. |
| Prompt or instruction owner | Approved instruction purpose, version record, and change proposal. |
| Service owner | Service operation, incident route, customer support dependency, and retirement coordination. |
| Governance decision owner | Operating-model approval, deferral, rejection, and material-change route. |
| Evidence owner | Approved reference location, retention, and decision reviewability. |
| Supplier or vendor owner | Supplier evidence, contract or support route, and managed-product escalation. |

An unnamed future owner is a gap, not an operating plan.

## Capacity, quota, and region are dependencies

Capacity, quota, throughput, rate limits, region availability, residency, and
service availability may constrain the asset path. S12 records the dependency,
its evidence reference or gap, affected scope, owner, and customer process. It
does not reserve capacity, validate quota, test a region, or prove availability.

These dependencies can create a material-change route when the approved model
or instruction path must be substituted, limited, moved, or retired.

## Incident, rollback, deprecation, and retirement need routes

An incident route says who receives and assesses a relevant issue. A rollback
route says which customer change process owns a reversal or containment decision.
A deprecation route says who assesses provider or asset withdrawal. A retirement
route says who stops use, updates approved records, retains required evidence,
communicates status, and confirms closure.

A route is not a promise of recovery. The customer records evidence and
limitations, including supplier-managed boundaries.

## Handoffs prevent duplicate assurance

S12 owns the model-and-prompt operating-model decision. It does not redo:

- **S4 initial admission and model selection:** S12 consumes the approved
  selection or records a selection gap.
- **S7 evaluation and release assurance:** S12 routes a material change needing
  evaluation, regression, or release evidence to S7.
- **S11 service monitoring and FinOps:** S12 routes capacity, quota, incident,
  telemetry, cost, and service-operating questions to S11.

A handoff is a named dependency and customer process, not proof the recipient
has completed its work.
