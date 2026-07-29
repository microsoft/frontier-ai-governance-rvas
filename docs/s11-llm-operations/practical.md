# Practical workshop: LLMOps change control package

**Microsoft default:** Microsoft Learn LLMOps inner/outer-loop lifecycle: data
curation, experimentation, evaluation, validate/deploy, inference, monitor, and
feedback/data collection.

**Customer decision:** Decide whether one bounded LLMOps change is ready for the
next customer process, or whether it must be deferred, rejected, routed, or
blocked. This is a lifecycle-readiness and handoff decision only; it is not
automatic release approval.

## Work the package

1. **Choose the change and target process.** Select one prompt, retrieval,
   tool/API, model, fine-tuning, dataset, evaluation, deployment alias,
   fallback, feedback, retirement, or automation change. Name the environment,
   target customer process, decision owner, artifact owners, and approved
   records location.
2. **Build the LLMOps change card.** Record affected artifacts, safe references,
   lifecycle question, intended stage, evidence limits, stop condition, and
   owners.
3. **Walk the seven lifecycle stages.** Record the input reference, output
   reference, owner, accepted-when condition, blocker, material-change trigger,
   and receiving handoff for each stage.

| Stage | Inspect | Practical decision cue |
|---|---|---|
| Data curation | data source, feedback queue, transformation, quality, privacy, retention, curation output | Defer when the data/privacy owner, purpose, retention route, quality rule, or approved curation reference is missing. |
| Experimentation | candidate prompt/retrieval/model/tool/code reference, hypothesis, lineage, population, cost/capacity assumption | Defer when the candidate cannot be reconstructed or no experiment owner accepts the hypothesis and limits. |
| Evaluation | scenario set, evaluator/rubric version, baseline, candidate result, threshold owner, unsupported slices | Mark diagnostic-only or defer when baseline, threshold, reviewer, or interpretation owner is missing. |
| Validate/deploy | release manifest, environment, alias target, change authority, excluded population, rollback target | Do not treat this package as deployment approval; record the separate customer process that may promote or hold the change. |
| Inference | model/deployment route, gateway/API boundary, identity, quota/capacity, fallback trigger, support owner | Defer when switch authority, fallback, capacity, or support path is unowned. |
| Monitor | signal source, population, query owner, retention, alert route, stop/fallback/rollback signal | Defer when the operating signal cannot support a stop, fallback, rollback, or review decision. |
| Feedback/data collection | feedback source, hypothesis, privacy route, curation rule, candidate artifact, mutation gate | Block when feedback can mutate production data, prompts, retrieval, model aliases, or tools without gate review. |

4. **Build the release manifest.** Join safe references for prompt,
   retrieval, tool schema, model/deployment alias, evaluation, runtime control,
   operating signal, rollout stage, stop condition, rollback target, and change
   authority.
5. **Record artifact version contracts.** For each affected prompt, model,
   dataset, rubric, retrieval config, tool schema, alias, feedback queue, or
   rollout plan, record owner, version/provenance, intended use, review trigger,
   and retirement route.
6. **Record model/deployment lifecycle state.** Name the approved baseline,
   candidate, fallback, deprecated, retired, or blocked state. Capture testing,
   canary, traffic switch, fallback, rollback, retirement, and automation
   authority.
7. **Define rollout, fallback, and rollback.** Record stage plan, entry
   conditions, traffic population, excluded users, monitoring signals, stop
   conditions, fallback trigger, rollback target, review date, and switch
   authority.
8. **Gate feedback-to-curation.** Confirm that operating signals and user
   feedback become hypotheses and curated candidate inputs, not direct
   production mutations.
9. **Check automation readiness.** Before automating testing, canary rollout,
   alias switching, fallback routing, feedback-to-curation, or retirement,
   require evidence references, owner, trigger, stop condition, validation
   reference, manual override, and exception path.
10. **Record the outcome.** Mark ready for next process, defer, reject, route,
    or block with owner, acceptance test, target date, evidence location, and
    review trigger.

## Scenario prompts

| Scenario | Probe | Likely decision pressure |
|---|---|---|
| Prompt change | Can the team name prompt version, rationale, baseline comparison, rollback target, and release manifest entry? | Defer if the prompt is not versioned or rollback is unclear. |
| Retrieval config change | Are source list, permission boundary, filter/ranking, refresh cadence, data owner, and evaluation route recorded? | Block if retrieval changes bypass data/privacy review. |
| Tool schema change | Does the schema/version, operation boundary, consumer owner, gateway/API route, and evaluation impact exist? | Route to tool/API owner if permission or response contract changes are unclear. |
| Evaluation dataset or rubric change | Who owns the new threshold, unsupported slices, and comparison impact? | Defer if score changes cannot be compared to baseline. |
| Candidate model rollout | Are baseline, candidate, fallback, capacity, cost, support, evaluation, and stop conditions recorded? | Defer if fallback or switch authority is missing. |
| Deployment alias switch | Who can move the alias, which population is affected, and what rollback target is valid? | Block if alias authority or rollback target is unknown. |
| Fine-tuning candidate | Is data provenance, privacy route, experiment lineage, cost/capacity, evaluation, and support boundary recorded? | Route to data/privacy and model owner before release readiness. |
| Feedback reuse | Does feedback have purpose, retention, consent/privacy route, curation owner, and mutation gate? | Block direct production mutation. |
| Canary without stop condition | What signal halts expansion and who acts? | Defer until stop/fallback/rollback route is owned. |
| Deprecated model retirement | Which dependencies, rollback paths, retained records, and removal owner exist? | Defer if hidden consumers or rollback dependency are unreviewed. |
| Automation readiness blocker | Which manual evidence must exist before automation is enabled? | Keep manual until trigger, stop condition, validation, and override are explicit. |

