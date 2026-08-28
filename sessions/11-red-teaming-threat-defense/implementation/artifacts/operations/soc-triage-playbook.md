# SOC triage playbook for Session 11 AI signals

Use this playbook only for the nonproduction Foundry project and policy-assistant version listed in
`../red-team/authorization-scope.json`. Do not copy prompts, responses, tool payloads, prompt evidence, user
identities, or customer data into this repository.

## Triage

1. Confirm the Defender alert or incident belongs to the approved subscription, Foundry project,
   agent or model, and authorized red-team window.
2. Determine whether the signal is a planned test, an unrelated benign event, or an unplanned
   security event. Never close an alert only because a red-team run was active.
3. Review Defender evidence under the customer's security-data handling rules. Use the operational KQL
   only for payload-free alert metadata.
4. Correlate the alert with the Foundry red-team run ID and report URL. Keep detailed attack and
   response content in the governed portals.

## Contain

- For unsafe tool behavior, disable the agent endpoint or remove the tool binding through the
  existing [Session 05](../../../../05-governed-agent-baseline/implementation/README.md) or
  [Session 08](../../../../08-mcp-tool-security/implementation/README.md) control. Do not depend on a system-prompt edit alone.
- For suspected leakage, stop the run, disable the affected data or tool path, and follow the
  customer's data incident process.
- For a false positive, keep the Defender disposition in the SOC system, not as copied evidence in
  this repository.

## Escalate and recover

The SOC owner coordinates the security decision. The agent owner handles instruction and version
changes. The tool owner controls permissions and backend authorization, while the Defender owner
controls sensor coverage. The residual-risk authority decides whether another remediation run is
required.

Recovery returns only the previously approved agent version and tool boundary. A Session 11 result
does not authorize production promotion.
