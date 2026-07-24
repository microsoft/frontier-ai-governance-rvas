# S12 Runbook: LLMOps lifecycle decision

Use this runbook with the [S12 activity guide](../../docs/s12-llm-operations/index.md).
The customer decides the lifecycle operating model and implementation handoff;
the facilitator protects the boundary.

> **Boundary:** define stages, controls, owners, evidence, and backlog only. Do
> not ingest data, alter prompts/models, run experiments/evaluations, deploy,
> configure services, query live data, execute an incident, or approve
> production.

## Entry condition

Bring one bounded LLM application/service, named data, experiment, evaluation,
platform, service, governance, and evidence owners, plus an approved records
location. Unknown ownership or route is a blocker to record, not an assumption
to resolve in the workshop.

## 1. Map the inner loop

1. Copy `templates/model-prompt-operations-register.template.md`.
2. For **data curation**, record the intended use, approved source/provenance
   reference, transformation, owner, limitation, and S2 handoff.
3. For **experimentation**, record the hypothesis, candidate/release reference,
   population, owner, and the decision the result can inform.
4. For **evaluation**, record the scenario/dataset, scorer or rubric, coverage,
   threshold owner, and S7 route.

Ask: **"What turns this data into a reproducible candidate, and what proves the
candidate is worth promoting?"**

## 2. Map deployment and inference

Record DEV -> PRE -> PRO purpose, promotion authority, and environment limits.
For one PRE candidate, complete the release-manifest references to the candidate
artifact, evaluation evidence, service release, deployment/inference route,
change decision, and rollback target.

Ask: **"Can a reviewer reconstruct the active route and undo it through the
approved change process?"** If not, defer the affected promotion claim.

## 3. Map monitoring and feedback

Copy `templates/incident-rollback-retirement-plan.template.md`. For monitoring,
record the signal, population/retention limit, interpretation owner, escalation
route, and S11 handoff. For feedback, record purpose, privacy/consent and
retention route, quality/curation rule, and the S2 route before reuse.

Ask: **"How does a production observation become a governed improvement rather
than an automatic production mutation?"**

## 4. Apply stage gates to change

Copy `templates/operating-model-material-change-decision.template.md`. Classify
at least one feedback/data change, one candidate behavior change, and one
production-operation change. Route each according to the template; do not
substitute a pull request, dashboard, or version number for a decision.

## 5. Decide and hand over

The governance decision owner records one outcome:

- **Approve:** every stage has an owner, evidence, exit gate, and accepted
  handoff.
- **Defer:** a control, record, owner, or route is missing; name the blocker,
  target date, and decision limit.
- **Reject:** the lifecycle cannot support the stated application scope.

For each gap, assign an implementation owner and completion evidence. Record
limitations, explicit exclusions, and the next lifecycle review. S12 approval
is never authorization to make a production change.
