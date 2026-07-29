# S9 · Control-Plane Reconciliation & Lifecycle

**Facilitator deck**

Microsoft default: **Agent 365 where available, Microsoft Entra Agent ID, Azure API Center, API Management/gateway, Microsoft Foundry, Azure Monitor/Application Insights, and customer control-plane register**.

Concrete decision: **Close, close with owned gaps, defer, reject, route, or block the reconciliation package for one bounded population.**

---

## The control plane is accountable records

- A dashboard is not the control plane.
- A source export is not the control plane.
- The control plane is the customer-owned registry that says what exists, who owns it, how records join, which lifecycle state applies, and what gaps remain.

Note:
Start by separating visibility from accountability. S9 is not "do we have a list?" It is "can this list be governed and closed?"

---

## Registry population card

- Population: pilot, agent group, API/tool set, Foundry project, or portfolio slice.
- Included: agents, identities, tools/APIs, models, data sources, telemetry pointers, lifecycle records.
- Excluded: records owned by another steward or not in scope.
- Owners: steward, evidence owner, lifecycle owner, finding owners.
- Cadence: next review and re-entry triggers.

Note:
If the population is vague, every reconciliation result will be vague.

---

## Canonical fields

| Entity | Minimum fields |
|---|---|
| Agent/workload | registry ID, purpose, lifecycle, owners, risk tier, exception |
| Identity | object/app/agent identity ID, sponsor, authority, disabled state |
| Tool/API | API/tool ID, schema, route, parent/consumer, owner, lifecycle |
| Model | deployment alias, region, quota owner, evaluation baseline |
| Data | source, classification, permission boundary, data owner |
| Telemetry | correlation key, query owner, alert owner, retention owner |
| Lifecycle | state, transition, review, closure, recurrence |

Note:
Unknown fields are not filled with best guesses. They become findings.

---

## Source of record is field-level

- Agent records may come from Agent 365, Foundry, or customer register.
- Identity truth comes from Entra identity records.
- Tool/API truth may come from API Center, API Management, gateway, or publication record.
- Telemetry truth comes from operations views.
- Lifecycle and exceptions come from customer governance records.

Note:
Do not ask "which system is the system of record?" Ask "which system owns this field?"

---

## Join keys: explicit identifiers only

- Registry ID.
- Platform object ID.
- Agent identity ID.
- Application ID.
- API ID or gateway route ID.
- Tool schema ID.
- Foundry project/agent/model reference.
- Telemetry correlation key.
- Customer record reference.

Note:
Names, aliases, screenshots, and owner guesses are hints, not joins.

---

## Reconciliation finding types

- Missing owner or steward.
- Stale version.
- Orphan identity.
- Uncataloged tool/API.
- Route mismatch.
- Telemetry gap.
- Lifecycle conflict.
- Exception aging.
- Unsupported field coverage.

Note:
Each finding needs affected reference, source systems, conflict rule, owner, target date, validation reference, and recurrence check.

---

## Lifecycle state machine

- proposed;
- active_review;
- publish_ready;
- published;
- hold;
- suspended;
- deprecated;
- retired;
- withdrawn.

Note:
Lifecycle is a decision trail, not a label. A transition needs owner, review reference, effective date, and permitted destination.

---

## Material-change triggers

- Owner or steward change.
- Identity or authority change.
- Tool/API schema or gateway route change.
- Model deployment or alias change.
- Data source or classification change.
- Telemetry pointer change.
- Risk tier or exception change.
- Lifecycle state change.
- Operating scope change.

Note:
Material change reopens the package because prior reconciliation may no longer describe the population.

---

## Closeout with owned gaps

Close with gaps only when every gap has:

- owner;
- acceptance test;
- target date;
- evidence reference;
- recurrence check;
- exception route if residual risk is accepted;
- receiving process and next review trigger.

Note:
Closeout accepts accountability, not absence of findings.

---

## Schema and safe evidence boundary

- Use the S9 registry schema or equivalent customer shape.
- Store field shapes and safe references here.
- Keep customer exports, object IDs, tenant IDs, telemetry payloads, retirement evidence, live config, and secrets in customer systems.
- Do not add live tenant queries during the workshop.

Note:
The schema makes the record precise; it is not a reason to copy raw evidence.

---

## Failure modes and hard stops

- Matching by display name.
- No steward or approved records location.
- Orphan identity without sponsor.
- Tool/API exists without parent or consumer.
- Telemetry pointer has no query or retention owner.
- Lifecycle state has no transition evidence.
- Exception expired without owner.
- Retired state has no closure evidence.
- Workshop asks for live tenant changes or production approval.

Note:
These become block, defer, or route decisions.

---

## Workshop artifact and handoff

- Artifact: control-plane reconciliation package.
- Decision: close, close with owned gaps, defer, reject, route, or block.
- Handoff: steward, identity owner, API/tool owner, platform/Foundry owner, telemetry owner, lifecycle owner, portfolio or release/change owner.
- Boundary: read-only, safe references only, no catalog/access/lifecycle changes, no runtime-proof or production-approval claim.

Note:
End with owners, dates, acceptance tests, and recurrence checks.
