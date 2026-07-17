# S4 · Agent Engineering — Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Microsoft agent-path capabilities and Foundry
    features change over time. Confirm current product status in the
    [Platform technical guide](../reference/platform-technical-guide.md) and
    official product docs before delivery.

S4 is the **path-selection decision point**. This page turns the six-path
comparison into an explicit menu with selection criteria and trade-offs, and
names the two decisions that travel with it — **model selection** and the
**admission standard** — so the customer leaves with a recorded implementation
decision and a configuration backlog, not a preference.

These are planning decisions. A path recommendation creates backlog and
ownership; it does **not** deploy or configure any product. Execution stays with
the customer's engineering, security, change, and release processes.

## Decision 1 — Which Microsoft implementation path?

Choose against the agent's **authority boundary**, **users and data boundary**,
required **customization/control**, **engineering ownership**, and the
**governance surface** each path exposes.

| Path | When it fits | Trade-off / limitation | Governance surface to backlog |
|---|---|---|---|
| **Copilot Studio** | Low-code makers, business workflows, fast iteration | Less low-level control; governed largely via Power Platform | Power Platform DLP, environment routing, connector governance |
| **Microsoft Foundry Agent Service** | Pro-code agents needing tools, models, tracing, evaluation | Requires platform/engineering ownership | Project/model, agent type, tools, identity, telemetry, evaluation, red-team, catalog |
| **Custom Azure app/service on Foundry models & tools** | Deep customization, bespoke orchestration or integration | Most engineering to own; broadest attack/governance surface | Identity, gateway, network, telemetry, evaluation — all customer-owned |
| **Microsoft 365 Copilot extensibility** | Agents extending M365 Copilot in the productivity surface | Bounded to the M365 extensibility model | M365 Copilot governance, Agent 365, connector/data governance |
| **Workflow automation** | Deterministic, rules-first automation with limited agency | Not suited to open-ended reasoning tasks | Connector governance, run history, change control |
| **Research / prototype isolation** | Experiments not intended for production | Must stay isolated; not an admission to ship | Isolation boundary, data handling, explicit non-production label |

Record the recommendation, **confidence**, **assumptions**, and the
**alternatives rejected or deferred** — the rejected options are part of the
decision, not noise.

## Decision 2 — Model selection (and fine-tuning, if in scope)

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

## Decision 3 — Admission standard for the chosen path

The admission requirements and test expectations must **match the agent's
authority archetype** (advises / confirms-with-human / acts-in-boundary /
coordinates). Higher authority raises the bar for evidence, human-control points,
evaluation, and red-team coverage. Record what the agent must satisfy before it
ships or materially changes, plus material-change and retirement triggers.

## Decisions made & adoption progress

| Adoption stage | What "done" looks like at S4 |
|---|---|
| **Decided** | One bounded candidate is classified, a path is chosen with rationale, and admission requirements are set |
| **Backlogged** | The selected-path configuration backlog has owners and later-session/change-process routing |
| **In adoption** | Engineering builds the backlog outside this session; S6/S7 assurance and S9 catalog reconcile the evidence |

Tie the outcome to the **S0 maturity baseline** (engineering/admission dimension)
and the **S12 portfolio** roadmap. Capture the choice, alternatives, and
rationale in the technical decision record
(`labs/s4-agent-engineering/templates/technical-decision-record.template.md`);
it complements the admission record as the durable decision artifact.

## Related references

- [S4 Concepts](concepts.md) — authority model, path choices, material changes, retirement.
- [Platform technical guide](../reference/platform-technical-guide.md) — Citadel layers and platform/governance boundary.
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md) and [performance-testing guide](../reference/performance-testing-guide.md).
