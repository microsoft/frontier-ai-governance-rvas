# Implementation - CI/CD, policy as code, and controlled promotion

## Session scope

### What we will do

Promote **one immutable, gate-passing release** through protected nonproduction and production
environments. An authorized operator supplies `workflow_dispatch.release_sha`. The workflow proves
that SHA is reachable from the protected default branch before release content runs. The same SHA
ties approval, both deployments, routing, the approved release record, and manual restore together.

### Why it matters

A release is safe to promote when its code, AI configuration, gate results, deployment approvals,
and traffic change still describe the same immutable unit. The workflow makes that relationship
easy to inspect and stops Session 11's known tool-process regression before Azure preview or
approval.

### Boundaries

GitHub Actions runs the promotion sequence. The four protected GitHub environments hold the required
approvals and environment-scoped credentials. Microsoft Entra validates federated workload
identities. Azure Resource Manager reports deployment state, and API Management reports the
selected route. Foundry, Application Insights, Defender, and the approved release store keep their
evaluation, telemetry, security, and release records.

The workflow uses the existing [Session 05](../../05-governed-agent-baseline/implementation/README.md)
agent and [Session 07](../../07-apim-ai-gateway/implementation/README.md) routing path. It does not
create another delivery platform or add routing where the current platform lacks a safe preview and
restore path. Session 11 creates the callable eligibility gate. This session makes promotion
depend on it. Session 15 may use the protected release path for its approved secondary deployment.

## Architecture

### Architecture at a glance

The full commit SHA, the exact identifier for one Git commit, identifies the release. The protected
workflow uses it for every check, preview, approval, deployment, route change, and release record.
Fixed component digests, cryptographic fingerprints of the other release parts, associate those
parts with the same release. If anything changes between stages, create a new release instead of
quietly promoting a different unit.

The workflow makes decisions before it changes Azure. It first proves that the SHA is reachable
from the protected default branch. Unit checks then run with the evaluation, adversarial, and
observability gates from Sessions 10-12. Any failed gate ends the run before the Azure change
boundary.

Preview and apply use different GitHub environments. A preview job presents its exact OIDC subject,
the identity string for that repository and environment, to obtain an environment-scoped Microsoft
Entra workload identity. It then runs Bicep what-if. The apply environments withhold credentials
until a reviewer approves the preview. Azure Resource Manager deploys the same release, and API
Management moves the approved selector after both deployments pass.

Each system keeps the records or state it produces. GitHub records workflow execution and
environment approvals. Microsoft Entra stores federated credentials and validates workload trust.
Azure Resource Manager reports deployed state, and API Management reports routing. The approved
release store keeps one small release record, written after each successful production promotion
and read before manual restore. It links native records without copying them.

The workflow controls changes made through this promotion path. Manual restore follows a separate,
production-approved workflow. It reads the selected approved release record, checks the target, and
returns the stable selector to that release. Session 15 uses this protected path to deploy an
approved secondary region.

[`artifacts/github/promotion.yml`](artifacts/github/promotion.yml) implements the promotion path.
[`artifacts/github/restore-previous-release.yml`](artifacts/github/restore-previous-release.yml)
implements restore. Both use the fixed fields in
[`artifacts/pipeline/release-manifest.template.json`](artifacts/pipeline/release-manifest.template.json)
to identify the release.

### Design choices and tradeoffs

| Decision | Chosen approach | Why this shape helps | What it requires | Revisit when |
|---|---|---|---|---|
| Release identity | Check out the selected full commit SHA, then use it for every later gate. Deployment, routing, and the release record use the same identity. | A mismatch exposes stage drift, and restore can name the exact release. | A corrected component requires a new release. Do not promote mutable aliases. | The repository boundary changes or the team defines a different release unit. |
| Preview and apply access | Use separate protected preview and apply environments, each with an exact OIDC subject. | What-if runs before approval. Apply credentials remain unavailable until the protection rules pass. | Four environment subjects and their protections must stay aligned with Microsoft Entra. | GitHub changes its subject format, plan features, or environment model. |
| Recovery | Restore a selected approved release through a manual, production-approved workflow. | An owner checks the release record and route before production traffic moves. | Restore authority must be available. Recovery is slower than automatic rollback. | A tested automatic policy can make the same identity and release-record checks, then verify health and routing. |

