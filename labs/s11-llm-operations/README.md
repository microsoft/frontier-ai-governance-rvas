# S11 · LLMOps Change Control lab kit

Use this lab to inspect one actual Foundry change and one customer pipeline
change reference before it moves to the next customer process. Work in the
customer's approved records system; this repository keeps only blank templates
and safe field shapes.

## Inputs

- One baseline release reference and one candidate release reference for the
  same workload.
- Microsoft Foundry project, app/agent, prompt or instruction version, model
  deployment/alias, dataset or scenario, evaluation run, monitoring signal, and
  rollout stage references where available.
- Customer pipeline/change run reference, release manifest reference, branch or
  commit reference, environment, rollback target, fallback route, and change
  owner.
- Named owners for data, prompt/instructions, model deployment, evaluation,
  release pipeline, operations, feedback, rollback/fallback, and evidence.
- Known stop condition for missing owner, unsupported service, unsafe evidence
  handling, or any request to move production traffic during the lab.

## Steps

1. Open the Foundry project and inspect project assets for the workload:
   app/agent, prompt/instruction, model deployment, dataset/scenario,
   evaluation, traces/monitoring link, and owner.
2. Open the prompt or instruction source. Check version, owner, change summary,
   rollback reference, excluded content boundary, and approval state.
3. Open the model deployment or alias view. Check baseline alias, candidate
   alias, fallback alias, region, capacity/quota owner, and support boundary.
4. Open the dataset/scenario and evaluation run. Compare baseline and candidate
   result references, thresholds, unsupported slices, and evaluator owner.
5. Open the release manifest. Verify it joins prompt/instruction, retrieval,
   tool schema, model alias, dataset/scenario, evaluation run, runtime control,
   monitoring signal, rollout stage, rollback target, fallback route, and
   approver/change reference.
6. Open the customer pipeline run. Check build/test/evaluation gates, release
   environment, failed/skipped steps, manual approvals, and generated manifest
   reference.
7. Open the rollout stage and rollback/fallback route. Check stage entry
   conditions, stop condition, switch authority, rollback target, fallback
   trigger, and monitoring signal.
8. Safe activity: compare the baseline and candidate release references without
   moving production traffic. Mark each join as matched, missing, mismatched,
   unsupported, or needs separate change review.
9. Classify expected signals: manifest complete, evaluation missing, alias
   mismatch, rollback target missing, feedback source not approved, automation
   not ready, or ready for separate change review.

## Required technical fields

- Foundry project and workload safe reference
- Baseline and candidate release references
- Prompt/instruction version state
- Model deployment/alias and fallback state
- Dataset/scenario and evaluation run state
- Release manifest completeness
- Pipeline run gates and approval state
- Rollout stage, stop condition, rollback target, and fallback route
- Monitoring signal and owner
- Feedback source approval state
- Automation readiness
- Separate change-review readiness

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision wrapper when needed.

## Output

A customer-owned inspection record that says whether the candidate is ready for a
separate customer change review, what must be fixed first, and who owns each
fix. The lab does not edit prompts, mutate data, deploy code, switch aliases,
move traffic, activate fallback, or approve production.
