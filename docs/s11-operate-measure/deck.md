# S11 · Operate, Monitor & FinOps

**Facilitator deck**

Governance lead · Service owner · Cost owner · 90-minute operating-review design session

## One operating question

> **"What decision can this review support, and what evidence limits travel with it?"**

The customer leaves with a repeatable review definition, owners, cadence, limits, and next review.

---

## Review evidence, not dashboards

![Operating review produces decisions and drift hypotheses.](../assets/diagrams/s11-operating-review-flow.svg)

- Every question needs population, period, coverage limit, owner, and decision use.
- Unavailable, uninstrumented, and excluded paths are coverage gaps—not zero or pass.
- Foundry traces, OpenTelemetry, and Application Insights can supply bounded operating signals.
- A production score or trend is not release sign-off or control-enforcement proof.

---

## FinOps and drift

- Record workload scope, shared-cost assumptions, allocation limits, cost owner, and exclusions.
- Training and inference cost are distinct for fine-tuned models.
- Difference from an S7 synthetic baseline is a drift hypothesis until tested against workload, version, quota, configuration, and coverage changes.

---

## Entry and boundary

- **Entry:** S9 closeout or documented deferral, question owners, evidence references, and approved records location.
- **Boundary:** approved references only; no live-data query, copied telemetry, dashboard, metric, threshold, remediation, policy, identity, or production change.
- No trusted evidence or accountable owner means the question is blocked.

---

## Step 1 — Define the review · 10 min

Select one population, period, decision, owners, and records location.

> **"What is out of scope?"**

---

## Step 2 — Map coverage · 15 min

For every question, record evidence references, coverage, exclusions, latency and attribution limits, and, where relevant, Foundry project, deployment, agent/run identifier, evaluator, and version.

---

## Step 3 — Select questions · 20 min

Choose only relevant control-coverage, reliability, risk, quality, cost, adoption, human-review, or business-outcome questions.

> **"Who interprets this? What decision follows? What else could explain a change?"**

---

## Step 4 — Drift, remediation, and exception routes · 30 min

Record a hypothesis, alternatives, evidence limits, test or observation plan, owner, escalation trigger, validation, recurrence check, exception expiry, and closure reviewer.

---

## Step 5 — Decide and hand over · 15 min

Approve, defer, or reject the review definition and technical choices. Record limits, unresolved gaps, and next review.

---

## Verification and handoff

- [ ] Population, decision, owners, cadence, and evidence location are recorded.
- [ ] Selected questions have coverage limits and interpretation owners.
- [ ] Drift hypotheses and findings have test, validation, recurrence, and escalation routes.
- [ ] Operating and technical decisions are recorded or backlogged.

The review definition and remediation references enter the customer governance cadence; implementation remains with customer engineering and change processes.
