# S9 · Control-Plane Reconciliation & Lifecycle

**Facilitator deck**

Microsoft default: **Agent 365 where available, Microsoft Entra Agent ID, Azure API Center, API Management/gateway, Microsoft Foundry, Azure Monitor/Application Insights, and customer control-plane register**.

Concrete decision: **Reconcile one bounded population, then close, close with owned gaps, defer, reject, route, or block.**

---

## Reconcile accountable control-plane fields

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

## Open each source system

- Agent 365 / agent inventory: `admin.microsoft.com` -> Copilot -> Agents &
  connectors -> All agents; check owner, channel, lifecycle, identity link.
- Entra: Agent ID, managed identity, service principal, sponsor, enabled state.
- API Center and API Management: API/version/schema, product/backend/route.
- Foundry: project, app/agent, deployment alias, evaluation/run, telemetry link.
- Monitor/App Insights: correlation key, query owner, alert owner, retention.
- Defender/Sentinel: posture, alert/incident route, SOC owner.
- Portfolio/CMDB/change: owner, lifecycle, exception, duplicate record.

Note:
Record safe references and states only. Raw exports, object IDs, endpoints,
telemetry payloads, tenant IDs, and screenshots stay in customer systems.

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

## One-workload reconciliation

- Pick one workload and compare IDs across registry, Agent 365, Entra, API
  Center, API Management, Foundry, Monitor, Defender/Sentinel, and portfolio.
- Verify owner, lifecycle state, callable API/tool, model deployment alias,
  telemetry pointer, security handoff, and duplicate records.
- Classify the result before assigning work.

Note:
Expected signals are matching owner, orphaned identity, uncataloged API,
unmonitored deployment, stale lifecycle state, missing telemetry, duplicate
record, unsupported source, or validated no-gap.

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
Each finding needs affected reference, source systems, conflict rule, owner, target event, validation reference, and recurrence check.

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

## Decide and hand over

- Complete: reconciled population, owned gaps, and lifecycle actions.
- Decision: close, close with owned gaps, defer, reject, route, or block.
- Handoff: steward, identity owner, API/tool owner, platform/Foundry owner, telemetry owner, lifecycle owner, portfolio or release/change owner.
- Boundary: read-only, safe references only, no catalog/access/lifecycle changes, no runtime-proof or production-approval claim.

Note:
End with the decision, receiving owner, next reconciliation action,
accepted-when condition, and customer-owned evidence reference.
