# Implementation - CI/CD, policy as code, and controlled promotion

## Session scope

### What we will do

Promote **one immutable, gate-passing release** through protected nonproduction and production
environments. An authorized operator supplies `workflow_dispatch.release_sha`. The workflow proves
that the full SHA belongs to the protected default branch before it runs release content.

That SHA ties the gates, approvals, deployments, routing, release record, and manual restore to one
release.

### Why it matters

Code, AI configuration, gate results, approvals, and routing can drift between pipeline stages. This
workflow stops that drift. It also runs Session 11's known blocked tool-process case before Azure
preview or approval.

### Boundaries

GitHub Actions controls this promotion path. Four GitHub environments separate preview from apply.
Microsoft Entra validates their workload identities. Azure Resource Manager holds deployment state,
API Management holds routing state, and the approved release store holds the release record.

The workflow uses the existing [Session 05](../../05-governed-agent-baseline/implementation/README.md)
agent, [Session 07](../../07-apim-ai-gateway/implementation/README.md) route,
[Session 11](../../11-foundry-evaluations-quality-gates/implementation/README.md) release gate,
[Session 12](../../12-red-teaming-threat-defense/implementation/README.md) security-release
attestation, and [Session 13](../../13-observability-cost-operations/implementation/README.md) smoke
check. Those systems remain authoritative for their own state and records.

The control covers changes made through these workflows. It does not make an out-of-path deployment
safe or trigger automatic restore.

## Architecture

### Architecture at a glance

The full commit SHA is the release identity. Fixed digests bind the prompt, agent version, model
alias, APIM policy, evaluation inputs, and Bicep parameters to it. A changed component creates a new
release.

The workflow first proves default-branch lineage and runs the unit, evaluation, adversarial, and
observability gates. Preview jobs then use environment-scoped OIDC to run Bicep what-if. The apply
environments withhold their OIDC values until a reviewer approves the matching preview.

After both deployments pass, API Management moves the approved selector. The release store marks
the staged record approved only after routing succeeds. Manual restore reads an approved record,
previews the selector change, waits for production approval, and returns traffic to that selected
release.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Release identity | Full commit SHA plus fixed component digests | Every stage and restore name one release | Any correction requires a new release | The repository or release-unit boundary changes |
| Access | Separate preview and apply environments with exact OIDC subjects | What-if runs before approval; apply credentials stay withheld | Four trusts and environment protections must stay aligned | GitHub changes its plan features, environment model, or subject format |
| Recovery | Manual, production-approved restore from an approved release record | An owner checks the exact release and route before traffic moves | Restore needs an available authority and takes longer than automation | A tested automatic policy can make the same identity, approval, and health checks |

### Architecture guidance

