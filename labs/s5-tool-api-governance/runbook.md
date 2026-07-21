# S5 Runbook: Report-only tool and API governance review

Use this runbook with the visible [S5 co-delivery activity](../../docs/s5-tool-api-governance/index.md#4-co-delivery-walkthrough).
The customer operates its records and makes every decision. The facilitator
keeps the 90-minute method, evidence boundary, and decision wording explicit.
Do not store raw customer records in this kit.

## Roles, timebox, and entry condition

- **Timebox:** 90 minutes: boundary (10 min), ownership and identity (15 min),
  naming/workspace (15 min), classification and authority (20 min), publication
  and lifecycle review (20 min), decision and handoff (10 min).
- **Customer activity owner:** prepares the candidate records. **Catalog owner:**
  keeps the entry current. **Technical owner:** explains version and intended
  behavior. **Evidence owner:** points to approved records. **Decision owner:**
  accepts, defers, rejects, suspends, or withdraws the disposition. Classification
  and security reviewers interpret their applicable evidence.
- **Entry condition:** a bounded candidate list, approved records location,
  named owners, applicable review criteria, and decision authority are
  available.

## Customer-operated offline review

1. For each candidate, copy
   [`templates/catalog-record.template.md`](templates/catalog-record.template.md)
   into the approved customer records system. Record only safe identifiers and
   references. Do not copy credentials, endpoints, payloads, raw logs, or
   customer data into this repository.
2. Record the accountable catalog owner, technical owner, decision owner,
   candidate version, intended consumers, source reference, proposed name, and
   workspace or namespace decision. Unknown values remain unknown and become
   findings; do not infer them from a similar entry.
3. Record the classification reference and constraints, caller identity
   reference, authentication expectation, authority boundary, allowed actions,
   prohibited actions, and exception route. Do not grant a permission, create
   an identity, or validate a live connection.
4. Copy
   [`templates/review-decision.template.md`](templates/review-decision.template.md)
   into the approved customer records system. Compare each publication criterion
   with a customer-held evidence reference, then record **publish-ready**,
   **hold**, **reject**, **suspended**, or **withdrawn**. Publish-ready means
   the record is ready to enter the customer's separate publication process; it
   is not an instruction or proof to publish.
5. Copy
   [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md)
   when the customer needs a durable record of the publication/registry,
   MCP-governance, or tool-authentication option selected. Record the options
   considered, rationale, verified-status caveat, owner, and adoption stage;
   do not configure the registry, gateway, identity, or tool.
6. For a material version, ownership, classification, caller identity,
   authority, workspace, or dependency change, record re-review as the next
   action. For suspension or withdrawal, record the trigger, scope, action
   owner, communication reference, verification reference, and next decision.
   The customer performs any action through its approved change process.
7. Record the tool/API implementation backlog in the catalog and decision
   records. Include API Center or catalog registration, gateway/APIM route,
   caller identity, MCP/connector/tool implementation path, version/material
   change boundary, runtime evidence dependency, recommendation, confidence,
   assumptions, evidence reference or gap, owner, later session, and customer
   process.

## Interpretation and handoff

Review only what the records support. A catalog entry, template, or absence of a
finding does not prove safe use, authorization, compliance, runtime behavior,
or enforcement. Record the checked scope, expected signal, observed fact or
no-result, reviewer interpretation, decision, owner, due date, residual gap,
and next review.

Hand off safe references to the catalog and decision records. If the customer
chooses to publish, grant access, create an integration, suspend, or withdraw,
that work requires its separate approval, rollback, communication, and
verification process.

## Blocker pathways

| If | Then |
|---|---|
| Ownership, version, classification, caller identity, authority, or decision authority is missing | Stop the dependent review; record the gap, owner, target date, and hold or deferral. Do not infer or publish. |
| A criterion needs a live test, permission grant, workspace change, or integration | Record the dependency and send it to the customer's approved change process. Do not perform it in S5. |
| Suspension or withdrawal is indicated | Record the trigger and required customer action path. The decision owner directs the customer-owned action and verification. |
| No expected evidence exists | Record the no-result and scope. Hold, refine the question, use another customer control, or withdraw; never call absence a pass. |
