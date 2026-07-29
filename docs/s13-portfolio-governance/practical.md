# Practical workshop: portfolio decision package

**Microsoft default:** Agent 365 and Microsoft control-plane records where
available, customer-approved exception and roadmap records, Azure Cost
Management and FinOps records for investment decisions, operating/evaluation/
red-team records for assurance, and the foundation baseline for re-measurement.

**Customer decision:** Continue, pause, retire, fund, defer, route, or block one
bounded portfolio item. This is a prioritization and handoff decision only; it
does not change tenant policy, prove runtime enforcement, approve funding,
certify compliance, or approve production use.

## Work the package

1. **Choose the portfolio slice and review period.** Select one pilot cohort,
   agent population, capability group, roadmap item set, exception set,
   dependency cluster, or cost/capacity decision. Name the included and excluded
   scope, decision forum, review period, portfolio owner, roadmap owner, risk
   owner, evidence owner, control-plane steward, operating review owner, and
   FinOps/capacity owner where relevant.
2. **Build the review card.** Record decision question, population, review
   period, decision forum, approved records location, evidence limits, and stop
   condition.
3. **Assemble source lineage and coverage.** Use customer-approved references
   for inventory/control-plane, identity, tool/API, model/deployment, assurance,
   operating health, exceptions, cost/capacity, roadmap, and baseline records.
   Record source owner, freshness, population, exclusions, coverage limit, and
   interpretation owner before making a recommendation.
4. **Build the scorecard.** Fill only the fields that can be supported by safe
   references. Use coverage, residual risk, assurance, operating health,
   cost/capacity, maturity, exception age, dependency, roadmap, owner readiness,
   and confidence fields.
5. **Identify concentration and clusters.** Look for repeated exceptions,
   accepted-risk expiry, shared dependencies, unowned blockers, stale evidence,
   cost/capacity pressure, and roadmap items that need sequencing.
6. **Compare trade-offs.** Apply risk/value/cost/capacity/coverage/dependency/
   maturity/urgency/confidence/effort criteria. Use weights only when the
   governance forum owns them.
7. **Define roadmap action and owner readiness.** Record action type,
   accountable owner, implementation owner, evidence owner, funding/capacity
   owner where relevant, dependency owner, target date, acceptance test,
   evidence reference, exception status, and next review trigger.
8. **Record baseline feedback.** Decide whether repeated patterns open a
   baseline question about ownership, evidence expectations, risk appetite,
   funding, cadence, policy, or sequencing.
9. **Record outcome and handoff.** Continue, pause, retire, fund, defer, route,
   or block with rationale, owner, acceptance test, target date, evidence
   reference, and review trigger.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Complete rollup with clear owners | Continue / fund / roadmap handoff | Act only when lineage, freshness, coverage limits, prioritization rationale, roadmap owner, target date, and baseline trigger are recorded. |
| Stale control-plane inventory | Defer evidence reliance | Record stale source, affected population, owner, refresh expectation, coverage limit, and recheck trigger. |
| Expired accepted-risk item | Route or block | Escalate to risk owner with expiry, affected items, residual risk, closure criterion, and roadmap impact. |
| High-cost, low-evidence capability | Pause / route / defer | Require cost allocation owner, value hypothesis, evidence plan, capacity basis, and stop/continue criteria. |
| Shared identity, gateway, model, data, or telemetry dependency | Dependency cluster | Name sequence owner, first unblock action, downstream items, and review trigger. |
| Evidence gap hidden by aggregate score | Split or block conclusion | Do not use the aggregate until excluded population and confidence limit are visible. |
| Cost/capacity pressure | Finance / capacity route | Route with cost basis, allocation owner, capacity assumption, decision date, and roadmap impact. |
| No roadmap owner | Block or defer | Assign accountable owner, implementation owner, evidence owner, receiving forum, and target date before prioritization. |
| Maturity movement claim | Baseline feedback | Require stable question, same scope or explicit scope change, supporting references, and owner acceptance. |
| Framework mapping request | Assurance route | Use framework to structure questions; do not issue certification or conformity conclusion. |
| Funding request | Customer funding process | S13 can provide rationale and references, not funding approval. |
| Repeated ownership or evidence gap | Baseline feedback trigger | Open owner and evidence-system questions for the baseline owner and governance forum. |

