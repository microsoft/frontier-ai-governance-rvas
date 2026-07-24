# S12 LLMOps stage-gate and material-change decision

Copy this safe-reference template into the customer's approved records system.
It classifies a lifecycle change; it does not authorize data use, deployment,
release, or production use.

## Change decision

| Field | Record |
|---|---|
| Application/service and affected lifecycle stage | |
| Proposed change and approved reference | |
| Current and proposed candidate/release-manifest references | |
| Classification: material / non-material / unknown | |
| Governance decision owner and date | |
| Effective date, exception expiry, or next review | |
| Result: approve / defer / reject / route | |

## Mandatory routing assessment

| Impact question | Yes / no / unknown | Required route and evidence |
|---|---|---|
| Does it add/reuse data, feedback, retention, or a transformation? | | S2 data decision and curation record |
| Does it change model, prompt, retrieval, tool use, fine-tuning, or behavior? | | Experiment record, S7 evaluation, customer change before PRO |
| Does it change a model/provider, deployment path, region, or inference dependency? | | S4 where selection changes; platform/change control; S7/S11 as applicable |
| Does it change evaluation data, scorer, rubric, coverage, or threshold? | | S7 comparison and decision record |
| Does it change telemetry, alerts, incident operation, capacity, or cost allocation? | | S11 and customer change route |
| Is control, evidence, or ownership unavailable? | | Defer; record gap, owner, target date, and limitation |

## Decision and exception record

| Field | Record |
|---|---|
| Decision: advance / hold / reject | |
| Rationale and lifecycle assumptions affected | |
| Required S2, S4, S7, S11, platform, supplier, or change handoffs | |
| Equivalent control for an exception | |
| Required evidence before next stage and before PRO | |
| Rollback/containment target and decision owner | |
| Residual limitation and customer communication | |
| Acceptance evidence, target date, and receiving owner | |
