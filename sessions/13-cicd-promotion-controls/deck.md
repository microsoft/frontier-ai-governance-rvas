---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 13</p>

# CI/CD, policy as code, and controlled promotion

**300 minutes - One fixed release, two controlled stages**

<!-- Notes: Session 12 made the service operable. This session keeps promotion repeatable and limited. -->

---

## Control objective

> Promote one fixed, gate-passing release through protected nonproduction and production environments, with approval, deployment, routing, and restore tied to the same commit SHA.

### Release questions

- Which release is moving?
- Which gates can stop it?
- Who may release it to production?
- How does traffic return to the previous release listed in the release record?

<!-- Notes: The unit is a linked release, not a collection of independently mutable settings. -->

---

## Why it matters

A release is safe to promote only while its code, AI configuration, gate results, approvals, and traffic change describe the same release unit.

The protected workflow keeps that relationship easy to inspect. It also stops Session 10's known tool-process regression before any Azure preview or approval.

<!-- Notes: The SHA is the release spine from input through restore. -->

---

## Implementation outcomes

1. Bind one fixed release to the protected `release_sha`.
2. Make Azure deployment depend on the Session 10 gate and the other approved release checks.
3. Require protected nonproduction and production approvals after their what-if previews.
4. Bind both deployments, routing, and the approved manifest to the same SHA.
5. Confirm the allowed path, blocked path, and previous-release restore reference.

<!-- Notes: Extended mode is deliberate because both paths protect the production checkpoint. -->

---

## Focused-route baseline

Each substitute needs live state, an owner, and the result shown here.

| Control | Live state | Required result |
|---|---|---|
| Fixed agent | Commit-bound prompt, agent, model alias, Bicep parameters | Platform owner deploys the approved release to nonproduction |
| Gateway | Versioned APIM policy, stable and candidate selectors, restore path | Gateway owner previews only the selectors in the routing contract and restores the previous one |
| Evaluation | Definition, active thresholds, enabled release policy, baseline, candidate, generated self-test | Quality owner sees the matching candidate pass and the tool-process self-test return BLOCK |
| Red-team | Confirmed before/after report for the same agent and fixed version | Security owner sees lower attack success, no risk category getting worse, blocked actions, and all five privacy flags set to false |
| Observability | Logging contract and fixed smoke result | Observability owner sees complete trace, separated failures, no sensitive input |

<!-- Notes: A focused route cannot replace these rows with a general equivalence statement. -->

---

<!-- _class: section-divider -->

# Promote one linked release

The protected workflow input binds code and AI configuration to one commit and set of digests.

<!-- Notes: Drift between stages invalidates the promotion. -->

---

## Architecture overview

The full commit SHA, the exact identifier for one Git commit, is the release identity. Every step
carries it forward. A mismatch starts a new release.

| Stage | Decision or action | System of record |
|---|---|---|
| Before Azure | Prove default-branch lineage and require all release gates to pass | GitHub Actions and the linked gate systems |
| Preview | Exchange the exact environment OIDC subject, then run Bicep what-if | Microsoft Entra and Azure Resource Manager |
| Apply | Release credentials after approval and deploy the same SHA | Protected GitHub apply environments and Azure Resource Manager |
| Route and record | Move the approved selector, then finalize the linked manifest | Azure API Management and the approved release store |

<!-- Notes: A mismatch means the team creates a new release. GitHub owns workflow execution and approvals. Microsoft Entra owns workload trust. Azure owns deployed state, API Management owns routing, and the release store owns the final manifest. -->

---

## Controlled promotion flow

<!-- _class: diagram -->

![One commit moves through repository checks and release gates before deployment. Failed checks stop the release, and restore returns to the previous approved version.](assets/diagrams/controlled-promotion-flow.svg)

<!-- Notes: The release SHA stays the same through every preview, approval, deployment, route change, and manifest record. The two red exits stop before the Azure change boundary. -->

---

## What this means

Failed gates leave Azure unchanged. Manual restore uses the previous approved manifest and its own
production approval.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Why | Requirement |
|---|---|---|---|
| Release identity | Full commit SHA with fixed component digests | Every stage and restore name one release | A corrected component starts a new release |
| Access boundary | Separate preview and protected apply environments with exact OIDC subjects | What-if runs before approval; apply credentials stay withheld | Four environment trusts must remain aligned with Microsoft Entra |
| Recovery | Manual, production-approved restore of the previous release | An owner checks the manifest and selector before traffic moves | Restore is slower and requires an available authority |

The approved manifest links the selected release to its deployments, routing result, and previous release.

<!-- Notes: Detailed runtime records stay in their source systems. The release manifest links them rather than copying them. -->

---

<!-- _class: decision -->

## Decision gate 1 - Repository and action integrity

### Required

