# SOC triage playbook for Session 11 AI signals

Use this playbook for the nonproduction Foundry project and policy-assistant version authorized in
the approved change system. Do not copy prompts, responses, tool payloads, prompt evidence, user
identities, or customer data into the repository.

| Field | Value |
|---|---|
| Maintained by | SOC owner |
| Consumer | SOC analyst and incident commander |
| Update trigger | An incident, routing, product, or control-boundary change |
| Review cadence | Quarterly |

## Triage

1. Confirm the Defender alert or incident belongs to the approved subscription, Foundry project,
   agent or model, and authorized red-team window.
2. Decide whether the signal is a planned test, an unrelated benign event, or an unplanned security
   event. Never close an alert only because a red-team run was active.
3. Review Defender evidence under the customer's security-data handling rules. Use the operational KQL
   only for payload-free alert metadata.
4. Correlate the alert with the Foundry red-team run ID and report URL. Keep detailed attack and
   response content in the governed portals.

The hunt uses current alert titles exactly for jailbreak, credential leakage, suspicious access,
tool misuse, LLM reconnaissance, wallet or cost abuse, phishing or malicious URLs, and malicious
uploaded AI models. Do not replace the title list with a broad `Title has "AI"` filter.

## Contain

- For unsafe tool behavior, disable the agent endpoint or remove the tool binding through the
  existing [Session 04](../../../../04-governed-agent-baseline/implementation/README.md) or
  [Session 09](../../../../09-mcp-tool-security/implementation/README.md) control. Do not depend on a system-prompt edit alone.
- For suspected leakage, stop the run, disable the affected data or tool path, and follow the
  customer's data incident process.
- For a false positive, keep the Defender disposition in the SOC system, not as copied evidence in
  this repository.

## Escalate and recover

The SOC owner coordinates the security decision. The agent owner changes instructions and versions.
The tool owner controls permissions and backend authorization. The Defender owner controls sensor
coverage. The residual-risk authority decides whether to run remediation again.

Recovery returns only the previously approved agent version and tool boundary. A Session 11 result
does not authorize production promotion.

Defender AI model posture and malware scanning cover model and supply-chain risk. They do not
replace the agent red-team comparison. Defender real-time protection is also a separate control
surface: supported blocking depends on the agent type and integration. Session 11 does not create
or change those rules.