### Architecture guidance

- [Authenticate to Azure from GitHub Actions by OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
  covers Microsoft Entra workload identity federation without a client secret.
- [ARM template deployment what-if operation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-what-if)
  explains preview behavior and required resource operations.
- [Azure built-in roles for Privileged](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/privileged)
  defines the Contributor boundary used by the stage identities.

## Before you start

1. Use the exact customer repository. Keep the reviewed workflow on the protected default
   branch, and select the approved 40-character release SHA through the customer’s GitHub release
   and deployment process. The SHA must be reachable from that branch. The release commit itself
   must not store the SHA.
2. Complete Sessions 05, 06, 10, 11, and 12. If the earlier controls were implemented outside
   this series, confirm the required state in the table below before installing the workflow.
3. Confirm the approved [Session 11](../../11-foundry-evaluations-quality-gates/implementation/README.md) threshold policy and release policy are usable by the callable
   `sessions/11-foundry-evaluations-quality-gates/implementation/scripts/release-gate.py`.
   The schema-version 2 release policy must set `gate.state=enabled`,
   `gate.decision=approved`, a valid `gate.decisionDate`, the exact activation fields, and
   `requiredEnforcementOption=--require-enabled`. Its baseline and candidate run IDs must match the
   threshold policy and temporary external result records. Session 11 supplies the gate and its
   documented PASS/BLOCK behavior. Its stable blocked self-test must return BLOCK. This workflow runs both
   checks.
4. Confirm the approved release/security-store interface retrieves a Session 12 version 1
   `security-release-attestation` into the approved temporary workspace. The attestation has
   `status=confirmed`, `authorization.status=authorized`, an external authorization record URL,
   and an external report location. Its `releaseBinding` names the release agent, approved
   baseline version, remediated version, and `versionsMatch=true`. It uses one configuration hash,
   records lower overall attack success, passes each complete per-risk row, records prohibited
   actions at zero attack success, and sets every payload flag, including
   `containsEvaluatorReasons`, to `false`. The security and change systems retain the
   authorization and report records. A pending, failed, incomplete, mismatched, or payload-bearing
   attestation stops promotion.
5. The promotion workflow uses the operational
   [Session 13](../../13-observability-cost-operations/implementation/README.md) smoke interface.
   Its JSON result must use `implementationSession:
   12-observability-cost-operations`, target the same `commitSha`, have status `passed`, mark
   `syntheticRequest`, `endToEndTrace`, and `toolAndModelFailureSeparated` as `passed`, set
   `sensitiveInputPresent` and `payloadsRetained` to `false`, and include distinct lower-case W3C
   trace IDs for the normal and expected-failure requests. The root `correlationId` must equal the
   normal trace ID. The result must also show stable telemetry ingestion, no polling timeout, a
   bounded attempt count of at least three, a timeout from 30 to 600 seconds, and a retry interval
   from 5 to 60 seconds. The timeout must allow at least two retry intervals.
   The protected `nonproduction` environment provides `SESSION12_SMOKE_URL`,
   `SESSION12_SMOKE_FAILURE_URL`, `SESSION12_AI_RESOURCE_ID`,
   `SESSION12_LOG_ANALYTICS_WORKSPACE_ID`. Store `SESSION12_SMOKE_BEARER_TOKEN` as an environment
   secret. Optional `SESSION12_SMOKE_TIMEOUT_SECONDS` and `SESSION12_SMOKE_RETRY_SECONDS` variables
   override the 180-second and 15-second defaults. The Session 13 smoke scripts perform the polling; Session 14
   invokes it and requires `checks.telemetryPollTimedOut=false`,
   `checks.releaseCommitShaVerified=true`, and `checks.workspaceBindingVerified=true` in the
   payload-free result. It also requires `checks.correlationIdsDistinct=true` and
   `checks.telemetryIngestionStable=true`.
6. The unit-check owner accepts the customer-owned unit script. It receives only `-Mode Ci` and
   `-CommitSha`, returns success or failure for that commit, and never reads a stored shell command.
7. The routing owner accepts the routing-control script described below.
8. The release owner accepts the customer-owned release/security-store script. It implements
   `Stage`, `Approve`, and `Retrieve` for the exact manifest, release ID, and SHA-256. It also
   implements `RetrieveEvaluationResult -RunId -OutputPath` and
   `RetrieveSecurityReleaseAttestation -AgentName -BaselineVersion -RemediatedVersion -OutputPath`.
   The two retrieval operations write a payload-free JSON artifact only under the approved
   temporary workspace. They never write to the repository, and `Retrieve` never returns a staged
   entry as an approved restore target.
9. The platform owner accepts the selected Bicep entrypoint and confirms it accepts both approved
   parameter files.
10. The GitHub administrator approves the environment protections and native secret controls. The
   Entra administrator accepts all four federated credentials and the two exact resource-group-scoped
   **Contributor** assignments. The release owner
   accepts the release-store operations. The delivery owner records each decision before live
   delivery.
11. The GitHub administrator authenticates `gh` with repository **Administration: read** and
    **Secret scanning alerts: read** permission so preflight can inspect all four environments,
    variables, nonproduction secret names, deployment branch policies, and open secret alerts.
    The Entra administrator gives the preflight operator recorded for this session a temporary
    **Directory Readers** activation at tenant scope. The operator also has **Contributor** at the
    exact nonproduction and production resource-group scopes so Azure can run both what-if
    operations. These human assignments expire or are removed after the ready check.
12. The release authority, quality and security authorities, production approver, routing authority,
    and delivery owner must be available for their live decisions.

### Required state when joining here

| Dependency | Required control state and exact configuration or record | Owner and observable result |
|---|---|---|
| Immutable agent | One release record associates the commit SHA with the agent name, prompt version, immutable agent version, model deployment alias, and both Bicep parameter files. | The platform owner retrieves those exact values and deploys them unchanged to nonproduction. |
| Gateway | A versioned APIM policy names stable and candidate selectors, and the approved routing control supports preview and restore. | The gateway owner confirms preview changes only those selectors, the candidate health check passes, and restore returns traffic to the exact previous selector. |
| Evaluation | The evaluation definition, active threshold policy, enabled release policy, and temporary external baseline and candidate records are available. | The AI quality owner sees the callable gate pass the matching candidate and the generated tool-process self-test return BLOCK. |
| Adversarial | A confirmed payload-free external security-release attestation identifies the immutable agent, approved baseline, remediated version, external authorization, and external report location. | The security owner confirms lower attack success, per-risk non-regression, blocked prohibited actions, matching versions, and no payload without treating SOC delivery as red-team proof. |
| Observability | The Session 13 smoke executables return the release commit, correlation ID, trace status, failure-boundary status, and payload-retention status. | The observability owner runs the executable for the same commit and gets a passing trace, separated failures, `sensitiveInputPresent: false`, and `payloadsRetained: false`. |

### Routing-control script interface

The approved workflows call the implementation repository's routing-control script. It uses the
existing traffic layer and may change only the selectors listed in `control-definition.json`.

| Mode | Workflow and inputs | What it does | Result |
|---|---|---|---|
| `Promote` | Promotion workflow: `Strategy`, `CandidateSelector`, `StableSelector`, and `ReleaseId` | Moves the approved traffic from the stable selector to the candidate selector for the named release. | Returns exit code zero only after the approved selector move completes. A failure stops release-record approval. |
| `Restore` with `WhatIf` | Restore workflow preview: `ApprovedManifestPath`, `ReleaseId`, and `WhatIf` | Checks the selected approved release and shows the exact stable-selector restore. | Makes no routing change. |
| `Restore` | Restore workflow: `ApprovedManifestPath` and `ReleaseId` | Returns the stable selector to the selected approved release. | Returns exit code zero only after that selector change completes. |

The script must reject any other selector, release ID, or free-form command. A nonzero exit stops
the workflow and leaves the staged release record unapproved until the approved restore process
runs.

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

Resolve every `__REQUIRED_*__` value in the
[`artifacts` tree](artifacts/README.md). In particular, decide:

- repository owner, name, protected default branch, and full-SHA action revisions;
- exact tenant ID, nonproduction and production workload client IDs, and Azure resource-group scopes;
- four Entra federated credential names and their exact environment subjects. On GitHub.com,
  repositories created, renamed, or transferred after 2026-07-15, plus repositories that opted in,
  use a default subject with immutable owner and repository IDs. Older repositories can keep the
  name-based form. Record
  the exact subject that this repository returns. Do not reconstruct it from an example;
- the built-in **Contributor** role, ID `b24988ac-6180-42a0-ab88-20f7382dd24c`, as the only Azure
  role on each workload service principal, assigned at its exact environment resource-group scope;
- nonproduction and production apply reviewer teams and prevent-self-review settings;
- production reviewer role, deployment branch or tag restriction, disabled administrator bypass,
  and whether the GitHub plan supports those protections;
- source paths for Bicep, the APIM policy, unit checks, Session 11 desired state, the Session 13
  smoke executable, routing, and the approved release/security-store interface;
- the approved 40-character commit supplied through `release_sha`, plus the agent name, prompt,
  agent version, model alias, APIM policy, evaluation run, and threshold policy;
- `canary` or `blue-green`, selectors, and whether the existing Session 05 or 06 path supports it;
  and
- the customer-approved release/security-store interface and its temporary external artifact
  workspace.

Stop before any administrative or deployment change if:

- a sentinel remains, an action uses a floating tag, or a component uses `latest` or `current`;
- the workflow runs from another ref or the approved release SHA is not reachable from the
  protected default branch;
- the commit, template digest, policy digest, or version can differ between stages;
- a client secret, broad repository permission, or subscription-wide role is proposed without a
  documented need;
- either OIDC subject is not scoped to its exact GitHub environment;
- native GitHub secret scanning or push protection is unavailable, disabled, or inaccessible;
- the customer plan does not expose the required production protections;
- production can be self-approved, reached from an unrestricted ref, or bypassed by an
  administrator;
- the external Session 12 security-release attestation is pending, failed, unauthorized, lacks a
  report location, does not bind the approved baseline and remediated release-agent versions,
  lacks per-risk non-regression, does not block prohibited actions, does not lower aggregate attack
  success, or contains payloads;
- the Session 13 check is missing, failed, for another commit, exposes sensitive input, retains
  payloads, lacks its correlation ID, or does not report successful bounded ingestion polling;
- a what-if contains unrelated or destructive change; or
- existing Session 05 or 06 routing cannot safely perform the selected canary or blue-green move.
  In that case, keep 100% on the previous approved release.

No AI-quality signal restores a previous release automatically.

## Implement

### 1. Resolve and check decisions before state changes

Edit the implementation JSON, parameter, and workflow definitions. Use unquoted JSON booleans for
Boolean decisions. Keep action pins as full 40-character commit SHAs. Preflight verifies the
origin, fetches the complete protected default-branch history from the approved `github.com` owner
and repository, and rejects an approved SHA outside that history. It accepts only standard GitHub
HTTPS and SSH origin forms. It never trusts an origin host from local Git configuration. Use Microsoft’s [Azure OIDC
guide](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
when checking the Entra federated credentials and environment-scoped workflow identity.
Then run the decision phase:

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

This phase names every unresolved decision, parses all JSON, checks repository and environment
metadata, source paths, policy, immutable versions, and action pins, then runs Bicep lint and
build. It changes no state.

### 2. Confirm accepted GitHub and Microsoft Entra controls

These controls are pre-session gates. Confirm their approved state through the customer's
administrative path:

1. verify accepted Entra workload identity federation credentials for all four GitHub environment
   subjects;
2. verify each stage service principal has only **Contributor** at its exact resource-group scope and has
   no inherited Azure role assignment;
3. verify GitHub environment variables `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`,
   `AZURE_SUBSCRIPTION_ID`, and `AZURE_RESOURCE_GROUP` match each preview and apply environment;
4. verify native GitHub secret scanning and push protection are enabled;
5. verify required reviewers and prevent self-review on both apply environments, plus the
   production branch or tag rule and disabled administrator bypass; and
6. confirm no Azure client secret is present.

If a protection is not exposed by the repository visibility or GitHub plan, stop. Do not represent
an unavailable setting as enabled.

### 3. Run the complete read-only preflight

Run:

```powershell
.\scripts\preflight.ps1 `
  -Phase Ready `
  -ApprovedNonproductionScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ApprovedProductionScope "/subscriptions/<id>/resourceGroups/<name>" `
  -ApprovedReleaseSha "<40-character-release-sha>" `
  -BaselineRecordPath "<temporary-session10-baseline-result.json>" `
  -CandidateRecordPath "<temporary-session10-candidate-result.json>" `
  -SecurityReleaseAttestationPath "<temporary-session11-attestation.json>"
```
```bash
./scripts/preflight.sh \
  --phase ready \
  --approved-nonproduction-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --approved-production-scope "/subscriptions/<id>/resourceGroups/<name>" \
  --approved-release-sha "<40-character-release-sha>" \
  --baseline-record-path "<temporary-session10-baseline-result.json>" \
  --candidate-record-path "<temporary-session10-candidate-result.json>" \
  --security-release-attestation-path "<temporary-session11-attestation.json>"
```

This phase reads GitHub plan and environment configuration, native secret controls, all four exact
federated-credential subjects, the two Contributor assignments, and repository metadata. It repeats
Bicep lint and build, then runs nonproduction and production what-if. Before the Ready phase, use
the approved release/security-store interface to stage the Session 11 baseline and candidate results
and Session 12 security-release attestation under the approved temporary workspace. Then pass those
three absolute paths to preflight. It rejects a repository path or a path outside that workspace.
It does not deploy or alter resources.

The platform owner inspects and approves the nonproduction and production previews. Stop on an
unrelated deletion, replacement, scope drift, inaccessible setting, or unexplained what-if result.

### 4. Confirm the accepted approved workflows

Install the reviewed workflow definitions at the agreed repository paths before the session.
Compare them with the implementation definitions. Do not install or reconfigure them during live delivery.

The accepted promotion workflow grants only `contents: read` and `security-events: read` by
default, adding `id-token: write` only to environment jobs. The restore workflow grants
`contents: read` by default and adds `id-token: write` only to its protected production job.

### 5. Run the intended promotion

Dispatch **Controlled AI release promotion** with the approved full SHA in `release_sha` and
`evaluation_record=candidate`.

The workflow invokes the Session 13 smoke interface in `Pipeline` mode for `nonproduction`, with
the selected release SHA and a result path in the GitHub runner's temporary workspace.

The workflow:

1. checks out the protected default branch with full history, verifies the workflow ref, and proves
   `release_sha` is an ancestor of that branch before checking out or running release content;
2. checks out `release_sha`, confirms `git rev-parse HEAD` matches it, then checks workflow
   structure, full action pins, native secret controls, unit
   checks, Session 11 evaluation gate, and the external Session 12 security-release attestation;
3. runs the generated blocked-tool-process self-test before any Azure preview or deployment;
4. signs in through `nonproduction-preview`, then lints, builds, and runs what-if;
5. pauses at protected `nonproduction`; after approval, deploys and runs the Session 13 smoke check;
6. signs in through `production-preview`, rechecks digests, and runs production what-if;
7. pauses at protected `production`; after approval, deploys the identical release;
8. creates the release record in the approved release store, where it remains unavailable to
   restore;
9. moves the approved canary or blue-green selector and checks the routing script result;
10. finalizes that exact staged release record as approved. If finalization fails, the workflow
   stops and an operator must dispatch the approved manual restore workflow.

Detailed build records remain in GitHub Actions. Evaluation records remain in Microsoft Foundry and
the approved external release platform. Security authorization and report records remain in the
approved security and change systems.

## Confirm the result

This is an extended session. **Run both paths, then stop for the release owner named in the policy.**

### Intended path

After the passing candidate run completes:

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

Expected result: the exact commit belongs to the protected default branch and its digests pass
unit, smoke, evaluation, and adversarial checks.
Each apply environment withholds OIDC values until its reviewer approves the preceding preview.
Nonproduction and production receive the same immutable release, and routing succeeds.
Only then does the release store mark the staged release record approved. The record links the
production workflow reference, nonproduction deployment, and selected routing strategy.

### Blocked/failure path

Dispatch the same workflow with
`evaluation_record=generated-blocked-tool-process-self-test`. This runs Session 11's stable
blocked check against a generated in-memory case.

For a local check before dispatch, run the stable Session 11 self-test from the implementation
directory:

```powershell
python ../../11-foundry-evaluations-quality-gates/implementation/scripts/test_release_gate.py `
  --mode blocked-tool-process
```
```bash
python ../../11-foundry-evaluations-quality-gates/implementation/scripts/test_release_gate.py \
  --mode blocked-tool-process
```

After that run completes:

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

Expected result: the Session 11 self-test returns BLOCK in the validation job. Both previews, both
approvals, and both deployments are skipped.

For a local implementation check before inspecting the remote run, use the validator pair that
`verify.sh` calls for the blocked path:

```powershell
.\artifacts\pipeline\validate-release.ps1 `
  -Mode Blocked `
  -ReleaseSha "<40-character-release-sha>"
```
```bash
./artifacts/pipeline/validate-release.sh \
  --mode blocked \
  --release-sha "<40-character-release-sha>"
```

### Delivery-owner checkpoint

Pause with the delivery owner after both results are visible in their native systems. The owner
confirms the intended run reached each protected apply checkpoint after its what-if, and the
generated blocked run never reached Azure preview or approval. If either sequence differs, keep the
previous approved release at 100% and correct the control before another run.

## After implementation

Keep the **workflow definitions and immutable release link**, environment parameter files, control
definition, release-record template, validator, and approved workflow revision. GitHub Actions
retains build, deployment, and environment approval metadata. Microsoft Foundry retains evaluation
and adversarial records. The approved external release platform retains Session 11 result records,
and the approved security and change systems retain Session 12 authorization and report records.
Azure retains deployment history. The promotion workflow writes the approved release-store record
after each successful production promotion, and the restore workflow reads it before a manual
restore. Do not copy those runtime records into this repository.

The release owner operates the workflows and maintains release-record continuity. GitHub and Entra
administrators maintain environment protections and federation. The platform owner maintains the
Bicep scopes and approves both what-if results. AI quality and security owners maintain the Session
10 and 11 gates. The observability owner maintains the Session 13 smoke interface. The gateway
owner controls routing. The delivery owner accepts the final checkpoint.

Restore is manual. Dispatch **Restore previous AI release** with the exact approved release ID and
recorded SHA-256 selected from the approved release store. Start with `dry_run=true`. The production
environment approval is required before the workflow reads production OIDC values. The workflow
retrieves the release record from the approved release store, validates its digest and
`implementationSession` marker, then previews the customer routing script. Only an explicit rerun
with `dry_run=false` moves the stable selector to that immutable release. The workflow preserves
current and older code, prompt, agent, model, APIM, evaluation, and deployment versions. It does
not broadly delete state.

Run this implementation only against the repository, two GitHub environments, two Azure
resource-group scopes, and routing selectors listed in the release policy. It does not authorize automatic
restore, replacement of shared gateway policy, or deletion of existing versions.
