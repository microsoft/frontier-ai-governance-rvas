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

They leave with:

- an LLMOps lifecycle canvas covering data curation, experimentation,
  evaluation, validate/deploy, inference, monitoring, and feedback/data
  collection;
- a named owner, evidence reference, input, output, and decision gate for each
  stage;
- a safe-reference release manifest for a bounded PRE or PRO candidate;
- material-change routes that prevent feedback, experiments, and production
  changes from bypassing the required S2, S4, S7, S11, platform, or customer
  change decisions; and
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
- Available S2, S4, S7, and S11 handoff routes, even if evidence is incomplete.

The session can start with gaps, but unknown ownership, data purpose, evaluation
route, promotion authority, monitoring route, or feedback governance defers the
affected decision.

## 3. Why this session matters

An LLM application is not complete when a model endpoint responds. Teams need a
repeatable way to curate data, learn through experiments, evaluate candidates,
promote deliberately, operate inference, observe outcomes, and turn governed
feedback into the next iteration. Without that loop, production changes are
untraceable and monitoring produces observations without improvement.

Read [S12 Concepts](concepts.md) for the inner/outer loops and [Technical
decisions](technical.md) for the Azure implementation mapping, lifecycle gates,
and acceptance evidence.

## 4. Detailed facilitation reference

!!! warning "Design the operating system; do not operate it here"
    The group may define controls, gates, owners, evidence, and a backlog. Do
    not ingest data, select or alter a model, change prompts, run evaluation,
    deploy infrastructure, query production telemetry, or approve production.

| Activity | Time | Customer action | Facilitator decision test |
|---|---:|---|---|
| Map the inner loop | 20 min | Identify curation, experiment, and evaluation inputs, owners, records, and exit gates. | What turns a learning idea into an evaluable candidate? |
| Map validate/deploy and inference | 15 min | Define DEV/PRE/PRO promotion, release manifest, inference dependencies, and rollback route. | What evidence supports promotion, and can the active route be reconstructed? |
| Map monitoring and feedback | 15 min | Select signals, interpretation/response owners, feedback purpose, and curation route. | What turns a signal into a hypothesis and feedback into governed data? |
| Apply material changes | 15 min | Classify one data/feedback change, one candidate change, and one production-operation change. | Which accountable route must approve each change? |
| Plan implementation | 15 min | Assign work, acceptance evidence, blockers, and review cadence. | What proves every stage is operational rather than aspirational? |
| Decide | 10 min | Approve, defer, or reject the lifecycle model with limits. | Can learning safely travel from production back to the inner loop? |

### Handoff boundaries

- **S2:** data governance, privacy, retention, and compliance.
- **S4:** initial implementation-path and model selection/admission.
- **S7:** candidate evaluation and release assurance.
- **S11:** production monitoring, incident operation, capacity, and FinOps.
- **S12:** lifecycle orchestration, stage gates, artifact ownership, and the
  governed feedback-to-curation loop.

## 5. Verification & evidence capture

- [ ] All seven LLMOps stages have a purpose, owner, approved record, and
  decision/exit condition.
- [ ] Data and feedback only enter curation through an owned S2-governed route.
- [ ] Candidates are reproducible and cannot bypass evaluation or promotion.
- [ ] The active PRE/PRO route is reconstructable from a release manifest and
  has a rollback target.
- [ ] Monitoring signals have coverage limits, an interpretation owner, and an
  S11 escalation route.
- [ ] The customer decision, backlog, limitations, and next lifecycle review are
  recorded.

## 6. Change boundary

S12 makes no data, model, prompt, evaluation, deployment, infrastructure,
telemetry, incident, or production change. Customer data, engineering, release,
platform, and service-management processes own execution.
