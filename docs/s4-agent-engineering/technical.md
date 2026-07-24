# S4 · Agent Engineering: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Microsoft agent-path capabilities and Foundry
    features change over time. Confirm current product status in the
    [Platform technical guide](../reference/platform-technical-guide.md) and
    official product docs before delivery.

S4 is the path-selection decision point. It compares six paths and records the
associated model-selection and admission decisions. A recommendation creates a
backlog and ownership; it does not deploy or configure a product.

## Decision 1: Which Microsoft implementation path?

Choose based on the agent's **authority**, **users and data**, needed
**customization/control**, **engineering owner**, and the controls each path
exposes.

| Path | When it fits | Trade-off / limitation | Governance surface to backlog |
|---|---|---|---|
| **Copilot Studio** | Low-code makers, business workflows, fast iteration | Less low-level control; governed largely via Power Platform | Power Platform DLP, environment routing, connector governance |
| **Microsoft Foundry Agent Service** | Pro-code agents needing tools, models, tracing, evaluation | Requires platform/engineering ownership | Project/model, agent type, tools, identity, telemetry, evaluation, red-team, catalog |
| **Custom Azure app/service on Foundry models & tools** | Deep customization, bespoke orchestration or integration | Most engineering to own; broadest attack/governance surface | Identity, gateway, network, telemetry, evaluation: all customer-owned |
| **Microsoft 365 Copilot extensibility** | Agents extending M365 Copilot in the productivity surface | Bounded to the M365 extensibility model | M365 Copilot governance, Agent 365, connector/data governance |
| **Workflow automation** | Deterministic, rules-first automation with limited agency | Not suited to open-ended reasoning tasks | Connector governance, run history, change control |
| **Research / prototype isolation** | Experiments not intended for production | Must stay isolated; not an admission to ship | Isolation boundary, data handling, explicit non-production label |

Record the recommendation, **confidence**, **assumptions**, and the
**alternatives rejected or deferred**: the rejected options are part of the
decision, not noise.

## Decision 2: Model selection (and fine-tuning, if in scope)

Model choice is a governance decision as well as an engineering one. Record
capability fit, latency, cost tier, data residency, licensing, deployment
availability, and version ownership. Use the deployment aliases owned by
platform infra rather than hard-coding model names. A fine-tuning proposal needs
a stated capability gap, an alternative considered, training-data governance, and
a base-vs-fine-tuned comparison owner.

See the [quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md)
and the [agent performance-testing guide](../reference/performance-testing-guide.md)
for the selection criteria and the latency/throughput evidence that support this
decision.

## Decision 3: Admission standard for the chosen path

The admission requirements and test expectations must **match the agent's
authority archetype** (advises / confirms-with-human / acts-in-boundary /
coordinates). Higher authority raises the bar for evidence, human-control points,
evaluation, and red-team coverage. Record what the agent must satisfy before it
ships or materially changes, plus material-change and retirement triggers.

## Decision 4: What is the controlled promotion model?

Map the customer's approved labels to a clear DEV → PRE → PRO decision path.
DEV is for isolated development and experimentation with explicit
non-production boundaries; PRE is for integration, certification, and
regression evidence with stated production-equivalence assumptions; PRO is a
separate customer change-authority decision for live operation.

| Stage | Entry decision | Evidence that can inform the next decision | What it cannot prove |
|---|---|---|---|
| **DEV** | S4 admission to a bounded non-production activity | Purpose, authority, ownership, selected-path backlog, and basic non-production controls | Integration safety, production readiness, or operating control effectiveness |
| **PRE** | Customer promotion into certification/integration scope | S3 platform-control profile, accepted S6 gateway proof, S7 evaluation/assurance references, and any applicable S8 disposition | That PRE exactly mirrors PRO, unless the customer records the equivalence evidence and limits |
| **PRO** | Separate production change decision | S9 lifecycle/catalog reference, rollback and support route, operating/alert ownership, and customer approvals | Future quality, safety, availability, or control effectiveness |

Record the customer labels, population, promotion gate, explicit differences,
rollback owner, change authority, and resulting state in
`labs/s4-agent-engineering/templates/rollout-decision-record.template.md`.
Promotion is a decision record, not an instruction to deploy.

## Decisions made & adoption progress

| Adoption stage | What "done" looks like at S4 |
|---|---|
| **Decided** | One bounded candidate is classified, a path is chosen with rationale, and admission requirements are set |
| **Backlogged** | The selected-path configuration backlog has owners and later-session/change-process routing |
| **In adoption** | Engineering builds the backlog outside this session; S6/S7 assurance and S9 catalog reconcile the evidence |

Tie the outcome to the S0 baseline and S12 roadmap. Capture the choice,
alternatives, and rationale in
`labs/s4-agent-engineering/templates/technical-decision-record.template.md`.

## Related references

- [S4 Concepts](concepts.md): authority model, path choices, material changes, retirement.
- [Platform technical guide](../reference/platform-technical-guide.md): Citadel layers and platform/governance boundary.
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md) and [performance-testing guide](../reference/performance-testing-guide.md).