- approved repository and protected release ref
- full 40-character release SHA held outside the release commit
- full-SHA revisions for every action
- `contents: read` by default; `id-token: write` only on environment jobs
- fixed component versions

### Stop

Floating tags, `latest`, mutable aliases, a release SHA outside the protected default branch, or a checkout that differs from the protected `release_sha` input.

<!-- Notes: A familiar action tag is still mutable; pin the reviewed commit. -->

---

<!-- _class: decision -->

## Decision gate 2 - Identity and scope

![Microsoft Entra workload identity](assets/icons/microsoft/microsoft-entra-workload-id.svg)

**Four environments · Four specific subjects · Two stage identities**

Record the subject issued for this repository:

- name-based: `repo:owner/repository:environment:<environment>`
- immutable default after **2026-07-15**: `repo:owner@ID/repository@ID:environment:<environment>`

Each stage service principal has built-in **Contributor** (`b24988ac-6180-42a0-ab88-20f7382dd24c`) only at its environment resource group.

<!-- Notes: Use the repository's actual OIDC format. Human GitHub and Entra admin access expires after ready preflight. -->

---

<!-- _class: decision -->

## Decision gate 3 - Apply protection

The `nonproduction` and `production` apply environments require reviewers and prevent self-review. The `production` environment also requires:

1. an approved branch or tag restriction;
2. disabled administrator bypass; and
3. variables withheld until protection rules pass.

**Plan and repository visibility are preflight facts, not assumptions.**

<!-- Notes: If the plan does not expose a required setting, stop and choose an approved boundary. -->

---

## Native secret boundary

Promotion stops unless GitHub reports:

- native secret scanning is enabled;
- push protection is enabled; and
- secret-scanning settings and alerts are accessible to the workflow.

No fallback third-party scanner is added for this session.

<!-- Notes: An inaccessible setting is not treated as a passing setting. -->

---

## Bicep safety gates

![Azure Policy](assets/icons/microsoft/azure-policy.svg)

For the same entrypoint and parameter contract:

1. lint;
2. build;
3. nonproduction what-if in `nonproduction-preview`;
4. approval in `nonproduction`, then deployment;
5. production what-if in `production-preview`; and
6. approval in `production`, then deployment.

Stop on unrelated deletion, replacement, scope drift, or unexplained expansion.

<!-- Notes: What-if predicts changes; it does not make ambiguous output safe. -->

---

## Quality and safety gates remain independent

| Gate | Required result |
|---|---|
| Unit | Customer script succeeds for the matching commit |
| [Session 12](../12-observability-cost-operations/) smoke | Operational executable, logging-bound commit, live workspace binding, distinct trace IDs, fixed-time polling, no sensitive input or stored payload |
| [Session 10](../10-foundry-evaluations-quality-gates/) evaluation | Aggregate quality, tool-process, and safety thresholds pass |
| [Session 11](../11-red-teaming-threat-defense/) red-team | Confirmed report and matching review record, fixed version binding, lower ASR, no risk category getting worse, blocked actions at zero ASR |

Any blocking failure prevents the production job.

<!-- Notes: Service health does not substitute for behavioral quality or red-team resilience. -->

---

## Use the existing session controls

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

### [Session 10](../10-foundry-evaluations-quality-gates/)

Use the callable `release-gate.py` with its threshold policy, evaluation definition, baseline, candidate, and required tool-process block case.

Session 13 enforces it in promotion.

### [Session 11](../11-red-teaming-threat-defense/)

Consume the confirmed payload-free before/after report and its version-matched risk/change review record. SOC delivery stays a separate result.

### [Session 12](../12-observability-cost-operations/)

Call the Session 12 `smoke.ps1` executable with fixed arguments.

Session 12 polls log arrival with a fixed timeout and retry interval.

Session 13 requires at least three attempts and a timeout that allows two retry intervals. The Bash path remains paired for operator use.

<!-- Notes: No arbitrary shell strings and no copied gate implementation. -->

---

## Routing is conditional

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

Use `canary` or `blue-green` only when the existing [Session 05](../05-governed-agent-baseline/) or [Session 06](../06-apim-ai-gateway/) path already supports:

- fixed candidate and stable selectors;
- a limited traffic move;
- the previous approved release; and
- a preview or dry run.

Otherwise: **stop and keep 100% on the previous approved selector.**

<!-- Notes: Do not introduce a routing platform merely to complete this session. -->

---

<!-- _class: implementation -->

## Configure and test controlled promotion

Before the session, the unit-check owner accepts the unit script, the routing owner accepts the routing script, and the release owner accepts the release-store script.

The platform owner accepts both parameter contracts. GitHub and Entra administrators accept protections, OIDC trust, and roles. The delivery owner records these decisions in the customer's normal delivery or change record.

Live delivery runs the allowed and blocked paths, then pauses for the delivery owner.

**Timebox: 115 minutes**

