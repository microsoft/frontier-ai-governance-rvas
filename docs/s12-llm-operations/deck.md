# S12 · LLM Operations

**Facilitator deck**

Governance lead - Model operations owner - Service owner - 90-minute evidence-first review

Note:
This provider-neutral, report-only session records a customer-owned model-and-prompt operating model. It does not select or deploy models, alter prompts, query live data, configure services, or approve production changes.

---

## One operating-model decision

> **"Should this model-and-prompt operating model be approved, deferred, or rejected?"**

The answer names applicability, assets, owners, change routes, dependencies, limitations, and backlog.

Note:
Keep the scope bounded to a workload, service, product configuration, or asset population. Approval concerns the operating model only; it is not a production-change approval.

---

## Applicability begins with customer control

- S12 applies when the customer can select, configure, version, or materially change a model or system instruction.
- Customer-controlled, shared-control, supplier-managed, and unknown routes have different evidence needs.
- A supplier statement is not proof for a specific customer configuration.

Note:
Ask what the customer can actually change. When a managed product or supplier controls the asset, record the customer controls, supplier route, limitation, and ownership instead of assuming direct model operation.

---

## The asset boundary is operational

- Reference approved model/provider, access path, prompt or system-instruction asset, version, owner, and service scope.
- Retain references, not prompt text, responses, credentials, or live configuration.
- A version identifier supports comparison; it does not prove safety or approval.

Note:
The goal is not a universal inventory. It is a reviewable answer for a bounded scope: which assets are approved, who owns them, and how a meaningful change is assessed.

---

## Material changes need a route

- Assess model/provider, model version, access path, system instruction, region, quota, ownership, service route, and retirement changes.
- Classify the effect on the approved operating model and record the rationale.
- A version number alone does not decide materiality.

Note:
A small instruction edit can be material when it changes authority or expected behavior. A provider change can be material when it changes the approved asset path. Record the route; do not make the change here.

---

## Dependencies are not assurances

- Capacity, quota, region, supplier, incident, rollback, deprecation, and retirement dependencies need owners and evidence limits.
- A named route does not prove availability, recovery, or operating effectiveness.
- Gaps become customer-owned backlog items.

---

## Keep the handoffs distinct

- **S4:** initial admission and model/provider selection.
- **S7:** evaluation and release assurance for material changes.
- **S11:** monitoring, incidents, capacity, quota, and FinOps operation.
- **S12:** the operating model, ownership, versioning, material-change, and lifecycle routes.

Note:
Record a handoff as a dependency and named customer process. Do not repeat its assurance or monitoring work in this session.

---

## Entry and boundary

- **Entry:** bounded scope, customer control or supplier applicability, owners, and approved records location.
- **Boundary:** approved references only; no selection, deployment, prompt change, live-data query, configuration, incident action, or production approval.
- Unknown control or owner defers the affected decision.

---

## Step 1: Scope and applicability - 10 min

> **"What can the customer actually select, configure, version, or materially change?"**

Record the workload or asset population, control, owners, exclusions, and decision needed.

---

## Step 2: Assets and ownership - 15 min

> **"Which asset is approved for use, and who owns its operation?"**

Reference the model/provider, access path, instruction asset, version, record, and owner. Record gaps without copying sensitive content.

---

## Step 3: Versioning and change route - 20 min

> **"Which changes could invalidate the operating decision?"**

Classify material changes, name decision owners, record required evidence, and route S7 assurance work where needed.

---

## Step 4: Dependencies and lifecycle - 15 min

> **"What fails, changes, or ends outside this team's direct control?"**

Record capacity, quota, region, supplier, incident, rollback, deprecation, and retirement dependencies with owners and limits.

---

## Step 5: Supplier applicability - 10 min

> **"What evidence can the supplier provide, and what customer decision remains?"**

Mark customer-controlled, shared-control, supplier-managed, or unknown. Name the support, notice, escalation, and customer review routes.

---

## Step 6: Decide and hand over - 20 min

Approve, defer, or reject the operating model. Record limitations, backlog owners, review date, and S4, S7, or S11 handoffs.

Note:
Approval does not authorize a model selection, production change, service configuration, or prompt alteration.

---

## Verification and handoff

- [ ] Scope, applicability, owners, exclusions, and evidence location are recorded.
- [ ] Assets, versions, and ownership have approved references or visible gaps.
- [ ] Material-change and lifecycle routes have owners and dependencies.
- [ ] S4, S7, and S11 handoffs are distinct and named.
- [ ] Decision, limitations, backlog, and next review are customer-owned.
