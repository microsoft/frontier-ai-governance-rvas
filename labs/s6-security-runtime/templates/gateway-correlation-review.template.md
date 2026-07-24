# Gateway correlation review

Copy this template into the approved customer records system. It reviews a
customer-operated non-production request through the approved gateway path. Do
not store prompts, responses, endpoint values, credentials, raw telemetry, or
customer identifiers in this repository.

## Review contract

| Field | Record |
|---|---|
| Bounded workload / pilot path | |
| Gateway-proof manifest reference | |
| Gateway route and access-contract reference | |
| Backend and policy reference | |
| Correlation identifier | |
| Request evidence reference | |
| Telemetry evidence reference | |
| Platform reviewer | |
| Security reviewer | |
| Decision owner and review date | |

## Correlation decision

| Check | Result / reference | Interpretation owner |
|---|---|---|
| Manifest conforms to `rvas.delivery.gateway-proof.v1` | | |
| Manifest result is `pass` or `fail`; any `blocked` review decision is recorded separately | | |
| Correlation identifier resolves in approved gateway telemetry | | |
| Observed route matches the approved gateway/access-contract/backend path | | |
| Observed policy behavior supports the stated expectation | | |
| Prompt Shields, gateway policy, identity, telemetry, and human-review limits are recorded separately | | |

## Decision matrix

| Observed pattern | Decision |
|---|---|
| Conforming `pass` manifest and accepted telemetry correlation by both reviewers | Accepted gateway proof. Record the decision reference and any permitted use. |
| `pass` manifest but missing or disputed telemetry correlation | Deferred or blocked. A transport pass is not enforcement evidence. |
| `fail` manifest | Rejected or deferred with owner, target date, and reviewed scope. |
| Unsafe route, production-only target, missing reviewer, or missing record location | Blocked. Stop dependent assurance work. |
| Direct Content Safety or component diagnostic only | Reference separately as a diagnostic; do not use as S6 gateway proof. |

## Runtime-control implementation backlog

| Backlog item | Applies / N/A / unknown / follow-up | Recommendation and confidence | Evidence reference or gap | Owner | Follow-up customer process |
|---|---|---|---|---|---|
| Gateway/APIM route, access contract, backend, or policy remediation | | | | | Customer platform process |
| Content Safety, Prompt Shields, or runtime policy review | | | | | Customer security process |
| Telemetry correlation, retention, alerting, or reviewer route | | | | | Customer operating process |
| Identity, RBAC, OBO, or data-control dependency | | | | | Customer identity and data-governance processes |
| Accepted gateway proof use in evaluation or release assurance | | | | | Customer evaluation process |
| Catalog/lifecycle or operating-evidence update | | | | | Customer service-management process |
