---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 06</p>

# Azure API Management AI gateway design

120 minutes · Create an owned gateway design and readiness record

<!-- Notes: This is a facilitated design workshop. Do not make Azure changes in this session. -->

---

## Why it matters

> Create a source-controlled APIM gateway design record that a delivery team can use to decide
> whether a target AI workload is ready for an approved implementation.

- Name the backend, ingress, identity, network, APIM, Content Safety, and telemetry boundaries.
- Record limits, safety, routing, and restore decisions.
- Name the owners and readiness gaps.

<!-- Notes: Keep the conversation on one target workload and its nonproduction scope. -->

---

<!-- _class: two-column -->

## Architecture and gateway boundary

<div class="columns">
<div>

The caller reaches APIM through the recorded ingress. APIM validates the caller, applies the
recorded controls, then calls the selected backend with the backend identity in the record.

Content Safety and telemetry have named control boundaries. The design record assigns their owners
before policy authoring starts.

</div>
<div>

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

**APIM** owns the route and policy.

![Azure AI Content Safety](assets/icons/microsoft/azure-ai-content-safety.svg)

**Content Safety** has a separate decision and owner.

</div>
</div>

<!-- Notes: Do not imply that the design record controls live traffic. APIM does after implementation. -->

---

<!-- _class: decision -->

## Architecture tradeoffs

| Decision | Record now | Handoff |
| --- | --- | --- |
| Backend | Type and approved endpoint reference | Select the implementation variant |
| Ingress and identity | Client credential and APIM backend identity | Configure token validation and backend authorization |
| Network | Inbound, backend, and DNS paths | Validate the reachable implementation route |
| Safety and telemetry | Content Safety path and body-capture policy | Author policies that preserve the data boundary |
| Restore | Disable or rollback path | Use the approved implementation change path |

<!-- Notes: An endpoint reference is allowed. A live endpoint or credential is not. -->

---

## Readiness is visible

`gateway-design-record.json` has two usable states:

- **ready-for-implementation**: all decisions are complete and no readiness gap is open.
- **approved-with-gaps**: a named owner still has an action to complete.

Every gap has an ID, description, owner, and resolution action. The preflight script checks the
record locally. It does not sign in to Azure.

<!-- Notes: If a decision cannot be made, record the gap. Do not guess. -->

---

<!-- _class: implementation -->

## Working path

**Total session: 120 minutes.**

1. Set the scope and target backend boundary.
2. Record APIM, identity, network, safety, telemetry, and operating decisions.
3. Name owners and readiness gaps.
4. Run preflight against the completed record.
5. Hand the record to the implementation owner or wait for the recorded gaps to close.

<!-- Notes: The result is a durable implementation input, not a deployed gateway. -->

---

## Stop before handoff

- The target backend, ingress, identity, network path, or APIM tier is unknown.
- A live endpoint, credential, token, prompt, or customer content appears in the record.
- A required decision has no named owner.
- An open gap lacks a resolution action.
- The record is marked ready while a readiness gap remains open.

<!-- Notes: Resolve the gap or leave the record approved-with-gaps. -->

---

## Session 07 applicability

Session 07 implements the existing **Foundry Agent Service policy-assistant** variant. It needs:

- a target agent endpoint;
- actual backend authorization;
- approved network connectivity; and
- this completed design record.

The Session 06 design works for other approved backend types. Those backends need a separately
approved implementation variant.

<!-- Notes: Keep this distinction clear. Session 06 is deliberately backend-flexible. -->

---

## Operate the design record

The delivery owner keeps the record with the workload's approved change records. Update it through
source control when the backend, identity, network, APIM tier, safety decision, telemetry
boundary, limits, routing, restore path, or ownership changes.

The Session 07 preflight process consumes the record before a deployment proposal.

<!-- Notes: The design record has no Azure resource to remove. -->

---

<!-- _class: closing -->

# Thank you!
