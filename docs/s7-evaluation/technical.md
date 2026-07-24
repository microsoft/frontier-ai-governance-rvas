# S7 · Quality, Safety Evaluation & Release Assurance: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Evaluation, tracing, load-testing, and CI/CD
    capabilities change over time; verify current status, availability, region,
    quota, and pricing before delivery. See the [performance-testing guide](../reference/performance-testing-guide.md).

Choose evaluation evidence, a release-gate path, and a performance-evidence
path for the bounded release. S7 records the choice; it does not implement it.

**Default and exception.** Default to Microsoft Foundry evaluations or agent
evaluators where current support fits, combined with accepted S6 evidence and a
customer-owned release decision. A manual scorer, another service, or an
explicit coverage gap is an exception only when its owner, reason,
compensating review, target date, and return criteria are recorded. Verify
availability, region, quota, and feature scope before use.

![S7 illustrative assurance pattern: accepted S6 runtime evidence precedes an evaluation plan covering selected quality, safety, groundedness, tool-use, regression, and human-review dimensions. The customer-owned assurance decision remains continue or hold.](../assets/diagrams/s7-evaluation-release-handoff.svg)

## Decision 1: Evaluation approach & scorers

Choose against the checks that are universal versus project-gated, the coverage
population, who interprets the result, and whether a later reviewer can
reproduce the evidence.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Azure AI Foundry evaluators / agent evaluators** (verify current availability and scope) | The customer uses a supported Foundry project and needs repeatable quality, groundedness, safety, tool-use, or task checks | Some agent evaluators are preview and cannot be the sole production gate; scores still need bounded populations and human interpretation | Record evaluator version, scenario population, unsupported scope, interpretation owner, and threshold owner |
| **Manual annotation / customer scorers** | Domain judgment, policy nuance, or unsupported evaluator coverage is needed | Slower and harder to scale; consistency depends on reviewer calibration | Record rubric, reviewer role, sampling plan, adjudication path, and reproducibility limits |
| **Policy-scenario assertion suites** (verify current guidance/status) | Specific safety, refusal, tool-boundary, or regression scenarios need targeted pass/fail evidence | Scenario suites do not prove broad quality or runtime enforcement | Record scenario owner, expected behavior, version, regression route, and which checks remain outside scope |
| **Hybrid scorecard** | Release needs both automated repeatability and expert interpretation | More owners and evidence to reconcile | Record which checks are universal, which are project-gated, and who resolves conflicts |

For every selected dimension, record the candidate version, accepted S6 proof,
scenario population, evaluator or rubric version, coverage limit, threshold
owner, human-review path, and decision use. Resolve unsupported coverage and
threshold ownership before automation; assign adversarial-risk and production
sampling or drift work to their accountable customer owners.

## Decision 2: Release-gate mechanism & CI/CD integration

Choose against automation maturity, release cadence, threshold ownership, and
whether the gate leaves an auditable customer-owned record.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Manual assurance sign-off** (S7 handoff) | The organization needs a controlled release decision before automation is ready | Slower; depends on named reviewers and disciplined records | Record accepted S6 proof, evaluation-plan reference, decision owner, outcome, next action, and review date |
| **Cloud evaluation run in CI/CD** (verify Foundry SDK/cloud-evaluation status) | Evaluation suites are versioned and the release process can consume results consistently | Requires engineering ownership, secrets/identity design, failure handling, and threshold governance | Record pipeline owner, evaluator suite version, threshold owner, audit trail, and rollback route |
| **Continuous evaluation on production sampling** (verify feature and telemetry status) | The customer has production traces and wants drift or regression signals after release | Production samples are not controlled experiments; sampling and retention limit claims | Record sampling population, retention, interpretation owner, escalation path, and S11 handoff |
| **Manual gate plus automation backlog** | Evidence is useful now but automation is not yet trusted enough to block release | Creates transition work that can stall without ownership | Record manual decision now and backlog the CI/CD or continuous-evaluation owner and adoption trigger |

## Decision 3: Performance & latency evidence path

Choose against streaming user experience, SLO ownership, environment fidelity,
and the evidence needed for TTFT/TTFB, end-to-end p95, throughput, and
saturation. Defer metric detail to the performance-testing guide.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Synthetic pre-production load** (for example Azure Load Testing; verify status, region, quota, and pricing) | A bounded interaction needs controlled first-token, end-to-end, throughput, and error evidence before release | Test environment fidelity, quota/PTU ceilings, and stubbed tools limit transfer to production | Record workload model, targets, environment-fidelity limits, run owner, and release-decision use |
| **Production telemetry** (OpenTelemetry, Application Insights, or Foundry traces; verify configuration and availability) | Real traffic measurement is available for drift review | Sampling, retention, and instrumentation gaps limit attribution; not a pre-release controlled test | Record trace source, population, retention, SLO owner, drift route, and operating-review owner |
| **Synthetic baseline plus production reconciliation** | Streaming or high-volume interactions need both controlled evidence and real-traffic follow-up | Most coordination and evidence management | Record the synthetic baseline, production counterpart, owner split, and drift-investigation route |
| **Performance deferred with explicit gap** | Performance is not material to the current bounded release, or evidence is unavailable | Leaves latency and capacity risk unresolved | Record why it is deferred, the owner, trigger, and what release decision the gap can still support |

## Decisions made & adoption progress

S7 records a lasting release-assurance decision and evidence reference. The
customer assigns any production counterpart to its operating owner.

| Adoption stage | What "done" looks like at S7 |
|---|---|
| **Decided** | The evaluation approach, release-gate mechanism, and performance-evidence path are chosen or explicitly deferred with rationale |
| **Backlogged** | Evaluator/scorer work, CI/CD or continuous-evaluation adoption, performance testing, and production reconciliation have owners |
| **In adoption** | Customer engineering or release teams implement the selected path outside this kit and retain evidence in the approved records system |

Capture the choice, alternatives, verified-status caveats, and adoption stage in
`labs/s7-evaluation/templates/technical-decision-record.template.md`.

## Related references

- [S7 Concepts](concepts.md): evaluation boundaries, threshold ownership, performance assurance, and release-sign-off limits.
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md).
- [Performance-testing guide](../reference/performance-testing-guide.md).
