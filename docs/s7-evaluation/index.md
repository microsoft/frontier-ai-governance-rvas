# S7 · Evaluation Evidence & Release Readiness

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

!!! abstract "What is at stake"
    Release and change decisions need agreed evidence, thresholds, and owners;
    confidence in a demo is not enough.

## 1. Test a candidate change

Test whether one bounded candidate change can continue toward the next release
process. Base the decision on accepted runtime-path evidence, a versioned
scenario set, a suitable evaluator or rubric, baseline comparison, customer-owned
thresholds, gate behavior, performance or cost evidence where relevant, and a
named release/hold owner.

Work through these checks:

- An **evaluation candidate card** for the workload, capability, change type,
  release question, owners, environment, lifecycle state, and approved records
  location.
- A **runtime-prerequisite statement** that either references accepted
  runtime-path evidence or marks the work diagnostic-only.
- A **scenario-set package** with source, owner, population, sampling method,
  included and excluded slices, data/tool boundary, reviewer role, time window,
  and material-change triggers.
- An **evaluator/rubric package** covering Microsoft Foundry evaluations, agent
  evaluators, manual rubric/scorer review, CI/CD cloud evaluation, load testing,
  or diagnostic-only status.
- A **baseline, threshold, and exception model** with comparison rule, selected
  metrics, regression tolerance, threshold owner, exception owner, and
  re-evaluation criterion.
- A **finding-to-action map** that turns results into release blocker, accepted
  exception, diagnostic-only observation, operating hypothesis, or backlog item.
- A **release-readiness handoff** that says `continue`, `hold`, `defer`,
  `reject`, `route`, `block`, or `diagnostic-only`, names the owner, and sets
  the next action.

`labs/s7-evaluation/` holds the single-file work package and required
decision-record template. Shared helpers, when needed, live under
`labs/helpers/`. The kit does **not** hold live evaluators, prompt data, model
outputs, scores, datasets, CI/CD gates, telemetry, customer records, or release
approvals.

### What happens next

**Next customer action:** give the completed evaluation evidence package and
backlog to the named evaluation, engineering, release/change, performance, or
rollback owner before any release decision progresses.

### Plain decision and default path

**Decision question:** *Can this specific change continue toward the next
customer release process, or must it hold because the scenario set, evaluator,
baseline, threshold, runtime prerequisite, performance evidence, rollback route,
or release owner is not ready?*

The default is Microsoft Foundry evaluations or agent evaluators where their
current support, region, and scope fit, paired with customer-owned human
interpretation and accepted runtime-path evidence. Use manual scoring, policy
scenarios, CI/CD cloud evaluation, load testing, another approved test service,
or an explicit diagnostic-only gap when Foundry support, evaluator fit, data
handling, automation readiness, performance needs, or coverage does not fit.

S7 prepares the release-readiness review. It does not approve production, change a
pipeline, configure Foundry, set thresholds for the customer, run load tests, or
claim runtime enforcement.

## 2. Prerequisites

- A bounded candidate change: model, prompt/instruction, retrieval source,
  tool/API, policy/control, orchestration, deployment alias, or release package.
- A named evaluation owner, model/agent owner, scenario owner, threshold owner,
  evidence owner, and release/hold owner.
- An approved customer records system for safe references.
- Accepted runtime-path evidence when the evaluation will be used for release
  reliance. If that condition is missing, scope the work as diagnostic-only.
- A customer-owned evaluation-plan reference, usually for Microsoft Foundry
  evaluations or agent evaluators after current availability and scope are
  verified.

## 3. Make release decisions on evidence

A score is not a decision. A release-readiness package needs to say which
scenario set was tested, what changed, what baseline it was compared with, who
owns the threshold, which unsupported slices remain, what happens on failure,
and who can continue or hold the change.

Foundry evaluations and agent evaluators can help the customer test quality,
safety, groundedness, tool use, task adherence, and regression where current
availability and scope are verified. They inform the decision. They do not
replace accepted runtime-path evidence or the customer's release process.

Use [Technical decisions](technical.md) for evaluator routes, diagnostic-only
boundaries, threshold ownership, and release-readiness evidence.

## 4. Rollback and handoff

S7 changes no evaluator, agent, model deployment, data source, CI/CD gate,
threshold, or release policy. The customer can defer or replace its
decision through its own change and evidence process. Handoff names the
scenario, evaluator, threshold, rollback/remediation owner, release/hold owner,
evidence references, review cadence, and material-change triggers. The completed
handoff remains customer owned.
