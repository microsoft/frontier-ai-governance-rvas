# Runtime control matrix

Copy this blank matrix into the approved customer records system. It turns a
selected risk into an explicit control placement, response, and evidence
expectation. It does not enable a policy, inspect live traffic, or prove that a
control blocked or allowed a request.

## Scope and decision

| Field | Record |
|---|---|
| Bounded workload, environment, and route | |
| Risk/control decision owner | |
| Platform, security, and operations reviewers | |
| Gateway-proof reference, if available | |
| Approved records location and review date | |

## Risk-to-control matrix

| Risk or failure mode | Inspection point | Selected control layer | Expected action: block / allow / annotate / escalate | Control owner | Response owner and route | Evidence expected later | Coverage limit / capability caveat |
|---|---|---|---|---|---|---|---|
| Unauthorized user or workload access | | Identity / network / gateway | | | | | |
| Direct prompt injection or harmful input | | Gateway / model / agent | | | | | |
| Indirect injection from tool or retrieved content | | Agent / tool response | | | | | |
| Unauthorized or excessive tool action | | Gateway / in-process tool boundary | | | | | |
| Sensitive-data or PII exposure | | Gateway / model / application | | | | | |
| Unsafe or ungrounded output | | Model / application / human review | | | | | |
| Token, rate, or availability abuse | | Gateway / platform | | | | | |
| Missing correlation or telemetry | | Gateway / application / operations | | | | | |

## Layer interaction and evidence

| Control decision | Conflict or bypass scenario | Resolution rule | Correlation / evidence reference | Owner | Review cadence |
|---|---|---|---|---|---|
| Gateway and model/agent controls | | | | | |
| Gateway and in-process tool controls | | | | | |
| Runtime decision and SOC/operations response | | | | | |
| Safety/telemetry retention and privacy boundary | | | | | |

## Follow-up backlog

| Backlog item | Applies / N/A / unknown / follow-up | Recommendation and confidence | Evidence reference or gap | Owner | Follow-up customer process |
|---|---|---|---|---|---|
| Gateway proof and correlation acceptance | | | | | Customer security and evaluation processes |
| Policy, guardrail, tool-control, or response routing | | | | | Customer security or platform process |
| Identity, data, or tool-authority dependency | | | | | Customer identity, data-governance, and tool-governance processes |
| Alert, retention, operational review, or remediation route | | | | | Customer operating process |
