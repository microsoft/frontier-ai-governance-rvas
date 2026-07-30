# S11 · LLMOps Change Control

!!! info "Freshness"
    Last reviewed: 2026-07-30. Verify current Microsoft Foundry, Azure DevOps/GitHub pipeline, Azure Monitor, Application Insights, regional availability, quota, pricing, and customer requirements before delivery.

<span class="rvas-badge rvas-persona">LLMOps owner</span> <span class="rvas-badge rvas-persona">AI developer</span> <span class="rvas-badge rvas-persona">Service owner</span>

!!! abstract "What is at stake"
    Models and prompts change continuously; the customer needs ownership,
    evidence, and rollback routes that keep pace with those changes.

## 1. Inspect one Foundry and pipeline change

Inspect one actual candidate change against the current baseline before it moves
to the customer's next process. Use safe references only and do not move
production traffic.

**Plain decision question:** Is this prompt/instruction, retrieval, tool, data,
evaluation, deployment-alias, fallback, feedback, or automation change ready for
a **separate customer change review**, or must it be deferred, rejected, routed,
or blocked?

Work through these concrete checks:

- Open the Microsoft Foundry project. Inspect the workload assets: app/agent,
  prompt or instruction version, retrieval reference, tool schema reference,
  model deployment alias, dataset/scenario, evaluation run, traces/monitoring
  link, and owner.
- Open the customer source and pipeline system. Inspect the branch/commit or
  release reference, pipeline run, generated release manifest, build/test/eval
  gates, skipped or failed steps, manual approvals, and target environment.
- Compare the baseline release reference and candidate release reference. Verify
  prompt/instruction version, model deployment/alias, dataset/scenario,
  evaluation run, rollout stage, rollback target, fallback route, monitoring
  signal, and approver/change reference.
- Open the rollout stage. Check entry conditions, stop condition, switch
  authority, excluded population, fallback trigger, rollback target, and recheck
  condition.
- Open the feedback source. Check approval, privacy/retention route, curation
  owner, sampling/quality rule, and mutation gate before feedback can shape a
  new candidate.
- Check automation readiness for regression, canary, alias switching, fallback
  routing, feedback curation, and retirement. If prerequisites are missing,
  leave the step manual and assign the fix.
- Classify expected signals: manifest complete, evaluation missing, alias
  mismatch, rollback target missing, feedback source not approved, automation
  not ready, or ready for separate change review.

`labs/s11-llm-operations/` contains offline templates for the customer-approved
records system. They retain approved references only, not raw prompts, model
outputs, datasets, telemetry, identifiers, credentials, live configuration, or
production evidence.

### What happens next

Engineering, platform, data, evaluation, operations, release, and service teams
implement the accepted work through customer-controlled source, data, IaC,
change, and operational processes. S11 prepares a lifecycle handoff; it does
not select a model, move traffic, switch aliases, activate fallback, retire a
deployment, configure resources, enable automation, or authorize production.

## 2. Prerequisites

- One bounded LLMOps change: model, prompt, retrieval configuration, tool/API
  schema, dataset/scenario, evaluation rubric, deployment alias, fallback route,
  feedback queue, or automation candidate.
- Named data, experiment, engineering, evaluation, platform/change, operations,
  LLMOps, governance, and evidence owners.
- Approved customer records location and customer source, data, change,
  incident, evidence, and retention processes.
- Available evidence-reference routes for data/privacy, implementation,
  evaluation baseline, runtime controls, operating signals, and change review,
  even when evidence is incomplete.

The session can start with gaps. Unknown version owner, stage owner,
evaluation baseline, switch authority, fallback route, rollback target,
monitoring signal, feedback governance, or approved record location defers or
blocks the affected decision.

## 3. Keep change control connected to operations

LLMOps fails when model, prompt, retrieval, data, and tool changes move faster
than the release evidence around them. A model endpoint response is not an
operating lifecycle. A dashboard is not a feedback loop. A deployment alias is
not safe simply because it has a friendly name.

S11 makes the lifecycle concrete. The team traces one change through the inner
loop, pins the versions that define the candidate, connects them to
evaluation and operating references, and decides what must be true before the
outer loop can promote, hold, roll back, fall back, retire, or automate that
path. The result is a practical inspection record that the customer's release,
platform, service, and governance owners can act on.

The most important rule is that feedback is a candidate input. Production
signals, user feedback, incident notes, or cost observations may create a
hypothesis, a curated dataset candidate, or a new evaluation scenario. They do
not directly mutate production prompts, retrieval sources, model aliases, or
tool behavior without gate review.

Use [Technical decisions](technical.md) for the Foundry and pipeline inspection
workflow, baseline/candidate comparison, rollout checks, feedback gate, and
record shapes.

## 4. Change boundary

S11 makes no data, model, prompt, evaluation, deployment, infrastructure,
telemetry, incident, traffic, fallback, retirement, automation, or production
change. It identifies safe references, owners, limits, stop conditions, evidence
expectations, and the next customer-controlled process.
