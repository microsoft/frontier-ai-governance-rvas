# S12 · LLM Operations: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 - Provider-neutral patterns below require customer
    verification of current availability, region, quota, licensing, contract,
    product, and configuration conditions before adoption.

S12 chooses a customer-owned model-and-prompt operating model. It records
options, ownership, dependencies, and limits; it does not select, deploy, or
change a model or prompt.

## Decision 1: Applicability and asset boundary

Choose the smallest boundary that supports a decision. It may be one workload,
service, product configuration, or bounded asset population.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| Customer-controlled inventory | Customer can select, configure, version, or materially change the model or instruction. | Requires asset and owner evidence; can miss shared dependencies if scoped too narrowly. | Record model/provider, access path, instruction asset, versioning, owners, and change route. |
| Shared-control register | Customer controls some assets and a platform or supplier controls others. | Boundaries can be ambiguous. | Separate customer, platform, and supplier responsibilities and evidence routes. |
| Managed-product applicability record | Supplier controls the model or instruction and the customer has limited configuration control. | Supplier evidence may be incomplete or product-specific. | Record available customer controls, limitations, supplier route, and unresolved dependency. |
| Defer for unknown control | Ownership or control cannot be established. | No complete operating-model decision can be claimed. | Record the gap, owner, and route to resolve it. |

## Decision 2: Versioning and material-change route

Choose a method that enables comparison and accountable review without copying
sensitive instruction content.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| Customer asset register with approved references | The customer maintains source, release, configuration, or record-system references. | Reference quality depends on the customer record system. | Record asset identifier, version, status, owner, evidence reference, and review trigger. |
| Deployment or access-path alias with change record | A customer platform abstracts the provider or model behind an approved route. | An alias can hide a material provider or model change. | Require an owner and route for changes behind the alias. |
| Supplier version and notice route | Managed product controls the asset path. | Vendor labels and notices may not expose all changes. | Record contractual/support route, applicability limit, and customer assessment owner. |
| No reliable version evidence | No reviewable identifier or reference is available. | Change comparison is not supportable. | Defer approval or narrow the claim; backlog the evidence gap. |

## Decision 3: Dependency and lifecycle route

Choose the route that identifies what happens when a dependency degrades,
changes, or ends. Do not treat a named process as evidence it has been tested.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| Customer-operated route | Customer owns the model access path, service, and change process. | Requires named capacity, incident, rollback, and retirement owners. | Record process references and explicit exclusions. |
| Shared provider/platform route | Customer depends on a managed platform or provider for availability, quota, region, or deprecation. | Customer cannot control all recovery actions. | Record dependency owner, support/escalation route, evidence limits, and fallback decision route. |
| Supplier-managed product route | Product supplier controls operational behavior or withdrawal. | Customer may only configure product-level options. | Record supplier notice/support route, customer communications and retirement responsibilities. |
| Backlog-only gap | No reliable route or owner exists. | The route cannot support an assurance claim. | Assign an owner, target date, and customer process; defer or limit approval. |

## Decisions made & adoption progress

| Adoption stage | What "done" looks like at S12 |
|---|---|
| Decided | Applicability, asset boundary, versioning, material-change classes, dependency routes, and owners are approved, deferred, or rejected with limitations. |
| Backlogged | Customer-owned work for inventory, record quality, quota/region evidence, supplier route, incident/rollback, deprecation, or retirement has named owners and handoffs. |
| In adoption | Customer teams implement the approved operating model through their own platform, engineering, change, supplier, service-management, S7, and S11 processes. |

Capture the selection, alternatives, rationale, evidence limits, owners, and
adoption stage in
`labs/s12-llm-operations/templates/operating-model-material-change-decision.template.md`.
