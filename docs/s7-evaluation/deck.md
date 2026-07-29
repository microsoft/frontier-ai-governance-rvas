# S7 · Evaluation Evidence & Release Readiness

**Facilitator deck**

Microsoft default: **Microsoft Foundry evaluations, agent evaluators, cloud
evaluation, CI/CD integration, and Azure Load Testing where applicable**.

Concrete decision: **continue, hold, defer, reject, route, block, or mark
diagnostic-only for one candidate change.**

---

## 1. Evaluation evidence, not release approval

- S7 builds an evaluation evidence package.
- The package informs the customer's release process.
- It does not approve production, change a pipeline, configure Foundry, set
  thresholds, or prove runtime enforcement.

Note:
Open by breaking the old gate framing. The artifact is evidence for a customer
release decision.

---

## 2. Start with one candidate change

- Workload and capability.
- Model, prompt, retrieval, tool/API, policy, deployment alias, or release
  package change.
- Release question: what would continue, hold, or roll back?
- Owners: model/agent, scenario, evaluation, threshold, evidence, release/hold,
  rollback.

Note:
Keep the room on one concrete change. Do not let the session become a generic
quality framework discussion.

---

## 3. Runtime-path acceptance before release reliance

- If accepted runtime-path evidence exists, reference it safely.
- If it is missing, the evaluation can still be useful.
- Missing runtime prerequisite means **diagnostic-only**, not release reliance.

Note:
This protects the boundary between evaluator results and actual reviewed runtime
control evidence.

---

## 4. Scenario set is the unit of evidence

- Scenario-set reference and owner.
- Source, population, sampling method, included slices, excluded slices.
- Data/tool boundary, environment assumption, reviewer role, time window.
- Material-change triggers.

Note:
Ask "what did this scenario set actually represent?" before looking at scores.

---

## 5. Evaluator and rubric route comparison

- Foundry evaluator where supported.
- Agent evaluator for task, intent, tool-use, or agent behavior.
- Manual rubric or SME scorer for domain/policy judgment.
- CI/CD cloud evaluation when release automation is mature.
- Load/performance route when latency, quota, saturation, or cost matters.
- Diagnostic-only when prerequisites are missing.

Note:
Make the route choice explicit. Different routes produce different evidence
packages and limitations.

---

## 6. Baseline and candidate comparison

- Baseline run, score, or accepted behavior reference.
- Candidate run/reference tied to the exact change.
- Comparison rule and selected metrics.
- Regression tolerance and re-evaluation criterion.

Note:
Without a baseline, the team is staring at a number with no release meaning.

---

## 10. Finding-to-action map

- Low groundedness -> retrieval, source, or prompt backlog.
- Unsafe result -> safety review, threshold review, or runtime-control backlog.
- Tool-call error -> tool contract, parameter, or authority backlog.
- Regression -> change-owner review, rollback option, repeat evaluation.
- Latency/cost miss -> operating, quota, budget, or capacity hypothesis.

Note:
Every finding needs an owner and closure evidence. Scores without actions are
noise.

---

## 11. Diagnostic-only and hard stops

- No accepted runtime-path evidence for release reliance.
- No scenario owner or baseline.
- No threshold owner.
- Unsupported evaluator used as sole production gate.
- Aggregate score hides failed high-risk slices.
- No release/hold owner, rollback route, or approved records location.

Note:
These are not presentation details; they determine whether the package can be
used.

---

## 12. Close with the artifact

- Decision: continue, hold, defer, reject, route, block, or diagnostic-only.
- Evidence package: candidate card, scenario set, evaluator/rubric, baseline,
  thresholds, gate behavior, performance/cost, findings, handoff.
- Boundary: customer evidence stays in approved systems; production changes use
  customer change approval.

Note:
End with a handoff the receiving owner can act on.
