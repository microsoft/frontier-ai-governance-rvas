# S10 Conditional In-Process Governance Decision Record

Copy this template into the customer's approved records system. Use it to record one bounded S10 applicability decision.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, tenant policy, tool arguments, or customer evidence in this repository.

## Scope

| Field | Record |
|---|---|
| Workload / capability / portfolio slice | |
| Candidate tool action | |
| Exact pre-tool decision needed | Allow / deny / approval / route / none |
| Delegated authority being constrained | |
| Decision owner | |
| Code or implementation owner | |
| Policy owner | |
| Evidence owner | |
| Audit-record route and retention owner | |
| Approved customer records location | |
| Target date | |

## Applicability decision

| Decision field | Record |
|---|---|
| Boundary choice | Gateway-only / in-process candidate / both / not applicable |
| Result | Approve / defer / reject / route |
| Rationale | |
| Gateway or platform control reference | |
| In-process decision reference or skip reason | |
| Evidence reference | |
| Accepted when | |
| Exception status | None / proposed / accepted / rejected |
| Handoff owner and customer process | |
| Review date or trigger | |

## Required considerations

Keep answers short and references-only. Do not paste sensitive prompts, outputs, telemetry, access assignments, tenant configuration, customer data, or runtime validation artifacts.

| Consideration | Customer answer / reference | Decision impact |
|---|---|---|
| Can gateway/platform controls make the meaningful decision? | | |
| Is there an exact local pre-tool allow, deny, approval, or route decision? | | |
| What delegated authority does the local decision constrain? | | |
| Who owns the customer code or implementation path? | | |
| Who owns policy changes and approval route? | | |
| Where will audit records be retained? | | |
| If AGT is considered, what Public Preview caveat or limitation must be assessed? | | |
| If not applicable, what alternate S11/S13 or customer-backlog path remains? | | |

## Decision paths

| Path | Complete when | Backlog rule |
|---|---|---|
| Gateway-only | Gateway/platform control can make the meaningful decision and owner accepts the reference | No in-process or AGT adoption item is needed |
| In-process candidate | A real local pre-tool decision and delegated authority exist and gateway controls cannot decide it | Create only a customer-owned engineering assessment item |
| Both | Gateway control and local context are both needed | Name correlation, conflict-review, audit, and owner routes |
| Not applicable | No real local decision point or delegated authority exists | Preserve skip path; no adoption task is needed; route to S11/S13 or customer backlog |

## Exception or future assessment

Complete this section only when a future engineering assessment, exception, or compensating control is needed. This record does not approve deployment, tenant change, policy operation, runtime suitability, or production release.

| Field | Record |
|---|---|
| Reason | |
| Equivalent or compensating control | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Review trigger | |
| AGT Public Preview caveat, if considered | |

## Backlog and handoff

Create a customer-owned backlog item only for a gap that prevents the selected decision from being accepted by the receiving owner.

| Backlog field | Record |
|---|---|
| Backlog item | |
| Boundary choice | Gateway-only / in-process candidate / both / not applicable |
| Owner | |
| Evidence location | |
| Accepted when | |
| Exception if any | |
| Target date | |
| Handoff process | |

## Safe filled example

| Field | Safe example |
|---|---|
| Boundary choice | "Not applicable" |
| Rationale | "No delegated local pre-tool decision was identified; gateway control remains the customer-owned path" |
| Evidence reference | "Customer-approved control record reference; no prompts, outputs, telemetry, policy, or tool arguments copied here" |
| Backlog item | "None for S10; route operating observation to S11 review backlog" |
