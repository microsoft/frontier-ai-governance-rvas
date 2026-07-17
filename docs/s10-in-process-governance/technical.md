# S10 · In-Process Governance — Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · The Agent Governance Toolkit (AGT) is Public
    Preview and pinned in this curriculum; verify current status and limitations
    before delivery. See the [Platform technical guide](../reference/platform-technical-guide.md).

S10's core question is not "is there a place to run a policy check?" — it is a
**technical decision** with a clear menu: *where should the tool-call policy
boundary live for this agent, if anywhere?* This page gives the options,
the criteria to choose, and the trade-offs, so the customer records a real
decision (including "not applicable") and a concrete next step.

S10 installs and executes nothing. Every option below is a decision the
customer's engineering and change process would own.

## Decision — Where does the tool-call policy boundary live?

The deciding test is whether there is a **real decision point immediately before
a tool call**, what **delegated authority** that call carries, and whether the
customer needs **audit or tamper evidence** for it.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Gateway-only** (API Management / governance hub) | The meaningful control point is at the platform boundary; tool calls are mediated there | Cannot see or decide inside the agent process before a local tool call | Sufficient when there is no in-process decision point; record it as the deliberate choice |
| **In-process policy check** (AGT-style `govern()` before the tool call) | There is a genuine pre-tool decision point with allow / deny / approval semantics inside the process | Preview maturity; runs in customer code; needs an engineering assessment and owner | Adds a decision the gateway cannot make; record policy owner, approval route, and audit retention |
| **Defense in depth** (gateway **and** in-process) | High-authority tool actions where boundary and in-process controls should reinforce each other | Two controls and owners to build, correlate, and maintain | Strongest setup; one control never proves the other is configured or working |
| **Not applicable** (for this architecture) | No real in-process boundary, or no delegated authority worth a local check | Forcing adoption would be theatre | A valid, recorded decision — route back to existing controls and the S6 backlog |

## Supporting decision — What evidence does the boundary need?

If an in-process boundary is chosen, decide the **audit and tamper-evidence**
requirement separately. A local hash chain shows internal consistency only; it
can be replaced and recalculated. Real tamper evidence needs a customer-managed
**signed record in immutable external storage**, owned and retained correctly.

| Evidence need | Suitable option | What it cannot do |
|---|---|---|
| Understand policy decisions & consistency | Offline simulator record | Prove AGT execution, production validity, or tamper evidence |
| Know which policy checked an action | In-process audit record (future assessment) | Prove downstream success or compliance by itself |
| Tamper evidence | Signed immutable external record | Replace policy ownership, approval, or technical validation |

## Decisions made & adoption progress

| Adoption stage | What "done" looks like at S10 |
|---|---|
| **Decided** | The boundary option is chosen (including "not applicable") with the delegated-authority and evidence rationale recorded |
| **Backlogged** | Any in-process assessment, policy ownership, and immutable-audit route are added to the S6 backlog with owners |
| **In adoption** | A separate engineering assessment evaluates installation/code change; S6 reconciles the runtime evidence |

Adoption here authorizes only a separate assessment — not installation,
deployment, or a policy change. Tie the decision to the **S0 maturity baseline**
and **S12 portfolio**, and capture it in the technical decision record
(`labs/s10-in-process-governance/templates/technical-decision-record.template.md`).

## Related references

- [S10 Concepts](concepts.md) — the offline Preview boundary, hash-chain consistency, and what real tamper evidence requires.
- [Platform technical guide](../reference/platform-technical-guide.md) — where AGT sits relative to gateway/network controls.
