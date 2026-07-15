# S5 · API, Tool & MCP Governance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Apply the customer's current policy and
    approval model to every candidate and material change.

This page explains the operating model behind S5. Use [S5 Prepare](index.md)
for the 90-minute customer co-delivery method.

## A catalog is a decision record, not a safety proof

A catalog makes a candidate easier to find and review. It can record ownership,
intended use, classification, caller identity, authority, and lifecycle
decisions. It cannot, by itself, prove that a tool is safe, that a caller is
authorized, that policy is enforced, or that a live integration behaves as
claimed.

That distinction prevents discoverability from being mistaken for assurance.
S5 requires evidence references and an explicit decision, while leaving
implementation and runtime verification to separate customer processes.

## Ownership is specific and durable

Catalog ownership answers who keeps the record current and who coordinates
review. Technical ownership answers who understands the candidate's behavior
and version. A decision owner accepts publication readiness, a hold, suspension,
or withdrawal. One person may hold more than one role, but the responsibilities
must remain explicit.

An entry with no accountable owner is not ready for publication. It remains
proposed or on hold until responsibility is accepted.

## Names and workspaces are control decisions

Names should distinguish a candidate's purpose and boundary without implying
unearned assurance. A workspace, namespace, or collection signals intended
audience and the governance rules that apply there. The decision should state
why the placement fits the classification, whether another entry could be
confused with it, and who approved the choice.

S5 records the decision; it does not create, move, or publish an entry.

## Classification sets the review depth

Classification captures the handling constraints that shape whether and how a
candidate may be considered. The record should state the classification
reference, intended data categories, restricted data categories, and unresolved
assumptions. It should not make a generic claim that the candidate is compliant
or safe.

If the classification is unknown, reviewers cannot decide whether workspace,
caller, and authority choices are proportionate. The correct result is a gap or
hold, not a guessed classification.

## Caller identity and authority are different questions

Caller identity answers *who or what is expected to invoke the candidate* and
how that identity is established. Authority scope answers *what that caller is
allowed to cause*, under which conditions, and what is prohibited. An identity
reference without a bounded authority scope is incomplete; a scope without an
identifiable caller cannot be meaningfully reviewed.

Authority should be expressed as an intended minimum: allowed actions, resource
or data boundary, constraints, prohibited actions, escalation route, and the
approval reference for exceptions. S5 neither grants authority nor tests it.

## Versioning makes a decision reproducible

A publication or lifecycle decision applies to a specific version and stated
configuration boundary. A material change in interface, data handling, caller
identity, authority, ownership, classification, or dependency requires
re-review. A version label alone does not prove that no material change
occurred; the owner records the assessment and resulting disposition.

## Lifecycle includes stopping use

Useful lifecycle states distinguish at least **proposed**, **publish-ready**,
**published**, **hold**, **suspended**, and **withdrawn**. The customer may use
different labels if their meanings and transition authority are explicit.

Suspension is a temporary restriction pending investigation, remediation, or a
decision. Withdrawal removes the candidate from intended discovery or use and
retains only the records required by the customer's retention process. Both
need a trigger, owner, communication path, verification reference, and
reconsideration or closure decision. The S5 record documents these facts; it
does not take the action.

## Evidence-first keeps uncertainty visible

Every material statement needs a customer-held reference, an identified owner,
or an explicit unknown. A no-result is meaningful only when the checked scope
and expected signal are recorded. This makes the catalog useful for governance
without converting absence, a template, or an unverified entry into evidence of
safe use.
