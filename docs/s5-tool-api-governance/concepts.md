# S5 · API, Tool & MCP Governance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Apply the customer's current policy and
    approval model to every candidate and material change.

This page explains the operating model behind S5. Use [S5 Prepare](index.md) for
the 90-minute customer co-delivery method.

## A catalog is a decision record, not a safety proof

A catalog makes a candidate easier to find and review. It can record ownership,
intended use, classification, caller identity, authority, and lifecycle decisions.
It cannot prove that a tool is safe, that a caller is authorized, that policy is
enforced, or that a live integration behaves as claimed.

S5 records evidence references and a decision. Implementation and runtime
verification remain separate processes.

## Publication decisions become a work list

The S5 recommendation names the publication path and rejected or deferred
alternatives. Its backlog may cover registration, gateway route, caller identity,
MCP/connector path, authority, lifecycle, runtime evidence, record
reconciliation, and change ownership. Publishing, permission grants,
configuration, and runtime-safety proof stay in the customer's implementation
and assurance processes.

## Ownership is specific and lasting

Catalog ownership answers who keeps the record current and coordinates review.
Technical ownership answers who understands the candidate's behavior and version.
A decision owner accepts publication readiness, hold, suspension, or withdrawal.
One person may hold more than one role, but the record must say so.

An entry with no accountable owner is not ready for publication. It stays
proposed or on hold until someone accepts responsibility.

## Names and workspaces are control decisions

Names should show the candidate's purpose and boundary without implying more
safety than reviewers have proved. A workspace, namespace, or collection signals
its audience and the rules that apply.

Record why the placement fits the classification, potential name confusion, and
the approver. S5 does not create, move, or publish an entry.

## Classification sets the review depth

Classification captures the handling limits that shape whether and how a
candidate may be considered. The record should state the classification
reference, intended data categories, restricted data categories, and unresolved
assumptions. It should not make a broad claim that the candidate is compliant or
safe.

If the classification is unknown, reviewers cannot decide whether the workspace,
caller, and authority choices fit the risk. The right result is a gap or hold,
not a guessed classification.

## Caller identity and authority are different questions

Caller identity answers *who or what is expected to invoke the candidate* and how
that identity is established. Authority scope answers *what that caller is
allowed to cause*, under which conditions, and what is prohibited.

An identity reference without a bounded authority scope is incomplete. A scope
without an identifiable caller cannot be reviewed.

State authority as the minimum needed: allowed actions, resource or data
boundary, constraints, prohibited actions, escalation route, and approval
reference for exceptions. S5 neither grants authority nor tests it.

## Versioning makes a decision reproducible

A publication or lifecycle decision applies to a specific version and stated
configuration boundary. A material change in interface, data handling, caller
identity, authority, ownership, classification, or dependency requires re-review.
A version label alone is accepted only as an identifier. The owner
records the assessment and disposition.

## Lifecycle includes stopping use

Useful lifecycle states distinguish at least **proposed**, **publish-ready**,
**published**, **hold**, **suspended**, and **withdrawn**. The customer may use
different labels if their meanings and transition authority are explicit.

Suspension is a temporary restriction while the customer investigates,
remediates, or decides. Withdrawal removes the candidate from intended discovery
or use and keeps only the records the customer must retain. Both need a trigger,
owner, communication path, verification reference, and reconsideration or closure
decision.

The S5 record documents these facts; the customer change process takes the action.

## Evidence-first keeps uncertainty visible

Every material statement needs a customer-held reference, owner, or explicit
unknown. "Nothing found" is useful only with the checked scope and expected
signal.

## Runtime enforcement is a shared concern

Azure API Management or an AI Gateway policy can enforce part of an approved
publication decision while a tool is invoked. Keep separate identity, data,
observability, lifecycle, and in-process checks where they apply.

Treat runtime enforcement as the connection between controls. S5 identifies the
intended boundary and owner. Runtime assurance reviews bounded path evidence.
Control-plane and operating-review records keep lifecycle and operating signals
current.

For an APIM-mediated route, S5 should record which policy families are expected:
caller authentication, backend authentication, quotas, content-safety checks,
blocklists, semantic cache, token metrics, diagnostics, and backend resilience.
Those names are publication-planning fields, not proof that the policy ran.

MCP server publication follows the same rule. A server can be registered,
reviewed, published, suspended, or withdrawn, but each state needs a version,
owner, allowed action boundary, consumer scope, and withdrawal trigger. The
record should say whether the route is gateway-mediated, allow-listed, or
requires an in-process decision before tool use.

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for API Management AI Gateway, Azure Policy, Entra, and data-governance
references that can inform a customer-owned publication and enforcement backlog.
