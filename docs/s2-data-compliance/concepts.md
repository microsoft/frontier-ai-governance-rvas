# S2 · Data & Compliance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Confirm tenant licensing and product availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the Purview data-and-compliance controls used in S2. [S2 Prepare](index.md) starts the safe delivery sequence.

## Data raises its own governance question

![DSPM findings drive labels, DLP, and compliance evidence through the customer change process.](../assets/diagrams/s2-compliance-flow.svg)

Governance has to answer more than "is this agent allowed to run?" It also has
to answer which data reaches the agent, which sensitive data can show up in
prompts, retrieval results, tool outputs, generated responses, storage, or
downstream sharing, and what evidence is left after an interaction.

Microsoft Purview brings data security and compliance to AI workloads and connected apps.[^purview] S2 uses Purview for data classification, discovery, policy review, investigation, and Purview records. Gateway work stays in the platform/runtime sessions.

## S2 starts with one data path, not a product checklist

For one in-scope AI scenario, map the data path in references only. The point is
to inspect where a concrete piece of data can move, not to list every Purview
feature that might exist in the tenant.

1. **Prompt/input:** what user, system, or application input can contain
   sensitive data?
2. **Retrieval/source data:** which repositories, SharePoint sites, files,
   indexes, databases, or connectors can contribute content, and who owns them?
3. **Tool outputs/actions:** which downstream systems can return data or create
   records on behalf of a user or agent?
4. **Generated response:** where could sensitive content be produced, displayed,
   logged, cached, or summarized?
5. **Storage and sharing:** where are transcripts, audit events, files, exports,
   tickets, or messages retained or shared after the interaction?
6. **Runtime dependency:** where would masking, gateway routing, content safety,
   logging, or tool-call control be needed outside Purview?
7. **Evaluation and evidence reuse:** which prompts, outputs, traces, tickets,
   or reviewed records might become evaluation data or workshop evidence later?

Do not copy customer prompts, outputs, documents, exports, audit evidence,
policy configuration, or live tenant data into this repository. Record the
customer-held reference, owner, gap, decision, and review date.

## Segment control map

Use this map when the conversation collapses into "Purview covers it" or "the
gateway masks it." Each segment needs its own coverage statement.

| Segment | Data question | Microsoft/source control to inspect | Gap S2 records |
|---|---|---|---|
| Source system | Which files, sites, databases, messages, or records can enter the scenario? | Purview labels/classifiers, DSPM exposure, source ACLs, retention policy, residency record | Owner missing, overexposed access, unsupported store, unknown data class, stale permissions. |
| Prompt/input | Which user or system input can include sensitive data? | DLP support for workload, app input validation, gateway inspection if routed, telemetry policy | Prompt path unsupported, sensitive fields unminimized, gateway bypass, no logging expectation. |
| Retrieval context | Which snippets or records are selected and cached? | Source ACLs, index filters, connector identity, label filters, cache/storage owner | Retrieval can surface overshared content, stale index, missing filter owner, cache retention gap. |
| Tool request | What parameters leave the agent boundary? | Gateway route, API contract, DLP condition if supported, app redaction, data-processing owner | Regulated parameter crosses boundary, unsupported connector, no minimization before call. |
| Tool response | What data returns from downstream systems? | API response policy, gateway observation, app truncation/redaction, log/correlation route | Gateway cannot see response, returned data bypasses source controls, log captures sensitive payload. |
| Final response | What can be displayed, copied, shared, saved, or summarized? | DLP/report-only observation, Communication Compliance if applicable, output review route | Sensitive answer can be shared downstream, no false-positive owner, no user notice or restriction. |
| Logs/telemetry | What metadata or content is retained? | Audit, app logs, Application Insights/Log Analytics, retention/access owner | Logs become a new regulated data store, retention unknown, access too broad. |
| Evaluation data | What production traces may be reused? | Dataset approval, de-identification route, retention, evaluation owner | Production prompts/outputs reused without approval, no deletion or reuse limit. |
| Evidence reference | Where does the decision point to evidence? | Customer evidence system, eDiscovery/legal hold route, records owner | Evidence copied into delivery materials, unapproved storage, no hold/deletion owner. |

## Findings turn into a work list the customer owns

S2 ends with a recommended next step and its assumptions and owners: close DSPM
or classification gaps, review a report-only DLP change, confirm investigation
or retention, resolve gateway dependencies, or record `accepted_risk`/`blocked`.
Policy rollout remains in the customer's compliance and change process.

Concrete failure modes should be named, not softened:

- **Empty DSPM or audit result without scope:** no-result is not safety proof
  unless workload support, time range, source, role/license, reviewer, and query
  scope are recorded.
