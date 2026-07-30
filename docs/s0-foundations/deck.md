# S0 · Technical Intake & Feasibility Triage

**Facilitator deck**

Decision: **route one candidate to a technical session, or block it because it
is not inspectable.**

---

## Start with one candidate

- One workload, agent, capability, or change.
- One environment and lifecycle state.
- One customer owner who can open the relevant system.
- One approved records location.
- One first technical blocker.

Note:
Do not start with a governance theme. If the team cannot point to a workload or
source system, the result is discovery-only.

---

## Open the source system

Check the surfaces that already exist:

- Azure subscription or resource group.
- Foundry project, Copilot Studio environment, M365 extension, or custom app.
- Entra identity.
- API gateway, API Center, connector, or MCP/tool registry.
- Data source, retrieval path, prompt/output/log path.
- Application Insights, Log Analytics, Monitor, Defender, Sentinel, Purview, or
  customer backlog/change record.

Note:
The question is "what can the customer inspect now?" not "what should the
program eventually own?"

---

## Classify inspectability

| Result | Use when |
|---|---|
| Ready for technical session | Owner, surface, evidence location, and first inspection target exist. |
| Blocked by access | The right customer system cannot be opened. |
| Blocked by owner | No one can explain or accept the candidate path. |
| Blocked by evidence handling | Evidence has no safe customer records location. |
| Unsupported or wrong route | The proposed product path does not fit. |
| Discovery-only | The candidate is still an idea, not an inspectable workload. |

---

## Route the first blocker

- Identity or permission path -> S1.
- Data, Purview, retention, or eDiscovery path -> S2.
- Platform route, network, gateway, telemetry -> S3 or S6.
- Agent build path or authority -> S4.
- Tool, connector, API, MCP, or operation -> S5.
- Evaluation readiness -> S7.
- Authorized red-team target -> S8.
- Inventory mismatch -> S9.
- Operations, cost, quota, alerting -> S10.
- Release/change lifecycle -> S11.
- Cross-workload priority -> S12.

---

## Hard stops

- No owner who can open the system.
- No customer records location.
- Candidate is only a concept or portfolio slogan.
- Only production access exists and no read-only review is approved.
- The review would require copying customer evidence into this repo.
- The requested decision is legal, funding, procurement, or production approval.

---

## Output

End with:

- candidate reference;
- source system inspected or missing;
- first blocker;
- result state;
- next session or customer process;
- owner;
- accepted-when condition;
- recheck trigger.

Note:
S0 changes nothing. It gets the next technical action clean enough that the
following session can do real work.
