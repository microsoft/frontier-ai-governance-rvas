# Disable and restore

## Immediate disable switch

Keep or restore the stable endpoint at 100% of the [Session 05](../../../../05-governed-agent-baseline/implementation/README.md) approved agent version. Do not pin the
candidate version when either evaluation path fails or the release owner cannot observe the result.
The Session 10 scripts never change the endpoint selector.

## Ordered restore

1. Set `release/release-policy.json` gate state to `disabled` and record the owner role and reason.
2. Keep or restore the approved agent version on the stable endpoint.
3. Remove the Session 10 gate from a delivery workflow only after the release owner confirms that no
   active promotion depends on it.
4. Cancel any running Session 10 evaluation from Foundry if it is consuming unnecessary budget.
5. Keep the golden data set in the approved evaluation store. Keep the threshold history,
   aggregate release records, and blocked self-test command.
6. Remove a Foundry evaluation definition or dataset version only when the quality owner confirms
   that no release record or comparison depends on it.

Do not delete the Foundry project, agent versions, judge-model deployment, Application Insights,
[Session 08](../../../../08-mcp-tool-security/implementation/README.md) tool path, or customer data as a restore shortcut. A failed candidate remains unpinned
and is remediated in a new version rather than mutated in place.
