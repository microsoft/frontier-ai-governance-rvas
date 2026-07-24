# S12 Takeaway Kit: LLMOps lifecycle

This offline kit turns an LLMOps decision into a customer-owned implementation
handoff. It covers the Microsoft LLMOps inner loop (data curation,
experimentation, evaluation) and outer loop (validate/deploy, inference,
monitoring, feedback/data collection). Azure services support the workflow but
do not replace its gates, evidence, and ownership.

Start with [runbook.md](runbook.md). Copy templates to the customer's approved
records system and retain approved references only. The kit does not ingest data,
change models/prompts, run evaluations, configure services, access live
telemetry, or approve production.

| Template | Use |
|---|---|
| [`templates/model-prompt-operations-register.template.md`](templates/model-prompt-operations-register.template.md) | Map all seven lifecycle stages and record the candidate release manifest. |
| [`templates/operating-model-material-change-decision.template.md`](templates/operating-model-material-change-decision.template.md) | Apply stage gates and route lifecycle changes to S2/S4/S7/S11/platform/change owners. |
| [`templates/incident-rollback-retirement-plan.template.md`](templates/incident-rollback-retirement-plan.template.md) | Define monitoring, feedback-to-curation, incident, rollback, deprecation, and retirement routes. |

The templates contain safe references, not raw data, prompt content, model
outputs, secrets, live configuration, or authority to proceed.