## Decision record

Fill this record in the customer-approved records system. Store only safe
references here; completed customer evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Bounded LLMOps change control package |
| Change card | Workload, change type, lifecycle question, environment, target process, affected artifacts, owners, approved records location, evidence limits, stop condition |
| Seven-stage lifecycle | Data curation, experimentation, evaluation, validate/deploy, inference, monitor, feedback/data collection stage records |
| Release manifest | Release reference, prompt/instruction, retrieval config, tool schema, model aliases, evaluation, runtime-control, telemetry, rollout stage, stop condition, rollback target, approver |
| Version contracts | Prompt, model, dataset/scenario, rubric, retrieval config, tool schema, deployment alias, feedback queue, rollout plan |
| Model/deployment lifecycle | Baseline, candidate, fallback, deprecated, retired, or blocked state; owner; authority; support/capacity/cost; retirement route |
| Rollout/fallback/rollback | Stage plan, entry conditions, population, switch authority, monitoring signal, stop condition, fallback trigger, rollback target, review date |
| Feedback-to-curation | Signal source, hypothesis, privacy route, curation rule, candidate artifact, evaluation route, mutation gate |
| Automation readiness | Test, canary, alias switch, fallback, feedback, and retirement prerequisites with manual override and exception path |
| Exceptions | Residual risk, owner, expiry, evidence reference, review trigger |
| Decision | Ready for next process, defer, reject, route, or block |
| Accepted when | Owners, safe references, evidence limits, stop conditions, rollback/fallback, feedback gate, automation prerequisites, backlog, and handoff are complete |

## Acceptance checks

| Check | Accepted when... | Receiving owner |
|---|---|---|
| Change card | scope, target process, artifacts, owners, records location, evidence limits, and stop condition are recorded | LLMOps owner |
| Seven-stage lifecycle | each stage has input, output, owner, accepted-when condition, blocker, and receiving handoff | LLMOps/service owner |
| Release manifest | artifact references and rollback target can reconstruct the candidate without copying raw artifacts | Platform/change owner |
| Version contracts | affected artifacts have owner, version/provenance, reapproval trigger, and retirement route | Artifact owners |
| Model lifecycle | baseline, candidate, fallback, deprecated/retired or blocked states have authority and evidence requirements | Model/platform owner |
| Rollout/fallback/rollback | stage plan, switch authority, monitoring signal, stop condition, fallback trigger, rollback target, and review date are recorded | Platform/change and operations owners |
| Feedback gate | feedback becomes a governed candidate input with privacy route, curation rule, evaluation route, and mutation gate | Data/privacy and LLMOps owners |
| Automation readiness | trigger, prerequisite evidence, owner, stop condition, validation reference, manual override, and exception path are named | LLMOps/platform owner |
| Workshop safety | no raw customer evidence is copied, no tenant/live-policy change is made, and no deployment, alias switch, automation, runtime-proof, or production-approval claim is made | Facilitator |

## Decision tree

- **Ready for next process** when the lifecycle package fits the bounded change,
  safe references and owners are complete, evidence limits are understood, and
  the receiving customer process accepts the handoff.
- **Defer** when a gap has a named owner, target date, acceptance test, evidence
  location, and next review trigger.
- **Reject** when the scoped change cannot meet the lifecycle control path or
  acceptance expectation safely.
- **Route** when a data/privacy, engineering, evaluation, platform/change,
  operations, legal/compliance, governance, release, portfolio, or accepted-risk
  owner must decide first.
- **Block** when missing approved records location, artifact owner, lineage,
  evidence reference, switch authority, fallback route, rollback target,
  feedback gate, or scope clarity prevents a safe decision.

For an exception, record: reason, affected lifecycle stage, unsupported or
unverified control, equivalent customer-owned control if one exists, owner,
evidence reference, expiry, acceptance test, target date, receiving owner, and
review trigger.

Future automation prompt: **What evidence must pass before this lifecycle step
can be automated, and who can stop or override it?**

**Boundary:** Keep customer data and evidence in customer-approved systems;
store references only. This workshop changes no tenant policy, moves no
traffic, switches no alias, enables no automation, proves no runtime
enforcement, and does not approve production.
