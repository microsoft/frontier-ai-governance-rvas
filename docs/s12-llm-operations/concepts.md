# S12 · LLMOps concepts

!!! info "Freshness"
    Last reviewed: 2026-07-24. Confirm current Azure service capabilities,
    availability, region, quota, pricing, and customer standards before
    adoption.

[Microsoft's LLMOps guidance](https://learn.microsoft.com/en-us/ai/playbook/technology-guidance/generative-ai/mlops-in-openai/)
defines LLMOps as the collection of tools and processes that manages the
end-to-end development, deployment, and maintenance of LLM-based applications.
It is not a model inventory, a prompt repository, or a dashboard in isolation.
It is the operating system that turns learning from an application into
controlled improvement.

## The inner and outer loops

The inner loop improves a candidate solution before production:

1. **Data curation:** understand, transform, and enrich the data used for
   grounding, examples, evaluation, or fine-tuning.
2. **Experimentation:** test candidate approaches such as prompt engineering,
   retrieval optimization, model selection, fine-tuning, and tuning.
3. **Evaluation:** define fit-for-purpose measures and compare candidates at
   the points that affect solution performance.

The outer loop operates the approved solution:

4. **Validate and deploy:** validate production fitness, compare candidates
   where appropriate, and promote through controlled environments.
5. **Inference:** provide reliable, low-latency, high-throughput responses for
   the intended workload.
6. **Monitor:** assess health, resource use, anomalies, privacy/safety signals,
   and solution performance.
7. **Feedback and data collection:** collect governed user feedback and
   operational learning to enrich the next validation dataset.

The feedback stage closes the loop: production learning becomes a governed input
to data curation and experimentation, not an unreviewed production change.

## A governance decision at every stage

| LLMOps stage | Decision the team must make | Minimum evidence |
|---|---|---|
| Data curation | Is this data permitted, fit for purpose, traceable, and sufficiently representative for the stated use? | Data source, transformation, ownership, quality/privacy limit, and S2 route. |
| Experimentation | Which hypothesis and candidate combination are we testing, and what can the result prove? | Candidate/version reference, hypothesis, experiment owner, population, and limits. |
| Evaluation | What measures, pass/fail criteria, and human judgment determine suitability? | Dataset/scenario, scorer/rubric, threshold owner, coverage limit, and S7 route. |
| Validate and deploy | May this candidate advance from DEV to PRE or PRO? | Release manifest, accepted evidence, change authority, rollback, and exclusions. |
| Inference | Is the production route reliable and governed for its authority and demand? | Deployment/service route, identity/dependency owner, performance assumptions, and support path. |
| Monitor | Which signal triggers review, escalation, rollback, or investigation? | Signal definition, coverage/retention limit, interpretation owner, and S11 route. |
| Feedback and collection | Which feedback can enter learning, and under what privacy, quality, and consent rules? | Collection purpose, approval, retention, curation owner, and S2/S11 route. |

## A learning artifact has a lifecycle

Treat prompts, retrieval configuration, evaluation datasets, model/deployment
aliases, and feedback datasets as controlled learning artifacts. Each needs an
owner, safe reference, version/provenance, intended use, review trigger, and
retirement route. A version alone does not prove that an artifact is suitable,
evaluated, approved, or deployed correctly.

## Azure implementation principle

For Azure/Microsoft workloads, use Microsoft Foundry and the customer platform
to connect the lifecycle: protected source and IaC records for change
provenance; Foundry evaluation and observability where applicable; and
Application Insights/Azure Monitor and the customer incident/change processes
for operation. The selected services are implementation choices. LLMOps is the
decision flow, evidence, and ownership across them.

## Handoffs preserve accountability

- **S2** owns data governance, privacy, retention, and compliance decisions.
- **S4** owns initial implementation-path and model selection/admission.
- **S7** owns evaluation and release-assurance evidence.
- **S11** owns production monitoring, incident operation, capacity, and FinOps.
- **S12** connects the lifecycle, sets stage gates, assigns artifact ownership,
  and ensures feedback safely informs the next inner-loop iteration.

A handoff is a required route and evidence reference, not proof that another
team has completed its work.
