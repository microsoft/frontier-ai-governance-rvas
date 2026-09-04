# Promote and operate the Citadel platform lifecycle

## Session scope

### What we will do

**Promote one immutable Citadel change and keep it operable afterward.** We will bind upstream commits, customer overlays, agent versions, contracts, gate results, and deployment parameters to one release; run protected promotion and restore paths; then add the deployed estate to lifecycle and retirement operations.

### Why it matters

Citadel spans several repositories and Azure control planes. Without one release identity, a reviewed contract can be promoted with another platform version or agent. The release record and estate report keep those parts connected after deployment.

### Boundaries

GitHub Actions controls the approved promotion path. Azure owns live deployment state, APIM owns routing, Foundry owns agent and model state, and the approved release store owns durable release records. The estate report reads live state; it does not replace those systems.

## Architecture

### Architecture at a glance

The full commit SHA identifies one release. Fixed digests bind the Citadel hub and spoke commits, customer overlays, agent version, contracts, evaluation and security results, and environment parameters. Protected preview and apply environments deploy the same release. The estate workbook then tracks live resources and retirement signals.

```text
release SHA -> gates -> nonproduction preview/apply -> production preview/apply
                                                       |
                                                 APIM selector
                                                       |
                                      release record and estate lifecycle
```

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Release identity | Full SHA and fixed component digests | Every stage names the same change | Corrections require a new release |
| Azure access | Environment-scoped OIDC | No stored Azure client secret | Trust and environment rules need maintenance |
| Restore | Manual protected workflow | Owner sees the selected release and route | Slower than automatic rollback |
| Estate | Live query plus shared workbook | Finds drift and retirement signals | Owners must resolve findings in source systems |

### Architecture guidance

- [Authenticate to Azure from GitHub Actions by OpenID Connect](https://learn.microsoft.com/azure/developer/github/connect-from-azure-openid-connect)
- [Deployments and environments](https://learn.microsoft.com/azure/developer/github/github-actions)
- [Microsoft Foundry model lifecycle](https://learn.microsoft.com/azure/foundry/openai/concepts/model-retirements)

## Before you start

Prepare the protected repository, default branch, four GitHub environments, exact Azure OIDC subjects, scoped deployment roles, required reviewers, secret protection, release store, previous approved release, Citadel source pins, overlays, gate records, smoke interface, routing selector, and estate scope.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Record | `artifacts/control-definition.json` | Citadel promotion workflows and validators |
| Deployment | `artifacts/github/promotion.yml` | GitHub Actions and the release operator |
| Deployment | `artifacts/github/restore-previous-release.yml` | GitHub Actions and the restore operator |
| Runtime | `artifacts/pipeline/release-manifest.template.json` | promotion workflow and approved release store |
| Runtime | `artifacts/pipeline/validate-release.ps1` | GitHub Actions workflow and PowerShell release operator |
| Runtime | `artifacts/pipeline/validate-release.sh` | Bash-based release operator |
| Deployment | `artifacts/environments/nonproduction.parameters.json` | nonproduction preview and apply jobs |
| Deployment | `artifacts/environments/production.parameters.json` | production preview and apply jobs |
| Record | `artifacts/estate/estate-scope.json` | estate report scripts and platform inventory owner |
| Deployment | `artifacts/estate/infra/main.bicep` | estate workbook deployment |
| Deployment | `artifacts/estate/monitoring/estate-lifecycle-workbook.json` | shared Azure Workbook |
| Runtime | `artifacts/estate/queries/foundry-accounts.kql` | estate report and Azure Resource Graph Explorer |
| Runtime | `artifacts/estate/queries/service-health-retirements.kql` | estate report and Azure Resource Graph Explorer |
| Runtime | `artifacts/estate/queries/advisor-retirement-findings.kql` | estate report and Azure Resource Graph Explorer |

## Decisions and stop conditions

Stop when an action uses a floating tag, a component uses `latest`, the release SHA is outside the protected branch, an OIDC subject differs from the observed GitHub subject, apply credentials are available before approval, gate or smoke records refer to another release, what-if contains unexplained changes, the previous release cannot be restored, or an estate finding has no owner.

## Implement

### 1. Complete the release and estate definitions

Resolve every `__REQUIRED_*__` value. Bind the pinned Citadel hub and spoke commits, customer overlays, agent version, contract digests, gate records, smoke contract, environment parameters, and APIM selector to the release SHA.

### 2. Run preflight

```powershell
.\scripts\preflight.ps1 -Phase Ready -ApprovedNonproductionScope $nonproductionScope -ApprovedProductionScope $productionScope -ApprovedReleaseSha $releaseSha -BaselineRecordPath $baselineRecord -CandidateRecordPath $candidateRecord -SecurityReleaseAttestationPath $securityRecord
```

```bash
./scripts/preflight.sh --phase ready --approved-nonproduction-scope "$nonproduction_scope" --approved-production-scope "$production_scope" --approved-release-sha "$release_sha" --baseline-record-path "$baseline_record" --candidate-record-path "$candidate_record" --security-release-attestation-path "$security_record"
```

Review both Azure what-if results before approval.

### 3. Promote the release

Install `promotion.yml` and `restore-previous-release.yml` through the normal repository change path. Dispatch the promotion workflow with the approved full SHA. It must run local validation, the Session 05 gate, the Session 06 smoke path, both previews, both protected apply stages, routing, and release-record approval in that order.

### 4. Deploy the estate workbook and run the report

```powershell
.\scripts\deploy-workbook.ps1
.\scripts\build-estate-report.ps1
```

```bash
./scripts/deploy-workbook.sh
./scripts/build-estate-report.sh
```

Assign every tag, network, region, lifecycle, Service Health, and Advisor finding to its owning platform or workload team.

## Confirm the result

### Intended path

```powershell
.\scripts\verify.ps1 -Check Intended -ReleaseSha $releaseSha -PromotionRunId $runId
```

```bash
./scripts/verify.sh --check intended --release-sha "$release_sha" --promotion-run-id "$run_id"
```

The same SHA reaches both apply environments after their previews, the selector moves once, the release record is approved, and the estate report includes the deployed Citadel resources.

### Blocked or failure path

Run the workflow with the generated blocked gate. Validation returns `BLOCK`, and no Azure preview, approval, deployment, route change, or release approval runs.

### Delivery-owner checkpoint

The delivery owner confirms both sequences. Keep the previous selector at 100 percent if either path differs.

## After implementation

The release owner manages promotion, action pins, restore, and release records. GitHub and Entra administrators manage environment protection and OIDC trust. Platform and workload owners resolve estate findings and plan Citadel upgrades. Restore through the approved release record and protected workflow. Do not delete shared state, logs, or earlier immutable releases as part of restore.
