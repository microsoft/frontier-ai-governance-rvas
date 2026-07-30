# Plan the engagement

Use this guide to prepare a focused AI-governance engagement. The facilitator
runs the method; customer administrators use their own tools, and customer
decision owners approve changes and accept risk.

## Bring the right people

| Role | Main contribution |
|---|---|
| Executive sponsor | Sets direction, clears blockers, and accepts portfolio priorities. |
| Governance lead | Owns the baseline, evidence record, and first technical blocker. |
| Platform owner | Owns the platform path, trust-boundary decisions, and platform evidence. |
| Identity, data, and security administrators | Open and operate the relevant customer controls. |
| AI developer or maker | Explains agent implementation, testing, changes, and tool boundaries. |
| Evidence owner | Maintains evidence references, retention treatment, and decision traceability. |

One person can hold several roles. Do not schedule a decision workshop without a
customer decision owner.

## Prepare the first decision

Write down:

1. one bounded agent group or use-case question;
2. the decision to make and its possible outcomes: approve, defer, reject, or route;
3. the customer records location and evidence owner;
4. the technical owner, known architecture limits, and relevant supplier dependency;
5. the safe stop condition and any non-production target required for the work.

Use the initial conversation as triage, not a scoring exercise. If the customer
cannot name a decision owner, evidence owner, approval route, or safe review
target, record readiness work with an owner instead of beginning a workshop.

Before booking, complete [Check whether a session is ready](../delivery/session-readiness.md).
It keeps the 90-minute workshop focused on a decision rather than missing
prerequisites.

## Choose only the work that answers the question

Start with a [governance baseline and operating-model workshop](../s0-foundations/index.md).
It identifies the first technical blocker and selects the smallest useful set
of follow-on workshops.

Use these dependencies when selecting that work:

- establish the platform route before relying on admission, publication, runtime,
  evaluation, or adversarial-testing decisions;
- set admission and tool or API authority before making downstream change or
  assurance decisions;
- use an approved non-production target before runtime assurance, evaluation, or
  adversarial testing;
- reconcile ownership and lifecycle records before relying on operating or
  portfolio decisions.

The customer may already have a platform path. Treat readiness gaps as owned
backlog items; accept control readiness only from customer records.

## Deliver safely

Start with the least disruptive posture: report-only access controls; simulated,
test, or notify-mode data controls; and decisions before platform or engineering
deployment. Production promotion remains a customer change decision.

Before a privileged change, confirm the human approver, change window, incident
contact, rollback owner and trigger, verification step, and evidence-retention
route. Notify security operations before adversarial testing. See
[How to Deliver](../how-to-deliver.md#non-production-hard-exit-gate) for the
live-action exit gate.

Keep customer evidence in customer systems. This curriculum may reference a
record, gap, owner, date, decision, or retention treatment. It must not copy
customer prompts, outputs, telemetry, credentials, supplier contracts, audit
evidence, or regulated records into the repository.

Supplier and third-party questions remain visible during planning, but the
curriculum does not create a supplier-assurance program or legal conclusion.
Route them through the customer's existing procurement, legal, security, or
vendor-risk process, or record an owned follow-up.
