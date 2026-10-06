# Operational files

Keep the shipped files as templates. Complete copies outside source control,
then run preflight against that directory. Customer identifiers, user overrides,
endpoints, and device-management exports stay in the customer's approved store.

The gateway operator imports `budget-fragment.xml` as `claude-foundry-budgets`
and applies `api-policy.xml` at API scope. The endpoint-management owner merges
the Code settings into the approved device configuration and installs the token
helper. Export the Desktop profile from the app rather than hand-authoring MDM.
