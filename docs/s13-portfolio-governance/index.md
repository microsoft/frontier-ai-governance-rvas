# S13 · Portfolio Governance & Continuous Improvement

!!! info "Freshness"
    Last reviewed: 2026-07-29. Verify current Microsoft service capabilities,
    tenant coverage, licensing, reporting limits, cost allocation, and customer
    governance requirements before delivery.

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Portfolio owner</span> <span class="rvas-badge rvas-persona">Risk owner</span>

## 1. Outcome & what the customer keeps

The customer answers one practical portfolio question:
**can this bounded portfolio slice produce a defensible next roadmap decision
from customer-owned references, with lineage, freshness, coverage limits,
exception concentration, dependency clusters, cost/capacity basis,
prioritization rationale, owner readiness, and baseline feedback triggers?**

**Plain decision question:** Should this portfolio item **continue, pause,
retire, fund, defer, route, or block** for the next customer process? The
default is the customer-approved records system, supplemented by verified
Microsoft records where applicable. Any other source needs documented scope,
freshness, owner, and limit.

They leave with:

- a **portfolio review card** for one bounded population, review period,
  decision forum, included/excluded scope, owners, and approved records
  location;
- a source-lineage and coverage package for inventory, control-plane,
  exception, assurance, operating, cost/capacity, roadmap, and baseline
  references;
- a portfolio scorecard with coverage, residual risk, assurance, operating
  health, cost/capacity, maturity, exception age, dependency, roadmap,
  owner-readiness, and confidence fields;
- exception concentration and dependency cluster views that identify repeated
  patterns, shared blockers, owners, escalation routes, and closure criteria;
- a prioritization and trade-off record covering risk, value, cost, capacity,
  coverage, dependency leverage, maturity movement, urgency, confidence, and
  effort/complexity;
- a roadmap action package with owner readiness, target date, acceptance test,
  evidence reference, exception status, and next review trigger;
- baseline feedback questions for repeated ownership gaps, evidence gaps, risk
  appetite issues, cost/capacity pressure, dependency concentration, matured
  controls, stale assumptions, or policy ambiguity; and
- a decision and backlog with safe references only.

`labs/s13-portfolio-governance/` holds blank offline templates for the
customer-approved records system. It does **not** consolidate live data, create
a dashboard, calculate an authoritative portfolio score, alter policy, approve
funding, certify compliance, or approve production.

### What happens next

The receiving governance, roadmap, finance, platform, operations, risk, policy,
or baseline owner moves accepted actions through the customer's separate
authority and records process. S13 creates a portfolio decision package and
backlog; it does not execute investments or policy changes.

## 2. Prerequisites

- One bounded portfolio slice, pilot set, roadmap item, exception set,
  dependency cluster, cost/capacity decision, or baseline feedback question.
- A review period, population definition, included and excluded scope, and
  receiving decision forum.
- Named portfolio decision owner, roadmap owner, risk owner, evidence owner,
  control-plane steward, operating review owner, FinOps/capacity owner where
  relevant, and baseline owner.
- Approved customer records location and source-reference routes for inventory,
  exception, assurance, operating, cost/capacity, roadmap, and baseline records.

The session can start with gaps. Missing or stale evidence is recorded as a
coverage limit, not replaced with a template, estimate, aggregate label, or
empty score.

## 3. Why this session matters

Local reviews can produce good action items and still miss portfolio patterns:
the same owner gap across many agents, one gateway dependency blocking several
roadmap items, a cost allocation issue hiding consumption pressure, or a policy
assumption that no longer fits actual usage.

S13 makes those patterns visible without turning the repository into a customer
data warehouse. Every rollup keeps its source lineage, freshness, exclusions,
and interpretation owner. The result is a decision package leaders can use to
choose what continues, pauses, retires, gets funded, gets routed, or returns to
the baseline cycle.

The key discipline is that aggregation is not proof. A scorecard can support a
roadmap decision only when the covered population, excluded scope, stale
sources, missing owners, and confidence limits remain visible.

Read [S13 Concepts](concepts.md) before delivery and [Technical decisions](technical.md)
for the scorecard, prioritization, concentration, dependency, and baseline
feedback record shapes.

## 4. Change boundary

S13 is report-only. It makes no dashboard, live-data query, production, access,
configuration, policy, budget, funding, compliance-certification, maturity
certification, or baseline-change decision by itself. Any approved change,
assurance activity, investment execution, policy update, or baseline update uses
the organization's separate authority, change, and records processes.
