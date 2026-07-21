# S7 Runbook: Assurance Handoff

S7 does not operate a live evaluation or gate. Its one action is a
customer-operated assurance review and decision handoff.

## Facilitated activity alignment

Run this sequence during the [S7 90-minute co-delivery workshop](../../docs/s7-evaluation/index.md#4-co-delivery-walkthrough).
Before step 1, the facilitator confirms a customer assurance owner, platform
and security reviewers/evidence owner, decision owner, approved record
location, and accepted S6 entry evidence. The customer performs the review and
chooses the outcome; the facilitator keeps the assurance boundary and records
the handoff.

1. Confirm the customer evidence system contains an S6 gateway-proof manifest
   conforming to `contracts/gateway-proof.schema.json`, with `result: "pass"`.
2. Confirm named customer platform and security reviewers have accepted that
   proof after correlating its `correlation_id` with gateway telemetry. A passed
   request without this acceptance is not an S7 entry condition.
3. The customer assurance owner copies
   `templates/technical-decision-record.template.md` into the approved customer
   records system to record the selected evaluation approach, release-gate
   mechanism, performance-evidence path, alternatives considered, and
   verified-status caveats. Then the owner copies
   `templates/evaluation-plan-review.template.md` into the approved customer
   records system to record evaluation coverage, limits, interpretation owners,
   and release-decision use. They also copy
   `templates/assurance-outcome.template.json` into their approved records
   system, records only references (not raw evidence), and selects `continue`
   or `hold`.
   Where quality thresholds are in scope, the assurance owner also copies
   `templates/quality-measurement-plan.template.md`, records customer-owned
   dimensions, evaluator options, coverage limitations, threshold governance,
   and baseline references, then validates the threshold decision against
   `contracts/quality-threshold-decision.schema.json`. Ask which evaluators are
   universal versus project-gated, who proposes and approves the threshold, and
   which population is not covered.
   Where synthetic performance or load testing is in scope, the owner also
   copies `templates/performance-test-plan.template.md` to record the workload
   model, first-token / end-to-end / throughput / error-saturation targets, and
   environment-fidelity limits (quota/PTU, stubs versus live, data parity). The
   load engine (for example Azure Load Testing, after current service status,
   region, quota, and pricing are verified) is customer-run and referenced, not
   operated by this kit; production reconciliation of any drift hands off to S11.
4. Validate the completed record against
   `contracts/assurance-handoff.schema.json`. The assurance exit is complete
   only when the S6 decision is `accepted` and the customer has recorded the
   outcome and decision reference.

Customer teams may run Foundry Evaluations or introduce a CI gate separately in
their own approved delivery process after current status, availability, and
scope are verified. Those results do not replace the accepted S6 gateway proof
and are not produced by this kit. Use the evaluation-plan review to distinguish
quality, groundedness, safety, tool-use, regression, human-review, and
unsupported-scope questions. A score or metric is useful only with its bounded
population, version, evaluator, coverage limit, interpretation owner, and
release decision.

Record the evaluation implementation backlog in the evaluation-plan review:
Foundry evaluation target (after current status and scope are verified),
evaluator type or scorecard, dataset/scenario owner, trace source, unsupported
scope, evaluation-suite version, continuous-evaluation cadence where available,
release threshold, future CI/CD or release-gate owner, rollback/observation
route, S8 red-team dependency, S11 operating-review handoff, recommendation,
confidence, assumptions, evidence reference or gap, owner, and customer process.

**Interpret and decide:** retain only safe references to the accepted S6 proof,
evaluation plan, assurance owner, and decision. Choose `continue` only when the
handoff contract is complete and the S6 decision is `accepted`; otherwise
choose `hold`, defer, or record **blocked** with the dependency, owner, target
date, and review date. A fixture score, evaluator result, or proposed gate is
context for a customer-owned process, not an S7 exit.

For a later operating review, retain customer-held references to the bounded
workload, evaluation-plan/version, applicable runtime correlation, decision
outcome, and reviewer. Do not copy evaluation cases, scores, prompts, or
outputs into this kit.
