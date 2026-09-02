---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 05</p>

# Microsoft Agent 365 secure rollout and data controls

270 minutes · Configure DLP, then make one scoped rollout

<!-- Notes: The propagation wait is outside facilitated working time. -->

---

## Why it matters

**Problem.** Agent Registry makes an agent discoverable, and group installation gives people access
before any data-loss check runs.

**Solution.** This session gates installation on an enabled, propagated Purview DLP policy. The agent can come
from Microsoft Foundry, Copilot Studio, or Agent Builder.

- Agent Registry identifies the agent and group.
- Purview DLP is simulated before the group gets access.
- The included member finds the agent. The excluded user does not.
- Audit returns metadata without prompts, responses, or identities.

<!-- Notes: Keep policy, labels, simulation, and audit state in Purview. -->

---

<!-- _class: two-column -->

## Architecture and control boundary

<div class="columns">
<div>

![Purview DLP is simulated and propagated before a scoped Agent 365 installation.](assets/diagrams/purview-dlp-lifecycle.svg)

</div>
<div>

The source platform publishes the agent. **Agent Registry** holds availability and scoped
installation. **Purview** holds DLP, labels, audit, simulation, and findings.

For a Foundry agent, the separate DLP path needs an Entra-app-scoped rule and application
enforcement of `processContent` with signed-in user context.

Copilot Studio and Agent Builder retain their runtime controls.

Hosted and custom agents need supported Agent 365 SDK instrumentation. Inline Purview decisions
also need application code.

</div>
</div>

<!-- Notes: Purview visibility does not replace source-platform runtime controls. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Required answer | Limit |
|---|---|---|
| Agent | One Available Agent Registry entry from a supported platform | Publishing and runtime remain with the source platform |
| Audience | One approved nonproduction Entra group | Organization-wide installation is out of scope |
| DLP | Agent, group, label, directions, locations, and `Block` or `Audit` | The portal summary must match these coordinates |
| Encrypted source | Explicit agent **VIEW** and **EXTRACT** rights plus direct share | “All users” does not grant the agent access |
| Generated content | Labelled destination, mandatory labelling, or auto-labelling | Source labels do not transfer automatically |
| Restore | Named Purview and Microsoft 365 owners | Reused labels and source data stay in place |

<!-- Notes: The DLP and label operator needs Compliance Data Administrator. -->

---

<!-- _class: implementation -->

## Rollout path

**Part 1: prepare**

1. Select the published Foundry, Copilot Studio, or Agent Builder agent.
2. Complete the Agent Registry contract and owner handoff.
3. Preflight the DLP change.
4. Create the custom policy in `TestWithNotifications`.

**Part 2: authorize access**

5. Review simulation, enable the policy, and wait for propagation.
6. Record `EnabledAndPropagated` and `Confirmed` in the installation gate.
7. Preflight installation, then install for the named group and host product.

<!-- Notes: The first preflight explicitly does not authorize installation. -->

---

<!-- _class: decision -->

## Safety gates

Stop when:

- a required license, owner, role, permission, label right, or restore route is missing;
- the Purview summary is wider than the approved agent, group, label, directions, locations, or action;
- a policy has not been enabled and propagated before installation;
- the deployment contract still has an unresolved `__REQUIRED_*__` value;
- production data or payload retention enters the path;
- a Foundry agent lacks its separate app-scoped DLP rule or user-context `processContent` enforcement.
- a hosted or custom agent is registered but lacks its supported runtime observability integration.

The installation-phase preflight accepts Session 05 installation only when the DLP gate is
recorded as `EnabledAndPropagated` and `Confirmed`.

<!-- Notes: Do not use the session number as a blanket installation block. -->

---

<!-- _class: implementation -->

## Confirm the extended checks

**Intended path**

Run a labelled synthetic interaction after propagation. `Block` stops the match. `Audit` allows it
and records the match.

**Failure path**

Repeat it with the excluded-user alias. Keep the agent, source, label, direction, location, and
action unchanged. Purview must not report a match. The excluded user must not find the agent.

**Delivery-owner checkpoint**

The delivery owner observes propagation, included access, excluded-user denial, both DLP results,
and scoped audit activity. Keep the policy in simulation or disable it if a check fails.

---

<!-- _class: two-column -->

## Operate and restore

<div class="columns">
<div>

### Payload-free audit

The audit query uses:

- `AIInvokeAgent`
- `AIExecuteTool`
- `AIInferenceCall`
- `AIGuardrail`

It displays time, operation, agent ID, agent name, and result status. No audit export is written.

</div>
<div>

### Restore

1. Return the policy to `TestWithNotifications`.
2. Disable it after reviewing dependencies.
3. Remove the scoped group installation before deleting a session-created policy.
4. Remove label rights or source sharing after the data owner confirms that no dependency remains.

The data governance owner reviews the ownership record quarterly.

</div>
</div>

<!-- Notes: Never delete a reused label, audit records, or source data during this restore. -->

---

<!-- _class: closing -->

# Thank you!
