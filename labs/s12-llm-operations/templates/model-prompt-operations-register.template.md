# S12 LLMOps lifecycle canvas and release manifest

Copy this safe-reference template into the customer's approved records system.
Do not enter prompt text, outputs, secrets, customer data, live configuration,
or personal data.

## Scope and ownership

| Field | Record |
|---|---|
| LLM application/service, users, and environment | |
| Lifecycle decision under review | |
| LLMOps, data, experiment, evaluation, platform, service, governance, and evidence owners | |
| Approved records location | |
| Decision and next review date | |

## Inner and outer loop

| Stage | One artifact | One gate / exit decision | Owner | Approved evidence reference and limit | Acceptance evidence / target date | Handoff |
|---|---|---|---|---|---|---|
| Data curation | | | | | | S2 / experiment |
| Experimentation | | | | | | Evaluation |
| Evaluation | | | | | | S7 / validate and deploy |
| Validate and deploy | | | | | | Customer change / inference |
| Inference | | | | | | S11 / service support |
| Monitor | | | | | | Investigate / improve |
| Feedback and data collection | | | | | | S2 / data curation |

## Candidate release manifest

| Control asset | Approved reference | Accountable owner | Status / evidence gap |
|---|---|---|---|
| Service release/version | | | |
| Candidate code, prompt, retrieval, or configuration release | | | |
| Model/deployment alias and inference route | | | |
| Evaluation dataset/scenario and scorer/rubric version | | | |
| S7 evaluation/release decision | | | |
| DEV/PRE/PRO promotion and customer change decision | | | |
| Rollback target | | | |
| Monitoring and feedback collection route | | | |
| Release reconstruction reviewer, acceptance evidence, and target date | | | |

## Lifecycle completeness check

| Question | Yes / no / gap | Evidence reference or owner |
|---|---|---|
| Can a candidate be reproduced from its data, artifact, and evaluation references? | | |
| Can the active PRE/PRO route be reconstructed and rolled back? | | |
| Does monitoring have a coverage limit, interpretation owner, and escalation route? | | |
| Can feedback enter curation only through a governed data route? | | |

## Implementation backlog

| Work item | Blocked stage or risk | Owner | Completion evidence | Target date | Status |
|---|---|---|---|---|---|
| | | | | | |
