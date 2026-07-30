# S12 · Portfolio Evidence & Roadmap

!!! info "Freshness"
    Last reviewed: 2026-07-30. Verify current Microsoft service capabilities,
    tenant coverage, licensing, reporting limits, cost allocation, and customer
    technical decision requirements before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Portfolio owner</span> <span class="rvas-badge rvas-persona">Risk owner</span>

!!! abstract "What is at stake"
    Individual reviews can hide repeated gaps, shared dependencies, and cost
    pressure that should change the next portfolio decision.

## 1. Prioritize one portfolio slice

Use one bounded portfolio slice to choose a defensible next technical action.
Compare source lineage, freshness, coverage limits, exception concentration,
dependency clusters, cost/capacity basis, owner readiness, and baseline feedback
triggers.

**Plain decision question:** Should this portfolio item **continue, pause,
retire, fund, defer, route, or block** for the next customer process? The
default is the customer-approved records system, supplemented by verified
Microsoft records where applicable. Any other source needs documented scope,
freshness, owner, and limit.

Work through these checks:

- Open the S0 intake record for each candidate workload. Check sponsor, owner,
  intended use, user population, platform path, target event, and acceptance
  criteria.
- Open S2 compliance/Purview references. Check compliance state, unsupported
  data-path limits, retention/eDiscovery route, and open gaps.
- Open S5 API/tool admission references. Check API/tool owner, schema/route,
  gateway state, permission boundary, and unapproved tool gaps.
- Open S7 evaluation references. Check baseline/candidate result, unsupported
  slices, threshold owner, and retest state.
- Open S8 findings. Check severity, exploitability or impact, remediation owner,
  exception expiry, retest plan, and open blocker.
- Open S9 inventory/control-plane references. Check owner, identity, API/tool,
  Foundry, telemetry, lifecycle, duplicate records, and stale state.
- Open S10 operating/cost references. Check alert/correlation coverage,
  latency/error/capacity/cost signal, incident route, budget/export, and owner.
- Open the customer backlog/change system. Check current status, dependency,
  target event, funding/capacity assumption, and next accepted action.
- Rank three candidates by technical blocker, risk, value, dependency, and next
  action while keeping source freshness, exclusions, unsupported paths, and
  owner gaps visible.

`labs/s12-portfolio-governance/` holds blank offline templates for the
customer-approved records system. It does **not** consolidate live data, create
a dashboard, calculate an authoritative portfolio score, alter policy, approve
funding, certify compliance, or approve production.

### What happens next

The receiving portfolio, finance, platform, operations, risk, policy,
or baseline owner moves accepted actions through the customer's separate
authority and records process. S12 sets portfolio priorities and a backlog; it
does not execute investments or policy changes.

## 2. Prerequisites

- One bounded portfolio slice, pilot set, technical action, exception set,
  dependency cluster, cost/capacity decision, or baseline feedback question.
- A review period, population definition, included and excluded scope, and
  receiving decision path.
- Named portfolio decision owner, technical action owner, risk owner, evidence owner,
  control-plane steward, operating review owner, FinOps/capacity owner where
  relevant, and baseline owner.
- Approved customer records location and source-reference routes for inventory,
  exception, assurance, operating, cost/capacity, technical action, and baseline records.

The session can start with gaps. Treat missing or stale evidence as a
coverage limit; do not replace it with a template, estimate, aggregate label, or
empty result.

## 3. See the patterns individual reviews miss

Local reviews can produce good action items and still miss portfolio patterns:
the same owner gap across many agents, one gateway dependency blocking several
technical actions, a cost allocation issue hiding consumption pressure, or a policy
assumption that no longer fits actual usage.

S12 makes those patterns visible without turning the repository into a customer
data warehouse. Every rollup keeps its source lineage, freshness, exclusions,
and interpretation owner. The result lets leaders choose what continues, pauses,
retires, gets funded, gets routed, or returns to
the baseline cycle.

The key discipline is that aggregation is not proof. A portfolio decision table
is useful only when the covered population, excluded scope, stale sources,
missing owners, and confidence limits remain visible.

Use [Technical decisions](technical.md) for prioritization, concentration,
dependency, source-lineage, and baseline-feedback record shapes.

## 4. Expected portfolio signals

| Signal | Meaning | Next action |
|---|---|---|
| Promotable workload | Intake, compliance, API/tool, evaluation, findings, control-plane, operating/cost, and backlog references are current enough for the next customer process. | Continue, fund, or promote through the customer process. |
| Blocked workload | Required owner, evidence route, remediation, evaluation, operating signal, rollback, funding/capacity, or records location is missing. | Block or defer with acceptance check. |
| Unsupported workload | Product, region, connector, data path, API/tool route, monitoring, or compliance coverage is not supported for the intended claim. | Route to platform/product/risk owner. |
| Duplicate initiative | Same workload or dependency appears in multiple intake, portfolio, backlog, or change records. | Merge or split with portfolio owner. |
| Missing owner | No accountable owner for workload, risk, API/tool, operations, FinOps, or evidence. | Stop ranking reliance until owner is assigned. |
| Missing operating signal | S10 signal, cost/capacity view, alert, correlation, or incident route is unavailable. | Route to operations/telemetry/FinOps owner. |
| Stale exception | Exception is expired or lacks recheck owner/date. | Route to risk owner and block promotion reliance. |

## 5. Support limits

S12 can rank and route work only from customer-approved references. It does not
turn framework mappings into certification, aggregate scores into funding
approval, stale evidence into fleet truth, or missing telemetry into a healthy
state. If a source system is unsupported, sampled, aggregate-only, stale,
non-comparable, or outside the review period, name the owner and recheck route
before relying on it.

## 6. Change boundary

S12 is report-only. It makes no dashboard, live-data query, production, access,
configuration, policy, budget, funding, compliance-certification, baseline evidence
claim, or baseline-change decision by itself. Any approved change,
assurance activity, investment execution, policy update, or baseline update uses
the organization's separate authority, change, and records processes.
