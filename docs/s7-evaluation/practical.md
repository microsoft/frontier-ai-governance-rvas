# Practical activity: review one assurance package

## What you will do

Customer assurance owners connect an accepted S6 proof to one evaluation plan
and make an explicit `continue` or `hold` decision.

## Before you start

- Confirm accepted S6 gateway proof, named assurance owner, decision owner, and
  approved records location.
- Use only safe references. Do not copy evaluation cases, prompts, scores, or
  outputs into this repository.
- Stop at review if the S6 proof is not accepted.

## Customer-operated activity

1. Follow `labs/s7-evaluation/runbook.md` to copy the assurance and
   evaluation-plan records into the customer system.
2. Record the evaluation scope, coverage limit, interpretation owner, and
   release-decision use.
3. If the customer already ran an approved evaluation, interpret its referenced
   result with its version and coverage limits; do not treat a score as a
   release decision.
4. Validate the handoff and choose `continue` or `hold`.

## What good looks like

A later reviewer can find the accepted S6 proof, evaluation plan, evidence
limits, decision owner, and next action. Missing evidence produces `hold`.

## If the environment is not ready

Complete the evaluation-plan review and record the owner and prerequisite for
the missing evaluation evidence.

## Keep and hand over

Keep the assurance handoff in approved customer records. Hand evaluator, data,
threshold, CI/CD, rollback, or S8 work to the relevant customer owner.
