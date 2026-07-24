# S12 · LLMOps: Azure implementation blueprint

!!! warning "Verify before adopting"
    This is an Azure/Microsoft reference operating model. Verify current
    Microsoft Foundry, Azure Monitor, Application Insights, API Management,
    region, quota, and customer requirements before implementation.

S12 makes the LLMOps lifecycle operational. It prescribes the minimum
engineering records and decision gates needed to move learning from data to
production and back into governed improvement. It does not select a model,
configure Azure resources, or approve a production release.

## Reference lifecycle and Azure mapping

| Stage | Azure/Microsoft implementation default | Required governance record | Exit decision |
|---|---|---|---|
| Data curation | Customer-governed data source and transformation process; approved references to data and retrieval/evaluation assets. | Data purpose, source/provenance, transformation, retention, owner, and S2 decision. | Suitable for the stated experiment/evaluation use, or blocked. |
| Experimentation | Protected source repository and reproducible candidate references for prompts, retrieval configuration, model/deployment choices, and code. | Hypothesis, candidate/release reference, experiment population, owner, and limitations. | Worth evaluating, abandoned, or requires new data/control. |
| Evaluation | Microsoft Foundry evaluators/agent evaluators where supported, customer rubrics, and versioned scenario datasets. | Scorer/rubric, dataset/scenario version, coverage, threshold owner, results reference, and S7 decision. | Candidate meets the defined gate, fails, or needs iteration. |
| Validate and deploy | DEV -> PRE -> PRO promotion through customer CI/CD, IaC, and change control. | Release manifest linking service release, deployment alias, instruction release, evaluation evidence, approver, and rollback target. | Promote, hold, rollback, or reject. |
| Inference | Foundry deployment behind a customer-owned alias; selected gateway/backend contract and managed identity/network path where applicable. | Service/deployment route, owner, dependency and support path, performance assumptions. | Ready for approved workload, or constrained/deferred. |
| Monitor | Foundry observability where applicable plus Application Insights/Azure Monitor and customer alerting. | Signal, population, retention/coverage limit, interpretation owner, escalation route, and S11 reference. | Normal operation, investigate, contain, or improve. |
| Feedback and collection | Approved feedback capture and curation pipeline; feedback enters a candidate dataset, never a direct production mutation. | Purpose, consent/privacy route, sampling/quality rule, retention, owner, and S2/S11 handoff. | Reuse for inner-loop curation, discard, or investigate. |

## Non-negotiable lifecycle controls

1. **Reproducibility:** every experiment and promotion has a safe reference to
   its code/configuration, candidate artifacts, data/evaluation version, and
   outcome. Do not put sensitive contents in the S12 kit.
2. **Separated environments:** DEV, PRE, and PRO have named purposes,
   promotion authority, and stated equivalence limits. PRE evidence is not
   automatic PRO approval.
3. **Stage gates:** a candidate cannot skip from an experiment to PRO. It needs
   S7 evaluation/release assurance and a customer change decision.
4. **Closed-loop learning:** feedback/data collection requires governance before
   it becomes curation input; monitoring signals create a hypothesis, not an
   automatic root cause or model change.
5. **Reconstructable inference:** the active PRO route is recoverable from a
   release manifest: service release, deployment alias, instruction/retrieval
   release, evaluation reference, approval, and rollback target.

## Material-change decision matrix

| Change | Lifecycle effect | Mandatory route |
|---|---|---|
| New data source, feedback reuse, retention, or transformation | Changes data-curation fitness and privacy/compliance assumptions. | S2, then experiment/evaluation owner. |
| Prompt, retrieval, tool-use, model, fine-tuning, or configuration behavior change | Creates a new experimental candidate. | Experiment record, S7 evaluation, customer change before PRO. |
| New model/provider, family, region, or deployment path | Changes selection, inference dependencies, and possibly behavior. | S4 admission/selection, S7, platform/change control, S11 as applicable. |
| Deployment alias, fallback, quota, capacity, gateway, or identity change | Changes validation/deployment or inference dependencies. | Platform/change control; S7/S11 where behavior or operations change. |
| Evaluation dataset, scorer, rubric, or threshold change | Changes what the team can claim from evaluation. | S7 decision and recorded comparison/coverage impact. |
| Telemetry, alert, retention, cost allocation, or incident route change | Changes monitoring and feedback-loop evidence. | S11 and customer change route. |

## Implementation handoff and acceptance

| Work item | Owner | Completion evidence |
|---|---|---|
| Map one workload across all seven LLMOps stages | LLMOps/service owner | Completed lifecycle canvas with owner and record at every stage. |
| Version inner-loop artifacts and experiment records | Engineering/instruction owner | Protected source/release convention and completed experiment reference. |
| Establish the evaluation gate | S7/release owner | Scenario/rubric and accepted evaluation decision reference. |
| Establish promotion and reconstruction | Platform/service/change owner | DEV/PRE/PRO record and completed release manifest with rollback target. |
| Establish inference operations | Platform/service owner | Deployment alias, support/dependency, and performance-assumption references. |
| Establish monitoring and feedback governance | S11, S2, and service owner | Signal/feedback definitions, ownership, coverage limits, and escalation/curation routes. |

## Boundaries

S12 uses the results of S2, S4, S7, and S11 but does not duplicate their
decisions. Its value is the joined-up workflow: every production signal and
user-feedback item has a governed route back to the correct inner-loop stage,
with an accountable owner and evidence trail.
