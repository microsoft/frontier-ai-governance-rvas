# Operational maturity model

Use this model to explain the enterprise adoption journey before selecting
sessions. Customers do not need more governance vocabulary first; they need to
know which operating capability is missing, who owns it, and what artifact moves
it forward.

The model is progressive, but not strictly linear. A customer may enter through
an urgent security, identity, evaluation, or portfolio question. Use S0 to
confirm the first blocker, then select the smallest session set that advances
the maturity level with a durable output. Use the
[Implementation artifact catalog](../reference/implementation-artifact-catalog.md)
to map that output to the repository skeleton that future implementation labs
can fill in.

| Level | Goal | Customer outcome | Primary sessions |
|---|---|---|---|
| **1. Discover** | Know what AI exists and why it matters. | Bounded use case, owner, evidence location, inventory, lifecycle state, and portfolio visibility. | [S0](../s0-foundations/index.md), [S9](../s9-control-plane/index.md), [S12](../s12-portfolio-governance/index.md) |
| **2. Secure** | Prevent obvious mistakes before scale. | Identity boundary, data-use decision, platform route, runtime control path, and named remediation owners. | [S1](../s1-identity/index.md), [S2](../s2-data-compliance/index.md), [S3](../s3-platform-foundation/index.md), [S6](../s6-security-runtime/index.md) |
| **3. Govern** | Standardize how AI work is admitted, changed, and published. | Admission standard, tool/API publication rule, model and prompt change-control path, and implementation backlog. | [S4](../s4-agent-engineering/index.md), [S5](../s5-tool-api-governance/index.md), [S11](../s11-llm-operations/index.md) |
| **4. Operate** | Observe production-like behavior and route action. | Evaluation threshold, authorized red-team finding route, telemetry review, cost/capacity owner, and operating cadence. | [S7](../s7-evaluation/index.md), [S8](../s8-red-teaming/index.md), [S10](../s10-operate-measure/index.md) |
| **5. Scale** | Automate governance and continuous improvement. | Reconciled control-plane records, governance agents, continuous compliance backlog, executive roadmap, and recurrence model. | [S9](../s9-control-plane/index.md), [S10](../s10-operate-measure/index.md), [S12](../s12-portfolio-governance/index.md) |

## How to use it in delivery

1. Start with the business outcome and candidate workload, not the technology.
2. Identify the maturity level that is blocking adoption.
3. Select the minimum sessions that create the needed artifact or decision.
4. Name the Microsoft control path and the customer owner who can act on it.
5. End with the next tenant, repository, dashboard, policy, backlog, or
   operating-process change.

## Session selection patterns

| If the customer says... | Start here | Then route to... |
|---|---|---|
| "We do not know what agents exist." | Discover | S0 for scope, S9 for reconciliation, S12 for portfolio triage. |
| "We are worried about access or data exposure." | Secure | S1 for identity, S2 for data path, S3/S6 for platform and runtime controls. |
| "Teams are building agents differently." | Govern | S4 for admission, S5 for tools/APIs, S11 for model and prompt lifecycle. |
| "We need confidence before release." | Operate | S7 for evaluation, S8 for authorized red teaming, S10 for operating signals. |
| "We need this to become repeatable." | Scale | S9/S12 for control-plane and portfolio cadence, then governance automation backlog. |

## Evidence and implementation boundary

This maturity model is an adoption guide, not a certification score. A level is
usable only when the customer has named owners, safe evidence references,
accepted next actions, and a recurrence path in its own records system.
Templates, samples, and offline helpers are preparation aids; they do not prove
that a customer control is deployed or operating.
