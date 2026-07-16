# In-process governance applicability review

Copy this template into the approved customer records system. It supports an
adoption decision only; it does not authorize AGT installation, code change,
policy deployment, endpoint access, or production use.

## Candidate boundary

| Field | Record |
|---|---|
| Candidate agent/workload reference | |
| Candidate tool action and delegated authority | |
| Existing gateway/API controls | |
| Existing identity, data, evaluation, and runtime controls | |
| Policy owner and approval route | |
| Audit-record owner and retention need | |
| Tamper-evidence requirement, if any | |
| Decision owner and review date | |

## Evidence needed before any future engineering assessment

| Evidence need | Owner | Status / reference |
|---|---|---|
| Current AGT source, release status, APIs, and limitations reviewed | | |
| Supported language/runtime and framework fit reviewed | | |
| Policy ownership and change-review route defined | | |
| Audit storage, retention, access, and tamper-evidence route defined | | |
| Gateway, identity, data, runtime, and outcome controls remain in force | | |
| Rollback, verification, and production-change process identified | | |

## Decision

| Field | Record |
|---|---|
| Decision: investigate further / defer / reject / not applicable | |
| Rationale and limitations | |
| Owner and due date | |
| Dependencies and next review | |

## In-process governance implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Later session or customer process |
|---|---|---|---|---|---|
| AGT applicability, release status, API, and limitation assessment | | | | | Engineering assessment |
| Tool-call policy owner, approval route, and delegated authority | | | | | S4 / S5 |
| Integration, framework/runtime fit, rollback, and verification | | | | | Customer SDLC/change process |
| Signed immutable audit record, retention, and tamper-evidence route | | | | | Records/security process |
| Gateway, identity, data, runtime, or catalog dependency | | | | | S1 / S2 / S6 / S9 |