1. Resolve required decisions and run decision preflight.
2. Confirm environment protection, the four specific OIDC subjects, both Contributor assignments, and secret controls.
3. Confirm the reviewed promotion and restore workflows are installed.
4. Run complete preflight; the platform owner approves both what-if results.
5. Run the intended and blocked promotion paths.

<!-- Notes: The first preflight occurs before administrative state changes. -->

---

## Preflight has two read-only phases

### Decisions

Files, decision sentinels, approved scopes, repository metadata, workflow enforcement, fixed versions, action pins, source paths, Bicep lint and build.

### Ready

GitHub plan and environments, native secret controls, Session 12 environment variable and optional secret names, four specific OIDC subjects, both resource-group Contributor assignments, and both deployment what-if operations.

Neither phase deploys or changes a resource.

<!-- Notes: Ready repeats local checks before it reads external configuration. -->

---

## Promotion job order

1. **Validate** - repository, pins, secrets, unit, evaluation, red-team
2. **Nonproduction preview** - OIDC, lint/build, what-if
3. **Nonproduction apply** - reviewer approval, deploy, smoke
4. **Production preview** - OIDC, digest recheck, what-if
5. **Production apply** - reviewer approval, deploy
6. **Stage, route, finalize** - keep the manifest unapproved until routing succeeds

GitHub `needs` puts each approval after its preview.

<!-- Notes: A failed nonproduction job leaves the production job skipped. -->

---

## Intended-path check

Dispatch with the approved `release_sha` and `evaluation_record=candidate`.

Expected:

- matching commit and digests survive both stages;
- the commit is reachable from the protected default branch before release content runs;
- the behavior gates pass before Azure deployment;
- each apply OIDC token waits behind its environment approval;
- the reviewer releases only the fixed version listed in the manifest;
- the manifest remains staged until routing reports success;
- the release store approves it only after routing succeeds;
- existing routing moves only the approved selector; and
- the manifest links the previous approved release.

<!-- Notes: If finalization fails, run approved restore for the previous selector and leave the staged manifest unapproved. -->

---

## Blocked/failure-path check

Dispatch the same workflow with:

`evaluation_record=generated-blocked-tool-process-self-test`

The workflow runs [Session 10](../10-foundry-evaluations-quality-gates/)'s stable in-memory tool-process self-test.

Expected:

1. the generated gate check returns BLOCK;
2. the validation job fails;
3. no Azure preview or apply approval is requested; and
4. both deployments and routing are skipped.

<!-- Notes: The self-test exercises the generated in-memory blocked case. -->

---

<!-- _class: decision -->

## Delivery-owner checkpoint

The release policy lists who decides release, quality, security, production approval, routing, and delivery questions.

Each person makes only their required live decision.

Pause after both paths.

The delivery owner confirms:

- the intended run reached production only after every gate and reviewer action;
- the blocked run stopped before any Azure preview or approval; and
- the previous approved selector remained available throughout.

If any sequence differs, keep 100% on the previous release and correct the workflow.

<!-- Notes: The owner decides whether the control sequence is safe to keep in operation. -->

---

## Operational promotion control

One customer-owned delivery control:

- no client secrets;
- one release through preview and apply environments;
- workflow and metadata enforced before deployment;
- independent quality, safety, and smoke gates;
- protected production approval;
- conditional existing routing;
- linked release manifest; and
- manual restore to the previous release.

<!-- Notes: Keep this workflow as the customer-owned path for later releases. -->

---

## Live state and ownership

| Owner | Operational responsibility |
|---|---|
| Release owner | Workflows, action pins, manifest continuity |
| GitHub and Entra admins | Environment protection and OIDC trust |
| Platform owner | Bicep entrypoint, parameters, approved Azure scopes, both what-if approvals |
| Quality and security owners | Session 09 and 11 gate health |
| Observability owner | Session 12 smoke interface |
| Gateway owner | Existing routing selectors |
| Delivery owner | Intended and blocked checkpoint |

<!-- Notes: Native systems retain their own operational records. -->

---

## Manual restore

Dispatch the restore workflow against the approved release store with:

- approved release ID;
- recorded manifest SHA-256; and
- `dry_run=true` first.

After production environment approval, validate the marker and digest, preview, then move only the stable selector. Preserve current and older versions. Delete nothing broad.

<!-- Notes: AI-quality signals can alert owners but cannot trigger this workflow automatically. -->

---

## Recap

- One linked fixed release
- GitHub OIDC without client secrets
- Bicep lint, build, and two what-if gates
- Native secret, unit, smoke, evaluation, and red-team controls
- Protected production approval
- Conditional canary or blue-green routing
- Permitted and blocked paths before owner checkpoint
- Manual restore to the previous release with existing versions

<!-- Notes: The previous approved release remains the safe default whenever a gate is uncertain. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Close on ownership: release integrity is a continuous delivery property. -->