## Decision record

Fill this record in the customer-approved records system. Store only safe
references here; completed evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Portfolio decision package |
| Review card | Portfolio slice, population, review period, decision question, included/excluded scope, decision forum, owners, records location, evidence limits, stop condition |
| Source lineage | Inventory/control-plane, identity, tool/API, model/deployment, assurance, operating, exception, cost/capacity, roadmap, and baseline references with freshness and coverage limits |
| Scorecard | Coverage, residual risk, assurance, operating health, cost/capacity, maturity, exception age, dependency, roadmap, owner readiness, and confidence fields |
| Exception concentration | Population, pattern, affected items, shared dependency, risk consequence, owner, escalation, closure criterion |
| Dependency cluster | Dependency type, blocked roadmap items, sequence owner, first unblock action, downstream effect, risk if ignored, review trigger |
| Prioritization | Criteria, weights if used, owner, rationale, rejected alternatives, uncertainty, decision forum, action implication |
| Roadmap action | Continue / pause / retire / fund / defer / route / block / monitor / re-baseline / open policy question |
| Owner readiness | Accountable owner, implementation owner, evidence owner, funding/capacity owner, dependency owner, target date, acceptance test |
| Baseline feedback | Trigger, question, owner, evidence references, target forum, accepted-when condition, review trigger |
| Decision | Result, rationale, evidence reference, exception status, backlog item, handoff owner, next review trigger |

## Acceptance checks

| Check | Accepted when... | Receiving owner |
|---|---|---|
| Review card | population, period, included/excluded scope, forum, owners, records location, evidence limits, and stop condition are recorded | Portfolio owner |
| Source lineage | every rollup metric or claim traces to source owner, freshness date, coverage limit, interpretation owner, and safe reference | Evidence owner |
| Scorecard | fields are supported by references and confidence/coverage limits are visible | Portfolio/governance owner |
| Exception concentration | population, affected items, repeated pattern, shared dependency, escalation route, and closure criterion are recorded | Risk owner |
| Dependency cluster | sequence owner, first unblock action, blocked items, downstream effects, and review trigger are recorded | Roadmap owner |
| Prioritization | criteria, weights, rationale, rejected alternatives, uncertainty, decision forum, and action implication are recorded | Governance forum |
| Roadmap action | owner, target date, acceptance test, evidence reference, exception status, blocked-by list, and next review trigger are recorded | Roadmap owner |
| Baseline feedback | question, trigger, owner, evidence references, target forum, accepted-when condition, and review trigger are recorded | Baseline owner |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, changes no tenant policy, and makes no dashboard, funding, compliance, runtime-proof, enforcement, or production-approval claim | Facilitator |

## Decision tree

- **Continue** when the action should proceed through the receiving customer
  process with owner, evidence, target date, and review trigger.
- **Pause** when the item should stop expanding until evidence, cost, risk, or
  ownership changes.
- **Retire** when the item should enter the customer's retirement/removal
  process with dependency review and retained-record route.
- **Fund** when the package is ready for the customer funding process. This is
  not funding approval.
- **Defer** when evidence is incomplete, stale, non-comparable, unowned, or lacks
  coverage/freshness limits, but a named owner can close the gap.
- **Route** when finance, FinOps, platform capacity, risk, roadmap, evidence,
  operating, exception, assurance, legal/compliance, policy, or baseline owner
  must decide first.
- **Block** when ownership, forum authority, evidence location,
  cost/capacity basis, roadmap ownership, source lineage, or scope clarity
  prevents a defensible decision.

For an exception, record: reason, affected portfolio item, source limitation,
residual risk, value or cost impact, equivalent control or compensating review
if one exists, owner, evidence reference, acceptance test, target date, roadmap
impact, expiry, and review trigger.

**Boundary:** Keep customer evidence in customer-approved systems; store
references only. This workshop records portfolio prioritization and handoffs
only.
