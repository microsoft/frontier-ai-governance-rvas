---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 02</p>

# Landing-zone guardrails with Azure Policy

**240 minutes · Stage first, enforce second**

---

## Control objective

> At the approved sandbox resource group, Azure Policy denies ARM changes that use blocked locations or miss required tags.

### Session result

- Current built-ins supply the implementation inputs.
- One initiative and one narrow assignment remain in operation.
- One JSON source supplies required tags to the definition and assignment.
- The cloud platform owner reviews live Policy Insights findings and Azure Policy exemptions.
- The change authority approves promotion to `Default`.
- The live state matches the approved scope and policy references.

Policy Insights reports existing-resource compliance. The assignment does not fix existing resources or cover controls outside these two rules.

<!-- Notes: Keep the live assignment at resource-group scope. Wider promotion is outside this timed core. -->

---

## Implementation outcomes

1. Resolve current built-ins for allowed locations and required resource tags.
2. Deploy a reusable initiative and stage it at one approved sandbox scope.
3. Load required tags from one implementation JSON source.
4. Review live Policy Insights state before change-authority approval.
5. Confirm the live scope, enforcement mode, locations, tags, and references.

---

<!-- _class: section-divider -->

## Why it matters

Staging on one owned resource group shows the likely impact before deny mode is turned on. The owner can fix exemptions before the change authority promotes the policy.

---

<!-- _class: two-column -->

## Architecture overview

<div class="columns">
<div>

### Where the rules can act

```text
AI workloads
├── Sandbox
├── Development
└── Production
```

This session assigns policy only to the Session 01 sandbox resource group. Other environments need
their own parameters, owner, enforcement decision, and exemptions.

</div>
<div>

### What happens to a change

![Azure Policy icon](assets/icons/microsoft/azure-policy.svg)

- The assignment applies only to one sandbox resource group.
- Azure checks the requested location and required tags.
- `DoNotEnforce` records the result without denying the change.
- After owner review, `Default` denies a request that fails either rule.

Azure Policy holds the control state. Policy Insights holds evaluated compliance.

</div>
</div>

---

## What each policy object does

<div class="cards">
<div class="card">

### Initiative

Groups the current Microsoft built-ins for allowed locations and required tags. Stable reference
IDs keep each rule identifiable.

</div>
<div class="card">

### Assignment

Applies the parameters at one resource group. `DoNotEnforce` reports likely failures without
denying them; approved `Default` enforcement denies a failing request.

</div>
<div class="card">

### Live state

Azure Policy records the assignment and exemptions. Policy Insights reports evaluated compliance
for resources already in scope.

</div>
</div>

---

## Promotion path

![Azure Policy state machine from built-in resolution through staged assignment, approval, enforcement, and operation](assets/diagrams/policy-promotion.svg)

<!-- Notes: New assignments take time to propagate. A stale first policy-state query is a stop condition. Point out that enforcement mode and observed compliance are separate facts. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Packaging | One initiative that refers to current Microsoft built-ins | Their IDs and effects must be checked before deployment |
| Scope | Exact Session 01 sandbox resource group | Sibling groups and wider scopes remain outside this control |
| Rollout | `DoNotEnforce`, owner review, then `Default` | Evaluation time can delay enforcement |

Sessions 03 and 04 inherit these checks inside the assigned group. Wider promotion needs its own parameters, owner, and restore plan.

---

## Built-ins are implementation inputs

1. Query the tenant-visible Azure Policy catalog.
2. Require one nondeprecated match for each display name.
3. Inspect the rule, parameters, version, and `Deny` effect.
4. Pass the resolved IDs to Bicep in the current shell.
5. Resolve again before the next implementation.

**Do not copy a policy GUID from the slide deck.**

Source: [Microsoft Azure Policy built-in policy catalog](https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies).

---

## Implementation path

Sandbox preflight requires sandbox values only. Production placeholders do not block this path.

1. **Resolve** `Allowed locations` and `Require a tag on resources`.
2. **Preview and deploy** one custom initiative with stable reference IDs.
3. **Assign** it to the approved sandbox resource group in `DoNotEnforce`.
4. **Inspect** current policy state for resources already in scope.
5. **Reference** the customer change or risk record; keep exemption state in Azure Policy.
6. **Keep** `Default` in operation after the owner review and change-authority approval.

---

<!-- _class: implementation -->

## Apply the Azure Policy controls

**Timebox:** 150 minutes

Put two preventive controls on evaluated ARM changes at the live resource-group assignment.

- **Operator access:** Resource Policy Contributor on the approved sandbox subscription
- **Safe boundary:** one approved sandbox resource group
- **First assignment:** `DoNotEnforce`
- **Review:** cloud platform owner reads Policy Insights and Azure Policy exemption state
- **Approval:** change authority decides whether to promote
- **Live state:** marked initiative and assignment with `Default`
- **Existing estate:** inspect resources already in scope

---

<!-- _class: decision -->

## Stop conditions for the change

- Read the wait period from the customer change record before evaluating.
- If policy state remains stale after that period, keep `DoNotEnforce`.
- Record the cloud platform owner and next review date, then stop before confirmation.

| Gate | Stop when |
|---|---|
| Scope | The resource group is shared, unowned, or affected by an unclear inherited assignment |
| Enforcement | A built-in changed, is deprecated, or no longer uses the expected rule and effect |
| Exemption | The live exemption is broader than the approved scope or lacks an expiry and customer risk reference |
| Promotion | The cloud platform owner has not reviewed findings and exemptions, the change authority has not approved, or restore ownership is not ready |

Production and management-group promotion require separate authorization.

---

## Confirm the current result

Run one visible check after the operating-state decision.

| Inspect | Expected state |
|---|---|
| Assignment path | Approved resource-group scope |
| Enforcement | `Default`; `DoNotEnforce` means the session is incomplete |
| Session marker | `02-landing-zone-guardrails` on initiative and assignment |
| Required tags | Assignment metadata and initiative references match `guardrail-settings.json` |
| Initiative references | One location reference plus one reference per required tag |

Read the assignment and initiative state in the console. The check creates nothing and writes no separate output package.

---

<!-- _class: decision -->

## Keep policy state in Azure

| System | Authoritative state |
|---|---|
| Azure Policy | Definition, assignment, enforcement mode, and exemption |
| Policy Insights | Current compliance result |
| Customer change or risk system | Approval, risk acceptance, owner, and review date |
| Repository | Deployable policy, one tag source, restore guidance, and external references |

Source: [Azure Policy exemption structure](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/exemption-structure).

---

<!-- _class: two-column -->

## What remains after the session

<div class="columns">
<div>

### Kept

- Subscription initiative
- Sandbox assignment
- Sandbox parameter files
- Required-tag source
- Customer change and risk pointers

</div>
<div>

### Restore or remove

First return the assignment to `DoNotEnforce`.

If removal is approved, the guarded script deletes only marked policy objects and refuses to remove an initiative that another assignment still uses.

</div>
</div>

---

## Recap and next dependency

- **Control:** current built-ins grouped in a customer-owned initiative.
- **Scope:** one approved sandbox resource group.
- **Promotion:** the cloud platform owner reviews live findings and exemptions; the change authority approves `Default`.
- **Confirmation:** live state matches the expected locations, tags, effects, and references.
- **Next:** [Session 03](../03-identity-privileged-access/) gives people and workloads narrow, time-bound identities.

---

<!-- _class: closing -->

# Thank you!
