# How to Deliver

This facilitator playbook keeps the S0-S12 curriculum practical. Each session
selects one bounded technical unit of work, records safe references, and decides
whether to proceed, defer, route, reject, or block.

## Delivery outcome

At close, the customer should have:

- an S0 technical baseline card and first blocker;
- one customer-owned artifact for each completed session;
- named owners for blockers and acceptance checks;
- control-plane reconciliation for the in-scope population;
- operating evidence and FinOps signals for the selected workload; and
- a portfolio action package with source lineage and blocker visibility.

Templates and samples are preparation aids. They never prove that a customer
control is deployed, operating, or approved for production.

## Before the first session

Confirm:

- sponsor and decision owner;
- evidence location;
- bounded pilot or route;
- platform, identity, data, security, engineering, operations, and evidence
  owners as needed;
- safe non-production target where runtime, evaluation, or adversarial work is
  requested.

If an owner, evidence location, or safe target is missing, create a blocker
instead of starting downstream work.

## Lean session model

Each session has three working surfaces:

| Surface | Use |
|---|---|
| Session page | Outcome, workshop flow, hard stops, and change boundary. |
| Technical decisions | Microsoft service path, control checks, schemas/snippets, failure modes. |
| Lab kit | One compact README and one technical artifact template. |

Decks are secondary facilitator assets. They summarize the workshop; they are
not a separate source of truth.

## Sequencing

The sequence is flexible, but dependencies are real:

| Phase | Sessions | Practical question |
|---|---|---|
| Govern | S0-S2 | Who owns the pilot, identity path, and data path? |
| Establish | S3-S5 | Which platform, build path, and tool/API route are acceptable? |
| Assure | S6-S8 | What runtime, evaluation, and red-team evidence can be trusted? |
| Operate | S9-S12 | Which records reconcile, which signals operate, and which portfolio action follows? |

Do not use a later session to paper over a missing earlier technical owner or
evidence reference.

## Non-production hard exit gate

Do not run runtime assurance, evaluation, or adversarial activity until:

- the target is customer-owned and non-production;
- the owner can stop, reset, or isolate it;
- scope, window, and rollback contact are recorded;
- no production users or unapproved customer data are in scope;
- S8 has written authorization and rules of engagement.

If any item is missing, stop the activity and continue only with offline review
or another unblocked session.

## Control language

Use concrete states:

| State | Meaning |
|---|---|
| Reference only | Reviewed as a starting point; no customer control is claimed. |
| Designed | Owner, route, and acceptance check are defined. |
| Observing | Customer is collecting non-production, report-only, simulation, or alert evidence. |
| Accepted for next process | Evidence package is ready for the customer's separate process. |
| Blocked | A missing owner, unsupported service, unsafe evidence path, or unresolved technical gap stops reliance. |

Avoid vague scoring or ceremony language. Record the technical blocker
and next action.
