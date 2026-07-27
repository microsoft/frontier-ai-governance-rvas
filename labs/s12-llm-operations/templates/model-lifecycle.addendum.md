# S12 Model Lifecycle Addendum

Use this addendum with [`decision-record.template.md`](decision-record.template.md). Copy both into the customer's approved records system when the LLMOps decision needs model-version, rollout, fallback, rollback, retirement, or automation-readiness detail.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Model lifecycle decision

Use safe references only. Record enough ownership and evidence to let the team later automate model testing, rollout, switching, fallback, feedback-to-curation, and retirement. This addendum is not automatic release approval.

| Model lifecycle field | Record |
|---|---|
| Approved baseline model / deployment alias | |
| Baseline evidence reference and owner | |
| Candidate model or prompt versions under test | |
| Candidate lineage / experiment reference | |
| Fallback model / route | |
| Fallback activation criteria | |
| Deprecated model or prompt versions | |
| Retired model or prompt versions | |
| Evaluation, safety, cost, latency, capacity, and support evidence required before rollout | |
| Authority to approve testing | |
| Authority to approve canary or phased rollout | |
| Authority to promote or switch traffic | |
| Authority to activate fallback | |
| Authority to roll back | |
| Authority to retire or remove a version | |
| Canary / phased rollout criteria | |
| Rollback trigger and rollback target | |
| Monitoring signal used for fallback or rollback | |
| Retirement trigger and removal owner | |
| Feedback-to-curation gate and owner | |
| Automation prerequisites for testing, rollout, alias switching, fallback, feedback-to-curation, or retirement | |
| Exception owner and review trigger | |

## Seven-stage lifecycle trace

| Stage | Required reference before lifecycle handoff |
|---|---|
| Data curation | Source or feedback queue reference, data/privacy review owner, quality check, and curation handoff |
| Experiment | Candidate artifact, lineage, parameters or prompt-change reference, experiment owner, cost/capacity assumption |
| Evaluation | S7 record with scenario set, evaluator version, thresholds, baseline, exception owner, and limitations |
| Validate/deploy | Release manifest, deployment alias, canary criteria, customer change process, rollback target, release/hold owner |
| Inference | Inference route, gateway/API boundary, switch authority, fallback route, quota/cost/SLA owner |
| Monitor | Signal source, reviewer, cadence, alert route, fallback/rollback decision input, retention owner |
| Feedback/data collection | Feedback route, triage owner, data/privacy review, mutation gate, curation handoff |

## Model lifecycle review questions

- Which approved baseline model or deployment alias is in scope?
- Which candidate model or prompt versions are under test, and which evidence must exist before rollout?
- Which fallback model or route can receive traffic if the candidate fails?
- Which versions are deprecated or retired, and who owns removal?
- Who can approve testing, canary rollout, alias switching, fallback routing, rollback, and retirement?
- What monitoring signal and review cadence inform fallback or rollback?
- What must be true before testing, rollout, alias switching, fallback, feedback-to-curation, or retirement can be automated?
- What condition blocks this record from being used as release reliance?

## Safe filled examples

| Field | Safe example |
|---|---|
| Feedback-to-curation work item | "Connect feedback queue to curated dataset review" |
| Feedback evidence location | "Customer-approved feedback queue and S2 data-curation record references" |
| Feedback accepted when | "No production observation mutates prompts or data without gate review" |
| Model rollout work item | "Prepare model-version rollout automation" |
| Model rollout evidence location | "Customer-approved evaluation run, release manifest, deployment alias, monitor signal, and fallback route references" |
| Model rollout accepted when | "Candidate model has baseline comparison, pass/fail thresholds, switch authority, canary criteria, fallback target, rollback trigger, retirement owner, and automation prerequisites recorded" |
| Retirement work item | "Retire superseded deployment alias" |
| Retirement accepted when | "Fallback is available, dependencies are reviewed, removal owner and date are recorded, and rollback target remains documented until the customer process closes" |
