# S7 Evaluation Gate Runbook

Use this runbook to guide the required lab path. The customer inspects its own Microsoft evaluation and release records, records safe references in its approved system, and decides whether the scoped evaluation gate is ready for handoff.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry gate

Confirm the customer has a bounded workload or portfolio slice, a decision owner, an evaluation owner, an implementation owner, an evidence owner, a release/hold owner, and an approved records location. If any are missing, stop the decision and create a blocker backlog item with the missing owner, record, or approval path.

## Required review flow

1. **Set the gate question.** Record the bounded evaluation decision, such as whether a candidate prompt, retrieval change, agent capability, model version, or release candidate has enough evaluation evidence for handoff.
2. **Choose the route.** Record one or more routes: `foundry-evaluator`, `manual-rubric`, `ci-cd-gate`, `load-test`, or `diagnostic-only`. Use `diagnostic-only` when S6 runtime assurance, telemetry, gateway, or S3 platform prerequisites are missing.
3. **Define the scenario set.** Record safe references for the scenario set, source, owner, reviewer, time window, expected environment, data/tool boundary, and unsupported or excluded slices. Do not paste prompts, outputs, transcripts, or raw customer data.
4. **Inspect evaluator and rubric version.** Name the Foundry evaluator, agent evaluator, scorer, rubric, or SME review method; record version, owner, limitation, and reviewer. If the version cannot be named, defer or block.
5. **Confirm baseline and candidate evidence.** Reference the baseline run or score, candidate run, comparison method, regression tolerance, and evidence owner. If no baseline exists for the selected metrics, create a backlog item before relying on the gate.
6. **Set thresholds and ownership.** Record pass/fail thresholds, threshold-change owner, exception owner, release/hold owner, and the process that receives holds or exceptions.
7. **Review CI/CD gate path.** Record whether the gate is blocking, warning, manual, diagnostic-only, or not applicable; name the pipeline/check reference, gate owner, exception path, and receiving release process. Do not treat the record as automatic release approval.
8. **Review load-test need.** If latency, throughput, quota, cost, or regression tolerance matters, record the Azure Load Testing or customer-approved performance evidence reference, reviewer, threshold, and owner. If performance is out of scope, record why.
9. **Check prerequisites and limits.** Record S6 runtime, S3 platform, S2 data, or S12 lifecycle dependencies that limit evaluation reliance. If prerequisites are missing, mark the path `diagnostic-only`, `defer`, or `blocked`.
10. **Set decision state.** Use one state:
    - `approve`: scenario set, evaluator/rubric version, baseline, thresholds, evidence reference, release/hold owner, acceptance test, and handoff are complete;
    - `defer`: a gap has a named owner and target date;
    - `reject`: the scoped evaluation path cannot meet the gate question safely;
    - `route`: another release, runtime, platform, security, product, legal/compliance, or exception owner must decide first;
    - `blocked`: access, licensing, evidence location, ownership, baseline, S6/S3 prerequisite, or scope clarity prevents a decision.
11. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, release or backlog impact, and next review trigger.
12. **Handoff.** Send the completed decision record and backlog references to the evaluation owner, model/agent owner, QA/release owner, runtime/platform owner where applicable, and governance owner.

## Blocker categories

Use the smallest accurate category: `owner-missing`, `record-location-missing`, `scenario-set-missing`, `scenario-scope-unclear`, `evaluator-version-missing`, `rubric-version-missing`, `baseline-missing`, `threshold-owner-missing`, `ci-cd-gate-not-ready`, `load-test-evidence-missing`, `s6-prerequisite-missing`, `s3-prerequisite-missing`, `access-or-license`, `unsupported-evaluator`, `release-hold-owner-missing`, or `exception-owner-missing`.

## Completion check

The lab is complete when the customer-owned decision record includes the gate question, route, scenario set, evaluator/rubric version, baseline and candidate references, threshold owner, CI/CD gate mode, load-test decision when applicable, prerequisite limits, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
