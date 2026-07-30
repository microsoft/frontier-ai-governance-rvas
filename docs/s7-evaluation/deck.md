# S7 · Foundry Evaluation Runbook

**Facilitator deck**

Microsoft default: **Microsoft Foundry cloud evaluation, Azure DevOps
`AIAgentEvaluation@2` where the pipeline can consume results, and Azure Load
Testing or approved telemetry where performance matters**.

Concrete decision: **continue, hold, defer, reject, route, block, retest, or
diagnostic-only for one candidate change**.

---

## Start with the project and candidate

- Open `ai.azure.com` and select the pre-release Foundry project.
- Name candidate: model/deployment, agent version, prompt, retrieval, tool/API,
  policy, or release package.
- Name baseline: accepted run, previous agent version, gold result, or missing.
- Name threshold owner and evidence location.

Note:
If there is no baseline or threshold owner, the run can still diagnose behavior
but must not be used as release reliance.

---

## Upload or select the scenario source

- Foundry **Build** -> **Evaluations** -> **Datasets**.
- Upload/select versioned JSONL or CSV, or reference supported response/trace
  IDs.
- Confirm mappings: query, response, context, ground truth, and evaluator fields.
- Record dataset/scenario version and excluded slices.

Note:
Do not paste prompts, outputs, trace payloads, endpoints, secrets, or tenant IDs
into the workshop repository.

---

## Select evaluators from the catalog

- Foundry **Build** -> **Evaluations** -> **Evaluator catalog**.
- Check evaluator name, version, required inputs, region/project support, and
  preview status.
- Choose only dimensions tied to the release question: groundedness, relevance,
  task adherence, tool use, safety, protected material, custom rubric, or
  regression.

Note:
An unavailable or preview-only evaluator is not a blocker by itself; using it as
the only production gate is the blocker.

---

## Configure and run

1. Create evaluation.
2. Select dataset/source and evaluator set.
3. Configure model or agent target.
4. Set baseline and candidate references where supported.
5. Run and wait for **Succeeded**, **Failed**, or **Canceled**.
6. Copy run ID and safe result link to the customer record.

Note:
The result is useful only for the exact project, dataset/scenario version,
evaluator, target, and time window.

---

## Review baseline, candidate, and thresholds

- Compare candidate against baseline.
- Inspect failed high-risk slices before looking at aggregate scores.
- Check metric thresholds and threshold file version.
- Decide whether failures hold release, require retest, or route to exception.

Note:
No baseline means no release meaning unless the threshold owner accepts a
specific alternate comparison rule.

---

## CI/CD branch

- Azure DevOps extension task: `AIAgentEvaluation@2`.
- Auth: ARM service connection, workload identity federation, or managed
  identity.
- Inputs: project endpoint, deployment name, data path, agent IDs, optional
  baseline agent ID.
- Threshold file/post-step controls fail, warn, or require human review.
- Store pipeline report, run ID, threshold version, and safe result link.

Note:
Manual override needs owner, expiry, reason, ticket/change reference, and retest
trigger.

---

## Load and performance branch

- Use Azure Load Testing or the approved customer tool.
- Define request mix, concurrency/ramp, duration, retry, timeout, and stop
  condition.
- Set quota/cost boundary: TPM/RPM/PTU, dependency quotas, test budget.
- Correlate run ID with Foundry traces, Application Insights, Azure Monitor,
  gateway logs, and dependency telemetry.

Note:
Hold release on failed p95/p99 latency, error, throttling, saturation, quota, or
budget threshold.

---

## Expected signals

| Signal | Action |
|---|---|
| Run succeeded | Inspect thresholds and failed slices. |
| Evaluator unavailable | Use alternate/manual route or hold. |
| Threshold failed | Hold or route exception to threshold owner. |
| Result diagnostic-only | Do not use for release reliance. |
| Baseline missing | Create baseline or obtain time-limited exception. |
| Override required | Record owner, expiry, compensating check, retest trigger. |
| Hold release | Stop promotion until fixed, retested, or accepted. |

Note:
End with the receiving owner, next action, accepted-when check, and safe customer
record reference.
