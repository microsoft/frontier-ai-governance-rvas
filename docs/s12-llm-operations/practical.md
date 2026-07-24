# Do this

**Customer owner:** LLMOps owner, AI developer, and service owner

Use a fictional or sanitized workload. Do not use live data, prompt text,
outputs, credentials, production telemetry, or service configuration.

1. Complete one lifecycle-canvas row for each inner-loop stage: data curation,
   experimentation, and evaluation. Name the artifact, owner, evidence
   location, exit decision, and S2/S7 handoff.
2. Complete the outer-loop rows for validate/deploy, inference, monitoring, and
   feedback/data collection. Include the PRE/PRO gate, release manifest,
   rollback target, monitoring signal, and feedback-to-curation rule.
3. Classify three changes: reuse feedback in an evaluation dataset, change a
   retrieval/prompt candidate, and alter telemetry retention. Apply the S2,
   S7, S11, platform, or customer-change route.
4. Select the weakest lifecycle link and create one owner-backed implementation
   work item with completion evidence and a target date.

**Decision question:** Can learning safely move from production feedback to a
curated candidate, through evaluation and promotion, then back into monitored
operation? Record **approve, defer, reject, or route**. If not, defer the
affected lifecycle claim.

**Azure/Microsoft default:** use protected source and customer change control,
Foundry evaluation/observability where supported, and Azure Monitor/Application
Insights for operation. An exception must name its verified service, owner,
coverage limit, acceptance evidence, and target date.

**Acceptance:** each of the seven stages has one artifact, gate, owner,
safe-reference evidence, and handoff; the release manifest reconstructs the
active route and rollback target. S12 changes and approves nothing in a customer
system.
