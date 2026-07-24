# S8 Takeaway Kit: Adversarial Testing

This kit supports one authorized, customer-operated Microsoft Foundry AI Red
Teaming Agent run against a customer-owned non-production endpoint. It contains
no attack dataset, threshold policy, mock target, endpoint client, credentials,
or customer evidence. A completed scan is evidence for only its written scope;
it is not a production approval or a claim that untested attack paths are safe.

**Decision:** approve, defer, reject, or route each finding. The default is an
authorized non-production Foundry AI Red Teaming Agent run where supported.
PyRIT, manual, or other paths require an owner, reason, compensating
authorization, acceptance criteria, target date, and S6/S7/S9 handoff.

See [Lab files: scripts and CSV templates](../README.md) before running the
customer-operated adapter.

## Workshop alignment

Use the [S8 practical activity](../../docs/s8-red-teaming/practical.md)
to confirm roles, the 90-minute monitored window, authorization, stop
conditions, interpretation, and decision before following the runbook. The
customer security/SOC lead and endpoint owner authorize and operate the run;
the facilitator never supplies test data or operates the target.

The customer leaves with references to the authorization, rules of engagement,
SOC debrief, unchanged native scorecard, any threshold comparison, and a
decision with an owner and due date. If any required reference or result is
missing, the outcome is a blocker—not a substitute test or pass.

Use [`runbook.md`](runbook.md) for authorization, the customer-operated run,
native-scorecard handling, and evidence/decision handoff.

Use [`templates/technical-decision-record.template.md`](templates/technical-decision-record.template.md)
to record the red-team approach, scope/authorization, remediation-routing choice,
and adoption stage in the customer's approved records system.
