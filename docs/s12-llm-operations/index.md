# S12 · LLMOps

!!! info "Freshness"
    Last reviewed: 2026-07-24. Verify current Azure service capabilities,
    regional availability, quota, pricing, and customer requirements before
    delivery.

<span class="rvas-badge rvas-persona">LLMOps owner</span> <span class="rvas-badge rvas-persona">AI developer</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & what the customer keeps

The customer answers one operating question:
**is there a controlled path from data and experimentation to production,
monitoring, feedback, and the next improvement cycle?**

**Plain decision question:** Does this bounded workload have a controlled LLMOps
inner and outer loop? Record **approve, defer, reject, or route**. Default to
protected source and customer change control, Microsoft Foundry
evaluation/observability where supported, and Azure Monitor/Application Insights
for operations. An exception needs a verified service, owner, coverage limit,
acceptance evidence, and target date.

They leave with:

- an LLMOps lifecycle canvas covering data curation, experimentation,
  evaluation, validate/deploy, inference, monitoring, and feedback/data
  collection;
- a named owner, Microsoft record location, input, output, and decision gate for each
  stage;
- a model lifecycle decision for approved, candidate, fallback, deprecated, and
  retired model versions, including who can approve model switching and what
  evidence is required before rollout;
- a safe-reference release manifest for a bounded PRE or PRO candidate;
- material-change routes that prevent feedback, experiments, and production
  changes from bypassing the required data, agent-engineering, evaluation,
  operating, platform, or customer change decisions; and
- an approve, defer, or reject decision with a practical implementation backlog.

`labs/s12-llm-operations/` contains offline templates and a runbook. They retain
approved references only, not raw prompts, model outputs, customer data,
credentials, live configuration, or production telemetry.

### What happens next

Engineering, platform, data, release, and service teams implement the accepted
work through customer-controlled source, data, IaC, change, and operational
processes. S12 defines the end-to-end LLMOps workflow; it does not configure
resources or authorize production.

## 2. Prerequisites

- One bounded LLM application or service and its intended user/workload scope.
- Named data, experiment, evaluation, platform, service, governance, and
  evidence owners.
- An approved records location and customer data/change/incident processes.
- Available data, agent-engineering, evaluation, and operating handoff routes,
  even if evidence is incomplete.

The session can start with gaps, but unknown ownership, data purpose, evaluation
route, promotion authority, monitoring route, or feedback governance defers the
affected decision.

## 3. Why this session matters

An LLM application is not complete when a model endpoint responds. Teams need a
repeatable way to curate data, learn through experiments, evaluate candidates,
promote deliberately, operate inference, observe outcomes, and turn governed
feedback into the next iteration. Without that loop, production changes are
untraceable and monitoring produces observations without improvement.

This session also makes model lifecycle choices explicit. The customer should
understand which model versions are in use, which versions are candidates or
fallbacks, which are deprecated or retired, and who decides when to test, roll
out, roll back, or switch between them. Capturing those decisions now lets the
team later automate regression testing, canary rollout, model alias changes,
fallback routing, and retirement without re-opening basic ownership questions.

Read [S12 Concepts](concepts.md) for the inner/outer loops and [Technical
decisions](technical.md) for the Azure implementation mapping, lifecycle gates,
and acceptance evidence.

## 4. Change boundary

S12 makes no data, model, prompt, evaluation, deployment, infrastructure,
telemetry, incident, or production change. Customer data, engineering, release,
platform, and service-management processes own execution.
