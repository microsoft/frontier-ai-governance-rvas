# S12 · Portfolio Evidence & Roadmap

**Facilitator deck**

Workshop decision: **Can this bounded portfolio slice produce a defensible next
technical action decision from customer-owned references, with lineage, freshness,
coverage limits, exception concentration, dependency clusters, cost/capacity
basis, prioritization rationale, owner readiness, and baseline feedback
triggers?**

Boundary: S12 prepares a portfolio decision package. It does not create
dashboards, query live systems, approve funding, change policy, certify
compliance, prove runtime enforcement, approve production, or change a baseline.

---

## Portfolio decision package, not dashboard tour

![S12 portfolio decision package: review card, source lineage, decision table, exception concentration, dependency clusters, prioritization, technical action, baseline feedback, blocked gaps, and safe references.](../assets/diagrams/s12-portfolio-to-s0-feedback-loop.svg)

- Start with one portfolio slice and review period.
- Decide: continue, pause, retire, fund, defer, route, or block.
- Keep source lineage, freshness, coverage limits, and owners visible.
- The artifact is a customer-owned decision package and backlog.

Note:
If the room starts discussing charts before agreeing the population and decision
owner process, stop and build the review card first.

---

## Portfolio review card

- Portfolio slice and review period.
- Decision question and receiving owner process.
- Included and excluded agents, workloads, regions, controls, cost centers, and
  evidence sources.
- Portfolio, risk, roadmap, evidence, operations, FinOps/capacity, and baseline
  owners.
- Approved records location.
- Evidence limits and stop condition.

Note:
The review card is the unit of accountability. Without it, the portfolio view
has no boundary.

---

## Source lineage and coverage limits

- Inventory and control plane.
- Identity, tool/API, model/deployment, and data references.
- Assurance and operating references.
- Exception register and accepted-risk items.
- Cost/capacity references.
- Roadmap and baseline references.

Note:
Every metric needs source owner, freshness date, population, exclusions,
coverage limit, interpretation owner, and safe reference.

---

## portfolio decision table field families

- Coverage.
- Residual risk.
- Assurance.
- Operating health.
- Cost/capacity.
- baseline evidence.
- Exception age.
- Dependency.
- Roadmap.
- Owner readiness.
- Confidence.

Note:
The decision table is a decision aid. It is not compliance certification, funding
approval, or proof of operating effectiveness.

---

## Exception concentration views

- By owner.
- By control domain.
- By platform, identity, model, gateway, data, tool/API, or telemetry
  dependency.
- By age, severity, expiry, or recurrence.
- By accepted-risk pressure.
- By unowned blocker.

Note:
Each concentration needs population, pattern, affected items, risk consequence,
owner, escalation route, and closure criterion.

---

## Dependency clusters and sequence

- Shared identity dependency.
- Shared gateway or tool/API route.
- Shared model/deployment or fallback dependency.
- Shared data source.
- Shared telemetry or operating signal gap.
- Shared funding, capacity, ownership, or policy dependency.

Note:
A dependency cluster tells the portfolio what must be sequenced together. It is
not a blame map.

---

## Framework and assurance boundary

- NIST AI RMF, ISO/IEC 42001, EU AI Act, and Microsoft Responsible AI principles
  can structure questions.
- Framework mapping is not certification.
- Portfolio aggregation is not assurance evidence.
- Separate assurance, legal, compliance, and audit owners retain their own
  processes.

Note:
Do not let a mapping table become a conformity claim.

---

## Failure modes and hard stops

- No approved records location.
- Unknown population or review period.
- Stale inventory treated as complete fleet.
- Aggregate score hides excluded high-risk workload.
- Cost/capacity decision has no allocation owner.
- Accepted-risk item is past expiry.
- Dependency cluster has no sequence owner.
- technical action has no owner.
- Funding approval requested in the workshop.
- Framework mapping treated as certification.
- baseline movement lacks stable baseline and evidence.

Note:
Translate each failure into defer, route, block, or backlog with owner,
acceptance test, target event, evidence reference, and recheck condition.

---

## Workshop artifact and handoff

- Portfolio review card.
- Source-lineage and coverage package.
- Decision table package.
- Exception concentration and dependency package.
- Prioritization and trade-off record.
- technical action and owner-readiness package.
- Baseline feedback record.
- Decision and backlog.

Note:
Close with the customer-owned decision package and receiving owner. Keep raw
evidence in customer-approved systems only.
