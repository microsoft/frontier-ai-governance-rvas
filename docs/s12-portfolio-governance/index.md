# S12 · Portfolio Evidence & Roadmap

!!! info "Freshness"
    Last reviewed: 2026-07-29. Verify current Microsoft service capabilities,
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

- a **portfolio review card** for one bounded population, review period,
  decision path, included/excluded scope, owners, and approved records
  location;
- a source-lineage and coverage package for inventory, control-plane,
  exception, assurance, operating, cost/capacity, technical action, and baseline
  references;
- a compact decision table with coverage, residual risk, assurance, operating
  health, cost/capacity, exception age, dependency, owner-readiness, and
  confidence fields;
- exception concentration and dependency cluster views that identify repeated
  patterns, shared blockers, owners, escalation routes, and closure criteria;
- a prioritization and trade-off record covering risk, value, cost, capacity,
  coverage, dependency leverage, urgency, confidence, and
  effort/complexity;
- a technical action package with owner readiness, acceptance test, evidence
  reference, blocker status, and next action;
- baseline feedback questions for repeated ownership gaps, evidence gaps, risk
  appetite issues, cost/capacity pressure, dependency concentration, matured
  controls, stale assumptions, or policy ambiguity; and
- a decision and backlog with safe references only.

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

## 4. Change boundary

S12 is report-only. It makes no dashboard, live-data query, production, access,
configuration, policy, budget, funding, compliance-certification, baseline evidence
claim, or baseline-change decision by itself. Any approved change,
assurance activity, investment execution, policy update, or baseline update uses
the organization's separate authority, change, and records processes.