- [Authenticate to Azure from GitHub Actions by OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
- [ARM template deployment what-if operation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-what-if)
- [Azure built-in roles for Privileged](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged)

## Before you start

Complete these items before facilitated work:

- Use the approved repository and protected default branch. Select an approved 40-character SHA
  reachable from that branch; do not store the selected SHA in its own commit.
- Confirm that release metadata binds that SHA to the prompt, immutable agent version, model alias,
  APIM policy, evaluation inputs, and both environment parameter files.
- Confirm the Session 11 release policy is enabled. Its temporary external baseline and candidate
  records must match the policy run IDs. The candidate passes, and the generated tool-process
  self-test returns BLOCK.
- Retrieve the confirmed Session 12 `security-release-attestation` into the approved temporary
  workspace. It must match the release agent and baseline/remediated versions, include external
  authorization and report locations, show lower aggregate attack success and per-risk
  non-regression, record prohibited actions at zero attack success, and contain no payload.
- Confirm the Session 13 smoke scripts check the same commit and live Application Insights workspace
  binding. The result must use distinct normal and failure trace IDs, wait for stable ingestion,
  separate tool and model failures, report no sensitive input, and retain no payload.
- Have the unit-check, routing, release/security-store, and parameter-file owners accept their files.
  The delivery owner records those decisions.

The protected `nonproduction` environment holds `SESSION13_SMOKE_URL`,
`SESSION13_SMOKE_FAILURE_URL`, `SESSION13_AI_RESOURCE_ID`,
`SESSION13_LOG_ANALYTICS_WORKSPACE_ID`, and the `SESSION13_SMOKE_BEARER_TOKEN` secret. Optional
timeout and retry variables override the 180-second and 15-second defaults.

Configure `nonproduction-preview`, `nonproduction`, `production-preview`, and `production`. Both
apply environments require reviewers and prevent self-review. Production also restricts deployment
refs and disables administrator bypass. Native secret scanning and push protection must be enabled.

Each stage service principal has one federated credential for preview and one for apply. Every
subject must exactly match the repository's current GitHub OIDC subject and environment. Assign only
Contributor, role ID `b24988ac-6180-42a0-ab88-20f7382dd24c`, at the exact environment resource-group
scope. Contributor supports deployment and what-if but cannot assign Azure roles.

For preflight, the GitHub administrator needs repository Administration: read and Secret scanning
alerts: read. The Entra administrator gives the operator temporary Directory Readers at tenant
scope. The operator also needs temporary Contributor at both exact resource-group scopes for
what-if. Expire or remove this human access after the ready check. The workload identities keep
their scoped Contributor assignments.

The release/security-store interface must retrieve the Session 11 and 12 temporary records and
support `Stage`, `Approve`, and `Retrieve` by exact release ID and SHA-256. `Retrieve` must never
return a staged record as a restore target.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/control-definition.json`](artifacts/control-definition.json) | The Session 14 validators, preflight scripts, and GitHub Actions workflows |
| Deployment | [`artifacts/github/promotion.yml`](artifacts/github/promotion.yml) | GitHub Actions and the release operator |
| Deployment | [`artifacts/github/restore-previous-release.yml`](artifacts/github/restore-previous-release.yml) | GitHub Actions and the production restore operator |
| Runtime | [`artifacts/pipeline/release-manifest.template.json`](artifacts/pipeline/release-manifest.template.json) | The promotion workflow and approved release store |
| Runtime | [`artifacts/pipeline/validate-release.ps1`](artifacts/pipeline/validate-release.ps1) | The GitHub Actions workflow and PowerShell-based release operator |
| Runtime | [`artifacts/pipeline/validate-release.sh`](artifacts/pipeline/validate-release.sh) | The Bash-based release operator |
| Deployment | [`artifacts/environments/nonproduction.parameters.json`](artifacts/environments/nonproduction.parameters.json) | The nonproduction preview and apply jobs |
| Deployment | [`artifacts/environments/production.parameters.json`](artifacts/environments/production.parameters.json) | The production preview and apply jobs |

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value in the [`artifacts` tree](artifacts/README.md). Decide:

1. The repository, protected default branch, approved full SHA, and full-SHA action revisions.
2. The tenant, stage workload client IDs, exact resource-group scopes, four federated credential
   names, and four observed OIDC subjects. Do not reconstruct a subject from an example.
3. The apply reviewers, prevent-self-review settings, production ref restriction, administrator
   bypass setting, and GitHub plan support.
4. The Bicep, APIM policy, unit, Session 11, Session 13, routing, and release-store source paths.
5. The immutable agent and component versions, `canary` or `blue-green` strategy, allowed selectors,
   release ID, and approved temporary workspace.

Stop before a change when:

- a sentinel remains; an action uses a floating tag; or a component uses `latest` or `current`;
- the SHA is outside the protected default branch, workflow content comes from another ref, or a
  digest can change between stages;
- a client secret, broad repository permission, inherited Azure assignment, or wider-than-resource-
  group workload role is present;
- an OIDC subject differs from the exact GitHub environment subject;
- secret scanning, push protection, required reviewers, prevent-self-review, the production ref
  rule, or disabled administrator bypass is unavailable or inaccessible;
- Session 11 records, the enabled policy, or the generated blocked test do not match the release;
- the Session 12 attestation is pending, unauthorized, incomplete, version-mismatched, missing its
  report location, worse on aggregate or any risk row, unable to block prohibited actions, or
  payload-bearing;
- the Session 13 check is missing, failed, for another commit or workspace, exposes sensitive input,
  retains payload, reuses trace IDs, or cannot show stable bounded ingestion;
- what-if contains unrelated deletion, replacement, scope drift, or unexplained expansion; or
- the existing Session 05 or 07 route cannot preview and restore the selected selector pair. Keep
  100% on the previous approved selector.

No AI-quality signal restores a release automatically.

## Implement

### 1. Complete the definitions and run decision preflight

Set the JSON values, parameter files, workflow paths, full action SHAs, and fixed versions. Then run:

```powershell
.\scripts\preflight.ps1 `
  -Phase Decisions `
  -ApprovedNonproductionScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ApprovedProductionScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ApprovedReleaseSha "<40-character-release-sha>"
```
```bash
./scripts/preflight.sh \
  --phase decisions \
  --approved-nonproduction-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --approved-production-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --approved-release-sha "<40-character-release-sha>"
```

This read-only phase checks unresolved decisions, repository lineage, workflow structure, fixed
versions, action pins, source paths, JSON, Bicep lint, and Bicep build.

### 2. Confirm the administrative gates

The GitHub and Entra administrators confirm the four environment protections and OIDC trusts, the
two exact Contributor assignments, environment variables, native secret controls, and absence of
Azure client secrets. Stop if the repository plan cannot expose a required protection.

### 3. Run ready preflight

Use the approved release/security-store interface to retrieve the Session 11 baseline and candidate
records and the Session 12 attestation into the approved temporary workspace. Pass their absolute
paths:

```powershell
.\scripts\preflight.ps1 `
  -Phase Ready `
  -ApprovedNonproductionScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ApprovedProductionScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ApprovedReleaseSha "<40-character-release-sha>" `
  -BaselineRecordPath "<temporary-session11-baseline-result.json>" `
  -CandidateRecordPath "<temporary-session11-candidate-result.json>" `
  -SecurityReleaseAttestationPath "<temporary-session12-attestation.json>"
```
```bash
./scripts/preflight.sh \
  --phase ready \
  --approved-nonproduction-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --approved-production-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --approved-release-sha "<40-character-release-sha>" \
  --baseline-record-path "<temporary-session11-baseline-result.json>" \
  --candidate-record-path "<temporary-session11-candidate-result.json>" \
  --security-release-attestation-path "<temporary-session12-attestation.json>"
```

Ready repeats the local checks, reads GitHub and Entra configuration, verifies both role scopes, and
runs both Bicep what-if operations. It rejects repository paths and files outside the approved
temporary workspace. It changes no resources.

The platform owner approves both previews. Stop on any unexplained result.

### 4. Run the permitted promotion

Install the reviewed promotion and restore workflows through the normal repository change path
before live delivery. Dispatch **Controlled AI release promotion** with the approved `release_sha`
and `evaluation_record=candidate`.

The workflow:

1. proves the SHA belongs to the protected default branch, checks it out, and rechecks the workflow,
   pins, fixed digests, secret controls, unit result, Session 11 gate, and Session 12 attestation;
2. runs the generated blocked-tool-process self-test before Azure;
3. runs nonproduction what-if, waits for `nonproduction` approval, deploys, and runs Session 13 smoke;
4. rechecks digests, runs production what-if, waits for `production` approval, and deploys the same
   release; and
5. stages the release record, moves the approved selector, then approves the record. If finalization
   fails, leave the record staged and use the approved restore workflow.

## Confirm the result

Run both paths, then pause for the delivery owner.

### Intended path

```powershell
.\scripts\verify.ps1 `
  -Check Intended `
  -ReleaseSha "<40-character-release-sha>" `
  -PromotionRunId <github-actions-run-id>
```
```bash
./scripts/verify.sh \
  --check intended \
  --release-sha "<40-character-release-sha>" \
  --promotion-run-id <github-actions-run-id>
```

The run must show the selected SHA and digests through both deployments. All behavioral gates pass
before Azure. Each apply identity stays withheld until its preview is approved. Routing succeeds
before the release record becomes approved.

### Blocked/failure path

Dispatch the same workflow with
`evaluation_record=generated-blocked-tool-process-self-test`, then run:

```powershell
.\scripts\verify.ps1 `
  -Check Blocked `
  -ReleaseSha "<40-character-release-sha>" `
  -PromotionRunId <github-actions-run-id>
```
```bash
./scripts/verify.sh \
  --check blocked \
  --release-sha "<40-character-release-sha>" \
  --promotion-run-id <github-actions-run-id>
```

The validation job must return BLOCK. No Azure preview, apply approval, deployment, routing change,
or release-record approval may run.

### Delivery-owner checkpoint

The delivery owner confirms the intended run reached each apply environment after its matching
preview, while the blocked run stopped before Azure. If either sequence differs, keep the previous
approved selector at 100% and correct the workflow.

## After implementation

| What remains | Owner |
|---|---|
| Promotion, restore, action pins, and release-record continuity | Release owner |
| GitHub environment protection and OIDC trust | GitHub and Entra administrators |
| Bicep inputs, exact Azure scopes, and what-if review | Platform owner |
| Session 11 evaluation gate and Session 12 security gate | Quality and security owners |
| Session 13 smoke interface | Observability owner |
| APIM selectors and routing control | Gateway owner |
| Permitted and blocked checkpoint | Delivery owner |

GitHub, Azure, Microsoft Foundry, Application Insights, the approved release platform, and the
security and change systems retain their native records. Do not copy runtime records into this
repository.

To restore, dispatch **Restore previous AI release** with the exact approved release ID and recorded
SHA-256. Start with `dry_run=true`. The workflow validates the release digest and
`implementationSession` marker, previews the selector change, and waits for production approval.
Rerun with `dry_run=false` to move only the stable selector to that approved immutable release.

Restore preserves current and older code, prompt, agent, model, APIM, evaluation, and deployment
versions. It does not delete shared state. Use these workflows only for the approved repository,
four GitHub environments, two resource-group scopes, and routing selectors recorded in the control
definition.
