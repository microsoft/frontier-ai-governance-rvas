# Session 02 diagrams

`policy-promotion.excalidraw` is the authoritative editable source for the policy promotion state
machine. `policy-promotion.svg` is its portable deck and implementation-guide asset.

The state machine separates the assignment's configured enforcement mode from compliance observed
in Policy Insights. Its refusal loop returns an unapproved or unclear change to `DoNotEnforce`.
The evidence panel uses the resource ID shape for the exact resource-group scope and contains no
customer identifiers.
