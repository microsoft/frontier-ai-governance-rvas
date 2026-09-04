---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 12</p>

# CI/CD, policy as code, and controlled promotion

240 minutes · Promote one fixed release, test the blocked path, and keep restore ready

<!-- Notes: Observability and cost controls made the service operable. This promotion control governs how a release reaches production. -->

---

## Why it matters

**Problem.** Code, AI configuration, gate results, approvals, and routing can drift apart across
pipeline stages, so a gate that passed somewhere doesn't guarantee what's actually running in
production.

**Solution.** Tying every stage to one commit SHA stops that drift, and the workflow reruns Session
09's known blocked tool-process case before Azure sees a preview or approval.

<!-- Notes: The release is one linked unit. A changed component creates a new release. -->

---

<!-- _class: two-column -->

## Architecture

<div class="columns">
<div>

**Before Azure**

GitHub verifies branch lineage, fixed digests, action pins, secret controls, the agent portfolio decisions, and the release gates.

**Preview and apply**

Microsoft Entra validates four exact environment subjects. Azure Resource Manager previews before each protected approval.

</div>
<div>

**Route and record**

API Management moves the approved selector. The release store approves the staged record only after routing succeeds.

**Restore**

A separate production-approved workflow retrieves one approved record and moves only the stable selector.

</div>
</div>

<!-- Notes: GitHub, Entra, Azure, API Management, and the release store remain authoritative for their own state. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

![Microsoft Entra workload identity](assets/icons/microsoft/microsoft-entra-workload-id.svg)

| Decision | Required choice | Limit |
|---|---|---|
| Release identity | Full commit SHA plus fixed component digests | A correction starts a new release |
| Workload access | Two stage service principals, each with preview and apply OIDC trust | Exact observed GitHub subjects only |
| Azure role | Contributor `b24988ac-6180-42a0-ab88-20f7382dd24c` | Exact environment resource-group scope; no inherited assignment |
| Agent portfolio | Approved framework path and a finished duplicate review | A framework exception needs an approval reference and a support owner |
| Recovery | Manual restore from an approved release record | Production approval and exact ID plus SHA-256 |

Human preflight access is temporary: Directory Readers at tenant scope and Contributor at both exact resource-group scopes. Remove or expire it after the ready check.

<!-- Notes: The workload identities keep their scoped Contributor assignments for pipeline operation. -->

---

## Stop before the change when

- A `__REQUIRED_*__` value, floating action tag, mutable alias, or client secret remains.
- The SHA is outside the protected default branch or a digest can change between stages.
- An OIDC subject, role assignment, environment variable, or approved scope does not match.
- Secret scanning, push protection, reviewers, prevent-self-review, the production ref rule, or disabled administrator bypass cannot be verified.
- evaluation, security, or promotion records do not match the immutable release or fail their checks.
- The framework path sits outside the approved list without an approval reference, or the duplicate review points at an existing agent.
- What-if shows unrelated deletion, replacement, scope drift, or unexplained expansion.
- The existing route cannot preview and restore the selected selector pair.

Keep 100% on the previous approved selector when a gate is uncertain.

<!-- Notes: An inaccessible protection is not a passing protection. -->

---

<!-- _class: implementation -->

## Implementation path

**Total session: 240 minutes. Guided implementation and checks: about 180 minutes.**

1. Confirm the release unit, owners, framework path, duplicate review, source paths, four environments, OIDC subjects, and exact Azure scopes.
2. Run decision preflight for repository lineage, pins, fixed versions, JSON, Bicep lint, and build.
3. Run ready preflight with the temporary evaluation records and security attestation.
4. Review both Bicep what-if results.
5. Run the permitted promotion through nonproduction and production.
6. Run the generated blocked tool-process path.
7. Pause for the delivery-owner checkpoint and restore handoff.

The remaining time covers the briefing, live decisions, approvals, and operating handoff.

<!-- Notes: Both preflight phases are read-only. The guide contains paired PowerShell and Bash commands. -->

---

## Permitted and blocked paths

| Path | Dispatch | Expected sequence |
|---|---|---|
| Permitted | Approved `release_sha`; `evaluation_record=candidate` | Gates → nonproduction preview and approval → deploy and smoke → production preview and approval → deploy → route → approve release record |
| Blocked | Same SHA; `evaluation_record=generated-blocked-tool-process-self-test` | The evaluation gate returns BLOCK in validation; no Azure preview, approval, deployment, route, or record approval |

The permitted path runs the generated blocked self-test before Azure as an internal control. The separate blocked dispatch proves the workflow cannot cross the Azure boundary after that result.

<!-- Notes: Extended mode exists because the delivery owner needs to observe both sequences. -->

---

<!-- _class: decision -->

## Delivery-owner checkpoint

Confirm:

- the selected SHA and fixed digests survived both stages;
- every behavioral gate passed before Azure;
- each apply identity stayed withheld until its matching preview was approved;
- nonproduction smoke verified the commit and live Application Insights workspace binding;
- routing succeeded before the release record became approved; and
- the blocked run stopped before Azure preview or approval.

If the sequence differs, keep the previous release at 100% and correct the workflow.

<!-- Notes: The release, quality, security, production-approval, routing, and delivery authorities make only their assigned decisions. -->

---

<!-- _class: two-column -->

## Operate and restore

<div class="columns">
<div>

### Keep in operation

- Release owner: workflows, pins, release records
- GitHub and Entra admins: protection and federation
- Platform owner: Bicep, scopes, what-if review
- Quality, security, and observability owners: release gates
- Gateway owner: approved selectors

</div>
<div>

### Restore

1. Select an approved release ID and recorded SHA-256.
2. Dispatch with `dry_run=true`.
3. Validate the digest and `implementationSession` marker.
4. Review the selector preview and approve production.
5. Rerun with `dry_run=false`.

Restore moves only the stable selector. It preserves current and older versions.

</div>
</div>

<!-- Notes: No AI-quality signal triggers restore automatically. Native systems keep their own records. -->

---

<!-- _class: closing -->

# Thank you!
