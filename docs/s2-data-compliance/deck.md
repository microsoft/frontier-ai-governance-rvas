# S2 · Data-Path Trace Workshop

**Facilitator deck**

Microsoft default: **Microsoft Purview Data Security Posture Management, Data
Loss Prevention, sensitivity labels, audit, eDiscovery, retention, and
customer-owned source records**.

Concrete decision: **Can this one AI data path continue with known
classification, exposure, DLP observation, investigation, retention,
minimization, and gateway/runtime boundaries?**

---

## Start with one data path

- Pick one pilot scenario, not a portfolio abstraction.
- Trace source -> prompt/input -> retrieval -> tool request -> tool response ->
  final response -> logs/telemetry -> downstream sharing.
- Every segment needs a control statement, owner, limitation, and next action.

Note:
Open by preventing the session from becoming a generic Purview feature tour.

---

## The path is the artifact

Record references for:

- source data and permissions;
- prompt/input fields;
- retrieval source, index, connector, and cache;
- tool request parameters and tool response classes;
- generated response display, copy, save, and share routes;
- logs, telemetry, transcripts, evaluation data, and evidence references.

Note:
Keep customer prompts, outputs, documents, exports, logs, and policy artifacts in
customer systems.

---

## What Purview can prove

![DSPM findings drive labels, DLP, and compliance evidence through the customer change process.](../assets/diagrams/s2-compliance-flow.svg)

- Classification and sensitivity labels can describe source data where supported.
- DSPM/exposure findings can show oversharing or risky access before
  enforcement.
- DLP/report-only can observe supported sharing or use paths.
- Audit/eDiscovery/retention can support investigation where workload coverage
  exists.

Note:
Purview coverage depends on workload, location, role, license, region, tenant,
condition, and source support.

---

## What Purview cannot prove alone

- It cannot prove gateway masking on paths Purview cannot observe.
- It cannot prove source permissions are least privilege without source review.
- It cannot prove tool responses, streaming output, or direct service calls are
  minimized.
- It cannot turn an empty result into safety proof without validated scope.
- It cannot approve production or deploy policy from the workshop.

Note:
Use this slide when someone says, "Purview covers it" without naming the segment.

---

## Evidence outcomes

| Outcome | Meaning |
|---|---|
| Result | A supported record shows a finding, label, match, alert, route, or classification. |
| No result | A supported review found no signal in a recorded scope, time range, workload, and source. |
| Unsupported | Workload, connector, location, role, license, region, or condition blocks coverage. |
| Blocked | Missing owner, evidence location, scope, retention, legal, or gateway detail stops the decision. |
| Not applicable | The segment is outside the bounded path, with a re-review trigger if it changes. |

Note:
No-result is not a green light unless the review scope is credible.

---

## DLP without enforcement claims

- Map DLP by entry point: prompt, retrieval, tool request, tool response, final
  response, storage, sharing.
- Record state: existing, report-only/simulation, enforced, designed,
  unavailable, not applicable, or blocked.
- Name reviewer, false-positive owner, exception owner, and change process.
- Do not claim runtime proof or production approval.

Note:
S2 may prepare a report-only review. It does not deploy enforcement.

---

## Investigation and retention route

- Which audit search finds the relevant user, app, agent, document, or sharing
  records?
- Which eDiscovery, legal hold, privacy, Insider Risk, or Communication
  Compliance owner receives an observation?
- Which retention policy governs source content, interaction logs, evidence
  notes, and investigation records?
- Which logs become a new regulated data store?

Note:
A DLP policy is not an investigation plan.

---

## Minimization and gateway boundary

- Prefer the earliest reliable point: source filter, retrieval filter,
  application redaction, gateway masking, output check, telemetry minimization.
- Gateway masking complements Purview; it does not replace classification, DLP,
  audit, eDiscovery, retention, or legal hold.
- Record bypasses: direct service calls, streaming, tool response, cached
  retrieval, telemetry payloads, and evaluation reuse.

Note:
Ask where the sensitive field first appears and where it first can be reduced.

---

## Failure modes and hard stops

- Unknown source owner or data class.
- Empty DSPM/audit result without validated scope.
- DLP policy exists but does not map to the AI route.
- Unsupported connector, workload, condition, role, license, or region.
- Gateway-visible prompt used as proof of source-system controls.
- Logs, transcripts, or evaluation datasets retain sensitive data without owner.
- Retention, legal hold, residency, or privacy route unresolved.

Note:
Defer with a named owner and accepted-when condition when fixable. Block when the
path cannot be safely reviewed.

---

## Workshop artifact and decision

The record must capture:

- data-path trace card;
- segment control map;
- Purview/DSPM/classification outcomes;
- DLP/report-only readiness;
- audit/eDiscovery/retention route;
- minimization placement and bypasses;
- decision: approve, defer, reject, route, or blocked with owner, target date,
  handoff, and review trigger.

Note:
Close with the artifact, not a meeting summary. S2 changes no policy, exports no
evidence, proves no runtime enforcement, and approves no production.
