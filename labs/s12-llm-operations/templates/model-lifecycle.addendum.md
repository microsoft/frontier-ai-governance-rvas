# S12 Model Lifecycle Addendum

Use this addendum with the shared [`../../templates/decision-record.template.md`](../../templates/decision-record.template.md). Copy both into the customer's approved records system when the LLMOps decision needs model-version, rollout, fallback, or retirement detail.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, or tenant changes in this repository.

## Model lifecycle decision

Use safe references only. Record enough ownership and evidence to let the team later automate model testing, rollout, switching, fallback, and retirement.

| Model lifecycle field | Record |
|---|---|
| Approved baseline model / deployment alias | |
| Candidate model versions under test | |
| Fallback model / route | |
| Deprecated or retired model versions | |
| Evaluation, safety, cost, latency, capacity, and support evidence required before rollout | |
| Authority to approve testing | |
| Authority to promote or switch traffic | |
| Canary / phased rollout criteria | |
| Rollback trigger and rollback target | |
| Retirement trigger and removal owner | |
| Automation backlog for testing, rollout, alias switching, fallback, or retirement | |

## Model lifecycle review questions

- Which approved baseline model or deployment alias is in scope?
- Which candidate model versions are under test, and which evidence must exist before rollout?
- Which fallback model or route can receive traffic if the candidate fails?
- Which versions are deprecated or retired, and who owns removal?
- Who can approve testing, canary rollout, alias switching, fallback routing, rollback, and retirement?
- What must be true before testing, rollout, alias switching, fallback, or retirement can be automated?

## Safe filled examples

| Field | Safe example |
|---|---|
| Feedback-to-curation work item | "Connect feedback queue to curated dataset review" |
| Feedback evidence location | "Customer-approved feedback queue and S2 data-curation record references" |
| Feedback accepted when | "No production observation mutates prompts or data without gate review" |
| Model rollout work item | "Prepare model-version rollout automation" |
| Model rollout evidence location | "Customer-approved evaluation run, release manifest, and gateway alias record references" |
| Model rollout accepted when | "Candidate model has pass/fail thresholds, switch authority, canary criteria, fallback target, and rollback trigger recorded" |
