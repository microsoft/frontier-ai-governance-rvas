# Implementation

These files create a subscription-scope initiative from the current allowed-locations and
required-tag built-ins, then assigns it to the approved sandbox resource group. The assignment
starts in `DoNotEnforce` and moves to `Default` only after the live Policy Insights review.

`scripts/resolve-builtins.ps1` resolves current built-ins outside Bicep and returns their IDs,
versions, and effects to the current shell. Re-resolve them before each implementation. The script
does not write a separate output package.

`policy/guardrail-settings.json` is the only required-tag source. Both parameter files load it, and
preflight rejects a divergent or malformed reference.

`governance/change-reference.md` points to the customer change and risk records. Azure Policy and
Policy Insights remain authoritative for deployed policy and exemption state.
