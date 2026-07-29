# S12 · LLMOps Change Control

!!! info "Freshness"
    Last reviewed: 2026-07-24. Verify current Azure service capabilities,
    regional availability, quota, pricing, and customer requirements before
    delivery.

<span class="rvas-badge rvas-persona">LLMOps owner</span> <span class="rvas-badge rvas-persona">AI developer</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & what the customer keeps

The customer answers one practical operating question:
**can this bounded LLMOps change move to the next customer process with safe
artifact references, known lifecycle owners, accepted evidence references,
switch authority, rollback/fallback criteria, feedback governance, and
automation prerequisites?**

**Plain decision question:** Is this model, prompt, retrieval, tool, data,
evaluation, deployment-alias, fallback, or feedback change ready for the next
customer-controlled lifecycle step? Record **ready for next process, defer,
reject, route, or block**. Default to Microsoft Learn's LLMOps inner and outer
loop, Microsoft Foundry evaluation/observability where supported, customer
source/change processes, Azure Monitor/Application Insights for operating
signals, and safe references only.

They leave with:

- an **LLMOps change card** for one bounded change, environment, affected
  artifacts, lifecycle question, owners, target process, and approved records
  location;
- a seven-stage lifecycle package covering data curation, experimentation,
  evaluation, validate/deploy, inference, monitoring, and feedback/data
  collection, with owners, inputs, outputs, blockers, accepted-when conditions,
  and receiving handoffs;
- a release manifest that joins prompt/instruction, retrieval, tool schema,
  model/deployment alias, evaluation, runtime-control, telemetry, rollback,
  and approver references without copying raw artifacts;
- artifact version contracts for prompts, models, datasets, rubrics, retrieval
  configuration, tool schemas, deployment aliases, feedback queues, and rollout
  plans;
- a model/deployment lifecycle decision for approved baseline, candidate,
  fallback, deprecated, and retired states, including testing, canary, traffic
  switch, fallback, rollback, retirement, and automation authority;
- a rollout/fallback/rollback package with stage entry conditions, stop
  conditions, monitoring signals, rollback target, switch authority, and
  review trigger;
- a feedback-to-curation gate that turns operating signals into candidate
  learning inputs, not direct production mutations; and
- a backlog for missing ownership, evidence reference, stage gate, fallback,
  rollback, feedback, retirement, or automation prerequisites.

`labs/s12-llm-operations/` contains offline templates for the customer-approved
records system. They retain approved references only, not raw prompts, model
outputs, datasets, telemetry, identifiers, credentials, live configuration, or
production evidence.

### What happens next

Engineering, platform, data, evaluation, operations, release, and service teams
implement the accepted work through customer-controlled source, data, IaC,
change, and operational processes. S12 prepares a lifecycle handoff; it does
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

The session can start with gaps. Unknown artifact ownership, stage owner,
evaluation baseline, switch authority, fallback route, rollback target,
monitoring signal, feedback governance, or approved record location defers or
blocks the affected decision.

## 3. Why this session matters

LLMOps fails when model, prompt, retrieval, data, and tool changes move faster
than the release evidence around them. A model endpoint response is not an
operating lifecycle. A dashboard is not a feedback loop. A deployment alias is
not safe simply because it has a friendly name.

S12 makes the lifecycle concrete. The team traces one change through the inner
loop, records the artifact versions that define the candidate, connects them to
evaluation and operating references, and decides what must be true before the
outer loop can promote, hold, roll back, fall back, retire, or automate that
path. The result is a practical change control package that the customer's
release, platform, service, and governance owners can act on.

The most important rule is that feedback is a candidate input. Production
signals, user feedback, incident notes, or cost observations may create a
hypothesis, a curated dataset candidate, or a new evaluation scenario. They do
not directly mutate production prompts, retrieval sources, model aliases, or
tool behavior without gate review.

Read [S12 Concepts](concepts.md) for the inner/outer loop and artifact-control
model, [Technical decisions](technical.md) for the Azure implementation mapping
and record shapes, and [Practical workshop](practical.md) for the facilitation
sequence.

## 4. Change boundary

S12 makes no data, model, prompt, evaluation, deployment, infrastructure,
telemetry, incident, traffic, fallback, retirement, automation, or production
change. It records safe references, owners, limits, stop conditions, evidence
expectations, and the next customer-controlled process.
