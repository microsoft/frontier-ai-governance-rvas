# Practical workshop: portfolio governance decision route

**Microsoft default:** Agent 365 and control-plane records, Azure Cost Management, operating evidence, roadmap, and the S0 re-baseline.

**Customer decision:** Approve, defer, reject, or route one bounded portfolio-governance decision. This is a prioritization and handoff decision only; it does not change tenant policy, prove runtime enforcement, or approve production use.

## Work the decision

1. **Choose the portfolio question.** Select one bounded portfolio slice, pilot set, roadmap item, exception set, or capacity/cost decision. Name the portfolio decision owner, roadmap owner, evidence owner, finance/FinOps owner if relevant, and receiving forum.
2. **Assemble the rollup by reference.** Use customer-approved records for Agent 365/control-plane inventory, exception register, cost/capacity view, S11 operating evidence, roadmap, and S0 baseline. Record source lineage, freshness date, coverage limits, and owner for each source.
3. **Classify the route.** Pick the route that best fits the scenario before discussing acceptance:

| Scenario | Route | Practical decision cue |
|---|---|---|
| Complete rollup is available | Portfolio decision | Approve only as a handoff when source lineage, freshness, coverage limits, prioritization rationale, roadmap owner, and S0 re-baseline trigger are recorded. |
| Evidence is incomplete, stale, or not comparable | Evidence blocker | Defer until each missing source has an owner, target date, evidence location, freshness expectation, coverage limit, and recheck trigger. |
| Cost, capacity, or funding decision is needed | Finance / capacity route | Route to finance, FinOps, platform capacity, or sponsor owner with cost basis, capacity assumption, decision date, and roadmap impact. |
| Risk and value conflict | Governance prioritization route | Route to the portfolio forum with risk/value rationale, affected controls, exception status, value hypothesis, and stop or continue criteria. |
| No action owner for a portfolio item | Ownership blocker | Defer or block until roadmap owner, implementation owner, evidence owner, and receiving process are named. |
| Portfolio change alters foundation assumptions | S0 re-baseline trigger | Route to S0 baseline owner when scope, risk appetite, operating model, forum, ownership, funding, or roadmap sequencing changes. |

4. **Inspect portfolio tradeoffs without changing records.** Compare risk, value, cost, capacity, operating readiness, exception status, and roadmap dependency using references only. Do not paste customer evidence into this repository.
5. **Record the outcome and handoff.** Approve only when the rollup is traceable and fresh enough for the receiving owner to act. Otherwise defer with acceptance checks, reject if the item cannot meet the bounded portfolio goal, or route to finance, risk, roadmap, operating, or S0 baseline owner.

## Decision record

Fill this record in the customer-approved records system. Store only safe references here; completed evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Portfolio governance decision |
| Portfolio slice | Pilot set, roadmap item, exception set, capability group, or capacity/cost decision |
| Source lineage | Agent/control-plane inventory, exception register, cost/capacity view, S11 evidence, roadmap, and S0 baseline references |
| Freshness | Review date, expected refresh cadence, stale sources, and owner |
| Coverage limit | Workloads, agents, regions, business units, cost centers, controls, or evidence sources excluded from the rollup |
| Prioritization rationale | Risk/value/cost/capacity tradeoff, decision options, selected route, and stop or continue criteria |
| Roadmap owner | Accountable owner for sequencing, funding, backlog, and next forum |
| S0 re-baseline trigger | Portfolio change that requires operating-model or baseline update, or explicit no-trigger rationale |
| Handoff | Owner and customer process that accepts the decision or backlog item |

## Decision tree

- **Approve** when source lineage, freshness, coverage limits, prioritization rationale, roadmap owner, evidence location, acceptance check, target date, and S0 re-baseline trigger are complete.
- **Defer** when evidence is incomplete, stale, non-comparable, unowned, or lacks coverage/freshness limits, but a named owner can close the gap.
- **Reject** when the portfolio item cannot meet the bounded risk, value, cost, capacity, or operating-readiness goal.
- **Route** when finance, FinOps, platform capacity, risk, roadmap, evidence, operating, exception, or S0 baseline owner must decide first.

For an exception, record: reason, affected portfolio item, source limitation, residual risk, value or cost impact, equivalent control or compensating review, owner, evidence location, acceptance test, target date, roadmap impact, and review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Source lineage | every rollup metric or claim traces to a customer-approved Agent/control-plane, exception, cost, S11, roadmap, or S0 record reference | Evidence owner |
| Freshness | each source has a review date, expected refresh cadence, stale/not-available state, and owner | Portfolio operations |
| Coverage limit | included and excluded workloads, agents, regions, controls, cost centers, and evidence sources are named | Control-plane steward |
| Prioritization rationale | continue, pause, retire, fund, defer, or route decision cites risk, value, cost/capacity, operating readiness, and exception status | Portfolio forum |
| Roadmap owner | sequencing, funding, backlog, target date, and receiving process have an accountable owner | Roadmap owner |
| S0 re-baseline trigger | changes to scope, risk appetite, operating model, ownership, funding, or roadmap sequencing are routed to the S0 baseline owner, or no-trigger rationale is recorded | S0 baseline owner |
| No action owner | any unowned portfolio item is deferred or blocked with owner-assignment action, target date, and recheck forum | Executive sponsor |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, changes no tenant policy, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Workshop facilitator |

**Boundary:** Keep customer evidence in customer-approved systems; store references only. This workshop records portfolio prioritization and handoffs only.
