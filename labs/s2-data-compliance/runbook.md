# S2 Runbook

This file is retained for existing delivery links. Use
[`review-checklist.md`](review-checklist.md) as the detailed runbook.

## Decision contract

For one bounded data path, ask: **“Do we approve, defer, reject, or route the
proposed data-use enforcement decision?”** Default to supported Microsoft
Purview controls and the customer change-review process. If capability, workload
coverage, licensing, role, or retention is unavailable, document that exception
with owner, evidence reference, acceptance criterion, and target date; do not
claim equivalent coverage.

Complete the detailed steps in order: evidence/investigation question, path and
dependencies, DSPM for AI review, DLP coverage and report-only decision,
Audit/eDiscovery route, decision tree, and handoff. Record the result in
`templates/technical-decision-record.template.md`, then hand S3 platform
dependencies to S3 and runtime-security dependencies to S6. This runbook does
not deploy a policy, change a customer system, or approve production.