- **DLP exists but is not mapped to the AI path:** policy presence does not prove
  prompt, retrieval, tool, response, connector, and workload coverage.
- **Gateway masking treated as Purview proof:** masking may reduce runtime
  exposure, but it does not establish classification, retention, eDiscovery, or
  source permissions.
- **Unsupported connector or workload:** record the unsupported slice and release
  impact rather than claiming equivalent coverage.
- **Telemetry as new risk:** logs, transcripts, traces, and evaluation datasets
  can become regulated data stores.
- **Evaluation reuse without approval:** production prompts and outputs cannot be
  turned into test data unless the customer owns the de-identification,
  retention, and reuse decision.

Keep the decisions separate:

| Decision | What S2 records |
| --- | --- |
| Data path | Which prompts, retrieval sources, tool outputs, responses, storage locations, and sharing routes are in scope. |
| Classification/exposure | Whether each segment is labeled, unlabeled, overexposed, unknown, unsupported, or out of scope. |
| DLP/report-only readiness | Whether a supported Purview DLP scenario can be reviewed in simulation/report-only mode, with false-positive and owner review. |
| Investigation route | Which audit, eDiscovery, IRM, Communication Compliance, legal hold, retention, or customer process would handle a concern. |
| Gateway/runtime dependency | Which masking, routing, logging, or tool-control need belongs to a platform, runtime, or other accountable owner. |
| Decision state | Whether the item is approved to continue, deferred, rejected, `accepted_risk`, or `blocked`. |

## Data Security Posture Management finds exposure before enforcement

Microsoft Purview Data Security Posture Management helps you spot
oversharing, exposed sensitive data, risky access, and likely ways data could
leak.[^dspm] `DSPM for AI` is the classic product label; use the current
product path unless the customer has a reason to retain the classic experience.

It finds likely data-risk areas before a policy blocks or warns users.

**In the practical workshop:** treat each check as one of four outcomes:

- **Result:** the reviewed scope produced a finding, match, label, alert, audit
  route, or customer evidence reference.
- **No result:** the reviewed scope produced no matching signal; record the
  scope, date, and why absence is meaningful.
- **Unsupported:** the workload, location, role, license, or tenant capability
  does not support the expected Purview view or control.
- **Blocked:** the team cannot complete the review because a dependency such as
  access, owner, retention path, legal/compliance decision, or gateway detail is
  missing.

## Labels and DLP turn classification into controls

Sensitivity labels say how data should be handled. DLP policies use those labels (or sensitive-information types) to catch data that is shared or used in ways it should not be.[^purview]

For AI, that can mean spotting protected information in a prompt, a response, or
a connected workflow. The customer has to confirm which workloads, locations,
roles, licenses, and conditions Purview supports in its tenant. If that support
is unknown, S2 records an assumption or gap instead of implying coverage.

The Practical activity starts in simulation or test mode, then reviews matches
and false positives before enforcement. A report-only DLP candidate is not a
production approval; it is a customer-owned change-review input.

## Investigation needs an evidence trail

Audit, eDiscovery, Insider Risk Management, and Communication Compliance each cover a different investigation need.[^purview] Together, where they are supported, they route worrying activity into the customer's normal compliance process.

A DLP policy alone is not an evidence plan; the customer needs the applicable
logs, review queues, retention rules, hold process, legal/compliance owner, and
handoff route. S2 should be able to say who investigates, what customer-held
record they start from, what data is retained or excluded, and where a blocker
stops the path. It should not export or preserve customer prompts, generated
outputs, regulated content, or live tenant configuration in the curriculum
repository.

## Gateway masking helps, but does not replace, compliance

Purview governs how data is classified, reviewed, and investigated in supported
tenant locations. A gateway such as AI Hub Gateway or Citadel Governance Hub can
add a runtime step: for example, masking PII before a request reaches the
model.[^citadel]

These controls work together. Gateway masking does not replace data
classification, DLP review, audit retention, legal hold, or compliance
ownership. And a Purview policy does not stand up a runtime gateway, prove tool
authorization, or guarantee masking on paths Purview cannot see. When the data
path needs runtime control, record the dependency and route it to the appropriate
platform or runtime owner instead of treating it as a Purview checklist item.

[^purview]: Microsoft Learn - [Microsoft Purview for AI](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview).
[^dspm]: Microsoft Learn - [Data Security Posture Management](https://learn.microsoft.com/en-us/purview/data-security-posture-management-learn-about).
[^citadel]: Microsoft - [AI Hub Gateway / Citadel Governance Hub](https://aka.ms/ai-hub-gateway); [PII masking guide](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/pii-masking-apim.md).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Purview, DSPM, DLP, sensitivity, audit, eDiscovery, and compliance sources.
